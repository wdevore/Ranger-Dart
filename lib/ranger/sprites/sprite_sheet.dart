part of ranger;

/**
 * A [SpriteSheet] can either a collection (not recommened) or
 * a single image (for Canvas) or Texture (for WebGL) spritesheet.
 * 
 * [CanvasSprite]s reference this sheet for their visual representation.
 * 
 * A [SpriteSheet] is loaded from a URL/URI source. The source can be
 * specified with either a [URL] or [JSON] file.
 */
abstract class SpriteSheet extends SpriteBase {
  Html.HttpRequest _downloadRequest;
  
  String _jsonFile;
  String _resource;
  String _path;
  
  Function _loadedCallback;
  
  int cellWidth;
  int cellHeight;
  
  int columns;
  int rows;
  
  /**
   * We need to know what type of coordinate system the sprite sheet
   * was creating in so we can match it to [Ranger]'s system defined
   * [CONFIG.base_coordinate_system] default is [True].
   * 
   * If your sprite application generated a sheet with +Y pointing
   * downward then set the 'CoordSystem' json field to [False].
   */
  bool coordSystem = false;
  
  SpriteSheet();
  
  // zero indexed.
  int calcFrameIndexFrom(int column, int row) {
    // 0+0 = 0,1+0=1, 2+0=2,..., 4+0=4
    // 0+1*Colmns = 5,1+0=1, 2+0=2,..., 5+0=5
    int frame = column + (row * columns);
    return frame;
  }
  
  int getColumnFrom(int frame) {
    // 0=0,  1=1 ...4=4
    // 5=0,  6=1 ...9=4
    // 10=0, 11=1...14=4
    // 15=0, 16=1...19=4
    // 20=0, 21=1...24=4
    int column = frame % columns;
    return column;
  }
  
  int getRowFrom(int frame, int column) {
    // 0=0,  1=0 ...4=0
    // 5=1,  6=1 ...9=1
    // 10=2, 11=2...14=2
    // 15=3, 16=3...19=3
    // 20=4, 21=4...24=4
    // Solve for row based on equation from calcFrameIndexFrom
    int row = (frame - column) ~/ columns;
    return row;
  }

}
