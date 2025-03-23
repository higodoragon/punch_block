shader_type spatial;
render_mode shadows_disabled, unshaded;

// uniform float expand : hint_range(0.0, 1.0, 0.1) = 0.1;
// uniform float transparency : hint_range(0.0, 1.0, 0.1) = 0.6;
// uniform float roughness : hint_range(0.0, 1.0, 0.1) = 0.5;
// uniform bool use_normal = false;
// uniform sampler2D tex : source_color; 
// uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
// uniform sampler2D tex_frg_2;
// uniform float mix_amount : hint_range(0.0, 1.0, 0.01) = 0.0;

// void vertex() {
// 	VERTEX += (use_normal ? NORMAL : VERTEX) * expand;
// }

// void fragment() {
// 	//ALBEDO = texture(tex, UV).rgb;
// 	ALPHA = transparency;
// 	ROUGHNESS = roughness;

// 	// mix
// 	float outp = mix(color.x, tex_frg_2.x, mix_amount)
// 	// ALBEDO = color.rgb;
// 	ALBEDO = vec3(outp)
// }

uniform float mix_amount : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform sampler2D tex;
uniform vec4 col = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 texted = texture(tex, UV);
	vec3 mixed = mix(vec3(texted.xyz), vec3(col.xyz), mix_amount);
	ALBEDO = vec3(mixed);
}
