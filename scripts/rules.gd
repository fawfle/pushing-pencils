class_name Rules
extends Node

enum ID {
	DOUBLE_SPACE,
	ONLY_FIRST_13_LETTERS
}

class Rule:
	var id: ID
	var name: String
	var active: bool
	
	func _init(i, n):
		id = i
		name = n
		
	func activate():
		active=true
		
	func check(text: String) -> bool:
		match id:
			ID.DOUBLE_SPACE:
				return text.count(" ") * 2 == text.count("  ")
			ID.ONLY_FIRST_13_LETTERS:
				for c in ['N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']:
					if text.to_upper().contains(c):
						return false
		return true
	
var rules = [
	Rule.new(ID.DOUBLE_SPACE, "double space"),
	Rule.new(ID.ONLY_FIRST_13_LETTERS, "no letters in the last half of the alphabet")
]
