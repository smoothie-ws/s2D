#version 450

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D emissionMap;

in vec2 fragUV;
#if (S_SPIRV == 1)
in float fragDepth;
#endif
#if (S2D_SPRITE_INSTANCING == 1)
in mat3 model;
#else
uniform mat3 model;
#endif

layout(location = 0) out float depth;
layout(location = 1) out vec3 albedo;
layout(location = 2) out vec3 normal;
layout(location = 3) out vec3 emission;

#if (S2D_LIGHTING_PBR == 1)
uniform sampler2D ormMap;
layout(location = 4) out vec3 orm;
#endif

void main() {
    vec4 albedoCol = texture(albedoMap, fragUV);
    albedo = albedoCol.rgb / albedoCol.a;

    #if (S_SPIRV == 1)
    depth = 1.0 - fragDepth;
    #else
    depth = 1.0 - gl_FragCoord.z;
    #endif
    emission = texture(emissionMap, fragUV).rgb;
    #if (S2D_LIGHTING_PBR == 1)
    orm = texture(ormMap, fragUV).rgb;
    #endif

    normal = texture(normalMap, fragUV).rgb * 2.0 - 1.0;
    // local space -> world space
    normal.xy = mat2(model) * normal.xy;
    normal = normalize(vec3(normal.xy, normal.z));
    normal = normal * 0.5 + 0.5;
}
