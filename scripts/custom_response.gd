class_name CustomResponse

var activated: bool = false
var index: int = 0
var condition
var text: Array[String]
var type: DOC_TYPE = DOC_TYPE.WARNING
var apply_effect ## function to run on created document

func _init(_condition, _text, _doc_type: DOC_TYPE=DOC_TYPE.WARNING, _apply_effect=func(_x): return):		
	if _text is Array:
		text.assign(_text)
	else:
		text = [_text]
		
	condition = _condition
	type = _doc_type
	apply_effect = _apply_effect

func get_text():
	return text[index]

func update():
	index += 1
	if index == len(text):
		activated = true

enum DOC_TYPE {
	MEMO,
	WARNING,
	NOTICE,
	INDEX_CARD
}
