require 'sinatra'
require 'sinatra/async'
require 'json'
require 'rainbows'
require 'eventmachine'
require 'json/minify'
require './lib/constant.rb'

module CloudBoxHelpers
  # => TODO
  MANIFEST = RESOURCES_MANIFEST.map do |fn, data|
    content = JSON.minify(File.read(data[:path]))
    { fn => { content: content,
              length: content.length.to_s,
              hash: Digest::MD5.hexdigest(content) } }
  end.reduce(:merge)

  def public_url_for_resource(resource)
    protocol = CloudBox::USE_SSL ? "https" : "http"
    "#{protocol}://#{request.host_with_port}/#{RESOURCES_DATA_PATH}/#{resource[:path].split('/').last}"
  end

  def local_path_for_local_resource(resource)
    if RESOURCES_MANIFEST.has_key?(resource)
      RESOURCES_MANIFEST[resource][:path]
    else
      ''
    end
  end

  def version_for_local_resource(resource)
    if RESOURCES_MANIFEST.has_key?(resource)
      RESOURCES_MANIFEST[resource][:v]
    else
      nil
    end
  end
end
