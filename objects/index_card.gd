class_name IndexCard extends TextItem

@onready var simple_header: Sprite2D = $SimpleHeader
@onready var fancy_header: Sprite2D = $FancyHeader


func set_simple_header(now_visible: bool = true):
	simple_header.visible = now_visible

func set_fancy_header(now_visible: bool = true):
	fancy_header.visible = now_visible
