# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require 'rspec_in_context'
require 'faker'
require 'timecop'
require 'vcr'

require 'dotenv/load'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :faraday
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.filter_sensitive_data('<SCRIPT_NAME>') do
    ENV['VCR_SHOTGRID_SCRIPT_NAME'] || 'vcr_shotgrid_script_name'
  end
  config.filter_sensitive_data('<SCRIPT_KEY>') do
    ENV['VCR_SHOTGRID_SCRIPT_KEY'] &&
      URI
        .encode_www_form_component(ENV['VCR_SHOTGRID_SCRIPT_KEY'])
        &.gsub(/\*/, '%2A') || 'vcr_shotgrid_script_key'
  end
  config.filter_sensitive_data('<SHOTGUN_SCRIPT_NAME>') do
    ENV['VCR_SHOTGUN_SCRIPT_NAME'] || 'vcr_shotgun_script_name'
  end
  config.filter_sensitive_data('<SHOTGUN_SCRIPT_KEY>') do
    ENV['VCR_SHOTGUN_SCRIPT_KEY'] &&
      URI
        .encode_www_form_component(ENV['VCR_SHOTGUN_SCRIPT_KEY'])
        &.gsub(/\*/, '%2A') || 'vcr_shotgun_script_key'
  end
  config.filter_sensitive_data('=<USERNAME>') do
    (ENV['VCR_SHOTGUN_USERNAME'] && "=#{ENV['VCR_SHOTGUN_USERNAME']}") ||
      '=vcr_shotgrid_username'
  end
  config.filter_sensitive_data('<PASSWORD>') do
    ENV['VCR_SHOTGUN_PASSWORD'] &&
      ENV['VCR_SHOTGUN_PASSWORD']&.gsub(/!/, '%21') || 'vcr_shotgrid_password'
  end
  config.before_record do |i|
    i.response.body.sub!(
      /access_token":"[^"]+"/,
      "access_token\":\"<ACCESS_TOKEN>\"",
    )
    i.response.body.sub!(
      /refresh_token":"[^"]+"/,
      "refresh_token\":\"<REFRESH_TOKEN>\"",
    )
    i.request.headers['Authorization'] = '<ACCESS_TOKEN>' if i.request.headers[
      'Authorization'
    ]
  end
end

SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter]

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 90
  SimpleCov.minimum_coverage_by_file 80
end

SimpleCov.start { load_profile 'test_frameworks' }

require 'shotgrid_api_ruby'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.configure do |config|
  config.include RspecInContext

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end
