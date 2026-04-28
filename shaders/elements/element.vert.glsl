#version 450

uniform mat3 mvp;
uniform vec4 rect;

layout(location = 0) in vec2 vertPos;
layout(location = 1) in vec2 vertUV;
layout(location = 0) out vec2 fragPos;
layout(location = 1) out vec2 fragUV;

void main() {
    fragPos = rect.xy + vertPos * rect.zw;
    fragUV = vertUV;
    gl_Position = vec4((mvp * vec3(rect.xy + vertPos * rect.zw, 1.0)).xy, 0.0, 1.0);
}
