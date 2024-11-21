@tool


const PathVerifier = preload("path_verifier.gd")

## The resource scanner scans the project for resources matching the given
## definition and returns a list of matching resources.

var _group:ResourceGroup
var _verifier:PathVerifier
var _file_system:EditorFileSystem

## Ctor.
func _init(group:ResourceGroup, file_system:EditorFileSystem):
	_group = group	
	_verifier = PathVerifier.new(_group.base_folder, _group.includes, _group.excludes)
	_file_system = file_system
	
## Scans the whole project for resources that match the
## group definition.
func scan() -> Array[String]:
	var result:Array[String] = []
	var folder = _group.base_folder
	
	if folder == "":
		push_warning("In resource group '" + _group.resource_path + "': Base folder is not set. Resource group will be empty.")
		return result
	
	var root = _file_system.get_filesystem_path(folder)
	
	if root == null:
		push_warning("In resource group '" + _group.resource_path + "': Base folder '" + folder + "' does not exist. Resource group will be empty.")
		return result

	_scan(root, result)
	return result


func _scan(folder:EditorFileSystemDirectory, results:Array[String]):
	# get all files in the folder
	# for each file first check if it matches the group definition, before trying to load it
	for i in folder.get_file_count():
		var full_name = folder.get_file_path(i)
		if _matches_group_definition(full_name):
			if ResourceLoader.exists(full_name):
				results.append(full_name)
			else:
				push_warning("In resource group '" + _group.resource_path + "': File '" + full_name + "' exists, but is not a supported Godot resource. It will be ignored.")

	# recurse into subfolders
	for j in folder.get_subdir_count():
		_scan(folder.get_subdir(j), results)


func _matches_group_definition(file:String) -> bool:
	# Skip import files
	if file.ends_with(".import"):
		return false
		
	return _verifier.matches(file)
	
