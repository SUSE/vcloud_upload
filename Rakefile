$:.push(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'bundler'
require 'vcloud_upload'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << File.expand_path('../test', __FILE__)
  t.libs << File.expand_path('../', __FILE__)
  t.test_files = FileList['test/test.rb']
  t.verbose = true
end

begin
 require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files = ['lib/**/*.rb']
    t.options = ['--private']
  end
rescue LoadError
  STDERR.puts "Uses RDoc instead of yardoc! Install yardoc for bedder documentation."
  require 'rdoc/task'
  Rake::RDocTask.new(:doc) do |rdoc|
    rdoc.rdoc_dir = "doc"
    rdoc.title = "bicho #{VCloudUpload::VERSION}"
    extra_docs.each { |ex| rdoc.rdoc_files.include ex }
  end
end