part of ranger;

/** 
 * [Color4Mixin] is a mixin.
 * It only supports 1 color. You are either "filling" a [Node] or "outlining"
 * a [Node].
 * Create a new mixin if for more advanced behavior.
 * Mix with a [BaseNode] that you want Color [Animation]s applied towards.
 */
abstract class Color4Mixin {
  Color4<int> initialColor = Color4IWhite;
  Color4<int> changingColor = Color4IWhite;

  Color4<int> get displayedColor => initialColor;

  void initWithColor(Color4<int> color) {
    initialColor.r = color.r;
    initialColor.g = color.g;
    initialColor.b = color.b;
    initialColor.a = color.a;

    changingColor.r = color.r;
    changingColor.g = color.g;
    changingColor.b = color.b;
    changingColor.a = color.a;
  }
  
  void reset() {
    changingColor.r = initialColor.r;
    changingColor.g = initialColor.g;
    changingColor.b = initialColor.b;
    changingColor.a = initialColor.a;
  }
  
  void release() {
    initialColor.moveToPool();
    changingColor.moveToPool();
  }
  
  // ----------------------------------------------------------
  // Opacity
  // ----------------------------------------------------------
  int get opacity => changingColor.a;
  
  /**
   * Override synthesized setOpacity to recurse through Layer hiearchy.
   * [opacity] ranges from 0 -> 255.
   */
  void set opacity(int opacity) {
    changingColor.a = opacity;
  }
  
  // ----------------------------------------------------------
  // Color
  // ----------------------------------------------------------
  Color4<int> get color => changingColor;

  /**
   * If cascasding is enabled then children's colors are set as well.
   * Alpha is ignored. Use [opacity].
   */
  void set color(Color4<int> c) {
    changingColor.r = c.r;
    changingColor.g = c.g;
    changingColor.b = c.b;
    changingColor.b = c.b;
  }
}

