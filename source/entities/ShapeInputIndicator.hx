package entities;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import levels.LevelConfig;
import entities.IOEnums.IOShape;
import entities.ShapeIndicator;
import flixel.FlxG;
import flixel.tweens.misc.ShakeTween;

class ShapeInputIndicator extends ShapeIndicator {
	public var shape: IOShape;

	private var isShaking = false;
	private var shakingTween: flixel.tweens.misc.ShakeTween;

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

	public function startShaking() {
		if (isShaking) {
			return;
		}

		isShaking = true;
		var origianlLocation = FlxPoint.get(x, y);
		shakingTween = FlxTween.shake(this, 0.025, 999, FlxAxes.XY, {
			onComplete: (t) -> {
				isShaking = false;
				x = origianlLocation.x;
				y = origianlLocation.y;
			}
		});
	}

	@:access(flixel.tweens.FlxTween)
	public function stopShaking() {
		shakingTween.finish();
		shakingTween.cancel();
	}
}
