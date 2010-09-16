# Rakefile for google-translate

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

task :default => :gemspec

begin
  require 'bundler'
  
  begin
    require 'jeweler'
    
    Jeweler::Tasks.new do |gemspec|
      gemspec.name = "google-translate"
      gemspec.summary = "Simple client for Google Translate API (Summary)."
      gemspec.description = "Simple client for Google Translate API."
      gemspec.email = "alexander.shvets@gmail.com"
      gemspec.homepage = "http://github.com/shvets/google-translate"
      gemspec.authors = ["Alexander Shvets"]
      gemspec.files = FileList["CHANGES", "google-translate.gemspec", "Rakefile", "README", "VERSION",
                               "lib/**/*", "bin/**/*"]
      gemspec.add_dependency "json_pure", ">= 1.1.4"   

      gemspec.executables = ['translate', 't']
      gemspec.requirements = ["none"]
      gemspec.bindir = "bin"
    
      gemspec.add_bundler_dependencies
    end
  rescue LoadError
    puts "Jeweler not available. Install it s with: [sudo] gem install jeweler"
  end
rescue LoadError
  puts "Bundler not available. Install it s with: [sudo] gem install bundler"
end

desc "Release the gem"
task :"release:gem" do
  %x(
      rake gemspec
      rake build
      rake install
      git add .  
  )  
  puts "Commit message:"  
  message = STDIN.gets

  version = "#{File.open(File::dirname(__FILE__) + "/VERSION").readlines().first}"

  %x(
    git commit -m "#{message}"
    
    git push origin master

    gem push pkg/google-translate-#{version}.gem      
  )
end

desc "Run gem code locally"
task :"run:gem" do
  command = "bin/translate " + (ENV['params'].nil? ? '' : ENV['params'])
  puts ruby("#{command}")
end

Spec::Rake::SpecTask.new do |task|
  task.libs << 'lib'
  task.pattern = 'spec/**/*_spec.rb'
  task.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'teststuff'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rcov::RcovTask.new do |task|
  task.libs << 'test'
  task.test_files = FileList['test/**/*_test.rb']
  task.verbose = true
end

