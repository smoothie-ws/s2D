package s.ui.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using s.extensions.ArrayExt;

class ExprError extends haxe.Exception {
	public var expr:Expr;

	public function new(expr:Expr, ?message:String) {
		super(message ?? "Invalid expression");
		this.expr = expr;
	}

	public function warn()
		Context.warning('$message: ${expr.toString()}', expr.pos);
}
#end

class ElementMacro {
	public static macro function updateAxis(start:String, center:String, end:String, pos:String, length:String) {
		var sd = start + "Dirty";
		var cd = center + "Dirty";
		var ed = end + "Dirty";

		var as = macro anchors.$start;
		var ac = macro anchors.$center;
		var ae = macro anchors.$end;

		var s = macro $i{start};
		var c = macro $i{center};
		var e = macro $i{end};

		var p = macro $i{pos};
		var l = macro $i{length};
		var ld = macro $i{length + "Dirty"};
		var noBind = macro $as == null && $ac == null || $as == null && $ae == null || $ac == null && $ae == null;
		var noAnchor = macro $as == null && $ac == null && $ae == null;

		function updatePos()
			return macro {
				$p = $s.position;
				if (parent != null)
					$p -= parent.$start.position;
			}

		function updateLength()
			return macro {
				@:bypassAccessor $l = $e.position - $s.position;
				lengthChanged = true;
			}

		return macro {
			var lengthChanged = false;

			if ($s.positionDirty) {
				${updatePos()};
				if ($ae == null && $ac == null) {
					$e.position = $s.position + $l;
					$c.position = ($s.position + $e.position) * 0.5;
				} else {
					if ($ae != null && $ac == null)
						$c.position = ($s.position + $e.position) * 0.5;
					else if ($ae == null && $ac != null)
						$e.position = $c.position + ($c.position - $s.position);
					${updateLength()};
				}
			}

			if ($c.positionDirty) {
				if ($as == null && $ae == null) {
					var d = $l * 0.5;
					$s.position = $c.position - d;
					$e.position = $c.position + d;
					${updatePos()};
				} else {
					if ($as != null && $ae == null)
						$e.position = $c.position + ($c.position - $s.position);
					else if ($as == null && $ae != null) {
						$s.position = $c.position - ($e.position - $c.position);
						${updatePos()};
					}
					${updateLength()};
				}
			}

			if ($e.positionDirty) {
				if ($as == null && $ac == null) {
					$s.position = $e.position - $l;
					$c.position = ($s.position + $e.position) * 0.5;
					${updatePos()};
				} else {
					if ($as != null && $ac == null)
						$c.position = ($s.position + $e.position) * 0.5;
					else if ($as == null && $ac != null) {
						$s.position = $c.position - ($e.position - $c.position);
						${updatePos()};
					}
					${updateLength()};
				}
			}

			if ($i{pos + "Dirty"} && !$s.positionDirty && !$c.positionDirty && !$e.positionDirty && $noAnchor) {
				$s.position = $p;
				if (parent != null)
					$s.position += parent.$start.position;

				if ($as == null && $ac == null && $ae == null) {
					$c.position = $s.position + $l * 0.5;
					$e.position = $s.position + $l;
				} else if ($as == null && $ac != null && $ae == null) {
					$e.position = $c.position + ($c.position - $s.position);
					${updateLength()};
				} else if ($as == null && $ac == null && $ae != null) {
					${updateLength()};
					$c.position = $s.position + $l * 0.5;
				}
			}

			if ($ld) {
				if ($ac == null && $ae == null) {
					$e.position = $s.position + $l;
					$c.position = $s.position + $l * 0.5;
				} else if ($as == null && $ac == null && $ae != null) {
					$s.position = $e.position - $l;
					$c.position = $e.position - $l * 0.5;
					${updatePos()};
				} else if ($as == null && $ac != null && $ae == null) {
					var d = $l * 0.5;
					$s.position = $c.position - d;
					$e.position = $c.position + d;
					${updatePos()};
				}
			}

			if (lengthChanged)
				$ld = true;
		}
	}

	#if macro
	static var reserved = ["all"];

