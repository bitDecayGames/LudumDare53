package entities;

import flixel.FlxG;
import input.SimpleController;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Cursor extends FlxSprite {
    var grid:Grid;
    var gridCell = FlxPoint.get();
    
    public function new(grid:Grid) {
        super();
        this.grid = grid;
        loadGraphic(AssetPaths.cursor_idle__png, true, 40, 40);
        animation.add('play', [0, 1, 2, 3, 4, 5], 10);
        animation.play('play');

        FlxG.watch.add(this, "gridCell", 'Cursor Coord: ');
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (SimpleController.just_pressed(UP)) {
            if (gridCell.y > 0) {
                // good!
                gridCell.y--;
            } else {
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(DOWN)) {
            if (gridCell.y < grid.nodes.length - 1) {
                // good!
                gridCell.y++;
            } else {
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(LEFT)) {
            if (gridCell.x > 0) {
                // good!
                gridCell.x--;
            } else {
                // bad! animate something maybe? SFX?
            }
        }
        if (SimpleController.just_pressed(RIGHT)) {
            if (gridCell.x < grid.nodes[0].length - 1) {
                // good!
                gridCell.x++;
            } else {
                // bad! animate something maybe? SFX?
            }
        }

        if (SimpleController.just_pressed(A)) {
            grid.nodes[Std.int(gridCell.x)][Std.int(gridCell.y)].rotate(1);
        }

        x = grid.topCorner.x + gridCell.x * 32 - 4;
        y = grid.topCorner.y + gridCell.y * 32 - 4;
    }
}