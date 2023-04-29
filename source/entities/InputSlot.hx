package entities;

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
}
