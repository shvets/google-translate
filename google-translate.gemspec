#

Gem::Specification.new do |spec|
  spec.name              = 'translate'
  spec.rubyforge_project = 'google-translate'
  spec.version           = '0.5.0'
  spec.author            = "Alexander Shvets"
  spec.homepage          = 'http://rubyforge.org/projects/google-translate'
  spec.date              = %q{2009-01-21}
  spec.description       = 'Simple client for Google Translate API.'
  spec.email             = 'alexander.shvets@gmail.com'

  candidates = Dir.glob("{docs,lib,tests,bin}/**/*")
  spec.files = candidates.delete_if do |item|
    item.include?("svn") || item.include?("rdoc")
  end

  spec.require_paths = ["lib"]
  spec.requirements = ["none"]
  spec.bindir = "bin"
  spec.rubygems_version = '1.3.1'
  spec.platform = Gem::Platform::RUBY
  spec.has_rdoc = false

  spec.executables = ['translate']

  spec.add_dependency("json", ">= 1.1.3")

  spec.summary = %q{.}
end
