shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D BaseTexture : source_color, repeat_disable;
uniform sampler2D AltTexture : source_color, repeat_disable;
uniform sampler2D EmissionTexture : repeat_disable, hint_default_black;
uniform float MixValue : hint_range(0, 1) = 0;

void fragment() {
	ALBEDO = mix(texture(BaseTexture, UV), texture(AltTexture, UV), MixValue).xyz;
	EMISSION = mix(texture(EmissionTexture, UV).rrr, texture(EmissionTexture, UV).ggg, MixValue).xyz;
}
