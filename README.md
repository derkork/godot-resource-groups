# Godot Resource Groups

_This library is still quite new and has not seen much use yet. While it works reasonably well, there may still be bugs. Please report any issues you find._

<!--suppress HtmlDeprecatedAttribute -->
<p align="center"><img height="128" src="icon.svg" width="128"/></p>

## Introduction

Godot Resource Groups is a library for dynamically loading resources in Godot. In Godot you can only load resources if you know their paths in advance. This means you will need to hard-code all resource paths. This is not only error-prone it also prevents bulk-loading of resources unless you hard-code each and every resource path. 

With this library you can define resource groups - a set of resources that belong together. You can then load these resources from your game code with a single line without having to hardcode the paths to the resources and doing any directory scanning. This is useful in a variety of situations:

- you want to load all resources in a folder (e.g. all levels in your game to make a level selection screen)
- you want to pre-load resources to avoid stuttering when loading them for the first time 
- you want to load resources from a mod without hard-coding any paths

Resource groups are defined with path expressions and wildcards so they are resilient to changes in your project structure and automatically update when you add, remove or rename resources.

## Installation

The easiest way to install the plugin is to use the Godot Asset Library directly in Godot. Search for "Godot Resource Groups" and install the plugin. You can exclude the `godot_resource_groups_examples` folder if you don't need the examples. 

