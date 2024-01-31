using Godot;

// ReSharper disable once CheckNamespace
namespace GodotResourceGroups;

/// <summary>
/// A background loader for resource groups. Use <see cref="ResourceGroup.LoadAllInBackground"/>  or
/// <see cref="ResourceGroup.LoadMatchingInBackground"/>to create an instance of this class.
/// </summary>
public class ResourceGroupBackgroundLoader
{
    private readonly GodotObject _wrapped;

    internal ResourceGroupBackgroundLoader(GodotObject wrapped)
    {
        _wrapped = wrapped;
    }

    /// <summary>
    /// Cancels the background loading. The callback will not be called anymore after this method returns.
    /// </summary>
    public void Cancel()
    {
        _wrapped.Call("cancel");
    }

    /// <summary>
    /// Returns true if the background loading is done. Will also return true if the loading was cancelled.
    /// </summary>
    public bool IsDone()
    {
        return _wrapped.Call("is_done").As<bool>();
    }

    public readonly struct ResourceLoadingInfo
    {
        private readonly GodotObject _wrapped;

        public ResourceLoadingInfo(GodotObject wrapped)
        {
            _wrapped = wrapped;
        }

        public bool Success => _wrapped.Get("success").As<bool>();
        public string Path => _wrapped.Get("path").As<string>();
        public Resource Resource => _wrapped.Get("resource").As<Resource>();
        public float Progress => _wrapped.Get("progress").As<float>();
        public bool Last => _wrapped.Get("last").As<bool>();
    }
}