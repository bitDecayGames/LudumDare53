package entities;

import flixel.FlxG;
import flixel.FlxSprite;

class Woman extends FlxSprite {
    public static inline var IDLE = "idle";
    public static inline var IDLE_ANIMATION = "anim-idle";
    public static inline var CHEER_1_ANIMATION = "achieve-a";
    public static inline var CHEER_2_ANIMATION = "achieve-b";
    public static inline var UPGRADE_ANIMATION = "upgrade";
    public static inline var DOWNGRADE_ANIMATION = "downgrade";

    var currentLevel = 3;

    var idleTimer = 3.0;

    public function new(X:Float, Y:Float) {
        super(X, Y);

        loadGraphic(AssetPaths.secretary_sheet__png, true, 96, 160);
        // first block are idle animations
        // second and third blocks are celebration animations
        // fourth block is transition up animation
        // fifth block is the transition down animation
        
        addAnimForAllLevels(IDLE, 0, 1, true);
        addAnimForAllLevels(IDLE_ANIMATION, 0, 6);
        addAnimForAllLevels(CHEER_1_ANIMATION, 7, 6);
        addAnimForAllLevels(CHEER_2_ANIMATION, 15, 6);
        addAnimForAllLevels(UPGRADE_ANIMATION, 24, 6);
        addAnimForAllLevels(DOWNGRADE_ANIMATION, 33, 6);

        animation.finishCallback = (name) -> {
            trace('anim finished: ${name}');
            playAnimForCurrentLevel(IDLE);
        };

        playAnimForCurrentLevel(IDLE);
    }

    private function addAnimForAllLevels(name:String, start:Int, len:Int, looped:Bool = false) {
        for (i in 0...5) {
            if (name == DOWNGRADE_ANIMATION && i == 0) {
                // this on animation is known to be longer
                addAnim('${name}-${5 - i}', start - 1 + i * 41, len + 1, looped);
                continue;
            }
            addAnim('${name}-${5 - i}', start + i * 41, len, looped);
        }
    }

    private function addAnim(name:String, start:Int, len:Int, looped:Bool = false) {
        animation.add(name, [for (i in start...start+len) i], 10, looped);
    }

    public function playAnimForLevel(baseName:String, level:Int) {
        animation.play('${baseName}-${level}');
    }

    public function playAnimForCurrentLevel(baseName:String) {
        playAnimForLevel(baseName, currentLevel);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.U) {
            playAnimForCurrentLevel(UPGRADE_ANIMATION);
            currentLevel++;
        }

        if (FlxG.keys.justPressed.J) {
            playAnimForCurrentLevel(DOWNGRADE_ANIMATION);
            currentLevel--;
        }

        if (FlxG.keys.justPressed.I) {
            playAnimForCurrentLevel(CHEER_1_ANIMATION);
        }

        if (FlxG.keys.justPressed.K) {
            playAnimForCurrentLevel(CHEER_2_ANIMATION);
        }

        if (StringTools.startsWith(animation.name, "idle-")) {
            idleTimer -= elapsed;

            if (idleTimer <= 0) {
                idleTimer += FlxG.random.float(2, 10);
                playAnimForCurrentLevel(IDLE_ANIMATION);
            }
        }
    }
}