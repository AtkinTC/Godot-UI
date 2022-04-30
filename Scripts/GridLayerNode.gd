extends LayerNode
class_name GridLayerNode

@onready var grid_element_container = $Container/Grid

func _ready():
	super.set_element_container(grid_element_container)
	super._ready()
