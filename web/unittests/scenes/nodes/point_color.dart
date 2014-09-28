part of unittests;

class PointColor extends Ranger.Node {
  String outlineColor;
  String fillColor;
  
  double outlineThickness = 3.0;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  PointColor();
  
  PointColor._();
  factory PointColor.pooled() {
    PointColor poolable = new Ranger.Poolable.of(PointColor, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory PointColor.initWith(Ranger.Color4<int> fillColor, [Ranger.Color4<int> outlineColor, double fromScale = 1.0]) {
    PointColor poolable = new PointColor.pooled();
    if (poolable.init()) {
      poolable.fillColor = fillColor.toString();
      poolable.outlineColor = outlineColor.toString();
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static PointColor _createPoolable() => new PointColor._();

  PointColor clone() {
    PointColor poolable = new PointColor.pooled();
    
    if (poolable.initWith(this)) {
      poolable.fillColor = fillColor;
      poolable.outlineColor = outlineColor;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    
    return null;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = fillColor;
    context.drawColor = outlineColor;
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;

    context.drawPointAt(0.0, 0.0);

    context.restore();

    Ranger.Application.instance.objectsDrawn++;
  }

}
