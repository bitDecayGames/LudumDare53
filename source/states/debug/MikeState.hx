package states.debug;

import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;

using states.FlxStateExt;

class MikeState extends FlxTransitionableState {
	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();
		FlxG.camera.pixelPerfectRender = true;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var cam = FlxG.camera;
		DebugDraw.ME.drawCameraRect(cam.getCenterPoint().x - 5, cam.getCenterPoint().y - 5, 10, 10);
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
