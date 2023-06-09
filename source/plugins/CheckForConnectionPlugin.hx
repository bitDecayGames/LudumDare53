package plugins;

import entities.ConnectionTree;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;
import entities.InputSlot;
import entities.Grid;
import entities.Node;
import entities.OutputSlot;
import signals.Gameplay;

class CheckForConnectionPlugin implements Plugin {
	public function new() {}

	public function init(grid:Grid) {
		Gameplay.onRotate.add(this.check);
		Gameplay.onSwap.add(this.check);
		Gameplay.onRowSlide.add(this.check);
		Gameplay.onGameStart.add(this.check);
		Gameplay.onFinishedBlowingUp.add(this.check);

	}

	#if debug
	var debugTrees:Array<ConnectionTree> = [];
	var forceRefresh = false;
	#end

	public function check(grid:Grid) {
		Gameplay.onNewTreeSearch.dispatch();

		#if debug
		forceRefresh = true;
		debugTrees = [];
		#end

		if (grid == null) {
			return;
		}

		// TODO: filter out inputs that don't have anything in the queue
		var inputs = grid.inputs.map(s -> new InputNode(s, grid.get(s.gridX, s.gridY)));
		var outputs = grid.outputs.map(s -> new OutputNode(s, grid.get(s.gridX, s.gridY)));

		trace("Search for connection");

		// MW: this is horribly inefficient, and it runs on every rotate and swap... sooo....
		var connectedInputsDispatched: Array<Array<InputSlot>> = [];
		for (input in grid.inputs) {
			// for each input slot, traverse the grid from that input space
			var tree = grid.traverse(input.gridX, input.gridY, input.enter);

			// tree.root.color = input.queue[0].shape.getColor();

			#if debug
			debugTrees.push(tree);
			#end

			var leafs = tree.allNodes(); // this isn't just leafs because we found edge cases that a leaf wouldn't be the actual node that touches the input or output
			var connectedInputs:Array<InputSlot> = [input];
			var connectedOutputs:Array<OutputSlot> = [];
			for (leaf in leafs) {
				var outlets = leaf.node.getOutletsForEntrance(leaf.enter);

				for (i in inputs) {
					if (leaf.node == i.node && outlets.contains(i.slot.enter) && i.slot.queue.length > 0 && !connectedInputs.contains(i.slot)) {
						connectedInputs.push(i.slot);
						if (i.slot.queue.length > 0) {
							leaf.color = i.slot.queue[0].shape.getColor();
						}
					}
				}

				for (output in outputs) {
					if (leaf.node == output.node && outlets.contains(output.slot.exit) && output.slot.shapeList.length > 0 && !connectedOutputs.contains(output.slot)) {
						connectedOutputs.push(output.slot);
						if (output.slot.shapeList.length > 0) {
							leaf.color = output.slot.shapeList[0].shape.getColor();
						}
					}
				}
			}

			var duplicateConnectionFound = false;

			for (dispatchedInputs in connectedInputsDispatched) {
				for (dispatchedInput in dispatchedInputs) {
					for (newConnectedInput in connectedInputs) {
						if (newConnectedInput.gridX == dispatchedInput.gridX && newConnectedInput.gridY == dispatchedInput.gridY) {
							duplicateConnectionFound = true;
							break;
						}
					}
					if (duplicateConnectionFound) {
						break;
					}
				}
				if (duplicateConnectionFound) {
					break;
				}
			}
			if (duplicateConnectionFound) {
				continue;
			}

			Gameplay.onTreeResolved.dispatch(connectedInputs, connectedOutputs, tree);

			if (connectedOutputs.length > 0) {
				trace("Found a connection!");

				var connectionMatched = false;
				var numberOfNullConnections = 0;
				for (input in connectedInputs) {
					if (input.queue.length == 0) {
						numberOfNullConnections ++;
						continue;
				}

					for (output in connectedOutputs) {
						if (input.queue.length > 0 && output.shapeList.length > 0 && input.queue[0].shape == output.shapeList[0].shape) {
							connectionMatched = true;
							break;
						}
					}
					if (connectionMatched) {
						break;
					}
				}

				if (numberOfNullConnections < connectedInputs.length) {
					if (!connectionMatched) {
						trace("BAD CONNECTION!!!");
						Gameplay.onBadConnection.dispatch(connectedInputs, connectedOutputs, tree);
					} else {
						Gameplay.onCompleteDelivery.dispatch(connectedInputs, connectedOutputs, tree);
						// XXX - check the grid again to trigger masks to redraw. There is most certainly a better way to do this
						check(grid);
					}
				}
			}
			connectedInputsDispatched.push(connectedInputs);
		}
	}

	#if debug
	var activeTree = 0;
	#end

	public function update(grid:Grid, delta:Float) {

		#if debug
		var showTree = activeTree;
		if (FlxG.keys.justPressed.ONE) {
			showTree = 0;
		} else if (FlxG.keys.justPressed.TWO) {
			showTree = 1;
		} else if (FlxG.keys.justPressed.THREE) {
			showTree = 2;
		} else if (FlxG.keys.justPressed.FOUR) {
			showTree = 3;
		} else if (FlxG.keys.justPressed.FIVE) {
			showTree = 4;
		} else if (FlxG.keys.justPressed.SIX) {
			showTree = 5;
		} else if (FlxG.keys.justPressed.SEVEN) {
			showTree = 6;
		} else if (FlxG.keys.justPressed.EIGHT) {
			showTree = 7;
		} else if (FlxG.keys.justPressed.NINE) {
			DebugDraw.ME.clearPersistentCalls();
		}

		if (activeTree != showTree || forceRefresh) {
			forceRefresh = false;
			trace('drawing tree ${showTree}');
			activeTree = showTree;
			DebugDraw.ME.clearPersistentCalls();
			debugTrees[activeTree].degugDraw();
		}
		#end
	}
}

class InputNode {
	public var node:Node;
	public var slot:InputSlot;

	public function new(slot:InputSlot, node:Node) {
		this.slot = slot;
		this.node = node;
	}
}

class OutputNode {
	public var node:Node;
	public var slot:OutputSlot;

	public function new(slot:OutputSlot, node:Node) {
		this.slot = slot;
		this.node = node;
	}
}
