extends Node

enum ID {
	ANYTHING,
	ANYTHING_NOT_EMPTY,
	PENCIL_ONLY,
	PEN_ONLY,
	MATCH,
	HYPHEN_SPACE,
	ONLY_FIRST_13_LETTERS,
	ALPHANUMERIC,
	REVERSE_EACH_WORD,
	NO_VOWELS,
	FLIP_CASE,
	ALPHABETICAL_ORDER,
}

func check_rules(rules: Array[ID], source: String, input: String) -> bool:
	if len(rules) == 1:
		if rules[0] == ID.ANYTHING:
			return true
		if rules[0] == ID.ANYTHING_NOT_EMPTY:
			return input != ""
	
	return apply_multiple(rules, source) == input

func apply_multiple(rules: Array[ID], source: String) -> String:
	var new_source: String = source
	for rule in rules:
		new_source = apply(rule, new_source)
		
	return new_source

func apply(id: ID, source: String) -> String:
	var ret: String = source
	match id:
		ID.HYPHEN_SPACE:
			return source.replace(" ", "-")
		ID.ONLY_FIRST_13_LETTERS:
			var regex = RegEx.new()
			regex.compile("[n-zN-Z]")
			ret = regex.sub(source, "", true)
			
		ID.ALPHANUMERIC:
			var trans = ""
			for c in source.to_lower():
				if c == " ":
					trans += " "
					continue
					
				var code = c.unicode_at(0) - 96
				if code > 25:
					trans+= c
				trans += code
			ret = trans
		ID.REVERSE_EACH_WORD:
			var trans = []
			for word in source.split(" "):
				trans.append(word.reverse())
			ret = " ".join(trans)
		ID.NO_VOWELS:
			var regex = RegEx.new()
			regex.compile("[aeiouyAEIOUY]")
			ret = regex.sub(source, "", true)
	return ret

func clean_text(text: String):
	while text[text.length() - 1] == " ": text = text.substr(0, text.length() - 2)
	while text.contains("  "): text = text.replace("  ", " ")
	
	return text

var rule_descriptions = {
	ID.HYPHEN_SPACE: "due to technical restrictions, spaces are now hyphens",
	ID.ONLY_FIRST_13_LETTERS: "no letters in the last half of the alphabet",
	ID.ALPHANUMERIC: "transform all letters into their position in the alphabet (a->1)",
	ID.REVERSE_EACH_WORD: "flip each word",
	ID.NO_VOWELS: "vowels take up too much space, drop them for efficiency"
}
