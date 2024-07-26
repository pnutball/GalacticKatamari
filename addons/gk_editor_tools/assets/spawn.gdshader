shader_type spatial;
uniform bool selected = false;

void vertex() {
	if (selected) {
		if (COLOR.g < COLOR.b) {
			COLOR = vec4(0.5647115057049292, 0.03954623527673283, 0.26635560480286247, 1);
		} else if (COLOR.r > COLOR.g) {
			COLOR = vec4(0.9559733532492861, 0.8796223968878317, 0.01599629336550963, 1);
		} else if (COLOR.g > 0.6) {
			COLOR = vec4(0.7605245046752924, 0.33716361504833037, 0.006512090792594474, 1);
		} else if (COLOR.g < 0.3) {
			COLOR = vec4(0.8962693533742664, 0.846873231509858, 0.19806931955994886, 1);
		}
	}
	
}

void fragment() {
	ALBEDO = COLOR.xyz;
}