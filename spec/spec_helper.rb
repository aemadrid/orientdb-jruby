unless defined?(SPEC_HELPER_LOADED)

  GEM_ROOT  = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_ROOT  = GEM_ROOT + '/lib'
  SPEC_ROOT = GEM_ROOT + '/spec'
  TEMP_DIR  = SPEC_ROOT + '/tmp'

  TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"

  puts ">> GEM_ROOT     : #{GEM_ROOT}"
  puts ">> TEST_DB PATH : #{TEST_DB_PATH}"

  $LOAD_PATH.unshift(LIB_ROOT) unless $LOAD_PATH.include?(LIB_ROOT)

  require 'orientdb'
  require 'spec'
  require 'fileutils'

  FileUtils.mkdir_p TEST_DB_PATH

  Spec::Runner.configure do |config|
  end

  SPEC_HELPER_LOADED = true
end