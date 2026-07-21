extends SceneTree

## Writes the M1 locomotion and M1.5 action prototype inputs deterministically.

const ACTION_EVENTS: Dictionary[String, Array] = {
	"player_move_left": [KEY_A, KEY_LEFT],
	"player_move_right": [KEY_D, KEY_RIGHT],
	"player_jump": [KEY_SPACE],
	"player_dash": [KEY_SHIFT],
	"player_attack": [KEY_J],
}


func _initialize() -> void:
	call_deferred("_configure")


func _configure() -> void:
	for action_name: String in ACTION_EVENTS:
		var events: Array[InputEventKey] = []
		var keycodes: Array = ACTION_EVENTS[action_name]
		for keycode_variant: Variant in keycodes:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = keycode_variant as Key
			events.append(event)
		ProjectSettings.set_setting("input/%s" % action_name, {
			"deadzone": 0.5,
			"events": events,
		})
	var save_error: Error = ProjectSettings.save()
	print("M15_INPUT_MAP_CONFIG: %s" % error_string(save_error))
	quit(0 if save_error == OK else 1)
