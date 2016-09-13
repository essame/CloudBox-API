require 'rubygems'
require 'yaml'

Bundler.require :default, ENV['RACK_ENV'] || 'development'
Dotenv.load('.env', ".env.#{ENV['RACK_ENV']}")

MANIFEST_FILE_PATH = ".#{ENV['RACK_ENV'] == 'test' ? '/spec' : ''}/lib/resources_manifest.yml"
RESOURCES_FILES_PATH = ".#{ENV['RACK_ENV'] == 'test' ? '/spec' : ''}/resources/"

YAML.load_file(MANIFEST_FILE_PATH).each { |k, v| self.class.const_set(k, v) rescue nil }
RESOURCES_MANIFEST = RESOURCES_FILES.deep_symbolize_keys
