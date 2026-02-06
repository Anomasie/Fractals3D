shader_type spatial;

float random (vec2 st) {
	return fract(sin(dot(st.xy,
		vec2(12.9898,78.233)))*
		43758.5453123);
	}

void vertex() {
	NORMAL = normalize(vec3(0.0,1.0,0.0));// + normalize(POSITION.xyz))/(1.0);
}

void fragment() {
	//ALBEDO = (length(VERTEX))/(6.0)*vec3(1.0,0.0,0.0);// = VERTEX.y*256.0;
	//vec3(1.0,1.0,1.0)-(1.0-FRAGCOORD.z)/5.0
}