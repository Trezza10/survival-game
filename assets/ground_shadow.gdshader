shader_type canvas_item;
render_mode unshaded;

void fragment() {
	// Use the existing sprite alpha, including the Sprite2D's selected region.
	float alpha = texture(TEXTURE, UV).a * 0.5;
	alpha += texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a * 0.125;
	alpha += texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a * 0.125;
	alpha += texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a * 0.125;
	alpha += texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a * 0.125;
	COLOR = vec4(0.025, 0.035, 0.055, alpha * COLOR.a);
}
