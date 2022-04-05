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
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/shotgunsoftware/shotgrid_api_ruby'
  spec.metadata['changelog_uri'] =
    'https://github.com/shotgunsoftware/shotgrid_api_ruby/blob/main/CHANGELOG.md'

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
  spec.add_dependency 'faraday', '~> 1'
  spec.add_dependency 'sorbet-runtime'
  spec.add_dependency 'zeitwerk', '~> 2.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'faker', '> 1.8'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_in_context', '> 1'
  spec.add_development_dependency 'simplecov', '> 0.16'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
  spec.metadata = { 'rubygems_mfa_required' => 'true' }
end
