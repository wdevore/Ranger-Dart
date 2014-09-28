part of unittests;

/**
 * This node is an example of using the [Color4Mixin] mixin so that
 * the node interact with the [TweenAnimation] accessor.
 */
class PointColor4I extends Ranger.Node with Ranger.Color4Mixin {
  String outlineColor;
  
  double outlineThickness = 3.0;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  PointColor4I();
  
  PointColor4I._();
  factory PointColor4I.pooled() {
    PointColor4I poolable = new Ranger.Poolable.of(PointColor4I, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory PointColor4I.initWith(Ranger.Color4<int> fillColor, [Ranger.Color4<int> outlineColor, double fromScale = 1.0]) {
    PointColor4I poolable = new PointColor4I.pooled();
    if (poolable.init()) {
      poolable.initWithColor(fillColor);
      poolable.outlineColor = outlineColor.toString();
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static PointColor4I _createPoolable() => new PointColor4I._();

  PointColor4I clone() {
    PointColor4I poolable = new PointColor4I.pooled();
    
    if (poolable.initWith(this)) {
      poolable.initWithColor(initialColor);
      poolable.outlineColor = outlineColor;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    
    return null;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = color.toString();
    context.drawColor = outlineColor;
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;
    
    context.drawPointAt(0.0, 0.0);

    context.restore();

    Ranger.Application.instance.objectsDrawn++;
  }

}
