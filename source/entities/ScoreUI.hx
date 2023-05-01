package entities;

import ui.font.BitmapText.CyberRed;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class ScoreUI extends FlxTypedGroup<FlxSprite> {

    var gal:FlxSprite;

    var scoreLabel:CyberRed;
    var scoreValue:CyberRed;
    var levelLabel:CyberRed;
    var levelValue:CyberRed;
    var netOpsLabel:CyberRed;
    var netOpsValue:CyberRed;
    var averageNetOpsLabel:CyberRed;
    var averageNetOpsValue:CyberRed;
    

    public function new(scoreArea:FlxRect) {
        super();

        var borderSize = 4;
        var scoreBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), scoreArea.width + 2 * borderSize,
			scoreArea.height + 2 * borderSize);
		scoreBackground.offset.set(borderSize, borderSize);
		scoreBackground.setPosition(scoreArea.x, scoreArea.y);
		add(scoreBackground);

        var galBG = new FlxSprite(scoreArea.x + 16 - 3, scoreArea.y, AssetPaths.secretary_bg__png);
        add(galBG);
        gal = new Woman(scoreArea.x + 16, scoreArea.y + 3);
        add(gal);

        scoreLabel = new CyberRed(10 * 32, gal.y + gal.height + 16, "score");
		add(scoreLabel);

		scoreValue = new CyberRed(10 * 32, scoreLabel.y + 16, "00000123");
		add(scoreValue);

		levelLabel = new CyberRed(10 * 32, scoreValue.y + 32, "network");
		add(levelLabel);

		levelValue = new CyberRed(10 * 32, levelLabel.y + 16, "       1");
		add(levelValue);

        netOpsLabel = new CyberRed(10 * 32, levelValue.y + 32, "net ops");
		add(netOpsLabel);

		netOpsValue = new CyberRed(10 * 32, netOpsLabel.y + 16, "       1");
		add(netOpsValue);

        averageNetOpsLabel = new CyberRed(10 * 32, netOpsValue.y + 32, "avg ops");
		add(averageNetOpsLabel);

		averageNetOpsValue = new CyberRed(10 * 32, averageNetOpsLabel.y + 16, "       1");
		add(averageNetOpsValue);
    }

    public function setNetOps(count:Int) {
        netOpsValue.text = StringTools.lpad('${count}', '0', 8);
    }

    public function setAverageNetOps(count:Float) {
        averageNetOpsValue.text = StringTools.lpad('${count}', '0', 8);
    }
}