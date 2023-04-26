#include <common.fh>

// #define func max
// #define func min
#define func avg

vec3 avg(vec3 v0, vec3 v1)
{
	return (v0 + v1) / 2;
}

void main()
{
	OUT_Color = half4(0);
	
	vec2 uv = IO_uv0;
	float dx = 1.0 / textureSize(S_input_rt, 0).x;
	float dy = 1.0 / textureSize(S_input_rt, 0).y;
	
	vec3 s1 = textureLod(S_input_rt, uv + vec2(-dx, -dy), 0).rgb;
	vec3 s2 = textureLod(S_input_rt, uv + vec2(+dx, -dy), 0).rgb;
	vec3 s3 = textureLod(S_input_rt, uv + vec2(-dx, +dy), 0).rgb;
	vec3 s4 = textureLod(S_input_rt, uv + vec2(+dx, +dy), 0).rgb;
	
	if (U_pass) {//antiflicker
		half s1w = 1 / (Brightness(s1) + 1);
		half s2w = 1 / (Brightness(s2) + 1);
		half s3w = 1 / (Brightness(s3) + 1);
		half s4w = 1 / (Brightness(s4) + 1);
		half one_div_wsum = 1 / (s1w + s2w + s3w + s4w);

		OUT_Color.rgb = (s1 * s1w + s2 * s2w + s3 * s3w + s4 * s4w) * one_div_wsum;
	}
	else {
		OUT_Color.rgb = (s1 + s2 + s3 + s4) / 4.0;
	}
}
  
