// Matcap shader by nessinby, slightly modified by me (crealol2)
// Special thanks to Ben Cloward for the amazing Material tutorial which improved this shader 20x!!
// Video here: https://www.youtube.com/watch?v=osgMB0mf23w
// Thanks to FireRabbit for the base which I pulled apart!

shader_type spatial;
render_mode specular_disabled;
uniform sampler2D matcap : source_color, hint_default_black, repeat_disable; // Sampler 2d of the matcap
uniform sampler2D flatcap : source_color, hint_default_black, repeat_disable;
uniform float scale: hint_range(0.0, 1.0, 0.01) = 1;

// Bread and buter: Generates the MatCap's UV's
vec2 generate_matcap_uv(vec3 _normal, vec3 _node_position_view, float _scale) {
	vec3 cross_space = cross(normalize(_node_position_view), _normal); // cross products the normal with it's base position
	vec2 mat_space = vec2(cross_space.y * 1.0, cross_space.x); // converts to a Vec2 UV, having to switch x and y
	mat_space *= vec2(-0.5, -0.5); // modifies the mat space's size to fit into uv coords, & flips it
	// it's morphin time
	mat_space *= 1.0 / _scale;
	mat_space += vec2(0.5);
	return mat_space; // export the final uv's
}

void fragment(){
	vec2 matcap_uv = (generate_matcap_uv(NORMAL, NODE_POSITION_VIEW, scale)); // Matcap UV's
	vec3 _matcap = texture(matcap, matcap_uv).rgb; // Matcap Texture
	vec3 _flatcap = texture (flatcap, matcap_uv).rgb;
	ALBEDO = mix(((_flatcap + 0.2) * 1.25) - 0.35, _matcap, scale); // Sets the albedo to the matcap texture. 
}