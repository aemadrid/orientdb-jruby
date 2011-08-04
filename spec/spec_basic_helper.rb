GEM_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..'))
LIB_ROOT     = GEM_ROOT + '/lib'
SPEC_ROOT    = GEM_ROOT + '/spec'
TEMP_DIR     = SPEC_ROOT + '/tmp'
puts ">> GEM_ROOT     : #{GEM_ROOT}"

require 'orientdb'
require 'rspec'

require 'fileutils'

RSpec.configure do |config|
  config.color_enabled = true
end

class Developer

end
