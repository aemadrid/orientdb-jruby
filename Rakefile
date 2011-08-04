require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

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
desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Run all examples using rcov"
RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
  t.rcov      = true
  t.rcov_opts = %[-Ilib -Ispec --exclude "spec/*,gems/*" --text-report --sort coverage --aggregate coverage.data]
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :default => :spec

require 'orientdb/version'
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "orientdb #{OrientDB::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
