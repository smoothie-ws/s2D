#version 450

uniform mat3 mvp;
uniform vec4 rect;
uniform vec4 clipRect;

layout(location = 0) in vec2 vertPos;
layout(location = 1) in vec2 vertUV;
layout(location = 1) out vec2 fragUV;

void main() {
    fragUV = clipRect.xy + vertUV * clipRect.zw;
    gl_Position = vec4((mvp * vec3(rect.xy + vertPos * rect.zw, 1.0)).xy, 0.0, 1.0);
}
