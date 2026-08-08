extends SceneTree

## Godot-side entry point for the project-owned Chapter IV score renderer.
## The Python source is authoritative and produces MIDI, score JSON, analysis
## and the three formal OGG masters without downloading or sampling anything.

const PYTHON_EXECUTABLE: String = "/opt/anaconda3/bin/python3"
const GENERATOR_PATH: String = "res://chapters/chapter_04_drowned_underkeep/assets/audio/music/boss/soul_gaoler_ormund/source/generate_soul_gaoler_ormund_score.py"


func _initialize() -> void:
	var absolute_generator: String = ProjectSettings.globalize_path(GENERATOR_PATH)
	var output: Array = []
	var exit_code: int = OS.execute(PYTHON_EXECUTABLE, [absolute_generator], output, true)
	for line: Variant in output:
		print(str(line))
	if exit_code != 0:
		push_error("Soul Gaoler score generation failed with exit code %d" % exit_code)
	quit(exit_code)
