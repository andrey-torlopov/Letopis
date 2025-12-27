# Changelog

All notable changes to Letopis will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Optional Helper Utilities** (December 2025)
  - `@Logged` property wrapper for automatic get/set logging
  - `@LoggedSet` property wrapper for set-only logging
  - `LogLifecycle` SwiftUI ViewModifier for view lifecycle tracking
  - `logged()` scope-based function for operation logging (async/sync, throwing/non-throwing)
  - Publisher extensions for Combine (`.logged()`, `.logErrors()`, `.logLifecycle()`)
  - Complete documentation in [Docs/en/helpers.md](Docs/en/helpers.md) and [Docs/ru/helpers.md](Docs/ru/helpers.md)
  - Examples in `Sources/Letopis/Examples/HelpersExample.swift`

### Changed

- **Breaking Change: Sensitive Data Masking** (November 2025)
  - Sensitive data masking is now **enabled by default**
  - All keys in `sensitiveKeys` are automatically masked using partial strategy
  - Use `.notSensitive()` to explicitly disable masking for specific log events
  - **Migration**: Add `.notSensitive()` to log calls that need to show sensitive data in development

- **Architecture Changes** (November 2025)
  - Reworked event/action model into domain/action architecture
  - Added OSLog priority support
  - Made sensitive keys case-insensitive
  - Changed critical event icon

### Fixed

- Documentation improvements
- Sensitive data handling in edge cases

## Previous Releases

For information about earlier releases, please refer to the git history.
