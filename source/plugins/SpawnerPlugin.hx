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
    for (inputSlot in grid.inputs) {
      // Initialize every column with a shape
      inputSlot.addShape(grid, ShapeInputIndicator.newRandom());
		}

		counter = spawnTime;

		changeLevelSpawner();
		Gameplay.onLevelChange.add(this.changeLevelSpawner);
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
	}
}
