import 'package:ranger/ranger.dart' as Ranger;
import 'package:vector_math/vector_math.dart';

class SceneBox2 extends Ranger.Scene {
  
  @override
  void onEnter() {
    super.onEnter();
    print("SceneBox2.onEnter $tag");
  }
  
  @override
  void onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish();
    print("SceneBox2.onEnterTransitionDidFinish $tag");
  }
  
  @override
  void onExitTransitionDidStart() {
    super.onExitTransitionDidStart();
    print("SceneBox2.onExitTransitionDidStart $tag");
  }
  
  @override
  void onExit() {
    super.onExit();
    print("SceneBox2.onExit $tag");
  }
}

class BasicScene extends Ranger.AnchoredScene {
  Function _completeVisit;
  
  BasicScene.withPrimary(Ranger.Layer primary, [int zOrder = 0, int tag = 0, Function completeVisit = null]) {
    initWithPrimary(primary, zOrder, tag);
    completeVisitCallback = completeVisit;
  }
}

class AnchorNode extends Ranger.Node with Ranger.GroupingBehavior {
  double r = 0.0;
  Vector2 point = new Vector2.zero();
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  AnchorNode() {
    if (init()) {
      initGroupingBehavior(this);
    }
  }
  
  AnchorNode._();
  factory AnchorNode.pooled() {
    AnchorNode poolable = new Ranger.Poolable.of(AnchorNode, _createPoolable);
    poolable.init();
    return poolable;
  }

  static AnchorNode _createPoolable() => new AnchorNode._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  void update(double dt) {
    rotationByDegrees = r;
    r += 0.5;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.drawColor = "#ffffff";
    ls.setValues(-20.0, 0.0);
    le.setValues(20.0, 0.0);
    context.drawLine(ls, le);
    
    context.drawColor = "#000000";
    ls.setValues(0.0, -20.0);
    le.setValues(0.0, 20.0);
    context.drawLine(ls, le);
  }
}

class NodePoint2 extends Ranger.Node {
  Vector2 point = new Vector2.zero();
  Vector2 point2 = new Vector2.zero();
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  NodePoint2() {
  }
  
  NodePoint2._();
  factory NodePoint2.pooled() {
    NodePoint2 poolable = new Ranger.Poolable.of(NodePoint2, _createPoolable);
    poolable.init();
    return poolable;
  }

  static NodePoint2 _createPoolable() => new NodePoint2._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = "#0000ff";
    context.drawPoint(point, 3);
    context.fillColor = "#ff00ff";
    context.drawPoint(point2, 3);
  }
}

class ColorPoint extends Ranger.Node with Ranger.Color4Mixin {
  Vector2 localPosition = new Vector2.zero();
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  ColorPoint() {
  }
  
  ColorPoint._();
  factory ColorPoint.pooled() {
    ColorPoint poolable = new Ranger.Poolable.of(ColorPoint, _createPoolable);
    poolable.init();
    poolable.initWithUniformScale(poolable, 1.0);
    return poolable;
  }

  factory ColorPoint.initWith(Ranger.Color4<int> from, [double fromScale = 1.0]) {
    ColorPoint poolable = new ColorPoint.pooled();
    if (poolable.init()) {
      poolable.initWithColor(from);
      poolable.initWithUniformScale(poolable, fromScale);
      return poolable;
    }
    return null;
  }
  
  static ColorPoint _createPoolable() => new ColorPoint._();

  ColorPoint clone() {
    ColorPoint poolable = new ColorPoint.pooled();
    
    if (poolable.initWith(this)) {
      poolable.localPosition.setFrom(localPosition);
      poolable.initWithColor(initialColor);
      poolable.initWithUniformScale(poolable, scale.x);
      return poolable;
    }
    
    return null;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  void initWithUniformScale(Ranger.BaseNode node, double s) {
    super.initWithUniformScale(node, s);
  }
  
  void release() {
    super.release();
  }
  
  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    context.fillColor = color.toString();
    context.drawPoint(localPosition);

    //context.drawColor = "rgba(0,0,0,1.0)";
    //ls.setValues(0.0, 0.0);
    //le.setValues(uniformScale, 0.0);
    //context.drawLine(ls, le);
    
    context.restore();

    Ranger.Application.instance.objectsDrawn++;
  }

}

