package plugins;

import entities.Woman;
import flixel.util.FlxTimer;
import ui.font.BitmapText.CyberWhite;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import ui.font.BitmapText.CyberRed;
import levels.LevelConfig;
import entities.ScoreUI;
import signals.Gameplay;
import entities.Grid;

class ScoreModifierPlugin implements Plugin {
    public static var swapCount:Int = 5;

    var ui:ScoreUI;

    var opsSinceLastMessage = 0;

    var totalOps = 0;
    var totalCompletions = 0;
    var scoreValue = 0;

    var grid:Grid;

    public function new(ui:ScoreUI) {
        this.ui = ui;
    }

	public function init(grid:Grid):Void {
        this.grid = grid;

        Gameplay.onRotate.add((g) -> {
            opsSinceLastMessage++;
        });
        Gameplay.onSwap.add((g) -> {
            opsSinceLastMessage++;
        });
        Gameplay.onMessageSuccessfullySent.add((inputs, outputs) -> {
            totalCompletions++;
            trace('breaks: ${totalCompletions}');
            trace('current level: ${LevelConfig.currentLevel}, needed breaks ${LevelConfig.currentLevelConfig().breaksToFinish}');
            if (totalCompletions > LevelConfig.currentLevelConfig().breaksToFinish) {
                LevelConfig.nextLevel();
            }
            totalOps += opsSinceLastMessage;

            opsSinceLastMessage = 0;

            var sum = 0;
            for (i in outputs) {
                sum += i;
            }

            var avg = 1.0 * sum / outputs.length;

            trace('outputs: ${outputs}');
            trace('avg: ${avg}');

            // Score table
            if (inputs.length > 3 && outputs.length > 3) {
                giveScore(2000, 5, avg);
                scoreValue += 2000;
            } else if (inputs.length == 3 && outputs.length == 3) {
                giveScore(1200, 5, avg);
            } else if (inputs.length == 3 || outputs.length == 3) {
                giveScore(800, 2, avg);
            } else if (inputs.length == 2 && outputs.length == 2) {
                giveScore(500, 2, avg);
            } else if (inputs.length == 2 || outputs.length == 2) {
                giveScore(200, 1, avg);
            } else {
                giveScore(100, 1, avg);
            } 
        });
    }

    function giveScore(value:Int, extraShifts:Int, coord:Float) {
        // TODO SFX: Score awarded (some message delivered). See above for score ranges

        Gameplay.onScore.dispatch(value);
        var scaled = value * Woman.activeMultiplier;
        scoreValue += Std.int(scaled);
        // spawn text burst
        var award = new CyberWhite('${scaled}');
        trace('coord: ${coord}');
        trace('award width: ${award.width}    frameWidth: ${award.frameWidth}  textWidth ${award.textWidth}');
        award.setPosition(grid.topCorner.x + coord * 32 - award.width / 2 + 16, grid.topCorner.y - grid.gridCellSize);
        trace('final award x: ${award.x}');
        FlxG.state.add(award);
        new FlxTimer().start(0.5, (t) -> {
            FlxTween.tween(award, {y: award.y - 10, alpha: 0}, 0.5, {
                onComplete: (t) -> {
                    award.kill();
                }
            });    
        });

        // spawn shift gift
        var shifts = new CyberWhite('+${extraShifts}');
        shifts.setPosition(grid.topCorner.x + coord * 32 - shifts.width / 2 + 16, grid.topCorner.y - grid.gridCellSize);
        FlxG.state.add(shifts);

        var path = [
            shifts.getPosition(),
            FlxPoint.get(FlxG.width, 0),
            ui.swapValue.getPosition().add(ui.swapValue.width * 0.75),
        ];

        FlxTween.quadPath(shifts, path, 1.25,
            {
                ease: FlxEase.quadInOut,
                onComplete: (t) -> {
                    // TODO SFX: extra swaps awarded, particle ended path and number increased
                    shifts.kill();
                    for (point in path) {
                        point.put();
                    }
                    swapCount += extraShifts;
                }
            }
        );
    }

	public function update(grid:Grid, delta:Float):Void {
        ui.setNetOps(opsSinceLastMessage);
        if (totalCompletions == 0) {
            ui.setAverageNetOps(0);
        } else {
            ui.setAverageNetOps(Math.round(totalOps / totalCompletions));
            ui.setScore(scoreValue);
        }

        ui.setSwapCount(swapCount);
    }
}