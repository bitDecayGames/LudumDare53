import entities.ShapeInputIndicator;
import entities.InputSlot;
import flixel.FlxG;
import entities.Grid;

class SpawnerPlugin implements Plugin {
  private static inline var SPAWN_TIME: Float = 30;
  private var counter: Float = 0;

	public function init(grid:Grid) {
    counter = SPAWN_TIME;
  }

	public function update(grid:Grid, delta:Float) {
    counter -= delta;
    if (counter < 0) {
      counter = SPAWN_TIME;
      var inputToAdd: InputSlot = FlxG.random.getObject(grid.inputs);
      inputToAdd.queue.push(ShapeInputIndicator.newRandom());
    }
  }
}