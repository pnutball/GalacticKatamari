shader_type spatial;
render_mode unshaded, blend_add;

uniform sampler2D DustParticle: source_color, repeat_disable, filter_linear_mipmap, hint_default_black;
uniform sampler2D AlphaSizeCurve: repeat_disable;
varying float lifetime;

void vertex() {
	lifetime = INSTANCE_CUSTOM.y;
	float size = texture(AlphaSizeCurve, vec2(lifetime, 0)).x;
	UV = (UV-vec2(0.5))*vec2(size)+vec2(0.5);
}

void fragment() {
	vec4 tex = texture(DustParticle, UV);
	ALBEDO = mix(vec3(0), tex.rgb, tex.a * texture(AlphaSizeCurve, vec2(lifetime, 0)).y);
}