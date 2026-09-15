package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import flixel.FlxGame;
import flixel.FlxState;

class Setup extends Sprite
{
  var gameWidth:Int = 1280;
  var gameHeight:Int = 720;
  var initialState:Class<FlxState> = funkin.InitState;
  var maxSteps:Int = 120;
  var currentStep:Int = 0;

  public static function main():Void
  {
    Lib.current.addChild(new Setup());
  }

  public function new()
  {
    super();

    if (stage != null)
    {
      init();
    }
    else
    {
      addEventListener(Event.ADDED_TO_STAGE, init);
    }
  }

  function init(?event:Event):Void
  {
    if (hasEventListener(Event.ADDED_TO_STAGE))
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    }

    try
    {
      var game:FlxGame = new FlxGame(gameWidth, gameHeight, initialState);
      addChild(game);

      Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame);
    }
    catch (e:Dynamic)
    {
      Sys.println('Sanity check failed during game initialization: $e');
      Sys.exit(1);
    }
  }

  function onFrame(event:Event):Void
  {
    currentStep++;

    if (currentStep >= maxSteps)
    {
      Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onFrame);
      Sys.println('Sanity check passed: game ran for $maxSteps frames without crashing.');
      Sys.exit(0);
    }
  }
}
