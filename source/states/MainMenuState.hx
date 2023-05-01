package states;

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

class MainMenuState extends FlxState {
	var gameCursor:MenuCursor;
	var startArea = FlxRect.get(195, 285 + 43, 95, 28);
	var creditArea = FlxRect.get(175, 318 + 43, 134, 28);

	var selectedIndex = 0;

	override public function create():Void {
		var titleImage = new FlxSprite(AssetPaths.title__png);
		add(titleImage);

		gameCursor = new MenuCursor();
		add(gameCursor);

		super.create();

		// FmodManager.PlaySong(FmodSongs.LetsGo);
		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		// transOut = null;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.pressed.D && FlxG.keys.justPressed.M) {
			// Keys D.M. for Disable Metrics
			Bitlytics.Instance().EndSession(false);
			FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			trace("---------- Bitlytics Stopped ----------");
		}

		if (SimpleController.just_pressed(UP) && selectedIndex != 0) {
			selectedIndex = 0;
			FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
		}

		if (SimpleController.just_pressed(DOWN) && selectedIndex != 1) {
			selectedIndex = 1;
			FmodManager.PlaySoundOneShot(FmodSFX.CursorMove);
		}

		if (SimpleController.just_pressed(A)) {
			// TODO SFX: Menu item selected
			if (selectedIndex == 0) {
				FmodManager.PlaySoundOneShot(FmodSFX.TileClear);
				clickPlay();
			} else {
				FmodManager.PlaySoundOneShot(FmodSFX.TileClear);
				clickCredits();
			}
		}

		if (selectedIndex == 0) {
			gameCursor.select(startArea);
		} else {
			gameCursor.select(creditArea);
		}

		DebugDraw.ME.drawWorldRect(startArea.x, startArea.y, startArea.width, startArea.height);
		DebugDraw.ME.drawWorldRect(creditArea.x, creditArea.y, creditArea.width, creditArea.height);
	}

	function clickPlay():Void {
		FmodFlxUtilities.TransitionToState(new PlayState());

		// FmodManager.StopSong();
		// var swirlOut = new SwirlTransition(TransitionDirection.OUT, () -> {
		// 	// make sure our music is stopped;
		// 	FmodManager.StopSongImmediately();
		// 	FlxG.switchState(new PlayState());
		// }, FlxColor.GRAY, 0.75);
		// openSubState(swirlOut);
	}

	function clickCredits():Void {
		FmodFlxUtilities.TransitionToState(new CreditsState());
	}

	function clickAchievements():Void {
		FmodFlxUtilities.TransitionToState(new AchievementsState());
	}

	#if windows
	function clickExit():Void {
		System.exit(0);
	}
	#end

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
