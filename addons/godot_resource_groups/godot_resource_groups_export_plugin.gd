extends EditorExportPlugin

const ResourceScanner = preload("resource_scanner.gd")


func _begin_customize_resources(platform: EditorExportPlatform, features: PackedStringArray) -> bool:
	return true
	
func _get_name() -> String:
	return "Godot Resource Groups Export Plugin"

func _customize_resource(resource: Resource, path: String) -> Resource:
	print("Customizing resource: ", path)
	# re-scan resource paths for ResourceGroup on export
	if resource is ResourceGroup:
		print("Updating resource group before export: ", path)
		var group:ResourceGroup = resource as ResourceGroup
		var resource_scanner = ResourceScanner.new(group)
		var resource_paths   = resource_scanner.scan()
		group.paths = resource_paths
		return group

	# everything else we don't care about
	return null
	
func _customize_scene(scene: Node, path: String) -> Node:
	return null
	
	
func _get_customization_configuration_hash() -> int:
	return 0