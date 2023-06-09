package entities;

import entities.IOEnums.IOColor;
import entities.IOEnums.IOShape;
import entities.ShapeIndicator;

class ShapeOutputIndicator extends ShapeIndicator {
	public var shape: IOShape;
	public var colorEnum: IOColor;

	public function new(shape: IOShape) {
		super();
		this.shape = shape;
		// colorEnum = ioColor;
		// TODO: MW these shapes should maybe pulse to the rythm of the music?
		loadGraphic(AssetPaths.shapes__png, true, 32, 32);
		animation.frameIndex = shape;
		color = shape.getColor();
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
