require 'yaml'
require 'digest/sha1'
require 'byebug'

module CloudBoxCommit
  module_function

  # => TODO in environment
  MANIFEST_FILE_PATH = ".#{ENV['RACK_ENV'] == 'test' ? '/spec' : ''}/lib/resources_manifest.yml"
  RESOURCES_FILES_PATH = ".#{ENV['RACK_ENV'] == 'test' ? '/spec' : ''}/resources/"
  RESOURCES_FILES = YAML.load_file(MANIFEST_FILE_PATH).each { |k, v| self.class.const_set(k, v) rescue nil }['RESOURCES_FILES']
  # to get deep clone copy
  NEW_RESOURCES_FILE = Marshal.load(Marshal.dump(RESOURCES_FILES))

  def new_file?(resource_path)
    # => TODO
    resource = resource_path.split('/').last.split('.').first
    unless RESOURCES_FILES[resource]
      # => TODO
      NEW_RESOURCES_FILE[resource] = {
        'v' => 0,
        'path' => resource_path,
        'hash' => file_hash(resource_path)
      }
      return true
    end
    return false
  end

  def file_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path))
  end

  def file_changed?(resource)
    resource_path = RESOURCES_FILES[resource]['path'] rescue nil
    return false unless resource_path
    # TODO
    NEW_RESOURCES_FILE[resource]['hash'] = file_hash(resource_path)
    NEW_RESOURCES_FILE[resource]['hash'] != RESOURCES_FILES[resource]['hash']
  end

  def increment_version(resource)
    old_version = RESOURCES_FILES[resource]['v'] rescue 0
    new_version = old_version + 1
    NEW_RESOURCES_FILE[resource]['v'] = new_version
    puts "increment #{resource} version from #{old_version} to #{new_version}"
    true
  end

  def update_manifest_file
    File.open(MANIFEST_FILE_PATH, 'w') { |f| YAML.dump({ 'RESOURCES_FILES' => NEW_RESOURCES_FILE }, f) }
  end

  def commit_resource_version(resource_path)
    # => TODO
    resource = resource_path.split('/').last.split('.').first
    return increment_version(resource) if file_changed?(resource) or new_file?(resource_path)
    false
  end

  def check_deleted_resources
    diff_res = (RESOURCES_FILES.keys - Dir[RESOURCES_FILES_PATH + '*.*'].map { |e| e.split('/').last.split('.').first })
    return false if diff_res.empty?
    diff_res.each { |res| NEW_RESOURCES_FILE[res] = nil }
    true
  end

  def commit_resources_files
    resources_commited = []
    Dir[RESOURCES_FILES_PATH + '*.*'].each do |resource_path|
      resources_commited << commit_resource_version(resource_path)
    end
    update_manifest_file if resources_commited.any? || check_deleted_resources
  end
end
