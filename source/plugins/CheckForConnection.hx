package plugins;

import signals.Gameplay;
import entities.OutputSlot;
import entities.InputSlot;
import entities.Node;
import entities.Grid;

class CheckForConnectionPlugin implements Plugin {
	public function new() {}

	public function init(grid:Grid) {
		Gameplay.onTurn.add(this.check);
		Gameplay.onRowSlide.add(this.check);
		Gameplay.onSwap.add(this.check);
	}

	public function check() {
		// TODO: MW this check needs the grid
	}

	public function update(grid:Grid, delta:Float) {}
}
