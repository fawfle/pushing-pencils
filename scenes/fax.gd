extends Sprite2D

var overlapping_document: bool = false

func _ready() -> void:
	Global.item_dropped.connect(on_item_dropped)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.get_parent() is Document:
		return
		
	overlapping_document = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if not area.get_parent() is Document:
		return
	
	overlapping_document = false

func on_item_dropped(item: Node2D):
	if not item is Document:
		return
	
	Global.document_submitted.emit()
