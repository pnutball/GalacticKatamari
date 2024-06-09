shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D BaseTexture: source_color, hint_default_black, filter_nearest_mipmap;
uniform sampler2D OverlayTexture: source_color, hint_default_black, filter_linear_mipmap;
uniform float FaceOverlayAmount: hint_range(0.0, 1.0) = 0.5;
uniform float EmotionAmount: hint_range(-1.0, 1.0) = 0;
uniform vec3 ShockColor = vec3(178, 225, 255);
uniform vec3 AngerColor = vec3(219, 70, 70);

void fragment() {
	float OverlayMask = texture(OverlayTexture, UV).r;
	float ShadowMask = texture(OverlayTexture, UV).g;
	vec3 OverlayColor;
	vec3 EmotionColor;
	if (EmotionAmount > 0.0) {
		OverlayColor = vec3(1);
		EmotionColor = ShockColor / vec3(255.0);
	} else {
		OverlayColor = texture(BaseTexture, UV).rgb * vec3(1, 0.75, 0.75);
		EmotionColor = AngerColor / vec3(255.0);
	}
	ALBEDO = mix(mix(texture(BaseTexture, UV).rgb, OverlayColor, abs(EmotionAmount) * FaceOverlayAmount * OverlayMask),
	EmotionColor, 
	abs(EmotionAmount) * ShadowMask);
}