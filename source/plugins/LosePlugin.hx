package plugins;

import entities.Grid;
import signals.Gameplay;

class LosePlugin implements Plugin {
  var shakeInputShapes = false;
  var inputShapesAreAShaking = false;

  public function new() {}

  public function init(grid:Grid) {
    Gameplay.onInputsOverFilled.add(this.beginTheShaking);
    Gameplay.onInputQueueCleaned.add(this.endTheShaking);
  }

  public function update(grid:Grid, delta:Float) {
    if (!shakeInputShapes && inputShapesAreAShaking) {
      for (input in grid.inputs) {
        for (shape in input.queue) {
          if (shape != null) {
            shape.stopShaking();
          }
        }
      }
      inputShapesAreAShaking = false;
    } else if (shakeInputShapes && !inputShapesAreAShaking) {
      for (input in grid.inputs) {
        for (shape in input.queue) {
          if (shape != null) {
            shape.startShaking();
          }
        }
      }
      inputShapesAreAShaking = true;
    }
  }

  private function beginTheShaking() {
    if (shakeInputShapes) {
      trace('YOU LOSE!');
    } else {
      shakeInputShapes = true;
    }
  }

  private function endTheShaking() {
    shakeInputShapes = false;
  }
}