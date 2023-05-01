package entities;

import levels.LevelConfig;
import levels.LevelConfig;
import entities.IOEnums.IOColor;
import entities.IOEnums.IOShape;
import flixel.FlxG;
import flixel.FlxSprite;

class ShapeInputIndicator extends FlxSprite {
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
		var possibleShapes = LevelConfig.levels[LevelConfig.currentLevel].shapes;
		var randomShape = FlxG.random.getObject(possibleShapes);
		return new ShapeInputIndicator(randomShape);
	}
}
