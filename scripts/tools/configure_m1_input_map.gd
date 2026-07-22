extends SceneTree

## Writes the M1 locomotion and M1.5 action prototype inputs deterministically.

const ACTION_EVENTS: Dictionary[String, Array] = {
	"player_move_left": [KEY_A, KEY_LEFT],
	"player_move_right": [KEY_D, KEY_RIGHT],
	"player_jump": [KEY_SPACE],
	"dash": [KEY_SHIFT],
	"player_attack": [KEY_J],
}


func _initialize() -> void:
	call_deferred("_configure")


func _configure() -> void:
	ProjectSettings.set_setting("input/player_dash", null)
	for action_name: String in ACTION_EVENTS:
		var events: Array[InputEventKey] = []
		var keycodes: Array = ACTION_EVENTS[action_name]
		for keycode_variant: Variant in keycodes:
			var keycode: Key = keycode_variant as Key
			if action_name == "dash":
				var left_shift: InputEventKey = InputEventKey.new()
				left_shift.physical_keycode = keycode
				left_shift.location = KEY_LOCATION_LEFT
				events.append(left_shift)
				var right_shift: InputEventKey = InputEventKey.new()
				right_shift.physical_keycode = keycode
				right_shift.location = KEY_LOCATION_RIGHT
				events.append(right_shift)
			else:
				var event: InputEventKey = InputEventKey.new()
				event.physical_keycode = keycode
				events.append(event)
		ProjectSettings.set_setting("input/%s" % action_name, {
			"deadzone": 0.5,
			"events": events,
		})
	var save_error: Error = ProjectSettings.save()
	print("M15_INPUT_MAP_CONFIG: %s" % error_string(save_error))
	quit(0 if save_error == OK else 1)
