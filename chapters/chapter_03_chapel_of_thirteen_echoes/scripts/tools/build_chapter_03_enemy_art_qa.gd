extends SceneTree

## Builds deterministic nearest-neighbour evidence boards from repository images.

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const OUTPUT: String = "res://docs/qa/chapter_03_enemy_art_rework"
const BACKGROUND: Color = Color("0b0d15")
const PANEL_OLD: Color = Color("241a21")
const PANEL_NEW: Color = Color("14252a")
const DIVIDER: Color = Color("75604a")

const ROLES: Array[String] = [
	"bellchain_penitent", "censer_executioner", "silent_chorister",
	"stained_glass_seraph", "confessional_wraith", "thirteenth_scribe",
]
const ACTIONS: Dictionary = {
	"bellchain_penitent": "chain_lash_active",
	"censer_executioner": "overhead_crush_active",
	"silent_chorister": "crescent_hymn_active",
	"stained_glass_seraph": "dive_active",
	"confessional_wraith": "emerging_slash_active",
	"thirteenth_scribe": "thirteenth_seal_active",
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var overview: Image = _board(1536,512,BACKGROUND)
	var legacy_overview: Image = _board(1536,512,BACKGROUND)
	for index: int in range(ROLES.size()):
		var role: String = ROLES[index]
		if not _write_role_board(role,index+1):
			quit(1)
			return
		var idle: Image = _load_image("%s/%s/sprites/idle/idle_01.png" % [ROOT,role])
		var action: String = ACTIONS[role]
		var attack: Image = _load_image("%s/%s/sprites/%s/%s_01.png" % [ROOT,role,action,action])
		var old_idle: Image = _load_image("%s/%s/reference/deprecated_phase_2/sprites/idle/idle_01.png" % [ROOT,role])
		var old_attack: Image = _load_image("%s/%s/reference/deprecated_phase_2/sprites/%s/%s_01.png" % [ROOT,role,action,action])
		_blit_scaled(overview,idle,Vector2i(index*256,0),4)
		_blit_scaled(overview,attack,Vector2i(index*256,256),4)
		_blit_scaled(legacy_overview,old_idle,Vector2i(index*256,0),4)
		_blit_scaled(legacy_overview,idle,Vector2i(index*256,256),4)
	if overview.save_png(ProjectSettings.globalize_path("%s/13_all_enemy_new_sprite_overview.png" % OUTPUT)) != OK:
		push_error("Could not save new sprite overview")
		quit(1)
		return
	if legacy_overview.save_png(ProjectSettings.globalize_path("%s/14_old_vs_new_overview.png" % OUTPUT)) != OK:
		push_error("Could not save legacy comparison overview")
		quit(1)
		return
	print("CH3 ENEMY ART QA BOARDS | PASS roles=6 boards=14")
	quit(0)


func _write_role_board(role: String, number: int) -> bool:
	var concept: Image = _load_image("%s/%s/concept_art/%s_concept.png" % [ROOT,role,role])
	var silhouette: Image = _load_image("%s/%s/concept_art/%s_silhouette.png" % [ROOT,role,role])
	var old_idle: Image = _load_image("%s/%s/reference/deprecated_phase_2/sprites/idle/idle_01.png" % [ROOT,role])
	var action: String = ACTIONS[role]
	var old_attack: Image = _load_image("%s/%s/reference/deprecated_phase_2/sprites/%s/%s_01.png" % [ROOT,role,action,action])
	var idle: Image = _load_image("%s/%s/sprites/idle/idle_01.png" % [ROOT,role])
	var attack: Image = _load_image("%s/%s/sprites/%s/%s_01.png" % [ROOT,role,action,action])
	if [concept,silhouette,old_idle,old_attack,idle,attack].has(null):
		push_error("Missing QA source for %s" % role)
		return false
	var board: Image = _board(1536,512,BACKGROUND)
	_fill(board,Rect2i(448,0,512,512),PANEL_OLD)
	_fill(board,Rect2i(960,0,576,512),PANEL_NEW)
	_fill(board,Rect2i(446,0,2,512),DIVIDER)
	_fill(board,Rect2i(958,0,2,512),DIVIDER)
	_blit_scaled(board,concept,Vector2i(0,128),1)
	var silhouette_scaled: Image = silhouette.duplicate()
	silhouette_scaled.resize(192,192,Image.INTERPOLATE_NEAREST)
	board.blit_rect(silhouette_scaled,Rect2i(0,0,192,192),Vector2i(256,160))
	_blit_scaled(board,old_idle,Vector2i(448,128),4)
	_blit_scaled(board,old_attack,Vector2i(704,128),4)
	_blit_scaled(board,idle,Vector2i(960,128),4)
	_blit_scaled(board,attack,Vector2i(1216,128),4)
	var path: String = "%s/%02d_%s_concept_old_new.png" % [OUTPUT,number,role]
	if board.save_png(ProjectSettings.globalize_path(path)) != OK:
		push_error("Could not save %s" % path)
		return false
	var preview: Image = _board(1024,512,BACKGROUND)
	var action_reference: Image = _load_image("%s/%s/concept_art/%s_action_reference.png" % [ROOT,role,role])
	_blit_scaled(preview,action_reference,Vector2i(128,96),4)
	var small: Image = idle.duplicate(); small.resize(48,48,Image.INTERPOLATE_NEAREST)
	preview.blit_rect(small,Rect2i(0,0,48,48),Vector2i(488,400))
	path = "%s/%02d_%s_sprite_preview.png" % [OUTPUT,number+6,role]
	if preview.save_png(ProjectSettings.globalize_path(path)) != OK:
		push_error("Could not save %s" % path)
		return false
	return true


func _load_image(path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	return image


func _board(width: int,height: int,color: Color) -> Image:
	var image: Image = Image.create(width,height,false,Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _blit_scaled(target: Image,source: Image,position: Vector2i,scale_factor: int) -> void:
	var scaled: Image = source.duplicate()
	scaled.resize(source.get_width()*scale_factor,source.get_height()*scale_factor,Image.INTERPOLATE_NEAREST)
	target.blit_rect(scaled,Rect2i(0,0,scaled.get_width(),scaled.get_height()),position)


func _fill(image: Image,rect: Rect2i,color: Color) -> void:
	image.fill_rect(rect,color)
