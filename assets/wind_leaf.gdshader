shader_type canvas_item;

void fragment() {
	// A tiny stepped leaf shape, kept crisp like the supplied pixel sprites.
	vec2 pixel = floor(UV * vec2(8.0,5.0));
	float half_width = 4.0 - abs(pixel.y - 2.0);
	float shape = step(abs(pixel.x - 3.5), half_width);
	COLOR.a *= shape;
}
