part of ranger;

typedef Function ImageLoaded(Html.ImageElement ime);

/**
 * [ImageLoader] loads an image asyncronously. It returns a [Future].
 */
class ImageLoader {
  Html.ImageElement imageElement;
  String _resource;

  int imageWidth;
  int imageHeight;

  /**
   * Disabled by default. Enable if you want to simulate delays caused
   * by perhaps the Network or Server.
   */
  bool simulateLoadingDelay = false;
  
  Completer _loadingWorker;

  ImageLoader();
  
  /**
   * Often [resource] is a download URL from a source such as GDrive or
   * your application's resource folder.
   */
  factory ImageLoader.withResource(String resource) {
    ImageLoader il = new ImageLoader();
    il.initWithResource(resource);
    return il;
  }

  void initWithResource(String resource) {
    _resource = resource;
  }

  //----------------------------------------------------------------
  // Downloading.
  //----------------------------------------------------------------
  /**
   * [loadedCallback] is called when the resource has been loaded.
   * If the resource is SVG then you will need to specify the correct
   * width and height specified in the <svg> element. You can always
   * scale it afterwards.
   */
  Future<Html.ImageElement> load(int width, int height) {
    _loadingWorker = new Completer();
    
    this.imageWidth = width;
    this.imageHeight = height;

    imageElement = new Html.ImageElement(src: _resource, width: imageWidth, height: imageHeight);
    imageElement.onLoad.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
    
    return _loadingWorker.future;
  }
  
  //----------------------------------------------------------------
  // Loading into ImageData
  //----------------------------------------------------------------
  void _onData(Html.Event e) {
    if (simulateLoadingDelay) {
      // #################################################################
      // ## This is testing code only!
      // #################################################################
      // ## BEGIN TEST
      // Delay a random amount of seconds before calling callback.
      math.Random _randGen = new math.Random();
      int delay = 100 + _randGen.nextInt(2000);
      print("ImageLoader._onData: WARNING! Artificial delay of $delay.");
      new Future.delayed(new Duration(milliseconds: delay),
          () => _loadingWorker.complete(imageElement));
      // ## END TEST
    }
    else {
      _loadingWorker.complete(imageElement);
    }
  }

  void _onError(Html.Event e) {
    print("ImageLoader._onError $e");
  }

  void _onDone() {
    print("ImageLoader._onDone");
  }

  // Older download code that used HttpRequest to fetch data. Now I simply
  // ImageElement to handle fetching image data.
//  //----------------------------------------------------------------
//  // Downloading.
//  //----------------------------------------------------------------
//  /**
//   * [loadedCallback] is called when the resource has been loaded.
//   * If the resource is SVG then you will need to specify the correct
//   * width and height specified in the <svg> element. You can always
//   * scale it afterwards.
//   * [centered] default to Not-centered = false.
//   */
//  void load(Function loadedCallback, int width, int height, [bool centered = false]) {
//    _loadedCallback = loadedCallback;
//    this.imageWidth = width;
//    this.imageHeight = height;
//    
//    // The image in storage is still oriented as if +Y axis is downward.
//    // However, the coord system maybe flipped.
//    _sourceBlitRectangle = new Html.Rectangle(0, 0, width, height);
//
//    if (centered)
//      _destinationRect = new Html.Rectangle(-width/2.0, -height/2.0, width.toDouble(), height.toDouble());
//    else
//      _destinationRect = new Html.Rectangle(0.0, 0.0, width.toDouble(), height.toDouble());
//
//    // resource must be a file directly.
//    _loadImage(_resource);
//  }
//  
//  void _loadImage(String resource) {
//    // Start downloading resource.
//    _downloadRequest = new Html.HttpRequest();
//    _downloadRequest..responseType = "blob"
//      ..onLoad.listen(_onData_Request, onError: _onError_Request, onDone: _onDone_Request, cancelOnError: true)
//      ..open("GET", resource)
//      ..send();
//  }
//  
//  void _onData_Request(Html.Event e) {
//    Html.Blob response = _downloadRequest.response;
//    
//    final Html.FileReader reader = new Html.FileReader();
//    
//    reader.onLoad.listen((e) {
//            _handleData(reader);
//          });
//    reader.readAsArrayBuffer(response);
//  }
//
//  void _handleData(Html.FileReader reader) {
//    if (_isSVGSource) {
//      imageElement = new Html.ImageElement(src: _resource, width: imageWidth, height: imageHeight);
//    }
//    else {
//      Uint8List uintlist = new Uint8List.fromList(reader.result);
//      String charcodes = new String.fromCharCodes(uintlist);
//      String imageAsbase64 = Html.window.btoa(charcodes);
//      imageElement = new Html.ImageElement(src: "data:image/png;base64," + imageAsbase64, width: imageWidth, height: imageHeight);
//    }
//    
//    imageElement.onLoad.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
//  }
//
//  void _onError_Request(Html.Event e) {
//    print("SpriteImage: _onError_Request: $e");
//  }
//
//  void _onDone_Request() {
//    print("SpriteImage: _onDone_Request");
//  }
//
//  //----------------------------------------------------------------
//  // Loading into ImageData
//  //----------------------------------------------------------------
//  void _onData(Html.Event e) {
//    //print("SpriteImage: _onData");
//    _downloadRequest = null;
//    _loadedCallback();
//  }
//
//  void _onError(Html.Event e) {
//    print("SpriteImage: error: $e");
//  }
//
//  void _onDone() {
//    print("SpriteImage: done");
//  }
//

}
