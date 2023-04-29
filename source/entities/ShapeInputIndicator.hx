package entities;

import flixel.FlxG;
import flixel.FlxSprite;

enum Shape {
	Circle;
	Triangle;
	Square;
	Pentagon;
	Hexagon;
	Heptagon;
	Octogon;
	Nonagon;
	Decagon;
}

enum Color {
	Green;
	Blue;
	Yellow;
	Pink;
	White;
}

class ShapeInputIndicator extends FlxSprite {
	public var shape: Shape;
	public var colorEnum: Color;

	public function new(shape: Shape, color: Color) {
		super();
		this.shape = shape;
		colorEnum = color;
		// TODO: MW these shapes should maybe bounce around and spin in anticipation?
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public static function newRandom(): ShapeInputIndicator {
		var randomShape = FlxG.random.getObject(Type.allEnums(Shape));
		var randomColorEnum = FlxG.random.getObject(Type.allEnums(Color));
		return new ShapeInputIndicator(randomShape, randomColorEnum);
	}
}
