package s.assets.internal.image.format;

import haxe.io.Bytes;

class GIF extends AnimatedImageDecoder {
	static final interlacePasses = [
		{start: 0, step: 8},
		{start: 4, step: 8},
		{start: 2, step: 4},
		{start: 1, step: 2}
	];

	public function decode(bytes:Bytes):Void {
		DecodeTools.ensureAvailable(bytes, 0, 13, "GIF header");
		final signature = DecodeTools.readTag(bytes, 0, 6);
		if (signature != "GIF87a" && signature != "GIF89a")
			DecodeTools.fail('Invalid GIF signature: $signature');

		frameWidth = DecodeTools.u16LE(bytes, 6);
		frameHeight = DecodeTools.u16LE(bytes, 8);
		if (frameWidth <= 0 || frameHeight <= 0)
			DecodeTools.fail('Invalid GIF size: ${frameWidth}x$frameHeight');

		final packed = DecodeTools.u8(bytes, 10);
		final hasGlobalPalette = (packed & 0x80) != 0;
		final backgroundIndex = DecodeTools.u8(bytes, 11);
		final globalPaletteSize = hasGlobalPalette ? (1 << ((packed & 0x07) + 1)) : 0;

		var offset = 13;
		final globalPalette = hasGlobalPalette ? readPalette(bytes, offset, globalPaletteSize, "global") : null;
		if (hasGlobalPalette)
			offset += globalPaletteSize * 3;

		final background = readBackgroundColor(globalPalette, backgroundIndex);
		final canvas = Bytes.alloc(frameWidth * frameHeight * 4);
		fillRect(canvas, frameWidth, frameHeight, 0, 0, frameWidth, frameHeight, background.r, background.g, background.b, background.a);

		final frames = new Array<Bytes>();
		durations = [];

		var disposal = 0;
		var transparentIndex = -1;
		var delay = 0.0;
		var done = false;

		while (!done && offset < bytes.length) {
			DecodeTools.ensureAvailable(bytes, offset, 1, "GIF block marker");
			final blockType = DecodeTools.u8(bytes, offset++);

			switch blockType {
				case 0x21:
					DecodeTools.ensureAvailable(bytes, offset, 1, "GIF extension label");
					final label = DecodeTools.u8(bytes, offset++);
					switch label {
						case 0xF9:
							DecodeTools.ensureAvailable(bytes, offset, 6, "GIF graphic control extension");
							final blockSize = DecodeTools.u8(bytes, offset++);
							if (blockSize != 4)
								DecodeTools.fail('Invalid GIF graphic control block size: $blockSize');

							final control = DecodeTools.u8(bytes, offset++);
							disposal = (control >> 2) & 0x07;
							delay = DecodeTools.u16LE(bytes, offset) / 100.0;
							offset += 2;
							final candidateTransparentIndex = DecodeTools.u8(bytes, offset++);
							transparentIndex = (control & 0x01) != 0 ? candidateTransparentIndex : -1;

							if (DecodeTools.u8(bytes, offset++) != 0)
								DecodeTools.fail("GIF graphic control extension is missing terminator");
						case 0xFF:
							DecodeTools.ensureAvailable(bytes, offset, 1, "GIF application extension header");
							final headerSize = DecodeTools.u8(bytes, offset++);
							DecodeTools.ensureAvailable(bytes, offset, headerSize, "GIF application extension identifier");
							offset += headerSize;
							offset = skipSubBlocks(bytes, offset);
						case 0x01:
							DecodeTools.ensureAvailable(bytes, offset, 1, "GIF plain text extension header");
							final headerSize = DecodeTools.u8(bytes, offset++);
							DecodeTools.ensureAvailable(bytes, offset, headerSize, "GIF plain text extension header data");
							offset += headerSize;
							offset = skipSubBlocks(bytes, offset);
						case 0xFE:
							offset = skipSubBlocks(bytes, offset);
						case _:
							offset = skipSubBlocks(bytes, offset);
					}
				case 0x2C:
					DecodeTools.ensureAvailable(bytes, offset, 9, "GIF image descriptor");
					final left = DecodeTools.u16LE(bytes, offset);
					final top = DecodeTools.u16LE(bytes, offset + 2);
					final imageWidth = DecodeTools.u16LE(bytes, offset + 4);
					final imageHeight = DecodeTools.u16LE(bytes, offset + 6);
					final descriptor = DecodeTools.u8(bytes, offset + 8);
					offset += 9;

					if (imageWidth <= 0 || imageHeight <= 0)
						DecodeTools.fail('Invalid GIF frame size: ${imageWidth}x$imageHeight');
					if (left < 0 || top < 0 || left + imageWidth > frameWidth || top + imageHeight > frameHeight)
						DecodeTools.fail('GIF frame lies outside logical screen: ${imageWidth}x$imageHeight at $left,$top');

					final hasLocalPalette = (descriptor & 0x80) != 0;
					final interlaced = (descriptor & 0x40) != 0;
					final localPaletteSize = hasLocalPalette ? (1 << ((descriptor & 0x07) + 1)) : 0;
					final palette = hasLocalPalette ? readPalette(bytes, offset, localPaletteSize, "local") : globalPalette;
					if (hasLocalPalette)
						offset += localPaletteSize * 3;
					if (palette == null)
						DecodeTools.fail("GIF frame is missing a palette");

					DecodeTools.ensureAvailable(bytes, offset, 1, "GIF image LZW code size");
					final minimumCodeSize = DecodeTools.u8(bytes, offset++);
					final imageData = readSubBlocks(bytes, offset);
					offset = imageData.next;

					final previousCanvas = disposal == 3 ? cloneBytes(canvas) : null;
					final indices = decodeLzw(imageData.data, minimumCodeSize, imageWidth * imageHeight);
					blitFrame(canvas, palette, indices, left, top, imageWidth, imageHeight, interlaced, transparentIndex);

					frames.push(cloneBytes(canvas));
					durations.push(delay);

					switch disposal {
						case 2:
							fillRect(canvas, frameWidth, frameHeight, left, top, imageWidth, imageHeight, background.r, background.g, background.b,
								background.a);
						case 3:
							if (previousCanvas != null)
								canvas.blit(0, previousCanvas, 0, previousCanvas.length);
						case _:
					}

					disposal = 0;
					transparentIndex = -1;
					delay = 0.0;
				case 0x3B:
					done = true;
				case _:
					DecodeTools.fail('Unsupported GIF block type: $blockType');
			}
		}

		if (frames.length == 0)
			DecodeTools.fail("GIF contains no image frames");

		final frameCount = frames.length;
		final maxTextureSize = kha.Image.maxSize;
		atlasColumns = Std.int(Math.min(frameCount, Math.floor(maxTextureSize / frameWidth)));
		if (atlasColumns < 1)
			DecodeTools.fail('GIF frame width ${frameWidth} exceeds max texture size $maxTextureSize');

		atlasRows = Std.int(Math.ceil(frameCount / atlasColumns));
		if (atlasRows * frameHeight > maxTextureSize)
			DecodeTools.fail('GIF atlas exceeds max texture size $maxTextureSize: ${frameWidth}x${frameHeight} x $frameCount frames');

		width = frameWidth * atlasColumns;
		height = frameHeight * atlasRows;
		pixels = Bytes.alloc(width * height * 4);

		final rowBytes = frameWidth * 4;
		for (frame in 0...frameCount) {
			final source = frames[frame];
			final col = frame % atlasColumns;
			final row = Std.int(frame / atlasColumns);
			final xOffset = col * rowBytes;
			final yOffset = row * frameHeight;
			for (y in 0...frameHeight) {
				final src = y * rowBytes;
				final dst = (y + yOffset) * width * 4 + xOffset;
				pixels.blit(dst, source, src, rowBytes);
			}
		}

		finish();
	}

