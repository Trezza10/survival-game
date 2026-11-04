shader_type canvas_item;
render_mode unshaded, blend_add;

void fragment() {
	vec4 p = texture(TEXTURE, UV);
	bool matte = (p.r > 0.85 && p.b > 0.75 && p.g < 0.35)
		|| (p.g > 0.90 && p.r < 0.45 && p.b < 0.55)
		|| (p.b > 0.90 && p.r < 0.35 && p.g < 0.45)
		|| (p.r > 0.95 && p.g < 0.20 && p.b < 0.20)
		|| (p.r > 0.96 && p.g > 0.96 && p.b < 0.35);
	COLOR = vec4(p.rgb, p.a * (matte ? 0.0 : 0.28));
}
