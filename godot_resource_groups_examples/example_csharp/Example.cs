using System.Collections.Generic;

// ReSharper disable once CheckNamespace
namespace GodotResourceGroupsExamples
{
    using Godot;
    using GodotResourceGroups;

    public partial class Example : Node
    {
        private OptionButton _optionButton;
        private TextureRect _textureRect;
        private readonly List<Texture2D> _images = new();


        public override void _Ready()
        {
            _optionButton = GetNode<OptionButton>("%OptionButton");
            _textureRect = GetNode<TextureRect>("%TextureRect");

            // load a resource group from a .tres file
            var group = ResourceGroup.Of("res://godot_resource_groups_examples/image_resource_group.tres");
            
            // load all resources in the group
            group.LoadAllInto(_images);
            
            // prepare the option button
            foreach (var image in _images)
            {
                _optionButton.AddItem(image.ResourcePath);
            }
            
            OnOptionButtonItemSelected(0);
        }

        private void OnOptionButtonItemSelected(int index)
        {
            if (index < 0 || index >= _images.Count)
            {
                return;
            }
            // when an item is selected, set the texture of the texture rect, so we can see the image
            var image = _images[index];
            _textureRect.Texture = image;
        }
    }
}