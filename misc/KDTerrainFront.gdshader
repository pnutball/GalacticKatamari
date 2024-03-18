// NOTE: Shader automatically converted from Godot Engine 4.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform vec3 uv1_scale = vec3(1);
uniform vec3 uv1_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo_tex.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.5;
}
