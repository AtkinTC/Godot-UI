extends Node2D
class_name LayerNode

var layer_key : String

var focused : bool = false

var depth: int = 0

var content_container: LayerContentContainer

@onready var container: Control = $Container
@onready var background_color_rect: ColorRect = $Container/Background
@onready var border_color_rect: ColorRect = $Container/Border
@onready var title_label: Label = $Container/HeaderRect/H/TitleLabel
@onready var back_button: Button = $Container/HeaderRect/H/BackButton
@onready var back_button_filler: Control = $Container/HeaderRect/H/BackButtonFiller

@onready var background_layer_scene : PackedScene = preload("res://Scenes/LayerUI/BackgroundLayerNode.tscn")
var background_layer : BackgroundLayerNode

var display_title := "DISPLAY_TITLE"

func _ready():
	update_back_button()
	update_title_label()

func set_layer_key(_layer_key):
	layer_key = _layer_key

func set_display_title(title: String):
	display_title = title
	update_title_label()

func update_title_label():
	if(title_label):
		title_label.text = display_title

func set_content_container(_content_container: LayerContentContainer):
	content_container = _content_container
	content_container.set_parent_layer(self)
	if(!container):
		container = get_node("Container")
	container.add_child(content_container)

func add_element(element: Control):
	if("set_parent_layer" in element):
		element.set_parent_layer(self)
	content_container.add_child_element(element)
	
func set_depth(_depth: int):
	depth = _depth
	update_back_button()

func update_back_button():
	if(back_button):
		if(depth == 0):
			back_button.disabled = true
			back_button.visible = false
			back_button_filler.visible = true
		else:
			back_button.disabled = false
			back_button.visible = true
			back_button_filler.visible = false

func focus_layer():
	focused = true
	position = Vector2.ZERO
	visible = true
	if(background_layer):
		background_layer.visible = false

func hide_layer():
	focused = false
	position = Vector2.ZERO
	visible = false
	if(background_layer):
		background_layer.visible = false

func set_as_background(display_depth: int):
	focused = false
	position -= Vector2(15,15) * display_depth
	visible = true
	if(!background_layer):
		background_layer = background_layer_scene.instantiate()
		background_layer.set_display_title(display_title)
		add_child(background_layer)
	background_layer.visible = true

func open_child_layer(child_layer_key):
	LayerManager.focus_layer(child_layer_key)

func close_child_layers():
	LayerManager.focus_layer(layer_key)

func _on_back_button_pressed():
	var parent_layer_key : String = LayerManager.get_layer_parent_key_from_key(layer_key)
	var parent_layer : LayerNode = LayerManager.get_layer_node_from_key(parent_layer_key)
	if(parent_layer):
		parent_layer.close_child_layers()
