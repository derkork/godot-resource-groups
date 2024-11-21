# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2024-11-21
### Improved
- Increased scanning speed by a factor of 15 by using a different API for traversing the file system. This avoids building a lot of strings for path names and reduces scan time from 2.3 seconds to 0.13 seconds for a project with 100k files in it.

## [0.4.0] - 2024-07-19
### Added
- It is now possible to disable the automatic rebuild of the resource groups in a project. This can be beneficial in very large projects where updating all resource group can take a bit of time. To disable the automatic rebuild, go to project settings, **enable advanced settings**, and the uncheck the _Auto Rebuild_ option. You can manually rebuild all resource groups using the main menu entry _Project -> Tools -> Rebuild project resource groups_ ([#7](https://github.com/derkork/godot-resource-groups/issues/7)).

### Improved
- The plugin will now rebuild resource groups when the project is launched or exported, rather than when the project is saved. This will prevent unnecessary rebuilds when saving the project multiple times in a row ([#4](https://github.com/derkork/godot-resource-groups/issues/4)).
- The plugin will now warn you, if a resource group includes files that are not actually supported Godot resources (e.g. `.txt` files). Such files were ignored before but are now explicitly mentioned when building a resource group ([#8](https://github.com/derkork/godot-resource-groups/issues/8)).

### Fixed
- The C# wrappers will now correctly call the appropriate GDScript API for the `Includes`, `Excludes` and `Paths` properties. A big thank you goes out to [Kerozard](https://github.com/Kerozard) for finding the issue and providing a fix ([#6](https://github.com/derkork/godot-resource-groups/pull/6)).

## [0.3.0] - 2024-01-31
### Added
- It is now possible to load resources in background using the new `load_all_in_background` and `load_matching_in_background` functions (and their C# equivalents). These functions will accept a callback that will be called for each loaded resource and provides information about the result of the load operation and the overall progress. The callback will be called on the main thread. ([#2](https://github.com/derkork/godot-resource-groups/issues/2)).
- There are two new examples that demonstrate the new background loading functionality for both GDScript and C#.

## [0.2.0] - 2024-01-09
### Added
- There are two new functions `load_all_into` and `load_matching_into` (and their C# equivalents) which allow loading resources into typed arrays/collections for better type safety.

## [0.1.0] - 2023-11-08
- Initial release.
