raise "Rubyhaze only runs on JRuby. Sorry!" unless (RUBY_PLATFORM =~ /java/)

$: << File.dirname(__FILE__)
$: << File.expand_path('../../jars/', __FILE__)

require 'java'
require 'orientdb-client-0.9.23'

class OrientDB

  def self.const_missing(missing)
    puts "[#{name}:const_missing] #{missing}"
    super
  end

=begin
  def self.const_missing(name)
    name = name.to_s
    fname = File.dirname(__FILE__) / :models / name.snake_case + '.rb'
    if File.file?(fname)
      require fname
      Object.full_const_get "RCMS::" + name
    elsif name =~ /DO$/ && RCMS::Store.connected?
      found = RCMS::DataObjectDefinition.load_class(name)
      raise NameError, "uninitialized constant RCMS::#{name}" unless found
      found
    else
      super
    end
  end
=end

end

require 'orientdb/version'
require 'orientdb/proxy_mixin'
require 'orientdb/user'
require 'orientdb/database'
require 'orientdb/document'
require 'orientdb/oclass'
