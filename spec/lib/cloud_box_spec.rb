require 'spec_helper.rb'

describe 'cloud box' do
  let(:android_version) do { mv: ENV['ANDROID_MINIMUM_VERSION'],
                             lv: ENV['ANDROID_LATEST_VERSION'],
                             title: ENV['ANDROID_UPGRADE_TITLE'],
                             message: ENV['ANDROID_UPGRADE_MESSAGE'] }
  end
  let(:ios_version) do { mv: ENV['IOS_MINIMUM_VERSION'],
                         lv: ENV['IOS_LATEST_VERSION'],
                         title: ENV['IOS_UPGRADE_TITLE'],
                         message: ENV['IOS_UPGRADE_MESSAGE'] }
  end

  it 'version' do
    get '/version'
    expect(parsed_response_symbolize[:android]).to eq(android_version)
    expect(parsed_response_symbolize[:ios]).to eq(ios_version)
    expect(parsed_response_symbolize[:api]).to eq({ sm: ENV['API_SM'] })
  end

  it 'manifest' do
    get '/manifest'
    expect(parsed_response.keys).to eq(RESOURCES_FILES.keys)
  end

  it 'abtesting' do
    get '/abtesting'
    expect(parsed_response_symbolize[:androidRunning]).to eq(ENV['ABTESTING_ANDROID_RUNNING'])
    expect(parsed_response_symbolize[:iosRunning]).to eq(ENV['ABTESTING_ANDROID_RUNNING'])
  end

  context 'meta resource' do
    let(:resource_meta_data) do { v: 1,
                                 url: 'http://example.org/GBCloudBoxResourcesData/options.json',
                                 md5: 'dba71e35e9c33d387d90510259ce05a5' }
    end
    let(:resource_file_name) { 'options.json' }

    it 'meta resource' do
      get 'GBCloudBoxResourcesMeta/options'
      expect(parsed_response_symbolize).to eq(resource_meta_data)
    end

    it 'resource not found' do
      get 'GBCloudBoxResourcesMeta/another_resource.json'
      expect(last_response.status).to eq(500)
    end

    it 'attachment meta resource' do
      get 'resources/options.json'
      expect(last_response['Content-Type']).to eq('application/octet-stream')
      expect(last_response['Content-Disposition']).to eq('attachment; filename="options.json"')
    end

    it 'resource not found' do
      get 'resources/another_resource.json'
      expect(last_response.status).to eq(500)
    end

    it 'attachment data resource file' do
      get 'GBCloudBoxResourcesData/options.json'
      expect(last_response['Content-Type']).to eq('application/octet-stream')
      expect(last_response['Content-Disposition']).to eq('attachment; filename="options.json"')
    end

    it 'resource not found' do
      get 'GBCloudBoxResourcesData/another_resource.json'
      expect(last_response.status).to eq(500)
    end
  end

  it 'alive' do
    get '/alive'
    expect(last_response.body).to eq('777')
  end
end