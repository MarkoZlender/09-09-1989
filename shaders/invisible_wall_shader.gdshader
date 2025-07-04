shader_type spatial;

uniform sampler2D mask : source_color;
uniform vec3 glow_color : source_color; // The color that will glow
uniform vec3 glow_emission : source_color; // Color of the emission
uniform float glow_strength = 1.0; // Emission strength multiplier

// Scroll direction and speed
uniform vec2 scroll_direction = vec2(0.0, 1.0); // Default to upward scroll
uniform float scroll_speed = 1.0; // Speed of scrolling


void fragment() {
    // Calculate the new UVs based on the scroll direction and time
    vec2 scrolled_uv = UV + scroll_direction * scroll_speed * TIME;

    // Get the albedo color from the scrolled texture
    vec4 albedo = texture(mask, scrolled_uv);

    // Compare the color to the glow color (tweak the threshold for precision)
    float tolerance = 0.1;
    float color_match = step(tolerance, 1.0 - distance(albedo.rgb, glow_color));

    // Apply emission to the matched color
    vec3 emission = mix(vec3(0.0), glow_emission * glow_strength, color_match);

    // Output the final color and emission
    ALBEDO = albedo.rgb;
    EMISSION = emission;
}
