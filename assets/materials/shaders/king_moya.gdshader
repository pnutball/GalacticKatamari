shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D MoyaPattern: source_color, hint_default_black, repeat_disable;
uniform float rotation: hint_range(0.0, 6.29);

void fragment() {
	vec2 shiftUV = (VIEW.xy * 1.4);
	vec2 rotUV = vec2(shiftUV.x * cos(rotation) - shiftUV.y * sin(rotation),
	shiftUV.x * sin(rotation) + shiftUV.y * cos(rotation)) + 0.5;
	
	ALBEDO = texture(MoyaPattern, rotUV).rgb;
}