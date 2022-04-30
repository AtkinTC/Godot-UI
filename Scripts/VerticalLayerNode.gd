extends LayerNode
class_name VerticalLayerNode

@onready var vertical_element_container: VBoxContainer = $Container/VBox

func _ready():
	super.set_element_container(vertical_element_container)
	super._ready()
