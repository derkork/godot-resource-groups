@tool
extends EditorExportPlugin

var _on_export:Callable

func _init(on_export:Callable):
	_on_export = on_export

func _export_begin(features, is_debug, path, flags):
	_on_export.call()


func _get_name() -> String:
	return "Godot Resource Groups Export Plugin"
