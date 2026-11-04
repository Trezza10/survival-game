shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 p = texture(TEXTURE, UV);
	// Keep the flame luminous at night; the logs underneath receive normal lighting.
	float flame = (p.r > 0.70 && p.g > 0.21 && p.b < 0.52 && p.r > p.g * 1.10) ? 1.0 : 0.0;
	bool matte = p.r > 0.95 && p.g < 0.20 && p.b < 0.20;
	COLOR = vec4(p.rgb, p.a * flame * (matte ? 0.0 : 1.0));
}
