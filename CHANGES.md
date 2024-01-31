# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2024-01-31
### Added
- It is now possible to load resources in background using the new `load_all_in_background` and `load_matching_in_background` functions (and their C# equivalents). These functions will accept a callback that will be called for each loaded resource and provides information about the result of the load operation and the overall progress. The callback will be called on the main thread. ([#2](https://github.com/derkork/godot-resource-groups/issues/2)).
- There are two new examples that demonstrate the new background loading functionality for both GDScript and C#.

## [0.2.0] - 2024-01-09
### Added
- There are two new functions `load_all_into` and `load_matching_into` (and their C# equivalents) which allow loading resources into typed arrays/collections for better type safety.

## [0.1.0] - 2023-11-08
- Initial release.
