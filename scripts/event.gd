class_name Event extends Resource

# @export var on_completed: int
@export var nodes_to_add: Array[PackedScene]
## send a memo with text. "" means no memo
@export var memo_text: String
## send a memo on rejection. "" means no memo
@export var rejection_memo_text: String
## flag to update rules
@export var update_rules: bool = false
@export var rules: Array[Rules.ID]
## update the quoata. 0 means no update
# @export var new_quota: int
@export var change_round_type: bool = false
## the type of round. Currently main is single file and single doc
@export var round_type: GameManager.ROUND_TYPE = GameManager.ROUND_TYPE.DOC_FILE
