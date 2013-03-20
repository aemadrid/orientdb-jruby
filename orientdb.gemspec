# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orientdb/version'

Gem::Specification.new do |gem|
  gem.name          = %q{orientdb}
  gem.version       = OrientDB::VERSION
  gem.authors = [%q{Adrian Madrid}]
  gem.date = %q{2012-01-24}
  gem.description = %q{Simple JRuby wrapper for the OrientDB.}
  gem.homepage = %q{http://rubygems.org/gems/orientdb}
  gem.rubyforge_project = %q{orientdb}
  gem.summary = %q{JRuby wrapper for OrientDB}
  gem.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.platform = 'java'

  gem.add_development_dependency(%q<awesome_print>, [">= 0"])
  gem.add_development_dependency(%q<rspec>, [">= 2.4"])
  gem.add_development_dependency("pry")

end


