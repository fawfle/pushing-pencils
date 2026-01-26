extends PathFollow3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_child(0).make_current();
	#self.get_parent().make_current($Path3D/PathFollow3D/Camera3D)
	create_tween().tween_property(self, "progress_ratio", 1, 5)
	
	await get_tree().create_timer(5).timeout
	var test = get_tree().get_nodes_in_group("camtest")
	test[1].make_current()
