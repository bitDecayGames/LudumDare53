package entities;

import flixel.FlxSprite;

class OutputSlot extends FlxSprite {
	var shapeList:Array<ShapeOutputIndicator> = [];

	public function new() {
		super();

		// TODO: MW might need a sprite to be the a dotted line around the list?
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
