@tool
extends EditorPlugin

const ResourceScanner = preload("resource_scanner.gd")
const ResourceGroupScanner = preload("resource_group_scanner.gd")
const ResourceGroupsExportPlugin = preload("godot_resource_groups_export_plugin.gd")
const REBUILD_SETTING: StringName = "godot_resource_groups/auto_rebuild"

var _group_scanner: ResourceGroupScanner
var _export_plugin: ResourceGroupsExportPlugin

func _enter_tree():
	# make the plugin singleton available to the rest of the engine
	Engine.register_singleton("ResourceGroupsPlugin", self)
	
	add_tool_menu_item("Rebuild project resource groups", _rebuild_resource_groups)
	_group_scanner = ResourceGroupScanner.new(get_editor_interface().get_resource_filesystem())
	
	# try to get the setting, if it doesn't exist, set it to true
	var auto_rebuild: bool = ProjectSettings.get_setting(REBUILD_SETTING, true)
	
	# make sure it is there
	ProjectSettings.set_setting("godot_resource_groups/auto_rebuild", auto_rebuild)
	# add property info so it shows up in the editor
	ProjectSettings.add_property_info({
		"name": "godot_resource_groups/auto_rebuild",
		"description": "Automatically rebuild resource groups when the project is built.",
		"type": TYPE_BOOL,
	})
	
	# register the export plugin
	_export_plugin = ResourceGroupsExportPlugin.new(_rebuild_resource_groups)
	add_export_plugin(_export_plugin)


func _exit_tree():
	Engine.unregister_singleton("ResourceGroupsPlugin")
	remove_tool_menu_item("Rebuild project resource groups")
	remove_export_plugin(_export_plugin)


func _build() -> bool:
	# always read the setting to make sure it is up to date
	var auto_rebuild: bool = ProjectSettings.get_setting(REBUILD_SETTING, true)
	if auto_rebuild:
		_rebuild_resource_groups()
	return true


func _rebuild_resource_groups():
	var start = Time.get_unix_time_from_system()
	var groups = _group_scanner.scan()

	for group in groups:
		var resource_scanner = ResourceScanner.new(group, get_editor_interface().get_resource_filesystem())
		var resource_paths = resource_scanner.scan()

		group.paths = resource_paths
		

		ResourceSaver.save(group)
		get_editor_interface().get_resource_filesystem().update_file(group.resource_path)

	var end = Time.get_unix_time_from_system()
	print("Rebuilt resource groups in %.2f seconds." % [end-start])
