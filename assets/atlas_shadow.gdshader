shader_type canvas_item;
render_mode unshaded;
uniform vec4 atlas_rect;
uniform vec2 source_pixel_size;
#include "res://assets/wind.gdshaderinc"

void fragment() {
	vec2 sample_uv = wind_sample_uv(UV);
	vec4 p = texture(TEXTURE, sample_uv);
	bool matte = (p.r > 0.85 && p.b > 0.75 && p.g < 0.35)
		|| (p.g > 0.90 && p.r < 0.45 && p.b < 0.55)
		|| (p.b > 0.90 && p.r < 0.35 && p.g < 0.45)
		|| (p.r > 0.95 && p.g < 0.20 && p.b < 0.20)
		|| (p.r > 0.96 && p.g > 0.96 && p.b < 0.35);
	float alpha = p.a * (matte ? 0.0 : 1.0) * wind_region_mask(sample_uv);
	COLOR = vec4(0.025,0.035,0.055,alpha * COLOR.a);
}
