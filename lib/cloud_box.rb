# cloud_box.rb
# CloudBox

# Created by Luka Mirosevic on 20/03/2013.
# Copyright (c) 2013 Goonbee. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'sinatra'
require 'sinatra/async'
require 'json'
require 'rainbows'
require 'eventmachine'
require 'json/minify'
require './lib/version.rb'
require './lib/abtesting.rb'
require './lib/cloud_box_helpers.rb'

############################################### CONFIG ###############################################

class CloudBox < Sinatra::Base
  include CloudBoxHelpers
  # register Sinatra::Async

  configure :development do
    USE_SSL = false
    set :bind, '0.0.0.0'
    $stdout.sync = false
  end

  configure :production do
    USE_SSL = true

    #New relic
    require 'newrelic_rpm'
  end

  configure :staging do
    USE_SSL = true
  end

  ############################################### Version #######################################################

  get "/version" do
    headers 'Content-Type' => "application/json"
    body(JSON.generate(VERSION))
  end

  get '/manifest' do
    headers 'Content-Type' => "application/json"
    @manifest ||= MANIFEST.map {|k, v| [k, v[:hash]]}.to_h
    body(JSON.generate(@manifest))
  end

  ############################################### A-B Testing #######################################################

  get "/abtesting" do
    headers 'Content-Type' => "application/json"
    body(JSON.generate(ABTESTING))
  end

  ############################################### CLOUDBOX META ###############################################

  get "/#{RESOURCES_META_PATH}/:resource" do
    resource = params[:resource].to_sym
    if RESOURCES_MANIFEST.include?(resource)
      #get the resource info
      resource_info = RESOURCES_MANIFEST[resource]
      version = resource_info[:v]
      if resource_info.has_key?(:url)
        url = resource_info[:url]
      elsif resource_info.has_key?(:path)
        url = public_url_for_resource(resource_info)
      else
        ahalt 404
      end
      data = MANIFEST[resource]

      #construct the meta obj
      meta_obj = {
        :v => version,
        :url => url,
        :md5 => data[:hash]
      }

      #return the meta JSON
      headers 'Content-Type' => "application/json"
      body(JSON.generate(meta_obj))
    else
      ahalt 404
    end
  end

  ############################################### LOCAL RESOURCES SERVER ###############################################
  # TODO remove it!
  get "/resources/:resource" do
    resource = params[:resource].split('.').first.to_sym
    data = MANIFEST[resource]
    if data
      headers(
        'Resource-Version'          => version_for_local_resource(resource).to_s,
        'Content-Length'            => data[:length],
        'Content-Type'              => 'application/octet-stream',
        'Content-Disposition'       => "attachment; filename=\"#{params[:resource]}\"",
        'Content-Transfer-Encoding' => 'binary'
      )

      body data[:content]
    else
      ahalt 404
    end
  end

  get "/#{RESOURCES_DATA_PATH}/:resource" do
    resource = params[:resource].split('.').first.to_sym

    #get path
    path = local_path_for_local_resource(resource)

    #make sure file exists
    if File.file?(path) and File.readable?(path)
      #get some info about file
      content = JSON.minify(File.read(path))
      length = content.length
      filename = path.split('/').last
      # filename = resource
      type = "application/octet-stream"
      disposition = "attachment; filename=\"#{filename}\""
      transfer_encoding = "binary"

      #set headers
      headers(
        'Resource-Version'          => version_for_local_resource(resource).to_s,
        'Content-Length'            => length.to_s,
        'Content-Type'              => type.strip,
        'Content-Disposition'       => disposition,
        'Content-Transfer-Encoding' => transfer_encoding
      )

      #send file
      body content
    else
      ahalt 404
    end
  end

  ############################################### PLUMBING ###############################################

  get '/alive' do
    body '777'
  end
end
