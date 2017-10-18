# Heroku Buildpack: Wallarm Node

The Wallarm Node buildpack provides Wallarm WAF inside a dyno and connects NGINX to an app server via UNIX domain sockets.
This buildpack is based on `heroku-buildpack-nginx`.

## Wallarm Node

Wallarm Node does the following:

* Blocks malicious requests and filters the valid ones
* Analyzes the company's entire network traffic
* Collects the network traffic metrics and uploads the metrics to the Wallarm cloud
* Downloads fine-tuned resource-specific rules from the Wallarm cloud

## Versions

This buildpack updates automatically and installs the latest stable version of Wallarm Node.

## Requirements

* You have a Wallarm account with deploy permissions.
* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.
* You can start your web server with a shell command.

## Features

* Protects your resources from hacker attacks.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if a NGINX or an app server crashes. Safety first.
* Language/App Server agnostic.
* Customizable NGINX configuration.
* Application coordinated dyno starts.

### Language/App Server Agnostic

The Wallarm Node buildpack provides the `wallarm/bin/start-wallarm` command. This command takes another command as an argument. You must pass your app server's startup command to `start-wallarm`.

For example, to get Wallarm Node and Unicorn up and running:

```bash
$ cat Procfile
web: wallarm/bin/start-wallarm bundle exec unicorn -c config/unicorn.rb
```

### Environment variables

You can use the following environment variables:

`WALLARM_USER` - The user at my.wallarm.com that has rights to add new nodes.
`WALLARM_PASSWORD` - The user password.
`WALLARM_MODE` - The request handling mode: `off`, `monitoring` (default), `block`.
`WALLARM_TARANTOOL_MEMORY` - The amount of memory in gigabytes allocated to postanalytics (0.5 of total memory by default).

For example, to set your `WALLARM_MODE` to the blocking mode:

```bash
$ heroku config:set WALLARM_MODE=block
```

### Customizable NGINX configuration

You can provide your own NGINX configuration by creating a file named `nginx.conf.erb` in the directory `wallarm/etc`. Start by copying the buildpack's [default config file](https://github.com/wallarm/heroku-buildpack-wallarm-node/blob/master/nginx.conf.erb).

### Application/Dyno coordination

The buildpack will not start NGINX with the Wallarm module until a file is written to `/tmp/app-initialized`. Since NGINX binds to the dyno's $PORT and since $PORT determines if the app can receive traffic, you can delay NGINX accepting traffic until your application is ready to handle it. The examples below show how/when you should write the file when working with Unicorn.

## Setup

Here are 2 setup examples. One example is for a new app; another one is for an existing app. In both cases, we are using Ruby & Unicorn. Keep in mind that this buildpack is not Ruby specific.

### Existing App

Update Buildpacks
```bash
$ heroku buildpacks:add https://github.com/wallarm/heroku-buildpack-wallarm-node.git
```
Update Procfile:
```
web: wallarm/bin/start-wallarm bundle exec unicorn -c config/unicorn.rb
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for Wallarm Node buildpack'
```
Update Unicorn configuration:
```ruby
require 'fileutils'
listen '/tmp/nginx.socket'
before_fork do |server,worker|
  FileUtils.touch('/tmp/app-initialized')
end
```
```bash
$ git add config/unicorn.rb
$ git commit -m 'Update unicorn config to listen on NGINX socket.'
```
Connect to the Wallarm cloud:
```
heroku config:set WALLARM_USER <your email>
heroku config:set WALLARM_PASSWORD <your password>
```
Deploy the changes:
```bash
$ git push heroku master
```

### New App

```bash
$ mkdir myapp; cd myapp
$ git init
```

**Gemfile**
```ruby
source 'https://rubygems.org'
gem 'unicorn'
```

**config.ru**
```ruby
run Proc.new {[200,{'Content-Type' => 'text/plain'}, ["hello world"]]}
```

**config/unicorn.rb**
```ruby
require 'fileutils'
preload_app true
timeout 5
worker_processes 4
listen '/tmp/nginx.socket', backlog: 1024

before_fork do |server,worker|
  FileUtils.touch('/tmp/app-initialized')
end
```
Install Gems:
```bash
$ bundle install
```
Create Procfile
```
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```
Create & push the Heroku app:
```bash
$ heroku create
$ heroku buildpacks:add heroku/ruby
$ heroku buildpacks:add https://github.com/wallarm/heroku-buildpack-wallarm-node.git
$ heroku config:set WALLARM_USER <your email>
$ heroku config:set WALLARM_PASSWORD <your password>
$ git add .
$ git commit -am "init"
$ git push heroku master
$ heroku logs -t
```
Check the app:
```
$ heroku open
```

## License
Copyright (c) 2017 Wallarm, Inc.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
