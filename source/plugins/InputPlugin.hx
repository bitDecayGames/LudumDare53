package plugins;

import entities.Grid;
import input.InputCalcuator;
import input.SimpleController;

class InputPlugin implements Plugin {
	public function new() {}

	public function init(grid:Grid) {}

	public function update(grid:Grid, delta:Float) {
		// TODO: MW check for player input on rotate button and call rotate signal
		// TODO: MW check for player input hold button and select cardinal direction, and call swap signal

		var inputDir = InputCalcuator.getInputCardinal(0);
		if (inputDir != NONE) {
			// inputDir.asVector(velocity).scale(speed);
		} else {
			// velocity.set();
		}

		if (SimpleController.just_pressed(Button.A, 0)) {
			// color = color ^ 0xFFFFFF;
		}
	}
}
