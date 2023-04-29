package states;

import achievements.Achievements;
import bitdecay.flixel.debug.DebugDraw;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
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
