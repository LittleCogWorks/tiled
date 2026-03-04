class_name Game
extends Resource

# Unique game ID
var id: String = ""
# Current round number
var current_round: int = 0
# Game mode/type
var game_type: String = ""
# Game target score
var game_target: int = 1000
# Is the game currently active
var is_active: bool = false

# --- Round/question/result history ---
# Array of dictionaries: {round: int, question: Question, result: Dictionary}
var round_history: Array = []
# Current question (if any)
var current_question: Resource = null

# --- Methods ---

# Record round result
# TODO: This is never called anywhere — round_history is always empty.
# Call this from game_board._on_round_result() after each round resolves.
# Needed for end-of-game summary, stats, and network state sync.
# See code review doc § 2.8.
func record_round_result(round_num: int, question: Resource, result: Dictionary) -> void:
	round_history.append({"round": round_num, "question": question, "result": result})

# Set the current question
func set_current_question(q: Resource) -> void:
	current_question = q

# Clear all state for a new game
func reset() -> void:
	current_round = 0
	is_active = false
	round_history.clear()
	current_question = null
	
