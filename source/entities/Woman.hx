package entities;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import signals.Gameplay;
import flixel.FlxG;
import flixel.FlxSprite;

class Woman extends FlxSprite {
    public static inline var IDLE = "idle";
    public static inline var IDLE_ANIMATION = "anim-idle";
    public static inline var CHEER_1_ANIMATION = "achieve-a";
    public static inline var CHEER_2_ANIMATION = "achieve-b";
    public static inline var UPGRADE_ANIMATION = "upgrade";
    public static inline var DOWNGRADE_ANIMATION = "downgrade";

    // Level can range from 1-5 for a multiplier effect
    // 5 - 5x    multiplier
    // 4 - 2x    multiplier
    // 3 - 1x    multiplier
    // 2 - 0.5x  multiplier
    // 1 - 0.25x multiplier
    var currentLevel = 3;

    public static var activeMultiplier:Float = 1;

    var idleTimer = 3.0;

    var momentum = new Array<Momentum>();

    public function new(X:Float, Y:Float) {
        super(X, Y);

        Gameplay.onScore.add(newScore);

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
            playAnimForCurrentLevel(IDLE);
        };

        playAnimForCurrentLevel(IDLE);

        // start player out with some initial momentum
        momentum.push(new Momentum(300, 15));
        momentum.push(new Momentum(300, 20));
        momentum.push(new Momentum(300, 25));
    }

    private function addAnimForAllLevels(name:String, start:Int, len:Int, looped:Bool = false) {
        for (i in 0...5) {
            if (name == DOWNGRADE_ANIMATION && i == 0) {
                // this on animation is known to be longer
                addAnim('${name}-${5 - i}', start - 1 + i * 41, len + 1, looped);
                continue;
            }

            if (name == CHEER_1_ANIMATION && i == 0) {
                // this on animation is known to be longer
                addAnim('${name}-${5 - i}', start + i * 41, len + 2, looped);
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

    function newScore(points:Int) {
        var hypeTime = 120;
        if (points > 2000) {
            hypeTime = 5;
        } else if (points > 1200) {
            hypeTime = 10;
        } else if (points > 500) {
            hypeTime = 20;
        } else if (points > 200) {
            hypeTime = 30;
        }
        momentum.push(new Momentum(points, hypeTime));
        playAnimForCurrentLevel(FlxG.random.bool() ? CHEER_1_ANIMATION : CHEER_2_ANIMATION);
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

        var hype = 0;
        for (m in momentum) {
            m.duration -= elapsed;

            if (m.duration <= 0) {
                momentum.remove(m);
            } else {
                hype += m.score;
            }
        }

        FlxG.watch.addQuick("hype: ", hype);

        setLevelBasedOnHype(hype);

        switch currentLevel {
            case 1:
                activeMultiplier = .25;
            case 2:
                activeMultiplier = 0.5;
            case 3:
                activeMultiplier = 1;
            case 4:
                activeMultiplier = 2;
            case 5:
                activeMultiplier = 5;
        }
    }
    
    function setLevelBasedOnHype(hype:Int) {
        var hypeLevel = currentLevel;
        if (hype > 2000) {
            hypeLevel = 5;
        } else if (hype > 1200) {
            hypeLevel = 4;
        } else if (hype > 500) {
            hypeLevel = 3;
        } else if (hype > 200) {
            hypeLevel = 2;
        } else {
            hypeLevel = 1;
        }

        if (hypeLevel > currentLevel) {
            playAnimForCurrentLevel(UPGRADE_ANIMATION);
            // TODO SFX: Hype level up (woman excited)
            currentLevel++;
            multiplierParticle();
        } else if (hypeLevel < currentLevel) {
            playAnimForCurrentLevel(DOWNGRADE_ANIMATION);
            // TODO SFX: Hype level up (woman unamused)
            currentLevel--;
            multiplierParticle();

        }
    }

    function multiplierParticle() {
        var particle = new FlxSprite();
        particle.loadGraphic(AssetPaths.multipliers__png, true, 52, 21);
        particle.setPosition(x + width/2 - particle.width/2, y);
        particle.animation.frameIndex = currentLevel - 1;
        FlxG.state.add(particle);
        new FlxTimer().start(0.5, (t) -> {
            FlxTween.tween(particle, {y: particle.y - 30, alpha: 0}, 0.5, {
                onComplete: (t) -> {
                    particle.kill();
                }
            });    
        });
    }
}

class Momentum {
    public var score:Int;
    public var duration:Float;

    public function new(s:Int, d:Float) {
        score = s;
        duration = d;
    }
}