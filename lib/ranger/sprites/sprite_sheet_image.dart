part of ranger;


/**
 * A [SpriteSheetImage] can either be a collection (not recommened) or
 * a single image (for Canvas) or Texture (for WebGL) spritesheet. Either
 * way a image needs to be downloaded before viewing.
 * 
 * [Sprite]s reference this sheet for their visual representation.
 * 
 * A [SpriteSheetImage] is loaded from a URL/URI source. The source can be
 * specified with either a [URL] or [JSON] file.
 */
class SpriteSheetImage extends SpriteSheet {
  
  Html.ImageElement imageElement;
  // Note: may be used with WebGL.
  //Html.ImageData imageData;

  /**
   * Typically [resource] is a download URL from a source such as GDrive or
   * your application's resource folder.
   * 
   * Or [resource] is a json file with a key called "spriteTitle". This value
   * is a relative path including the actual spritesheet file.
   * {
   *  "spriteTitle" : "res/gtype.png",
   *  ...
   * }
   * 
   * In this case your "res/" directory would have two files:
   *     1: [JSON] file (which references the spritesheet image)
   *     2: a matching spritesheet image. 
   *     
   *     res/gtype.json
   *         gtype.png
   * Note: this does not actually download the sheet. Call [load] in
   * order to download the resource asyncronously.
   */
  SpriteSheetImage(String resource) {
    // TODO This expression may need tweaking for more complex paths.
    RegExp pathMatcher = new RegExp(r"^([a-z0-9- _]*[/]+)+");
    
    _path = pathMatcher.stringMatch(resource);
    if (_path == null)
      Logging.error("Path for $resource not found.");
    
    _resource = resource;
  }
  
  /**
   * [loadedCallback] is called when the resource has been loaded.
   */
  void load(Function loadedCallback, [int width = 64, int height = 64]) {
    _loadedCallback = loadedCallback;
    this.width = width;
    this.height = height;
    
    RegExp extensionMatcher = new RegExp(r"\b[a-zA-Z]+$");    
    String extension = extensionMatcher.stringMatch("json");
    if (extension != null) {
      // Get json file
      Html.HttpRequest.getString(_resource)
        .then(_processJSONFile)
        .catchError(_handleFileError);
    }
    else {
      // resource must be a file directly.
      _loadSpriteSheet(_resource, width, height);
    }

  }
  
  void _processJSONFile(String jsonString) {
    Map spriteMap = JSON.decode(jsonString);
    //print("SpriteSheetImage: $spriteMap");
    
    if (spriteMap.containsKey("spriteTitle")) {
      String sheetFile = spriteMap["spriteTitle"] as String;
      
      if (!spriteMap.containsKey("cellWidth")) {
        Logging.error("[cellWidth] must be specified in json map.");
        return;
      }
      cellWidth = spriteMap["cellWidth"] as int;

      if (!spriteMap.containsKey("cellHeight")) {
        Logging.error("[cellHeight] must be specified in json map.");
        return;
      }
      cellHeight = spriteMap["cellHeight"] as int;
      
      if (!spriteMap.containsKey("columns")) {
        Logging.error("[columns] must be specified in json map.");
        return;
      }
      columns = spriteMap["columns"] as int;

      if (!spriteMap.containsKey("rows")) {
        Logging.error("[rows] must be specified in json map.");
        return;
      }
      rows = spriteMap["rows"] as int;
      
      if (spriteMap.containsKey("sheetWidth")) {
        width = spriteMap["sheetWidth"] as int;
      }
      else {
        Logging.warning("Json map missing [sheetWidth] key. Attempting to infer from cell info.");
        width = columns * cellWidth;
      }
      
      if (spriteMap.containsKey("sheetWidth")) {
        height = spriteMap["sheetHeight"] as int;
      }
      else {
        Logging.warning("Json map missing [sheetHeight] key. Attempting to infer from cell info.");
        height = rows * cellHeight;
      }

      if (spriteMap.containsKey("frameRate")) {
        frameRate = spriteMap["frameRate"] as int;
      }
      else {
        Logging.warning("Json map missing [frameRate] key. Defaulting to 0.");
        frameRate = 0;
      }
      
      if (spriteMap.containsKey("playDirection")) {
        playDirection = spriteMap["playDirection"] as bool;
      }
      else {
        Logging.warning("Json map missing [playDirection] key. Defaulting to forward.");
        playDirection = true;
      }
      
      if (spriteMap.containsKey("frameCount")) {
        frameCount = spriteMap["frameCount"] as int;
      }
      else {
        Logging.warning("Json map missing [frameCount] key. Defaulting to (rows * columns).");
        frameCount = rows * columns;
      }

      if (spriteMap.containsKey("coordSystem")) {
        coordSystem = spriteMap["CoordSystem"] as bool;
      }
      else {
        Logging.warning("Json map missing [coordSystem] key. Defaulting to CONFIG.base_coordinate_system.");
        coordSystem = CONFIG.base_coordinate_system;
      }

      // TODO get root resource from the app's config, NOT Ranger's.
      sheetFile = _path + sheetFile;
      
      _loadSpriteSheet(sheetFile, width, height);
    }
    else {
      Logging.error("[spriteTitle] must be specified in json map. I can't tell what image to load.");
    }
  }

  void _handleFileError(Error error) {
    Logging.error("SpriteSheetImage._handleFileError: $error");
  }

  void _loadSpriteSheet(String resource, int width, int height) {
    // Start downloading resource.
    _downloadRequest = new Html.HttpRequest();
    _downloadRequest.responseType = "blob";
    _downloadRequest.onLoad.listen(_onData_Request, onError: _onError_Request, onDone: _onDone_Request, cancelOnError: true);
    _downloadRequest.open("GET", resource);
    _downloadRequest.send();
  }
  
  //----------------------------------------------------------------
  // Downloading.
  //----------------------------------------------------------------
  void _onData_Request(Html.Event e) {
    Html.Blob response = _downloadRequest.response;
    
    final Html.FileReader reader = new Html.FileReader();
    
    reader.onLoad.listen((e) {
            _handleData(reader);
          });
    reader.readAsArrayBuffer(response);
  }

  void _handleData(Html.FileReader reader) {
    Uint8List uintlist = new Uint8List.fromList(reader.result);
    String charcodes = new String.fromCharCodes(uintlist);
    String imageAsbase64 = Html.window.btoa(charcodes);

    imageElement = new Html.ImageElement(src: "data:image/png;base64," + imageAsbase64, width: width, height: height);
    imageElement.onLoad.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onError_Request(Html.Event e) {
    print("GET request error: $e");
  }

  void _onDone_Request() {
    print("GET request done");
  }

  //----------------------------------------------------------------
  // Loading into ImageData
  //----------------------------------------------------------------
  void _onData(Html.Event e) {
    _loadedCallback();
  }

  // We don't really need this method because we aren't using
  // putImageData during animation. Note it could be used with WebGL.
//  @deprecated
//  void _copyImage() {
//    // Copy ImageElement to an offscreen canvas.
//    Html.CanvasElement canvas = new Html.CanvasElement(width: width, height: height);
//    Html.CanvasRenderingContext2D context = canvas.context2D;
//
//    context.drawImageScaled(imageElement, 0, 0, width, height);
//
//    // Now that the context has data written to it we can get a image
//    // copy for blitting.
//    //imageData = context.getImageData(0, 0, width, height);
//  }
  
  void _onError(Html.Event e) {
      print("ImageElement error: $e");
  }

  void _onDone() {
      print("ImageElement done");
  }

}
