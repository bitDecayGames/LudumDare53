package states;

import flixel.addons.display.FlxTiledSprite;
import entities.ScoreUI;
import flixel.group.FlxGroup;
import entities.ShapeInputIndicator;
import entities.ShapeIndicator;
import signals.Gameplay;
import plugins.HandleDeliveryPlugin;
import plugins.CheckForConnectionPlugin;
import plugins.HandleBadConnectionPlugin;
import plugins.ScoreModifierPlugin;
import plugins.ConnectivityMaskingPlugin;
import plugins.LosePlugin;
import plugins.SpawnerPlugin;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import entities.Cursor;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import entities.Grid;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;


using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var cursor:FlxSprite;

	var scoreboardPos = FlxPoint.get(10 * 32, 32);
	var scoreboardSize = FlxPoint.get(4 * 32, 32 * 13);
	var scoreboardArea = FlxRect.get(10 * 32, 32, 4 * 32, 13 * 32 + 10);

	var inputsPos = FlxPoint.get(32, 32 + 9 * 32);
	var inputsSize = FlxPoint.get(8 * 32, 4 * 32);

	var outputsPos = FlxPoint.get(32, 32);
	var outputsSize = FlxPoint.get(8 * 32, 13 * 32 + 10);

	var bgGroup = new FlxTypedGroup<FlxSprite>();
	var piecesGroup = new FlxTypedGroup<FlxSprite>();
	var inputOutputGroup = new FlxTypedGroup<FlxSprite>();
	var uiGroup = new FlxTypedGroup<FlxSprite>();

	public function new() {
		super();

		Gameplay.reset();
	}

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		// #if music
		FmodManager.PlaySong(FmodSongs.Puzzle);
		// #end
		
		FlxG.camera.pixelPerfectRender = true;

		add(bgGroup);
		add(piecesGroup);
		add(inputOutputGroup);
		add(uiGroup);

		var bg = new FlxTiledSprite(AssetPaths.background_options__png, FlxG.width, FlxG.height);

		bgGroup.add(bg);


		var gridStartPosition = FlxPoint.get(32, 64);

		var sliceRect = FlxRect.get(9, 9, 20, 20);

		var nineSliceBorder = 4;

		var outputBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, sliceRect, outputsSize.x + 2 * nineSliceBorder + 8,
			outputsSize.y + 2 * nineSliceBorder);
		outputBackground.offset.set(nineSliceBorder, nineSliceBorder);
		outputBackground.setPosition(outputsPos.x, outputsPos.y);
		bgGroup.add(outputBackground);
		outputBackground.stretchCenter = true;
		outputBackground.stretchBottom = true;
		outputBackground.stretchLeft = true;
		outputBackground.stretchRight = true;
		outputBackground.stretchTop = true;

		Gameplay.onNodeSpawn.add((n) -> {
			piecesGroup.add(n);
			for (mask in n.masks) {
				piecesGroup.add(mask);			
			}
		});

		// Setup signal for future shapes
		Gameplay.onMessageSpawn.add(function(shape:ShapeIndicator) {
			inputOutputGroup.add(shape);
		});

		var scoreUI = new ScoreUI(scoreboardArea, bg);
		add(scoreUI);

		var grid = new Grid(32, gridStartPosition, 8, 8, [
			new CheckForConnectionPlugin(),
			new HandleDeliveryPlugin(),
			new HandleBadConnectionPlugin(),
			new SpawnerPlugin(),
			new ScoreModifierPlugin(scoreUI),
			new ConnectivityMaskingPlugin(),
			new LosePlugin()
		]);
		add(grid);

		cursor = new Cursor(grid);
		uiGroup.add(cursor);

		Gameplay.onGameStart.dispatch(grid);

		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		#if uidebug
		// Outputs
		DebugDraw.ME.drawWorldRect(32, 32, 8 * 32, 32);
		// Board
		DebugDraw.ME.drawWorldRect(32, 64, 8 * 32, 8 * 32);
		// Inputs
		DebugDraw.ME.drawWorldRect(32, 32 + 9 * 32, 8 * 32, 4 * 32);
		// Score board
		DebugDraw.ME.drawWorldRect(10 * 32, 32, 4 * 32, 32 * 13);
		#end
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