	function readPalette(bytes:Bytes, offset:Int, count:Int, name:String):Bytes {
		DecodeTools.ensureAvailable(bytes, offset, count * 3, 'GIF $name color table');
		return bytes.sub(offset, count * 3);
	}

	function readBackgroundColor(palette:Bytes, index:Int):{r:Int, g:Int, b:Int, a:Int} {
		if (palette == null || index < 0 || index * 3 + 2 >= palette.length) {
			return {r: 0, g: 0, b: 0, a: 0};
		}
		final base = index * 3;
		return {
			r: palette.get(base),
			g: palette.get(base + 1),
			b: palette.get(base + 2),
			a: 255
		};
	}

	function readSubBlocks(bytes:Bytes, offset:Int):{data:Bytes, next:Int} {
		final chunks = new Array<Bytes>();
		var total = 0;
		var cursor = offset;

		while (true) {
			DecodeTools.ensureAvailable(bytes, cursor, 1, "GIF sub-block length");
			final blockLength = DecodeTools.u8(bytes, cursor++);
			if (blockLength == 0)
				break;
			DecodeTools.ensureAvailable(bytes, cursor, blockLength, "GIF sub-block data");
			final chunk = bytes.sub(cursor, blockLength);
			chunks.push(chunk);
			total += blockLength;
			cursor += blockLength;
		}

		return {
			data: total > 0 ? DecodeTools.concat(chunks) : Bytes.alloc(0),
			next: cursor
		};
	}

