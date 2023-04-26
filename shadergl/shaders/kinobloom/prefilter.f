#include <common.fh>

half3 Median(half3 a, half3 b, half3 c) // 3-tap median filter
{
    return a + b + c - min(min(a, b), c) - max(max(a, b), c);
}

void main()
{
	OUT_Color = half4(0);
	
	vec2 TexelSize = 1.0f / textureSize(S_input_rt, 0).xy;
	
	float2 uv = IO_uv0 + TexelSize * U_bias;
	
	half3 pix;
	pix = texture(S_input_rt, uv).rgb;

	if (U_pass) {//antiflicker
		
		half3 pix_xm,pix_xp,pix_ym,pix_yp;
		pix_xm = texture(S_input_rt, uv - vec2(TexelSize.x, 0)).rgb;
		pix_xp = texture(S_input_rt, uv + vec2(TexelSize.x, 0)).rgb;
		pix_ym = texture(S_input_rt, uv - vec2(0, TexelSize.y)).rgb;
		pix_yp = texture(S_input_rt, uv + vec2(0, TexelSize.y)).rgb;

		pix = Median(pix, pix_xm, pix_xp);
		pix = Median(pix, pix_ym, pix_yp);
	
		// @Timon @Markus optional input limiting? maybe to reduce flicker due to extreme sun and/or local-light reflections? 
		float scalefac = 0.6;
		if (Brightness(pix_xm) < U_threshold ) 
		{
			pix *= scalefac;
		}
		if (Brightness(pix_xp) < U_threshold ) 
		{
			pix *= scalefac;
		}
		if (Brightness(pix_ym) < U_threshold ) 
		{
			pix *= scalefac;
		}
		if (Brightness(pix_yp) < U_threshold ) 
		{
			pix *= scalefac;
		}
	}
	if (any(isnan(pix)) || any(isinf(pix))) {
		OUT_Color.rgb = vec3(0);//TODO @Timon @Markus happens a lot likely bad drawcalls
	}
	else {
#ifdef KINO_USE_PATTERN
		pix *= RTResolve(S_pattern_map, uv).r;
#else
		half br = Brightness(pix) * 5f;
		//if (br > 10.0) {br = 10.0;}
		// Under-threshold part: quadratic curve
		half rq = clamp(br - U_color.x, 0, U_color.y); //clamp(br - U_color.x, 0, U_color.y);
		rq = U_color.z * rq * rq;
		// Combine and apply the brightness response curve.
		pix *= max(rq, br - U_threshold) / max(br, 1e-5);
#endif

		OUT_Color.rgb = pix;
	}
}
