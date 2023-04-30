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

class ConnectivityMaskingPlugin implements Plugin {
    // we may need n number of masks, one for each shape that is feeding into the grid
    var boardMask:FlxSprite;

    // The underlying image we want to show on the pipes
    var boardConnectiity:FlxSprite;

    // the result of the mask applied to the base image
    var result:FlxSprite;

    var maskOffset = FlxPoint.get();

    public function new() {}

	public function init(grid:Grid) {
        maskOffset.copyFrom(grid.topCorner);
        boardMask = new FlxSprite(grid.topCorner.x, grid.topCorner.y);
        boardMask.makeGraphic(grid.numberOfColumns * grid.gridCellSize, grid.numberOfRows * grid.gridCellSize);

        boardConnectiity = new FlxSprite(grid.topCorner.x, grid.topCorner.y);
        boardConnectiity.makeGraphic(Std.int(boardMask.width), Std.int(boardMask.height), FlxColor.RED);

        result = new FlxSprite(grid.topCorner.x, grid.topCorner.y);
        // result.alpha = 0.5;

        // TODO: add this in a less shitty way
        FlxG.state.add(result);

        Gameplay.onNewTreeSearch.add(resetMask);
        Gameplay.onTreeResolved.add(updateMask);

        #if maskdebug
        // FlxG.state.add(boardMask);
        #end
    }

	public function update(grid:Grid, delta:Float) {
        if (FlxG.keys.justPressed.M) {
            // updateMask(grid);
        }
    }
    
    function resetMask() {
        trace('updating pipe mask');
        FlxSpriteUtil.fill(boardMask, FlxColor.TRANSPARENT);
    }

    function updateMask(inputs:Array<InputSlot>, outputs:Array<OutputSlot>, tree:ConnectionTree) {
        for (node in tree.allNodes()) {
            trace('node position: (${(node.node.x - maskOffset.x) / 32}, ${(node.node.y - maskOffset.y) / 32})');
            trace('  node entered from ${node.enter}. node paths: ${node.node.connectionsEnter}');
            trace('  node rotation: ${node.node.rotationOffset}');
            trace('  node masks: ${node.node.masks}');
            trace('  node path num: ${node.node.pathId(node.enter)}');
            boardMask.stamp(node.node.masks[node.node.pathId(node.enter) - 1], Std.int(node.node.x - maskOffset.x), Std.int(node.node.y - maskOffset.y));
        }

        FlxSpriteUtil.alphaMaskFlxSprite(boardConnectiity, boardMask, result);
    }
}