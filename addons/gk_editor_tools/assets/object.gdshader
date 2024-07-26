shader_type spatial;
render_mode cull_back, specular_disabled, depth_draw_always;
uniform sampler2D Texture:source_color, filter_nearest_mipmap, hint_default_white;
uniform sampler2D Texture_Rolled:source_color, filter_nearest_mipmap, hint_default_black;
uniform bool Rolled = false;

void fragment() {
	vec4 cur_tex = texture(Texture, UV);
	if (Rolled) {cur_tex = texture(Texture_Rolled, UV);}
	ALBEDO = cur_tex.rgb;
	ALPHA = cur_tex.a;
}