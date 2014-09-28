part of unittests;

/**
 * This test shows how to properly dispose of [Node]s once they are no
 * longer relevant. In this example as each [TextNode]'s animation is
 * [UTE.TweenCallback.COMPLETE] we [removeChild] as it is no longer visible.  
 */
class MouseLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  Ranger.SpriteImage _mouse;
  
  String startColor;
  String endColor;

  List<RectangleNode> boxes = new List<RectangleNode>();

  Aabb2 _box = new Aabb2();
  Vector2 _min = new Vector2.zero();
  Vector2 _max = new Vector2.zero();
  
  Ranger.TextNode _title;
  
  MouseLayer();
 
  factory MouseLayer.basic([bool centered = true, int width, int height]) {
    MouseLayer layer = new MouseLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = true;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    _mouse = new Ranger.SpriteImage.withElement(GameManager.instance.resources.mouse);
    
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#eedc00").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#ff7f32").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#d14124").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#dde5ed").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#98a4ae").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#00ab8e").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#26d07c").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#00a9e0").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#80276c").toString();
    boxes.add(new RectangleNode.basic());
    boxes.last.fillColor = Ranger.color4IFromHex("#385e9d").toString();
    
    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween.registerAccessor(PointColor, app.animations);
    UTE.Tween.registerAccessor(RectangleNode, app.animations);
    
    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _configure();
    
    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    enableKeyboard = true;
    
    Ranger.Application app = Ranger.Application.instance;
    app.animations.alternateHandler = nodeCallbackHandler;

    super.onEnter();
  }
  
  @override
  void onExit() {
    super.onExit();
    
    // Just for this Layer we redirect the TweenAnimation's handler to
    // this node such that we can remove nodes as they complete their
    // animations.
    Ranger.Application app = Ranger.Application.instance;
    app.animations.resetToDefaultHandler();
    // Stop any previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.tweenMan.killTarget(_title, Ranger.TweenAnimation.TRANSLATE_Y);
    app.animations.tweenMan.killTarget(_mouse, Ranger.TweenAnimation.SHAKE);

  }

  void nodeCallbackHandler(int type, UTE.BaseTween source) {
    PointColor node;
    
    if (source.userData != null) {
      if (source.userData is PointColor) {
        node = source.userData as PointColor;
    
        switch(type) {
          case UTE.TweenCallback.COMPLETE:
            removeChild(node, true);
            break;
        }
      }
    }
  }
  
  void _shakeIcon() {
    // I am using an Immediately invoked Anonymous Closure 
    // to localize a variable rather creating a global variable.
    // In this case it is the initial position of the node being shaken.
    // originalPos could have been declared at the GameLayer level but
    // I didn't want the GameLayer littered with temporary objects just
    // for an animation.
    () {
      Ranger.Application app = Ranger.Application.instance;
      Ranger.Vector2P originalPos = new Ranger.Vector2P();
      UTE.Tween shake = app.animations.shake(
          _mouse,
          0.25,
          2.0,
          (int type, UTE.BaseTween source) {
            switch(type) {
              case UTE.TweenCallback.BEGIN:
                Ranger.Node n = source.userData as Ranger.Node;
                originalPos.v.setFrom(n.position);
                break;
              case UTE.TweenCallback.END:
                Ranger.Node n = source.userData as Ranger.Node;
                n.position.setFrom(originalPos.v);
                originalPos.moveToPool();
                break;
            }
          }
      );
    }();
  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_home.containsPoint(nodeP.v)) {
      app.sceneManager.popScene();
    }
    else {
      for(RectangleNode rn in boxes) {
        nodeP = app.drawContext.mapViewToNode(rn, event.offset.x, event.offset.y);
        // Moving an object back to the pool doesn't make it invalid or
        // unaccessable. It is simply available on the next allocate.
        // Hence, the "if" statement is making a runtime valid check. 
        nodeP.moveToPool();
        if (rn.containsPoint(nodeP.v)) {
          nodeP = app.drawContext.mapViewToNode(this, event.offset.x, event.offset.y);
          nodeP.moveToPool();
          _animateCircle(rn, nodeP.v);
          break;
        }
      }
    }

    _shakeIcon();
    
    return true;
  }
  
  void _animateCircle(RectangleNode rn, Vector2 p) {
    int index = boxes.indexOf(rn);
    int nIndex = (index + 1) % (boxes.length);
    
    PointColor pc = new PointColor.initWith(null);
    pc.fillColor = rn.fillColor;
    pc.outlineColor = boxes[nIndex].fillColor;
    pc.uniformScale = 1.0;
    pc.position = p;
    addChild(pc, 0, 1010);

    Ranger.Application app = Ranger.Application.instance;

    UTE.Timeline seq = new UTE.Timeline.sequence();

    // Optional Fade in. Would need to Create a Text node that mixes in
    // Color4Mixin to control transparency.
    
    // move down
    UTE.BaseTween scaleUp = app.animations.scaleTo(
        pc, 1.0,
        50.0, 50.0,
        UTE.Bounce.OUT,
        Ranger.TweenAnimation.SCALE_XY, pc,
        Ranger.TweenAnimation.MULTIPLY, false);
    seq.push(scaleUp);
    seq.start();
  }
  
  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    //---------------------------------------------------------------
    // Box nodes.
    //---------------------------------------------------------------
    Ranger.Size<double> size = app.designSize;

    // A grid (5x2) color squares.
    double boxWidth = size.width / 5.0;
    double boxHeight = size.height / 2.0;
    double dx = -hWidth;
    double dy = -hHeight;
    int r = 0;
    for(RectangleNode rn in boxes) {
      rn.scaleTo(boxWidth, boxHeight);
      rn.setPosition(dx, dy);
      addChild(rn, 0, 922);
      dx += boxWidth;
      if (r == 4) {
        dx = -hWidth;
        dy += boxHeight;
      }
      r++;
    }
    
    //---------------------------------------------------------------
    // Icon nodes.
    //---------------------------------------------------------------
    // Note: I explicitly set the zOrder to 10 to make sure they are
    // rendered above anything. Or I could have simply arranged the code
    // such that addChilds for this icon is done last.
    addChild(_mouse, 10, 3399);
    _mouse.uniformScale = 3.0;
    _mouse.setPosition(hGap, -vGap);
    
    addChild(_home, 10, 120);
    _home.uniformScale = 5.0;
    _home.setPosition(hGap, vGap);

    //---------------------------------------------------------------
    // Text nodes.
    //---------------------------------------------------------------
    double vDelta = -vGap * 2.0;
    _title = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#4e87a0"));
    _title.text = "Begin...uhmmm...mousing???";
    _title.setPosition(-hGap + (hGap * 0.01), vDelta);
    _title.strokeColor = Ranger.Color4IWhite;
    _title.strokeWidth = 1.0;
    _title.uniformScale = 7.0;
    addChild(_title, 10, 222);
    
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _title, 
        2.5,
        vDelta.abs(), 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
      ..start();

  }
 
//  @override
//  void drawBackground(Ranger.DrawContext context) {
//    if (!transparentBackground) {
//      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;
//      Ranger.Application app = Ranger.Application.instance;
//      
//      Ranger.Size<double> size = app.designSize;
//      context.save();
//
//      // Draw grid (5x2) color squares.
//      double boxWidth = size.width / 5.0;
//      double boxHeight = size.height / 2.0;
//      double dx = 0.0;
//      double dy = 0.0;
//      
//      context2D..fillStyle = goldYellow
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = orange
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = brickRed
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = offWhite
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = grey
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dy += boxHeight;
//      
//      dx = 0.0;
//      context2D..fillStyle = darkTeal
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = fieldGreen
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//      
//      dx += boxWidth;
//      context2D..fillStyle = softBlue
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//      
//      dx += boxWidth;
//      context2D..fillStyle = purple
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      dx += boxWidth;
//      context2D..fillStyle = darkSteal
//               ..fillRect(dx, dy, boxWidth, boxHeight);
//
//      
//      context.restore();
//    }
//  }

}
