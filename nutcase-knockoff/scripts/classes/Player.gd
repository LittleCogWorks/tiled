class_name Player
extends Resource

# Player — scripts/classes/Player.gd
# Resource representing a single player. Intentionally thin — just data.
# Game rules live in GameManager; collection/turn logic lives in PlayerManager.
#
# MULTIPLAYER NOTES:
#   device_id is already here — it will hold the WebSocket connection ID assigned
#   by NetworkManager when the player joins the lobby.
#   Consider adding:
#     var is_connected: bool = true  — track live connection status
#     var avatar_index: int = 0      — chosen avatar (index into GameConfig.PLR_BADGE_ICONS)

var id: String = ""              # Unique ID (e.g., "player_1")
var name: String = ""            # Display name ("Alice")
var score: int = 0               # Current points
var is_frozen: bool = false      # Locked out after wrong guess this round
var device_id: String = ""       # WebSocket connection ID (set by NetworkManager in multiplayer)
var color: Color = Color.WHITE   # Visual identifier (random on init)

func _init(p_id: String = "", p_name: String = "Player") -> void:
	id = p_id
	name = p_name
	# Assign random color if not set
	color = Color(randf(), randf(), randf())

func add_score(points: int) -> void:
	score += points
	print("%s scored %d points! Total: %d" % [name, points, score])

func freeze() -> void:
	is_frozen = true
	print("%s has been frozen!" % name)

func unfreeze() -> void:
	is_frozen = false
	print("%s is back in the game!" % name)

func reset_for_new_round() -> void:
	is_frozen = false
