#version 450

uniform mat3 mvp;
uniform vec4 rect;
uniform vec4 clipRect;

in vec2 vertPos;
in vec2 vertUV;
out vec2 fragUV;

void main() {
    fragUV = clipRect.xy + vec2(vertUV.x, 1.0 - vertUV.y) * clipRect.zw;
    gl_Position = vec4((mvp * vec3(rect.xy + vertPos * rect.zw, 1.0)).xy, 0.0, 1.0);
}
