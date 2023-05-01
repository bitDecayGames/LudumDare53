package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import plugins.ScoreModifierPlugin;
import input.SimpleController;
import bitdecay.flixel.debug.DebugDraw;
import flixel.FlxState;
import ui.MenuCursor;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import ui.font.BitmapText;
import bitdecay.flixel.transitions.TransitionDirection;
import bitdecay.flixel.transitions.SwirlTransition;
import states.AchievementsState;
import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;

using states.FlxStateExt;

#if windows
import lime.system.System;
#end

class FailState extends FlxState {
	var gameCursor:MenuCursor;
	var startArea = FlxRect.get(195, 285 + 43, 95, 28);

	var buttonActive = false;
	var done = false;
	var mainMenuItem:FlxSprite;

	override public function create():Void {

		var finalScoreLabel = new CyberRed("Final Score");
		finalScoreLabel.screenCenter();
		finalScoreLabel.y -= 16;
		add(finalScoreLabel);

		var finalScoreValue = new CyberWhite('${ScoreModifierPlugin.scoreValue}');
		finalScoreValue.screenCenter();
		finalScoreValue.y += 16;
		add(finalScoreValue);

		mainMenuItem = new CyberWhite('Main menu');
		mainMenuItem.screenCenter();
		mainMenuItem.y = FlxG.height - 50;
		mainMenuItem.alpha = 0;
		add(mainMenuItem);

		gameCursor = new MenuCursor();
		gameCursor.visible = false;
		add(gameCursor);

		gameCursor.select(FlxRect.get(mainMenuItem.x-14, mainMenuItem.y-3, mainMenuItem.width+28, mainMenuItem.height+4));

		super.create();

		// FmodManager.PlaySong(FmodSongs.LetsGo);
		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		// transOut = null;

		new FlxTimer().start(3, (t) -> {

			FlxTween.tween(mainMenuItem, { alpha: 1 }, {
				onComplete: (t) -> {
					gameCursor.visible = true;
					buttonActive = true;
				}
			});

		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (buttonActive && SimpleController.just_pressed(A)) {
			// TODO SFX: Menu item selected
			FmodFlxUtilities.TransitionToState(new MainMenuState());
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
