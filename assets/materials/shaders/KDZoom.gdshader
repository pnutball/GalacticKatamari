shader_type canvas_item;

// Old zoom shader: Controls how much the effect zooms.
uniform float zoom_amount: hint_range(0.0, 0.065) = 0;

// Controls the fade color - -1 is a fade to black, 1 is a fade to white.
uniform float fade: hint_range(-1.0, 1.0) = 0;

uniform float FX_opacity: hint_range(0.0, 1) = 0;
uniform float FX_zoom: hint_range(1, 2) = 1;
uniform sampler2D FX_overlay: filter_linear;

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
	return c;
}

vec2 uv_zoom(vec2 uv, float zoom) {
	return ((uv - vec2(0.5)) / zoom) + vec2(0.5);
}

void fragment() {
	//vec3 screenColor = radial_blur(TEXTURE, UV, vec2(0.5), zoom_amount, 16);
	vec3 screenColor = mix(texture(TEXTURE, UV).xyz, texture(FX_overlay, uv_zoom(UV, FX_zoom)).xyz, FX_opacity);
	COLOR = vec4(clamp(mix(mix(screenColor, vec3(1), clamp(fade, 0, 1)), vec3(0), clamp(fade * -1.0, 0, 1)), 0, 1), 1);
	

}