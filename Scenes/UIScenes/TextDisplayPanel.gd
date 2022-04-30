extends VBoxContainer
class_name TextDisplayPanel

@onready var text_display: RichTextLabel = $PanelContainer/TextDisplay

signal trigger_rebuild
signal graph_type_selection
signal trigger_navigation_batch
signal trigger_clear_navigation
signal map_selection

func _ready():
	clear_text()
	text_display.scroll_following = true

func clear_text():
	text_display.text = ""

func print_line(line: String):
	text_display.text += "\n" + line
	return text_display.get_line_count()

func print_lines(lines: Array):
	for line in lines:
		print_line(str(line))
	return text_display.get_line_count()

func _on_clear_text_button_pressed():
	clear_text()
