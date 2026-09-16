package funkin.mobile.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.Page;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.ui.TextMenuList;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.ui.options.items.EnumPreferenceItem;
import funkin.ui.options.OptionsState.OptionsMenuPageName;
import funkin.mobile.ui.FunkinHitbox.FunkinHitboxControlSchemes;
import funkin.mobile.ui.FunkinBackButton;

class MobileOptions extends Page<OptionsMenuPageName>
{
  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var preferenceDesc:Array<String> = [];
  var itemDesc:FlxText;
  var itemDescBox:FunkinSprite;
  var menuCamera:FlxCamera;
  var hudCamera:FlxCamera;
  var camFollow:FlxObject;

  public function new()
  {
    super();

    menuCamera = new FunkinCamera('mobileOptionsMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;

    hudCamera = new FlxCamera();
    FlxG.cameras.add(hudCamera, false);
    hudCamera.bgColor = 0x0;

    camera = menuCamera;

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    add(itemDescBox = new FunkinSprite());
    itemDescBox.cameras = [hudCamera];

    add(itemDesc = new FlxText(0, 0, 1180, null, 32));
    itemDesc.cameras = [hudCamera];

    createPrefItems();
    createPrefDescription();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);

    menuCamera.follow(camFollow, null, 0.085);

    var margin:Int = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, menuCamera.height - margin * 2);
    menuCamera.minScrollY = 0;

    items.onChange.add(function(selected)
    {
      itemDesc.text = preferenceDesc[items.selectedIndex];
    });

    #if FEATURE_TOUCH_CONTROLS
    var backButton:FunkinBackButton = new FunkinBackButton(FlxG.width - 230, FlxG.height - 200, exit, 1.0);
    add(backButton);
    #end
  }

  function createPrefDescription():Void
  {
    itemDescBox.makeSolidColor(1, 1, FlxColor.BLACK);
    itemDescBox.alpha = 0.6;
    itemDesc.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    itemDesc.borderSize = 3;

    itemDesc.text = preferenceDesc[items.selectedIndex];
    itemDesc.screenCenter();
    itemDesc.y += 270;

    itemDescBox.setPosition(itemDesc.x - 10, itemDesc.y - 10);
    itemDescBox.setGraphicSize(Std.int(itemDesc.width + 20), Std.int(itemDesc.height + 25));
    itemDescBox.updateHitbox();
  }

  function createPrefItems():Void
  {
    createPrefItemEnum('Hitbox Mode', 'Changes the layout of the touch controls used during gameplay.', [
      "Arrows" => FunkinHitboxControlSchemes.Arrows,
      "Four Lanes" => FunkinHitboxControlSchemes.FourLanes
    ], function(key:String, value:FunkinHitboxControlSchemes):Void
    {
      funkin.Preferences.controlsScheme = value;
    }, switch (funkin.Preferences.controlsScheme)
      {
        case FunkinHitboxControlSchemes.FourLanes:
          "Four Lanes";
        default:
          "Arrows";
      });
  }

  function createPrefItemEnum<T>(prefName:String, prefDesc:String, values:Map<String, T>, onChange:String->T->Void, defaultKey:String):Void
  {
    var item = new EnumPreferenceItem<T>(funkin.ui.FullScreenScaleMode.gameNotchSize.x, (120 * items.length) + 30, prefName, values, defaultKey, onChange);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (items != null) camFollow.y = items.selectedItem.y;

    items.forEach(function(daItem:TextMenuItem)
    {
      var textWidth:Int = 0;

      switch (Type.typeof(daItem))
      {
        case TClass(EnumPreferenceItem):
          textWidth = cast(daItem, EnumPreferenceItem<Dynamic>).lefthandText.getWidth();
        default:
      }

      var offset:Int = textWidth - 75;
      offset += (items.selectedItem == daItem) ? 150 : 120;

      daItem.x = offset + funkin.ui.FullScreenScaleMode.gameNotchSize.x;
    });
  }

  override function exit():Void
  {
    camFollow.setPosition(640, 30);
    menuCamera.snapToTarget();
    super.exit();
  }
}
