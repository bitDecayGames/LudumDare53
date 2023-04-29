package plugins;

import entities.Grid;

interface Plugin {
	public function init(grid:Grid):Void;
	public function update(grid:Grid, delta:Float):Void;
}
