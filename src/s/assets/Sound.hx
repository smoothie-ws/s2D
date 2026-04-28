package s.assets;

import s.assets.internal.sound.Sound as Internal;

@:forward()
@:forward.new
@:build(s.macro.AssetsMacro.buildAssetType("Sound"))
abstract Sound(Internal) from Internal to Internal {}
