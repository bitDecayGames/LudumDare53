package entities;

import flixel.FlxBasic;
import signals.Gameplay;
import entities.IOEnums.IOColor;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.FlxG;
import entities.ConnectionTree.LinkedNode;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;
import plugins.Plugin;
import levels.LevelConfig;

class Grid extends FlxBasic {
	public var nodes:Array<Array<Node>> = [];
	public var plugins:Array<Plugin> = [];
	public var inputs:Array<InputSlot> = [];
	public var outputs:Array<OutputSlot> = [];

	public var gridCellSize:Int;
	public var numberOfColumns:Int;
	public var numberOfRows:Int;

	public var topCorner:FlxPoint;

	private function getRandomNodeTypeForLocation(x:Int, y:Int, avoidTypes:Array<NodeType>):NodeType {
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

		var probabilitiesForLocation:Map<NodeType, Float> = LevelConfig.currentLevelConfig().probs.copy();


		if (isLocationInOutputOrInput) {
			// Make DEAD nodes probability 0
			probabilitiesForLocation.set(NodeType.Dead, 0);
		}

		for (i in 0...avoidTypes.length) {
			probabilitiesForLocation.set(avoidTypes[i], 0);
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
		#if testboard
		inputs[0].addShape(this, new ShapeInputIndicator(Club));
		inputs[1].addShape(this, new ShapeInputIndicator(Spade));
		inputs[2].addShape(this, new ShapeInputIndicator(Diamond));
		inputs[3].addShape(this, new ShapeInputIndicator(Diamond));
		inputs[4].addShape(this, new ShapeInputIndicator(Diamond));
		inputs[5].addShape(this, new ShapeInputIndicator(Spade));
		inputs[6].addShape(this, new ShapeInputIndicator(Heart));
		inputs[7].addShape(this, new ShapeInputIndicator(Spade));

		outputs[0].addShape(this, new ShapeOutputIndicator(Spade));
		outputs[1].addShape(this, new ShapeOutputIndicator(Heart));
		outputs[2].addShape(this, new ShapeOutputIndicator(Diamond));
		outputs[3].addShape(this, new ShapeOutputIndicator(Club));
		#end

		#if staticboard
		for (x in 0...numberOfColumns) {
			nodes.push([]);
			for (y in 0...numberOfRows) {
				if (y == 0 || y == numberOfRows-1) {
					nodes[x].push(spawnNewNodeOfTypeAtPosition(x, y, StraightStatic));
				} else {
					nodes[x].push(spawnNewNodeOfTypeAtPosition(x, y, Plus));
				}
			}
		}
		#elseif testboard
		makeColumn(0,[Straight,Straight,Corner,Tee,Straight,Plus,Plus,Straight],
					[0,1,2,1,0,0,0,1]);
		makeColumn(1,[Corner,Plus,Straight,Straight,Corner,Straight,Crossover,Straight],
					[2,0,0,1,0,1,1,1]);
		makeColumn(2,[Tee,Crossover,Plus,Crossover,Corner,Straight,Tee,Straight],
					[1,0,0,1,0,0,0,0]);
		makeColumn(3,[Straight,Straight,Plus,Straight,Straight,Corner,Straight, Crossover],
					[1,1,0,0,1,1,0,0]);
		makeColumn(4,[Corner,Plus,Plus,Crossover,Plus,Plus,Crossover,Corner],
					[3,0,0,0,0,0,1,3]);
		makeColumn(5,[Plus,Straight,Tee,Tee,Crossover,Crossover,Plus,Straight],
					[0,0,3,3,1,1,0,0]);
		makeColumn(6,[Corner,Tee,Crossover,Crossover,Corner,Straight,Tee,Straight],
					[2,0,0,1,2,0,0,1]);
		makeColumn(7,[Crossover,Plus,Corner,Straight,Straight,Tee,Crossover,Crossover],
					[1,0,1,0,0,3,0,1]);
		#else
			for (x in 0...numberOfColumns) {
				nodes.push([]);
				for (y in 0...numberOfRows) {
					nodes[x].push(spawnNewNodeAtPosition(x, y, []));
				}
			}
		#end

		for (nodesX in nodes) {
			for (node in nodesX) {
				// trace(node.nodeType, node.x, node.y);
			}
		}

		this.plugins = plugins;
		for (i in 0...plugins.length) {
			plugins[i].init(this);
		}

		// TODO: MW set up animation object to handle maybe some subtle grid/background animations
	}

	private function makeColumn(num:Int, pieces:Array<NodeType>, rots:Array<Int>) {
		var column = [for (i in 0...pieces.length) {
			// spawnNewNodeOfTypeAtPosition(num, pieces.length - i - 1, pieces[i], rots[i]);
			spawnNewNodeOfTypeAtPosition(num, i, pieces[i], rots[i]);
		}];
		// column.reverse();
		nodes.push(column);
	}

	public function spawnNewNodeAtPosition(x:Int, y:Int, avoidTypes:Array<NodeType>):Node {
		var chosenType = getRandomNodeTypeForLocation(x, y, avoidTypes);
		var newNode = Node.create(chosenType);
		newNode.originalOffset.copyFrom(topCorner);
		newNode.gridX = x;
		newNode.gridY = y;
		newNode.setPosition(topCorner.x + x * 32, topCorner.y + y * 32);
		Gameplay.onNodeSpawn.dispatch(newNode);
		return newNode;
	}

	public function spawnNewNodeOfTypeAtPosition(x:Int, y:Int, chosenType:NodeType, rotation:Int = -1):Node {
		var newNode = Node.create(chosenType, rotation);
		newNode.gridX = x;
		newNode.gridY = y;
		newNode.setPosition(topCorner.x + x * 32, topCorner.y + y * 32);
		Gameplay.onNodeSpawn.dispatch(newNode);
		return newNode;
	}

	public function spawnNewNodeAtNode(n:Node):Node {
		for (x in 0...numberOfColumns) {
			for (y in 0...numberOfRows) {
				if (nodes[x][y] == n) {
					var newNode = spawnNewNodeAtPosition(x, y, [NodeType.Dead]);
					nodes[x][y] = newNode;
					return newNode;
				}
			}
		}
		return null;
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
            FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
			return false;
		}
		if (y1 < 0 || y1 >= numberOfRows || y2 < 0 || y2 >= numberOfRows) {
            FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
			return false;
		}

		var firstNode = get(x1, y1);
		var secondNode = get(x2, y2);

		// only allow swap if the node is mobile
		if (!firstNode.isMobile() || !secondNode.isMobile()) {
            FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
			return false;
		}

		nodes[x1][y1] = secondNode;
		nodes[x2][y2] = firstNode;

		tweenTileSwap(firstNode, secondNode, () -> {
			firstNode.gridX = x2;
			firstNode.gridY = y2;
			secondNode.gridX = x1;
			secondNode.gridY = y1;
			cb();
		});
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

	public function getNumberOfColumns():Int {
		return numberOfColumns;
	}

	public function getNumberOfRows():Int {
		return numberOfRows;
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
		// var initialOutletCheck = enter.opposite();
		var node = get(startX, startY);
		if (node.getOutletsForEntrance(enter).length == 0) {
			// we can't traverse from the start node by entering this direction. There is no tree.
			return t;
		}

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
			c = toVisit.shift();
			visited.push(c);
			// get outputs from the currently visting linked node
			outlets = c.l.node.getOutletsForEntrance(c.l.enter);
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
				var enterDir = outlet.opposite();

				// if the node that we are traveling to is facing the wrong way, we don't want to add it
				if (node.getOutletsForEntrance(enterDir).length > 0) {
					// create the next coord and the linked node to check if it has already been visited
					var n = new Coord(curX, curY, new LinkedNode(node, enterDir));
					// add our back-reference to allow traversal in reverse
					n.l.addLinkedNode(c.l);
					if (!Coord.contains(visited, n) && !Coord.contains(toVisit, n)) {
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
