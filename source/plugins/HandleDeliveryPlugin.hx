package plugins;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import bitdecay.flixel.debug.DebugDraw;
import input.SimpleController;
import flixel.util.FlxTimer;
import entities.ConnectionTree;
import entities.InputSlot;
import entities.Grid;
import entities.OutputSlot;
import signals.Gameplay;

class HandleDeliveryPlugin implements Plugin {
	var grid:Grid;

	public function new() {}

	public function init(grid:Grid) {
		this.grid = grid;
		Gameplay.onCompleteDelivery.add(this.handleDelivery);
	}

	#if debug
	var breakHistory:Array<ConnectionTree> = [];
	#end

	public function handleDelivery(inputs:Array<InputSlot>, outputs:Array<OutputSlot>, tree:ConnectionTree) {
		// DON'T LOOK AT ME! I'M HIDEOUS!
		var completeInputXs: Map<Int, Int> = [];
		var completeOutputXs: Map<Int, Int> = [];
		var messageSuccessfullySent = false;
		for (inSlot in inputs) {
			var inSlotNode = grid.get(inSlot.gridX, inSlot.gridY);
			var shapeRemoved = false;
			tree.foreach((l) -> {
				// Find the linked node associated with the input slot
				if (l.node == inSlotNode) {
					// Search through all output slots
					for (outSlot in outputs) {
						var outSlotNode = grid.get(outSlot.gridX, outSlot.gridY);
						if (inSlot.queue.length > 0 && outSlot.shapeList.length > 0 &&
							inSlot.queue[0].shape == outSlot.shapeList[0].shape) {
								// First time we match inputslot and outputslot shapes remove the input slot shape
								var shapeSprite:FlxSprite = null;
								if (!shapeRemoved) {
									var slotToRemoveFrom = inSlot;
									shapeSprite = slotToRemoveFrom.removeShape(grid);
									shapeRemoved = true;
								}

								#if debug
								breakHistory.insert(0, tree);
								#end

								tree.foreach((m) -> {
									if (m.node == outSlotNode) {
										// Find shortest path to each output slot and remove all
										var linkedNodesToRemove = l.fastestPathToLinkedNode(m.node);
										var path:Array<FlxPoint> = [];

										if (shapeSprite != null) {
											path.push(shapeSprite.getPosition());
										}

										for (linkedNode in linkedNodesToRemove) {
											if (shapeSprite != null) {
												// TODO: Build these based on the actual node pipe configurations
												var point = linkedNode.node.getMidpoint();
												point.subtract(shapeSprite.width/2, shapeSprite.height/2);
												path.push(point);
											}
											linkedNode.partOfBreak = true;
											linkedNode.node.locked = true;
											linkedNode.node.color = FlxColor.GRAY;
										}
										path.push(outSlotNode.getPosition());
										if (shapeSprite != null) {
											path[path.length-1].add(16, -16);
											path[path.length-1].subtract(shapeSprite.width/2, shapeSprite.height/2);
										}

										if (shapeSprite != null) {
											FlxTween.linearPath(shapeSprite, path, linkedNodesToRemove.length * 0.2, {
												onComplete: (t) -> {
													// TODO: Some sort of effect?
													shapeSprite.kill();
													for (node in linkedNodesToRemove) {
														// TODO: We only want to blow up nodes that don't have more pieces on their way.
														// OR we can just wait to blow up the pipes until ALL pieces are done, regardless
														node.node.startBlowupSequence((n) -> {
															grid.spawnNewNodeAtNode(n);
														});
													}
												}
											});
										}

										messageSuccessfullySent = true;
										completeInputXs[inSlot.gridX] = inSlot.gridX;
										completeOutputXs[outSlot.gridX] = outSlot.gridX;
									}
								});
							}
						}
					}
				});
			}

			if (messageSuccessfullySent) {
				Gameplay.onInputQueueCleaned.dispatch();
				Gameplay.onMessageSuccessfullySent.dispatch(Lambda.array(completeInputXs), Lambda.array(completeOutputXs));
			}

		new FlxTimer().start(1.5, (t) -> {
			Gameplay.onFinishedBlowingUp.dispatch(grid);
		});
	}

	var lastIndex = 0;
	var showOldBreak = false;
	public function update(grid:Grid, delta:Float) {
		#if debug
		if (breakHistory.length == 0) {
			return;
		}

		var change = SimpleController.pressed(L);
		var nextIndex = lastIndex;
		if (SimpleController.pressed(L) && SimpleController.just_pressed(LEFT)) {
			nextIndex++;
		} else if (SimpleController.pressed(L) && SimpleController.just_pressed(RIGHT)) {
			nextIndex--;
		}
		nextIndex = Std.int(FlxMath.bound(nextIndex, 0, breakHistory.length - 1));
		if (showOldBreak != change || lastIndex != nextIndex) {
			DebugDraw.ME.clearPersistentCalls();

			showOldBreak = change;
			lastIndex = nextIndex;

			if (showOldBreak) {
				breakHistory[lastIndex].degugDraw(0x555555);
			}
		}
		#end
	}
}
