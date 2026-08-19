extends SceneTree

const EDRAN_SCENE: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/"
	+ "ch3_boss_sanctum.tscn"
)
const DUCHESS_SCENE: String = (
	"res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
)

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var edran: Node = _instantiate(EDRAN_SCENE)
	var duchess: Node = _instantiate(DUCHESS_SCENE)
	if edran == null or duchess == null:
		_finish()
		return
	var edran_root: String = "BossIntroOverlay/"
	var duchess_root: String = (
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/"
	)
	var edran_name: Label = edran.get_node(edran_root + "BossTitle/Name") as Label
	var duchess_name: Label = duchess.get_node(duchess_root + "DuchessIntroCard/Name") as Label
	var edran_epithet: Label = edran.get_node(edran_root + "BossTitle/Epithet") as Label
	var duchess_epithet: Label = duchess.get_node(duchess_root + "DuchessIntroCard/Epithet") as Label
	var edran_dialogue_panel: Control = edran.get_node(edran_root + "DialoguePanel") as Control
	var duchess_dialogue_panel: Control = duchess.get_node(duchess_root + "DuchessDialogue") as Control
	var edran_dialogue: Label = edran.get_node(edran_root + "DialoguePanel/Dialogue") as Label
	var duchess_dialogue: Label = duchess.get_node(duchess_root + "DuchessDialogue/Dialogue") as Label
	var edran_phase_name: Label = edran.get_node(edran_root + "PhaseTitle/Name") as Label
	var duchess_phase_name: Label = duchess.get_node(duchess_root + "DuchessPhaseTitle/Name") as Label
	var edran_phase_zh: Label = edran.get_node(edran_root + "PhaseTitle/Chinese") as Label
	var duchess_phase_zh: Label = duchess.get_node(duchess_root + "DuchessPhaseTitle/Chinese") as Label
	_expect_same_label_style(edran_name, duchess_name, "Boss name")
	_expect_same_label_style(edran_epithet, duchess_epithet, "Boss epithet")
	_expect_same_label_style(edran_dialogue, duchess_dialogue, "Dialogue")
	_expect_same_label_style(edran_phase_name, duchess_phase_name, "Phase name")
	_expect_same_label_style(edran_phase_zh, duchess_phase_zh, "Phase Chinese")
	_expect(edran_dialogue_panel.offset_left == duchess_dialogue_panel.offset_left, "Dialogue left margin differs")
	_expect(edran_dialogue_panel.offset_top == duchess_dialogue_panel.offset_top, "Dialogue top margin differs")
	_expect(edran_dialogue_panel.offset_right == duchess_dialogue_panel.offset_right, "Dialogue right margin differs")
	_expect(edran_dialogue_panel.offset_bottom == duchess_dialogue_panel.offset_bottom, "Dialogue bottom margin differs")
	_expect(not edran_name.has_theme_font_override("font"), "Edran must remain on the project default font")
	_expect(not duchess_name.has_theme_font_override("font"), "Duchess must reuse the project default font")
	_expect(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/bootstrap/main_bootstrap.tscn", "MainBootstrap must remain the F5 authority")
	edran.free()
	duchess.free()
	_finish()


func _instantiate(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		_failures.append("Could not load %s" % path)
		return null
	return packed.instantiate()


func _expect_same_label_style(reference: Label, candidate: Label, label_name: String) -> void:
	_expect(reference.get_theme_font_size("font_size") == candidate.get_theme_font_size("font_size"), "%s font size differs" % label_name)
	_expect(reference.get_theme_color("font_color") == candidate.get_theme_color("font_color"), "%s color differs" % label_name)
	_expect(reference.get_theme_color("font_outline_color") == candidate.get_theme_color("font_outline_color"), "%s outline color differs" % label_name)
	_expect(reference.get_theme_constant("outline_size") == candidate.get_theme_constant("outline_size"), "%s outline size differs" % label_name)
	_expect(reference.horizontal_alignment == candidate.horizontal_alignment, "%s alignment differs" % label_name)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BOSS_INTRO_UI_CONTRACT: PASS CH2=EDRAN_REFERENCE CH3=UNCHANGED")
		quit(0)
		return
	for failure: String in _failures:
		push_error("BOSS_INTRO_UI_CONTRACT: %s" % failure)
	quit(1)
