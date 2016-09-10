source 'https://rubygems.org'

ruby '2.3.0'

gem 'dotenv'
gem 'sinatra'
gem 'async_sinatra'
gem 'rainbows'
gem 'eventmachine', '1.0.9.1'
gem 'json-minify'
gem 'foreman'
gem 'hashr'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
  gem 'test-unit'
  gem 'byebug'
  gem 'rspec-rainbow'
end
