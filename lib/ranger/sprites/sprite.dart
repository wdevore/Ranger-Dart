part of ranger;

/**
 * A [Sprite] is an abstraction that references a [SpriteSheet] for its
 * visual presentation.
 * 
 * A [Sprite] could be a single frame or a sequence.
 * If it is a single frame ([frameRate] = 0) then the [SpriteSheet]
 * dimensions are the same as the [Sprite].
 * 
 * A [Sprite] can have a [frameRate] if it is an animation. The animation
 * determines the current frame. Otherwise, the current frame is
 * manually controlled.
 * 
 */
abstract class Sprite extends Node with TimingTarget {
  /// The current frame if this [Sprite] is an animation.
  int frameIndex = 0;
  bool centered;

  bool animationEnabled = false;
  
  double _accumulateTime = 0.0;
  double _simFrameRate;
  
  SpriteSheetImage sheet;
  Html.Rectangle _destinationRect;
  List<Html.Rectangle> _sourceBlitRects = new List<Html.Rectangle>();
  
  Aabb2 _aabbox = new Aabb2();

  void initWithSheet(SpriteSheetImage sheet) {
    this.sheet = sheet;
    
    changeFrameRate(sheet.frameRate);
    
    animationEnabled = sheet.frameRate > 0;
    
    if (centered)
      _destinationRect = new Html.Rectangle(-sheet.cellWidth/2.0, -sheet.cellHeight/2.0, sheet.cellWidth.toDouble(), sheet.cellHeight.toDouble());
    else
      _destinationRect = new Html.Rectangle(0.0, 0.0, sheet.cellWidth.toDouble(), sheet.cellHeight.toDouble());
    
    _buildFrames();
  }

  int get frameRate => sheet.frameRate;
  
  /**
   * [p] should be in node's local-space.
   */
  bool containsPoint(Vector2 p) {
    return localBounds.containsVector2(p);
  }

  Aabb2 get localBounds {
    _aabbox.min.setValues(_destinationRect.left, _destinationRect.top);
    _aabbox.max.setValues(_destinationRect.right, _destinationRect.bottom);
    return _aabbox;
  }
  
  /// [rate] is in frames per second.
  void changeFrameRate(int rate) {
    animationEnabled = rate > 0;
    
    if (animationEnabled) {
      // map from 60fps to rate.
      // 60fps = 16.78ms/f
      // 15fps = 4 * 16.77/f = 66.67ms/f
      double fixedRate = 1.0 / 60.0;
      
      _simFrameRate = (fixedRate * (60.0 / rate));
      //print("_simFrameRate: $_simFrameRate");
      _accumulateTime = 0.0;
    }
  }
  
  // TimingTarget
  @override
  void update(double dt) {
    if (animationEnabled) {
      _accumulateTime += dt;
      if (_accumulateTime > _simFrameRate) {
        nextFrame();
        _accumulateTime = 0.0;
      }
    }
  }
  
  /**
   * [frame] explicitly overrides the current frame. Otherwise the next
   * frame is updated automatically.
   */
  void nextFrame([int frame = -1]) {
    if (frame >= 0) {
      // explicity set frame.
      frameIndex = frame % sheet.frameCount;
      _accumulateTime = 0.0;
      //int column = sheet.getColumnFrom(frameIndex);
      //int row = sheet.getRowFrom(frameIndex, column);
      //print("frame: $frameIndex {${column}, ${row}}");
    }
    else {
      if (sheet.playDirection)
        frameIndex = (frameIndex + 1) % sheet.frameCount;
      else
        frameIndex = (frameIndex - 1) % sheet.frameCount;
    }
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
}
