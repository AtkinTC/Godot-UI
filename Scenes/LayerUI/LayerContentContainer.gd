extends Control
class_name LayerContentContainer

var parent_layer: LayerNode

func set_parent_layer(layer_node: LayerNode):
	parent_layer = layer_node

func add_child_element(child_element: Control):
	if("set_parent_layer" in child_element):
		child_element.set_parent_layer(parent_layer)
	add_child(child_element)
