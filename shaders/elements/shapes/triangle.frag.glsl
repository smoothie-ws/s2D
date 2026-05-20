#version 450

uniform vec4 color;
uniform float radius;
uniform float softness;
uniform float borderWidth;
uniform vec4 borderColor;
uniform float borderSoftness;

uniform vec2 point1;
uniform vec2 point2;
uniform vec2 point3;
in vec2 fragPos;
out vec4 fragColor;

float cross2(vec2 a, vec2 b) {
    return a.x * b.y - a.y * b.x;
}

vec2 lineIntersection(vec2 p, vec2 r, vec2 q, vec2 s) {
    float d = cross2(r, s);
    if (abs(d) < 1e-5)
        return (p + q) * 0.5;
    return p + r * (cross2(q - p, s) / d);
}

float sdf(vec2 p, vec2 a, vec2 b, vec2 c) {
    vec2 e0 = b - a;
    vec2 e1 = c - b;
    vec2 e2 = a - c;

    vec2 v0 = p - a;
    vec2 v1 = p - b;
    vec2 v2 = p - c;

    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);

    float s = sign(cross2(e0, a - c));

    vec2 d0 = vec2(dot(pq0, pq0), s * cross2(v0, e0));
    vec2 d1 = vec2(dot(pq1, pq1), s * cross2(v1, e1));
    vec2 d2 = vec2(dot(pq2, pq2), s * cross2(v2, e2));

    vec2 d = min(min(d0, d1), d2);
    return -sqrt(d.x) * sign(d.y);
}

void main() {
    float fillSoftness = max(softness, 1e-4);
    float strokeSoftness = max(borderSoftness, 1e-4);

    vec2 a = point1;
    vec2 b = point2;
    vec2 c = point3;

    vec2 e0 = b - a;
    vec2 e1 = c - b;
    vec2 e2 = a - c;

    float area2 = abs(cross2(e0, c - a));
    float perimeter = length(e0) + length(e1) + length(e2);
    float maxRadius = perimeter > 0.0 ? area2 / perimeter : 0.0;
    float r = min(radius, max(maxRadius - max(fillSoftness, strokeSoftness), 0.0));

    float winding = sign(cross2(e0, c - a));
    vec2 n0 = winding * normalize(vec2(-e0.y, e0.x));
    vec2 n1 = winding * normalize(vec2(-e1.y, e1.x));
    vec2 n2 = winding * normalize(vec2(-e2.y, e2.x));

    vec2 ia = lineIntersection(c + n2 * r, e2, a + n0 * r, e0);
    vec2 ib = lineIntersection(a + n0 * r, e0, b + n1 * r, e1);
    vec2 ic = lineIntersection(b + n1 * r, e1, c + n2 * r, e2);

    float dist = sdf(fragPos, ia, ib, ic) - r;

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
