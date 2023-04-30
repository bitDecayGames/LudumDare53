package entities;

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
}

enum IOColor {
	Green;
	Blue;
	Yellow;
	Pink;
	White;
}