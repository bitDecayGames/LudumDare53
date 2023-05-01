package entities;

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
		if (exits.length == 0) {
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
			node.allNodes(a);
		}
		return a;
	}

	public function fastestPathToLinkedNode(target:Node):Array<LinkedNode> {
		resetDepth();
		return searchForShortestPath([], target);
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
		// trace('returning path with len: ${a.length}');
		// This is a garbage hacky fix
		if (bestPath.length == 1) {
			return this.allNodes([]);
		} else {
			return bestPath;
		}
	}

	private function resetDepth() {
		depth = -1;
		for (node in this.exits) {
			node.resetDepth();
		}
	}
}
