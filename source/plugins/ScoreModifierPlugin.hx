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
        Gameplay.onMessageSuccessfullySent.add((shape, input, output) -> {
            totalCompletions++;
            totalOps += opsSinceLastMessage;

            opsSinceLastMessage = 0;
        });
    }

	public function update(grid:Grid, delta:Float):Void {
        ui.setNetOps(opsSinceLastMessage);
        if (totalCompletions == 0) {
            ui.setAverageNetOps(0);
        } else {
            ui.setAverageNetOps(totalOps / totalCompletions);
        }

        ui.setSwapCount(swapCount);
    }
}