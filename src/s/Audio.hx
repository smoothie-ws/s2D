package s;

import kha.math.FastVector3;
import aura.Aura;
import aura.dsp.panner.Panner;
import aura.dsp.panner.StereoPanner;
import s.math.Vec3;
import s.assets.Sound;

/**
 * Audio playback helper bound to a sound asset.
 *
 * `Audio` combines sound asset loading with a playback handle and panner state.
 * It is meant for high-level sound playback in gameplay code, where you want to
 * point at an asset source and then control transport and panning through one
 * object.
 *
 * Typical usage:
 * ```haxe
 * var audio = new Audio("sfx_explosion");
 * audio.volume = 0.8;
 * audio.play();
 * ```
 *
 * The instance lazily waits for the asset to become available. Calls such as
 * [`play`](s.Audio.play) are safe before loading finishes; playback begins once
 * the underlying handle exists.
 */
class Audio implements s.shortcut.Shortcut {
	var asset:SoundAsset = new SoundAsset();
	var panner:AudioPanner = new AudioPanner();

	@:readonly @:alias var sound:Sound = asset.asset;

	/**
	 * Asset source path or id.
	 *
	 * Changing this switches the sound asset used by the player.
	 */
	@:alias public var source:String = asset.source;

	/**
	 * Duration of the loaded sound in seconds.
	 *
	 * This value is only meaningful once [`isLoaded`](s.Audio.isLoaded) is `true`.
	 */
	@:readonly @:alias public var duration:Float = sound.length;

	/** Whether the sound asset has finished loading. */
	@:readonly @:alias public var isLoaded:Bool = asset.isLoaded;

	/**
	 * Whether the sound should be decoded to an uncompressed buffer before playback.
	 *
	 * Use this when startup latency matters more than memory usage, or when the
	 * backend performs better with uncompressed samples. Keeping it `false` can
	 * reduce memory cost for larger assets when compressed playback is available.
	 */
	public var uncompressed(default, set):Bool;

	/**
	 * Playback volume multiplier.
	 *
	 * This affects the final channel gain and is independent from panning.
	 *
	 * @default 1.0
	 */
	@:alias public var volume:Float = panner.volume;

	/**
	 * Stereo balance, usually in the `-1.0..1.0` range.
	 *
	 * Negative values bias the signal left, positive values bias it right.
	 */
	@:alias public var balance:Float = panner.balance;

	/**
	 * World-space sound position used by the panner.
	 *
	 * This is most useful when the active backend is configured for positional audio.
	 */
	@:alias public var location:Vec3 = panner.location;

	/**
	 * Maximum distance used for attenuation.
	 *
	 * Past this distance the panner stops reducing volume further.
	 */
	@:alias public var maxDistance:Float = panner.maxDistance;

	/**
	 * Strength of the Doppler effect.
	 *
	 * Set this to `0` to disable Doppler pitch shift for this player.
	 */
	@:alias public var dopplerStrength:Float = panner.dopplerStrength;

	/**
	 * Distance attenuation mode used by the panner.
	 *
	 * This controls how volume falls off with distance.
	 */
	@:alias public var attenuationMode:AttenuationMode = panner.attenuationMode;

	/**
	 * Distance attenuation factor used by the panner.
	 *
	 * Higher values usually make distance-based falloff more pronounced.
	 */
	@:alias public var attenuationFactor:Float = panner.attenuationFactor;

	/**
	 * Creates an audio player for the given sound source.
	 *
	 * `source` may be omitted and assigned later through [`source`](s.Audio.source).
	 *
	 * @param source Asset source path or id.
	 * @param uncomressed Whether uncompressed playback should be preferred.
	 */
	public function new(?source:String, uncomressed:Bool = true) {
		this.uncompressed = uncompressed;
		this.source = source;
	}

	/**
	 * Starts playback.
	 *
	 * If the sound asset is not loaded yet, playback is deferred until the asset
	 * becomes available.
	 *
	 * @param retrigger Whether to restart playback if already playing.
	 * @param waitForAsset Reserved for compatibility with older call sites.
	 */
	public inline function play(retrigger:Bool = false, waitForAsset:Bool = true)
		@:privateAccess asset.delay(_ -> panner.handle?.play(retrigger));

