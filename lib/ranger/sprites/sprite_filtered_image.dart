part of ranger;

typedef List<int> FilterFunction(List<int> pixels, [List<double> parms]);

/**
 * An experimental image filter.
 * These filters are from: (it is only a subset.)
 * http://www.html5rocks.com/en/tutorials/canvas/imagefilters/#disqus_thread
 */
class ImageFilters {
  static List<int> grayscale(List<int> pixels) {
    int r;
    int g;
    int b;
    for(int i = 0; i < pixels.length; i+= 4) {
      r = pixels[i];
      g = pixels[i+1];
      b = pixels[i+2];
      // CIE luminance for the RGB
      // The human eye is bad at seeing red and blue, so we de-emphasize them.
      double v = 0.2126*r + 0.7152*g + 0.0722*b;
      pixels[i] = pixels[i+1] = pixels[i+2] = v.toInt();
    }
    
    return pixels;
  }

  static List<int> brighten(List<int> pixels, [List<double> parms]) {
    for(int i = 0; i < pixels.length; i+= 4) {
      pixels[i] = (pixels[i] + parms[0]).toInt();
      pixels[i+1] = (pixels[i+1] + parms[0]).toInt();
      pixels[i+2] = (pixels[i+2] + parms[0]).toInt();
    }
    return pixels;
  }

  static List<int> threshold(List<int> pixels, [List<double> parms]) {
    int r;
    int g;
    int b;
    for(int i = 0; i < pixels.length; i+= 4) {
      r = pixels[i];
      g = pixels[i+1];
      b = pixels[i+2];
      double v = (0.2126*r + 0.7152*g + 0.0722*b >= parms[0]) ? 255.0 : 0.0;
      pixels[i] = pixels[i+1] = pixels[i+2] = v.toInt();
    }
    return pixels;
  }
}

/**
 * A [SpriteFilteredImage] an image with a pixel filter applied to it.
 * Something to consider when using this sprite type that the image ends up being bitmapped
 * and thus losing the canvas's internal rendering.
 * For example, if the resource is an SVG then the vector aspect of the
 * resource disappears and is replaced by a bitmap rendering which
 * introduces pixelation during up scaling. 
 * 
 * A [SpriteFilteredImage] is loaded from a URL/URI source. The source can be
 * specified with either a [URL] or [JSON] file.
 */
class SpriteFilteredImage extends SpriteImage {
  Html.CanvasElement _filterCanvas;
  Html.CanvasRenderingContext2D _filterContext;

  /**
   * A [FilterFunction] that is applied to image upon initial loading of
   * image. Set [ImageFilters] for simple examples of a filter function.
   */
  FilterFunction filterFunction;
  
  SpriteFilteredImage();
  
  SpriteFilteredImage._();
  factory SpriteFilteredImage.pooled() {
    SpriteFilteredImage poolable = new Poolable.of(SpriteFilteredImage, _createPoolable);
    poolable.pooled = true;
    poolable.init();
    return poolable;
  }

  static SpriteFilteredImage _createPoolable() => new SpriteFilteredImage._();

  /**
   * Often [resource] is a download URL from a source such as GDrive or
   * your application's resource folder.
   */
  factory SpriteFilteredImage.withResource(String resource) {
    SpriteFilteredImage poolable = new SpriteFilteredImage.pooled();
    if (poolable.init()) {
      // TODO convert to withElement poolable.initWithResource(resource);
      return poolable;
    }
    return null;
  }

  @override
  void draw(DrawContext context) {
    Html.CanvasRenderingContext2D context2D = context.renderContext as Html.CanvasRenderingContext2D;

    context.save();
    
    // Note: see uniformScale override for explanation.
    if (CONFIG.base_coordinate_system == CONFIG.LEFT_HANDED_COORDSYSTEM)
      context2D.scale(1.0, -1.0);

    context2D.drawImage(_filterCanvas, -imageWidth/2.0, -imageHeight/2.0);
    
    //context.drawColor = Color4IWhite.toString();
    //context.drawRect(_destinationRect.left, _destinationRect.top, _destinationRect.width, _destinationRect.height, false, true);
    
    context.restore();
  }
  
  //----------------------------------------------------------------
  // Loading into ImageData
  //----------------------------------------------------------------
  void _onData(Html.Event e) {
    //print("SpriteFilteredImage: _onData");

    // Create an offscreen image for filtering.
    _filterCanvas = new Html.CanvasElement(width: imageWidth, height: imageHeight);
    _filterContext = _filterCanvas.getContext('2d');
    
    // TODO We should be able to scale here to eliminate pixelation.
    _filterContext.drawImage(imageElement, 0.0, 0.0);
    
    Html.ImageData ida = _filterContext.getImageData(0.0, 0.0, imageWidth, imageHeight);
    
    if (filterFunction != null)
      filterFunction(ida.data);
    //else
    //  ImageFilters.grayscale(ida.data);
    
    _filterContext.putImageData(ida, 0.0, 0.0);
    
    _loadedCallback();
  }

  void _onError(Html.Event e) {
    print("SpriteFilteredImage: error: $e");
  }

  void _onDone() {
    print("SpriteFilteredImage: done");
  }

}
