shader_type canvas_item;

uniform vec4 atlas_rect; // source UV origin and size
uniform vec2 source_pixel_size;
uniform float relief = 1.5;
uniform sampler2D normal_atlas : hint_normal, filter_nearest, repeat_disable;
#include "res://assets/wind.gdshaderinc"

float clean_alpha(vec4 p) {
	// The supplied sheets contain neon matte remnants around some cutouts.
	bool matte = (p.r > 0.85 && p.b > 0.75 && p.g < 0.35)
		|| (p.g > 0.90 && p.r < 0.45 && p.b < 0.55)
		|| (p.b > 0.90 && p.r < 0.35 && p.g < 0.45)
		|| (p.r > 0.95 && p.g < 0.20 && p.b < 0.20)
		|| (p.r > 0.96 && p.g > 0.96 && p.b < 0.35);
	return p.a * (matte ? 0.0 : 1.0);
}

float height_at(sampler2D source, vec2 uv) {
	vec2 lo = atlas_rect.xy + source_pixel_size * 0.5;
	vec2 hi = atlas_rect.xy + atlas_rect.zw - source_pixel_size * 0.5;
	vec4 p = texture(source, clamp(uv, lo, hi));
	return clean_alpha(p) * (0.65 + dot(p.rgb, vec3(0.2126,0.7152,0.0722)) * 0.35);
}

void fragment() {
	vec2 sample_uv = wind_sample_uv(UV);
	vec4 albedo = texture(TEXTURE, sample_uv);
	COLOR = vec4(albedo.rgb, clean_alpha(albedo) * wind_region_mask(sample_uv));
	NORMAL_MAP = texture(normal_atlas, sample_uv).rgb;
	NORMAL_MAP_DEPTH = 1.0;
}
