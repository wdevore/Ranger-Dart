part of ranger;

/**
 * An Html5 Canvas specific [SpriteSheet] renderer.
 */
class CanvasSprite extends Sprite {
  bool aabboxVisible = false;
  double _inverseUniformScale = 1.0;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  CanvasSprite();
  
  CanvasSprite._();
  factory CanvasSprite.pooled() {
    CanvasSprite poolable = new Poolable.of(CanvasSprite, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static CanvasSprite _createPoolable() => new CanvasSprite._();

  factory CanvasSprite.initWith(SpriteSheetImage sheet, [bool centered = true]) {
    CanvasSprite poolable = new CanvasSprite.pooled();
    if (poolable.init()) {
      poolable.centered = centered;
      poolable.initWithSheet(sheet);
      return poolable;
    }
    return null;
  }

  void initWithSheet(SpriteSheetImage sheet) {
    super.initWithSheet(sheet);    
    _buildFrames();
  }

  void _buildFrames() {
    for(int i = 0; i < sheet.frameCount; i++) {
      int column = sheet.getColumnFrom(i);
      int row = sheet.getRowFrom(i, column);
      
      int offsetX = column * sheet.cellWidth;
      int offsetY = row * sheet.cellHeight;
      
      _sourceBlitRects.add(new Html.Rectangle(offsetX, offsetY, sheet.cellWidth, sheet.cellHeight));    
    }
  }
  
  @override
  set uniformScale(double s) {
    // Note: Internally the image is always stored such that +Y is downward.
    // This means we need to flip the scale and also flip the render Context.
    // Here the scale is flipped and in draw(...) the context is flipped.
    if (CONFIG.base_coordinate_system == CONFIG.LEFT_HANDED_COORDSYSTEM)
      _scale.setValues(s, s);
    else
      _scale.setValues(s, -s);
    
    _inverseUniformScale = 1.0 / calcUniformScaleComponent();
    
    node.dirty = true;
  }


  @override
  void draw(DrawContext context) {

    Html.CanvasRenderingContext2D context2D = context.renderContext as Html.CanvasRenderingContext2D;

    context.save();
    
    // See if the coordinates systems match. If not sync them.
    if (CONFIG.base_coordinate_system != sheet.coordSystem)
      context2D.scale(1.0, -1.0);
    
    context2D.drawImageToRect(sheet.imageElement, 
        _destinationRect, sourceRect: _sourceBlitRects[frameIndex]);

    context.restore();
    
    if (aabboxVisible) {
      context.save();
      context.fillColor = null;
      context.drawColor = Color4IGreen.toString();
      context.lineWidth = _inverseUniformScale;
      context.drawRect(_destinationRect.left, _destinationRect.top, _destinationRect.width, _destinationRect.height);
      context.restore();
    }

    // Note: The down side below is that we are doing an allocate on every
    // frame. Not preferred.
    //context2D.drawImageToRect(sheet.imageElement, 
    //    _destinationRect,
    //    sourceRect: new Html.Rectangle(offsetX, offsetY, sheet.cellWidth, sheet.cellHeight));

    // NOTE: putImageData is absolute and doesn't participate in the
    // rendering flow. It writes directly to the canvas ignoring any
    // prior drawings or transformations. Don't use.
    //    context2D.putImageData(sheet.imageData, -dirtyX, -dirtyY, 
    //        dirtyX, dirtyY, dirtyW, dirtyH);
  }

}
