extends Node2D

signal start_game
signal exit_game

@onready var start_game_btn = $StartGame
@onready var options_btn = $Options
@onready var exit_btn = $Exit
@onready var accept_dialog = $AcceptDialog
@onready var click_sound = $ClickSound
@onready var bg_music = $BGM

const CLICK_LEAD_IN_SECONDS: float = 0.05
var _start_requested: bool = false


func _ready() -> void:
	print("GameHome scene ready")
	start_game_btn.pressed.connect(_on_start_game_btn_pressed)
	options_btn.pressed.connect(_on_options_btn_pressed)
	exit_btn.pressed.connect(_on_exit_btn_pressed)
	accept_dialog.confirmed.connect(_on_AcceptDialog_confirmed)

	start_game_btn.grab_focus()
	start_game_btn.focus_mode = Control.FOCUS_ALL
	options_btn.focus_mode = Control.FOCUS_NONE
	options_btn.disabled = true
	exit_btn.focus_mode = Control.FOCUS_ALL
	bg_music.play()

func _play_click_sound() -> void:
	# Restart if already playing so rapid presses always produce a click.
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

func _on_start_game_btn_pressed() -> void:
	if _start_requested:
		return
	_start_requested = true
	start_game_btn.disabled = true
	_play_click_sound()
	# Small lead-in prevents scene transition from cutting off the click.
	await get_tree().create_timer(CLICK_LEAD_IN_SECONDS).timeout
	print("Start Game button pressed, emitting start_game signal")
	start_game.emit()

func _on_options_btn_pressed() -> void:
	# TODO: Implement settings screen
	print("Options button pressed - no options implemented yet")

func _on_exit_btn_pressed() -> void:
	_play_click_sound()
	accept_dialog.popup_centered()
	await get_tree().process_frame # Wait one frame
	if is_instance_valid(accept_dialog):
		var ok_button = accept_dialog.get_ok_button()
		if is_instance_valid(ok_button):
			ok_button.grab_focus() # Focus the OK button

func _on_AcceptDialog_confirmed() -> void:
	_play_click_sound()
	if not NetworkManager.is_local:
		NetworkManager.stop_server()
	print("Exit button pressed, quitting application")
	exit_game.emit()
