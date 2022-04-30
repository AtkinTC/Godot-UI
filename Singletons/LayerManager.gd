extends Node

var grid_layer_scene: PackedScene = load("res://Scenes/LayerScene/GridLayer.tscn")
var vertical_layer_scene: PackedScene = load("res://Scenes/LayerScene/VerticalLayer.tscn")
var layer_parent_element_scene: PackedScene = load("res://Scenes/LayerScene/LayerParentElement.tscn")

var layer_tab_scene: PackedScene = load("res://Scenes/LayerScene/LayerTab.tscn")

var layer_types := {
	"" : grid_layer_scene,
	"grid" : grid_layer_scene,
	"vertical" : vertical_layer_scene
}

var layers_dict  := {
	"layer_1" : {
		"display_title" : "Layer 1",
		"child_layers" : ["layer_2A", "layer_2B", "layer_2C"],
		"layer_type" : "grid"
	},
	"layer_2A" : {
		"display_title" : "Layer 2-A",
		"child_layers" : ["layer_3A", "layer_3B"],
		"layer_type" : "vertical",
		"order" : 1
	},
	"layer_2B" : {
		"display_title" : "Layer 2-B",
		"child_layers" : ["layer_3C", "layer_3D"],
		"order" : 2
	},
	"layer_2C" : {
		"display_title" : "Layer 2-C",
		"order" : 3
	},
	"layer_3A" : {
		"display_title" : "Layer 3-A"
	},
	"layer_3B" : {
		"display_title" : "Layer 3-B"
	},
	"layer_3C" : {
		"display_title" : "Layer 3-C"
	},
	"layer_3D" : {
		"display_title" : "Layer 3-D"
	}
}

var layer_nodes := {}
var layer_tabs := {}

var layers_graph := {}
var root_layer : String

func assemble_layers_data():
	layers_graph = {}
	root_layer = ""
	var potential_root_layers := layers_dict.keys()
	
	# graph out connections between layers
	for layer_key in layers_dict:
		var layer_dict = layers_dict.get(layer_key)
		var layer = layers_graph.get(layer_key, {})
		layer["child_layers"] = layer_dict.get("child_layers", [])
		layers_graph[layer_key] = layer
		
		for child_key in layer["child_layers"]:
			potential_root_layers.erase(child_key)
			var child_layer = layers_graph.get(child_key, {})
			child_layer["parent_layer"] = layer_key
			layers_graph[child_key] = child_layer
	
	assert(potential_root_layers.size() == 1) # There must only be one root layer
	root_layer = potential_root_layers[0]
	
	layers_graph[root_layer]["depth"] = 1
	var layer_stack := [root_layer]
	while layer_stack.size() > 0:
		var layer_key : String = layer_stack.pop_back()
		var depth : int = layers_graph[layer_key]["depth"]
		for child_key in layers_graph[layer_key].get("child_layers", []):
			layer_stack.append(child_key)
			layers_graph[child_key]["depth"] = depth + 1

func assemble_layer_nodes(root_node):
	for layer_key in layers_dict:
		var layer: LayerNode = layer_types[layers_dict[layer_key].get("layer_type", "")].instantiate()
		layer.set_display_title(layers_dict[layer_key]["display_title"])
		layer.set_depth(layers_graph[layer_key]["depth"])
		layer.set_layer_key(layer_key)
		root_node.add_child(layer)
		layer_nodes[layer_key] = layer
		
		if(layer_key != root_layer):
			layer.visible = false
		
		for child_key in layers_graph[layer_key]["child_layers"]:
			var child_element : LayerParentElement = layer_parent_element_scene.instantiate()
			layer.add_element(child_element)
			child_element.set_display_title(layers_dict[child_key]["display_title"])
			child_element.set_child_layer_key(child_key)

func assemble_layer_tabs(root_node):
	var layer_stack := [root_layer]
	while layer_stack.size() > 0:
		var layer_key : String = layer_stack.pop_front()
		
		var layer: LayerTab = layer_tab_scene.instantiate()
		layer.set_display_title(layers_dict[layer_key]["display_title"])
		layer.set_layer_key(layer_key)
		layer_tabs[layer_key] = layer
		
		if(layers_graph[layer_key]["depth"] == 1):
			root_node.add_child(layer)
		else:
			var parent_layer_tab : LayerTab = layer_tabs[layers_graph[layer_key]["parent_layer"]]
			parent_layer_tab.add_child_tab(layer)
		
		for child_key in layers_graph[layer_key].get("child_layers", []):
			layer_stack.append(child_key)

func focus_layer(_layer_key: String):
	close_all_layers()
	var display_depth := 0
	var layer_key = _layer_key
	while(layer_key):
		var layer_node : LayerNode = layer_nodes[layer_key]
		if(display_depth == 0):
			layer_node.focus_layer()
		if(display_depth != 0):
			layer_node.set_as_background(display_depth)
		layer_key = layers_graph[layer_key].get("parent_layer", null)
		display_depth += 1
	

func close_all_layers():
	for layer_key in layer_nodes.keys():
		var layer_node : LayerNode = layer_nodes[layer_key]
		layer_node.hide_layer()

func get_layer_parent_key_from_key(layer_key: String):
	return layers_graph.get(layer_key, {}).get("parent_layer", "")

func get_layer_child_keys_from_key(layer_key: String):
	return layers_graph.get(layer_key, {}).get("child_layers", [])

func get_layer_node_from_key(layer_key: String):
	return layer_nodes.get(layer_key, null)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
