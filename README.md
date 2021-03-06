#Esio: Elasticsearch I/O

Esio is an Erlang library that provides an HTTP client for [Elasticsearch](https://www.elastic.co/products/elasticsearch), which offers a sophisticated [RESTful API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html). It implements a data access layer for Erlang applications and makes data and objects semantic-friendly with Erlang. 

Unlike other projects, Esio does not aim to provide a generic HTTP-proxy approach. Instead, it does the following: 
* uses an urn-base schema to resolve identity crises and the hierarchical nature of index/type/key notation
* offers query templates to counter the complexity of DSL 
* uses Actor models for data streaming
* provides Erlang-friendly pattern matching  

Esio is still under development. Supplementary files:
* [design considerations](doc/design.md)
* [usage examples](doc/example.md) 

[![Build Status](https://secure.travis-ci.org/zalando/esio.svg?branch=master)](http://travis-ci.org/zalando/esio)

### Installing/Using Esio

The latest version of Esio is available from the master branch. All development, including new features and bug fixes, take place on the master branch using forking and pull requests as described in the [contribution guidelines](doc/contribution.md). 

This library uses [rebar](https://github.com/rebar/rebar/wiki). Use the following code snippet to include Esio in your `rebar.config`:
```
   {esio, ".*",
      {git, "https://github.com/zalando/esio", {branch, master}}
   }
``` 

###Running `esio`
Details to come.

###Contributing
See [contribution guideline](doc/contribution.md) for details on PR submission.

###Bugs
See [bug reporting](doc/bugs.md) for guidelines on raising issues. Submit bugs to the [Issues Tracker](https://github.com/zalando/esio/issues). 

###Contact

* email: dmitry.kolesnikov@zalando.fi

### License

The MIT License (MIT)

Copyright (c) 2016 Zalando SE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
