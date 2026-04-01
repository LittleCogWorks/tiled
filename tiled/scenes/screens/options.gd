extends Node2D

signal back_to_home

# Action buttons
@onready var start_button = $StartBtn
@onready var home_button = $HomeBtn
@onready var sfx_toggle = $Sound/Buttons/toggle
@onready var sfx_volume = $Sound/Buttons/Volume
@onready var sfx_volume_value = $Sound/Buttons/Value
@onready var music_toggle = $Music/Buttons/toggle
@onready var music_volume = $Music/Buttons/Volume
@onready var music_volume_value = $Music/Buttons/Value
@onready var internet_toggle = $Network/Buttons/toggle

const MIN_LINEAR_VOLUME := 0.001
const DEFAULT_LINEAR_VOLUME := 0.8


func _ready() -> void:
	start_button.pressed.connect(_on_back_pressed)
	home_button.pressed.connect(_on_back_pressed)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	music_toggle.toggled.connect(_on_music_toggled)
	music_volume.value_changed.connect(_on_music_volume_changed)
	internet_toggle.toggled.connect(_on_internet_toggled)

	_sync_from_settings()


func _sync_from_settings() -> void:
	_set_toggle_state(sfx_toggle, UserSettings.ui_sfx_enabled)
	_set_toggle_state(music_toggle, UserSettings.music_enabled)
	_set_toggle_state(internet_toggle, UserSettings.internet_enabled)

	var sfx_linear = _slider_value_from_settings(UserSettings.ui_sfx_enabled, UserSettings.ui_sfx_volume_db)
	sfx_volume.set_value_no_signal(sfx_linear)
	_update_slider_label(sfx_volume_value, sfx_linear)

	var music_linear = _slider_value_from_settings(UserSettings.music_enabled, UserSettings.music_volume_db)
	music_volume.set_value_no_signal(music_linear)
	_update_slider_label(music_volume_value, music_linear)


func _set_toggle_state(button: Button, enabled: bool) -> void:
	button.set_pressed_no_signal(enabled)
	button.text = "On" if enabled else "Off"


func _on_back_pressed() -> void:
	UISfx.play_ui_back()
	back_to_home.emit()


func _on_sfx_toggled(enabled: bool) -> void:
	if enabled and sfx_volume.value <= 0.0:
		sfx_volume.set_value_no_signal(DEFAULT_LINEAR_VOLUME)
		UserSettings.set_ui_sfx_volume_db(linear_to_db(DEFAULT_LINEAR_VOLUME))

	UserSettings.set_ui_sfx_enabled(enabled)
	_set_toggle_state(sfx_toggle, enabled)
	if enabled:
		UISfx.play_ui_confirm()


func _on_music_toggled(enabled: bool) -> void:
	UISfx.play_ui_click()
	if enabled and music_volume.value <= 0.0:
		music_volume.set_value_no_signal(DEFAULT_LINEAR_VOLUME)
		UserSettings.set_music_volume_db(linear_to_db(DEFAULT_LINEAR_VOLUME))

	UserSettings.set_music_enabled(enabled)
	_set_toggle_state(music_toggle, enabled)


func _on_internet_toggled(enabled: bool) -> void:
	UISfx.play_ui_click()
	UserSettings.set_internet_enabled(enabled)
	_set_toggle_state(internet_toggle, enabled)


func _on_sfx_volume_changed(value: float) -> void:
	_update_slider_label(sfx_volume_value, value)
	if value <= 0.0:
		UserSettings.set_ui_sfx_enabled(false)
		_set_toggle_state(sfx_toggle, false)
		return

	var linear = max(value, MIN_LINEAR_VOLUME)
	UserSettings.set_ui_sfx_volume_db(linear_to_db(linear))
	if not UserSettings.ui_sfx_enabled:
		UserSettings.set_ui_sfx_enabled(true)
		_set_toggle_state(sfx_toggle, true)
	UISfx.play_ui_click()


func _on_music_volume_changed(value: float) -> void:
	_update_slider_label(music_volume_value, value)
	if value <= 0.0:
		UserSettings.set_music_enabled(false)
		_set_toggle_state(music_toggle, false)
		return

	var linear = max(value, MIN_LINEAR_VOLUME)
	UserSettings.set_music_volume_db(linear_to_db(linear))
	if not UserSettings.music_enabled:
		UserSettings.set_music_enabled(true)
		_set_toggle_state(music_toggle, true)


func _slider_value_from_settings(enabled: bool, volume_db: float) -> float:
	if not enabled:
		return 0.0
	var linear = db_to_linear(volume_db)
	return clampf(linear, 0.0, 1.0)


func _update_slider_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(round(value * 100.0))
