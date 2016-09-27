require 'spec_helper.rb'

describe 'cloud box', :type => :request do
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
    let(:resource_meta_data) do { v: 2,
                                 url: 'http://example.org/CloudBoxAPIResourcesData/currencies.json',
                                 md5: '3d58ccdfe3db28ae6ca03eead42924be' }
    end
    let(:resource_file_name) { 'currencies.json' }

    it 'meta resource' do
      get 'CloudBoxAPIResourcesMeta/currencies'
      expect(parsed_response_symbolize).to eq(resource_meta_data)
    end

    it 'meta resource with extention' do
      get 'CloudBoxAPIResourcesMeta/currencies.json'
      expect(parsed_response_symbolize).to eq(resource_meta_data)
    end

    it 'resource not found' do
      get 'CloudBoxAPIResourcesMeta/another_resource.json'
      expect(last_response.status).to eq(404)
    end

    it 'attachment meta resource' do
      get 'resources/currencies.json'
      expect(last_response['Content-Type']).to eq('application/octet-stream')
      expect(last_response['Content-Disposition']).to eq('attachment; filename="currencies.json"')
    end

    it 'resource not found' do
      get 'resources/another_resource.json'
      expect(last_response.status).to eq(404)
    end

    it 'attachment data resource file' do
      get 'CloudBoxAPIResourcesData/currencies.json'
      expect(last_response['Content-Type']).to eq('application/octet-stream')
      expect(last_response['Content-Disposition']).to eq('attachment; filename="currencies.json"')
    end

    it 'resource not found' do
      get 'CloudBoxAPIResourcesData/another_resource.json'
      expect(last_response.status).to eq(404)
    end
  end

  it 'alive' do
    get '/alive'
    expect(last_response.body).to eq('777')
  end
end