	public static var shortcuts(default, null):Map<String, String> = [
		"element" => "s.ui.Element",
		// controls
		"button" => "s.ui.controls.Button",
		"slider" => "s.ui.controls.Slider",
		// "input" => "s.ui.controls.TextInput",
		// "edit" => "s.ui.elements.elements.TextEdit",
		// elements
		"text" => "s.ui.elements.Text",
		"label" => "s.ui.elements.Label",
		"canvas" => "s.ui.elements.Canvas",
		"icon" => "s.ui.elements.Icon",
		"image" => "s.ui.elements.ImageElement",
		"image.animated" => "s.ui.elements.AnimatedImageElement",
		"layer" => "s.ui.elements.Layer",
		"interactive" => "s.ui.elements.Interactive",
		// shapes
		"ellipse" => "s.ui.shapes.Ellipse",
		"triangle" => "s.ui.shapes.Triangle",
		"rectangle" => "s.ui.shapes.Rectangle",
		// gradients
		"gradient.conic" => "s.ui.gradients.ConicGradient",
		"gradient.linear" => "s.ui.gradients.LinearGradient",
		"gradient.radial" => "s.ui.gradients.RadialGradient",
		// positioners
		"row" => "s.ui.positioners.Row",
		// "flex" => "s.ui.positioners.Flex",
		"column" => "s.ui.positioners.Column",
		// layouts
		"layout" => "s.ui.layouts.Layout",
		"layout.row" => "s.ui.layouts.RowLayout",
		// "layout.flex" => "s.ui.layouts.FlexLayout",
		"layout.column" => "s.ui.layouts.ColumnLayout",
		// widgets
		// "progress" => "s.ui.widgets.ProgressBar",
		// "scroll" => "s.ui.widgets.ScrollView",
		// stage
		"stage2d" => "s.stage2d.Stage"
	];

	public static function init() {
		Compiler.registerCustomMetadata({metadata: ":ui.markup", doc: ""});
		Compiler.addGlobalMetadata("", "@:build(s.ui.macro.ElementMacro.build())", true, true, true);
	}

	public static function useShortcut(name:String, type:String) {
		if (reserved.contains(name)) {
			Context.warning("Can't overwrite reserved shortcut `name`", Context.currentPos());
			return;
		}

		if (shortcuts.exists(name)) {
			var previous = shortcuts.get(name);
			if (previous == type)
				return;
			Context.warning('Shortcut `$name -> $previous` will be overwritten to `$type`', Context.currentPos());
		}
		shortcuts.set(name, type);
	}

	public static function build() {
		var fields = Context.getBuildFields();

		for (field in fields) {
			if (field.meta == null)
				continue;
			for (m in field.meta)
				switch m.name {
					case ":ui.markup":
						buildMarkup(field);
				}
		}

		return fields;
	}

	static function getType(name:String) {
		return Context.getType(getTypeName(name)).toComplexType();
	}

	static function getTypePath(name:String):TypePath {
		return switch getType(name) {
			case TPath(tp):
				tp;
			default:
				throw "Invalid element class: " + name;
		}
	}

	static function getTypeName(name:String) {
		return shortcuts.get(name) ?? name;
	}

	static function getClassPath(name:String):TypePath {
		var elTypeName = getTypeName(name);
		var path = elTypeName.split(".");
		var typeName = path.pop();
		var typePath:TypePath = {
			pack: path,
			name: typeName,
			sub: null
		}
		if (typePath.pack.length > 0) {
			var c = typePath.pack[typePath.pack.length - 1].charAt(0);
			if (c == c.toUpperCase()) {
				typePath.sub = typePath.name;
				typePath.name = typePath.pack.pop();
			}
		}
		return typePath;
	}