	function skipSubBlocks(bytes:Bytes, offset:Int):Int
		return readSubBlocks(bytes, offset).next;

	function decodeLzw(data:Bytes, minimumCodeSize:Int, expectedLength:Int):Bytes {
		if (minimumCodeSize < 2 || minimumCodeSize > 8)
			DecodeTools.fail('Unsupported GIF LZW minimum code size: $minimumCodeSize');

		final clearCode = 1 << minimumCodeSize;
		final endCode = clearCode + 1;
		final prefix = [for (_ in 0...4096) -1];
		final suffix = Bytes.alloc(4096);
		final stack = [for (_ in 0...4097) 0];
		final output = Bytes.alloc(expectedLength);

		var codeSize = minimumCodeSize + 1;
		var nextCode = endCode + 1;
		var maxCode = 1 << codeSize;
		var bitOffset = 0;
		var oldCode = -1;
		var firstByte = 0;
		var out = 0;

		for (code in 0...clearCode)
			suffix.set(code, code);

		while (true) {
			final code = readCode(data, bitOffset, codeSize);
			if (code < 0)
				break;
			bitOffset += codeSize;

			if (code == clearCode) {
				codeSize = minimumCodeSize + 1;
				nextCode = endCode + 1;
				maxCode = 1 << codeSize;
				oldCode = -1;
				continue;
			}

			if (code == endCode)
				break;

			if (oldCode == -1) {
				if (code >= clearCode)
					DecodeTools.fail('Invalid GIF LZW stream: first code $code is not a literal');
				if (out >= expectedLength)
					DecodeTools.fail("GIF LZW stream produced too many pixels");
				output.set(out++, code);
				firstByte = code;
				oldCode = code;
				continue;
			}

			var current = code;
			var inCode = code;
			var stackSize = 0;

			if (current == nextCode) {
				stack[stackSize++] = firstByte;
				current = oldCode;
			} else if (current > nextCode) {
				DecodeTools.fail('Invalid GIF LZW code: $current');
			}

			while (current > endCode) {
				if (current >= nextCode)
					DecodeTools.fail('Invalid GIF LZW dictionary reference: $current');
				stack[stackSize++] = suffix.get(current);
				current = prefix[current];
				if (stackSize >= 4097)
					DecodeTools.fail("GIF LZW stack overflow");
			}

			if (current == clearCode || current == endCode)
				DecodeTools.fail('Invalid GIF LZW reserved code in dictionary stream: $current');

			firstByte = current;
			stack[stackSize++] = current;

			while (stackSize > 0) {
				if (out >= expectedLength)
					DecodeTools.fail("GIF LZW stream produced too many pixels");
				output.set(out++, stack[--stackSize]);
			}

			if (nextCode < 4096) {
				prefix[nextCode] = oldCode;
				suffix.set(nextCode, firstByte);
				nextCode++;
				if (nextCode == maxCode && codeSize < 12) {
					codeSize++;
					maxCode <<= 1;
				}
			}

			oldCode = inCode;
		}

		if (out != expectedLength)
			DecodeTools.fail('GIF LZW stream is truncated: expected $expectedLength pixels, got $out');
		return output;
	}

