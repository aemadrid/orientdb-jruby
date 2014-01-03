require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

#
# Test a local database:
# rake spec
#
# Test a remote database:
# ORIENTDB_TEST_URL=remote:localhost/test ORIENTDB_TEST_USERNAME=admin ORIENTDB_TEST_PASSWORD=admin ORIENTDB_TEST_POOLED=true rake spec
#
# Test a pooled remote database:
# ORIENTDB_TEST_URL=remote:localhost/test ORIENTDB_TEST_USERNAME=admin ORIENTDB_TEST_PASSWORD=admin ORIENTDB_TEST_POOLED=true rake spec
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orientdb/version'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'orientdb'
  gem.version = OrientDB::VERSION
  gem.homepage = 'http://github.com/aemadrid/orientdb-jruby'
  gem.summary = 'Simple JRuby wrapper for the OrientDB.'
  gem.description = 'Simple JRuby wrapper for the OrientDB.'
  gem.email = 'aemadrid@gmail.com'
  gem.authors = ['Adrian Madrid']
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.platform = 'java'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "orientdb-jruby #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
