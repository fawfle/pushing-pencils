extends Node3D

var credits_scene = preload("res://credits.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	$AudioStreamPlayer.play()
	$Timer.start()


func _on_timer_timeout() -> void:
	add_child(credits_scene.instantiate())
