extends Node

enum ID {
	ANYTHING,
	ANYTHING_NOT_EMPTY,
	PENCIL_ONLY,
	PEN_ONLY,
	MATCH,
	HYPHEN_SPACE,
	ONLY_FIRST_13_LETTERS,
	ONLY_LAST_13_LETTERS,
	ALPHANUMERIC,
	REVERSE_EACH_WORD,
	NO_VOWELS,
	FLIP_CASE,
	ALPHABETICAL_ORDER,
	RANDOM_NORMAL,
	RANDOM_NEW_CIRCLE,
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
			ret = source.replace(" ", "-")
		ID.ONLY_FIRST_13_LETTERS:
			var regex = RegEx.new()
			regex.compile("[n-zN-Z]")
			ret = regex.sub(source, "", true)
		ID.ONLY_LAST_13_LETTERS:
			var regex = RegEx.new()
			regex.compile("[a-mA-M]")
			ret = regex.sub(source, "", true)
		ID.ALPHANUMERIC:
			var trans = ""
			for c in source.to_lower():
				if c == " ":
					trans += " "
					continue
					
				var code: int = c.unicode_at(0) - 96
				if code > 25:
					trans+= c
				trans += str(code)
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
		ID.FLIP_CASE:
			var trans = ""
			for c in source:
				if c == " ":
					trans += " "
					continue
				var u = c.to_upper()
				var l = c.to_lower()
				if u == l:
					trans += c
				elif c == u:
					trans += l
				elif c == l:
					trans += u
			ret = trans
		ID.ALPHABETICAL_ORDER:
			var trans: Array[String] = []

			for word in source.split(" "):
				var letters: Array[String] = []
				var positions: Array[int] = []

				# Collect alphabetic characters and their positions
				for i in word.length():
					var c := word[i]
					if c.to_lower() != c.to_upper():
						letters.append(c)
						positions.append(i)

				# Sort letters alphabetically (case-insensitive, stable)
				letters.sort_custom(func(a, b):
					return a.to_lower() < b.to_lower()
				)

				# Rebuild the word
				var chars := word.split("")
				for j in positions.size():
					chars[positions[j]] = letters[j]

				trans.append("".join(chars))

			ret = " ".join(trans)

	return clean_text(ret)

func clean_text(text: String):
	if text.length() == 0: return text
	
	while text[text.length() - 1] == " ": text = text.substr(0, text.length() - 1)
	while text.contains("  "): text = text.replace("  ", " ")
	
	return text

var rule_descriptions = {
	ID.HYPHEN_SPACE: "due to technical restrictions, spaces are now hyphens",
	ID.ONLY_FIRST_13_LETTERS: "no letters in the last half of the alphabet",
	ID.ALPHANUMERIC: "transform all letters into their position in the alphabet (a->1)",
	ID.REVERSE_EACH_WORD: "flip each word",
	ID.NO_VOWELS: "vowels take up too much space, drop them for efficiency"
}
