package s.graphics;

/**
 * Basic graphical interface.<br>
 * Represent old devices with only pixel pushing operations.
 */
@:allow(s.graphics.RenderTarget)
class Context1D extends kha.graphics2.Graphics1 {
	/**
	 * Set the pixel color at a specific position.
	 */
	override function setPixel(x:Int, y:Int, color:kha.Color):Void { // fixes d3d11 image stride
		#if (kha_html5 || kha_krom)
		pixels.setInt32(y * (canvas.width * 4) + x * 4, kha.Color.fromBytes(color.Bb, color.Gb, color.Rb, color.Ab));
		#else
		pixels.setInt32(y * (canvas.width * 4) + x * 4, color);
		#end
	}
}
