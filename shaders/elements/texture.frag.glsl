#version 450

uniform vec4 color;
uniform sampler2D source;

in vec2 fragUV;
out vec4 fragColor;

void main() {
    vec4 tex = texture(source, fragUV);
    fragColor = color * vec4(tex.rgb / tex.a, tex.a);
}
