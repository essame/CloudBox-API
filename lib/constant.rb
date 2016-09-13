DEFAULT_ANDROID_MV = '1.0.0'
DEFAULT_ANDROID_LV = '1.0.0'
DEFAULT_IOS_MV = '1.0.0'
DEFAULT_IOS_LV = '1.0.0'
DEFAULT_API_SM = 'false'
DEFAULT_UPGRADE_TITLE = "Upgrade your App"
DEFAULT_UPGRADE_MESSAGE = "<b>We recently launched a new feature</b>"

RESOURCES_META_PATH = "GBCloudBoxResourcesMeta"
RESOURCES_DATA_PATH = "GBCloudBoxResourcesData"

DEFAULT_ABTESTING_ANDROID_RUNNING = 'false'
DEFAULT_ABTESTING_IOS_RUNNING = 'false'

ABTESTING = {
    androidRunning: ENV['ABTESTING_ANDROID_RUNNING'] || DEFAULT_ABTESTING_ANDROID_RUNNING,
    iosRunning: ENV['ABTESTING_IOS_RUNNING'] || DEFAULT_ABTESTING_IOS_RUNNING
}

MANIFEST = RESOURCES_MANIFEST.map do |fn, data|
  content = JSON.minify(File.read(data[:path]))
  { fn => { content: content,
            length: content.length.to_s,
            hash: Digest::MD5.hexdigest(content) } }
end.reduce(:merge)

ANDROID = {
  mv: ENV['ANDROID_MINIMUM_VERSION'] || DEFAULT_ANDROID_MV,
  lv: ENV['ANDROID_LATEST_VERSION'] || DEFAULT_ANDROID_LV,
  title: ENV['ANDROID_UPGRADE_TITLE'] || DEFAULT_UPGRADE_TITLE,
  message: ENV['ANDROID_UPGRADE_MESSAGE'] || DEFAULT_UPGRADE_MESSAGE
}

IOS = {
  mv: ENV['IOS_MINIMUM_VERSION'] || DEFAULT_IOS_MV,
  lv: ENV['IOS_LATEST_VERSION'] || DEFAULT_IOS_LV,
  title: ENV['IOS_UPGRADE_TITLE'] || DEFAULT_UPGRADE_TITLE,
  message: ENV['IOS_UPGRADE_MESSAGE'] || DEFAULT_UPGRADE_MESSAGE
}

API = {
  sm: ENV['API_SM'] || DEFAULT_API_SM
}

VERSION = {
  android: ANDROID,
  ios: IOS,
  api: API
}
