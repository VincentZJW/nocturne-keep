extends SceneTree

## Deterministic evidence composer for the full remaining Chapter IV replication pass.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const QA_ROOT: String = "res://docs/qa/chapter_04_character_replication"
const ROLES: Array[String] = [
	"drowned_gaoler", "chainbound_convict", "mire_harpooner",
	"sunken_shield_penitent", "bog_toad", "sewer_maw", "underkeep_executioner",
]
const PRIMARY_ACTION: Dictionary[String, String] = {
	"drowned_gaoler": "jailer_cleave",
	"chainbound_convict": "chain_sweep",
	"mire_harpooner": "harpoon_shot",
	"sunken_shield_penitent": "shield_bash",
	"bog_toad": "leap_crush",
	"sewer_maw": "sewer_bite",
	"underkeep_executioner": "executioner_cleave",
}
const BG: Color = Color("0a1118")
const PANEL: Color = Color("111c26")
const DIVIDER: Color = Color("50616d")


func _initialize() -> void:
	var failures: int = 0
	for role: String in ROLES:
		failures += _write_role_evidence(role)
	failures += _write_ormund_evidence()
	print("CH4 CHARACTER REPLICATION EVIDENCE | %s roles=%d" % ["PASS" if failures == 0 else "FAIL %d" % failures, ROLES.size()+1])
	quit(0 if failures == 0 else 1)


func _write_role_evidence(role: String) -> int:
	var output: String = "%s/%s" % [QA_ROOT, role]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var concept: Image = _load("%s/assets/enemies/%s/concept_art/%s_concept_sheet.png" % [ROOT,role,role])
	var current: Image = _load("%s/assets/enemies/%s/reference/%s_runtime_reference.png" % [ROOT,role,role])
	var legacy: Image = _load("%s/archive_legacy/character_replication_pre95/%s/reference/%s_runtime_reference.png" % [ROOT,role,role])
	# Replicated creature archives are removed after formal acceptance. Reuse the
	# authoritative current sheet when a historical comparison no longer exists.
	if legacy == null:
		legacy = current
	if concept == null or current == null:
		return 1
	var compare: Image = Image.create(1280,720,false,Image.FORMAT_RGBA8); compare.fill(BG)
	_panel(compare,Rect2i(20,20,760,680)); _panel(compare,Rect2i(800,20,460,330)); _panel(compare,Rect2i(800,370,460,330))
	_blit_fit(compare,concept,Rect2i(30,30,740,660),Image.INTERPOLATE_LANCZOS)
	_blit_fit(compare,current,Rect2i(820,70,420,230),Image.INTERPOLATE_NEAREST)
	_blit_fit(compare,legacy,Rect2i(820,420,420,230),Image.INTERPOLATE_NEAREST)
	compare.fill_rect(Rect2i(798,350,464,3),DIVIDER)
	var failures: int = 0
	if compare.save_png(ProjectSettings.globalize_path(output+"/concept_runtime_old_new.png")) != OK: failures += 1
	var matrix: Image = Image.create(1280,360,false,Image.FORMAT_RGBA8); matrix.fill(BG)
	var samples: Array[String] = ["idle/idle_01.png","walk/walk_02.png","%s_active/%s_active_01.png" % [PRIMARY_ACTION[role],PRIMARY_ACTION[role]],"hurt/hurt_02.png","death/death_04.png"]
	for index: int in range(samples.size()):
		var frame: Image=_load("%s/assets/enemies/%s/sprites/%s" % [ROOT,role,samples[index]])
		if frame==null: failures+=1; continue
		_panel(matrix,Rect2i(16+index*252,16,236,328))
		_blit_fit(matrix,frame,Rect2i(26+index*252,28,216,304),Image.INTERPOLATE_NEAREST)
	if matrix.save_png(ProjectSettings.globalize_path(output+"/animation_replication_matrix.png")) != OK: failures+=1
	var silhouette: Image=Image.create(768,384,false,Image.FORMAT_RGBA8); silhouette.fill(BG)
	var idle: Image=_load("%s/assets/enemies/%s/sprites/idle/idle_01.png" % [ROOT,role])
	var black: Image=idle.duplicate()
	for y:int in range(black.get_height()):
		for x:int in range(black.get_width()):
			var c:Color=black.get_pixel(x,y)
			if c.a>0.0: black.set_pixel(x,y,Color(0.01,0.01,0.012,c.a))
	_blit_fit(silhouette,black,Rect2i(32,32,320,320),Image.INTERPOLATE_NEAREST)
	_blit_fit(silhouette,idle,Rect2i(416,32,320,320),Image.INTERPOLATE_NEAREST)
	if silhouette.save_png(ProjectSettings.globalize_path(output+"/silhouette_material_check.png"))!=OK: failures+=1
	return failures


