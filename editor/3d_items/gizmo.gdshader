shader_type spatial;
render_mode unshaded, cull_back;
uniform vec3 color: source_color;
uniform bool selected = false;

void fragment() {
	ALBEDO = mix(color, vec3(1), 0.25 * float(selected));
}