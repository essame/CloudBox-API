require 'spec_helper.rb'

describe CloudBoxCommit do
  let(:resource) { 'currencies' }
  let(:resources_path) { './spec/resources' }
  let(:manifest_file_path) { './spec/lib/resources_manifest.yml' }

  context 'no resources files change' do
    it do
      expect(File).not_to receive(:open).with(manifest_file_path, 'w')
      described_class.commit_resources_files
    end
  end

  context 'change one resource file' do
    let(:new_manifest_data) do
      {
        'v' => 3,
        'path' => 'spec/resources/currencies.json',
        'hash' => 'ffc6d4081d6b2f9782e2d2e3358bac2c'
      }
    end

    before do
      allow(File).to receive(:read).with('spec/resources/options.json').and_call_original
      allow(File).to receive(:read).with('spec/resources/currencies.json').and_return('changed data file')
    end

    it do
      @buffer = StringIO.new()
      allow(File).to receive(:open).with(manifest_file_path, 'w').and_yield(@buffer)
      described_class.commit_resources_files
      expect(YAML.load(@buffer.string)['RESOURCES_FILES'][resource]).to eq(new_manifest_data)
    end
  end

  context 'add new resource file' do
    let(:resource) { 'new_resource' }
    let(:new_manifest_data) do
      {
        'v' => 1,
        'path' => './spec/resources/new_resource.ex',
        'hash' => 'd804ccc5afac7809487784df05d39b95'
      }
    end

    before do
      File.open("#{resources_path}/#{resource}.ex", 'w') { |f| f.write('new resource data') }
    end

    after do
      File.delete("#{resources_path}/#{resource}.ex")
    end

    it do
      @buffer = StringIO.new()
      allow(File).to receive(:open).with(manifest_file_path, 'w').and_yield(@buffer)
      described_class.commit_resources_files
      expect(YAML.load(@buffer.string)['RESOURCES_FILES'][resource]).to eq(new_manifest_data)
    end
  end

  context 'remove resource file' do
    let(:resource) { 'options' }
    let(:resource_path) { "#{resources_path}/#{resource}.json" }
    let!(:old_resource_data) { File.read(resource_path) }

    before do
      allow(File).to receive(:open).with('./spec/resources/options.json', 'w').and_call_original
      File.delete(resource_path)
    end

    after do
      File.open(resource_path, 'w') { |f| f.write(old_resource_data) }
    end

    it do
      @buffer = StringIO.new()
      allow(File).to receive(:open).with(manifest_file_path, 'w').and_yield(@buffer)
      described_class.commit_resources_files
      expect(YAML.load(@buffer.string)['RESOURCES_FILES'][resource]).to eq(nil)
    end
  end
end
