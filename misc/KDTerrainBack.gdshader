// NOTE: Shader automatically converted from Godot Engine 4.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_front,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D cutout_texture : filter_linear, hint_default_white, repeat_disable;
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
	vec2 screen_aspect = vec2(VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, VIEWPORT_SIZE.y / VIEWPORT_SIZE.x);
	vec2 cutout_uv = vec2(((SCREEN_UV.x - 0.5) * screen_aspect.x) + 0.5, SCREEN_UV.y);
	//ALPHA = texture(cutout_texture, cutout_uv).r;
	
}
