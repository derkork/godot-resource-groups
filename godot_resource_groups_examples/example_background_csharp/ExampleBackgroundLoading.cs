using Godot;
using GodotResourceGroups;

// ReSharper disable once CheckNamespace
namespace GodotResourceGroupsExamples
{
    partial class ExampleBackgroundLoading : PanelContainer
    {
        [Export(PropertyHint.ResourceType, hintString: "ResourceGroup")]
        public Resource OneThousandImages;

        private ResourceGroup _oneThousandImages;
        private Button _loadButton;
        private Button _cancelButton;
        private Label _doneLabel;
        private Label _infoLabel;
        private ProgressBar _progressBar;
        
        private ResourceGroupBackgroundLoader _backgroundLoader;

        public override void _Ready()
        {
            _oneThousandImages = ResourceGroup.Of(OneThousandImages);
            _loadButton = GetNode<Button>("%LoadButton");
            _cancelButton = GetNode<Button>("%CancelButton");
            _doneLabel = GetNode<Label>("%DoneLabel");
            _infoLabel = GetNode<Label>("%InfoLabel");
            _progressBar = GetNode<ProgressBar>("%ProgressBar");
        }

        private void OnLoadButtonPressed()
        {
            _loadButton.Visible = false;
            _cancelButton.Visible = true;
            _backgroundLoader = _oneThousandImages.LoadAllInBackground(OnResourceLoaded);
        }

        private void OnResourceLoaded(ResourceGroupBackgroundLoader.ResourceLoadingInfo info)
        {
            _progressBar.Value = info.Progress * 100.0f;
            _infoLabel.Text = info.Path + " : " + (info.Success ? "OK" : "NOT OK");
            _progressBar.Visible = !info.Last;
            _cancelButton.Visible = !info.Last;
            _infoLabel.Visible = !info.Last;
            _doneLabel.Visible = info.Last;
        }
        
        private void OnCancelButtonPressed()
        {
            _backgroundLoader.Cancel();
            _cancelButton.Visible = false;
            _loadButton.Visible = true;
            _progressBar.Visible = false;
            _infoLabel.Visible = false;
        }
    }
}