extends Control
class_name LayerParentElement

signal open_child_layer(layer_key)

@onready var background_color_rect: ColorRect = $Background
@onready var title_label: Label = $V/TitleLabel
@onready var layer_parent_button: Button = $V/LayerParentButton

#var child_layer: LayerNode
var parent_layer: LayerNode
var child_layer_key: String

var display_title = "DISPLAY_TITLE"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_title_label()
	#update_child_layer()

func set_display_title(title: String):
	display_title = title
	update_title_label()

func update_title_label():
	if(title_label):
		title_label.text = display_title

func set_child_layer_key(layer_key: String):
	child_layer_key = layer_key

func set_parent_layer(layer_node: LayerNode):
	parent_layer = layer_node

func _on_layer_parent_button_pressed():
	parent_layer.open_child_layer(child_layer_key)
