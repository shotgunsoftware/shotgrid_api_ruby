# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "shotgun_api_ruby/version"

Gem::Specification.new do |spec|
  spec.name          = "shotgun_api_ruby"
  spec.version       = ShotgunApiRuby::VERSION
  spec.authors       = ["Denis <Zaratan> Pasin"]
  spec.email         = ["denis.pasin@autodesk.com"]

  spec.summary       = 'Gem to interact easily with Shotgun REST api.'
  spec.description   = "Gem to facilitate the interaction with Shotgun's REST API."
  spec.homepage      = "https://github.com/shotgunsoftware/shotgun_api_ruby"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shotgunsoftware/shotgun_api_ruby"
  # spec.metadata["changelog_uri"] = "http://none.yet.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "faraday", "~> 0.17"
  spec.add_dependency "zeitwerk", "~> 2.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "bundler-audit"
  spec.add_development_dependency "overcommit"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.75"
  spec.add_development_dependency "rubocop-performance", "~> 1.5"
end
