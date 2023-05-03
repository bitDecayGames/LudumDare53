package entities;

import flixel.util.FlxColor;
import bitdecay.flixel.debug.DebugDraw;
import bitdecay.flixel.spacial.Cardinal;

class ConnectionTree {
	public var root:LinkedNode;

	public function new() {}

	public function leafs():Array<LinkedNode> {
		if (root == null)
			return [];
		return root.leafs();
	}

	public function allNodes():Array<LinkedNode> {
		if (root == null)
			return [];
		return root.allNodes([]);
	}

	public function add(node:Node, enter:Cardinal):LinkedNode {
		if (root == null) {
			root = new LinkedNode(node, enter);
			return root;
		}
		return root.add(node, enter);
	}

	public function foreach(f:LinkedNode->Void) {
		if (root == null || f == null)
			return;
		var toVisit:Array<LinkedNode> = [root];
		var visited:Array<LinkedNode> = [];
		while (toVisit.length > 0) {
			var cur = toVisit.shift();
			f(cur);
			for (node in cur.exits) {
				if (!visited.contains(node)) {
					toVisit.push(node);
				}
			}
			visited.push(cur);
		}
	}

	#if debug
	public function degugDraw(colorOverride:Int = 0) {
		if (root == null || root.node == null) {
			trace('no root to debug');
			return;
		}
		var visited:Array<LinkedNode> = [];
		DebugDraw.ME.drawWorldRect(root.node.x + 3, root.node.y + 3, root.node.width - 6, root.node.height - 6, true);
		debugDrawNode(visited, root, colorOverride);

		for (leaf in leafs()) {
			debugDrawNode(visited, leaf, 0x000001);
		}
	}

	private function debugDrawNode(visited:Array<LinkedNode>, ln:LinkedNode, colorOverride:Int = 0) {
		if (!visited.contains(ln)) {
			visited.push(ln);
		}

		var nodeColor = colorOverride != 0 ? colorOverride : ln.node.masks[ln.node.pathId(ln.enter) - 1].color;
		DebugDraw.ME.drawWorldRect(ln.node.x + 6, ln.node.y + 6, ln.node.width - 12, ln.node.height - 12, nodeColor, true);
		DebugDraw.ME.drawWorldRect(ln.node.x + 12, ln.node.y + 12, ln.node.width - 24, ln.node.height - 24, ln.color, true);
		if (ln.partOfBreak) {
			DebugDraw.ME.drawWorldRect(ln.node.x + 14, ln.node.y + 14, ln.node.width - 28, ln.node.height - 28, 0xCB491A, true);

		}
		var startCenter = ln.node.getMidpoint();
		for (exitNode in ln.exits) {
			// var linkColor = exitNode.node.masks[exitNode.node.pathId(exitNode.enter)].color;
			// Render link color and then recursively call for all exit nodes
			if (!visited.contains(exitNode)) {
				var endCenter = exitNode.node.getMidpoint();
				DebugDraw.ME.drawWorldLine(startCenter.x, startCenter.y, endCenter.x, endCenter.y, 0xFFFFFF, true);
				endCenter.put();
				debugDrawNode(visited, exitNode, colorOverride);
			}
		}
		startCenter.put();
	}
	#end

	public function toString():String {
		var count = 0;
		foreach((n) -> {
			count++;
		});
		return 'treeLen:${count}';
	}
}

class LinkedNode {
	public var node:Node;
	public var enter:Cardinal = Cardinal.N;
	public var exits:Array<LinkedNode> = [];

	private var depth:Int;
	public var partOfBreak:Bool = false;
	public var color:FlxColor = 0xFFFFFF;



	public function new(node:Node, enter:Cardinal) {
		this.node = node;
		this.enter = enter;
	}

	public function add(node:Node, enter:Cardinal):LinkedNode {
		var n = new LinkedNode(node, enter);
		exits.push(n);
		return n;
	}

	public function addLinkedNode(l:LinkedNode):LinkedNode {
		exits.push(l);
		return l;
	}

	public function leafs():Array<LinkedNode> {
		if (exits.length  <= 1) {
			return [this];
		}
		var v:Array<LinkedNode> = [];
		for (exit in exits) {
			var arr = exit.leafs();
			for (leaf in arr) {
				if (!v.contains(leaf)) {
					v.push(leaf);
				}
			}
		}
		return v;
	}

	public function allNodes(a:Array<LinkedNode>):Array<LinkedNode> {
		a.push(this);
		for (node in this.exits) {
			if (!a.contains(node)) {
				node.allNodes(a);
			}
		}
		return a;
	}

	public function fastestPathToLinkedNode(target:Node):Array<LinkedNode> {
		resetDepth();
		var result = searchForShortestPath([], target);
		if (result.length == 1) {
			// Something bad happened here... I don't think we should ever have a single node path
			return allNodes([]);
		}
		return result;
	}

	/**
	 * I have no clue if this actually works, I'm barely awake.  Good luck boys.
	 * @param a
	 * @param to
	 * @return Array<LinkedNode>
	 */
	private function searchForShortestPath(a:Array<LinkedNode>, to:Node):Array<LinkedNode> {
		// trace('looking at node: ${this}');
		// trace(' -- trying to find ${to}');
		// trace(' -- current a len: ${a.length}');
		a.push(this);
		if (this.node == to) {
			// trace('yo! I found the thing!');
			return a;
		}
		var bestLen = -1;
		var bestPath = a;
		for (node in this.exits) {
			if (!a.contains(node)) {
				var b = node.searchForShortestPath(a.copy(), to);
				if ((bestLen == -1 || b.length < bestLen) && b[b.length - 1].node == to) {
					// trace('updating path');
					// trace('path len: ${b.length}');
					bestLen = b.length;
					bestPath = b;
				}
			}
		}

		return bestPath;
	}

	private function resetDepth() {
		depth = -1;
		// for (node in this.exits) {
		// 	node.resetDepth();
		// }
	}
}
