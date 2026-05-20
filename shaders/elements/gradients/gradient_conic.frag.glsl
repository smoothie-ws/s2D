#version 450

uniform vec4 color;
uniform vec2 start;
uniform vec2 end;
uniform float dither;
uniform sampler2D gradient;

in vec2 fragPos;
in vec2 fragUV;
out vec4 fragColor;

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;

float rand(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    vec2 dir = end - start;
    float baseAngle = atan(dir.y, dir.x);
    vec2 delta = fragPos - start;
    float angle = atan(delta.y, delta.x);
    float t = fract((angle - baseAngle) / TAU);
    t = clamp(t + rand(fragPos) * dither, 0.0, 1.0);
    fragColor = texture(gradient, vec2(t, 0.5)) * color;
}
