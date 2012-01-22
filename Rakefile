require 'rspec'
require 'rubygems/package_task'
require 'rake/clean'

task :default =>  [ :spec, :gem ]

desc "Run all examples"
task :spec do |t|
  sh "rspec -Ispec -Ilib -rnotroff spec"
end

task :html do |t|
  sh "ruby -Ilib -rnotroff bin/notroff  test.nr test.html"
end

task :odt do |t|
  sh "ruby -Ilib -rnotroff bin/notroff -v -o test.nr test.odt"
end

task :docbook do |t|
  sh "ruby -Ilib -rnotroff bin/notroff -d test.nr test.xml"
end


gem_spec = Gem::Specification.new do |s|
  s.name = "notroff"
  s.version = "0.2.5"
  s.authors = ["Russ Olsen"]
  s.date = %q{2012-01-15}
  s.description = 'NotRoff A simple text to openoffice filter'
  s.summary = s.description
  s.email = 'russ@russolsen.com'
  s.files = FileList[ 'readme.nr', 'spec/**/*', 'lib/**/*' ]
  s.bindir = "bin"
  s.executables = ["notroff"]
  s.require_path = "lib"
  s.homepage = 'http://www.russolsen.com'
end

Gem::PackageTask.new( gem_spec ) do |t|
  t.need_zip = true
  t.need_tar = true
end

task :push => :gem do |t|
  sh "gem push pkg/#{gem_spec.name}-#{gem_spec.version}.gem"
end

CLEAN << 'pkg'
