package entities;

import signals.Gameplay;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;

class InputSlot extends FlxSprite {
	public var queue:Array<ShapeInputIndicator> = [];

	public var gridX:Int;
	public var gridY:Int;
	public var enter:Cardinal;

	public function new(gridX:Int, gridY:Int, enter:Cardinal) {
		super();
		this.gridX = gridX;
		this.gridY = gridY;
		this.enter = enter;
		// TODO: MW might need a sprite to be the a dotted line around the queue?
	}

	override public function update(delta:Float) {
		super.update(delta);
		// TODO: maybe track some kind of timer here to indicate when the input indicated should fail
	}

	// TODO: JF make sure the shape we're adding has an output
	public function addShape(grid: Grid, shape: ShapeInputIndicator) {
    var newShapeIndex = queue.length;
    queue.push(shape);
    shape.setPosition(grid.topCorner.x + gridX * 32,
                      grid.topCorner.y + (gridY + newShapeIndex + 1) * 32);
    Gameplay.onMessageSpawn.dispatch(shape);
  }
}
