extends Node

signal document_submitted(text: String)
signal document_completed()

signal item_dropped(node: Node2D)

var held: Node = null 

var hit_coffee: bool = false