class NodePoint extends Ranger.Node with Ranger.GroupingBehavior {
  Vector2 point = new Vector2.zero();
  Ranger.Color3<int> color = Ranger.Color3IWhite;
  // This is for visual scaling. Scaling a point doesn't really mean
  // anything transform wise. But it can't be visually hard to see the
  // point. So drawScale helps with visually seeing the point without
  // polluting the transform space with a meaningless scale.
  int drawScale = 1;
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  NodePoint() {
    init();
  }
  
  NodePoint._();
  factory NodePoint.pooled() {
    NodePoint poolable = new Ranger.Poolable.of(NodePoint, _createPoolable);
    poolable.init();
    return poolable;
  }

  static NodePoint _createPoolable() => new NodePoint._();

  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
      return true;
    }
    
    return false;
  }
  
  NodePoint clone() {
    NodePoint poolable = new NodePoint.pooled();
    if (poolable.initWith(this)) {
      poolable.initGroupingBehavior(this);
      poolable.point.setFrom(point);
      poolable.color.r = color.r;
      poolable.color.g = color.g;
      poolable.color.b = color.b;
      poolable.drawScale = drawScale;
      return poolable;
    }
    
    return null;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void release() {
    super.release();
    color.moveToPool();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = color.toString();
    context.drawPoint(point, drawScale);
  }
}

class LeafPoint extends Ranger.Node {
  Vector2 point = new Vector2.zero();
  Ranger.Color3<int> color = Ranger.Color3IWhite;
  // This is for visual scaling. Scaling a point doesn't really mean
  // anything transform wise. But it can't be visually hard to see the
  // point. So drawScale helps with visually seeing the point without
  // polluting the transform space with a meaningless scale.
  int drawScale = 1;
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  LeafPoint() {
    init();
  }
  
  LeafPoint._();
  factory LeafPoint.pooled() {
    LeafPoint poolable = new Ranger.Poolable.of(LeafPoint, _createPoolable);
    poolable.init();
    return poolable;
  }

  static LeafPoint _createPoolable() => new LeafPoint._();

  @override
  bool init() {
    if (super.init()) {
      return true;
    }
    
    return false;
  }
  
  LeafPoint clone() {
    LeafPoint poolable = new LeafPoint.pooled();
    if (poolable.initWith(this)) {
      poolable.point.setFrom(point);
      poolable.color.r = color.r;
      poolable.color.g = color.g;
      poolable.color.b = color.b;
      poolable.drawScale = drawScale;
      return poolable;
    }
    
    return null;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void release() {
    super.release();
    color.moveToPool();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = color.toString();
    context.drawPoint(point, drawScale);
  }
}

class NodeCenteredBox extends Ranger.Node with Ranger.GroupingBehavior {
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  double size = 10.0;
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  NodeCenteredBox() {
    init();
  }
  
  NodeCenteredBox._();
  factory NodeCenteredBox.pooled() {
    NodeCenteredBox poolable = new Ranger.Poolable.of(NodeCenteredBox, _createPoolable);
    poolable.init();
    return poolable;
  }

  static NodeCenteredBox _createPoolable() => new NodeCenteredBox._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
      return true;
    }
    
    return false;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    
    double left = -(size / 2.0);
    double bottom = -(size / 2.0);
    
    ls.setValues(left, bottom);
    le.setValues(left, bottom + size);
    context.drawLine(ls, le);
    context.fillColor = "#ff0000";
    context.drawPoint(ls, 2);

    ls.setValues(left, bottom + size);
    le.setValues(left + size, bottom + size);
    context.drawLine(ls, le);
    context.fillColor = "#00ff00";
    context.drawPoint(ls, 2);
    
    ls.setValues(left + size, bottom + size);
    le.setValues(left + size, bottom);
    context.drawLine(ls, le);
    context.fillColor = "#0000ff";
    context.drawPoint(ls, 2);

    ls.setValues(left + size, bottom);
    le.setValues(left, bottom);
    context.drawLine(ls, le);
    context.fillColor = "#ffffff";
    context.drawPoint(ls, 2);
  }
}

class NodeLine extends Ranger.Node {
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  NodeLine(double x1, double y1, double x2, double y2) {
    init();
    ls.setValues(x1, y1);
    le.setValues(x2, y2);
  }
  
  NodeLine._();
  factory NodeLine.pooled(double x1, double y1, double x2, double y2) {
    NodeLine poolable = new Ranger.Poolable.of(NodeLine, _createPoolable);
    poolable.init();
    return poolable;
  }

  static NodeLine _createPoolable() => new NodeLine._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    
    context.drawColor = "#000000";
    context.drawLine(ls, le);
    