	/**
	 * Pauses playback.
	 *
	 * If no playback handle exists yet, this call does nothing.
	 *
	 * @param waitForAsset Reserved for compatibility.
	 */
	public inline function pause(waitForAsset:Bool = true)
		@:privateAccess panner.handle?.pause();

	/**
	 * Stops playback.
	 *
	 * If no playback handle exists yet, this call does nothing.
	 *
	 * @param waitForAsset Reserved for compatibility.
	 */
	public inline function stop(waitForAsset:Bool = true)
		@:privateAccess panner.handle?.stop();

	function set_uncompressed(value:Bool) {
		if (value != uncompressed) {
			uncompressed = value;
			if (uncompressed)
				if (sound != null && sound.uncompressedData == null)
					if (sound.uncompressedData == null)
						sound.uncompress(() -> panner.handle = Aura.createUncompBufferChannel(sound));
					else
						panner.handle = Aura.createUncompBufferChannel(sound);
		}
		return uncompressed;
	}

	@:slot(asset.assetLoaded)
	function __updateAsset__(sound:Sound) {
		if (uncompressed || sound.compressedData == null)
			if (sound.uncompressedData == null)
				sound.uncompress(() -> panner.handle = Aura.createUncompBufferChannel(sound));
			else
				panner.handle = Aura.createUncompBufferChannel(sound);
		else
			panner.handle = Aura.createCompBufferChannel(sound);
	}
}

@:allow(s.Audio.AudioPanner)
private class AudioPanner {
	var panner(default, set):StereoPanner;

	public var handle(default, set):BaseChannelHandle;

	public var volume(default, set):Float = 1.0;
	public var balance(default, set):Float = 0.0;
	public var location(default, set):Vec3 = new Vec3(0, 0, 0);
	public var maxDistance(default, set):Float = 10.0;
	public var dopplerStrength(default, set):Float = 1.0;
	public var attenuationMode(default, set):AttenuationMode = AttenuationMode.Inverse;
	public var attenuationFactor(default, set):Float = 1.0;

	public function new() {}

	private inline function set_handle(value:BaseChannelHandle):BaseChannelHandle {
		handle = value;
		if (handle != null) {
			handle.setVolume(volume);
			if (panner != null)
				panner.setHandle(handle);
			else
				panner = new StereoPanner(handle);
		}
		return handle;
	}

	private inline function set_panner(value:StereoPanner):StereoPanner {
		panner = value;
		if (panner != null) {
			panner.setBalance(balance);
			panner.setLocation((location : FastVector3));
			panner.update3D();
			panner.maxDistance = maxDistance;
			panner.dopplerStrength = dopplerStrength;
			panner.attenuationMode = attenuationMode;
			panner.attenuationFactor = attenuationFactor;
		}
		return panner;
	}

	private inline function set_volume(value:Float):Float {
		volume = value;
		if (handle != null)
			handle.setVolume(value);
		return volume;
	}

	private inline function set_balance(value:Float):Float {
		balance = value;
		if (panner != null)
			panner.setBalance(value);
		return balance;
	}

	private inline function set_location(value:Vec3):Vec3 {
		location = value;
		if (panner != null) {
			panner.setLocation((value : FastVector3));
			panner.update3D();
		}
		return location;
	}

	private inline function set_dopplerStrength(value:Float):Float {
		dopplerStrength = value;
		if (panner != null)
			panner.dopplerStrength = value;
		return balance;
	}

	private inline function set_attenuationMode(value:AttenuationMode):AttenuationMode {
		attenuationMode = value;
		if (panner != null)
			panner.attenuationMode = value;
		return attenuationMode;
	}

	private inline function set_attenuationFactor(value:Float):Float {
		attenuationFactor = value;
		if (panner != null)
			panner.attenuationFactor = value;
		return attenuationFactor;
	}

	private inline function set_maxDistance(value:Float):Float {
		maxDistance = value;
		if (panner != null)
			panner.maxDistance = value;
		return maxDistance;
	}
}
