#version 450

uniform mat3 mvp;

in vec2 vertPos;
in vec2 vertUV;
out vec2 fragUV;

void main() {
    fragUV = vertUV;
    gl_Position = vec4((mvp * vec3(vertPos, 1.0)).xy, 0.0, 1.0);
}
