part of ranger;

/** 
 * [SkewBehavior] is a mixin.
 * Mix with a [NodeWithSkew] that you want Skew [Animation]s applied to.
 */
abstract class SkewBehavior {
  NodeWithSkew node;
  Vector2 _initialSkew = new Vector2(0.0, 0.0);
  Vector2 _changingSkew = new Vector2(0.0, 0.0);

  Vector2 get initialSkew => _initialSkew;

  void initWithSkewVector(NodeWithSkew node, Vector2 skew) {
    this.node = node;
    _initialSkew.setFrom(skew);
    _changingSkew.setFrom(skew);
  }
  
  void initWithSkewComponents(NodeWithSkew node, double x, double y) {
    this.node = node;
    _initialSkew.setValues(x, y);
    _changingSkew.setValues(x, y);
  }
  
  void initWithSkewUniform(NodeWithSkew node, double s) {
    this.node = node;
    _initialSkew.setValues(s, s);
    _changingSkew.setValues(s, s);
  }
  
  void reset() {
    _changingSkew.setFrom(_initialSkew);
  }
  
  Vector2 get skew => _changingSkew;

  /// [skew] in radians
  void set skew(Vector2 skew) {
    _changingSkew.setFrom(skew);
    node.dirty = true;
  }
  
  /// [v] in radians
  void set skewX(double v) {
    _changingSkew.x = v;
    node.dirty = true;
  }

  /// [skewToX] and [skewToY] are typically used by animations.
  set skewToX(double v) {
    _initialSkew.x = v;
    _changingSkew.x = v;
    node.dirty = true;
  }

  set skewToY(double v) {
    _initialSkew.y = v;
    _changingSkew.y = v;
    node.dirty = true;
  }

  /// [v] in radians
  void set skewY(double v) {
    _changingSkew.y = v;
    node.dirty = true;
  }

}