    context.fillColor = "#ff0000";
    context.drawPoint(ls, 2);
    context.fillColor = "#00ff00";
    context.drawPoint(le, 3);

  }
}

class SquareNode extends Ranger.Node with Ranger.GroupingBehavior {
  bool solid = false;
  bool outlined = true;
  String drawColor = Ranger.Color3IBlack.toString();
  String fillColor = Ranger.color4IFromHex("#aaaaaaff").toString();
  
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();

  /// Center on [BaseNode]'s position for drawing only. Transforms unaffected.
  bool drawCentered = false;
  
  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  SquareNode() {
    if (init()) {
      initGroupingBehavior(this);
      initWithUniformScale(this, 1.0);
    }
  }
  
  SquareNode._();
  factory SquareNode.pooled() {
    SquareNode poolable = new Ranger.Poolable.of(SquareNode, _createPoolable);
    poolable.init();
    poolable.size = 1.0;
    poolable.center();
    poolable.initWithUniformScale(poolable, 1.0);
    return poolable;
  }

  static SquareNode _createPoolable() => new SquareNode._();

  SquareNode clone() {
    SquareNode poolable = new SquareNode.pooled();
    poolable.initWith(this);
    poolable.size = 1.0;
    poolable.center();
    poolable.fillColor = fillColor;
    poolable.solid = solid;
    poolable.outlined = outlined;
    poolable.drawColor = drawColor;
    poolable.rect.setWith(rect);
    return poolable;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }
  
  set size(double s) {
    rect.width = s;
    rect.height = s;
  }

  double get size => rect.width;

  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = fillColor;
    context.drawColor = drawColor;
    
    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
  }

}

class BasicSquareNode extends Ranger.Node {
  bool solid = false;
  bool outlined = true;
  String drawColor = "rgb(255,200,0)";
  String fillColor = Ranger.color4IFromHex("#aaaaaa").toString();
  
  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  BasicSquareNode() {
    if (init()) {
      initWithUniformScale(this, 1.0);
      size = 1.0;
      center();
    }
  }
  
  BasicSquareNode._();
  factory BasicSquareNode.pooled() {
    BasicSquareNode poolable = new Ranger.Poolable.of(BasicSquareNode, _createPoolable);
    poolable.init();
    poolable.size = 1.0;
    poolable.center();
    poolable.initWithUniformScale(poolable, 1.0);
    return poolable;
  }

  static BasicSquareNode _createPoolable() => new BasicSquareNode._();

  BasicSquareNode clone() {
    BasicSquareNode poolable = new BasicSquareNode.pooled();
    poolable.initWith(this);
    poolable.size = 1.0;
    poolable.center();
    poolable.fillColor = fillColor;
    poolable.solid = solid;
    poolable.outlined = outlined;
    poolable.drawColor = drawColor;
    poolable.rect.setWith(rect);
    return poolable;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }
  
  set size(double s) {
    rect.width = s;
    rect.height = s;
  }

  double get size => rect.width;
  
  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = fillColor;
    context.drawColor = drawColor;
    
    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
  }
}

class GridNode extends Ranger.Node {
  double width;
  double height;
  double majorSpacing = 100.0;
  double minorSpacing = 25.0;
  
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  String majorColor = "#555555";
  String minorColor = "#aaaaaa";
  
  bool centered = false;
  
  Vector2 dimension = new Vector2.zero();
  
  Ranger.AffineTransform ainv;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  //GridNode(this.width, this.height, this.centered);
  GridNode();
  
  GridNode._();

  factory GridNode.withDimensions(double width, double height, [bool centered = false]) {
    GridNode poolable = new Ranger.Poolable.of(GridNode, _createPoolable);
    poolable.init();
    poolable.width = width;
    poolable.height = height;
    poolable.centered = centered;
    return poolable;
  }

  static GridNode _createPoolable() => new GridNode._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
    
