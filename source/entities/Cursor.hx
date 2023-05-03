package entities;

import plugins.ScoreModifierPlugin;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxObject;
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
		animation.add('play', [0, 1, 2, 3, 4], 10);
        animation.add('grab', [6, 7, 8, 9, 10], 10);
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

        if (SimpleController.pressed(R)) {
            animation.play('grab', animation.frameIndex);
        } else {
            animation.play('play', animation.frameIndex);
        }

        if (SimpleController.just_pressed(UP)) {
            if (SimpleController.pressed(R)) {
                attemptSwap(gridCell, Cardinal.N);
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
                attemptSwap(gridCell, Cardinal.S);
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
                attemptSwap(gridCell, Cardinal.W);
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
                attemptSwap(gridCell, Cardinal.E);
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

    private function attemptSwap(cell:FlxPoint, direction:Cardinal) {
        var dest = FlxPoint.get().copyFrom(cell);
        switch(direction) {
            case N:
                dest.y -= 1;
            case S:
                dest.y += 1;
            case E:
                dest.x += 1;
            case W:
                dest.x -= 1;
            default:
                trace('attempted to swap in invalid direction: ${direction}');
        }

        var wasSwapped = false;
        if (ScoreModifierPlugin.swapCount > 0) {
            // swap with the tile above if there is one
            wasSwapped = swapTiles(Std.int(gridCell.x), Std.int(gridCell.y), Std.int(dest.x), Std.int(dest.y));
        } else {
            // no swaps.
            FmodManager.PlaySoundOneShot(FmodSFX.TileCannotRotate);
        }
        if (!wasSwapped) {
            shake(direction.horizontal() ? FlxAxes.X : FlxAxes.Y);
        } else {
            ScoreModifierPlugin.swapCount--;
        }
    }

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
