part of ranger;

/** 
 * [ScaleBehavior] is a mixin.
 * Mix with a [BaseNode] that you want Scale [Animation]s applied to.
 */
abstract class ScaleBehavior {
  BaseNode node;
  Vector2 _scale = new Vector2(1.0, 1.0);

  void initWithScaleVector(BaseNode node, Vector2 scale) {
    this.node = node;
    _scale.setFrom(scale);
  }
  
  void initWithScaleComponents(BaseNode node, double x, double y) {
    this.node = node;
    _scale.setValues(x, y);
  }
  
  void initWithUniformScale(BaseNode node, double s) {
    this.node = node;
    _scale.setValues(s, s);
  }
  
  Vector2 get scale => _scale;

  set scale(Vector2 scale) {
    _scale.setFrom(scale);
    node.dirty = true;
  }
  
  set scaleX(double v) {
    _scale.x = v;
    node.dirty = true;
  }

  set scaleY(double v) {
    _scale.y = v;
    node.dirty = true;
  }

  get scaleX => _scale.x;
  get scaleY => _scale.y;
  
  void scaleTo(double x, double y) {
    _scale.setValues(x, y);
    node.dirty = true;
  }

  set uniformScale(double s) {
    _scale.setValues(s, s);
    node.dirty = true;
  }
  
  double get uniformScale => _scale.x;
  
}

