require 'helper'

describe Gocdkit do
  before do
    Gocdkit.reset!
  end

  after do
    Gocdkit.reset!
  end

  it "sets defaults" do
    Gocdkit::Configurable.keys.each do |key|
      expect(Gocdkit.instance_variable_get(:"@#{key}")).to eq(Gocdkit::Default.send(key))
    end
  end

  describe ".client" do
    it "creates an Gocdkit::Client" do
      expect(Gocdkit.client).to be_kind_of Gocdkit::Client
    end
    it "caches the client when the same options are passed" do
      expect(Gocdkit.client).to eq(Gocdkit.client)
    end
    it "returns a fresh client when options are not the same" do
      client = Gocdkit.client
      Gocdkit.login = "otherUser"
      Gocdkit.password = "otherPasswoooord"
      client_two = Gocdkit.client
      client_three = Gocdkit.client
      expect(client).not_to eq(client_two)
      expect(client_three).to eq(client_two)
    end
  end

  describe ".configure" do
    Gocdkit::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Gocdkit.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Gocdkit.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

end
