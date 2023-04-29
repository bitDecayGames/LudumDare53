package entities;

import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;

class OutputSlot extends FlxSprite {
	var shapeList:Array<ShapeOutputIndicator> = [];

	public var gridX:Int;
	public var gridY:Int;
	public var exit:Cardinal;

	public function new(gridX:Int, gridY:Int, exit:Cardinal) {
		super();

		this.gridX = gridX;
		this.gridY = gridY;
		this.exit = exit;

		// TODO: MW might need a sprite to be the a dotted line around the list?
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
