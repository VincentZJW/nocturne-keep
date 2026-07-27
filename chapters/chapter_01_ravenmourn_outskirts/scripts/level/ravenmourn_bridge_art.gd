class_name RavenmournBridgeArt
extends Node2D

## Detailed timber/iron bridge presentation. BridgeCollision remains authoritative.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var timber_dark: Color = Color(0.105, 0.065, 0.045, 1.0)
	var timber: Color = Color(0.245, 0.145, 0.082, 1.0)
	var timber_light: Color = Color(0.43, 0.27, 0.145, 1.0)
	var iron: Color = Color(0.15, 0.16, 0.19, 1.0)
	draw_rect(Rect2(-400.0, -10.0, 800.0, 26.0), timber_dark)
	for plank_index: int in range(20):
		var x_position: float = -398.0 + float(plank_index) * 40.0
		var plank_color: Color = timber if plank_index % 3 != 1 else Color(0.205, 0.115, 0.065, 1.0)
		draw_rect(Rect2(x_position, -9.0, 37.0, 18.0), plank_color)
		draw_line(Vector2(x_position + 3.0, -7.0), Vector2(x_position + 33.0, -7.0), timber_light, 2.0)
		draw_rect(Rect2(x_position + 7.0, -2.0, 3.0, 3.0), iron)
		draw_rect(Rect2(x_position + 28.0, 3.0, 3.0, 3.0), iron)
		if plank_index in [3, 9, 14, 18]:
			draw_line(Vector2(x_position + 18.0, -7.0), Vector2(x_position + 24.0, 7.0), timber_dark, 2.0)
	draw_rect(Rect2(-400.0, 10.0, 800.0, 8.0), iron)
	for support_x: float in [-360.0, -180.0, 0.0, 180.0, 360.0]:
		draw_rect(Rect2(support_x - 5.0, 14.0, 10.0, 32.0), timber_dark)
	for post_x: float in [-384.0, -208.0, -32.0, 144.0, 320.0, 384.0]:
		draw_rect(Rect2(post_x - 5.0, -48.0, 10.0, 46.0), iron)
		var cap: PackedVector2Array = PackedVector2Array([
			Vector2(post_x - 8.0, -48.0), Vector2(post_x, -60.0), Vector2(post_x + 8.0, -48.0),
		])
		draw_colored_polygon(cap, iron)
	var posts: Array[float] = [-384.0, -208.0, -32.0, 144.0, 320.0, 384.0]
	for segment_index: int in range(posts.size() - 1):
		_draw_chain(Vector2(posts[segment_index], -38.0), Vector2(posts[segment_index + 1], -38.0))


func _draw_chain(start: Vector2, end: Vector2) -> void:
	var span: float = end.x - start.x
	var links: int = maxi(1, int(absf(span) / 16.0))
	for link_index: int in range(links + 1):
		var ratio: float = float(link_index) / float(links)
		var sag: float = sin(ratio * PI) * 11.0
		var position: Vector2 = start.lerp(end, ratio) + Vector2(0.0, sag)
		draw_rect(Rect2(position - Vector2(3.0, 2.0), Vector2(6.0, 4.0)), Color(0.2, 0.21, 0.24, 1.0), false, 2.0)
