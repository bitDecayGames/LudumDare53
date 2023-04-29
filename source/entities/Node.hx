package entities;

import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;

class Node extends FlxSprite {
	var connectionsEnter:Array<Int> = [0, 0, 0, 0];
	var connectionsExit:Array<Int> = [0, 0, 0, 0];
	var rotationOffset:Int = 0;
	var gridCellSize:Float = 0;

	public function new(gridCellSize:Float) {
		super();
		this.gridCellSize = gridCellSize;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	/**
	 * Rotate the node/tile by 90 degrees in the given direction (positive == clockwise)
	 * @param dir a non-zero number that represents the number of 90 degree turns to make
	 */
	public function rotate(dir:Int) {
		rotationOffset = dir % 4;
		angle = rotationOffset * 90;
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
}
