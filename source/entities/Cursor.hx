package entities;

import signals.Gameplay;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import input.SimpleController;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Cursor extends FlxSprite {
	var grid:Grid;
	var gridCell = FlxPoint.get();

	var allowRotate = true;

	public function new(grid:Grid) {
		super();
		this.grid = grid;
		loadGraphic(AssetPaths.cursor_idle__png, true, 40, 40);
		animation.add('play', [0, 1, 2, 3, 4, 5], 10);
		animation.play('play');

		offset.set(4, 4);

		FlxG.watch.add(this, "gridCell", 'Cursor Coord: ');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (SimpleController.just_pressed(UP)) {
			if (SimpleController.pressed(R)) {
				// swap with the tile above if there is one
				grid.swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x), Std.int(gridCell.y) - 1);
				Gameplay.onSwap.dispatch(grid);
			} else if (gridCell.y > 0) {
				// good!
				gridCell.y--;
			} else {
				FlxTween.shake(this, 0.1, .12, FlxAxes.Y);
				// bad! animate something maybe? SFX?
			}
		}
		if (SimpleController.just_pressed(DOWN)) {
			if (SimpleController.pressed(R)) {
				// swap with the tile below if there is one
				grid.swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x), Std.int(gridCell.y) + 1);
				Gameplay.onSwap.dispatch(grid);
			} else if (gridCell.y < grid.nodes.length - 1) {
				// good!
				gridCell.y++;
			} else {
				FlxTween.shake(this, 0.1, .12, FlxAxes.Y);
				// bad! animate something maybe? SFX?
			}
		}
		if (SimpleController.just_pressed(LEFT)) {
			if (SimpleController.pressed(R)) {
				// swap with the tile to the left if there is one
				grid.swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x) - 1, Std.int(gridCell.y));
				Gameplay.onSwap.dispatch(grid);
			} else if (gridCell.x > 0) {
				// good!
				gridCell.x--;
			} else {
				FlxTween.shake(this, 0.1, .12, FlxAxes.X);
				// bad! animate something maybe? SFX?
			}
		}
		if (SimpleController.just_pressed(RIGHT)) {
			if (SimpleController.pressed(R)) {
				// swap with the tile to the right if there is one
				grid.swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x) + 1, Std.int(gridCell.y));
				Gameplay.onSwap.dispatch(grid);
			} else if (gridCell.x < grid.nodes[0].length - 1) {
				// good!
				gridCell.x++;
			} else {
				FlxTween.shake(this, 0.1, .12, FlxAxes.X);
				// bad! animate something maybe? SFX?
			}
		}

		if (SimpleController.just_pressed(A) && allowRotate) {
			allowRotate = false;
			grid.nodes[Std.int(gridCell.x)][Std.int(gridCell.y)].rotate(1, restoreControl);
			Gameplay.onRotate.dispatch(grid);
		}
		if (SimpleController.just_pressed(B) && allowRotate) {
			allowRotate = false;
			grid.nodes[Std.int(gridCell.x)][Std.int(gridCell.y)].rotate(-1, restoreControl);
			Gameplay.onRotate.dispatch(grid);
		}

		x = grid.topCorner.x + gridCell.x * 32;
		y = grid.topCorner.y + gridCell.y * 32;
	}

	private function restoreControl() {
		allowRotate = true;
	}
}
