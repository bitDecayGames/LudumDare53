package plugins;

import flixel.FlxG;
import entities.ConnectionTree;
import entities.InputSlot;
import entities.Grid;
import entities.Node;
import entities.OutputSlot;
import signals.Gameplay;

class HandleDeliveryPlugin implements Plugin {
	var grid:Grid;

	public function new() {}

	public function init(grid:Grid) {
		this.grid = grid;
		Gameplay.onCompleteDelivery.add(this.handleDelivery);
	}

	public function handleDelivery(inputs:Array<InputSlot>, outputs:Array<OutputSlot>, tree:ConnectionTree) {
		for (slot in inputs) {
			// TODO: MW for each input, we need to decide if it was successful or not
			slot.queue.pop();
		}

		// for each node, mark it as shouldBlowUp so that something else can blow it up when it is time
		tree.foreach((l) -> {
			l.node.startBlowupSequence((n) -> {
				grid.spawnNewNodeAtNode(n);
			});
		});
	}

	public function update(grid:Grid, delta:Float) {}
}
