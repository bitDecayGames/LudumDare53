package entities;

import entities.IOEnums.IOColor;
import entities.IOEnums.IOShape;
import flixel.FlxG;
import flixel.FlxSprite;

class ShapeInputIndicator extends FlxSprite {
	public var shape: IOShape;
	public var colorEnum: IOColor;

	public function new(shape: IOShape, color: IOColor) {
		super();
		this.shape = shape;
		colorEnum = color;
		// TODO: MW these shapes should maybe bounce around and spin in anticipation?
		loadGraphic(AssetPaths.shapes__png, true, 32, 32);
		animation.frameIndex = shape;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public static function newRandom(): ShapeInputIndicator {
		var randomShape = FlxG.random.getObject(IOShape.allValues);
		var randomColorEnum = FlxG.random.getObject(Type.allEnums(IOColor));
		return new ShapeInputIndicator(randomShape, randomColorEnum);
	}
}
