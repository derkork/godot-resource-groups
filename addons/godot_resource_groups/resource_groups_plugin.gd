class_name ResourceGroupsPlugin

## Rebuilds all resource groups. Useful if you have custom editor scripts that create or modify resources
## and want to update the resource groups via script.
static func rebuild_resource_groups():
	if not Engine.is_editor_hint():
		push_error("ResourceGroupsPlugin.rebuild_resource_groups() can only be called inside of the editor.")
		return

	var plugin = Engine.get_singleton("ResourceGroupsPlugin")
	if not is_instance_valid(plugin):
		push_error("Resource group plugin is not active, please check if it is enabled in the project settings.")
		return
	plugin._rebuild_resource_groups()
