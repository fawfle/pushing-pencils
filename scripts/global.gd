extends Node

signal document_submitted(input: String)
signal document_completed()

signal item_dropped(item: Node2D)

var held: Node = null 

var hit_coffee: bool = false
