## A data class for player messages
class_name Message

enum TYPE {
	MEMO,
	WARNING,
	NOTICE,
	INDEX_CARD,
	AWARD_3
}

const type_scenes: Dictionary[TYPE, PackedScene] = {
	TYPE.MEMO: preload("res://objects/memo.tscn"),
	TYPE.WARNING: preload("res://objects/warning.tscn"),
	TYPE.NOTICE: preload("res://objects/notice.tscn"),
	TYPE.INDEX_CARD: preload("res://objects/index_card.tscn"),
}

var text: String
var type: TYPE = TYPE.WARNING
var wait_time: float = 1.5

func _init(_type: TYPE, _text: String, _wait_time:float=1.5) -> void:
	text = _text;
	type = _type;
	wait_time = _wait_time
	

func instantiate_scene() -> Node2D:
	var scene: PackedScene = type_scenes.get(type);
	if scene == null: return null
	return scene.instantiate()
