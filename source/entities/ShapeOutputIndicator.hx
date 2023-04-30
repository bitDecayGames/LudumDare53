package entities;

import entities.IOEnums.IOColor;
import entities.IOEnums.IOShape;
import flixel.FlxSprite;

class ShapeOutputIndicator extends FlxSprite {
	public var shape: IOShape;
	public var colorEnum: IOColor;

	public function new(shape: IOShape, color: IOColor) {
		super();
		this.shape = shape;
		colorEnum = color;
		// TODO: MW these shapes should maybe pulse to the rythm of the music?
		loadGraphic(AssetPaths.shapes__png, true, 32, 32);
		animation.frameIndex = shape;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
