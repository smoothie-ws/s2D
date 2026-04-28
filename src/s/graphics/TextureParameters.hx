package s.graphics;

typedef MipMapFilter = kha.graphics4.MipMapFilter;
typedef TextureFormat = kha.graphics4.TextureFormat;
typedef TextureFilter = kha.graphics4.TextureFilter;
typedef TextureAddressing = kha.graphics4.TextureAddressing;

/**
 * Sampler parameters used when binding a texture.
 *
 * These values describe how texture coordinates outside the `0..1` range are
 * handled and which filters are used when sampling.
 */
typedef TextureParameters = {
	/** Horizontal texture addressing mode. */
	var ?uAddressing:TextureAddressing;

	/** Vertical texture addressing mode. */
	var ?vAddressing:TextureAddressing;

	/** Filter used when the texture is sampled smaller than its native size. */
	var ?minificationFilter:TextureFilter;

	/** Filter used when the texture is sampled larger than its native size. */
	var ?magnificationFilter:TextureFilter;

	/** Filter used when choosing between mip levels. */
	var ?mipmapFilter:MipMapFilter;
}
