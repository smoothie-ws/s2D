#version 450

#include "stage/std/lighting"

uniform mat3 viewProjection;
#if S2D_LIGHTING_SHADOWS == 1
uniform sampler2D shadowMap;
#endif

// light uniforms
uniform vec3 lightPosition;
uniform vec3 lightColor;
uniform vec2 lightAttrib;
#define lightPower lightAttrib.x
#define lightRadius lightAttrib.y
// #define lightVolume lightAttrib.z

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;

layout(location = 0) in vec2 fragCoord;
layout(location = 0) out vec3 fragColor;

void main() {
    vec3 albedo, normal, orm;
    albedo = texture(albedoMap, fragCoord).rgb;
    normal = texture(normalMap, fragCoord).rgb;
    orm = texture(ormMap, fragCoord).rgb;

    normal = normalize(normal * 2.0 - 1.0);
    vec3 position = inverse(viewProjection) * vec3(fragCoord * 2.0 - 1.0, 0.0);

    Light light = Light(
            lightPosition,
            lightColor,
            lightPower,
            lightRadius
        // lightVolume
        );
    vec3 l = lighting(light, position, normal, albedo.rgb, orm);
    #if S2D_LIGHTING_SHADOWS == 1
    fragColor = l * texture(shadowMap, fragCoord).r;
    #else
    fragColor = l;
    #endif
}
