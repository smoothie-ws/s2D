#version 450

uniform mat3 viewProjection;

layout(location = 0) in vec2 vertCoord;

layout(location = 0) out vec2 fragCoord;
layout(location = 1) out vec2 fragUV;
#if (S_SPIRV == 1)
out float fragDepth;
#endif

#if (S2D_SPRITE_INSTANCING != 1)
uniform float depth;
uniform mat3 model;
uniform vec4 cropRect;
#else
layout(location = 1) in vec4 cropRect;
layout(location = 2) in vec3 model0;
layout(location = 3) in vec3 model1;
layout(location = 4) in vec3 model2;
layout(location = 5) in float depth;

layout(location = 2) out mat3 model;
#endif

void main() {
    #if (S2D_SPRITE_INSTANCING == 1)
    model = mat3(model0, model1, model2);
    #endif
    vec3 pos = viewProjection * model * vec3(vertCoord, 1.0);
    gl_Position = vec4(pos.xy, depth, 1.0);

    fragCoord = gl_Position.xy;
    fragUV = cropRect.xy + (vertCoord * 0.5 + 0.5) * cropRect.zw;
    #if (S_SPIRV == 1)
    fragDepth = depth;
    #endif
}
