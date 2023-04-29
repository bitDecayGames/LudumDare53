package signals;

import flixel.util.FlxSignal;

class Gameplay {
	/**
	 * Startup signals will be called once the game is loaded and Flixel is initialized
	 */
	public static var onTurn:FlxSignal = new FlxSignal();

	/**
	 * Signals when two tiles are swapped with each other
	 */
	public static var onSwap:FlxSignal = new FlxSignal();

	/**
	 * Signals when a row slides some number of tiles down
	 */
	public static var onRowSlide:FlxSignal = new FlxSignal();

	/**
	 * Signals when a new message input has been spawned
	 */
	public static var onSpawn:FlxSignal = new FlxSignal();

	/**
	 * Signals when points have been collected
	 */
	public static var onCollectPoints:FlxSignal = new FlxSignal();

	/**
	 * Signals when a dilivery has been completed
	 */
	public static var onCompleteDelivery:FlxSignal = new FlxSignal();

	/**
	 * Signals when a Task has been completed
	 */
	public static var onCompleteTask:FlxSignal = new FlxSignal();

	/**
	 * Signals when a LevelGoal has been completed
	 */
	public static var onCompleteLevelGoal:FlxSignal = new FlxSignal();

	/**
	 * Signals when a message timeout occurs
	 */
	public static var onMessageTimeout:FlxSignal = new FlxSignal();

	/**
	 * Signals when a the level has been lost
	 */
	public static var onLoseLevel:FlxSignal = new FlxSignal();
}
