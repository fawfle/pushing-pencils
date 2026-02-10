class_name TASK_LIST

enum {
	MEMO,
	NOTICE,
	REJECTION_MEMO,
	NODES,
	RULES,
	TYPE,
	ON_START,
}

## Rounds master variable. Is a dictionary so indexes are more visible when editing, but secretly used as an array (don't tell anyone). 
static var TASK_DATA: Dictionary[int, Dictionary] = {
	 #n: {
		#MEMO: "",
		#NOTICE: "",
		#REJECTION_MEMO: "",
		#NODES: [],
		#RULES: [Rules.ID],
		#TYPE: GameManager.ROUND_TYPE
	#},
	0: {
		MEMO: "WELCOME: ENTER YOUR NAME",
		REJECTION_MEMO: "PLEASE ENTER YOUR NAME",
		RULES: [Rules.ID.ANYTHING_NOT_EMPTY],
		TYPE: GameManager.ROUND_TYPE.DOC_ONLY
	},
	1: {
		MEMO: "COPY THE TEXT",
		RULES: [Rules.ID.MATCH],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	2: {
		MEMO: "NEWS: ALL EMPLOYEES MUST WASH HANDS",
		RULES: [Rules.ID.MATCH],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	3: {
		NODES: [preload("res://objects/book.tscn")],
		RULES: [Rules.ID.HYPHEN_SPACE],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	4: {
		RULES: [Rules.ID.REVERSE_EACH_WORD],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	5: {
		NODES: [preload("res://objects/eraser.tscn")],
		RULES: [Rules.ID.NO_VOWELS],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	6: {
		RULES: [Rules.ID.ONLY_FIRST_13_LETTERS],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	7: {
		NODES: [preload("res://objects/pamphlet1.tscn")],
		RULES: [Rules.ID.FLIP_CASE],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	8: {
		RULES: [Rules.ID.ALPHABETICAL_ORDER],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	9: {
		NODES: [preload("res://objects/plaque.tscn")],
		RULES: [Rules.ID.RANDOM_NORMAL],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	10: {
		NODES: [preload("res://objects/paperweight.tscn")],
		MEMO: "MANDITORY SAFETY PAPERWEIGHT",
		RULES: [Rules.ID.RANDOM_NORMAL],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	11: {
		RULES: [Rules.ID.RANDOM_NORMAL],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	12: {
		NODES: [preload("res://objects/award_2.tscn")],
		NOTICE: "YOU WERE #2 EMPLOYEE OF  THE DAY. QUOTA INCREASED",
		RULES: [Rules.ID.RANDOM_NORMAL],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	13: {
		NODES: [preload("res://objects/pen.tscn")],
		MEMO: "TO KEEP THINGS PROFESSIONAL, USE PEN",
		RULES: [Rules.ID.PEN_ONLY],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	14: {
		NODES: [preload("res://objects/bell.tscn")],
		RULES: [Rules.ID.PENCIL_ONLY],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE
	},
	15: {
		RULES: [Rules.ID.ONLY_LAST_13_LETTERS],
		TYPE: GameManager.ROUND_TYPE.DOC_FILE,
		ON_START: func(): Global.circle_changed.emit()
	},
	16: {
		MEMO: "YOU'VE BEEN PROMOTED!"
	}
}

## array of tasks
static var TASKS: Array[Task] = LOAD_TASKS();

static func LOAD_TASKS() -> Array[Task]:
	print("loaded tasks")
	var res: Array[Task];
	for value: Dictionary in TASK_DATA.values():
		var task: Task = Task.new();
		
		if value.get(MEMO): task.memo_text = value.get(MEMO)
		if value.get(NOTICE): task.notice_text = value.get(NOTICE)
		if value.get(REJECTION_MEMO): task.rejection_memo_text = value.get(REJECTION_MEMO)
		
		if value.get(NODES):
			if value.get(NODES) is Array:
				task.nodes_to_add.assign(value.get(NODES))
			else:
				task.nodes_to_add.assign([value.get(NODES)])
		if value.get(RULES) != null: 
			if value.get(RULES) is Array:
				task.rules.assign(value.get(RULES))
			else:
				task.rules.assign([value.get(RULES)])
		
		if value.get(TYPE) != null: task.round_type = value.get(TYPE)
		if value.get(ON_START) != null: task.on_start = value.get(ON_START)
		
		res.append(task)
	
	return res;