	static function buildMarkup(field:Field) {
		var i = 0;
		var stack:Array<Expr> = [macro parent];
		var returnRef:Null<Expr> = null;

		inline function currentRef():Expr
			return stack[stack.length - 1];

		inline function parentRef():Expr
			return stack.length > 1 ? stack[stack.length - 2] : macro parent;

		function transform(expr:Expr, topLevel = false) {
			function addEl(meta:MetadataEntry, expr:Expr, pos:Position, ?varData:{name:String, type:Null<ComplexType>, isFinal:Bool}, ?assignRef:Expr) {
				var ctor = if (meta.name != "markup") {
					var tp = getClassPath(meta.name);
					macro @:pos(pos) new $tp($a{meta.params ?? []});
				} else switch meta.params {
					case [expr]: switch expr.expr {
							case ECall(e, params): macro @:pos(expr.pos) $e($a{[currentRef()].concat(params)});
							default:
								Context.error("Markup function call expected", meta.pos);
						}
					default:
						Context.error("Markup function call expected", meta.pos);
				}
				var elRef:Expr;
				var elExprs = [];

				if (varData != null) {
					elRef = macro @:pos(pos) $i{varData.name};
					elExprs.push({
						pos: pos,
						expr: EVars([
							{
								name: varData.name,
								type: varData.type,
								expr: ctor,
								isFinal: varData.isFinal
							}
						])
					});
				} else if (assignRef != null) {
					elRef = assignRef;
					elExprs.push(macro @:pos(pos) $assignRef = $ctor);
				} else {
					var elName = "__el" + i++;
					elRef = macro @:pos(pos) $i{elName};
					elExprs.push(macro @:pos(pos) var $elName = $ctor);
				}

				if (topLevel && stack.length == 1 && returnRef == null)
					returnRef = elRef;

				switch expr.expr {
					case EBinop(OpAssign, e1, e2):
						switch e1.expr {
							case EConst(CString(s, kind)):
								var exprs = flatten(e2);
								exprs.unshift(macro @:pos(e1.pos) $elRef.tags = $e1);
								expr.expr = EBlock(exprs);
							default:
						}
					default:
				}

				stack.push(elRef);
				var bodyExprs = transform(expr);
				stack.pop();
				if (bodyExprs != null && bodyExprs.length > 0)
					elExprs.push({
						pos: pos,
						expr: EBlock(bodyExprs)
					});
				elExprs.push(macro ${currentRef()}.addChild($elRef));

				return elExprs;
			}

			var def = expr.expr;
			if (def == null)
				return null;

			switch def {
				case EBlock(exprs):
					var out:Array<Expr> = [];
					for (e in exprs)
						out = out.concat(transform(e, topLevel));
					return out;
				case EConst(CIdent(s)) if (s.charAt(0) == "$"):
					if (s == "$parent")
						expr = parentRef();
					else if (s == "$element")
						expr = currentRef();
					else
						expr.expr = EField(currentRef(), s.substr(1));
					return transform(expr);
				case EMeta(m, e) if (m.name.charAt(0) != ":"):
					return addEl(m, e, expr.pos);
				case EMeta(m, e) if (m.name == ":bind"): // TODO
					var attrs = (m.params ?? []).map(e -> {
						var ident = extractName(transform(e)[0]).split(".");
						ident[ident.lastIndex()] = ident.last() + "Dirty";
						macro @:privateAccess $p{ident};
					});
					var cond = attrs[0];
					for (i in 1...attrs.length)
						cond = macro $cond || ${attrs[i]};
					var ex = macro $b{transform(e)};
					var updateExpr = cond != null ? macro if ($cond)
						$ex : macro $ex;
					return [ex, macro @:pos(expr.pos) ${currentRef()}.onUpdated(() -> $updateExpr)];
				case EVars(vars):
					var out:Array<Expr> = [];
					for (v in vars) {
						var n = v.name;
						if (v.expr == null) {
							out.push({
								pos: expr.pos,
								expr: EVars([
									{
										name: v.name,
										type: v.type,
										expr: null,
										isFinal: v.isFinal
									}
								])
							});
							continue;
						}
						out = out.concat(switch v.expr.expr {
							case EMeta(s, e):
								addEl(s, e, v.expr.pos, {
									name: n,
									type: v.type,
									isFinal: v.isFinal
								});
							default:
								[
									{
										pos: v.expr.pos,
										expr: EVars([
											{
												name: v.name,
												type: v.type,
												expr: block(transform(v.expr)),
												isFinal: v.isFinal
											}
										])
									}
								];
						});
					}
					return out;
				case EBinop(OpAssign, e1, e2):
					switch e2.expr {
						case EMeta(m, e):
							switch e1.expr {
								case EConst(CIdent(s)):
									return addEl(m, e, e2.pos, null, macro @:pos(e1.pos) $i{s});
								case EField(e, field):
									return addEl(m, e, e2.pos, null, e1);
								default:
							}
						default:
					}
				default:
			}

			return flatten(expr.map(e -> block(transform(e))));
		}

		var expr = extractExpr(field);
		var ret = null;
		var args = switch field.kind {
			case FFun(f):
				ret = f.ret;
				f.args;
			default:
				[];
		}

		args.unshift({name: "parent", type: macro :s.ui.Element});

		if (expr != null)
			field.kind = FFun({
				args: args,
				expr: block(transform(expr, true).concat([ret == null
					|| returnRef == null ? macro return parent : macro return $returnRef])),
				ret: ret
			});
	}

	static function extractExpr(field:Field) {
		return switch field.kind {
			case FFun(f):
				f.expr;
			case FVar(_, e), FProp(_, _, _, e):
				e;
		}
	}

	static function extractName(expr:Expr):String {
		return switch expr.expr {
			case EConst(CIdent(s)), EConst(CString(s)):
				s;
			case EField(e, field):
				extractName(e) + "." + field;
			default:
				Context.warning("Name expected", expr.pos);
				null;
		}
	}

	static function concat(e1:Expr, e2:Expr) {
		return block(flatten(e1).concat(flatten(e2)));
	}

	static function block(exprs:Array<Expr>) {
		if (exprs.length == 1)
			return exprs[0];
		else
			return macro $b{exprs};
	}

	static function flatten(expr:Expr):Array<Expr> {
		return switch expr.expr {
			case EBlock(exprs):
				exprs;
			default:
				[expr];
		}
	}
	#end
}
