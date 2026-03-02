shader_type spatial;

uniform float fresnel_power = 3.0;
uniform float interference_frequency = 3.0;
uniform vec3 albedo_color : source_color = vec3(1.0, 0.8, 0.6);
uniform vec3 shift : source_color = vec3(0.2, 0.7, 1.0);

uniform float roughness = 0.3;
uniform float metallic = 0.7;
uniform vec3 light_direction = vec3(0.0, -1.0, 0.0);

float fresnel(vec3 view, vec3 normal) {
	return pow(1.0 - dot(view, normal), fresnel_power);
}

vec3 irridescence(vec3 view, vec3 normal, vec3 light) {
	float dot_view = dot(view, normal);
	float dot_light = dot(light, normal);

	float angle = abs(dot_view - dot_light);
	float interference = sin(angle * interference_frequency) * 0.5 + 0.5;

	return mix(albedo_color, shift, interference);
}

void fragment() {
	ALBEDO = mix(
		irridescence(VIEW, NORMAL, light_direction),
		vec3(1.0),
		fresnel(VIEW, NORMAL));
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
