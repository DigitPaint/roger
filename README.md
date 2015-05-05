# Roger

[![Gem Version](https://badge.fury.io/rb/roger.png)](http://badge.fury.io/rb/roger)
[![Build Status](https://travis-ci.org/DigitPaint/roger.png?branch=master)](https://travis-ci.org/DigitPaint/roger)

## What is it?

Roger is your friendly front-end development toolbox! It helps you with these 4 things:

1. **Generate** : Set up your projects
1. **Serve** : Development server
1. **Test** : Test/lint your stuff
1. **Release** : Release your code

## Get started

We assume you have a working Ruby 1.9.x or higher running.

1. Install Roger

    ```shell
    gem install roger
    ```

1. Create a new project

    ```shell
    mockup generate new PROJECT_DIR
    ```

    Replace `PROJECT_DIR` with your project name

1. Start the development server

    ```shell
    mockup serve
    ```

    Open your webbrowser and go to `http://localhost:9000/`

1. Release your project

    ```shell
    mockup release
    ```

## Where to go from here?

Read more documentation:

* [**Templating** Learn the power of Roger built in templating](doc/templating.md)
* [**CLI** Learn about the different `mockup` commands](doc/cli.md)
* [**Mockupfile** Learn how to configure and extend your Project](doc/mockupfile.md)

## Why?

When we started with Roger there was no Grunt/Gulp/whatever and with us being a Ruby shop we wrote Roger. Since its beginning it has evolved into quite a powerful tool. 

Why would Roger be better than any other?
It's not it just does some things differently.

* Ruby
* Code over configuration
* Based on little modules, simple to extend
* Streams & files
* 4 easy commands separate concerns

## Contributors

[View contributors](https://github.com/digitpaint/roger/graphs/contributors)

## Logos

![Logo Black/Yellow](https://raw.githubusercontent.com/DigitPaint/roger/master/doc/images/logo_black-yellow.svg)
![Logo Plain](https://raw.githubusercontent.com/DigitPaint/roger/master/doc/images/logo_plain.svg)

## License

(The MIT License)

Copyright (c) 2015 Digitpaint

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