	function readCode(data:Bytes, bitOffset:Int, bitCount:Int):Int {
		final totalBits = data.length * 8;
		if (bitOffset + bitCount > totalBits)
			return -1;

		var byteOffset = bitOffset >> 3;
		var bitIndex = bitOffset & 7;
		var remaining = bitCount;
		var value = 0;
		var shift = 0;

		while (remaining > 0) {
			final available = 8 - bitIndex;
			final take = remaining < available ? remaining : available;
			final mask = (1 << take) - 1;
			final chunk = (data.get(byteOffset) >> bitIndex) & mask;
			value |= chunk << shift;
			remaining -= take;
			shift += take;
			byteOffset++;
			bitIndex = 0;
		}

		return value;
	}

	function blitFrame(canvas:Bytes, palette:Bytes, indices:Bytes, left:Int, top:Int, imageWidth:Int, imageHeight:Int, interlaced:Bool,
			transparentIndex:Int):Void {
		var src = 0;

		if (interlaced) {
			for (pass in interlacePasses) {
				var y = pass.start;
				while (y < imageHeight) {
					blitFrameRow(canvas, palette, indices, left, top + y, imageWidth, src, transparentIndex);
					src += imageWidth;
					y += pass.step;
				}
			}
		} else {
			for (y in 0...imageHeight) {
				blitFrameRow(canvas, palette, indices, left, top + y, imageWidth, src, transparentIndex);
				src += imageWidth;
			}
		}
	}

	function blitFrameRow(canvas:Bytes, palette:Bytes, indices:Bytes, left:Int, y:Int, imageWidth:Int, sourceOffset:Int, transparentIndex:Int):Void {
		for (x in 0...imageWidth) {
			final index = indices.get(sourceOffset + x);
			if (index == transparentIndex)
				continue;

			final paletteOffset = index * 3;
			if (paletteOffset + 2 >= palette.length)
				DecodeTools.fail('GIF palette index out of range: $index');

			final dst = (y * frameWidth + left + x) * 4;
			canvas.set(dst + 0, palette.get(paletteOffset + 0));
			canvas.set(dst + 1, palette.get(paletteOffset + 1));
			canvas.set(dst + 2, palette.get(paletteOffset + 2));
			canvas.set(dst + 3, 255);
		}
	}

	function fillRect(target:Bytes, targetWidth:Int, targetHeight:Int, x:Int, y:Int, rectWidth:Int, rectHeight:Int, r:Int, g:Int, b:Int, a:Int):Void {
		final startX = x < 0 ? 0 : x;
		final startY = y < 0 ? 0 : y;
		final endX = x + rectWidth > targetWidth ? targetWidth : x + rectWidth;
		final endY = y + rectHeight > targetHeight ? targetHeight : y + rectHeight;

		for (py in startY...endY)
			for (px in startX...endX) {
				final dst = (py * targetWidth + px) * 4;
				target.set(dst + 0, r);
				target.set(dst + 1, g);
				target.set(dst + 2, b);
				target.set(dst + 3, a);
			}
	}

	function cloneBytes(bytes:Bytes):Bytes {
		final copy = Bytes.alloc(bytes.length);
		copy.blit(0, bytes, 0, bytes.length);
		return copy;
	}
}
