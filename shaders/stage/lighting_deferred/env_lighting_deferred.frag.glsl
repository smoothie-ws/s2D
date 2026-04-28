#version 450

#include "stage/std/lighting"

layout(location = 0) in vec2 fragCoord;
layout(location = 0) out vec4 fragColor;

#if S2D_LIGHTING_ENVIRONMENT == 1
uniform sampler2D envMap;
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
#endif
uniform sampler2D emissionMap;

void main() {
    // environment lighting
    #if S2D_LIGHTING_ENVIRONMENT == 1
    // fetch gbuffer textures
    vec3 albedo, normal, emission, orm;
    albedo = texture(albedoMap, fragCoord).rgb;
    normal = texture(normalMap, fragCoord).rgb;
    emission = texture(emissionMap, fragCoord).rgb;
    orm = texture(ormMap, fragCoord).rgb;

    normal = normalize(normal * 2.0 - 1.0);

    vec3 col = emission + envLighting(envMap, normal, albedo, orm);
    // just emission
    #else
    vec3 col = texture(emissionMap, fragCoord).rgb;
    #endif

    fragColor = vec4(col, 1.0);
}
