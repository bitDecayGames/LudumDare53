package plugins;

import flixel.math.FlxPoint;
import entities.OutputSlot;
import entities.InputSlot;
import entities.ConnectionTree;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import signals.Gameplay;
import flixel.FlxSprite;
import entities.Grid;
import entities.IOEnums.IOShape;

class ConnectivityMaskingPlugin implements Plugin {
    var maskOffset = FlxPoint.get();

    var grid:Grid;

    public function new() {}

	public function init(grid:Grid) {
        this.grid = grid;
        maskOffset.copyFrom(grid.topCorner);

        Gameplay.onNewTreeSearch.add(resetMask);
        Gameplay.onTreeResolved.add(updateMask);
    }

    public function update(grid:Grid, delta:Float) {}
    
    function resetMask() {
        for (x in grid.nodes) {
            for (node in x) {
                for (mask in node.masks) {
                    mask.visible = false;
                    mask.color = FlxColor.WHITE;
                }
            }
        }
    }

    function updateMask(inputs:Array<InputSlot>, outputs:Array<OutputSlot>, tree:ConnectionTree) {
        for (node in tree.allNodes()) {
            var mask = node.node.masks[node.node.pathId(node.enter) - 1];
            for (slot in inputs) {
                if (slot.queue.length > 0) {
                    mask.visible = true;
                    if (mask.color == FlxColor.WHITE) {
                        // if we don't have a color, just use the shape color
                        mask.color = slot.queue[0].shape.getColor();
                    } else {
                        // otherwise, go halfway between our current color, and the new shape color
                        mask.color = FlxColor.interpolate(mask.color, slot.queue[0].shape.getColor(), 0.5);
                    }
                }
            }
        }
    }
}