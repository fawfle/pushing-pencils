extends Node2D

## pages of index 2i and 2i+1 are active
var page_index: int = 0

@onready var pages:  = ($Pages).get_children()
@onready var page_turn_sound := $PageTurn

func _ready() -> void:
	set_pages(page_index, true)

func _on_right_button_pressed() -> void:
	if (page_index == 0): return
	
	set_pages(page_index, false)
	page_index = max(page_index - 1, 0)
	set_pages(page_index, true)
	page_turn_sound.play()


func _on_left_button_pressed() -> void:
	if (page_index == len(pages) / 2.0 - 1): return
	
	set_pages(page_index, false)
	page_index = min(page_index + 1, len(pages) / 2.0 - 1)
	set_pages(page_index, true)
	page_turn_sound.play()

func set_pages(index: int, now_visible: bool) -> void:
	pages[2 * index].visible = now_visible
	pages[2 * index + 1].visible = now_visible
