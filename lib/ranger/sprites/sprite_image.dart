part of ranger;

/**
 * A [SpriteImage] a single image (for Canvas) or Texture (for WebGL).
 * 
 * A [SpriteImage] is loaded from a URL/URI source. The source can be
 * specified with either a [URL] or [JSON] file.
 */
class SpriteImage extends Node with Color4Mixin {
  Html.ImageElement imageElement;
  String _resource;

  Function _loadedCallback;

  int imageWidth;
  int imageHeight;

  Html.Rectangle _sourceBlitRectangle;
  Html.Rectangle _destinationRect;
  Aabb2 _aabbox = new Aabb2();
  bool aabboxVisible = false;
  
  double _inverseUniformScale = 1.0;
  
  SpriteImage();
  
  SpriteImage._();
  factory SpriteImage.pooled() {
    SpriteImage poolable = new Poolable.of(SpriteImage, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static SpriteImage _createPoolable() => new SpriteImage._();

  /**
   * [image] is a resource previously loaded by a resource loader.
   * [centered] defaults to True.
   * Note: this object may be being pulled from a pool. If so then the
   * object could have "stale" or "leftover" state from the last time
   * it was in use. So remember, you initializer should always initialize
   * to a set of "defaults" otherwise you will get strange results.
   */
  factory SpriteImage.withElement(Html.ImageElement image, [bool centered = true]) {
    SpriteImage poolable = new SpriteImage.pooled();
    if (poolable.init()) {
      poolable.initWithElement(image, centered);
      return poolable;
    }
    return null;
  }

  /**
   * See [SpriteImage.withElement] for an important note.
   */
  void initWithElement(Html.ImageElement image, bool centered) {
    imageElement = image;
    imageWidth = imageElement.width;
    imageHeight = imageElement.height;
    aabboxVisible = false;
    _inverseUniformScale = 1.0;
    
    _sourceBlitRectangle = new Html.Rectangle(0, 0, imageWidth, imageHeight);

    // The image in storage is still oriented as if +Y axis is downward.
    // However, the coord system maybe flipped.
    if (centered)
      _destinationRect = new Html.Rectangle(-imageWidth/2.0, -imageHeight/2.0, imageWidth.toDouble(), imageHeight.toDouble());
    else
      _destinationRect = new Html.Rectangle(0.0, 0.0, imageWidth.toDouble(), imageHeight.toDouble());
  }

  @override
  Node clone() {
    SpriteImage s = new SpriteImage.withElement(imageElement);
    s.imageWidth = imageWidth;
    s.imageHeight = imageHeight;
    s._sourceBlitRectangle = new Html.Rectangle(
        _sourceBlitRectangle.left,
        _sourceBlitRectangle.top,
        _sourceBlitRectangle.width,
        _sourceBlitRectangle.height);
    s._destinationRect = new Html.Rectangle(
        _destinationRect.left,
        _destinationRect.top,
        _destinationRect.width,
        _destinationRect.height);
    s._aabbox = new Aabb2.copy(_aabbox);
    s.aabboxVisible = aabboxVisible;
    s._inverseUniformScale = _inverseUniformScale; 
    return s;
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

  /**
   * [p] should be in node's local-space.
   */
  @override
  bool pointInside(Vector2 p) {
    return localBounds.containsVector2(p);
  }
  
  @override
  void draw(DrawContext context) {
    Html.CanvasRenderingContext2D context2D = context.renderContext as Html.CanvasRenderingContext2D;

    context.save();
    
    // Note: see uniformScale override for explanation.
    if (CONFIG.base_coordinate_system == CONFIG.LEFT_HANDED_COORDSYSTEM)
      context2D.scale(1.0, -1.0);

    context2D.globalAlpha = color.a / 255.0;

    context2D.drawImageToRect(
        imageElement, 
        _destinationRect, sourceRect: _sourceBlitRectangle
        );
 
    context.restore();
    
    if (aabboxVisible) {
      context.save();
      context.fillColor = null;
      context.drawColor = Color4IGreen.toString();
      context.lineWidth = _inverseUniformScale;
      context.drawRect(_destinationRect.left, _destinationRect.top, _destinationRect.width, _destinationRect.height);
      context.restore();
    }
    
  }
  
  Aabb2 get localBounds {
    _aabbox.min.setValues(_destinationRect.left, _destinationRect.top);
    _aabbox.max.setValues(_destinationRect.right, _destinationRect.bottom);
    return _aabbox;
  }
  
}
