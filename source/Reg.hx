package;

import flixel.FlxG;

/**
	stores global access variables
**/
class Reg
{
	public static var mobile(default, null):Bool = FlxG.html5.onMobile;
}
