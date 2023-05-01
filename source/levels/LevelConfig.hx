package levels;

import signals.Gameplay;
import flixel.math.FlxMath;
import flixel.FlxG;
import entities.NodeType;
import entities.IOEnums.IOShape;

class LevelConfig {
    public static var currentLevel(default, null) = 0;

    // level probabilities for tiles
    private static var levels:Array<SingleLevel> = [
        {
            num: 1,
            bgIndex: 0,
            breaksToFinish: 5,
            shapes: [
                Spade,
                Club,
                Diamond,
                Heart,
            ],
            probs: [
                Corner => 2,
                Tee => 2,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 0,
                DoubleCorner => 0,
                Crossover => 2,
                Empty => 0
            ],
        },
        {
            num: 2,
            bgIndex: 1,
            breaksToFinish: 10,
            shapes: [
                Spade,
                Club,
                Diamond,
                Heart,
                Circle,
            ],
            probs: [
                Corner => 2,
                Tee => 2,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 0.5,
                DoubleCorner => 1,
                Crossover => 1,
                Empty => 0.5
            ]
        },
        {
            num: 3,
            bgIndex: 2,
            breaksToFinish: 20,
            shapes: [
                Spade,
                Club,
                Diamond,
                Heart,
                Circle,
                Star,
            ],
            probs: [
                Corner => 2,
                Tee => 2,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 1,
                DoubleCorner => 2,
                Crossover => 2,
                Empty => 1
            ],
        },
        {
            num: 4,
            bgIndex: 3,
            breaksToFinish: 30,
            shapes: IOShape.allValues,
            probs: [
                Corner => 2,
                Tee => 1,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 1,
                DoubleCorner => 1,
                Crossover => 2,
                Empty => 1
            ],
        },
        {
            num: 5,
            bgIndex: 4,
            breaksToFinish: 40,
            shapes: IOShape.allValues,
            probs: [
                Corner => 2,
                Tee => 2,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 1.5,
                DoubleCorner => 2,
                Crossover => 2,
                Empty => 1.5
            ],
        },
        {
            num: 6,
            bgIndex: 5,
            breaksToFinish: 99999,
            shapes: IOShape.allValues,
            probs: [
                Corner => 2,
                Tee => 2,
                Straight => 4,
                Plus => 2,
                OneWay => 0,
                Dead => 2,
                DoubleCorner => 2,
                Crossover => 2,
                Empty => 2
            ],
        }
    ];

    public static function currentLevelConfig():SingleLevel {
        return levels[currentLevel];
    }

    public static function nextLevel() {
        var nextLevelNum: Int = currentLevel + 1;
        currentLevel = Std.int(FlxMath.bound(nextLevelNum, 0, levels.length - 1));
        Gameplay.onLevelChange.dispatch();
    }
}

typedef SingleLevel = {
    var num:Int;
    var bgIndex:Int;
    var breaksToFinish:Int;
    var shapes: Array<IOShape>;
    var probs: Map<NodeType, Float>;
}