package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.FlxG;
import flixel.FlxObject;

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

	var jumpForce:Int = 500;
	var jump2Force:Int = 800;
	var gravity:Int = 1200;

	var grounded:Bool;
	var wallSlideLeft:Bool;
	var wallSlideRight:Bool;

	var bullets:FlxTypedGroup<Bullet>;

	public function new(psBullets:FlxTypedGroup<Bullet>)
	{
		super(500, 100);

		makeGraphic(16, 16, FlxColor.RED);
		maxVelocity.set(300, 1000);			// max move speed, fall speed
		acceleration.y = gravity;
		drag.x = maxVelocity.x * 24;

		bullets = psBullets;

		// INPUT SETUP
		right = new FlxActionDigital().addKey(RIGHT, PRESSED).addGamepad(DPAD_RIGHT, PRESSED);
		left = new FlxActionDigital().addKey(LEFT, PRESSED).addGamepad(DPAD_LEFT, PRESSED);
		jump = new FlxActionDigital().addKey(C, JUST_PRESSED) .addGamepad(B, JUST_PRESSED);
		shoot = new FlxActionDigital().addKey(Z, JUST_PRESSED).addGamepad(RIGHT_TRIGGER, JUST_PRESSED);
		jump2 = new FlxActionDigital().addKey(X, JUST_PRESSED).addGamepad(A, JUST_PRESSED);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([right, left, jump, shoot, jump2]);

		FlxG.watch.add(this, "grounded");
		FlxG.watch.add(this, "wallSlideLeft");
		FlxG.watch.add(this, "wallSlideRight");
		FlxG.watch.add(acceleration, "x");
	}

	override public function update(elapsed:Float):Void
	{
		/*
		if (grounded)
		{
			acceleration.x -= 100;
			// drag.x = maxVelocity.x * 24;
		}
		else
		{
			acceleration.x -= 100;
			// drag.x = maxVelocity.x * 10;
		}
		*/
		// FIXME this doesnt need to update each frame, should happen once at grounded change
		
		updateInput();
		
		grounded = isTouching(FlxObject.DOWN);
		wallSlideLeft = (isTouching(FlxObject.LEFT) && !grounded);
		wallSlideRight = (isTouching(FlxObject.RIGHT) && !grounded);
		// possible edge case: both being true? they should be mutually exclusive
		
		if ((wallSlideLeft || wallSlideRight) && velocity.y > 0)
		{
			acceleration.y = 100;
			maxVelocity.y = 150;
		}
		else
		{
			acceleration.y = gravity;
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

		/*
		if (!left.triggered && !right.triggered && !leftM && ! rightM)
		{
			if (wallSlideLeft)
				moveLeft();
			if (wallSlideRight)
				moveRight();
		}
		*/
	}

	function moveLeft():Void
	{
		if (acceleration.x < maxVelocity.x)
			acceleration.x = maxVelocity.x
		else	
			acceleration.x -= drag.x;
	}

	function moveRight():Void
	{
		if (acceleration.x > maxVelocity.x)
			acceleration.x = maxVelocity.x
		else
			acceleration.x += drag.x;
	}

	function doJump():Void
	{
		if (grounded)
			velocity.y = - jumpForce;
		else if (wallSlideLeft)
		{
			velocity.y = - 300;
			velocity.x = 300;
		}
		else if (wallSlideRight)
		{
			velocity.y = - 300;
			velocity.x = -300;
		}
	}

	function doJump2():Void
	{
		velocity.y = -jump2Force;
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
