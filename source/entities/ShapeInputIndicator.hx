package entities;

import levels.LevelConfig;
import levels.LevelConfig;
import entities.IOEnums.IOColor;
import entities.IOEnums.IOShape;
import entities.ShapeIndicator;
import flixel.FlxG;

class ShapeInputIndicator extends ShapeIndicator {
	public var shape: IOShape;

	public function new(shape: IOShape) {
		super();
		this.shape = shape;
		// TODO: MW these shapes should maybe bounce around and spin in anticipation?
		loadGraphic(AssetPaths.shapes__png, true, 32, 32);
		animation.frameIndex = shape;
		color = shape.getColor();
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public static function newRandom(): ShapeInputIndicator {
		var possibleShapes = LevelConfig.currentLevelConfig().shapes;
		var randomShape = FlxG.random.getObject(possibleShapes);
		return new ShapeInputIndicator(randomShape);
	}
}
