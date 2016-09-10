require 'rubygems'
require 'yaml'

Bundler.require :default, ENV['RACK_ENV'] || 'development'
Dotenv.load('.env', ".env.#{ENV['RACK_ENV']}")

resources_manifest_path = ".#{ENV['RACK_ENV'] == 'test' ? '/spec' : ''}/resources/resources_manifest.yml"
YAML.load_file(resources_manifest_path).each { |k, v| self.class.const_set(k, v) rescue nil }
RESOURCES_MANIFEST = RESOURCES_FILES.deep_symbolize_keys