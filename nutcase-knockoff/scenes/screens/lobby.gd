extends Node2D

@onready var room_code_label = $RoomInfoContainer/Code
@onready var players_list= $PlayersContainer/Players
@onready var game_code_label = $RoomInfoContainer/Code
@onready var instructions_label = $JoinContainer/instructions
@onready var start_button = $StartBtn
@onready var home_button = $HomeBtn

signal lobby_start_requested(settings: Dictionary)
signal lobby_back_to_home
signal lobby_back_to_setup

const p_badge = preload("res://scenes/components/player_badge.tscn") 
var _setup_settings: Dictionary = {}

func configure(settings: Dictionary) -> void:
	_setup_settings = settings.duplicate(true)


func _ready() -> void:

	if NetworkManager.is_local == false:
		NetworkManager.start_server()
		room_code_label.text = "Room Code: %s" % NetworkManager.room_code
		NetworkManager.player_join_received.connect(_on_player_joined)
		NetworkManager.client_disconnected.connect(_on_player_disconnected)
		_update_players_list()
		_update_start_button_state()
	else:
		room_code_label.text = "Offline Lobby (Multiplayer mode not active)"


func _on_player_joined(device_id: String, player_name: String, avatar_index: int) -> void:
	print("Player joined: %s (Device ID: %s)" % [player_name, device_id])
	#  validate input
	var res = InputValidator.validate_player_name(player_name)
	if res["valid"] == false:
		print("Invalid player name '%s' from device %s, rejecting join" % [player_name, device_id])
		print("Reason: %s" % res["error"])
		return
	if avatar_index < 0 or avatar_index >= GameConfig.PLR_BADGE_ICONS.size():
		print("Invalid avatar index %d from device %s, rejecting join" % [avatar_index, device_id])
		return
	
	if PlayerManager.get_player_by_device_id(device_id) == null:
		PlayerManager.add_player(player_name, device_id, avatar_index)
		
	
	_update_players_list()
	_update_start_button_state()

func _on_player_disconnected(device_id: String) -> void:
	print("Player disconnected: Device ID %s" % device_id)
	var player = PlayerManager.get_player_by_device_id(device_id)
	if player != null:
		print("Removing player: %s (Device ID: %s)" % [player.name, device_id])
		PlayerManager.remove_player(player.id)
		_update_players_list()
		_update_start_button_state()


func _update_players_list() -> void:
	if players_list.get_child_count() > 0:
		for child in players_list.get_children():
			child.free()
	for player in PlayerManager.players:
		var badge_instance = p_badge.instantiate()
		players_list.add_child(badge_instance)
		badge_instance.setup(player)

func _update_start_button_state() -> void:
	start_button.disabled = PlayerManager.players.size() < 2

func _on_start_button_pressed() -> void:
	print("Start button pressed in lobby, emitting lobby_start_requested signal")
	if _setup_settings.is_empty():
		push_warning("Lobby settings are empty; cannot start game")
		return

	var settings = _setup_settings.duplicate(true)
	settings["players"] = PlayerManager.players
	settings["player_count"] = PlayerManager.players.size()

	lobby_start_requested.emit(settings)

	# Old direct GameManager.game usage kept here for reference during transition:
	# var settings = {
	# 	"players": PlayerManager.players,
	# 	"player_count": PlayerManager.players.size(),
	# 	"game_mode": GameManager.game.game_mode,
	# 	"game_type": GameManager.game.game_type,
	# 	"game_target": GameManager.game.game_target
	# }
	# lobby_start_requested.emit(settings)

func _on_home_button_pressed() -> void:
	print("Home button pressed in lobby, emitting lobby_back_to_home signal")
	lobby_back_to_home.emit()
	NetworkManager.stop_server()  # Stop server if we're going back to home
	
func _on_return_to_setup_pressed() -> void:
	print("Back to setup button pressed in lobby, emitting lobby_back_to_setup signal")
	lobby_back_to_setup.emit()
	NetworkManager.stop_server()  # Stop server if we're going back to setup

