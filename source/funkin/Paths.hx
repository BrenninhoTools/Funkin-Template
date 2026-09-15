package funkin;

import flixel.graphics.frames.FlxAtlasFrames;
import animate.FlxAnimateFrames;
import funkin.graphics.FunkinSprite.AtlasSpriteSettings;
import openfl.utils.AssetType;
import funkin.util.macro.ConsoleMacro;
import haxe.io.Path;

@:nullSafety
class Paths implements ConsoleClass
{
  static var currentLevel:Null<String> = null;

  public static function setCurrentLevel(name:Null<String>):Void
  {
    currentLevel = name == null ? null : name.toLowerCase();
  }

  public static function stripLibrary(path:String):String
  {
    var parts:Array<String> = path.split(':');
    return parts.length < 2 ? path : parts[1];
  }

  public static function getLibrary(path:String):String
  {
    var parts:Array<String> = path.split(':');
    return parts.length < 2 ? 'preload' : parts[0];
  }

  static function getPath(file:String, type:AssetType, library:Null<String>):String
  {
    if (library != null) return getLibraryPath(file, library);

    if (currentLevel != null)
    {
      var levelPath:String = getLibraryPathForce(file, currentLevel);
      if (Assets.exists(levelPath, type)) return levelPath;
    }

    var sharedPath:String = getLibraryPathForce(file, 'shared');
    if (Assets.exists(sharedPath, type)) return sharedPath;

    return getPreloadPath(file);
  }

  public static function getLibraryPath(file:String, library:String = 'preload'):String
  {
    return (library == 'preload' || library == 'default') ? getPreloadPath(file) : getLibraryPathForce(file, library);
  }

  static inline function getLibraryPathForce(file:String, library:String):String
  {
    return '$library:assets/$library/$file';
  }

  static inline function getPreloadPath(file:String):String
  {
    return 'assets/$file';
  }

  public static function file(file:String, type:AssetType = TEXT, ?library:String):String
  {
    return getPath(file, type, library);
  }

  public static function animateAtlas(path:String, ?library:String):String
  {
    return getLibraryPath('images/$path', library ?? 'preload');
  }

  public static function txt(key:String, ?library:String):String
  {
    return getPath('data/$key.txt', TEXT, library);
  }

  public static function frag(key:String, ?library:String):String
  {
    return getPath('shaders/$key.frag', TEXT, library);
  }

  public static function vert(key:String, ?library:String):String
  {
    return getPath('shaders/$key.vert', TEXT, library);
  }

  public static function xml(key:String, ?library:String):String
  {
    return getPath('data/$key.xml', TEXT, library);
  }

  public static function json(key:String, ?library:String):String
  {
    return getPath('data/$key.json', TEXT, library);
  }

  public static function srt(key:String, ?library:String, directory:String = 'data/'):String
  {
    return getPath('$directory$key.srt', TEXT, library);
  }

  public static function sound(key:String, ?library:String):String
  {
    return getPath('sounds/$key.${Constants.EXT_SOUND}', SOUND, library);
  }

  public static function soundRandom(key:String, min:Int, max:Int, ?library:String):String
  {
    return sound(key + FlxG.random.int(min, max), library);
  }

  public static function music(key:String, ?library:String):String
  {
    return getPath('music/$key.${Constants.EXT_SOUND}', MUSIC, library);
  }

  public static function videos(key:String, ?library:String):String
  {
    var path:Path = new Path(key);
    var resolvedLibrary:String = library ?? 'videos';

    return path.ext != null ? getPath('videos/${path.file}.${path.ext}', BINARY, resolvedLibrary) : getPath('videos/$key.${Constants.EXT_VIDEO}', BINARY,
      resolvedLibrary);
  }

  public static function voices(song:String, suffix:String = ''):String
  {
    return 'songs:assets/songs/${song.toLowerCase()}/Voices$suffix.${Constants.EXT_SOUND}';
  }

  public static function inst(song:String, suffix:String = '', withExtension:Bool = true):String
  {
    var ext:String = withExtension ? '.${Constants.EXT_SOUND}' : '';
    return 'songs:assets/songs/${song.toLowerCase()}/Inst$suffix$ext';
  }

  public static function image(key:String, ?library:String):String
  {
    return getPath('images/$key.png', IMAGE, library);
  }

  public static function font(key:String):String
  {
    return 'assets/fonts/$key';
  }

  public static function ui(key:String, ?library:String):String
  {
    return xml('ui/$key', library);
  }

  public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
  {
    return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
  }

  public static function getAnimateAtlas(key:String, ?library:String, settings:AtlasSpriteSettings):FlxAnimateFrames
  {
    var graphicKey:String = library != null ? Paths.animateAtlas(key, library) : Paths.animateAtlas(key);

    var validatedSettings:AtlasSpriteSettings = {
      swfMode: settings?.swfMode ?? false,
      cacheOnLoad: settings?.cacheOnLoad ?? false,
      filterQuality: settings?.filterQuality ?? MEDIUM,
      spritemaps: settings?.spritemaps ?? null,
      metadataJson: settings?.metadataJson ?? null,
      cacheKey: settings?.cacheKey ?? null,
      uniqueInCache: settings?.uniqueInCache ?? false,
      onSymbolCreate: settings?.onSymbolCreate ?? null,
      applyStageMatrix: settings?.applyStageMatrix ?? false,
      useRenderTexture: settings?.useRenderTexture ?? false
    };

    if (!Assets.exists('${graphicKey}/Animation.json'))
    {
      throw 'No Animation.json file exists at the specified path (${graphicKey})';
    }

    return FlxAnimateFrames.fromAnimate(graphicKey, validatedSettings.spritemaps, validatedSettings.metadataJson, validatedSettings.cacheKey,
      validatedSettings.uniqueInCache, {
        swfMode: validatedSettings.swfMode,
        cacheOnLoad: validatedSettings.cacheOnLoad,
        filterQuality: validatedSettings.filterQuality,
        onSymbolCreate: validatedSettings.onSymbolCreate
      });
  }

  public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
  {
    return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
  }
}

enum abstract PathsFunction(String)
{
  public var MUSIC;
  public var INST;
  public var VOICES;
  public var SOUND;
}