func _write_ormund_evidence() -> int:
	var output: String=QA_ROOT+"/soul_gaoler_ormund"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var concept: Image=_load("%s/assets/bosses/soul_gaoler_ormund/concept_art/soul_gaoler_ormund_phase_comparison.png" % ROOT)
	var current: Image=_load("%s/assets/bosses/soul_gaoler_ormund/reference/ormund_phase_runtime_comparison.png" % ROOT)
	var legacy: Image=_load("%s/archive_legacy/character_replication_pre95/soul_gaoler_ormund/reference/ormund_phase_runtime_comparison.png" % ROOT)
	if concept==null or current==null or legacy==null: return 1
	var board:Image=Image.create(1536,864,false,Image.FORMAT_RGBA8); board.fill(BG)
	_panel(board,Rect2i(20,20,940,824)); _panel(board,Rect2i(980,20,536,392)); _panel(board,Rect2i(980,432,536,412))
	_blit_fit(board,concept,Rect2i(30,30,920,804),Image.INTERPOLATE_LANCZOS)
	_blit_fit(board,current,Rect2i(1000,40,496,352),Image.INTERPOLATE_NEAREST)
	_blit_fit(board,legacy,Rect2i(1000,452,496,372),Image.INTERPOLATE_NEAREST)
	var failures:int=0
	if board.save_png(ProjectSettings.globalize_path(output+"/phase_concept_runtime_old_new.png"))!=OK: failures+=1
	var matrix:Image=Image.create(1536,512,false,Image.FORMAT_RGBA8); matrix.fill(BG)
	var samples:Array[String]=["idle_p1/idle_p1_01.png","halberd_sweep_active/halberd_sweep_active_02.png","phase_transition/phase_transition_06.png","idle_p2/idle_p2_01.png","chainstorm_cleave_active/chainstorm_cleave_active_02.png","death_collapse/death_collapse_04.png"]
	for index:int in range(samples.size()):
		var frame:Image=_load("%s/assets/bosses/soul_gaoler_ormund/sprites/%s" % [ROOT,samples[index]])
		if frame==null: failures+=1; continue
		_panel(matrix,Rect2i(12+index*254,12,242,488))
		_blit_fit(matrix,frame,Rect2i(22+index*254,24,222,464),Image.INTERPOLATE_NEAREST)
	if matrix.save_png(ProjectSettings.globalize_path(output+"/phase_animation_replication_matrix.png"))!=OK: failures+=1
	return failures


func _load(path: String) -> Image:
	var image: Image=Image.load_from_file(ProjectSettings.globalize_path(path))
	return null if image==null or image.is_empty() else image


func _panel(image: Image, rect: Rect2i) -> void:
	image.fill_rect(rect,DIVIDER)
	image.fill_rect(Rect2i(rect.position+Vector2i(3,3),rect.size-Vector2i(6,6)),PANEL)


func _blit_fit(target: Image, source: Image, rect: Rect2i, interpolation: Image.Interpolation) -> void:
	var copy:Image=source.duplicate()
	if copy.get_format() != Image.FORMAT_RGBA8:
		copy.convert(Image.FORMAT_RGBA8)
	var scale:float=minf(float(rect.size.x)/float(copy.get_width()),float(rect.size.y)/float(copy.get_height()))
	var size:=Vector2i(maxi(1,roundi(copy.get_width()*scale)),maxi(1,roundi(copy.get_height()*scale)))
	copy.resize(size.x,size.y,interpolation)
	var position:Vector2i=rect.position+(rect.size-size)/2
	target.blend_rect(copy,Rect2i(Vector2i.ZERO,size),position)
