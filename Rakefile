# Rakefile for google_translate

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

spec_name = 'google_translate.gemspec'

SPEC = Gem::Specification.load(spec_name)

Rake::GemPackageTask.new(SPEC) do |pkg| 
  #pkg.need_tar = true 
  #pkg.need_zip = true
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

desc "Run gem code locally"
task :"run:gem" do
  command = "bin/translate " + (ENV['params'].nil? ? '' : ENV['params'])
  puts ruby("#{command}")
end

desc "test gem compatibility with github"
task :"github:validate" do
  require 'yaml'
   
  require 'rubygems/specification'
  data = File.read(spec_name)
  spec = nil
   
  if data !~ %r{!ruby/object:Gem::Specification}
    Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
  else
    spec = YAML.load(data)
  end
   
  spec.validate
   
  puts spec
  puts "OK"
end

task :default => :package


require 'yaml'

# See: http://underpantsgnome.com/2007/1/16/managing-gems-with-rake

class Util
  def self.load_gems
    config = YAML.load_file(
      File.join(RAILS_ROOT, 'config', 'gems.yml'))
    gems = config[:gems].reject {|gem| ! gem[:load] }
    gems.each do |gem|
      require_gem gem[:name], gem[:version]
      require gem[:name]
    end
  end
end

namespace :gems do
  require 'rubygems' if RUBY_VERSION.to_f < 1.9

  desc "Download and install all gems required by development"
  task :install do
    # defaults to --no-rdoc, set DOCS=(anything) to build docs
    docs = (ENV['DOCS'].nil? ? '--no-rdoc' : '')
    #grab the list of gems/version to check
    config = YAML.load_file(File.join('config', 'gems.yml'))
    gems = config[:gems]

    gems.each do |gem|
      # load the gem spec
      gem_spec = YAML.load(`gem spec #{gem[:name]} 2> /dev/null`)
      gem_loaded = false
      begin
        gem_loaded = require_gem gem[:name], gem[:version]
      rescue Exception
      end

      # if forced
      # or there is no gem_spec
      # or the spec version doesn't match the required version
      # or require_gem returns false
      # (return false also happens if the gem has already been loaded)
      if !ENV['FORCE'].nil? ||!gem_spec ||
         (gem_spec.version.version != gem[:version] && !gem_loaded)
        gem_config = gem[:config] ? " -- #{gem[:config]}" : ''
        source = gem[:source] || config[:source] || nil
        source = "--source #{source}" if source
        ret = system "gem install #{gem[:name]} -v #{gem[:version]} #{source} #{docs} #{gem_config}" 
        # something bad happened, pass on the message
        p $? unless ret
      else
        puts "#{gem[:name]} #{gem[:version]} already installed" 
      end
    end
  end
end

