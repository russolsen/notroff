require 'rspec'
require 'rubygems/package_task'
require 'rake/clean'

task :default =>  [ :spec, :gem ]

desc "Run all examples"
task :spec do |t|
  cd 'spec' do
    Dir['*_spec.rb'].sort.each do |f|
      puts "Spec'ing #{f}"
      sh "rspec #{f}"
    end
  end
end


gem_spec = Gem::Specification.new do |s|
  s.name = "notroff"
  s.version = "0.1.1"
  s.authors = ["Russ Olsen"]
  s.date = %q{2011-05-05}
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
