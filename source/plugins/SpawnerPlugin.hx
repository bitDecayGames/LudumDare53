package plugins;

import bitdecay.flixel.spacial.Cardinal;
import entities.ShapeInputIndicator;
import entities.InputSlot;
import flixel.FlxG;
import entities.Grid;
import signals.Gameplay;

class SpawnerPlugin implements Plugin {
	private static inline var SPAWN_TIME:Float = 5;

	private var counter:Float = 0;

	public function new() {}

	public function init(grid:Grid) {
		for (inputSlot in grid.inputs) {
			// Initialize every column with a shape
			addShape(grid, inputSlot, ShapeInputIndicator.newRandom());
		}

		counter = SPAWN_TIME;
	}

	public function update(grid:Grid, delta:Float) {
		counter -= delta;
		if (counter < 0) {
			counter = SPAWN_TIME;
			var inputToAdd:InputSlot = FlxG.random.getObject(grid.inputs);
			addShape(grid, inputToAdd, ShapeInputIndicator.newRandom());
		}
	}

	// TODO: JF make sure the shape we're adding has an output
	private function addShape(grid:Grid, inputSlot:InputSlot, shape:ShapeInputIndicator) {
		var newShapeIndex = inputSlot.queue.length;
		inputSlot.queue.push(shape);
		shape.setPosition(grid.topCorner.x + inputSlot.gridX * 32, grid.topCorner.y + (inputSlot.gridY + newShapeIndex + 1) * 32);
		Gameplay.onSpawn.dispatch(shape);
	}
}
