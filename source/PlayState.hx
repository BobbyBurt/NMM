package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

// import entities.Interactive;
class PlayState extends FlxState
{
	var level:FlxTilemap;

	var bullets:FlxTypedGroup<Bullet>;

	var mobileUILeft:FlxSprite;
	var mobileUIRight:FlxSprite;
	var mobileUIAction1:FlxSprite;
	var mobileUIAction2:FlxSprite;

	var player:Player;

	override public function create()
	{
		FlxG.camera.bgColor = 0xffaaaaaa;
		FlxG.mouse.visible = !Reg.mobile;

		FlxG.camera.bgColor = FlxColor.BLACK;
		level = new FlxTilemap();
		level.loadMapFromCSV(FlxStringUtil.imageToCSV("assets/map2.png", false, 1), "assets/tiles.png", 0, 0, ALT);
		level.follow();
		add(level);

		bullets = new FlxTypedGroup<Bullet>(20);
		add(bullets);

		player = new Player(bullets);
		add(player);

		FlxG.camera.follow(player, PLATFORMER, 1);
		// FlxG.camera.zoom = 2;
		// this causes issues with UI, at least the way I'm setting them up.

		if (Reg.mobile)
			setupMobileButtons();
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(player, level);

		super.update(elapsed);
	}

	function setupMobileButtons()
	{
		mobileUILeft = new FlxSprite(0, 340);
		mobileUILeft.makeGraphic(200, 300, FlxColor.GREEN, false);
		mobileUILeft.immovable = true;
		mobileUILeft.scrollFactor.set(0, 0);
		mobileUILeft.alpha = 0.2;
		add(mobileUILeft);

		mobileUIRight = new FlxSprite(0, 40);
		mobileUIRight.makeGraphic(200, 300, FlxColor.BLUE, false);
		mobileUIRight.immovable = true;
		mobileUIRight.scrollFactor.set(0, 0);
		mobileUIRight.alpha = 0.2;
		add(mobileUIRight);

		mobileUIAction1 = new FlxSprite(1180, 40);
		mobileUIAction1.makeGraphic(200, 300, FlxColor.YELLOW, false);
		mobileUIAction1.immovable = true;
		mobileUIAction1.scrollFactor.set(0, 0);
		mobileUIAction1.alpha = 0.2;
		add(mobileUIAction1);

		mobileUIAction2 = new FlxSprite(1180, 340);
		mobileUIAction2.makeGraphic(200, 300, FlxColor.RED, false);
		mobileUIAction2.immovable = true;
		mobileUIAction2.scrollFactor.set(0, 0);
		mobileUIAction2.alpha = 0.2;
		add(mobileUIAction2);

		player.passMobileUISprites(mobileUILeft, mobileUIRight, mobileUIAction1, mobileUIAction2);
	}
}
