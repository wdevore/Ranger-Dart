part of ranger;

/** 
 * [UniformScaleMixin] is a mixin.
 * Mix with a [BaseNode] that you want Uniform Scale [Animation]s applied to.
 */
abstract class UniformScaleMixin {
  // Instead of having each Node check this behavior for a dirty state
  // This behavior notifies the Node.
  BaseNode node;
  double _initialUniformScale = 1.0;
  double _changingUniformScale = 1.0;

  double get initialUniformScale => _initialUniformScale;

  void initWithScale(BaseNode node, double scale) {
    this.node = node;
    _initialUniformScale = scale;
    _changingUniformScale = scale;
  }
  
  void reset() {
    _changingUniformScale = _initialUniformScale;
  }
  
  double get uniformScale => _changingUniformScale;

  void set uniformScale(double scale) {
    _changingUniformScale = scale;
    node.dirty = true;
  }
}

