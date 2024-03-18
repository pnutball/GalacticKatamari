shader_type canvas_item;

void fragment() {
	vec2 VIEWPORT_SIZE = vec2(1) / SCREEN_PIXEL_SIZE;
	vec2 screen_aspect = vec2(VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, VIEWPORT_SIZE.y / VIEWPORT_SIZE.x);
	vec2 cutout_uv = vec2(((SCREEN_UV.x - 0.5) * screen_aspect.x) + 0.5, SCREEN_UV.y);
	//COLOR = texture(TEXTURE, cutout_uv);
}
