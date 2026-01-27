extends Node

## any item
signal item_submitted(node: Node)
## document with input
signal document_submitted(input: String)
signal document_completed()

signal item_dropped(item: Node2D)

signal circle_changed()

var player_name: String = ""

var held: Node = null 

var hit_coffee: bool = false
