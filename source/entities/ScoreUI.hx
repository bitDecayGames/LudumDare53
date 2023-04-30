package entities;

import ui.font.BitmapText.CyberRed;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class ScoreUI extends FlxTypedGroup<FlxSprite> {

    var scoreLabel:CyberRed;
    var scoreValue:CyberRed;
    var levelLabel:CyberRed;
    var levelValue:CyberRed;
    var iopsLabel:CyberRed;
    var iopsValue:CyberRed;
    var averageIopsLabel:CyberRed;
    var averageIopsValue:CyberRed;
    

    public function new(scoreArea:FlxRect) {
        super();

        var borderSize = 4;
        var scoreBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), scoreArea.width + 2 * borderSize,
			scoreArea.height + 2 * borderSize);
		scoreBackground.offset.set(borderSize, borderSize);
		scoreBackground.setPosition(scoreArea.x, scoreArea.y);
		add(scoreBackground);

        scoreLabel = new CyberRed(10 * 32, 32, "score");
		add(scoreLabel);

		scoreValue = new CyberRed(10 * 32, scoreLabel.y + 16, "00000123");
		add(scoreValue);

		levelLabel = new CyberRed(10 * 32, scoreValue.y + 32, "network");
		add(levelLabel);

		levelValue = new CyberRed(10 * 32, levelLabel.y + 16, "       1");
		add(levelValue);

        iopsLabel = new CyberRed(10 * 32, levelValue.y + 32, "iops");
		add(iopsLabel);

		iopsValue = new CyberRed(10 * 32, iopsLabel.y + 16, "       1");
		add(iopsValue);

        averageIopsLabel = new CyberRed(10 * 32, iopsValue.y + 32, "avg iops");
		add(averageIopsLabel);

		averageIopsValue = new CyberRed(10 * 32, averageIopsLabel.y + 16, "       1");
		add(averageIopsValue);
    }

    public function setIops(count:Int) {
        iopsValue.text = StringTools.lpad('${count}', '0', 8);
    }

    public function setAverageIops(count:Float) {
        averageIopsValue.text = StringTools.lpad('${count}', '0', 8);
    }
}