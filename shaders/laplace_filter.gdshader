shader_type canvas_item;

uniform sampler2D iChannel0;
uniform float threshold : hint_range(0.0, 10., 0.1) = 1.0;
uniform bool invert_color = false;
uniform bool remove_b_color = false;

const int conv_length = 9,
           conv_width = 3;

// Laplace filter kernel
const float conv[conv_length] = float[conv_length](
    -1.,-1.,-1.,
    -1., 8.,-1.,
    -1.,-1.,-1.
);

void fragment()
{
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = UV,
          ps = 1. / iResolution.xy; // pixel size

    vec4 acc = vec4(0);
    for (int i = 0; i < conv_length; i++){
        vec2 d = vec2(float(i % conv_width - conv_width / 2), float(i / conv_width - conv_width / 2));
    	acc += conv[i] * texture(iChannel0, uv + d * ps * threshold);
    }
    
	COLOR.rgb = acc.rgb;
	if (invert_color == true){
		COLOR.rgb = 1.0 - acc.rgb;
	}
	if (remove_b_color == true){
		COLOR.a = acc.r;
	}
}