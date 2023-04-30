package states.debug;

import plugins.HandleDeliveryPlugin;
import plugins.CheckForConnectionPlugin;
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
import signals.Gameplay;
import entities.ShapeInputIndicator;

using states.FlxStateExt;

class JakeState extends FlxTransitionableState {
	var cursor:FlxSprite;

	var scoreboardPos = FlxPoint.get(10 * 32, 32);
	var scoreboardSize = FlxPoint.get(4 * 32, 32 * 13);

	var inputsPos = FlxPoint.get(32, 32 + 9 * 32);
	var inputsSize = FlxPoint.get(8 * 32, 4 * 32);

	var outputsPos = FlxPoint.get(32, 32);
	var outputsSize = FlxPoint.get(8 * 32, 32);

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		var grid = new Grid(32, FlxPoint.get(32, 64), 8, 8, [new CheckForConnectionPlugin(), new HandleDeliveryPlugin(), new SpawnerPlugin()]);

		var nineSliceBorder = 4;
		var boardBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), 8 * 32 + 2 * nineSliceBorder,
			8 * 32 + 2 * nineSliceBorder);
		boardBackground.offset.set(nineSliceBorder, nineSliceBorder);
		boardBackground.setPosition(grid.topCorner.x, grid.topCorner.y);

		var scoreBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), scoreboardSize.x + 2 * nineSliceBorder,
			scoreboardSize.y + 2 * nineSliceBorder);
		scoreBackground.offset.set(nineSliceBorder, nineSliceBorder);
		scoreBackground.setPosition(scoreboardPos.x, scoreboardPos.y);
		add(scoreBackground);

		var inputsBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), inputsSize.x + 2 * nineSliceBorder,
			inputsSize.y + 2 * nineSliceBorder);
		inputsBackground.offset.set(nineSliceBorder, nineSliceBorder);
		inputsBackground.setPosition(inputsPos.x, inputsPos.y);
		add(inputsBackground);

		var outputBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), outputsSize.x + 2 * nineSliceBorder,
			outputsSize.y + 2 * nineSliceBorder);
		outputBackground.offset.set(nineSliceBorder, nineSliceBorder);
		outputBackground.setPosition(outputsPos.x, outputsPos.y);
		add(outputBackground);

		var scoreLabel = new CyberRed(10 * 32, 32, "score");
		add(scoreLabel);

		var scoreValue = new CyberRed(10 * 32, scoreLabel.y + 16, "00000123");
		add(scoreValue);

		var levelLabel = new CyberRed(10 * 32, scoreValue.y + 32, "network");
		add(levelLabel);

		var levelValue = new CyberRed(10 * 32, levelLabel.y + 16, "       1");
		add(levelValue);

		add(boardBackground);
		add(grid);
		for (column in grid.nodes) {
			for (node in column) {
				add(node);
			}
		}

		for (outputSlot in grid.outputs) {
			for (shape in outputSlot.shapeList) {
				add(shape);
			}
		}

		// Initialize the beginning state of the input shapes
		for (inputSlot in grid.inputs) {
			for (shape in inputSlot.queue) {
				add(shape);
			}
		}
		// Setup signal for future shapes
		Gameplay.onMessageSpawn.add(function(shape:ShapeInputIndicator) {
			add(shape);
		});

		cursor = new Cursor(grid);
		add(cursor);

		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var cam = FlxG.camera;
		// Outputs
		DebugDraw.ME.drawWorldRect(32, 32, 8 * 32, 32);
		// Board
		DebugDraw.ME.drawWorldRect(32, 64, 8 * 32, 8 * 32);
		// Inputs
		DebugDraw.ME.drawWorldRect(32, 32 + 9 * 32, 8 * 32, 4 * 32);
		// Score board
		DebugDraw.ME.drawWorldRect(10 * 32, 32, 4 * 32, 32 * 13);
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
