extends Node

@warning_ignore("unused_signal")
## When any item is submitted
signal item_submitted(node: Node)

@warning_ignore("unused_signal")
## document with input
signal document_submitted(input: String)

@warning_ignore("unused_signal")
signal document_completed()

@warning_ignore("unused_signal")
signal item_dropped(item: Node2D)

@warning_ignore("unused_signal")
signal circle_changed()

var player_name: String = ""

var held: Node = null 

var hit_coffee: bool = false

var debug_mode: bool = false
