# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "orientdb/version"

Gem::Specification.new do |s|
  s.name = %q{orientdb}
  s.version = OrientDB::VERSION
  s.platform = %q{jruby}

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adrian Madrid"]
  s.date = %q{2011-02-01}
  s.default_executable = %q{orientdb_console}
  s.description = %q{Simple JRuby wrapper for the OrientDB.}
  s.email = ["aemadrid@gmail.com"]

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = %q{http://rubygems.org/gems/orientdb}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{orientdb}
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{JRuby wrapper for OrientDB}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.4"])
    else
      s.add_dependency(%q<awesome_print>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.4"])
    end
  else
    s.add_dependency(%q<awesome_print>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.4"])
  end
end

