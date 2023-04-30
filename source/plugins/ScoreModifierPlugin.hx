package plugins;

import entities.ScoreUI;
import signals.Gameplay;
import entities.Grid;

class ScoreModifierPlugin implements Plugin {
    var ui:ScoreUI;

    var rotationsSinceLastMessage = 0;

    var totalRotations = 0;
    var totalCompletions = 0;

    public function new(ui:ScoreUI) {
        this.ui = ui;
    }

	public function init(grid:Grid):Void {
        Gameplay.onRotate.add((g) -> {
            rotationsSinceLastMessage++;
        });
        Gameplay.onMessageSuccessfullySent.add((shape, input, output) -> {
            totalCompletions++;
            totalRotations += rotationsSinceLastMessage;

            rotationsSinceLastMessage = 0;
        });
    }

	public function update(grid:Grid, delta:Float):Void {
        ui.setNetOps(rotationsSinceLastMessage);
        if (totalCompletions == 0) {
            ui.setAverageNetOps(0);
        } else {
            ui.setAverageNetOps(totalRotations / totalCompletions);
        }
    }
}