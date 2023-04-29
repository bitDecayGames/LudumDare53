package entities;

import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;
import plugins.Plugin;

class Grid extends FlxSprite {
	public var nodes:Array<Array<Node>> = [];
	public var plugins:Array<Plugin> = [];
	public var inputs:Array<InputSlot> = [];
	public var outputs:Array<OutputSlot> = [];

	private var gridCellSize:Int;
	private var numberOfColumns:Int;
	private var numberOfRows:Int;

	public function new(gridCellSize:Int, numberOfColumns:Int, numberOfRows:Int, plugins:Array<Plugin>) {
		super();
		this.gridCellSize = gridCellSize;
		this.numberOfColumns = numberOfColumns;
		this.numberOfRows = numberOfRows;

		for (y in 0...numberOfRows) {
			nodes.push([]);
			for (x in 0...numberOfColumns) {
				nodes[y].push(new Node(gridCellSize));
			}
		}

		for (x in 0...numberOfColumns) {
			inputs.push(new InputSlot());
			outputs.push(new OutputSlot());
		}

		this.plugins = plugins;
		for (i in 0...plugins.length) {
			plugins[i].init(this);
		}

		// TODO: MW set up animation object to handle maybe some subtle grid/background animations
	}

	override public function update(delta:Float) {
		super.update(delta);

		for (i in 0...plugins.length) {
			plugins[i].update(this, delta);
		}
	}

	public function get(x:Int, y:Int):Node {
		if (x < 0 || x >= numberOfColumns) {
			throw 'x is out of bounds, must be between 0 and ${numberOfColumns}';
		}
		if (y < 0 || y >= numberOfRows) {
			throw 'y is out of bounds, must be between 0 and ${numberOfRows}';
		}
		return nodes[y][x];
	}

	/**
	 * Given a start x and y (a node) and the direction you are entering that node from,
	 * return a connection tree of all the connected nodes
	 * @param startX
	 * @param startY
	 * @param enter
	 * @return ConnectionTree
	 */
	public function traverse(startX:Int, startY:Int, enter:Cardinal):ConnectionTree {
		var t = new ConnectionTree();
		var n = get(startX, startY);
		var l = t.add(n, enter);
		return t;
	}
}

class Coord {
	public var x:Int;
	public var y:Int;
	public var enter:Cardinal;

	public function new(x:Int, y:Int, enter:Cardinal) {
		this.x = x;
		this.y = y;
		this.enter = enter;
	}
}
