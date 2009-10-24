# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{google_translate}
  s.version = "0.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
 
  s.authors = ["Alexander Shvets"]
  s.date = %q{2009-01-21}
  s.description = %q{Simple client for Google Translate API.}
  s.email = %q{alexander.shvets@gmail.com}

  s.files = ["CHANGES", "google_translate.gemspec", "Rakefile", "README", "lib/google_translate.rb", 
             "bin/translate", "bin/translate.bat", "spec/spec_helper.rb" , "spec/translate_spec.rb"]

  s.has_rdoc = true
  s.homepage = %q{http://github.com/shvets/google_translate}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{google_translate}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Simple client for Google Translate API.}

  if s.respond_to? :specification_version then
    s.specification_version = 2
  end

  s.executables = ['translate', 't']
  s.platform = Gem::Platform::RUBY
  s.requirements = ["none"]
  s.bindir = "bin"

  s.add_dependency("json_pure", ">= 1.1.4")
end
