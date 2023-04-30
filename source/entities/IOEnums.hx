package entities;

import flixel.util.FlxColor;

enum abstract IOShape(Int) from Int to Int {
	var Club = 0;
	var Star = 1;
	var Circle = 2;
	var Square = 3;
	var Heart = 4;
	var Diamond = 5;
	var Triangle = 6;
	var Spade = 7;

	public static var allValues:Array<IOShape> = [
		Club,
		Star,
		Circle,
		Square,
		Heart,
		Diamond,
		Triangle,
		Spade,
	];

	public function getColor():FlxColor {
		switch this {
			case Club:
				return FlxColor.GREEN;
			case Star:
				return FlxColor.BLUE;
			case Circle:
				return FlxColor.YELLOW;
			case Square:
				return FlxColor.PINK;
			case Heart:
				return FlxColor.RED;
			case Diamond:
				return FlxColor.MAGENTA;
			case Triangle:
				return FlxColor.ORANGE;
			case Spade:
				return FlxColor.PURPLE;
			default:
				return FlxColor.TRANSPARENT;
		}
	}
}

enum IOColor {
	Green;
	Blue;
	Yellow;
	Pink;
	Red;
	Magenta;
	Orange;
	Purple;
}