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
		for (slot in inputs) {
			var v = slot.queue.pop();
			if (v != null) {
				v.kill();
			}
		}

		// for each node, mark it as shouldBlowUp so that something else can blow it up when it is time
		tree.foreach((l) -> {
			l.node.startBlowupSequence((n) -> {
				new FlxTimer().start(0.5, (t) -> {
					grid.spawnNewNodeAtNode(n);
				});
			});
		});
		
		new FlxTimer().start(1.5, (t) -> {
			FmodManager.PlaySoundOneShot(FmodSFX.AnnouncerGood);
		});
	}

	public function update(grid:Grid, delta:Float) {}
}
