#version 450

uniform vec4 color;
uniform vec2 start;
uniform vec2 end;
uniform float dither;
uniform sampler2D gradient;

layout(location = 0) in vec2 fragPos;
layout(location = 1) in vec2 fragUV;
layout(location = 0) out vec4 fragColor;

float rand(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    float t = distance(start, fragPos) / distance(start, end);
    t = clamp(t + rand(fragPos) * dither, 0.0, 1.0);
    fragColor = texture(gradient, vec2(t, 0.5)) * color;
}
