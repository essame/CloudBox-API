ENV['RACK_ENV'] = 'test'
require 'test/unit'
require 'rack/test'
require 'rspec'
require 'sinatra/async'
require 'sinatra/async/test'
require 'byebug'

root = Pathname.new(File.expand_path('../..', __FILE__))
require root.join('config/environment.rb')
require root.join('lib/cloud_box.rb')
require root.join('lib/cloud_box_commit.rb')
require File.expand_path '../helpers.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  include Test::Unit::Assertions
  include Sinatra::Async::Test::Methods

  def app
    CloudBox
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Helpers
end
