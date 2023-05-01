package plugins;

import haxe.Timer;
import flixel.util.FlxTimer;
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
		// DON'T LOOK AT ME! I'M HIDEOUS!
		for (inSlot in inputs) {
			var inSlotNode = grid.get(inSlot.gridX, inSlot.gridY);
			tree.foreach((l) -> {
				// Find the linked node associated with the input slot
				if (l.node == inSlotNode) {
					var shapeRemoved = false;
					// Search through all output slots
					for (outSlot in outputs) {
						var outSlotNode = grid.get(outSlot.gridX, outSlot.gridY);
						if (inSlot.queue.length > 0 && outSlot.shapeList.length > 0 &&
							inSlot.queue[0].shape == outSlot.shapeList[0].shape) {
								// First time we match inputslot and outputslot shapes remove the input slot shape
								if (!shapeRemoved) {
									var v = inSlot.queue.pop();
									if (v != null) {
										v.kill();
									}
									shapeRemoved = true;
								}

								tree.foreach((m) -> {
									if (m.node == outSlotNode) {
										// Find shortest path to each output slot and remove all
										var linkedNodesToRemove = l.fastestPathToLinkedNode(m.node);
										for (linkedNode in linkedNodesToRemove) {
											linkedNode.node.startBlowupSequence((n) -> {
												new FlxTimer().start(0.5, (t) -> {
													grid.spawnNewNodeAtNode(n);
												});
											});
										}
									}
								});
							}
						}
					}
				});
		}
		
		new FlxTimer().start(1.5, (t) -> {
			FmodManager.PlaySoundOneShot(FmodSFX.AnnouncerGood);
		});
	}

	public function update(grid:Grid, delta:Float) {}
}
