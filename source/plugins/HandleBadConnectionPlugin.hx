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

class HandleBadConnectionPlugin implements Plugin {
	var grid:Grid;

	public function new() {}

	public function init(grid:Grid) {
		this.grid = grid;
		Gameplay.onBadConnection.add(this.handleBadConnection);
	}

	public function handleBadConnection(inputs:Array<InputSlot>, outputs:Array<OutputSlot>, tree:ConnectionTree) {
		// for each node, mark it as shouldBlowUp so that something else can blow it up when it is time
		tree.foreach((l) -> {
			l.node.startBadConnectionSequence();
		});

		// TODO SFX: Bad connection was made (no points scored)
	}

	public function update(grid:Grid, delta:Float) {}
}
