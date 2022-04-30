extends Node2D

@onready var layer_nodes_root = $Overlay/SubViewportContainer/SubViewport/LayersRoot
@onready var layer_tabs_root = $Overlay/VBoxContainer/HBoxContainer/PanelLeft/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	LayerManager.assemble_layers_data()
	LayerManager.assemble_layer_nodes(layer_nodes_root)
	LayerManager.assemble_layer_tabs(layer_tabs_root)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
