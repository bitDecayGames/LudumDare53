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
		// Corner => 2,
		// Tee => 2,
		Straight => 4,
		// Plus => 2,
		// OneWay => .5,
		// Warp;
		// Dead => 1,
		// DoubleCorner => 2,
		// Crossover => 2,
	];

	private function getRandomNodeTypeForLocation(x:Int, y:Int):NodeType {
		var probabilitieTypes:Array<NodeType> = [];
		var probabilityValues:Array<Float> = [];

		var isLocationInOutputOrInput = false;
		for (i in 0...inputs.length) {
			var input = inputs[i];
			if (input.gridX == x && input.gridY == y) {
				isLocationInOutputOrInput = true;
				break;
			}
		}
		for (i in 0...outputs.length) {
			if (outputs[i].gridX == x && outputs[i].gridY == y) {
				isLocationInOutputOrInput = true;
				break;
			}
		}

		var probabilitiesForLocation:Map<NodeType, Float> = probabilities.copy();
		if (isLocationInOutputOrInput) {
			// Make DEAD nodes probability 0
			probabilitiesForLocation.set(NodeType.Dead, 0);
		}

		for (key in probabilitiesForLocation.keys()) {
			probabilitieTypes.push(key);
			probabilityValues.push(probabilitiesForLocation.get(key));
		}

		return FlxG.random.getObject(probabilitieTypes, probabilityValues);
	}

	public function new(gridCellSize:Int, topCorner:FlxPoint, numberOfColumns:Int, numberOfRows:Int, plugins:Array<Plugin>) {
		super();
		this.topCorner = topCorner;
		this.gridCellSize = gridCellSize;
		this.numberOfColumns = numberOfColumns;
		this.numberOfRows = numberOfRows;

		// TODO: MW: we could move this logic into a plugin so that we could configure the inputs and outputs separately
		for (x in 0...numberOfColumns) {
			inputs.push(new InputSlot(x, numberOfRows - 1, Cardinal.S));
			outputs.push(new OutputSlot(x, 0, Cardinal.N));
		}

		for (x in 0...numberOfColumns) {
			nodes.push([]);
			for (y in 0...numberOfRows) {
				var chosenType = getRandomNodeTypeForLocation(x, y);
				var newNode = Node.create(chosenType);
				newNode.setPosition(topCorner.x + x * 32, topCorner.y + y * 32);
				nodes[x].push(newNode);
			}
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
			return null;
			// throw 'x is out of bounds, must be between 0 and ${numberOfColumns - 1}: ${x}';
		}
		if (y < 0 || y >= numberOfRows) {
			return null;
			// throw 'y is out of bounds, must be between 0 and ${numberOfRows - 1}: ${y}';
		}
		return nodes[x][y];
	}

	/**
	 * Swap the tiles at the given x and y coordinates
	 */
	public function swapTiles(x1:Int, y1:Int, x2:Int, y2:Int, ?cb:() -> Void):Bool {
		// return immmediately if the coordinates are out of bounds
		if (x1 < 0 || x1 >= numberOfColumns || x2 < 0 || x2 >= numberOfColumns) {
			return false;
		}
		if (y1 < 0 || y1 >= numberOfRows || y2 < 0 || y2 >= numberOfRows) {
			return false;
		}

		var firstNode = get(x1, y1);
		var secondNode = get(x2, y2);

		// only allow swap if the node is mobile
		if (!firstNode.isMobile() || !secondNode.isMobile()) {
			return false;
		}

		nodes[x1][y1] = secondNode;
		nodes[x2][y2] = firstNode;

		tweenTileSwap(firstNode, secondNode, cb);
		tweenTileSwap(secondNode, firstNode, cb);

		return true;
	}

	public function tweenTileSwap(firstNode:Node, secondNode:Node, ?cb:() -> Void) {
		FlxTween.linearPath(firstNode, [
			FlxPoint.weak(firstNode.x, firstNode.y),
			FlxPoint.weak(secondNode.x, secondNode.y)
		], 0.12, true, {
			onComplete: (t) -> {
				if (cb != null) {
					cb();
				}
			}
		});
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

		// be done as soon as there are no more nodes to visit
		while (toVisit.length > 0) {
			c = toVisit.pop();
			visited.push(c);
			// get outputs from the currently visting linked node
			outlets = c.l.node.getOutlets(c.l.enter);
			for (outlet in outlets) {
				// convert the cardinal direction outlet to a new node x,y coordinate
				outlet.asVector(v);
				var curX = c.x + Std.int(v.x);
				var curY = c.y + Std.int(v.y);
				// get the node at that coordinate
				var node = get(curX, curY);
				if (node == null) {
					continue; // not exactly sure what causes this to happen
				}
				// get the opposite of the exit of the last node since this is now the new enter
				var e = outlet.opposite();

				// if the node that we are traveling to is facing the wrong way, we don't want to add it
				if (node.getOutlets(e).length > 0) {
					// create the next coord and the linked node to check if it has already been visited
					var n = new Coord(curX, curY, new LinkedNode(node, e));
					if (!Coord.contains(visited, n)) {
						// only add the next node to toVist if the node has not already been visited
						c.l.addLinkedNode(n.l);
						toVisit.push(n);
					}
				}
			}
		}

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

	public static function contains(array:Array<Coord>, value:Coord):Bool {
		for (i in 0...array.length) {
			if (Coord.equals(array[i], value)) {
				return true;
			}
		}
		return false;
	}

	public static function equals(a:Coord, b:Coord):Bool {
		return a.x == b.x && a.y == b.y && a.l.node == b.l.node && a.l.node.pathId(a.l.enter) == b.l.node.pathId(b.l.enter);
	}
}
