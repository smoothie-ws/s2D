#version 450

uniform mat3 mvp;
uniform float depth;
uniform vec4 sourceClipRect;

in vec2 vertPos;
in vec2 vertUV;

out vec2 fragPos;
out vec2 fragUV;

void main() {
    vec3 pos = mvp * vec3(vertPos, 1.0);
    fragPos = pos.xy;
    fragUV = sourceClipRect.xy + vertUV * sourceClipRect.zw;
    gl_Position = vec4(fragPos, depth, 1.0);
}
