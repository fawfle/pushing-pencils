extends Node

signal document_submitted(text: String)
signal document_completed()

var held: Node = null 

var hit_coffee: bool = false
