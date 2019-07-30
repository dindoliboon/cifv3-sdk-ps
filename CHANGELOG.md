# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2019-07-29

### Added

- Added Connect-CifService to setup API URL and key after import.

### Changed

- Environment variable CifV3ApiUri and CifV3ApiKey not mandatory before importing the module.

## [0.1.0] - 2019-07-20

### Added

- Added function map to create aliases.

### Changed

- Uses InvokeBuild to streamline build process.

## [0.0.4] - 2019-02-20

### Added

- Use environment variable CifV3ApiUri to allow API basepath to be changed.
- Add authentication for GET /ping.

### Changed

- Bypass SSL validation requirement when connecting to HTTPS websites for .NET Core.

## [0.0.3] - 2019-02-18

### Changed

- Moved hard-coded paths to variable.

## [0.0.2] - 2019-02-18

### Added

- Added support for OpenAPI Generator.

## [0.0.1] - 2019-01-28

### Added

- Initial version.

[Unreleased]: https://github.com/dindoliboon/cifv3-sdk-ps/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/dindoliboon/cifv3-sdk-ps/compare/v0.1.0..v0.1.1
[0.1.0]: https://github.com/dindoliboon/cifv3-sdk-ps/compare/v0.0.4..v0.1.0
[0.0.4]: https://github.com/dindoliboon/cifv3-sdk-ps/releases/tag/v0.0.4
