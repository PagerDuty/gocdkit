if RUBY_ENGINE == 'ruby'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start
end

require 'json'
require 'gocdkit'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!(:allow => 'coveralls.io')

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before(:all) do
    # set things that need to available for all tests
  end
end

require 'vcr'
VCR.configure do |c|
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<GO_LOGIN>") do
    test_go_login
  end
  c.filter_sensitive_data("<GO_PASSWORD>") do
    test_go_password
  end

  c.before_http_request(:real?) do |request|
    next if request.headers['X-Vcr-Test-Repo-Setup']

    options = {
      :headers => {'X-Vcr-Test-Repo-Setup' => 'true'},
      :auto_init => true
    }

  end

  c.ignore_request do |request|
    !!request.headers['X-Vcr-Test-Repo-Setup']
  end

  c.default_cassette_options = {
    :serialize_with             => :json,
    # TODO: Track down UTF-8 issue and remove
    :preserve_exact_body_bytes  => true,
    :decode_compressed_response => true,
    :record                     => ENV['TRAVIS'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

def test_go_login
  ENV.fetch 'GOCDKIT_TEST_GO_LOGIN', 'go-go-gadget-go-cd'
end

def test_go_password
  ENV.fetch 'GOCDKIT_TEST_GO_PASSWORD', 'wow_such_password'
end

def stub_delete(url)
  stub_request(:delete, go_url(url))
end

def stub_get(url)
  stub_request(:get, go_url(url))
end

def stub_head(url)
  stub_request(:head, go_url(url))
end

def stub_patch(url)
  stub_request(:patch, go_url(url))
end

def stub_post(url)
  stub_request(:post, go_url(url))
end

def stub_put(url)
  stub_request(:put, go_url(url))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_response(file)
  {
    :body => fixture(file),
    :headers => {
      :content_type => 'application/json; charset=utf-8'
    }
  }
end

def go_url(url)
  return url if url =~ /^http/

  url = File.join(Gocdkit.api_endpoint, url)
  uri = Addressable::URI.parse(url)

  uri.to_s
end

def basic_gocd_url(path, options = {})
  url = File.join(Gocdkit.api_endpoint, path)
  uri = Addressable::URI.parse(url)

  uri.user = options.fetch(:login, test_go_login)
  uri.password = options.fetch(:password, test_go_password)

  uri.to_s
end

def basic_auth_client(login = test_go_login, password = test_go_password )
  client = Gocdkit.client
  client.login = test_go_login
  client.password = test_go_password

  client
end

def use_vcr_placeholder_for(text, replacement)
  VCR.configure do |c|
    c.define_cassette_placeholder(replacement) do
      text
    end
  end
end
