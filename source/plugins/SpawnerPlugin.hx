package plugins;

import entities.ShapeInputIndicator;
import entities.InputSlot;
import flixel.FlxG;
import entities.Grid;

class SpawnerPlugin implements Plugin {
	private static inline var SPAWN_TIME:Float = 5;

	private var counter:Float = 0;

	public function new() {}

	public function init(grid:Grid) {
    for (inputSlot in grid.inputs) {
      // Initialize every column with a shape
      inputSlot.addShape(grid, ShapeInputIndicator.newRandom());
		}

		counter = SPAWN_TIME;
	}

	public function update(grid:Grid, delta:Float) {
		counter -= delta;
		if (counter < 0) {
			counter = SPAWN_TIME;
			var inputToAdd:InputSlot = FlxG.random.getObject(grid.inputs);
			inputToAdd.addShape(grid, ShapeInputIndicator.newRandom());
		}
	}
}
