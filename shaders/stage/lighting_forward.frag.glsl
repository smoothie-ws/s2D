#version 450

#include "stage/std/lighting"

// stage uniforms
uniform mat3 viewProjection;
#if S2D_LIGHTING_ENVIRONMENT == 1
uniform sampler2D envMap;
#endif

// layer uniforms
uniform float[1 + 4 * 8] lights;

// material uniforms
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D emissionMap;
uniform sampler2D ormMap;

#if (S2D_SPRITE_INSTANCING != 1)
uniform mat3 model;
#else
layout(location = 2) in mat3 model;
#endif

layout(location = 0) in vec2 fragCoord;
layout(location = 1) in vec2 fragUV;
layout(location = 0) out vec4 fragColor;

void main() {
    // fetch material textures
    vec4 albedo = texture(albedoMap, fragUV);
    vec3 emission = texture(emissionMap, fragUV).rgb;
    vec3 orm = texture(ormMap, fragUV).rgb;

    vec3 normal = texture(normalMap, fragUV).rgb * 2.0 - 1.0;
    normal.xy = mat2(model) * normal.xy;
    normal = normalize(vec3(normal.xy, normal.z));

    vec3 position = inverse(viewProjection) * vec3(fragCoord, 0.0);

    // output color
    vec3 col = emission;

    int offset = 1;
    for (int i = 0; i < lights[0]; i++) {
        Light light = Light(
            vec3(lights[offset++], lights[offset++], lights[offset++]),
            vec3(lights[offset++], lights[offset++], lights[offset++]),
            lights[offset++],
            lights[offset++]
        );
        col += lighting(light, position, normal, albedo.rgb, orm);
    }

    fragColor = vec4(col * albedo.a, albedo.a);
}
