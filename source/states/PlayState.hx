package states;

import plugins.HandleDeliveryPlugin;
import plugins.CheckForConnectionPlugin;
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

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		var scoreLabel = new CyberRed(10 * 32, 32, "score");
		add(scoreLabel);

		var scoreValue = new CyberRed(10 * 32, scoreLabel.y + 16, "00000123");
		add(scoreValue);

		var levelLabel = new CyberRed(10 * 32, scoreValue.y + 32, "network");
		add(levelLabel);

		var levelValue = new CyberRed(10 * 32, levelLabel.y + 16, "       1");
		add(levelValue);

		var grid = new Grid(32, FlxPoint.get(32, 64), 8, 8, [new CheckForConnectionPlugin(), new HandleDeliveryPlugin(),]);
		add(grid);

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
