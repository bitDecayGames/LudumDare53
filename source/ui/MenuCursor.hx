package ui;

import flixel.math.FlxRect;
import flixel.FlxSprite;

class MenuCursor extends FlxSprite {

    var frameSize = 40;

    public function new() {
        super();
        loadGraphic(AssetPaths.cursor_idle__png, true, frameSize, frameSize);
        animation.add('play', [for (i in 0...6) i], 10);
        animation.play('play');
    }

    public function select(area:FlxRect) {
        setPosition(area.x + area.width/2 - width/2, area.y + area.height/2 - height/2);
        scale.set(area.width / frameSize, area.height / frameSize);
    }
}