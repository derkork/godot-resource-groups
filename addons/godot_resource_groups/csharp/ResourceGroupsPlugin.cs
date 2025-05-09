using Godot;

namespace GodotResourceGroups;

public class ResourceGroupsPlugin
{
    /// <summary>
    /// Rebuilds all resource groups. Useful if you have custom editor scripts that create or modify resources
    /// and want to update the resource groups via script.
    /// </summary>
    public static void RebuildResourceGroups()
    {
        if (!Engine.IsEditorHint())
		{
			GD.PushError("ResourceGroupsPlugin.RebuildResourceGroups() can only be called inside of the editor.");
			return;
		}
        
        var plugin = Engine.GetSingleton("ResourceGroupsPlugin");
        if (plugin == null)
        {
	        GD.PushError("Resource group plugin is not active, please check if it is enabled in the project settings.");
	        return;
        }

        plugin.Call("_rebuild_resource_groups");
    }
}