    // To draw the grid full dimensions we need to use non-transformed
    // dimensions.
    if (parent != null) {
      ainv = parent.calcInverseTransform();

      dimension.setValues(width, height);
      Ranger.Vector2P tp = Ranger.PointApplyAffineTransform(dimension, ainv);
      dimension.setFrom(tp.v);

      tp.moveToPool();
    }
  }

  // This GridNode needs to know that it was added as a child.
  @override
  void addedAsChild() {
    dirty = true;
  }
  
  @override
  void draw(Ranger.DrawContext context) {

    // Note: we really should extract the length
    double invScale = 1.0 / calcUniformScaleComponent();
    context.lineWidth = invScale;
    
    if (!centered)
      _drawNonCentered(context, dimension.x, dimension.y);
    else
      _drawCentered(context, dimension.x, dimension.y);
    Ranger.Application.instance.objectsDrawn++;

  }
  
  void _drawCentered(Ranger.DrawContext context, double w, double h) {
    context.drawColor = minorColor;
    
    // Draw horizontal lines moving toward +Y
    for (double r = minorSpacing; r <= h; r += minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(-w, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }
    
    // Draw horizontal lines moving toward -Y
    for (double r = -minorSpacing; r >= -h; r -= minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(-w, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }

    // vertical lines
    for (double c = minorSpacing; c <= w; c += minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, -h);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }

    for (double c = -minorSpacing; c >= -w; c -= minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, -h);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }

    context.drawColor = majorColor;
    // horizontal lines
    for (double r = majorSpacing; r <= h; r += majorSpacing) {
      ls.setValues(-w, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double r = -majorSpacing; r >= -h; r -= majorSpacing) {
      ls.setValues(-w, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double c = majorSpacing; c <= w; c += majorSpacing) {
      ls.setValues(c, -h);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
    for (double c = -majorSpacing; c >= -w; c -= majorSpacing) {
      ls.setValues(c, -h);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
    
    ls.setValues(0.0, -h);
    le.setValues(0.0, h);
    context.drawLine(ls, le);

    ls.setValues(-w, 0.0);
    le.setValues(w, 0.0);
    context.drawLine(ls, le);
    
  }

  void _drawNonCentered(Ranger.DrawContext context, double w, double h) {
    context.drawColor = minorColor;
    for (double r = 0.0; r <= h; r += minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(0.0, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }

    // vertical lines
    for (double c = 0.0; c <= w; c += minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, 0.0);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }
    
    context.drawColor = majorColor;
    // horizontal lines
    for (double r = 0.0; r <= h; r += majorSpacing) {
      ls.setValues(0.0, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double c = 0.0; c <= w; c += majorSpacing) {
      ls.setValues(c, 0.0);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
  }
}

// This node is a custom rendering node specific to Canvas2D
class SquareParticleNode extends Ranger.Node with Ranger.Color4Mixin {
  Vector2 localPosition = new Vector2.zero();
  
  Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  factory SquareParticleNode.init() {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    if (poolable.init()) {
      poolable.size = 1.0;
      poolable.center();
      return poolable;
    }
    return null;
  }

  factory SquareParticleNode.initWithColorAndScale(Ranger.Color4<int> from, [double fromScale = 1.0]) {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    if (poolable.init()) {
      poolable.initWithColor(from);
      poolable.initWithUniformScale(poolable, fromScale);
      poolable.size = 1.0;
      poolable.center();
      return poolable;
    }
    return null;
  }
  
  SquareParticleNode._();
  
  factory SquareParticleNode.pooled() {
    SquareParticleNode poolable = new Ranger.Poolable.of(SquareParticleNode, _createPoolable);
    return poolable;
  }

  static SquareParticleNode _createPoolable() => new SquareParticleNode._();

  SquareParticleNode clone() {
    SquareParticleNode poolable = new SquareParticleNode.pooled();
    
    if (poolable.initWith(this)) {
      poolable.initWithColor(initialColor);
      poolable.initWithUniformScale(poolable, uniformScale);
      poolable.size = 1.0;
      poolable.center();
      return poolable;
    }
    
    return null;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }
  
  set size(double s) {
    rect.width = s;
    rect.height = s;
  }

  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
  }

  @override
  void draw(Ranger.DrawContext context) {
//    CanvasRenderingContext2D render = context.renderContext;
//
//    render.fillStyle = color.toString();
//    render.rect(rect.bottom, rect.left, rect.width, rect.height);
//    render.fill();

//    render..strokeStyle = drawColor
//             ..stroke();
    
    // This color is from the color mixin. Once such object that can
    // change it is the TweenParticle.
    context.fillColor = color.toString();

    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    Ranger.Application.instance.objectsDrawn++;
  }
}

abstract class PolygonNode extends Ranger.Node with Ranger.GroupingBehavior {
  bool solid = true;
  bool outlined = false;
  bool showAABBox = false;
  bool enableAABoxVisual = true;
  bool showRectBox = false;
  bool isSelectable = true;
  
  String drawColor = Ranger.Color3IWhite.toString();
  String fillColor = Ranger.color4IFromHex("#aaaaaa").toString();

  Ranger.MutableRectangle<double> worldAABBox = new Ranger.MutableRectangle<double>.withP(
      0.0, 0.0, 0.0, 0.0);
  
  Ranger.Polygon polygon;
  double uniScale = 1.0;
  
  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
      
      return true;
    }
    
    return false;
  }
  
  void select() {
    uniScale = this.nodeToWorldScale();
    showAABBox = true;
  }
  
  void unSelect() {
    showAABBox = false;
    intersectsViewPort = false;
  }

  @override
  void dirtyChanged(Ranger.Node node) {
    super.dirtyChanged(node);
    uniScale = this.nodeToWorldScale();
    calcAABBToWorld();
  }

  @override
  bool isVisible() {
    Ranger.Application app = Ranger.Application.instance; 

    bool intersects = checkVisibility(worldAABBox, app.viewPortWorldAABB);
    
    if (intersects && isSelectable)
      intersectsViewPort = true;
    else
      intersectsViewPort = false;
    
    return intersects;
  }

  @override
  Ranger.MutableRectangle<double> calcAABBToWorld() {
    // The aabox will have been set by a subclass.
    worldAABBox.left = polygon.aabbox.left;
    worldAABBox.bottom = polygon.aabbox.bottom;
    worldAABBox.width = polygon.aabbox.width;
    worldAABBox.height = polygon.aabbox.height;
    
    Ranger.AffineTransform transform = nodeToWorldTransform();
    Ranger.RectangleApplyAffineTransform(worldAABBox, transform);

    if (children == null)
      return worldAABBox;

    // Iterate children collecting Bounding Boxes
    for(PolygonNode child in children) {
      if (child.visible) {
        Ranger.MutableRectangle<double> bbox = child._calcAABBOfChild(transform);

        // Accumulate bounds. Union aabbox to bbox
        worldAABBox.union(bbox);

        bbox.moveToPool();    // Return to pool.
      }
    }

    transform.moveToPool();

    return worldAABBox;
  }

  // Internal recursion method. See [calcAABBToWorld].
  Ranger.MutableRectangle<double> _calcAABBOfChild(Ranger.AffineTransform parentTransform) {
    // Create a rectangle to accumulate this child's bounds.
    Ranger.MutableRectangle<double> accumBox = new Ranger.MutableRectangle<double>.withP(
        polygon.aabbox.left, polygon.aabbox.bottom, polygon.aabbox.width, polygon.aabbox.height);
    
    //AffineTransform transform = affineTransformMultiply(nodeToWorldTransform(), parentTransform);
    Ranger.AffineTransform transform = nodeToWorldTransform();
    
    Ranger.RectangleApplyAffineTransform(accumBox, transform);

    if (children != null) {
      // Iterate children collecting Bounding Boxes
      for(PolygonNode child in children) {
        if (child.visible) {
          // Recurse into children
          Ranger.MutableRectangle<double> childBox = child._calcAABBOfChild(transform); // A pooled rectangle
          
          // Accumulate bounds. Union child bbox.
          accumBox.union(childBox);
          
          // Return bbox back to pool for next child.
          childBox.moveToPool();
        }
      }
    }
    
    transform.moveToPool();
    
    return accumBox;
  }

  /**
   * Iterate through this Node's children accumulating local AABBoxes.
   * An AABBox only needs to be recomputed if a Node becomes dirty.
   */
  Ranger.MutableRectangle<double> calcParentAABB() {
    Ranger.AffineTransform at = new Ranger.AffineTransform.withAffineTransformP(calcTransform());

    // Take this node's aabbox and transform it 
    Ranger.RectApplyAffineTransformTo(polygon.aabbox, rect, at);

    if (children == null)
      return rect;

    // Iterate children collecting Bounding Boxes
    for(PolygonNode child in children) {
      if (child.visible) {
        Ranger.MutableRectangle<double> bbox = child._calcParentAABB(at);

        // Accumulate bounds. Union aabbox to bbox
        rect.union(bbox);

        bbox.moveToPool();    // Return to pool.
      }
    }

    at.moveToPool();

    return rect;
  }
  
  // Internal recursion
  Ranger.MutableRectangle<double> _calcParentAABB(Ranger.AffineTransform parentTransform) {
    // Create a rectangle to accumulate aabboxes.
    Ranger.MutableRectangle<double> accumBox = new Ranger.MutableRectangle<double>.withP(0.0, 0.0, 0.0, 0.0);
    
    Ranger.AffineTransform transform = Ranger.affineTransformMultiply(calcTransform(), parentTransform);
    
    Ranger.RectApplyAffineTransformTo(polygon.aabbox, accumBox, transform);

    if (children != null) {
      // Iterate children collecting Bounding Boxes
      for(PolygonNode child in children) {
        if (child.visible) {
          // Recurse into children
          Ranger.MutableRectangle<double> childBox = child._calcParentAABB(transform);
          
          // Accumulate bounds. Union child bbox.
          accumBox.union(childBox);
          
          // Return bbox back to pool for next child.
          childBox.moveToPool();
        }
      }
    }
    
    transform.moveToPool();
    
    return accumBox;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.fillColor = fillColor;
    context.drawColor = drawColor;
    
    if (solid)
      context.drawPoly(polygon.points, Ranger.DrawContext.CLOSED, Ranger.DrawContext.SOLID);

    context.lineWidth = 1.0 / uniScale;

    if (outlined) {
      context.drawPoly(polygon.points, Ranger.DrawContext.CLOSED, Ranger.DrawContext.OUTLINED);
      
      context.drawLineByComp(0.0, 0.0, 0.5, 0.0);
    }

    if (showAABBox && enableAABoxVisual) {
      context.drawColor = "rgb(255,0,0)";
      context.drawRect(polygon.aabbox.left, polygon.aabbox.bottom, polygon.aabbox.width, polygon.aabbox.height);
    }

    if (showRectBox) {
      context.lineWidth = 1.0;
      context.drawColor = "rgb(0,255,255)";
      context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    }
    
    if (intersectsViewPort) {
      context.drawColor = "rgb(0,0,0)";
      context.drawLineByComp(-0.25, 0.25, 0.25, -0.25);
      context.drawLineByComp(-0.25, -0.25, 0.25, 0.25);
    }
    
    Ranger.Application.instance.objectsDrawn++;
  }

  bool pointInside(Vector2 point) {
    Ranger.AffineTransform at = calcTransform();
    
    return polygon.isPointInside(point);
  }

}

class SquarePolygonNode extends PolygonNode with Ranger.VisibilityBehavior {
  
  //Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  SquarePolygonNode._();
  
  factory SquarePolygonNode() {
    SquarePolygonNode poolable = new SquarePolygonNode.pooled();
    if (poolable.init()) {
      poolable.polygon = new Ranger.Square.centered();
      return poolable;
    }
    return null;
  }

  factory SquarePolygonNode.pooled() {
    SquarePolygonNode poolable = new Ranger.Poolable.of(SquarePolygonNode, _createPoolable);
    return poolable;
  }

  static SquarePolygonNode _createPoolable() => new SquarePolygonNode._();

  @override
  void addedAsChild() {
    dirty = true;
    select();
  }

  @override
  SquarePolygonNode clone() {
    SquarePolygonNode poolable = new SquarePolygonNode.pooled();
    if (poolable.init()) {
      poolable.initWith(this);
      poolable.fillColor = fillColor;
      poolable.solid = solid;
      poolable.outlined = outlined;
      poolable.drawColor = drawColor;
      return poolable;
    }
    
    return null;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
}

class CirclePolygonNode extends PolygonNode with Ranger.VisibilityBehavior {
  
  //Ranger.MutableRectangle<double> rect = new Ranger.MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  double uniScale = 1.0;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  CirclePolygonNode._();
  
  factory CirclePolygonNode.withSegments(int segments) {
    CirclePolygonNode poolable = new CirclePolygonNode.pooled();
    if (poolable.init()) {
      poolable.polygon = new Ranger.Circle.withSegments(segments);
      poolable.select();
      return poolable;
    }
    return null;
  }

  factory CirclePolygonNode.pooled() {
    CirclePolygonNode poolable = new Ranger.Poolable.of(CirclePolygonNode, _createPoolable);
    return poolable;
  }

  static CirclePolygonNode _createPoolable() => new CirclePolygonNode._();

  CirclePolygonNode clone() {
    CirclePolygonNode poolable = new CirclePolygonNode.pooled();
    if (poolable.init()) {
      poolable.initWith(this);
      poolable.fillColor = fillColor;
      poolable.solid = solid;
      poolable.outlined = outlined;
      poolable.drawColor = drawColor;
      return poolable;
    }
    return null;
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  void addedAsChild() {
    dirty = true;
    select();
  }


}
