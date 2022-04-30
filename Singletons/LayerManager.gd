extends Node

var grid_layer_scene: PackedScene = load("res://Scenes/LayerUI/GridLayerNode.tscn")
var vertical_layer_scene: PackedScene = load("res://Scenes/LayerUI/VerticalLayerNode.tscn")
var layer_child_button_element_scene: PackedScene = load("res://Scenes/LayerUI/LayerChildButtonElement.tscn")
var layer_tab_scene: PackedScene = load("res://Scenes/LayerUI/LayerTab.tscn")

var layer_types := {
	"" : grid_layer_scene,
	"grid" : grid_layer_scene,
	"vertical" : vertical_layer_scene
}

var layers_dict  := {
	"root" : {
		"display_title" : "HOME"
	},
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
var root_layer_key := "root"

func assemble_layers_data():
	assert(layers_dict.has(root_layer_key)) ## root layer must be defined
	
	layers_graph = {}
	var unparented_layers := layers_dict.keys()
	unparented_layers.erase(root_layer_key)
	
	# create root node
	var root : Dictionary = layers_graph.get(root_layer_key, {})
	root["depth"] = 0
	layers_graph[root_layer_key] = root
	
	# graph out connections between layers
	for layer_key in layers_dict:
		var layer_dict = layers_dict.get(layer_key)
		var layer = layers_graph.get(layer_key, {})
		layer["child_layers"] = layer_dict.get("child_layers", [])
		layers_graph[layer_key] = layer
		
		for child_key in layer["child_layers"]:
			unparented_layers.erase(child_key)
			var child_layer = layers_graph.get(child_key, {})
			child_layer["parent_layer"] = layer_key
			layers_graph[child_key] = child_layer
	
	# all unparented nodes are added to root as children
	root["child_layers"] = unparented_layers
	for child_key in unparented_layers:
		layers_graph[child_key]["parent_layer"] = root_layer_key
	
	# traverse down from root layers to set depth values
	var layer_stack := [root_layer_key]
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
		
		if(layer_key != root_layer_key):
			layer.visible = false
		
		for child_key in layers_graph[layer_key]["child_layers"]:
			var child_element : LayerChildButtonElement = layer_child_button_element_scene.instantiate()
			layer.add_element(child_element)
			child_element.set_display_title(layers_dict[child_key]["display_title"])
			child_element.set_child_layer_key(child_key)

func assemble_layer_tabs(root_node):
	var layer_stack : Array = layers_graph[root_layer_key]["child_layers"]
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
		#LayerNode
		var layer_node : LayerNode = layer_nodes[layer_key]
		if(display_depth == 0):
			layer_node.focus_layer()
		else:
			layer_node.set_as_background(display_depth)
		
		#LayerTab
		if(layer_key != root_layer_key):
			var layer_tab : LayerTab = layer_tabs[layer_key]
			if(display_depth == 0):
				layer_tab.focus_layer()
			else:
				layer_tab.expand_child_container()
		
		layer_key = layers_graph[layer_key].get("parent_layer", null)
		display_depth += 1

func close_all_layers():
	for layer_key in layer_nodes.keys():
		#LayerNode
		var layer_node : LayerNode = layer_nodes[layer_key]
		layer_node.hide_layer()
		
		#LayerTab
		if(layer_key != root_layer_key):
			var layer_tab : LayerTab = layer_tabs[layer_key]
			layer_tab.unfocus_layer()

func get_layer_parent_key_from_key(layer_key: String):
	return layers_graph.get(layer_key, {}).get("parent_layer", "")

func get_layer_child_keys_from_key(layer_key: String):
	return layers_graph.get(layer_key, {}).get("child_layers", [])

func get_layer_node_from_key(layer_key: String):
	return layer_nodes.get(layer_key, null)

func get_layer_tab_from_key(layer_key: String):
	return layer_tabs.get(layer_key, null)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

