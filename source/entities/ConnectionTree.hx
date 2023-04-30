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
			var cur = toVisit.pop();
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
}
