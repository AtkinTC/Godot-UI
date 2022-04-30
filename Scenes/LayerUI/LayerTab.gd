extends VBoxContainer
class_name LayerTab

var focused := false

var layer_key : String

var display_title := "DISPLAY_TITLE"

@onready var button: Button = $Panel/MarginContainer/H/Button
@onready var expand_button: Button = $Panel/MarginContainer/H/ExpandContainer/ExpandButton
@onready var margin_container: MarginContainer = $MarginContainer
@onready var child_container: VBoxContainer = $MarginContainer/V

# Called when the node enters the scene tree for the first time.
func _ready():
	update_child_container()
	update_display_title()

func set_layer_key(_layer_key):
	layer_key = _layer_key

func add_child_tab(child_tab: LayerTab):
	child_container.add_child(child_tab)
	update_child_container()
	
func update_child_container():
	if(child_container.get_child_count() == 0):
		margin_container.visible = false
		expand_button.visible = false
	else:
		margin_container.visible = true
		expand_button.visible = true

func set_display_title(title: String):
	display_title = title
	update_display_title()

func update_display_title():
	if(button):
		button.text = display_title

func focus_layer():
	focused = true

func unfocus_layer():
	focused = false

func expand_child_container():
	margin_container.visible = true
	expand_button.text = "-"

func collapse_child_container():
	margin_container.visible = false
	expand_button.text = "+"
	
	#recursively collapse child tabs as well
	var child_keys : Array = LayerManager.get_layer_child_keys_from_key(layer_key)
	for child_key in child_keys:
		var child_tab : LayerTab = LayerManager.get_layer_tab_from_key(child_key)
		child_tab.collapse_child_container()

func toggle_child_container():
	if(margin_container.visible):
		collapse_child_container()
	else:
		expand_child_container()

func _on_button_pressed():
	LayerManager.focus_layer(layer_key)

func _on_expand_button_pressed():
	toggle_child_container()
