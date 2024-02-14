shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_linear;
uniform float water_depth = 2;
uniform vec3 water_color = vec3(0, 92, 136);
uniform vec3 shore_color = vec3(44, 163, 211);
uniform int steps: hint_range(2, 4, 1) = 3;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	
	depth = VERTEX.z + depth;
	
	vec3 water_color_conv = water_color / vec3(255.0) * 0.8;
	vec3 shore_color_conv = shore_color / vec3(255.0) * 0.8;
	ALBEDO = mix( shore_color_conv, water_color_conv, floor(clamp(depth*water_depth*float(steps)*3.0, 0.0, float(steps - 1)))/float(steps - 1) );
}

