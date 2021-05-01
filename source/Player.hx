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
	var jumpHold:FlxActionDigital;
	var shoot:FlxActionDigital;
	var jump2:FlxActionDigital;

	var mobileUILeft:FlxSprite;
	var mobileUIRight:FlxSprite;
	var mobileUIAction1:FlxSprite;
	var mobileUIAction2:FlxSprite;

	// states
	var grounded:Bool;
	var wallSlideLeft:Bool = false;
	var wallSlideRight:Bool = false;
	var doingJump2:Bool = false;

	var bullets:FlxTypedGroup<Bullet>;

	static var MAX_VELOCITY_X:Int = 400;
	static var MAX_VELOCITY_Y:Int = 2000;

	static var JUMP_FORCE:Int = 900;
	static var JUMP_2_FORCE:Int = 1200;
	static var JUMP_WARP:Int = 15;
	static var JUMP_2_WARP:Int = 20;
	// warp is my lingo for moving the player a certain distance
	/** force applied downwards when jump isnt held **/
	static var JUMP_PUSH_FORCE:Int = 50;

	static var GRAVITY:Int = 2000;

	static var WALL_JUMP_FORCE_X:Int = 900;
	static var WALL_JUMP_FORCE_Y:Int = 700;
	static var WALL_SLIDE_GRAVITY:Int = 200;
	static var WALL_SLIDE_MAX_VELOCITY:Int = 200;

	static var MOVE_SPEED:Int = 3000;
	static var DRAG_X:Int = 3000;
	static var DRAG_X_AIRBORNE:Int = 400;

	public function new(psBullets:FlxTypedGroup<Bullet>)
	{
		super(500, 100);

		makeGraphic(35, 35, FlxColor.RED);
		maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y); // max move speed, fall speed
		// PROB fall speed doesnt seem to be effected. is it controlled by something else?
		acceleration.y = GRAVITY;
		drag.x = DRAG_X;

		bullets = psBullets;

		// INPUT SETUP
		right = new FlxActionDigital().addKey(RIGHT, PRESSED).addGamepad(DPAD_RIGHT, PRESSED);
		left = new FlxActionDigital().addKey(LEFT, PRESSED).addGamepad(DPAD_LEFT, PRESSED);
		jump = new FlxActionDigital().addKey(F, JUST_PRESSED).addGamepad(B, JUST_PRESSED);
		jumpHold = new FlxActionDigital().addKey(F, PRESSED).addGamepad(B, PRESSED);
		shoot = new FlxActionDigital().addKey(S, JUST_PRESSED).addGamepad(RIGHT_TRIGGER, JUST_PRESSED);
		jump2 = new FlxActionDigital().addKey(D, JUST_PRESSED).addGamepad(A, JUST_PRESSED);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([right, left, jump, jumpHold, shoot, jump2]);

		FlxG.watch.add(this, "grounded");
		FlxG.watch.add(this, "wallSlideLeft");
		FlxG.watch.add(this, "wallSlideRight");
		FlxG.watch.add(acceleration, "x");
		FlxG.watch.add(drag, "x");
		FlxG.watch.add(this, "doingJump2");
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
			drag.x = DRAG_X_AIRBORNE;
		}
		// FIXME this doesnt need to update each frame, should happen once at grounded change

		grounded = (isTouching(FlxObject.DOWN) && velocity.y == 0);
		if (grounded)
		{
			doingJump2 = false;
		}

		updateInput();

		if ((wallSlideLeft || wallSlideRight) && velocity.y > 0)
		{
			acceleration.y = WALL_SLIDE_GRAVITY;
			maxVelocity.y = WALL_SLIDE_MAX_VELOCITY;
		}
		else
		{
			acceleration.y = GRAVITY;
			maxVelocity.y = MAX_VELOCITY_Y;
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

		// jump push
		if (!jumpHold.triggered && !action1M && velocity.y < 0 && !doingJump2)
		{
			velocity.y += JUMP_PUSH_FORCE;
		}

		wallslideCheck((left.triggered || leftM), (right.triggered || rightM));
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
		{
			velocity.y = -JUMP_FORCE;
			y -= JUMP_WARP;
		}
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
		y -= JUMP_2_WARP;
		// TODO check if there's collision some distance adove, if so don't apply warp
		velocity.y = -JUMP_2_FORCE;
		doingJump2 = true;
	}

	function doShoot()
	{
		// bullets.recycle(Bullet.new).set(getMidpoint());
	}

	/**
		called each frame to update wallslide state
	**/
	function wallslideCheck(leftInput:Bool, rightInput:Bool)
	{
		// set true
		if (leftInput && isTouching(FlxObject.LEFT) && !grounded)
		{
			wallSlideLeft = true;
			makeGraphic(35, 35, FlxColor.WHITE);
		}
		else if (rightInput && isTouching(FlxObject.RIGHT) && !grounded)
		{
			wallSlideRight = true;
			makeGraphic(35, 35, FlxColor.WHITE);
		}

		// while true
		if (!leftInput && !rightInput)
		{
			if (wallSlideLeft)
				moveLeft();
			else if (wallSlideRight)
				moveRight();
		}

		// set false
		if (wallSlideLeft && !isTouching(FlxObject.LEFT) || grounded)
		{
			wallSlideLeft = false;
			makeGraphic(35, 35, FlxColor.RED);
		}
		else if (wallSlideRight && !isTouching(FlxObject.RIGHT) || grounded)
		{
			wallSlideRight = false;
			color.lightness = 1;
			makeGraphic(35, 35, FlxColor.RED);
		}

		// NOTE wallslides are mutually exclusive. left has priority
	}

	public function passMobileUISprites(left:FlxSprite, right:FlxSprite, action1:FlxSprite, action2:FlxSprite)
	{
		mobileUILeft = left;
		mobileUIRight = right;
		mobileUIAction1 = action1;
		mobileUIAction2 = action2;
	}
}
