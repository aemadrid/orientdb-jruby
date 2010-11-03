raise "Rubyhaze only runs on JRuby. Sorry!" unless (RUBY_PLATFORM =~ /java/)

$: << File.dirname(__FILE__)
path = File.expand_path('../../jars/', __FILE__)
puts "path : #{path}"
$: << path

require 'java'
require 'orientdb-client-0.9.23'

module OrientDB
end

require 'orientdb/version'
require 'orientdb/mixins/proxy'
require 'orientdb/user'
require 'orientdb/database'
require 'orientdb/document'
