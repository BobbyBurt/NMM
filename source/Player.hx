package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxPath;

class Player extends FlxSprite
{
	static var actions:FlxActionManager;

	var right:FlxActionDigital;
	var left:FlxActionDigital;
	var jump:FlxActionDigital;
	var shoot:FlxActionDigital;
	var jump2:FlxActionDigital;

	var mobileUILeft:FlxSprite;
	var mobileUIRight:FlxSprite;
	var mobileUIAction1:FlxSprite;
	var mobileUIAction2:FlxSprite;

	var grounded:Bool;
	var wallSlideLeft:Bool;
	var wallSlideRight:Bool;

	var bullets:FlxTypedGroup<Bullet>;

	static var JUMP_FORCE:Int = 500;
	static var JUMP_2_FORCE:Int = 800;
	static var WALL_JUMP_FORCE_X:Int = 400;
	static var WALL_JUMP_FORCE_Y:Int = 300;
	static var GRAVITY:Int = 1200;

	static var MOVE_SPEED:Int = 1500;
	static var DRAG_X:Int = 2000;

	public function new(psBullets:FlxTypedGroup<Bullet>)
	{
		super(500, 100);

		makeGraphic(16, 16, FlxColor.RED);
		maxVelocity.set(400, 1000); // max move speed, fall speed
		acceleration.y = GRAVITY;
		drag.x = DRAG_X;

		bullets = psBullets;

		// INPUT SETUP
		right = new FlxActionDigital().addKey(RIGHT, PRESSED).addGamepad(DPAD_RIGHT, PRESSED);
		left = new FlxActionDigital().addKey(LEFT, PRESSED).addGamepad(DPAD_LEFT, PRESSED);
		jump = new FlxActionDigital().addKey(C, JUST_PRESSED).addGamepad(B, JUST_PRESSED);
		shoot = new FlxActionDigital().addKey(Z, JUST_PRESSED).addGamepad(RIGHT_TRIGGER, JUST_PRESSED);
		jump2 = new FlxActionDigital().addKey(X, JUST_PRESSED).addGamepad(A, JUST_PRESSED);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([right, left, jump, shoot, jump2]);

		FlxG.watch.add(this, "grounded");
		FlxG.watch.add(this, "wallSlideLeft");
		FlxG.watch.add(this, "wallSlideRight");
		FlxG.watch.add(acceleration, "x");
		FlxG.watch.add(drag, "x");
	}

	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;

		if (grounded)
		{
			drag.x = DRAG_X;
		}
		else
		{
			drag.x = 500;
		}
		// FIXME this doesnt need to update each frame, should happen once at grounded change

		updateInput();

		grounded = isTouching(FlxObject.DOWN);
		wallSlideLeft = (isTouching(FlxObject.LEFT) && !grounded);
		wallSlideRight = (isTouching(FlxObject.RIGHT) && !grounded);
		// EDGECASE: both being true? they should be mutually exclusive

		if ((wallSlideLeft || wallSlideRight) && velocity.y > 0)
		{
			acceleration.y = 100;
			maxVelocity.y = 150;
		}
		else
		{
			acceleration.y = GRAVITY;
			maxVelocity.y = 1000;
		}

		super.update(elapsed);
	}

	function updateInput()
	{
		var leftM:Bool = false;
		var rightM:Bool = false;
		var action1M:Bool = false;
		var action2M:Bool = false;

		if (Reg.mobile)
		{
			for (touch in FlxG.touches.list)
			{
				if (touch.pressed)
				{
					if (touch.overlaps(mobileUILeft))
						leftM = true;
					if (touch.overlaps(mobileUIRight))
						rightM = true;
					if (touch.overlaps(mobileUIAction1))
						action1M = true;
					if (touch.overlaps(mobileUIAction2))
						action2M = true;
				}
			}
		}

		if (left.triggered || leftM)
			moveLeft();
		if (right.triggered || rightM)
			moveRight();
		if (jump.triggered || action1M)
			doJump();
		if (shoot.triggered)
			doShoot();
		if (jump2.triggered || action2M)
			doJump2();

		// wall magnet
		if (!left.triggered && !right.triggered && !leftM && !rightM)
		{
			if (wallSlideLeft)
				moveLeft();
			if (wallSlideRight)
				moveRight();
		}
	}

	function moveLeft():Void
	{
		acceleration.x = -MOVE_SPEED;
	}

	function moveRight():Void
	{
		acceleration.x = MOVE_SPEED;
	}

	function doJump():Void
	{
		if (grounded)
			velocity.y = -JUMP_FORCE;
		else if (wallSlideLeft)
		{
			velocity.y = -WALL_JUMP_FORCE_Y;
			velocity.x = WALL_JUMP_FORCE_X;
		}
		else if (wallSlideRight)
		{
			velocity.y = -WALL_JUMP_FORCE_Y;
			velocity.x = -WALL_JUMP_FORCE_X;
		}
	}

	function doJump2():Void
	{
		velocity.y = -JUMP_2_FORCE;
	}

	function doShoot()
	{
		bullets.recycle(Bullet.new).set(getMidpoint());
	}

	public function passMobileUISprites(left:FlxSprite, right:FlxSprite, action1:FlxSprite, action2:FlxSprite)
	{
		mobileUILeft = left;
		mobileUIRight = right;
		mobileUIAction1 = action1;
		mobileUIAction2 = action2;
	}
}
