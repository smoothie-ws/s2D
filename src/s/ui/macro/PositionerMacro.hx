package s.ui.macro;

import haxe.macro.Expr;

using s.extensions.StringExt;

class PositionerMacro {
	public static macro function updatePositionFlow(l:String, s:String, c:String, e:String, cl:String, cs:String, cc:String, ce:String) {
		var ld = '${l}Dirty';
		var cld = '${cl}Dirty';

		var sRef = macro $i{s};
		var cRef = macro $i{c};
		var eRef = macro $i{e};
		var lRef = macro $i{l};
		var EtoSRef = macro $i{'${e.capitalize()}To${s.capitalize()}'};
		var aERef = macro $i{'Align${e.capitalize()}'};
		var aCRef = macro $i{'Align${c.capitalize()}'};

		var csRef = macro $i{cs};
		var ccRef = macro $i{cc};
		var ceRef = macro $i{ce};
		var clRef = macro $i{l};
		var caERef = macro $i{'Align${ce.capitalize()}'};
		var caCRef = macro $i{'Align${cc.capitalize()}'};

		var childLDRef:Expr = macro c.$ld;
		var childCLDRef:Expr = macro c.$cld;

		function crossAlign()
			return macro {
				if (alignment.matches($caERef))
					c.$ce.position = $ceRef.position - $ceRef.padding - c.$ce.margin;
				else if (alignment.matches($caCRef))
					c.$cc.position = $ccRef.position + $ccRef.padding + c.$cc.margin;
				else
					c.$cs.position = $csRef.position + $csRef.padding + c.$cs.margin;
			}

		return macro {
			var relayout = children.dirty || spacingDirty || directionDirty || alignmentDirty || $sRef.offsetDirty || $cRef.offsetDirty
				|| $eRef.offsetDirty || $csRef.offsetDirty || $ccRef.offsetDirty || $ceRef.offsetDirty;

			if (!relayout)
				for (c in children)
					if (c.visibilityDirty
						|| c.parentDirty
						|| $childLDRef
						|| $childCLDRef || c.$s.marginDirty || c.$e.marginDirty || c.$cs.marginDirty || c.$cc.marginDirty || c.$ce.marginDirty) {
						relayout = true;
						break;
					}

			if (!relayout) {
				var i = 0;
				while (i < children.count)
					updateChild(children[i++]);
				return;
			}

			var size = 0.0;
			var items = [];

			for (c in children)
				if (c.isVisible) {
					size += c.$l + c.$s.margin + c.$e.margin;
					items.push(c);
				}
			if (items.length > 1)
				size += (items.length - 1) * spacing;

			var base = 0.0;
			// Align*End*
			if (alignment.matches($aERef))
				base = $eRef.position - $eRef.padding - size;
			// Align*Center*
			else if (alignment.matches($aCRef))
				base = $cRef.position + $cRef.padding - size * 0.5;
			// fallback: Align*Start*
			else
				base = $sRef.position + $sRef.padding;

			if (direction.matches($EtoSRef)) {
				base += size;
				for (c in items) {
					c.$e.position = base - c.$e.margin;
					${crossAlign()};
					updateChild(c);
					base = c.$s.position - c.$s.margin - spacing;
				}
			} else {
				for (c in items) {
					c.$s.position = base + c.$s.margin;
					${crossAlign()};
					updateChild(c);
					base = c.$e.position + c.$e.margin + spacing;
				}
			}
		}
	}
}
