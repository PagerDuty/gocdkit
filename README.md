# Deprecated
This repository is no longer maintained.

# Gocdkit

Ruby toolkit for the [go-server][go-server] API. Client code forked from octokit.rb
[go-server]: http://go.cd

```ruby
# Provide authentication credentials
Gocdkit.configure do |c|
  c.login = 'i_am_a_go_user'
  c.password = 'continuous_delivery_R0X'
end

# Fetch all pipelines
Gocdkit.pipelines
```
or

```ruby
# Provide authentication credentials
client = Gocdkit::Client.new(:login => 'i_am_a_go_user', :password => 'continuous_delivery_R0X')
# Fetch all pipelines
client.pipelines
```

### Accessing HTTP responses

While most methods return a `Resource` object, sometimes you may
need access to the raw HTTP response headers. You can access the last HTTP
response with `Client#last_response`:

```ruby
config      = Gocdkit.config
response    = Gocdkit.last_response
# TODO finish example
```

## Authentication

### Basic Http Auth

```ruby
client = Gocdkit::Client.new \
  :login    => 'i_am_a_go_user',
  :password => 'continuous_delivery_R0X'

user = client.user
user.login
# => "i_am_a_go_user"
```

### Using a .netrc file

Gocdkit supports reading credentials from a netrc file (defaulting to
`~/.netrc`).  Given these lines in your netrc:

```
machine my.go.server
  login i_am_a_go_user
  password continuous_delivery_R0X
```
You can now create a client with those credentials:

```ruby
client = Gocdkit::Client.new(:netrc => true)
client.login
# => "i_am_a_go_user"
```

## Configuration and defaults

While `Gocdkit::Client` accepts a range of options when creating a new client
instance, Gocdkit's configuration API allows you to set your configuration
options at the module level. This is particularly handy if you're creating a
number of client instances based on some shared defaults.

### Configuring module defaults

Every writable attribute in {Gocdkit::Configurable} can be set one at a time:

```ruby
Gocdkit.api_endpoint = 'http://my.go.server/go/api'
Gocdkit.web_endpoint = 'http://my.go.server/go'
```

or in batch:

```ruby
Gocdkit.configure do |c|
  c.api_endpoint = 'http://my.go.server/go/api'
  c.web_endpoint = 'http://my.go.server/go'
end
```

### Using ENV variables

Default configuration values are specified in {Gocdkit::Default}. Many
attributes will look for a default value from the ENV before returning
Gocdkit's default.

```ruby
# Given $GOCDKIT_API_ENDPOINT is "http://my.go.server/go/api"
Gocdkit.api_endpoint

# => "http://my.go.server/go/api"
```

Deprecation warnings and API endpoints in development preview warnings are
printed to STDOUT by default, these can be disabled by setting the ENV
`GOCDKIT_SILENT=true`.

## Advanced usage

Since Gocdkit employs [Faraday][faraday] under the hood, some behavior can be
extended via middleware.

### Debugging

Often, it helps to know what Gocdkit is doing under the hood. You can add a
logger to the middleware that enables you to peek into the underlying HTTP
traffic:

```ruby
stack = Faraday::RackBuilder.new do |builder|
  builder.response :logger
  builder.use Gocdkit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Gocdkit.middleware = stack
Gocdkit.user 'oh_nooo'
```

See the [Faraday README][faraday] for more middleware magic.

## Hacking on Gocdkit.rb

If you want to hack on Gocdkit locally, we try to make [bootstrapping the
project][bootstrapping] as painless as possible. To start hacking, clone and run:

    script/bootstrap

This will install project dependencies and get you up and running. If you want
to run a Ruby console to poke on Gocdkit, you can crank one up with:

    script/console

Using the scripts in `./scripts` instead of `bundle exec rspec`, `bundle
console`, etc.  ensures your dependencies are up-to-date.

### Running and writing new tests

Gocdkit uses [VCR][] for recording and playing back API fixtures during test
runs. These cassettes (fixtures) are part of the Git project in the `spec/cassettes`
folder. If you're not recording new cassettes you can run the specs with existing
cassettes with:

    script/test

Gocdkit uses environmental variables for storing credentials used in testing.
If you are testing an API endpoint that doesn't require authentication, you
can get away without any additional configuration. Here is the full list of configurable environmental variables for testing
Gocdkit:

ENV Variable | Description |
:-------------------|:-----------------|
`GOCDKIT_TEST_LOGIN`| GitHub login name (preferably one created specifically for testing against).
`GOCDKIT_TEST_PASSWORD`| Password for the test GitHub login.

## Supported Ruby Versions

This library was tested against the following Ruby
implementations:

* Ruby 2.1.4
