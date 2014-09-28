part of ranger;

/** 
 * [RotationBehavior] is a mixin.
 * Mix with a [BaseNode] that you want Rotation [Animation]s applied to.
 */
abstract class RotationBehavior {
  BaseNode node;
  double _rotation = 0.0;
  double _rotationRate = 0.0;
  
  void initWithRotation(BaseNode node, double rotation) {
    this.node = node;
      _rotation = rotation;
  }
  
  double get rotation => _rotation;
  double get rotationInDegrees => _rotation / PIOver180;
  double get rotationRate => _rotationRate;
  
  /**
   * [angle] is in `radians`.
   * Depending on the [CONFIG.BASE_COORDINATE_ORIENTATION] system
   * (aka left or right handed). Rotation will change between systems.
   * If "true", angles specified with POSITIVE values will cause
   * Counter Clockwise (CCW) rotations.
   * If "false" then angles specified with POSITIVE values cause
   * Clockwise (CW) rotations.
   */
  set rotation(double angle) {
    _rotation = angle;
    node.dirty = true;
  }
  
  /**
   * [angle] is in `degrees`.
   * Depending on the [CONFIG.BASE_COORDINATE_ORIENTATION] system
   * (aka left or right handed). Rotation will change between systems.
   * If "true" then angles specified with POSITIVE values cause
   * Counter Clockwise (CCW) rotations.
   * If "false" then angles specified with POSITIVE values cause
   * Clockwise (CW) rotations.
   */
  set rotationByDegrees(double angle) {
    _rotation = angle * PIOver180;
    node.dirty = true;
  }

  /**
   * [rotationRate] applies during animations. 
   */
  set rotationRate(double rate) => _rotationRate = rate;
}

