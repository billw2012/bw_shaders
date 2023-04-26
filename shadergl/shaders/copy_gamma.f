#include <common.fh>

vec3 aces_approx(vec3 v)
{
    v *= 0.6f;
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0f, 1.0f);
}

vec3 uncharted2_tonemap_partial(vec3 x)
{
    float A = 0.15f;
    float B = 0.50f;
    float C = 0.10f;
    float D = 0.20f;
    float E = 0.02f;
    float F = 0.30f;
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 uncharted2_filmic(vec3 v)
{
    float exposure_bias = 2.0f;
    vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

    vec3 W = vec3(11.2f);
    vec3 white_scale = vec3(1.0f) / uncharted2_tonemap_partial(W);
    return curr * white_scale;
}

vec4 msaa()
{
#ifdef MAIN_MSAA
	vec4 col = TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy), 0)));
	for (int i = 1; i < MAIN_MSAA; ++i) {
		col += TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy), i)));
	}
	col /= vec4(MAIN_MSAA);
	col = TO_linearRGB(col);
	return col;
#else
	return vec4(1, 1, 0, 1);
#endif
}

vec4 ssaa(ivec2 off)
{
	#if defined(AAMODE_SSAA_2X)
	return TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy) * ivec2(1, 2) + off, 0)));
	#elif defined(AAMODE_SSAA_4X)
	return TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy) * ivec2(2) + off, 0)));
	#elif defined(AAMODE_SSAA_6X)
	return TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy) * ivec2(2, 3) + off, 0)));
	#elif defined(AAMODE_SSAA_9X)
	return TO_sRGB(saturate(texelFetch(S_input_rt, ivec2(gl_FragCoord.xy) * ivec2(3) + off, 0)));
	#else
	return vec4(1, 1, 0, 1);
	#endif
}

void main()
{
	//TODO @Timon optimize
	vec4 col;
	#if defined(UPMODE_FSR)
	OUT_Color = RTResolve(S_input_rt);
	#elif defined(AAMODE_SSAA_2X)
	col  = ssaa(ivec2(0, 0));
	col += ssaa(ivec2(0, 1));
	col /= vec4(2);
	col = TO_linearRGB(col);
	OUT_Color = col;
	#elif defined(AAMODE_SSAA_4X)
	col  = ssaa(ivec2(0, 0));
	col += ssaa(ivec2(1, 0));
	col += ssaa(ivec2(1, 1));
	col += ssaa(ivec2(0, 1));
	col /= vec4(4);
	col = TO_linearRGB(col);
	OUT_Color = col;
	#elif defined(AAMODE_SSAA_6X)
	col  = ssaa(ivec2(0, 0));
	col += ssaa(ivec2(1, 0));
	col += ssaa(ivec2(1, 1));
	col += ssaa(ivec2(0, 1));
	col += ssaa(ivec2(0, 2));
	col += ssaa(ivec2(1, 2));
	col /= vec4(6);
	col = TO_linearRGB(col);
	OUT_Color = col;
	#elif defined(AAMODE_SSAA_9X)
	col  = ssaa(ivec2(0, 0));
	col += ssaa(ivec2(1, 0));
	col += ssaa(ivec2(2, 0));
	col += ssaa(ivec2(2, 1));
	col += ssaa(ivec2(1, 1));
	col += ssaa(ivec2(0, 1));
	col += ssaa(ivec2(0, 2));
	col += ssaa(ivec2(1, 2));
	col += ssaa(ivec2(2, 2));
	col /= vec4(9);
	col = TO_linearRGB(col);
	OUT_Color = col;
	#elif defined(MAIN_MSAA)
	OUT_Color = msaa();
	#else
	OUT_Color = RTResolve(S_input_rt);
	#endif
	if (U_gamma != 1.0) {
		OUT_Color = pow(OUT_Color, vec4(U_gamma));
	}

	// ACES tonemap
	//OUT_Color.rgb = aces_approx(OUT_Color.rgb);

	// Uncharted tonemap
	OUT_Color.rgb = uncharted2_filmic(OUT_Color.rgb);

	// contrast
	// OUT_Color = clamp((OUT_Color - 0.5f) * 1.04f + 0.5f, 0.0f, 1.0f);

	// brightness
	OUT_Color.rgb = OUT_Color.rgb * 2.0f;
}
