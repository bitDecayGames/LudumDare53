package entities;

import flixel.FlxG;
import levels.LevelConfig;
import signals.Gameplay;
import flixel.addons.display.FlxTiledSprite;
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

    var swapLabel:CyberRed;
    public var swapValue:CyberRed;

    var bgOptions:FlxSprite;
    var bg:FlxTiledSprite;
    
    public function new(scoreArea:FlxRect, bgAccess:FlxTiledSprite) {
        super();

        bg = bgAccess;

        bgOptions = new FlxSprite();
		bgOptions.loadGraphic(AssetPaths.background_options__png, true, 32, 32);


        bg.loadFrame(bgOptions.frames.getByIndex(0));

        var borderSize = 4;
        var scoreBackground = new FlxSliceSprite(AssetPaths.nine_tile__png, FlxRect.get(4, 4, 24, 24), scoreArea.width + 2 * borderSize,
			scoreArea.height + 2 * borderSize);
		scoreBackground.offset.set(borderSize, borderSize);
		scoreBackground.setPosition(scoreArea.x, scoreArea.y);
		add(scoreBackground);


        scoreLabel = new CyberRed(10 * 32, scoreArea.y + 8, "score");
		add(scoreLabel);

		scoreValue = new CyberRed(10 * 32, scoreLabel.y + 16, "00000000");
		add(scoreValue);

		levelLabel = new CyberRed(10 * 32, scoreValue.y + 32, "network");
		add(levelLabel);

		levelValue = new CyberRed(10 * 32, levelLabel.y + 16, "       1");
		add(levelValue);

        var galBG = new FlxSprite(scoreArea.x + 16 - 3, levelValue.y + 32, AssetPaths.secretary_bg__png);
        add(galBG);
        gal = new Woman(scoreArea.x + 16, galBG.y + 3);
        add(gal);

        netOpsLabel = new CyberRed(10 * 32, gal.y + gal.height + 16, "net ops");
		add(netOpsLabel);

		netOpsValue = new CyberRed(10 * 32, netOpsLabel.y + 16, "       1");
		add(netOpsValue);

        averageNetOpsLabel = new CyberRed(10 * 32, netOpsValue.y + 32, "avg ops");
		add(averageNetOpsLabel);

		averageNetOpsValue = new CyberRed(10 * 32, averageNetOpsLabel.y + 16, "       1");
		add(averageNetOpsValue);

        swapLabel = new CyberRed(10 * 32, averageNetOpsValue.y + 32, "swaps");
		add(swapLabel);

        swapValue = new CyberRed(10 * 32, swapLabel.y + 16, "0");
		add(swapValue);

        Gameplay.onLevelChange.add(() -> {
            bg.loadFrame(bgOptions.frames.getByIndex(LevelConfig.currentLevel));
            levelValue.text = StringTools.lpad('${LevelConfig.currentLevel + 1}', ' ', 8);
        });
    }

    public function setNetOps(count:Int) {
        netOpsValue.text = StringTools.lpad('${count}', '0', 8);
    }

    public function setAverageNetOps(count:Float) {
        averageNetOpsValue.text = StringTools.lpad('${count}', '0', 8);
    }

    public function setSwapCount(count:Int) {
        swapValue.text = StringTools.lpad('${count}', '0', 8);
    }

    public function setScore(count:Int) {
        scoreValue.text = StringTools.lpad('${count}', '0', 8);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        #if debug
        if (FlxG.keys.justPressed.L) {
            LevelConfig.nextLevel();
            Gameplay.onLevelChange.dispatch();
        }
        #end
    }
}