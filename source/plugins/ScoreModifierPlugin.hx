package plugins;

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
            trace('inputs: ${inputs.size} outputs: ${outputs.size}');
            totalCompletions++;
            totalOps += opsSinceLastMessage;

            opsSinceLastMessage = 0;

            // Score table
            if (inputs.size > 3 && outputs.size > 3) {
                scoreValue += 2000;
            } else if (inputs.size == 3 && outputs.size == 3) {
                scoreValue += 1200;
            } else if (inputs.size == 3 || outputs.size == 3) {
                scoreValue += 800;
            } else if (inputs.size == 2 && outputs.size == 2) {
                scoreValue += 500; 
            } else if (inputs.size == 2 || outputs.size == 2) {
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