raise "Rubyhaze only runs on JRuby. Sorry!" unless (RUBY_PLATFORM =~ /java/)

$: << File.dirname(__FILE__)
$: << File.expand_path('../../jars/', __FILE__)

require 'java'
require 'orientdb-client-0.9.24'

module OrientDB

  def self.const_missing(missing)
    puts "[#{name}:const_missing] #{missing}"
    super
  end

end

require 'orientdb/ext'
require 'orientdb/constants'
require 'orientdb/version'
require 'orientdb/user'
require 'orientdb/property'
require 'orientdb/schema'
require 'orientdb/storage'
require 'orientdb/database'
require 'orientdb/record'
require 'orientdb/document'
require 'orientdb/sql_query'
require 'orientdb/sql'
require 'orientdb/oclass'
