# -*- encoding: utf-8 -*-
require File.expand_path("../lib/orientdb/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "orientdb"
  s.version     = OrientDB::VERSION
  s.platform    = "jruby"
  s.authors     = ["Adrian Madrid"]
  s.email       = ["aemadrid@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/orientdb"
  s.summary     = "JRuby wrapper for OrientDB"
  s.description = "JRuby wrapper for OrientDB"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "orientdb"

  s.add_dependency "hashie"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "rspec", ">= 2.1"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = Dir["test/test*.rb"]
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
