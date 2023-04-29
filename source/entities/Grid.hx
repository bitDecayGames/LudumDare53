package entities;

import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.FlxG;
import entities.ConnectionTree.LinkedNode;
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

	public var topCorner:FlxPoint;

	var probabilities:Map<NodeType, Float> = [
		Corner => 2,
		Tee => 2,
		Straight => 4,
		Plus => 2,
		OneWay => .5,
		// Warp;
		Dead => .5,
		DoubleCorner => 2,
		Crossover => 2,
	];

	var cachedProbabilityTypes:Array<NodeType> = [];
	var cachedProbabilityValues:Array<Float> = [];

	public function new(gridCellSize:Int, topCorner:FlxPoint, numberOfColumns:Int, numberOfRows:Int, plugins:Array<Plugin>) {
		super();
		this.topCorner = topCorner;
		this.gridCellSize = gridCellSize;
		this.numberOfColumns = numberOfColumns;
		this.numberOfRows = numberOfRows;

		if (cachedProbabilityValues.length == 0) {
			for (key => value in probabilities) {
				cachedProbabilityTypes.push(key);
				cachedProbabilityValues.push(value);
			}
		}

		for (x in 0...numberOfColumns) {
			nodes.push([]);
			for (y in 0...numberOfRows) {
				var chosenType = FlxG.random.getObject(cachedProbabilityTypes, cachedProbabilityValues);
				var newNode = Node.create(chosenType);
				newNode.setPosition(topCorner.x + x * 32, topCorner.y + y * 32);
				nodes[x].push(newNode);
				FlxG.state.add(newNode);
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
		return nodes[x][y];
	}


	/**
	 * Swap the tiles at the given x and y coordinates
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 */
	public function swapTiles(x1:Int, y1:Int, x2:Int, y2:Int) {
		// return immmediately if the coordinates are out of bounds
		if (x1 < 0 || x1 >= numberOfColumns || x2 < 0 || x2 >= numberOfColumns) {
			return;
		}
		if (y1 < 0 || y1 >= numberOfRows || y2 < 0 || y2 >= numberOfRows) {
			return;
		}

		var firstNode = get(x1, y1);
		var secondNode = get(x2, y2);

		nodes[x1][y1] = secondNode;
		nodes[x2][y2] = firstNode;

		// firstNode.setPosition(topCorner.x + x2 * 32, topCorner.y + y2 * 32);
		// secondNode.setPosition(topCorner.x + x1 * 32, topCorner.y + y1 * 32);
		// Like above but animated, use a tween
		FlxTween.linearPath(
			firstNode, 
			[
				FlxPoint.weak(topCorner.x + x1 * 32, topCorner.y + y1 * 32),	
				FlxPoint.weak(topCorner.x + x2 * 32, topCorner.y + y2 * 32)
			], 
			0.12
		);
		FlxTween.linearPath(
			secondNode,
			[
				FlxPoint.weak(topCorner.x + x2 * 32, topCorner.y + y2 * 32),
				FlxPoint.weak(topCorner.x + x1 * 32, topCorner.y + y1 * 32)
			], 
			0.12
		);

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
		var toVisit:Array<Coord> = [new Coord(startX, startY, t.add(get(startX, startY), enter))];
		var visited:Array<Coord> = [];

		// helper vars for efficiency
		var outlets:Array<Cardinal>;
		var v:FlxPoint = FlxPoint.get(0, 0);
		var c:Coord;

		// MW holy shit this is absolute spaghetti code.  I'm sorry for whoever is reading this
		// and thinks they are going to add some logic.  Good luck...
		do {
			c = toVisit.pop();
			// get outputs from the currently visting linked node
			outlets = c.l.node.getOutlets(c.l.enter);
			for (outlet in outlets) {
				// convert the cardinal direction outlet to a new node x,y coordinate
				outlet.asVector(v);
				var curX = c.x + Std.int(v.x);
				var curY = c.y + Std.int(v.y);
				// get the node at that coordinate
				var node = get(curX, curY);
				// get the opposite of the exit of the last node since this is now the new enter
				var e = outlet.opposite();
				// if the node that we are traveling to is facing the wrong way, we don't want to add it
				if (node.getOutlets(e).length > 0) {
					// create the next coord and the linked node to check if it has already been visited
					var n = new Coord(curX, curY, new LinkedNode(node, e));
					if (!visited.contains(n)) {
						// only add the next node to toVist if the node has not already been visited
						c.l.addLinkedNode(n.l);
						toVisit.push(n);
					}
				}
			}
			// be done as soon as there are no more nodes to visit
		} while (toVisit.length > 0);

		return t;
	}
}

/**
 * Tracks the x/y coordinate in the grid, as well as the linkedNode for use in created the ConnectionTree during the traverse method
 */
class Coord {
	public var x:Int;
	public var y:Int;
	public var l:LinkedNode;

	public function new(x:Int, y:Int, l:LinkedNode) {
		this.x = x;
		this.y = y;
		this.l = l;
	}

	public function equals(o:Coord):Bool {
		// check if the x/y coordinates match, then if the nodes are the same object, then if the pathId on the enter is the same, in which case these coords are the "same"
		return x == o.x && y == o.y && l.node == o.l.node && l.node.pathId(l.enter) == o.l.node.pathId(o.l.enter);
	}
}
