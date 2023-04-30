package plugins;

import entities.ShapeInputIndicator;
import entities.InputSlot;
import flixel.FlxG;
import entities.Grid;

class SpawnerPlugin implements Plugin {
	private var spawnTime:Float = 30;
	private var counter:Float = 0;

	public function new() {}

	public function init(grid:Grid) {
    for (inputSlot in grid.inputs) {
      // Initialize every column with a shape
      inputSlot.addShape(grid, ShapeInputIndicator.newRandom());
		}

		counter = spawnTime;
	}

	public function update(grid:Grid, delta:Float) {
		counter -= delta;
		if (counter < 0) {
			counter = spawnTime;
			var inputToAdd:InputSlot = FlxG.random.getObject(grid.inputs);
			inputToAdd.addShape(grid, ShapeInputIndicator.newRandom());
		}
	}

	public function setSpawnTime(newTime: Float) {
		if (newTime > 0) {
			spawnTime = newTime;
		}
	}
}
