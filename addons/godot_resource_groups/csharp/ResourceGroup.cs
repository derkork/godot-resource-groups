using System.Collections.Generic;

namespace GodotResourceGroups
{
	using Godot;
	using System;

	public class ResourceGroup
	{
		private readonly Resource _wrapped;

		private ResourceGroup(Resource wrapped)
		{
			_wrapped = wrapped;
		}

		/// <summary>
		/// Loads a resource group from the given path.
		/// </summary>
		public static ResourceGroup Of(string path)
		{
			var wrapped = GD.Load<Resource>(path);
			return Of(wrapped);
		}


		/// <summary>
		/// Creates a typesafe wrapper for the given resource group.
		/// </summary>
		public static ResourceGroup Of(Resource wrapped)
		{
			if (wrapped == null)
			{
				throw new ArgumentNullException(nameof(wrapped));
			}

			if (wrapped.GetScript().As<Script>() is not GDScript gdScript ||
				!gdScript.ResourcePath.EndsWith("resource_group.gd"))
			{
				throw new ArgumentException("Resource is not a resource group");
			}

			return new ResourceGroup(wrapped);
		}


		/// <summary>
		/// Returns all include patterns in this resource group.
		/// </summary>
		public List<string> Includes => new(_wrapped.Call("get_includes").AsStringArray());

		/// <summary>
		/// Returns all exclude patterns in this resource group.
		/// </summary>
		public List<string> Excludes => new(_wrapped.Call("get_excludes").AsStringArray());

		/// <summary>
		/// Returns all paths in this resource group.
		/// </summary>
		public List<string> Paths => new(_wrapped.Call("get_paths").AsStringArray());

		/// <summary>
		/// Loads all resources in this resource group.
		/// </summary>
		/// <returns></returns>
		public List<Resource> LoadAll() => new(_wrapped.Call("load_all").AsGodotObjectArray<Resource>());

		/// <summary>
		/// Returns all paths in this resource group that match the given patterns.
		/// </summary>
		public List<string> GetMatchingPaths(IEnumerable<string> includes, IEnumerable<string> excludes)
			=> new(_wrapped.Call("__csharp_get_matching_paths", ToArray(includes), ToArray(excludes)).AsStringArray());


		/// <summary>
		/// Returns all resources in this resource group that match the given patterns.
		/// </summary>
		public List<Resource> LoadMatching(IEnumerable<string> includes, IEnumerable<string> excludes)
			=> new(_wrapped.Call("__csharp_load_matching", ToArray(includes), ToArray(excludes)).AsGodotObjectArray<Resource>());

		private static string[] ToArray(IEnumerable<string> enumerable)
		{
			return enumerable as string[] ?? new List<string>(enumerable).ToArray();
		}

	}
}
