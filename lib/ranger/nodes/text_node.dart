part of ranger;

/**
 * [TextNode] is a Html5 Canvas specific [Node] for displaying text.
 * It presense is mostly for unit tests and templates. It normal for
 * you to implement your own text node depending on your requirements.
 * This node is not that efficient.
 */
class TextNode extends Node {
  Color4<int> strokeColor = Color4IBlue;
  double strokeWidth = 1.0;
  Color4<int> fillColor;
  String text;
  String horzAlign;
  String baseLine;
  String font;
  bool shadows = false;
  
  bool init() {
    if (super.init()) {
      return true;
    }
    
    return false;
  }
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  TextNode();
  
  TextNode._();
  factory TextNode.pooled() {
    TextNode poolable = new Poolable.of(TextNode, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory TextNode.initWith(Color4<int> fillColor, [Color4<int> strokeColor, double fromScale = 1.0]) {
    TextNode poolable = new TextNode.pooled();
    if (poolable.init()) {
      poolable.font = null;
      poolable.shadows = false;
      poolable.strokeColor = strokeColor;
      poolable.fillColor = fillColor;
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static TextNode _createPoolable() => new TextNode._();

  TextNode clone() {
    TextNode poolable = new TextNode.pooled();
    
    if (poolable.initWith(this)) {
      poolable.initWithUniformScale(poolable, scale.x);
      return poolable;
    }
    
    return null;
  }

  @override
  void draw(DrawContext context) {
    context.save();

    if (fillColor != null)
      context.fillColor = fillColor.toString();
    else
      context.fillColor = null;
     
    if (strokeColor != null)
      context.drawColor = strokeColor.toString();
    else
      context.drawColor = null;
    
    if (horzAlign != null)
      context.horzAlign = horzAlign;
    if (baseLine != null)
      context.baseLine = baseLine;

    if (font != null)
      context.font = font;
    
    context.shadows = shadows;
    
    double invScale = 1.0 / calcUniformScaleComponent() * strokeWidth;
    context.lineWidth = invScale;
    context.drawText(text, position);
    
    context.restore();
  }

}