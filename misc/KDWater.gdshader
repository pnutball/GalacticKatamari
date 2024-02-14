shader_type spatial;

uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_linear;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	//depth = VERTEX.z + depth;
	ALBEDO = vec3(depth * 0.5);
}

