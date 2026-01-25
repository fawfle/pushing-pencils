extends Sprite2D

var overlapping_document: bool = false
@onready var area2D: Area2D = $Area2D

func _ready() -> void:
	Global.item_dropped.connect(on_item_dropped)

func _on_area_2d_area_entered(area: Area2D) -> void:	
	if area.get_parent() is Document:
		overlapping_document = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Document:
		overlapping_document = false

func on_item_dropped(item: Node2D):
	if item is Document and overlapping_document:
		Global.document_submitted.emit(item.get_text())
		return
		
	var overlapping := area2D.get_overlapping_areas()
	for area in overlapping:
		var parent := area.get_parent()
		if parent == item:
			Global.item_submitted.emit(parent)
