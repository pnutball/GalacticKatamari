shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D MoyaPattern: source_color, hint_default_black, repeat_disable;
uniform float rotation: hint_range(0.0, 6.29);
uniform float scale = 1.4;
uniform vec2 offset = vec2(0);

void fragment() {
	vec2 conv_offset = (offset * vec2(0.00324133333,-0.00324285714));
	vec2 shiftUV = (VIEW.xy * scale) + conv_offset;
	vec2 rotUV = vec2(shiftUV.x * cos(rotation) - shiftUV.y * sin(rotation),
	shiftUV.x * sin(rotation) + shiftUV.y * cos(rotation)) + 0.5;
	
	ALBEDO = texture(MoyaPattern, rotUV).rgb;
}