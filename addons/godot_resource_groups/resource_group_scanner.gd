@tool

var _file_system:EditorFileSystem

func _init(file_system:EditorFileSystem) -> void:
	_file_system = file_system

## The resource group scanner finds all resource groups currently 
## in the project.

## Scans the whole project for resources that match the
## group definition.
func scan() -> Array[Resource]:
	var result:Array[Resource] = []
	_scan(_file_system.get_filesystem(), result)
	return result


func _scan(folder:EditorFileSystemDirectory, results:Array[Resource]):
	# get all files in the folder
	for i in folder.get_file_count():
		if folder.get_file_type(i) == "Resource":
			var path = folder.get_file_path(i)
			if path.ends_with(".tres"):
				var resource = ResourceLoader.load(path)
				if resource is ResourceGroup:
					results.append(resource)

	# for each file first check if it matches the group definition, before trying to load it
	for j in folder.get_subdir_count():
		_scan(folder.get_subdir(j), results)


