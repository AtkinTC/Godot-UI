extends Node2D
class_name BackgroundLayerNode

var background_image: Image

@onready var background_color_rect: ColorRect = $Container/Background
@onready var border_color_rect: ColorRect = $Container/Border
@onready var title_label: Label = $Container/TitleLabel

var display_title := "DISPLAY_TITLE"

func _ready():
	update_title_label()

func set_display_title(title: String):
	display_title = title
	update_title_label()

func update_title_label():
	if(title_label):
		title_label.text = display_title
