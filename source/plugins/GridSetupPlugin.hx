package plugins;

import entities.OutputSlot;
import entities.InputSlot;
import entities.Node;
import entities.Grid;

class GridSetupPlugin implements Plugin {
	var width:Int;
	var height:Int;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
	}

	public function init(grid:Grid) {
		for (y in 0...height) {
			grid.nodes.push([]);
			for (x in 0...width) {
				grid.nodes[y].push(new Node());
			}
		}

		for (x in 0...width) {
			grid.inputs.push(new InputSlot());
			grid.outputs.push(new OutputSlot());
		}
	}

	public function update(grid:Grid, delta:Float) {}
}
