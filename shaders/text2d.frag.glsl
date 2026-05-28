#version 450

uniform vec4 color;
uniform vec4 outlineColor;
uniform float sdfRange;
uniform float outlineWidth;
uniform float softness;
uniform float weight;
uniform vec2 sourceInvSize;
uniform sampler2D source;

in vec2 fragUV;
out vec4 fragColor;

const float alphaFringeClip = 0.03;

float sampleDistance(vec2 uv) {
    return texture(source, uv).r;
}

float screenPxRange() {
    vec2 screenTexSize = 1.0 / max(fwidth(fragUV), vec2(1e-6));
    float range = 0.5 * sdfRange * dot(sourceInvSize, screenTexSize);
    return max(range, 1.0);
}

float hardenAlpha(float alpha) {
    float value = clamp(alpha, 0.0, 1.0);
    value = value * value * (3.0 - 2.0 * value);
    return clamp((value - alphaFringeClip) / (1.0 - alphaFringeClip), 0.0, 1.0);
}

void main() {
    float distance = sampleDistance(fragUV);
    float sdfUnit = 1.0 / (2.0 * max(sdfRange, 1.0));
    float edgeRange = max(screenPxRange() * 1.50 / (1.0 + max(softness, 0.0)), 1e-4);
    float fillThreshold = 0.5 - weight * sdfUnit;
    float outlineThreshold = fillThreshold - outlineWidth * sdfUnit;
    float fillAlpha = hardenAlpha(clamp((distance - fillThreshold) * edgeRange + 0.5, 0.0, 1.0));
    float outlineCoverage = hardenAlpha(clamp((distance - outlineThreshold) * edgeRange + 0.5, 0.0, 1.0));
    float outlineAlpha = max(outlineCoverage - fillAlpha, 0.0);

    float alpha = fillAlpha * color.a + outlineAlpha * outlineColor.a;
    vec3 rgb = (color.rgb * fillAlpha * color.a + outlineColor.rgb * outlineAlpha * outlineColor.a) / max(alpha, 1e-6);
    fragColor = vec4(rgb, alpha);
}
