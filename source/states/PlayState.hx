package states;

import flixel.addons.display.FlxTiledSprite;
import entities.ScoreUI;
import signals.Gameplay.NodeSpawnSignal;
import flixel.group.FlxGroup;
import entities.ShapeInputIndicator;
import signals.Gameplay;
import plugins.HandleDeliveryPlugin;
import plugins.CheckForConnectionPlugin;
import plugins.HandleBadConnectionPlugin;
import plugins.ScoreModifierPlugin;
import plugins.ConnectivityMaskingPlugin;
import plugins.SpawnerPlugin;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import entities.Cursor;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import entities.Grid;
import ui.font.BitmapText.CyberRed;
import achievements.Achievements;
import bitdecay.flixel.debug.DebugDraw;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;


using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var cursor:FlxSprite;

	var scoreboardPos = FlxPoint.get(10 * 32, 32);
	var scoreboardSize = FlxPoint.get(4 * 32, 32 * 13);
	var scoreboardArea = FlxRect.get(10 * 32, 32, 4 * 32, 32 * 13);

	var inputsPos = FlxPoint.get(32, 32 + 9 * 32);
	var inputsSize = FlxPoint.get(8 * 32, 4 * 32);

	var outputsPos = FlxPoint.get(32, 32);
	var outputsSize = FlxPoint.get(8 * 32, 32);

	var bgGroup = new FlxTypedGroup<FlxSprite>();
	var piecesGroup = new FlxTypedGroup<FlxSprite>();
	var inputOutputGroup = new FlxTypedGroup<FlxSprite>();
	var uiGroup = new FlxTypedGroup<FlxSprite>();

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		#if music
		FmodManager.PlaySong(FmodSongs.Puzzle);
		#end
		
		FlxG.camera.pixelPerfectRender = true;

		add(bgGroup);
		add(piecesGroup);
		add(inputOutputGroup);
		add(uiGroup);

		var bg = new FlxTiledSprite(AssetPaths.background_options__png, FlxG.width, FlxG.height);

		bgGroup.add(bg);


		var gridStartPosition = FlxPoint.get(32, 64);

		var nineSliceBorder = 4;
		var boardBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), 8 * 32 + 2 * nineSliceBorder,
			8 * 32 + 2 * nineSliceBorder);
		boardBackground.offset.set(nineSliceBorder, nineSliceBorder);
		boardBackground.setPosition(gridStartPosition.x, gridStartPosition.y);

		var scoreBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), scoreboardSize.x + 2 * nineSliceBorder,
			scoreboardSize.y + 2 * nineSliceBorder);
		scoreBackground.offset.set(nineSliceBorder, nineSliceBorder);
		scoreBackground.setPosition(scoreboardPos.x, scoreboardPos.y);
		bgGroup.add(scoreBackground);

		var inputsBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), inputsSize.x + 2 * nineSliceBorder,
			inputsSize.y + 2 * nineSliceBorder);
		inputsBackground.offset.set(nineSliceBorder, nineSliceBorder);
		inputsBackground.setPosition(inputsPos.x, inputsPos.y);
		bgGroup.add(inputsBackground);

		var outputBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), outputsSize.x + 2 * nineSliceBorder,
			outputsSize.y + 2 * nineSliceBorder);
		outputBackground.offset.set(nineSliceBorder, nineSliceBorder);
		outputBackground.setPosition(outputsPos.x, outputsPos.y);
		bgGroup.add(outputBackground);

		bgGroup.add(boardBackground);
		Gameplay.onNodeSpawn.add((n) -> {
			piecesGroup.add(n);
		});

		// Setup signal for future shapes
		Gameplay.onMessageSpawn.add(function(shape:ShapeInputIndicator) {
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
		]);
		add(grid);

		for (outputSlot in grid.outputs) {
			for (shape in outputSlot.shapeList) {
				add(shape);
			}
		}

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
