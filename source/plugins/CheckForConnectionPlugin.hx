package plugins;

import signals.Gameplay;
import entities.Grid;

class CheckForConnectionPlugin implements Plugin {
	public function new() {}

	public function init(grid:Grid) {
		Gameplay.onRotate.add(this.check);
		Gameplay.onRowSlide.add(this.check);
		Gameplay.onSwap.add(this.check);
	}

	public function check() {
		// TODO: MW this check needs the grid
	}

	public function update(grid:Grid, delta:Float) {}
}
