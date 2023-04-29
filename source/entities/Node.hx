package entities;

import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import misc.Macros;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;

class Node extends FlxSprite {
	// These arrays are in the form [top, right, bottom, left]
	var connectionsEnter:Array<Int> = [0, 0, 0, 0];
	var connectionsExit:Array<Int> = [0, 0, 0, 0];
	var rotationOffset:Int = 0;
	var gridCellSize:Float = 0;

	var blowingUp:Bool = false;

	public static function create(type:NodeType):Node {
		trace('creating node with type: ${type}');
		switch type {
			case Corner:
				return new Node(32, AssetPaths.bend__png, [0, 0, 1, 1], [0, 0, 1, 1], FlxG.random.int(0, 3));
			case Tee:
				return new Node(32, AssetPaths.tee__png, [0, 1, 1, 1], [0, 1, 1, 1], FlxG.random.int(0, 3));
			case Straight:
				return new Node(32, AssetPaths.straight__png, [1, 0, 1, 0], [1, 0, 1, 0], FlxG.random.int(0, 3));
			case Plus:
				return new Node(32, AssetPaths.plus__png, [1, 1, 1, 1], [1, 1, 1, 1], FlxG.random.int(0, 3));
			case OneWay:
				return new Node(32, AssetPaths.straight_oneway__png, [0, 0, 1, 0], [1, 0, 0, 0], FlxG.random.int(0, 3));
			// case Warp:
			// 	// TODO: How do we capture this info?
			case Dead:
				return new Node(32, AssetPaths.blocker__png, [0, 0, 0, 0], [0, 0, 0, 0], 0);
			case DoubleCorner:
				return new Node(32, AssetPaths.double_bend__png, [1, 1, 2, 2], [1, 1, 2, 2], FlxG.random.int(0, 3));
			case Crossover:
				return new Node(32, AssetPaths.plus_overlapping__png, [1, 2, 1, 2], [1, 2, 1, 2], FlxG.random.int(0, 3));
		}
		return null;
	}

	private function new(gridCellSize:Float, asset:FlxGraphicAsset, entrances:Array<Int>, exits:Array<Int>, rot:Int) {
		super();
		this.gridCellSize = gridCellSize;
		loadGraphic(asset);
		rotate(rot);
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	/**
	 * Rotate the node/tile by 90 degrees in the given direction (positive == clockwise)
	 * @param dir a non-zero number that represents the number of 90 degree turns to make
	 */
	public function rotate(dir:Int, ?cb:() -> Void) {
		rotationOffset += dir;
		FlxTween.angle(this, angle, rotationOffset * 90, 0.12, {
			onComplete: (t) -> {
				rotationOffset = rotationOffset % 4;
				angle = rotationOffset * 90;
				if (cb != null) {
					cb();
				}
			}
		});
	}

	/**
	 * Sets the [top, right, bottom, left] connection points.
	 *
	 * 0 - no connection
	 *
	 * 1/2 - represents connective pipes where all the 1s connect and all the 2s connect but
	 * the 1s don't connect to the 2s
	 */
	public function setConnections(enter:Array<Int>, exit:Array<Int>) {
		if (enter == null || enter.length != 4) {
			throw "enter array must have a length of 4";
		}
		if (exit == null || exit.length != 4) {
			throw "exit array must have a length of 4";
		}
		connectionsEnter = enter;
		connectionsExit = exit;
	}

	/**
	 * Get the path id at the cardinal enter
	 * @param enter
	 * @return Int
	 */
	public function pathId(enter:Cardinal):Int {
		var enterIndex = (cardinalToIndex(enter) + rotationOffset) % 4;
		return connectionsEnter[enterIndex];
	}

	/**
	 * Given an input direction (when you pass North, you are saying you are COMING from
	 * the top, not that you are heading towards the top), get the corresponding outlets
	 * in cardinal directions.  The return array will contain 0, 1, 2, or 3 elements.
	 * @param enter the direction you are entering the tile from
	 * @return Array<Cardinal> the directions you can now exit the tile from
	 */
	public function getOutlets(enter:Cardinal):Array<Cardinal> {
		var enterIndex = (cardinalToIndex(enter) + rotationOffset) % 4;
		var path = connectionsEnter[enterIndex];
		if (path == 0)
			return [];
		var outlets:Array<Cardinal> = [];
		for (i in 0...4) {
			var iRot = (i + rotationOffset) % 4;
			if (iRot != enterIndex && connectionsExit[iRot] == path) {
				outlets.push(indexToCardinal(iRot));
			}
		}
		return outlets;
	}

	/**
	 * Converts a cardinal direction (only accepts N,S,E,W) into an index
	 * to be used to index into the connections array.
	 * @param c the N/S/E/W cardinal direction
	 * @return Int the index for the connections array
	 */
	private function cardinalToIndex(c:Cardinal):Int {
		switch (c) {
			case Cardinal.E:
				return 1;
			case Cardinal.S:
				return 2;
			case Cardinal.W:
				return 3;
			default:
				return 0;
		}
	}

	/**
	 * Converts an index from 0-3 into cardinal directions (NESW)
	 * @param i
	 * @return Cardinal
	 */
	private function indexToCardinal(i:Int):Cardinal {
		switch (i) {
			case 1:
				return Cardinal.E;
			case 2:
				return Cardinal.S;
			case 3:
				return Cardinal.W;
			default:
				return Cardinal.N;
		}
	}

	public function startBlowupSequence() {
		if (!blowingUp) {
			blowingUp = true;
			FlxTween.shake(this, 0.1, 0.5, FlxAxes.XY, {
				onComplete: (t) -> {
					kill();
				}
			});
		}
	}
}
