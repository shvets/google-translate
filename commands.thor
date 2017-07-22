#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))

require "thor"
require "google_translate/version"
require "gemspec_deps_gen/gemspec_deps_gen"

class Commands < Thor

  def initialize *params
    super

    @version = GoogleTranslate::VERSION
    @project_name = File.basename(Dir.pwd)
  end

  no_commands do
    def generate
      generator = GemspecDepsGen.new

      generator.generate_dependencies "spec", "#{@project_name}.gemspec.erb", "#{@project_name}.gemspec"
    end
  end

  desc "build", "build"
  def build
    generate

    system "gem build #{@project_name}.gemspec"
  end

  desc "install", "install"
  def install
    system "gem install #{@project_name}-#{@version}.gem"
  end

  desc "uninstall", "uninstall"
  def uninstall
    system "gem uninstall #{@project_name}"
  end

  desc "release", "release"
  def release
    invoke :build
    system "gem push #{@project_name}-#{@version}.gem"
  end

  desc "rspec", "rspec"
  def rspec *args
    system "`which rspec` #{args.join(' ')}"
  end
end

if File.basename($0) != 'thor'
  Commands.start
end
