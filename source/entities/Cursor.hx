package entities;

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
            if (gridCell.y > 0) {
                // good!
                gridCell.y--;
            } else {
                FlxTween.shake(this, 0.1, .12, FlxAxes.Y);
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(DOWN)) {
            if (gridCell.y < grid.nodes.length - 1) {
                // good!
                gridCell.y++;
            } else {
                FlxTween.shake(this, 0.1, .12, FlxAxes.Y);
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(LEFT)) {
            if (gridCell.x > 0) {
                // good!
                gridCell.x--;
            } else {
                FlxTween.shake(this, 0.1, .12, FlxAxes.X);
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(RIGHT)) {
            if (gridCell.x < grid.nodes[0].length - 1) {
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
        }

        x = grid.topCorner.x + gridCell.x * 32;
        y = grid.topCorner.y + gridCell.y * 32;
    }

    private function restoreControl() {
        allowRotate = true;
    }
}