package plugins;

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

    public function new(ui:ScoreUI) {
        this.ui = ui;
    }

	public function init(grid:Grid):Void {
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

            // Score table
            if (inputs.length > 3 && outputs.length > 3) {
                scoreValue += 2000;
            } else if (inputs.length == 3 && outputs.length == 3) {
                scoreValue += 1200;
            } else if (inputs.length == 3 || outputs.length == 3) {
                scoreValue += 800;
            } else if (inputs.length == 2 && outputs.length == 2) {
                scoreValue += 500; 
            } else if (inputs.length == 2 || outputs.length == 2) {
                scoreValue += 200;
            } else {
                scoreValue += 100;
            } 
        });
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