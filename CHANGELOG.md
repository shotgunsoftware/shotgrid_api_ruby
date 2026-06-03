# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0.9] - 2026-05-11

### Changed

- Replaced `activesupport` runtime dependency with `dry-inflector` (~> 1.0): only `String#camelize`/`singularize` were used, no need for the full ActiveSupport tree

### Added

- `ruby-lsp` as the canonical Ruby language server for development

### Removed

- `activesupport` runtime dependency (along with its tree: `concurrent-ruby`, `i18n` transitive, `tzinfo`, `drb`, `minitest`, …)
- `solargraph` dev dependency (and its tree: `backport`, `kramdown`, `reverse_markdown`, `nokogiri`, …) — superseded by `ruby-lsp`

## [0.2.0.8] - 2026-05-10

### Added

- Explicit dependency on `ostruct` (no longer in default gems on Ruby 4.0+)

### Changed

- Bumped minimum Ruby to 3.3 and updated the CI matrix to non-EOL versions (3.3, 3.4, 4.0)
- Upgraded Sorbet/Tapioca stack (sorbet-static now ships arm64-darwin-25 binaries)
- Bumped RuboCop and migrated `require:` extensions to the new `plugins:` syntax; `TargetRubyVersion` raised to 3.3
- Refreshed gem RBIs against the updated dependencies

### Fixed

- Gemspec metadata: `homepage_uri`, `source_code_uri` and `changelog_uri` were silently overwritten by a subsequent `spec.metadata = {…}` assignment; consolidated into a single hash literal so all entries are published

## [0.2.0.6] - 2023-01-29

### Added

- Adding Ruby 3.2 to the test matrix

## [0.2.0.5] - 2022-04-04

### Removed

- Removing Ruby 2.6 after EOL

### Changed

- ActiveSupport 7+

## [0.2.0.4] - 2022-01-04

### Changed

- Moving to bundler 2
- Updating all dependencies

### Added

- Adding Ruby 3.1 to test matrix

## [0.2.0.1] - 2021-10-12

### Changed

- Fixing Rubocop

## [0.2.0] - 2021-08-27

### Added

- Adding Sorbet

## [0.1.3.3] - 2021-08-28

### Added

- Issue default format

## [0.1.3.2] - 2021-08-24

### Added

- Code Of Conduct

## [0.1.3.1] - 2021-08-24

### Changed

- Correctly advertising the minimum ruby version to 2.6

## [0.1.3] - 2021-08-24

### Changed

- Updated tooling
- Adding `ShotgridCallError` to capture call errors and give access to the raw Faraday response

## [0.1.2] - 2021-06-16

### Changed

- Renamed to Shotgrid

## [0.1.1] - 2021-06-15

### Added

- summarize and count support

## [0.1.0] - 2021-06-14

### Added

- Complete test coverage (Unit + Integration tests)
- Adding minimum coverage for tests
- Adding Guard

### Changed

- Fixed many edge-case bugs

### Removed

- Removed the `Gemfile.lock` since it shouldn't be commited in gems

## [0.0.8.5] - 2021-01-15

### Added

- Added prettier for ruby style

## [0.0.8.4] - 2021-01-07

### Changed

- Safer eager_load

## [0.0.8.3] - 2021-01-07

### Added

- eager_load files to fix weird bugs in rspec

## [0.0.8] - 2020-12-16

### Added

- Schema: read
- Schema: read fields

## [0.0.7] - 2020-12-16

### Added

- Entities: update
- Entities: create
- Entities: delete
- Entities: revive

[unreleased]: https://github.com/shotgunsoftware/shotgrid_api_ruby/compare/v0.2.0...HEAD
[0.2.0.5]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.2.0.5
[0.2.0.4]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.2.0.4
[0.2.0.1]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.2.0.1
[0.2.0]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.2.0
[0.1.3.3]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.3.3
[0.1.3.2]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.3.2
[0.1.3.1]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.3.1
[0.1.3]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.3
[0.1.2]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.2
[0.1.1]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.1
[0.1.0]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.1.0
[0.0.8.5]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.0.8.5
[0.0.8.4]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.0.8.4
[0.0.8.3]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.0.8.3
[0.0.8]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.0.8
[0.0.7]: https://github.com/shotgunsoftware/shotgrid_api_ruby/releases/tag/v0.0.7
