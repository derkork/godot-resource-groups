@tool
extends EditorPlugin

const ResourceScanner = preload("resource_scanner.gd")
const ResourceGroupScanner = preload("resource_group_scanner.gd")

var _group_scanner:ResourceGroupScanner

func _enter_tree():
	add_tool_menu_item("Rebuild project resource groups", _rebuild_resource_groups)
	_group_scanner = ResourceGroupScanner.new()


func _exit_tree():
	remove_tool_menu_item("Rebuild project resource groups")
	
func _save_external_data():
	_rebuild_resource_groups()
	

func _rebuild_resource_groups():
	var groups = _group_scanner.scan()

	for group in groups:
		var resource_scanner = ResourceScanner.new(group)
		var resource_paths = resource_scanner.scan()
		group.paths = resource_paths
		
		ResourceSaver.save(group)
		get_editor_interface().get_resource_filesystem().update_file(group.resource_path)


	print("Updated ", groups.size(), " resource groups.")
