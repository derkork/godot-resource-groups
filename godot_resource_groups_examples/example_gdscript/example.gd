extends Control

@onready var option_button = %OptionButton
@onready var texture_rect = %TextureRect

var _images:Array[Texture2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# load the resource group
	var group:ResourceGroup = preload("../image_resource_group.tres") as ResourceGroup

	print(_images.get_typed_script())

	# get all images
	group.load_all_into(_images)
	
	# add all images to the option button
	for image in _images:
		option_button.add_item(image.resource_path)
		
	# select the first image
	_on_option_button_item_selected(0)


func _on_option_button_item_selected(index):
	if _images.size() <= index:
		return
		
	texture_rect.texture = _images[index]

	
