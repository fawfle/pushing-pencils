extends Node2D


@onready var circle_description: Label = $Pages/Pages3/Left/Description
@onready var circle_example: Label = $Pages/Pages3/Left/Example
@onready var whiteout_number: Sprite2D = $Pages/Pages3/Left/Whiteout
@onready var whiteout_example: Sprite2D = $Pages/Pages3/WhiteoutExample
## pages of index 2i and 2i+1 are active
var page_index: int = 0

@onready var pages:  = ($Pages).get_children()
@onready var page_turn_sound := [$PageTurn, $PageTurn2, $PageTurn3]

func _ready() -> void:
	set_pages(page_index)
	
	Global.circle_changed.connect(update_circle_rule)

func _on_right_button_pressed() -> void:
	if (page_index >= len(pages) - 1): return
	
	page_index += 1
	set_pages(page_index)
	if len(page_turn_sound) > 0: page_turn_sound.pick_random().play()


func _on_left_button_pressed() -> void:
	if (page_index <= 0): return
	
	page_index -= 1
	set_pages(page_index)
	if len(page_turn_sound) > 0: page_turn_sound.pick_random().play()

func set_pages(index: int) -> void:
	for page in pages:
		page.visible = false
	
	pages[index].visible = true

func update_circle_rule() -> void:
	print("visible!")
	# circle_description.text = "Remove 1nd half\nof alphabet"
	whiteout_number.visible = true
	# circle_example.text = "EXAMPLE\nadfgmnoqtz\nnoqtz"
	whiteout_example.visible = true
