package signals;

import entities.IOEnums.IOShape;
import entities.Node;
import entities.ConnectionTree;
import entities.InputSlot;
import entities.OutputSlot;
import entities.Grid;
import entities.ShapeInputIndicator;
import flixel.util.FlxSignal;

typedef SpawnSignal = FlxTypedSignal<ShapeInputIndicator->Void>;
typedef NodeSpawnSignal = FlxTypedSignal<Node->Void>;
typedef GridSignal = FlxTypedSignal<Grid->Void>;
typedef InputOutputsSignal = FlxTypedSignal<Array<InputSlot>->Array<OutputSlot>->ConnectionTree->Void>;

/**
 * A signal to indicate a successful delivery of a message. Args include the shape delivered, the input column, and the output column
**/
typedef DeliverySignal = FlxTypedSignal<IOShape->Int->Int->Void>;

class Gameplay {
	/**
	 * Startup signals will be called once the game is loaded and Flixel is initialized
	 */
	/**
	 * Signals when a tile is rotated
	 */
	public static var onRotate:GridSignal = new GridSignal();

	/**
	 * Signals when two tiles are swapped with each other
	 */
	public static var onSwap:GridSignal = new GridSignal();

	/**
	 * Signals when a row slides some number of tiles down
	 */
	public static var onRowSlide:GridSignal = new GridSignal();

	/**
	 * Signals when a new message input has been spawned
	 */
	public static var onMessageSpawn:SpawnSignal = new SpawnSignal();

	/**
	 * Signals when a new node has been spawned
	 */
	 public static var onNodeSpawn:NodeSpawnSignal = new NodeSpawnSignal();

	/**
	 * Signals when points have been collected
	 */
	public static var onCollectPoints:FlxSignal = new FlxSignal();

	/**
	 * Signals when a dilivery has been completed. This may not be an 'correct' delivery, just that a message was connected to an output
	 */
	public static var onCompleteDelivery:InputOutputsSignal = new InputOutputsSignal();

	/**
	 * Signals that indicate a message of the given type was sent successfully to the proper output
	**/
	public static var onMessageSuccessfullySent = new DeliverySignal();

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
