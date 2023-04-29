package misc;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class Macros {
	/**
	 * Shorthand for retrieving compiler flag values
	 *
	 * @param key The key to get a defined value for
	 *
	 * @returns The value of the given key. If no value is defined for key, null is returned.
	 */
	public static macro function getDefine(key:String):haxe.macro.Expr {
		return macro $v{haxe.macro.Context.definedValue(key)};
	}

	/**
	 * Shorthand for setting compiler flags
	 *
	 * @param key The key to set a defined value for
	 * @param value The value to set for a defined value
	 */
	public static macro function setDefine(key:String, value:String):haxe.macro.Expr {
		haxe.macro.Compiler.define(key, value);
		return macro null;
	}

	/**
	 * Shorthand for checking if a compiler flag is defined
	 *
	 * @param key The key to check for a  defined value for
	 *
	 * @returns True if the key has a defined value, false otherwise
	 */
	public static macro function isDefined(key:String):haxe.macro.Expr {
		return macro $v{haxe.macro.Context.defined(key)};
	}

	public static macro function getEnumValues(typePath:Expr):Expr {
		// Get the type from a given expression converted to string.
		// This will work for identifiers and field access which is what we need,
		// it will also consider local imports. If expression is not a valid type path or type is not found,
		// compiler will give a error here.
		var type = Context.getType(typePath.toString());

		// Switch on the type and check if it's an abstract with @:enum metadata
		switch (type.follow()) {
		  case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
			// @:enum abstract values are actually static fields of the abstract implementation class,
			// marked with @:enum and @:impl metadata. We generate an array of expressions that access those fields.
			// Note that this is a bit of implementation detail, so it can change in future Haxe versions, but it's been
			// stable so far.
			var valueExprs = [];
			for (field in ab.impl.get().statics.get()) {
			  if (field.meta.has(":enum") && field.meta.has(":impl")) {
				var fieldName = field.name;
				valueExprs.push(macro $typePath.$fieldName);
			  }
			}
			// Return collected expressions as an array declaration.
			return macro $a{valueExprs};
		  default:
			// The given type is not an abstract, or doesn't have @:enum metadata, show a nice error message.
			throw new Error(type.toString() + " should be @:enum abstract", typePath.pos);
		}
	  }
}
