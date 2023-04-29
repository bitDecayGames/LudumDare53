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
