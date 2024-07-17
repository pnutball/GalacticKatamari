shader_type spatial;
render_mode vertex_lighting, cull_disabled, ambient_light_disabled, specular_disabled, shadows_disabled;

uniform sampler2D light_texture: source_color, filter_linear_mipmap_anisotropic, hint_default_white, repeat_disable;
uniform sampler2D dark_texture: source_color, filter_linear_mipmap_anisotropic, hint_default_black, repeat_disable;
uniform sampler2D shadow_ramp;

void vertex() {
	COLOR = vec4(1);
}

void fragment() {
	ALBEDO = texture(light_texture, UV).rgb;
}

void light() {
	float lambert = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * 1.0;
	DIFFUSE_LIGHT = mix(texture(dark_texture, UV).rgb, vec3(1), texture(shadow_ramp, vec2(clamp(lambert, 0.002, 1.0), 0)).x);
}