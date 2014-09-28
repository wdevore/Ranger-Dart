part of unittests;

/**
 * This [Node] is an example of implementing a [Tweenable] directly.
 * By doing so you gain a lot more flexibility over using the fixed
 * [TweenAnimation] accessor.
 */
class PointColorTween extends Ranger.Node with UTE.Tweenable {
  static const int COLOR = 75;
  static const int TINT = 76;
  static const int FADE = 77;
  static const int COLOR_OUTLINE = 85;
  static const int TINT_OUTLINE = 86;
  static const int FADE_OUTLINE = 87;
  
  Ranger.Color4<int> outlineColor;
  Ranger.Color4<int> fillColor;
  
  double outlineThickness = 3.0;
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  PointColorTween();
  
  PointColorTween._();
  factory PointColorTween.pooled() {
    PointColorTween poolable = new Ranger.Poolable.of(PointColorTween, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory PointColorTween.initWith(Ranger.Color4<int> fillColor, [Ranger.Color4<int> outlineColor, double fromScale = 1.0]) {
    PointColorTween poolable = new PointColorTween.pooled();
    if (poolable.init()) {
      poolable.fillColor = fillColor;
      poolable.outlineColor = outlineColor;
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static PointColorTween _createPoolable() => new PointColorTween._();

  PointColorTween clone() {
    PointColorTween poolable = new PointColorTween.pooled();
    
    if (poolable.initWith(this)) {
      poolable.fillColor = fillColor;
      poolable.outlineColor = outlineColor;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    
    return null;
  }
  
  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
    switch (tweenType) {
      case COLOR:
        returnValues[0] = fillColor.r;
        returnValues[1] = fillColor.g;
        returnValues[2] = fillColor.b;
        returnValues[3] = fillColor.a;
        return 4;
      case TINT:
        returnValues[0] = fillColor.r;
        returnValues[1] = fillColor.g;
        returnValues[2] = fillColor.b;
        return 3;
      case TINT_OUTLINE:
        returnValues[0] = outlineColor.r;
        returnValues[1] = outlineColor.g;
        returnValues[2] = outlineColor.b;
        return 3;
      case FADE:
        returnValues[0] = fillColor.a;
        return 1;
      case FADE_OUTLINE:
        returnValues[0] = outlineColor.a;
        return 1;
    }
    
    return 0;
  }
  
  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
    switch (tweenType) {
      case COLOR:
        fillColor.r = newValues[0].ceil();
        fillColor.g = newValues[1].ceil();
        fillColor.b = newValues[2].ceil();
        fillColor.a = newValues[3].ceil();
        break;
      case TINT:
        fillColor.r = newValues[0].ceil();
        fillColor.g = newValues[1].ceil();
        fillColor.b = newValues[2].ceil();
        break;
      case TINT_OUTLINE:
        outlineColor.r = newValues[0].ceil();
        outlineColor.g = newValues[1].ceil();
        outlineColor.b = newValues[2].ceil();
        break;
      case FADE:
        fillColor.a = newValues[0].ceil();
        break;
      case FADE_OUTLINE:
        outlineColor.a = newValues[0].ceil();
        break;
    }
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = fillColor.toString();
    context.drawColor = outlineColor.toString();
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;

    context.drawPointAt(0.0, 0.0);

    context.restore();

    Ranger.Application.instance.objectsDrawn++;
  }

}
