# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shotgrid_api_ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'shotgrid_api_ruby'
  spec.version = ShotgridApiRuby::VERSION
  spec.authors = ['Denis <Zaratan> Pasin']
  spec.email = ['guillaume.brossard@autodesk.com']

  spec.summary = 'Gem to interact easily with Shotgrid REST api.'
  spec.description =
    "Gem to facilitate the interaction with Shotgrid's REST API."
  spec.homepage = 'https://github.com/shotgunsoftware/shotgrid_api_ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.0')

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/shotgunsoftware/shotgrid_api_ruby',
    'changelog_uri' =>
      'https://github.com/shotgunsoftware/shotgrid_api_ruby/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true',
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
      end
    end
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7'
  spec.add_dependency 'faraday', '>= 1', '< 3'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'sorbet-runtime'
  spec.add_dependency 'zeitwerk', '~> 2.2'
end
