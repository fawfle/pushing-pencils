extends Node

enum ID {
	NONE,
	DOUBLE_SPACE,
	ONLY_FIRST_13_LETTERS
}

func check_rules(rules: Array[ID], source: String, input: String) -> bool:
	return apply_multiple(rules, source) == input

func apply_multiple(rules: Array[ID], source: String) -> String:
	var new_source: String = source
	for rule in rules:
		new_source = apply(rule, new_source)
		
	return new_source

func apply(id: ID, source: String) -> String:
	match id:
		ID.DOUBLE_SPACE:
			return source.replace(" ", "  ")
		ID.ONLY_FIRST_13_LETTERS:
			var regex = RegEx.new()
			regex.compile("/[n-zN-z]/")
			return regex.sub(source, "")
	return source
	
var rule_descriptions = {
	ID.DOUBLE_SPACE: "double space",
	ID.ONLY_FIRST_13_LETTERS: "no letters in the last half of the alphabet"
}
