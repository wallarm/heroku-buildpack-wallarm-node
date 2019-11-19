# Update unicorn application

#### Add Wallarm Node buildpack

```bash
heroku buildpacks:add https://github.com/wallarm/heroku-buildpack-wallarm-node.git
```


#### Update unicorn configuration

It should:
* listen on `/tmp/nginx.socket` unix socket when wallarm filtering enabled;
* creates `/tmp/app-initialized` file for coordinate start with nginx.

```ruby
require 'fileutils'

wallarm_enabled = %w[yes Yes false False].include? ENV['WALLARM_ENABLED']

if wallarm_enabled
  listen '/tmp/nginx.socket'
  before_fork do |server,worker|
    FileUtils.touch('/tmp/app-initialized')
  end
else
  listen ENV['PORT']
end
```


#### Update Procfile

Prepend corresponding dynos start command with `wallarm/bin/start-wallarm`:
```
web: wallarm/bin/start-wallarm bundle exec unicorn -c config/unicorn.rb
```


#### Configure & push the Heroku app:

```bash
git add Procfile
git commit -m 'Update procfile for Wallarm Node buildpack'
git add config/unicorn.rb
git commit -m 'Update unicorn config to listen on NGINX socket.'
heroku config:set WALLARM_USER <your email>
heroku config:set WALLARM_PASSWORD <your password>
git push
```


#### Check the app:

```bash
heroku open
```
