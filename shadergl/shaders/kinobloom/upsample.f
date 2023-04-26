#include <common.fh>

// #define func max
// #define func min
// #define func avg

float avg(float v0, float v1)
{
	return (v0 + v1) / 2;
}

void main()
{
	OUT_Color = half4(0);
	
	vec2 uv = IO_uv0;
	float scale = U_scale;
#ifdef HIGH_QUALITY
	// 9-tap bilinear upsampler (tent filter)
	
	float dx = scale / textureSize(S_input_rt, 0).x;
	float dy = scale / textureSize(S_input_rt, 0).y;
	
	vec4 s;
	s  = textureLod(S_input_rt, uv + vec2(-dx, -dy),	0);
	s += textureLod(S_input_rt, uv + vec2(0, -dy),		0) * 2;
	s += textureLod(S_input_rt, uv + vec2(dx, -dy),		0);
	
	s += textureLod(S_input_rt, uv + vec2(-dx, 0),		0) * 2;
	s += textureLod(S_input_rt, uv + vec2(0, 0),		0) * 4;
	s += textureLod(S_input_rt, uv + vec2(dx, 0),		0) * 2;
	
	s += textureLod(S_input_rt, uv + vec2(-dx, dy),		0);
	s += textureLod(S_input_rt, uv + vec2(0, dy),		0) * 2;
	s += textureLod(S_input_rt, uv + vec2(dx, dy),		0);
	
	OUT_Color = U_useralphascale * s / 16.0;
#elif 1
	/*LOW_QUALITY*/
	
	float dx = 0.5 * scale / V_viewportpixelsize.x;
	float dy = 0.5 * scale / V_viewportpixelsize.y;
	
	vec4 s;
	s  = textureLod(S_input_rt, uv + vec2(-dx, -dy), 0);
	s += textureLod(S_input_rt, uv + vec2(+dx, -dy), 0);
	s += textureLod(S_input_rt, uv + vec2(-dx, +dy), 0);
	s += textureLod(S_input_rt, uv + vec2(+dx, +dy), 0);
	
	OUT_Color = U_useralphascale * s / 4.0;
#endif
}
