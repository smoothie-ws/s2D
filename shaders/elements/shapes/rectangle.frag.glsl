#version 450

uniform vec4 rect;
uniform vec4 color;
uniform float radius;
uniform float softness;
uniform vec4 borderColor;
uniform float borderWidth;
uniform float borderSoftness;

in vec2 fragPos;
out vec4 fragColor;

float sdf(vec2 center, vec2 size) {
    vec2 q = abs(center) - size + radius;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

void main() {
    float fillSoftness = max(softness, 1e-4);
    float strokeSoftness = max(borderSoftness, 1e-4);
    vec2 center = rect.xy + rect.zw * 0.5;
    vec2 halfSize = rect.zw * 0.5 - vec2(max(fillSoftness, strokeSoftness) - min(borderWidth, 0.0));
    float dist = sdf(fragPos - center, halfSize);

    float outer = 1.0 - smoothstep(-strokeSoftness, strokeSoftness, dist + min(borderWidth, 0.0));
    float innerBorder = 1.0 - smoothstep(-strokeSoftness, strokeSoftness, dist + max(borderWidth, 0.0));
    float fill = 1.0 - smoothstep(-fillSoftness, fillSoftness, dist + max(borderWidth, 0.0));
    float border = max(outer - innerBorder, 0.0) * step(1e-4, abs(borderWidth));

    float fillAlpha = color.a * fill;
    float borderAlpha = borderColor.a * border;
    float alpha = borderAlpha + fillAlpha * (1.0 - borderAlpha);
    vec3 rgb = (borderColor.rgb * borderAlpha + color.rgb * fillAlpha * (1.0 - borderAlpha)) / max(alpha, 1e-4);

    fragColor = vec4(rgb, alpha);
}
