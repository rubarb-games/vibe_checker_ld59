shader_type canvas_item;

uniform sampler2D main_tex:source_color;
uniform float green_treshold = 0.95;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(main_tex,UV);
	
	if (col.g > green_treshold && col.r < 0.25 && col.b < 0.25) {
		discard;
	}
	COLOR = col;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