You can also download a ZIP file of this repository from the [release page](https://github.com/derkork/godot-resource-groups/releases) and extract it, then copy the `addons/godot_resource_groups` folder into your project's `addons` folder.

After you installed it, make sure you enable the plugin in the project settings:

![Enabling the plugin in the project settings](manual/images/enable_the_plugin.png)


### Installation with C#

If you want to use this library with C#, make sure you are using the .NET version of Godot 4. This can be downloaded from the [Godot download page](https://godotengine.org/download). The standard version of Godot 4 does not support C#. If you got Godot from Steam, you have the standard version and need to download the .NET version separately from the Godot website. There are additional installation steps for the Godot .NET version, so make sure you follow the instructions on the [Godot documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html).

After you installed the plugin as described above, you may need to initialize your C# project if you haven't already done so. You can do this by going to the menu _Project_ -> _Tools_ -> _C#_ -> _Create C# solution_.

![Create C# solution](manual/images/create_csharp_solution.png)

> ⚠️ **Note**: the C# API is currently experimental and may change in the future. Please give it a try and let me know if you encounter any issues.


## Usage
### Creating a resource group

This addon adds a new resource type called `ResourceGroup`. You can create a new resource group by right-clicking in the FileSystem dock and selecting "New" -> "Resource" and then "ResourceGroup".

![Creating a new resource group](manual/images/resource_group_creation.png)

### Adding resources to a resource group

To add resources to a resource group, select the resource group in the file system. Now you can configure it in the inspector. 

![Resource group inspector](manual/images/inspector.png)

The resource group has three properties:

- _Base Folder_ - the folder that contains the resources you want to add to the resource group. This must be a folder inside of the project folder, it cannot be outside of it.
- _Includes_ - a list of path expressions that define which resources should be included in the resource group. If this is empty, then _all_ resources in the base folder will be included.
- _Excludes_ - a list of path expressions that define which resources should be excluded from the resource group. Can be empty, in which case no resources will be excluded.

Both _Includes_ and _Excludes_ are lists of path expressions. A path expression is a string that can contain wildcards. The following wildcards are supported:

- `*` - matches any number of characters except `/`
- `**` - matches any number of characters including `/`
- `?` - matches exactly one character except `/`

For example, the path expression `**.png` will match all PNG files in the base folder and all subfolders. The path expression `foo/*.png` will match all PNG files in the `foo` folder. The path expression `foo/**.png` will match all PNG files in the `foo` folder and all subfolders of the `foo` folder. The expression `image?.png` will match `image1.png` and `image2.png` but not `image.png` or `image12.png`.

Whenever the project is launched, resource groups will be automatically updated. This means that if you add or remove resources in the base folder, the resource group will automatically be updated to include or exclude these resources based on the path expressions that you have given. If your project contains a lot of resource groups and updating them all takes too long, starting with version 0.4.0 you can disable the automatic rebuild of resource groups in the project settings. To do this go to the project settings, **enable advanced settings**, and then uncheck the _Auto Rebuild_ option.

![Disabling the automatic rebuild of resource groups](manual/images/disable_automatic_rebuild.png)

You can manually rebuild all resource groups using the main menu entry _Project -> Tools -> Rebuild project resource groups_.

### Loading resources from a resource group

To load resources from a resource group, you first must load the resource group.

```gdscript
var resource_group:ResourceGroup = load("res://path/to/resource_group.tres")
```

Since ResourceGroups are defined in GDScript you can't use them directly in C#. Therefore this library provides a C# wrapper around the GDScript ResourceGroup class. You can load a resource group in C# like this:

```csharp
var resourceGroup = ResourceGroup.Of("res://path/to/resource_group.tres");
``` 

Now you can load all resources in the resource group with a single line:

```gdscript
var resources = resource_group.load_all()
```

in C#:

```csharp
var resources = resourceGroup.LoadAll();
```

This will return an array of all resources in the resource group. The resources will be loaded if they are not already loaded. If you only need a subset of the resources, you can use the `load_matching` method instead:

```gdscript
# load all PNG files, except those that contain "monochrome" in their name
var resources = resource_group.load_matching(["*.png"], ["*monochrome*.png"])
```

in C#:

```csharp
// load all PNG files, except those that contain "monochrome" in their name
var resources = resourceGroup.LoadMatching(new []{"*.png"}, new []{"*monochrome*.png"});
```

If you want to use type safe arrays, you can also use the type safe variants:
	
```gdscript
# declare a type safe array
var images:Array[Texture2D] = []
# fills the array with the resources from the resource group
resource_group.load_all_into(images)
```

in C#:

```csharp
// declare a typed list
var images = new List<Texture2D>();
// fills the list with the resources from the resource group
resourceGroup.LoadAllInto(images);
```

There are also type safe variants for `load_matching` in GDScript and C# which work similarly.

### Loading resources in the background

Loading resources can take a while, especially if you have a lot of resources or if the resources are large. This can cause stuttering in your game. To avoid this, you can load resources in the background, starting with version 0.3.0 of this library. To load all resources in the background, use the `load_all_in_background` method:

```gdscript
var _loader:ResourceGroupBackgroundLoader = null

func _ready():
	_loader = resource_group.load_all_in_background(on_resource_loaded)

func on_resource_loaded(info:ResourceGroupBackgroundLoader.ResourceLoadingInfo):
	print("Resource loading succeeded: ", info.success) # will be false if loading failed, true otherwise
	print("Resource loaded: ", info.resource) # will be null if loading failed
	print("Resource path: ", info.path) # the path of the resource, will always be set, even if loading failed
	print("Progress: ", info.progress) # the overall progress of the loading operation, between 0 and 1
	print("Is last resource: ", info.last) # will be true if is the last resource that has been loaded

func _on_cancel_button_pressed():
	# loading can be cancelled at any time by calling cancel on the loader
	_loader.cancel()
```

**Important:**: you need to retain a reference to the background loader during the loading process. Otherwise Godot will free the resource loader and your loading will never finish. In general you will want to do this anyway, to allow the user to cancel the loading process.

This works similarly in C#:

```csharp
private ResourceGroupBackgroundLoader _loader;

public override void _Ready()
{
	_loader = resourceGroup.LoadAllInBackground(OnResourceLoaded);
}

private void OnResourceLoaded(ResourceGroupBackgroundLoader.ResourceLoadingInfo info)
{
	GD.Print("Resource loading succeeded: ", info.Success); // will be false if loading failed, true otherwise
	GD.Print("Resource loaded: ", info.Resource); // will be null if loading failed
	GD.Print("Resource path: ", info.Path); // the path of the resource, will always be set, even if loading failed
	GD.Print("Progress: ", info.Progress); // the overall progress of the loading operation, between 0 and 1
	GD.Print("Is last resource: ", info.Last); // will be true if is the last resource that has been loaded
}

public void _OnCancelButtonPressed()
{
	// loading can be cancelled at any time by calling cancel on the loader
	_loader.Cancel();
}
```
Also check out the loading examples for [GDScript](godot_resource_groups_examples/example_background_gdscript) and [C#](godot_resource_groups_examples/example_background_csharp) for more details.

There is also a variant `load_matching_in_background` which works similarly, but only loads a subset of the resources.

## Using in plugins

### Rebuilding resources on request from another plugin

If you create resources using editor scripting, you can trigger a rebuild of all resource groups from your plugin:

```gdscript
ResourceGroupsPlugin.rebuild_resource_groups()
```

Similarly from C#:

```csharp
ResourceGroupsPlugin.RebuildResourceGroups();
```

Please note, that this will only work in the editor. If you call this function at runtime it will print an error message and do nothing.

## FAQ

### How do I select all but a few resources?

You can use the `Excludes` property to exclude resources from the resource group. For example, if you want to include all levels in your game except the tutorial levels, you could set this up like this:

- _Base Folder_: `res://levels`
- _Includes_: `**.tscn`
- _Excludes_: `**tutorial.tscn`

### Will this work when the game is exported?

Yes, this is one of the problems that this library solves. As resources are packaged into PCK files when the game is exported, you cannot easily get a list of all resources in a folder anymore after exporting, because Godot will rename/reorganize some files. This library solves this problem by storing the list of resources in the resource group itself, so all you need to do is load up your well-known resource group and you can get a list of all resources in it.


### I pressed save but the resources don't update, is this broken?

This has been changed in version 0.4.0 after the video showing how to use it was released. The paths will only be updated when the project is built (e.g. on game start) or exported. This was done to prevent slowdowns in large projects with a lot of resources as it is not necessary to do this every time you save the project. 
