package entities;

import flixel.FlxSprite;

class InputSlot extends FlxSprite {
	public var queue:Array<ShapeInputIndicator> = [];

	public function new() {
		super();

		// TODO: MW might need a sprite to be the a dotted line around the queue?
	}

	override public function update(delta:Float) {
		super.update(delta);

		// TODO: maybe track some kind of timer here to indicate when the input indicated should fail
	}
}
