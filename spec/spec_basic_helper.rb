unless defined?(SPEC_BASIC_HELPER_LOADED)

  GEM_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_ROOT     = GEM_ROOT + '/lib'
  SPEC_ROOT    = GEM_ROOT + '/spec'
  TEMP_DIR     = SPEC_ROOT + '/tmp'
  puts ">> GEM_ROOT     : #{GEM_ROOT}"

  $LOAD_PATH.unshift(LIB_ROOT) unless $LOAD_PATH.include?(LIB_ROOT)

  require 'orientdb'
  require 'rspec'
  #require 'rspec/autorun'
  require 'fileutils'

  RSpec.configure do |config|
    config.color_enabled = true
  end

  class Developer

  end

  SPEC_BASIC_HELPER_LOADED = true
end