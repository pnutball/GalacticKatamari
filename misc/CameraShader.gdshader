shader_type spatial;
render_mode unshaded, cull_front, depth_prepass_alpha, depth_draw_opaque;

uniform float zoom_amount: hint_range(0.0, 0.065) = 0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

/*
	放射状ブラーエフェクト by あるる（きのもと　結衣） @arlez80
	Radial Blur Effect by Yui Kinomoto

	MIT License
	
	Converted to Godot 4 function by crealol2
*/
vec3 radial_blur(sampler2D tex, vec2 uv, vec2 blur_center, float blur_power, int sampling_count) {
	vec2 direction = uv - blur_center;
	vec3 c = vec3( 0.0, 0.0, 0.0 );
	float f = 1.0 / float( sampling_count );
	for( int i=0; i < sampling_count; i++ ) {
		c += texture( tex, uv - blur_power * direction * float(i) ).rgb * f;
	}
	return c * vec3(2);
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0) * vec4(-1.0, -1.0, 1.0, 1.0);
}

void fragment() {
	ALBEDO = radial_blur(screen_texture, SCREEN_UV, vec2(0.5), zoom_amount, 16);
}