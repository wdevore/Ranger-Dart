part of ranger;

/**
 * Base class for [Sprite]s.
 */
abstract class SpriteBase {
  int width;
  int height;
  
  /// 0 = single frame only.
  int frameRate;
  /// How many frames make up the animation.
  int frameCount;
  
  /**
   * We need to know what type of coordinate system the sprite sheet
   * was creating in so we can match it to [Ranger]'s system defined
   * [CONFIG.base_coordinate_system] default is [True].
   * 
   * If your sprite application generated a sheet with +Y pointing
   * downward then set the 'CoordSystem' json field to [False].
   */
  bool coordSystem = false;
  
  /**
   * [playDirection] is dependent on the coordinate system being either
   * left or right. Your sprite sheet is most likely defined in a system
   * where the origin is in the top-left corner.
   * 
   * The largest effect is if your animation frames have what appear as
   * a rotations.
   * 
   * if [CONFIG.base_coordinate_system] is true then [Ranger]'s system
   * has +Y pointing 'upward', but if your sprite application generated
   * a sheet expecting +Y to point 'downward' your sprite animation will
   * appear to animate "backwards".
   * 
   * True = forward
   */
  bool playDirection;

}
