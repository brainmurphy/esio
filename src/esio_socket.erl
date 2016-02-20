%%
%%   Copyright (C) 2016 Zalando SE
%%
%%   This software may be modified and distributed under the terms
%%   of the MIT license.  See the LICENSE file for details.
%%
%% @doc
%%   Elastic Search REST API socket
-module(esio_socket).
-behaviour(pipe).
-author('dmitry.kolesnikov@zalando.fi').

-export([
   start_link/2,
   init/1,
   free/2,
   handle/3
]).


%%-----------------------------------------------------------------------------
%%
%% factory
%%
%%-----------------------------------------------------------------------------

start_link(Uri, Opts) ->
   pipe:start_link(?MODULE, [Uri, Opts], []).   

init([Uri, Opts]) ->
   erlang:process_flag(trap_exit, true),
   Sock = knet:socket(Uri, Opts),
   {ok, handle, 
      #{
         sock => Sock, 
         uri  => Uri, 
         opts => Opts,
         req  => deq:new()
      }
   }.

free(_, #{sock := Sock}) ->
   knet:close(Sock).

%%-----------------------------------------------------------------------------
%%
%% state machine
%%
%%-----------------------------------------------------------------------------

%%
%% client requests
handle({put, _, _} = Put, Pipe, #{sock := Sock, uri := Uri, req := Req} = State) ->
   request(Sock, build_http_req(Uri, Put)),
   {next_state, handle, 
      State#{req := deq:enq(#{type => put, pipe => Pipe}, Req)}
   };   

handle({get, _} = Get, Pipe, #{sock := Sock, uri := Uri, req := Req} = State) ->
   request(Sock, build_http_req(Uri, Get)),
   {next_state, handle, 
      State#{req := deq:enq(#{type => get, pipe => Pipe}, Req)}
   };

handle({remove, _} = Remove, Pipe, #{sock := Sock, uri := Uri, req := Req} = State) ->
   request(Sock, build_http_req(Uri, Remove)),
   {next_state, handle, 
      State#{req := deq:enq(#{type => remove, pipe => Pipe}, Req)}
   };

%%
%% socket is terminated 
handle({sidedown, b, normal}, _, #{uri := Uri, opts := Opts} = State) ->
   Sock = knet:socket(Uri, Opts),
   {next_state, handle, 
      State#{sock => Sock}
   };

handle({sidedown, b, Reason}, _, State) ->
   {stop, Reason, State};

handle(close, _, State) ->
   {stop, normal, State};

%%
%% elastic search response
handle({http, _Sock, {Code, _Text, _Head, _Env}}, _Pipe, #{req := Req} = State) ->
   Head = deq:head(Req),
   {next_state, handle, 
      State#{req => deq:poke(Head#{code => Code, json => []}, deq:tail(Req))}
   };

handle({http, _Sock,  eof}, _Pipe, #{req := Req} = State) ->
   response(deq:head(Req)),
   {next_state, handle, 
      State#{req => deq:tail(Req)}
   };

handle({http, _Sock, Pack}, _Pipe, #{req := Req} = State) ->
   #{json := Json} = Head = deq:head(Req),
   {next_state, handle, 
      State#{req => deq:poke(Head#{json => [Pack|Json]}, deq:tail(Req))}
   }.


%%%----------------------------------------------------------------------------   
%%%
%%% private
%%%
%%%----------------------------------------------------------------------------   

%%
%% stream request to elastic search
request(Sock, Packets) ->
   lists:foreach(
      fun(X) ->
         knet:send(Sock, X)
      end,
      Packets
   ).

%%
%% stream response to client
response(#{type := put, code := Code, pipe := Pipe})
 when Code >= 200, Code < 300 ->
   %% TODO: how to handle meta-data about key (e.g. created and version)?
   %%   <<"{\"_index\":\"a\",\"_type\":\"b\",\"_id\":\"1\",\"_version\":1,\"created\":true}">>
   pipe:a(Pipe, ok);

response(#{type := put, code := Code, pipe := Pipe}) ->
   pipe:a(Pipe, {error, Code});

response(#{type := get, code := Code, pipe := Pipe, json := Json})
 when Code =:= 200 ->
   Val = jsx:decode(
      erlang:iolist_to_binary(
         lists:reverse(Json)
      ),
      [return_maps]
   ),
   pipe:a(Pipe, {ok, maps:get(<<"_source">>, Val)});

response(#{type := get, code := 404, pipe := Pipe}) ->
   pipe:a(Pipe, {error, not_found});

response(#{type := get, code := Code, pipe := Pipe}) ->
   pipe:a(Pipe, {error, Code});

response(#{type := remove, code := Code, pipe := Pipe})
 when Code >= 200, Code < 300 orelse Code =:= 404 ->
   pipe:a(Pipe, ok);

response(#{type := remove, code := Code, pipe := Pipe}) ->
   pipe:a(Pipe, {error, Code}).



%%
%% 
build_http_req(Uri, {put, Key, Val}) ->
   [
      {
         'PUT',
         urn_to_http_path(Uri, Key),
         [
            {'Content-Type',  {application, json}},
            {'Transfer-Encoding', <<"chunked">>},
            {'Connection',     'keep-alive'}
         ]
      },
      Val,
      eof
   ];

build_http_req(Uri, {get, Key}) ->
   [
      {
         'GET',
         urn_to_http_path(Uri, Key),
         [
            {'Accept',  'application/json'},
            {'Connection',    'keep-alive'}
         ]
      },
      eof
   ];

build_http_req(Uri, {remove, Key}) ->
   [
      {
         'DELETE',
         urn_to_http_path(Uri, Key),
         [
            {'Accept',  'application/json'},
            {'Connection',    'keep-alive'}
         ]
      },
      eof
   ].

%%
%%
urn_to_http_path(Uri, {urn, _, _} = Key) ->
   urn_to_http_path(Uri, uri:segments(Key));

urn_to_http_path(Uri, [_Cask, _Type, _Key] = List) ->
   uri:segments(List, Uri);

urn_to_http_path(Uri, [Cask, Key]) ->
   uri:segments([Cask, <<"default">>, Key], Uri).



      


