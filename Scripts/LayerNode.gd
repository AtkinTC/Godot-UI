extends Node2D
class_name LayerNode

var layer_key : String

#var parent_layer : LayerNode
var focused : bool = false

var depth: int = 1

var element_container

@onready var background_image_node: Sprite2D = $BackgroundImage
var background_image: Image

@onready var background_color_rect: ColorRect = $Container/Background
@onready var border_color_rect: ColorRect = $Container/Border
@onready var title_label: Label = $Container/H/TitleLabel
@onready var back_button: Button = $Container/H/BackButton

@onready var background_layer_scene : PackedScene = preload("res://Scenes/LayerScene/BackgroundLayer.tscn")
var background_layer : BackgroundLayerNode

var display_title := "DISPLAY_TITLE"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_back_button()
	update_title_label()

func set_element_container(_element_container):
	element_container = _element_container

func set_layer_key(_layer_key):
	layer_key = _layer_key

func set_display_title(title: String):
	display_title = title
	update_title_label()

func update_title_label():
	if(title_label):
		title_label.text = display_title

func set_background_image(_background_image: Image):
	background_image = _background_image
#	if(background_image_node != null):
#		var new_texture = ImageTexture.new()
#		new_texture.create_from_image(_background_image)
#		background_image_node.set_texture(new_texture)

func add_element(element: Control):
	if("set_parent_layer" in element):
		element.set_parent_layer(self)
	element_container.add_child(element)
	if("depth" in element):
		element.depth = depth
	
func set_depth(_depth: int):
	depth = _depth
	update_back_button()

func update_back_button():
	if(back_button):
		if(depth == 1):
			back_button.disabled = true
			back_button.visible = false
		else:
			back_button.disabled = false
			back_button.visible = true

func focus_layer():
	position = Vector2.ZERO
	visible = true
	if(background_layer):
		background_layer.visible = false

func hide_layer():
	position = Vector2.ZERO
	visible = false
	if(background_layer):
		background_layer.visible = false

func set_as_background(display_depth: int):
	position -= Vector2(35,35) * display_depth
	visible = true
	if(!background_layer):
		background_layer = background_layer_scene.instantiate()
		background_layer.set_display_title(display_title)
		add_child(background_layer)
	background_layer.visible = true

func move_to_background():
	#self.visible = false
	self.position -= Vector2(35,35)
	
	if(!background_layer):
		background_layer = background_layer_scene.instantiate()
		background_layer.set_display_title(display_title)
		add_child(background_layer)
	background_layer.visible = true
	
	var parent_layer_key : String = LayerManager.get_layer_parent_key_from_key(layer_key)
	var parent_layer : LayerNode = LayerManager.get_layer_node_from_key(parent_layer_key)
	if(parent_layer):
		parent_layer.move_to_background()

func return_from_background():
	#self.visible = true
	self.position += Vector2(35,35)
	
	if(background_layer):
		background_layer.visible = false
	
	var parent_layer_key : String = LayerManager.get_layer_parent_key_from_key(layer_key)
	var parent_layer : LayerNode = LayerManager.get_layer_node_from_key(parent_layer_key)
	if(parent_layer):
		parent_layer.return_from_background()

func open_child_layer(child_layer_key):
	var child_layer = LayerManager.get_layer_node_from_key(child_layer_key)
	if(child_layer):
		var viewport: Viewport = get_viewport()
		var texture: Texture2D = get_viewport().get_texture()
		var image: Image = get_viewport().get_texture().get_image()
		child_layer.set_background_image(image)
		child_layer.visible = true
		
		move_to_background()

func close_child_layers():
	var child_layer_keys : Array = LayerManager.get_layer_child_keys_from_key(layer_key)
	
	for child_layer_key in child_layer_keys:
		var child_layer : LayerNode = LayerManager.get_layer_node_from_key(child_layer_key)
		if(child_layer):
			child_layer.visible = false
			
	return_from_background()

func _on_back_button_pressed():
	var parent_layer_key : String = LayerManager.get_layer_parent_key_from_key(layer_key)
	var parent_layer : LayerNode = LayerManager.get_layer_node_from_key(parent_layer_key)
	if(parent_layer):
		parent_layer.close_child_layers()

#func _process(delta):
#	self.position += Vector2(0.1,0.1)
