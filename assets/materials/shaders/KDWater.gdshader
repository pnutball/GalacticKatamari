shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_linear;
uniform float water_depth = 2;
uniform vec3 water_color:source_color = vec3(0, 92, 136);
uniform vec3 shore_color:source_color  = vec3(44, 163, 211);
uniform int steps: hint_range(2, 4, 1) = 3;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float blend = floor(clamp((vertex_y - depth_texture_y) * float(steps) / water_depth, 0.0, float(steps-1)))/float(steps-1);
	ALBEDO = mix( shore_color, water_color, blend );
}