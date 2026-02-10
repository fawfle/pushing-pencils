class_name Task

# var on_completed: int
var nodes_to_add: Array[PackedScene]
## send a memo with text. "" means no memo
var memo_text: String
## send a memo with text. "" means no notice_text
var notice_text: String
## send a memo on rejection. "" means no memo
var rejection_memo_text: String
## flag to update rules
# var update_rules: bool = false
var rules: Array[Rules.ID]
## update the quoata. 0 means no update
# @export var new_quota: int
# var change_round_type: bool = false
## the type of round. Currently main is single file and single doc
var round_type: GameManager.ROUND_TYPE = GameManager.ROUND_TYPE.DOC_FILE

## function to execute on start of task
var on_start: Callable
