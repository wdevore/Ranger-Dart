part of ranger;

/** 
 * [PositionalBehavior] is a mixin.
 * Mix with a [BaseNode] that you want positional [Animation]s applied to.
 */
abstract class PositionalBehavior {
  BaseNode node;
  Vector2 _position = new Vector2.zero();

  void initWithPositionVector(BaseNode node, Vector2 position) {
    this.node = node;
    _position.setFrom(position);
  }
  
  void initWithPositionComponents(BaseNode node, double x, double y) {
    this.node = node;
    _position.setValues(x, y);
  }
  
  Vector2 get position => _position;

  set position(Vector2 position) {
    _position.setFrom(position);
    node.dirty = true;
  }
  
  set positionX(double v) {
    _position.x = v;
    node.dirty = true;
  }

  set positionY(double v) {
    _position.y = v;
    node.dirty = true;
  }

  void setPosition(double x, double y) {
    _position.setValues(x, y);
    node.dirty = true;
  }
  
  void moveByComp(double x, double y) {
    _position.setValues(_position.x + x, _position.y + y);
    node.dirty = true;
  }

  void moveBy(Vector2 v) {
    _position.setValues(_position.x + v.x, _position.y + v.y);
    node.dirty = true;
  }
}

