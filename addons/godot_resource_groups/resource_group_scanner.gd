@tool


## The resource group scanner finds all resource groups currently 
## in the project.

## Scans the whole project for resources that match the
## group definition.
func scan() -> Array[Resource]:
	var result:Array[Resource] = []
	var folder = "res://"

	_scan(folder, result)
	return result


func _scan(folder:String, results:Array[Resource]):
	# get all files in the folder
	var files = DirAccess.get_files_at(folder)

	# for each file first check if it matches the group definition, before trying to load it
	for file in files:
		var full_name = folder + "/" + file
		# avoid loading each and every resource in the project
		if full_name.ends_with(".tres") and ResourceLoader.exists(full_name):
			var resource = ResourceLoader.load(full_name)
			if resource is ResourceGroup:
				results.append(resource)

	# recurse into subfolders
	var subfolders = DirAccess.get_directories_at(folder)
	for subfolder in subfolders:
		_scan(folder + "/" + subfolder, results)


