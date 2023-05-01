package plugins;

import entities.ShapeInputIndicator;
import entities.ShapeOutputIndicator;
import entities.InputSlot;
import entities.OutputSlot;
import flixel.FlxG;
import entities.Grid;
import signals.Gameplay;
import levels.LevelConfig;

class SpawnerPlugin implements Plugin {
	private var spawnTime:Float = 30;
	private var counter:Float = 0;
	private var grid: Grid;

	public function new() {}

	public function init(grid:Grid) {
		this.grid = grid;

		changeLevelSpawner();
		Gameplay.onLevelChange.add(this.changeLevelSpawner);
	}

	public function update(grid:Grid, delta:Float) {
		counter -= delta;
		if (counter < 0) {
			counter = spawnTime;

			var spawnsLeft = false;
			for(input in grid.inputs) {
				if (input.queue.length < 4) {
					spawnsLeft = true;
				}
			}

			if (spawnsLeft) {
				var inputToAdd:InputSlot = FlxG.random.getObject(grid.inputs);
				while (inputToAdd.queue.length >= 4) {
					inputToAdd = FlxG.random.getObject(grid.inputs);
				}	
				inputToAdd.addShape(grid, ShapeInputIndicator.newRandom());
			} else {
				trace('OH NO WERE OUT OF INPUTS');
			}
		}
	}

	private function setSpawnTime(newTime: Float) {
		if (newTime > 0) {
			spawnTime = newTime;
			counter = spawnTime;
		}
	}

	public function changeLevelSpawner() {
		for (output in this.grid.outputs) {
			var shape = output.shapeList.pop();
			if (shape != null) {
				shape.kill();
			}
		}

		var shapesInLevel = LevelConfig.currentLevelConfig().shapes;
		var outputIndexToGenerate:Array<Int> = [];
		while (outputIndexToGenerate.length < shapesInLevel.length) {
				var random:Int = Math.floor(Math.random() * shapesInLevel.length + 1);
				if (outputIndexToGenerate.indexOf(random) == -1) {
						outputIndexToGenerate.push(random);
				}
		}

		var shapeToAdd = 0;
		for (gridX in outputIndexToGenerate) {
			this.grid.outputs[gridX].addShape(this.grid, new ShapeOutputIndicator(shapesInLevel[shapeToAdd]));
			shapeToAdd++;
		}

		for (inputSlot in grid.inputs) {
      // Initialize every column with a shape
			if (inputSlot.queue.length == 0) {
				inputSlot.addShape(grid, ShapeInputIndicator.newRandom());
			}
		}

		setSpawnTime(LevelConfig.currentLevelConfig().spawnRate);
	}
}
