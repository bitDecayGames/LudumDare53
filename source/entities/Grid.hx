package entities;

import flixel.FlxSprite;
import plugins.Plugin;

class Grid extends FlxSprite {
	public var nodes:Array<Array<Node>> = [];
	public var plugins:Array<Plugin> = [];
	public var inputs:Array<InputSlot> = [];
	public var outputs:Array<OutputSlot> = [];

	public function new(plugins:Array<Plugin>) {
		super();
		this.plugins = plugins;
		for (i in 0...plugins.length) {
			plugins[i].init(this);
		}

		// TODO: MW set up animation object to handle maybe some subtle grid/background animations
	}

	override public function update(delta:Float) {
		super.update(delta);

		for (i in 0...plugins.length) {
			plugins[i].update(this, delta);
		}
	}
}
