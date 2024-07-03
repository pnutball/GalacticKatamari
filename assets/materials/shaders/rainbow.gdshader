shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, fog_disabled, depth_prepass_alpha, depth_draw_always;
uniform sampler2D tex: source_color,hint_default_transparent,filter_linear_mipmap_anisotropic,repeat_enable;
uniform float shift: hint_range(0, 1, 0.01);

void fragment() {
	vec4 _tex = texture(tex, clamp(UV, vec2(0, 0.0009765625), vec2(1, 0.9990234375)) + vec2(shift));
	ALBEDO = _tex.rgb;
	//ALPHA = _tex.a;
}