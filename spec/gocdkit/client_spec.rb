require 'helper'
require 'json'

describe Gocdkit::Client do

  before do
    Gocdkit.reset!
  end

  after do
    Gocdkit.reset!
  end

  describe "module configuration" do

    before do
      Gocdkit.reset!
      Gocdkit.configure do |config|
        Gocdkit::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      Gocdkit.reset!
    end

    it "inherits the module configuration" do
      client = Gocdkit::Client.new
      Gocdkit::Configurable.keys.each do |key|
        expect(client.instance_variable_get(:"@#{key}")).to eq("Some #{key}")
      end
    end

    describe "with class level configuration" do

      before do
        @opts = {
          :connection_options => {:ssl => {:verify => false}},
          :login    => "acooldudewithshades",
          :password => "yeaaaaaaaaahhhhh"
        }
      end

      it "overrides module configuration" do
        client = Gocdkit::Client.new(@opts)
        expect(client.login).to eq("acooldudewithshades")
        expect(client.instance_variable_get(:"@password")).to eq("yeaaaaaaaaahhhhh")
      end

      it "can set configuration after initialization" do
        client = Gocdkit::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
        expect(client.login).to eq("acooldudewithshades")
        expect(client.instance_variable_get(:"@password")).to eq("yeaaaaaaaaahhhhh")
      end

      it "masks passwords on inspect" do
        client = Gocdkit::Client.new(@opts)
        inspected = client.inspect
        expect(inspected).not_to include("yeaaaaaaaaahhhhh")
      end

      describe "with .netrc" do
        before do
          File.chmod(0600, File.join(fixture_path, '.netrc'))
        end

        it "can read .netrc files" do
          Gocdkit.reset!
          client = Gocdkit::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
          expect(client.login).to eq("gouser")
          expect(client.instance_variable_get(:"@password")).to eq("il0veruby")
        end

      end
    end
  end

  describe "content type" do
    it "sets a default Content-Type header" do
      root_request = stub_get("").
        with({:headers => {"Content-Type" => "application/json"}})
      Gocdkit.client.get "", {}
      assert_requested root_request
    end
  end

  describe "authentication" do
    before do
      Gocdkit.reset!
      @client = Gocdkit.client
    end

    describe "with module level config" do
      before do
        Gocdkit.reset!
      end
      it "sets basic auth creds with .configure" do
        Gocdkit.configure do |config|
          config.login = 'pengwynn'
          config.password = 'il0veruby'
        end
        expect(Gocdkit.client).to be_basic_authenticated
      end
      it "sets basic auth creds with module methods" do
        Gocdkit.login = 'pengwynn'
        Gocdkit.password = 'il0veruby'
        expect(Gocdkit.client).to be_basic_authenticated
      end
    end

    describe "with class level config" do
      it "sets basic auth creds with .configure" do
        @client.configure do |config|
          config.login = 'pengwynn'
          config.password = 'il0veruby'
        end
        expect(@client).to be_basic_authenticated
      end
      it "sets basic auth creds with instance methods" do
        @client.login = 'pengwynn'
        @client.password = 'il0veruby'
        expect(@client).to be_basic_authenticated
      end
    end

    describe "when basic authenticated"  do
      it "makes authenticated calls" do
        Gocdkit.configure do |config|
          config.login = 'pengwynn'
          config.password = 'il0veruby'
        end

        pipeline_groups_request = stub_get("http://localhost:8153/go/api/config/pipeline_groups")
        Gocdkit.client.get("/go/api/config/pipeline_groups")
        assert_requested pipeline_groups_request
      end
    end

  end

  describe ".agent" do
    before do
      Gocdkit.reset!
    end
    it "acts like a Sawyer agent" do
      expect(Gocdkit.client.agent).to respond_to :start
    end
    it "caches the agent" do
      agent = Gocdkit.client.agent
      expect(agent.object_id).to eq(Gocdkit.client.agent.object_id)
    end
  end # .agent

  describe ".last_response" do
    it "caches the last agent response" do
      Gocdkit.reset!
      client = Gocdkit.client
      expect(client.last_response).to be_nil
      stub_get("some/end/point").
        to_return(:status => 200)
      client.get "some/end/point"
      expect(client.last_response.status).to eq(200)
    end
  end # .last_response

  describe ".get" do
    before(:each) do
      Gocdkit.reset!
    end
    it "handles query params" do
      stub_get("config/pipeline_groups").
        with(:query => {:foo => "bar"})
      Gocdkit.get "config/pipeline_groups", :foo => "bar"
      assert_requested :get, "http://localhost:8153/go/api/config/pipeline_groups?foo=bar"
    end
    it "handles headers" do
      request = stub_get("admin/config.xml").
        with(:query => {:foo => "bar"}, :headers => {:accept => "application/xml"})
      Gocdkit.get "admin/config.xml", :foo => "bar", :accept => "application/xml"
      assert_requested request
    end
  end # .get

  describe ".head" do
    it "handles query params" do
      Gocdkit.reset!
      request = stub_head("something").
        with(:query => {:foo => "bar"})
      Gocdkit.head "something", :foo => "bar"
      assert_requested request
    end
    it "handles headers" do
      Gocdkit.reset!
      request = stub_head("something").
        with(:query => {:foo => "bar"}, :headers => {:accept => "text/plain"})
      Gocdkit.head "something", :foo => "bar", :accept => "text/plain"
      assert_requested request
    end
  end # .head

  describe "when making requests" do
    before do
      Gocdkit.reset!
      @client = Gocdkit.client
    end
    it "allows Accept'ing another media type" do
      root_request = stub_get("").
        with(:headers => {:accept => "application/xml"})
      @client.get "", :accept => "application/xml"
      assert_requested root_request
      expect(@client.last_response.status).to eq(200)
    end
    it "sets a default user agent" do
      root_request = stub_get("").
        with(:headers => {:user_agent => Gocdkit::Default.user_agent})
      @client.get ""
      assert_requested root_request
      expect(@client.last_response.status).to eq(200)
    end
    it "sets a custom user agent" do
      user_agent = "Mozilla/5.0 I am Spartacus!"
      root_request = stub_get("").
        with(:headers => {:user_agent => user_agent})
      client = Gocdkit::Client.new(:user_agent => user_agent)
      client.get ""
      assert_requested root_request
      expect(client.last_response.status).to eq(200)
    end
    it "sets a proxy server" do
      Gocdkit.configure do |config|
        config.proxy = 'http://proxy.example.com:80'
      end
      conn = Gocdkit.client.send(:agent).instance_variable_get(:"@conn")
      expect(conn.proxy[:uri].to_s).to eq('http://proxy.example.com')
    end
    it "passes along request headers for POST" do
      headers = {"X-CRUISE-CONFIG-MD5" => "bar"}
      root_request = stub_post("").
        with(:headers => headers).
        to_return(:status => 201)
      client = Gocdkit::Client.new
      client.post "", :headers => headers
      assert_requested root_request
      expect(client.last_response.status).to eq(201)
    end
  end

  context "error handling" do
    before do
      VCR.turn_off!
      Gocdkit.reset!
    end

    it "raises on 404" do
      stub_get('booya').to_return(:status => 404)
      expect { Gocdkit.get('booya') }.to raise_error Gocdkit::NotFound
    end

    it "raises on 500" do
      stub_get('boom').to_return(:status => 500)
      expect { Gocdkit.get('boom') }.to raise_error Gocdkit::InternalServerError
    end

    it "raises unauthorized on 401" do
      stub_get('some/admin/stuffs').to_return(:status => 401)
      expect { Gocdkit.get('some/admin/stuffs') }.to raise_error Gocdkit::Unauthorized
    end

    it "raises on unknown client errors" do
      stub_get('users').to_return \
        :status => 418,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "I'm a teapot"}.to_json
      expect { Gocdkit.get('users') }.to raise_error Gocdkit::ClientError
    end

    it "raises on unknown server errors" do
      stub_get('users').to_return \
        :status => 509,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "Bandwidth exceeded"}.to_json
      expect { Gocdkit.get('users') }.to raise_error Gocdkit::ServerError
    end

    it "handles an error response with an array body" do
      stub_get('users').to_return \
        :status => 500,
        :headers => {
          :content_type => "application/json"
        },
        :body => [].to_json
      expect { Gocdkit.get('users') }.to raise_error Gocdkit::ServerError
    end
  end
end
