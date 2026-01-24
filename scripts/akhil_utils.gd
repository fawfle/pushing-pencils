extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var word_list: PackedStringArray

func load_wordlist() -> void:
	var file_path = "res://wordlist.txt"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		# Splits by newline and removes empty entries
		word_list = content.split("\n", false)
		print("Loaded %d words." % word_list.size())


func generate_sentence(word_count: int) -> String:
	if word_list.is_empty():
		load_wordlist()
	
	var sentence = ""
	for i in range(word_count):
		if i!= 0:
			sentence += " "
		sentence += word_list[randi_range(0, word_list.size() - 1)]
	
	return sentence
	
func generate_doc_id() -> String:
	var generator = NanoIDGenerator.new("ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789")
	
	return generator.generate(3) + "-" + generator.generate(3)
