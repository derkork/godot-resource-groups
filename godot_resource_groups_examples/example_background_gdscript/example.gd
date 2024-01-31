extends PanelContainer

@export var one_thousand_images:ResourceGroup
@onready var _load_button:Button = %LoadButton
@onready var _cancel_button:Button = %CancelButton
@onready var _done_label:Label = %DoneLabel
@onready var _info_label:Label = %InfoLabel


@onready var _progress_bar = %ProgressBar

var _background_loader:ResourceGroupBackgroundLoader


func _on_load_button_pressed():
	_load_button.visible = false
	_cancel_button.visible = true
	_background_loader = one_thousand_images.load_all_in_background(_on_resource_loaded)


func _on_resource_loaded(info:ResourceGroupBackgroundLoader.ResourceLoadingInfo):
	_progress_bar.value = info.progress * 100.0
	_info_label.text = info.path + " : " + ("OK" if info.success else "NOT OK")
	_progress_bar.visible = not info.last
	_cancel_button.visible = not info.last
	_info_label.visible = not info.last
	_done_label.visible = info.last


func _on_cancel_button_pressed():
	_background_loader.cancel()
	_cancel_button.visible = false
	_load_button.visible = true
	_progress_bar.visible = false
	_info_label.visible = false
