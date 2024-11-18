// NOTE: Shader automatically converted from Godot Engine 4.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform vec3 uv1_scale = vec3(1);
uniform vec3 uv1_offset;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo_tex.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.5;

	vec4 vertex_world = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	//ALBEDO = CAMERA_POSITION_WORLD.xyz;

	//ALBEDO = vertex_world.xyz;
	//ALBEDO = VERTEX;
	//ALBEDO = fma(NORMAL, vec3(2.0), vec3(-1.0));
	if (distance(NORMAL.rg, vec2(0)) < 0.8) {
		ALPHA = distance(CAMERA_POSITION_WORLD, vertex_world.xyz) - (2.0);
	}
}
