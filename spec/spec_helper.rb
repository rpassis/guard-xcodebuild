$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "guard/xcodebuild"
require "factory"

def fixture_path(*path)
  File.join(File.dirname(__FILE__), 'fixtures', *path)
end