package s.stage2d.objects;

import aura.dsp.panner.Panner;
import s.Audio;
import s.math.SMath;

@:access(s.Audio)
class Speaker extends StageObject {
	var audio:Audio = new Audio();

	@:alias public var source:String = audio.asset.source;

	@:alias public var balance:Float = audio.balance;
	@:alias public var maxDistance:Float = audio.maxDistance;
	@:alias public var dopplerStrength:Float = audio.dopplerStrength;
	@:alias public var attenuationMode:AttenuationMode = audio.attenuationMode;
	@:alias public var attenuationFactor:Float = audio.attenuationFactor;

	public function new(source:String, uncompressed:Bool = true) {
		super();
		audio = new Audio(source, uncompressed);
	}

	public inline function play(retrigger:Bool = false) {
		audio.play(retrigger);
	}

	public inline function pause() {
		audio.pause();
	}

	public inline function stop() {
		audio.stop();
	}
}
