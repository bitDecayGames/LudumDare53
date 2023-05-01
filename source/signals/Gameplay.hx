package signals;

import entities.IOEnums.IOShape;
import entities.Node;
import entities.ConnectionTree;
import entities.InputSlot;
import entities.OutputSlot;
import entities.Grid;
import entities.ShapeInputIndicator;
import entities.ShapeOutputIndicator;
import entities.ShapeIndicator;
import flixel.util.FlxSignal;

typedef SpawnSignal = FlxTypedSignal<ShapeIndicator->Void>;
typedef NodeSpawnSignal = FlxTypedSignal<Node->Void>;
typedef GridSignal = FlxTypedSignal<Grid->Void>;
typedef InputOutputSignal = FlxTypedSignal<Array<InputSlot>->Array<OutputSlot>->ConnectionTree->Void>;

/**
 * A signal to indicate a successful delivery of a message. Args include the shape delivered, the input column, and the output column
**/
typedef DeliverySignal = FlxTypedSignal<Array<Int>->Array<Int>->Void>;

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
	 * Signals when points are earned	
	**/
	public static var onScore = new FlxTypedSignal<Int->Void>();

	/**
	 * Signals when points have been collected
	 */
	public static var onCollectPoints:FlxSignal = new FlxSignal();

	/**
	 * Signals when a new traversal search has begun
	**/
	public static var onNewTreeSearch = new FlxSignal();

	/**
	 * Signals when a new tree is found. Contains all information of tree's nodes, connected inputs, and connected outputs (if any)
	**/
	public static var onTreeResolved = new InputOutputSignal();

	/**
	 * Signals when a dilivery has been completed. This may not be an 'correct' delivery, just that a message was connected to an output
	 */
	public static var onCompleteDelivery:InputOutputSignal = new InputOutputSignal();

	/**
	  * Signals when a bad connection has happened
	 */
	public static var onBadConnection: InputOutputSignal = new InputOutputSignal();

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
	 *
	**/
	public static var onLevelChange:FlxSignal = new FlxSignal();

	/**
	 * Signals when a the level has been lost
	 */
	public static var onLoseLevel:FlxSignal = new FlxSignal();

	/**
	 * Signals when the game has been started
	**/
	public static var onGameStart:GridSignal = new GridSignal();

	/***
	 * Signals when tiles are done blowing up after delivery
	**/
	public static var onFinishedBlowingUp:GridSignal = new GridSignal();

	/**
		Signals when input queues are full and another input has attempted to be added
	**/
	public static var onInputsOverFilled:FlxSignal = new FlxSignal();

	/**
		Signals when input queues were full but at least 1 input has been cleared
	**/
	public static var onInputQueueCleaned:FlxSignal = new FlxSignal();

	public static function reset() {
		onRotate.removeAll();
		onSwap.removeAll();
		onRowSlide.removeAll();
		onMessageSpawn.removeAll();
		onNodeSpawn.removeAll();
		onScore.removeAll();
		onCollectPoints.removeAll();
		onNewTreeSearch.removeAll();
		onTreeResolved.removeAll();
		onCompleteDelivery.removeAll();
		onBadConnection.removeAll();
		onMessageSuccessfullySent.removeAll();
		onCompleteTask.removeAll();
		onCompleteLevelGoal.removeAll();
		onMessageTimeout.removeAll();
		onLevelChange.removeAll();
		onLoseLevel.removeAll();
		onGameStart.removeAll();
		onFinishedBlowingUp.removeAll();
		onInputsOverFilled.removeAll();
		onInputQueueCleaned.removeAll();
	}
}
