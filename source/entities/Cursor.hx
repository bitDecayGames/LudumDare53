package entities;

import openfl.ui.GameInput;
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
    var shakeTween:FlxTween;
    var preshakeLocation:FlxPoint = FlxPoint.get();

	var allowInteraction = true;

	public function new(grid:Grid) {
		super();
		this.grid = grid;
		loadGraphic(AssetPaths.cursor_idle__png, true, 40, 40);
		animation.add('play', [0, 1, 2, 3, 4, 5], 10);
		animation.play('play');
		offset.set(4, 4);
	}

    private function doneSwapping() {
        restoreControl();
		Gameplay.onSwap.dispatch(grid);
    }

	private function swapTiles(x1:Int, y1:Int, x2:Int, y2:Int):Bool {
		if (!allowInteraction)
			return false;

		var wasSwapped = grid.swapTiles(x1, y1, x2, y2, doneSwapping);
		if (!wasSwapped)
			return false;

		allowInteraction = false;
		gridCell.x = x2;
		gridCell.y = y2;
        FmodManager.PlaySoundOneShot(FmodSFX.TileSlide);
        return true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

        if (SimpleController.just_pressed(UP)) {
            if (SimpleController.pressed(R)) {
                // swap with the tile above if there is one
                var wasSwapped = swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x), Std.int(gridCell.y) - 1);
                if (!wasSwapped) {
                    shake(FlxAxes.Y);
                }
            } else if (gridCell.y > 0) {
                // good!
                gridCell.y--;
                FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
            } else {
                shake(FlxAxes.Y);
                FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
            }
        }
        if (SimpleController.just_pressed(DOWN)) {
            if (SimpleController.pressed(R)) {
                // swap with the tile below if there is one
                var wasSwapped = swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x), Std.int(gridCell.y) + 1);
                if (!wasSwapped) {
                    shake(FlxAxes.Y);
                }
            } else if (gridCell.y < grid.nodes.length - 1) {
                // good!
                gridCell.y++;
                FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
            } else {
                shake(FlxAxes.Y);
                FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
            }
        }
        if (SimpleController.just_pressed(LEFT)) {
            if (SimpleController.pressed(R)) {
                // swap with the tile to the left if there is one
                var wasSwapped = swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x) - 1, Std.int(gridCell.y));
                if (!wasSwapped) {
                    shake(FlxAxes.X);
                }
            } else if (gridCell.x > 0) {
                // good!
                gridCell.x--;
                FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
            } else {
                shake(FlxAxes.X);
                FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
            }
        }
        if (SimpleController.just_pressed(RIGHT)) {
            if (SimpleController.pressed(R)) {
                // swap with the tile to the right if there is one
                var wasSwapped = swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(gridCell.x) + 1, Std.int(gridCell.y));
                if (!wasSwapped) {
                    shake(FlxAxes.X);
                }
            } else if (gridCell.x < grid.nodes[0].length - 1) {
                // good!
                gridCell.x++;
                FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
            } else {
                shake(FlxAxes.X);
                FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
            }
        }

        var currentNode = grid.nodes[Std.int(gridCell.x)][Std.int(gridCell.y)];
        var canRotate = currentNode.isMobile() && allowInteraction;
        if (SimpleController.just_pressed(A)) {
            if (!canRotate) {
                shake(FlxAxes.XY);
                if (currentNode.nodeType == Dead) {
                    FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
                }
            } else {
                FmodManager.PlaySoundOneShot(FmodSFX.TileClockwise);
                allowInteraction = false;
                currentNode.rotate(1, doneRotating);
            }
        }

        if (SimpleController.just_pressed(B)) {
            if (!canRotate) {
                shake(FlxAxes.XY);
                if (currentNode.nodeType == Dead) {
                    FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
                }
            } else {
                FmodManager.PlaySoundOneShot(FmodSFX.TileCounterclockwise);
                allowInteraction = false;
                currentNode.rotate(-1, doneRotating);
            }
        }

		x = grid.topCorner.x + gridCell.x * 32;
		y = grid.topCorner.y + gridCell.y * 32;
	}

    // private function selected() {
    //     var currentNode = grid.nodes[Std.int(gridCell.x)][Std.int(gridCell.y)];
    //     if (currentNode.nodeType == Dead) {

    //     }
    // }

    private function doneRotating() {
        restoreControl();
        Gameplay.onRotate.dispatch(grid);
    }


	private function restoreControl() {
		allowInteraction = true;
	}

    private function shake(axis:FlxAxes) {
        if (shakeTween != null) {
            shakeTween.cancel();
            x = preshakeLocation.x;
            y = preshakeLocation.y;
        }
        
        preshakeLocation.x = x;
        preshakeLocation.y = y;

        shakeTween = FlxTween.shake(this, 0.1, .12, axis, { onComplete: doneShaking });
    }

    private function doneShaking(t:FlxTween) {
        shakeTween = null;
    }
}
