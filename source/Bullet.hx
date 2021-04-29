package;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bullet extends FlxSprite
{
    public function new()
    {
        super();
        loadGraphic("assets/bullet-bill.png", false);
        solid = false;
    }

    public function set(location:FlxPoint)
    {
        super.reset(location.x, location.y);
    }
}