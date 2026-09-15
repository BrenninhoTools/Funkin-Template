package;

import lime.system.System;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import funkin.ui.FullScreenScaleMode;
import funkin.Preferences;
import funkin.PlayerSettings;
import funkin.util.logging.CrashHandler;
import funkin.ui.debug.FunkinDebugDisplay;
import funkin.ui.debug.FunkinDebugDisplay.DebugDisplayMode;
import funkin.save.Save;
import funkin.FunkinMemory;
import funkin.audio.FunkinSound;
#if hxvlc
import hxvlc.util.Handle;
#end
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.media.Video;
import openfl.net.NetStream;
import funkin.util.WindowUtil;

class Main extends Sprite
{
  var gameWidth:Int = 1280;
  var gameHeight:Int = 720;
  var initialState:Class<FlxState> = funkin.InitState;
  var zoom:Float = -1;
  var skipSplash:Bool = true;

  public static function main():Void
  {
    #if android
    Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.content.Context.getExternalFilesDir()));
    #elseif ios
    Sys.setCwd(haxe.io.Path.addTrailingSlash(lime.system.System.documentsDirectory));
    #end

    CrashHandler.initialize();
    CrashHandler.queryStatus();

    Lib.current.addChild(new Main());
  }

  public function new()
  {
    super();

    haxe.Log.trace = funkin.util.logging.AnsiTrace.trace;
    funkin.util.logging.AnsiTrace.traceBF();

    openfl.utils._internal.Log.level = openfl.utils._internal.Log.LogLevel.INFO;

    funkin.modding.PolymodHandler.loadAllMods();

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

    #if (!html5 && !mobile)
    openfl.Lib.application.onExit.add((_) ->
    {
      funkin.audio.FunkinSound.stopAllAudio(true, true);
      funkin.FunkinMemory.purgeCache(true);

      openfl.Assets.cache.clear();

      Sys.exit(0);
    }, 99);
    #end

    var context = stage.window.context.type;
    if (context != WEBGL && context != OPENGL && context != OPENGLES)
    {
      var tech:String = #if web 'WebGL' #elseif desktop 'OpenGL' #else 'OpenGL ES' #end;
      var requiredVersion:String = #if web '$tech 1.0 or newer' #elseif desktop '$tech 3.0 or newer' #else '$tech 2.0 or newer' #end;
      var desc:String = 'Failed to initialize the $tech rendering context!\n\n';
      #if web
      desc += 'Make sure your graphics card supports $requiredVersion, your graphics drivers are up to date, and hardware acceleration is enabled on your browser.';
      #elseif desktop
      desc += 'Make sure your graphics card supports $requiredVersion, and your graphics drivers are up to date.';
      #else
      desc += 'Make sure your device supports $requiredVersion.';
      #end

      WindowUtil.showError('Failed to initialize $tech', desc);
      System.exit(1);
    }

    setupGame();
  }

  public static var debugDisplay:FunkinDebugDisplay;

  function setupGame():Void
  {
    #if FEATURE_HAXEUI
    initHaxeUI();
    #end

    debugDisplay = new FunkinDebugDisplay(10, 10, 0xFFFFFF);

    FlxG.signals.postUpdate.add(handleDebugDisplayKeys);

    #if mobile
    FlxG.signals.preUpdate.add(repositionCounters.bind(true));
    #end

    Save.load();

    #if hxvlc
    Handle.initAsync(function(success:Bool):Void {});
    #end

    WindowUtil.setVSyncMode(funkin.Preferences.vsyncMode);

    untyped FlxG.cameras = new funkin.graphics.FunkinCameraFrontEnd();

    var framerate:Int = Preferences.unlockedFramerate ? 0 : Preferences.framerate;

    var game:FlxGame = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash,
      (FlxG.stage.window.fullscreen || Preferences.autoFullscreen));

    @:privateAccess
    game._customSoundTray = funkin.ui.options.FunkinSoundTray;

    addChild(game);

    #if FEATURE_DEBUG_FUNCTIONS
    #if !FLX_NO_DEBUG game.debugger.interaction.addTool(new funkin.util.TrackerToolButtonUtil()); #end
    funkin.util.macro.ConsoleMacro.init();
    #end

    #if !html5
    FlxG.scaleMode = new FullScreenScaleMode();
    #end

    #if mobile
    repositionCounters(false);
    #end
  }

  #if FEATURE_HAXEUI
  function initHaxeUI():Void
  {
    haxe.ui.locale.LocaleManager.instance.autoSetLocale = false;
    haxe.ui.Toolkit.init();
    haxe.ui.Toolkit.theme = 'dark';
    haxe.ui.Toolkit.autoScale = false;
    haxe.ui.focus.FocusManager.instance.autoFocus = false;
    funkin.input.Cursor.registerHaxeUICursors();
    haxe.ui.tooltips.ToolTipManager.defaultDelay = 200;
  }
  #end

  function handleDebugDisplayKeys():Void
  {
    if (PlayerSettings.player1.controls == null || !PlayerSettings.player1.controls.check(DEBUG_DISPLAY)) return;

    var nextMode:DebugDisplayMode;

    switch (Preferences.debugDisplay)
    {
      case DebugDisplayMode.Off:
        nextMode = DebugDisplayMode.Simple;
      case DebugDisplayMode.Simple:
        nextMode = DebugDisplayMode.Advanced;
      case DebugDisplayMode.Advanced:
        nextMode = DebugDisplayMode.Off;
    }

    Preferences.debugDisplay = nextMode;
  }

  #if mobile
  function repositionCounters(lerp:Bool):Void
  {
    var scale:Float = Math.max(Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height), 1);

    if (debugDisplay != null)
    {
      debugDisplay.scaleX = debugDisplay.scaleY = scale;

      if (FlxG.game != null)
      {
        final thypos:Float = Math.max(FullScreenScaleMode.notchSize.x, 10);

        if (lerp)
        {
          debugDisplay.x = flixel.math.FlxMath.lerp(debugDisplay.x, FlxG.game.x + thypos, FlxG.elapsed * 3);
        }
        else
        {
          debugDisplay.x = FlxG.game.x + thypos;
        }

        debugDisplay.y = FlxG.game.y + (3 * scale);
      }
    }
  }
  #end
}
