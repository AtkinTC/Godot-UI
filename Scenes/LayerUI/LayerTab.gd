extends VBoxContainer
class_name LayerTab

var focused := false
var expanded := false

var layer_key : String

var display_title := "DISPLAY_TITLE"

@onready var panel: Panel = $Panel
@onready var button: Button = $Panel/MarginContainer/H/Button
@onready var expand_button: Button = $Panel/MarginContainer/H/ExpandContainer/ExpandButton
@onready var margin_container: MarginContainer = $MarginContainer
@onready var child_container: VBoxContainer = $MarginContainer/V

# Called when the node enters the scene tree for the first time.
func _ready():
	update_child_container()
	update_display_title()
	update_focus()

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
		if(expanded):
			margin_container.visible = true
			expand_button.text = "-"
		else:
			margin_container.visible = false
			expand_button.text = "+"
		expand_button.visible = true

func set_display_title(title: String):
	display_title = title
	update_display_title()

func update_display_title():
	if(button):
		button.text = display_title

func focus_layer():
	focused = true
	update_focus()

func unfocus_layer():
	focused = false
	update_focus()

func update_focus():
	if(!panel):
		panel = get_node("Panel")
	if(focused):
		var style = panel.get_theme_stylebox("panel_focused", "Panel")
		panel.add_theme_stylebox_override("panel", style)
	else:
		var style = panel.get_theme_stylebox("panel_unfocused", "Panel")
		panel.add_theme_stylebox_override("panel", style)

func expand_child_container():
	expanded = true
	margin_container.visible = true
	expand_button.text = "-"
	update_child_container()

func collapse_child_container():
	expanded = false
	margin_container.visible = false
	expand_button.text = "+"
	update_child_container()
	
	#recursively collapse child tabs as well
	var child_keys : Array = LayerManager.get_layer_child_keys_from_key(layer_key)
	for child_key in child_keys:
		var child_tab : LayerTab = LayerManager.get_layer_tab_from_key(child_key)
		child_tab.collapse_child_container()

func toggle_child_container():
	if(expanded):
		collapse_child_container()
	else:
		expand_child_container()

func _on_button_pressed():
	LayerManager.focus_layer(layer_key)

func _on_expand_button_pressed():
	toggle_child_container()
