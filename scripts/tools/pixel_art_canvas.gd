class_name PixelArtCanvas
extends RefCounted

## Small, deterministic helpers for constructing hard-edged pixel images.


static func create_transparent(size: Vector2i) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	return image


static func fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	var clipped: Rect2i = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if clipped.has_area():
		image.fill_rect(clipped, color)


static func fill_rects(image: Image, rects: Array[Rect2i], color: Color) -> void:
	for rect: Rect2i in rects:
		fill_rect(image, rect, color)


static func draw_line(
		image: Image,
		start: Vector2i,
		end: Vector2i,
		color: Color,
		thickness: int = 1
	) -> void:
	var x0: int = start.x
	var y0: int = start.y
	var x1: int = end.x
	var y1: int = end.y
	var dx: int = absi(x1 - x0)
	var sx: int = 1 if x0 < x1 else -1
	var dy: int = -absi(y1 - y0)
	var sy: int = 1 if y0 < y1 else -1
	var error: int = dx + dy
	var radius: int = maxi(0, thickness - 1)
	while true:
		fill_rect(image, Rect2i(x0 - radius / 2, y0 - radius / 2, thickness, thickness), color)
		if x0 == x1 and y0 == y1:
			break
		var doubled_error: int = error * 2
		if doubled_error >= dy:
			error += dy
			x0 += sx
		if doubled_error <= dx:
			error += dx
			y0 += sy


static func silhouette(source: Image, color: Color) -> Image:
	var result: Image = create_transparent(source.get_size())
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			if source.get_pixel(x, y).a > 0.0:
				result.set_pixel(x, y, color)
	return result


static func resize_nearest(source: Image, size: Vector2i) -> Image:
	var result: Image = source.duplicate()
	result.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	return result


static func blend_scaled(
		destination: Image,
		source: Image,
		position: Vector2i,
		scale: int
	) -> void:
	var scaled: Image = resize_nearest(source, source.get_size() * scale)
	destination.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), position)
