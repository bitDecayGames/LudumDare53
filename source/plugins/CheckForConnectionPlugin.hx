package plugins;

import entities.InputSlot;
import entities.Grid;
import entities.Node;
import entities.OutputSlot;
import signals.Gameplay;

class CheckForConnectionPlugin implements Plugin {
	public function new() {}

	public function init(grid:Grid) {
		Gameplay.onRotate.add(this.check);
		Gameplay.onRowSlide.add(this.check);
		Gameplay.onSwap.add(this.check);
	}

	public function check(grid:Grid) {
		var inputs = grid.inputs.map(s -> new InputNode(s, grid.get(s.gridX, s.gridY)));
		var outputs = grid.outputs.map(s -> new OutputNode(s, grid.get(s.gridX, s.gridY)));

		// MW: this is horribly inefficient, and it runs on every rotate and swap... sooo....
		for (input in grid.inputs) {
			var tree = grid.traverse(input.gridX, input.gridY, input.enter);
			var leafs = tree.leafs();
			var connectedOutputs:Array<OutputSlot> = [];
			var connectedInputs:Array<InputSlot> = [input];
			for (leaf in leafs) {
				var outlets = leaf.node.getOutlets(leaf.enter);

				for (i in inputs) {
					if (leaf.node == i.node && outlets.contains(i.slot.enter) && !connectedInputs.contains(i.slot)) {
						connectedInputs.push(i.slot);
					}
				}

				for (output in outputs) {
					if (leaf.node == output.node && outlets.contains(output.slot.exit) && !connectedOutputs.contains(output.slot)) {
						connectedOutputs.push(output.slot);
					}
				}
			}
			if (connectedOutputs.length > 0) {
				Gameplay.onCompleteDelivery.dispatch(connectedInputs, connectedOutputs, tree);
			}
		}
	}

	public function update(grid:Grid, delta:Float) {}
}

class InputNode {
	public var node:Node;
	public var slot:InputSlot;

	public function new(slot:InputSlot, node:Node) {
		this.slot = slot;
		this.node = node;
	}
}

class OutputNode {
	public var node:Node;
	public var slot:OutputSlot;

	public function new(slot:OutputSlot, node:Node) {
		this.slot = slot;
		this.node = node;
	}
}
