// Shared by color/normal shading and projected shadows.
// wind_time comes from a pausable scene node rather than shader TIME.
uniform float wind_time = 0.0;
uniform float wind_amplitude = 0.0;
uniform float wind_anchor = 0.1;
varying float wind_phase;

void vertex() {
	wind_phase = MODEL_MATRIX[3].x * 0.012 + MODEL_MATRIX[3].y * 0.007;
	if (wind_amplitude > 0.0) {
		// Give the moving outline space without changing the texture or collision.
		VERTEX.x *= 1.12;
		float center = atlas_rect.x + atlas_rect.z * 0.5;
		UV.x = center + (UV.x - center) * 1.12;
	}
}

vec2 wind_sample_uv(vec2 uv) {
	if (wind_amplitude <= 0.0) { return uv; }
	vec2 local_uv = (uv - atlas_rect.xy) / atlas_rect.zw;
	float height = clamp(1.0 - local_uv.y, 0.0, 1.0);
	float bend = smoothstep(wind_anchor, 1.0, height);
	float gust = 0.75 + 0.25 * sin(wind_time * 0.37 + wind_phase * 0.5);
	float wave = sin(wind_time * 1.7 + wind_phase)
		+ 0.30 * sin(wind_time * 3.1 + wind_phase * 1.37 + height * 3.0);
	return uv - vec2(wave * gust * bend * wind_amplitude * source_pixel_size.x, 0.0);
}

float wind_region_mask(vec2 uv) {
	if (wind_amplitude <= 0.0) { return 1.0; }
	vec2 p = (uv - atlas_rect.xy) / atlas_rect.zw;
	return step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
}
