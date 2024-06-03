shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D BaseTexture: source_color, hint_default_black;
uniform sampler2D EyeOverlay: source_color, hint_default_transparent;
uniform float EyeWhiteness: hint_range(0.0, 1.0);

void fragment() {
	vec4 EyeVec = texture(EyeOverlay, UV);
	ALBEDO = mix(texture(BaseTexture, UV).rgb, EyeVec.rgb, EyeWhiteness * EyeVec.a);
}