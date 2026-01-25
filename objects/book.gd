extends Node2D



func _on_button_pressed() -> void:
	$Pages/Page0003.visible = true
	$Pages/Page0004.visible = true
	$Pages/Page0001.visible = false
	$Pages/Page0002.visible = false
	$AudioStreamPlayer2D.play()


func _on_button_2_pressed() -> void:
	$Pages/Page0001.visible = true
	$Pages/Page0002.visible = true
	$Pages/Page0003.visible = false
	$Pages/Page0004.visible = false
	$AudioStreamPlayer2D.play()
