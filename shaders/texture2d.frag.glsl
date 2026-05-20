#version 450

uniform vec4 color;
uniform sampler2D source;

in vec2 fragUV;
out vec4 fragColor;

void main() {
    fragColor = texture(source, fragUV) * color;
}
