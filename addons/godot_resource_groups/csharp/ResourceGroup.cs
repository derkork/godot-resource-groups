// ReSharper disable once CheckNamespace
namespace GodotResourceGroups
{
    using Godot;
    using System.Collections.Generic;
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
        // ReSharper disable once MemberCanBePrivate.Global
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
        /// Loads all resources in this resource group in the background. The given callback will be called
        /// for each resource that is loaded. The callback will be called from the main thread.
        /// </summary>
        /// <returns>A <see cref="ResourceGroupBackgroundLoader"/> which can be used to cancel the background loading.</returns>
        public ResourceGroupBackgroundLoader LoadAllInBackground(
            Action<ResourceGroupBackgroundLoader.ResourceLoadingInfo> callback)
        {
            var godotCallback =
                Callable.From<GodotObject>(it => callback(new ResourceGroupBackgroundLoader.ResourceLoadingInfo(it)));
            var wrapped = _wrapped.Call("load_all_in_background", godotCallback);
            return new ResourceGroupBackgroundLoader(wrapped.AsGodotObject());
        }

        /// <summary>
        /// Loads all resources that match the given include and exclude specification from this resource group in the background.
        /// The given callback will be called for each resource that is loaded. The callback will be called from the main thread.
        /// </summary>
        /// <returns>A <see cref="ResourceGroupBackgroundLoader"/> which can be used to cancel the background loading.</returns>
        public ResourceGroupBackgroundLoader LoadMatchingInBackground(IEnumerable<string> includes,
            IEnumerable<string> excludes,
            Action<ResourceGroupBackgroundLoader.ResourceLoadingInfo> callback)
        {
            var godotCallback =
                Callable.From<GodotObject>(it => callback(new ResourceGroupBackgroundLoader.ResourceLoadingInfo(it)));
            var wrapped = _wrapped.Call("__csharp_load_matching_in_background", ToArray(includes), ToArray(excludes),
                godotCallback);
            return new ResourceGroupBackgroundLoader(wrapped.AsGodotObject());
        }

        /// <summary>
        /// Loads all items of the group into the given collection. If an item is of the wrong
        /// type it will be skipped and an error is printed.
        /// </summary>
        public void LoadAllInto<T>(ICollection<T> destination)
        {
            var items = _wrapped.Call("load_all").AsGodotObjectArray<Resource>();
            PushInto(items, destination);
        }

        /// <summary>
        /// Returns all paths in this resource group that match the given patterns.
        /// </summary>
        public List<string> GetMatchingPaths(IEnumerable<string> includes, IEnumerable<string> excludes)
            => new(_wrapped.Call("__csharp_get_matching_paths", ToArray(includes), ToArray(excludes)).AsStringArray());


        /// <summary>
        /// Returns all resources in this resource group that match the given patterns.
        /// </summary>
        public List<Resource> LoadMatching(IEnumerable<string> includes, IEnumerable<string> excludes)
            => new(_wrapped.Call("__csharp_load_matching", ToArray(includes), ToArray(excludes))
                .AsGodotObjectArray<Resource>());

        /// <summary>
        /// Loads all resources in this resource group that match the given patterns and stores them
        /// into the given collection. If an item is of the wrong type it will be skipped and an
        /// error is printed.
        /// </summary>
        public void LoadMatchingInto<T>(ICollection<T> destination, IEnumerable<string> includes,
            IEnumerable<string> excludes)
        {
            var items = _wrapped.Call("__csharp_load_matching", ToArray(includes), ToArray(excludes))
                .AsGodotObjectArray<Resource>();
            PushInto(items, destination);
        }


        private static string[] ToArray(IEnumerable<string> enumerable)
        {
            return enumerable as string[] ?? new List<string>(enumerable).ToArray();
        }

        private static void PushInto<T>(IEnumerable<Resource> items, ICollection<T> destination)
        {
            foreach (var item in items)
            {
                if (item is T t)
                {
                    destination.Add(t);
                }
                else
                {
                    GD.PushError("Item ", item, " is not of required type ", typeof(T).Namespace, ". Skipping.");
                }
            }
        }
    }
}