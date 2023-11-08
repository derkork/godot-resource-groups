@tool


const PathVerifier = preload("path_verifier.gd")

## The resource scanner scans the project for resources matching the given
## definition and returns a list of matching resources.

var _group:ResourceGroup
var _verifier:PathVerifier

## Ctor.
func _init(group:ResourceGroup):
	_group = group	
	_verifier = PathVerifier.new(_group.base_folder, _group.includes, _group.excludes)

	
## Scans the whole project for resources that match the
## group definition.
func scan() -> Array[String]:
	var result:Array[String] = []
	var folder = _group.base_folder
	
	if folder == "":		
		push_warning("In resource group '" + _group.resource_path + "': Base folder is not set. Resource group will be empty.")
		return result
	
	if not DirAccess.dir_exists_absolute(folder):
		push_warning("In resource group '" + _group.resource_path + "': Base folder '" + folder + "' does not exist. Resource group will be empty.")
		return result

	_scan(_group.base_folder, result)
	return result


func _scan(folder:String, results:Array[String]):
	# get all files in the folder
	var files = DirAccess.get_files_at(folder)

	# for each file first check if it matches the group definition, before trying to load it
	for file in files:
		var full_name = folder + "/" + file
		if _matches_group_definition(full_name):
			if ResourceLoader.exists(full_name):
				results.append(full_name)

	# recurse into subfolders
	var subfolders = DirAccess.get_directories_at(folder)
	for subfolder in subfolders:
		_scan(folder + "/" + subfolder, results)


func _matches_group_definition(file:String) -> bool:
	# Skip import files
	if file.ends_with(".import"):
		return false
		
	return _verifier.matches(file)
	
