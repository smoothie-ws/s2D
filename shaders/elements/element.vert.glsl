#version 450

uniform mat3 mvp;
uniform vec4 rect;

in vec2 vertPos;
in vec2 vertUV;
out vec2 fragPos;
out vec2 fragUV;

void main() {
    fragPos = rect.xy + vertPos * rect.zw;
    fragUV = vertUV;
    gl_Position = vec4((mvp * vec3(rect.xy + vertPos * rect.zw, 1.0)).xy, 0.0, 1.0);
}
