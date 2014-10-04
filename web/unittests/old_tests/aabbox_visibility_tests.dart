library aabboxvisLibtests;

import 'dart:html';
import 'dart:collection';

//import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

import 'package:ranger/ranger.dart' as Ranger;

import 'scenes_and_nodes.dart';
import 'aabb_container_node.dart';

InputElement _nodeTagElement;
InputElement _applyAnimationElement;
SelectElement _animationsElement;
InputElement _loadJSONElement;
InputElement zoomSlider;
InputElement _spriteFrameElement;
SelectElement _frameRateElement;
Element viewMouseElement;
Element designPosElement;
Element worldPosElement;
Element nodePosElement;
Element localPosElement;
Element objectsDrawnElement;
Element framePerPeriodElement;
Element frameCountElement;
CheckboxInputElement stepEnabledElement;
InputElement stepElement;
Element fpsElement;

int maxParticles = 300;

Ranger.Scene aabboxVisibilityTest(Ranger.Application engine) {
  _loadJSONElement = querySelector("#loadJson");
  _loadJSONElement.onClick.listen(
      (Event event) => _loadJson()
  );

  _nodeTagElement = querySelector("#nodeTag");
  _animationsElement = querySelector("#animations");

  Ranger.Scene scene = _buildScene();
  
  return scene;
}

void _loadJson() {
  LinkedHashMap configuration = Ranger.Application.instance.configuration;
  print(configuration);
//  String path = "resources/config.json";
//  HttpRequest.getString(path)
//    .then(_processJson)
//    .catchError(_handleError);
}

void _processJson(String jsonString) {
  print(jsonString);
}

void _handleError(Error error) {
  
}

/*
 * We want to render both the local-aabbox an world-aabbox on top of
 * the of the Node.
 */
Ranger.Scene _buildScene() {
  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#668888"), true);
//  scene.addChild(layer, 0, 2010);

  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  Ranger.AnchoredScene scene = new Ranger.AnchoredScene.withPrimaryLayer(layer, _completeVisit);
  scene.tag = 2001;

  return scene;
}

void _completeVisit() {
  Ranger.Application app = Ranger.Application.instance;
  
  if (app.updateStats) {
    objectsDrawnElement.text = "${app.objectsDrawn}";
    framePerPeriodElement.text = "${app.framesPerPeriod} , UPS: ${app.updatesPerPeriod}";
    frameCountElement.text = "${app.frameCount}";
    
    app.framesPerPeriod = 0;
    app.updatesPerPeriod = 0;
    app.deltaAccum = 0.0;
    
    if (!(app.fpsAverage.isInfinite || app.fpsAverage.isNaN))
      fpsElement.text = "${app.fpsAverage.toStringAsFixed(2)}";
    else
      fpsElement.text = "Not enabled";
  }
}

class TestLayer extends Ranger.BackgroundLayer {
  Ranger.ParticleSystem ps;
  Ranger.ParticleActivation pactivation;

  Ranger.GroupNode _zoomControl;
  
  Ranger.Velocity pVelocity = new Ranger.Velocity();

  bool _turnCW = false;
  bool _turnCCW = false;
  bool _fireParticle = false;
  
  Ranger.BaseNode _selectedNode;

  Vector2 _touchBegin = new Vector2.zero();
  Vector2 _prevPos = new Vector2.zero();
  Vector2 _delta = new Vector2.zero();
  
  SquarePolygonNode worldAABB;
  
  SquarePolygonNode viewPort;
  
  int debug = 0;
  Ranger.SpriteSheetImage gTypeSheet;
  
  TestLayer() {
    viewMouseElement = querySelector("#viewMouse");
    designPosElement = querySelector("#designPos");
    worldPosElement = querySelector("#worldPos");
    nodePosElement = querySelector("#nodePos");
    localPosElement = querySelector("#localPos");
    objectsDrawnElement = querySelector("#objectsDrawn");
    framePerPeriodElement = querySelector("#ufps");
    frameCountElement = querySelector("#frameCount");
    fpsElement = querySelector("#fps");

    ps = new Ranger.ModerateParticleSystem.initWith(300);
    ps.setPosition(0.0, 0.0);
    pactivation = new Ranger.RandomValueParticleActivator();
    ps.particleActivation = pactivation;
    
//    _applyAnimationElement = querySelector("#applyAnimation");
//    _applyAnimationElement.onClick.listen(
//        (Event event) => _applyAnimation()
//    );
    
    zoomSlider = querySelector("#zoomSlider");
//    zoomSlider.onChange.listen((Event e) => _zoomChanged());
    zoomSlider.onMouseMove.listen((Event e) => _zoomChanged());

    _spriteFrameElement = querySelector("#spriteFrame");
    _spriteFrameElement.onChange.listen(
        (Event event) => _setSpriteFrame()
    );

    _frameRateElement = querySelector("#spriteFrameRate");
    _frameRateElement.onChange.listen(
        (Event event) => _changeFrameRate()
    );

    stepEnabledElement = querySelector("#stepEnabled");
    stepEnabledElement.onChange.listen(
        (Event event) => _changeStepEnable()
        );

    stepElement = querySelector("#step");
    stepElement.onClick.listen(
        (Event event) => Ranger.Application.instance.step = 0
        );
    
    stepElement.disabled = !Ranger.Application.instance.stepEnabled;

  }
  
  factory TestLayer.withColor(Ranger.Color4<int> color, [bool centered = true, int width, int height]) {
    TestLayer layer = new TestLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = color;
    return layer;
  }
  
  @override
  void release() {
//    viewPortWorldAABB.moveToPool();
  }
  
  // Note: This is now in the DrawContext's before() method.
//  @override
//  void draw(Ranger.DrawContext context) {
//    CanvasRenderingContext2D render = context.renderContext as CanvasRenderingContext2D;
//    
////    render.save();
//    render.beginPath();
//    if (centered) {
////      render.rect(-contentSize.width/2.0, -contentSize.height/2.0, contentSize.width, contentSize.height);
//      render.rect(-position.x, -position.y, contentSize.width, contentSize.height);
//    }
//    else
//      render.rect(0.0, 0.0, contentSize.width, contentSize.height);
//    render.clip();
////    render.restore();
//    
//    super.draw(context);
//  }

  @override
  void update(double dt) {
    if (!(_turnCW && _turnCCW)) {
      if (_turnCW) {
        double angle = ps.particleActivation.angleDirection;
        angle -= 5.0;
        ps.particleActivation.angleDirection = angle;
      }
      else if (_turnCCW) {
        double angle = ps.particleActivation.angleDirection;
        angle += 5.0;
        ps.particleActivation.angleDirection = angle;
      }
    }
    
    if (_fireParticle) {
      ps.activateByStyle(Ranger.ParticleActivation.VARIANCE_DIRECTIONAL);
    }
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    super.draw(context);
  }

  @override
  void onEnter() {
    enableKeyboard = true;
    super.onEnter();
//    if (!centered) {
//      setPosition(0.0, 300.0);
//    }
//    uniformScale = 0.5;
//    rotationByDegrees = 45.0;
    // Set the viewport to 1/3 the size of the screen size.
    Ranger.Application app = Ranger.Application.instance;
    //print("app.viewPortWindowAABB: ${app.viewPortWindowAABB}");

//    gTypeSheet = new Ranger.SpriteSheetImage("../resources/gtype.json");
//    gTypeSheet.load(spriteLoaded);
    
    _zoomControl = new Ranger.GroupNode.basic();
    addChild(_zoomControl, 0, 99);
    
    //---------------------------------------------------------------
    // Basic grid
    //---------------------------------------------------------------
    Ranger.Size<double> size = app.designSize;
    GridNode grid = new GridNode.withDimensions(size.width, size.height, centered);
    _zoomControl.addChild(grid, 0, 123);

    //---------------------------------------------------------------
    // Adhoc viewport for visual testing. Only add if you want to see
    // the viewport.
    //---------------------------------------------------------------
    //viewPort = new SquarePolygonNode();
    //viewPort.solid = false;
    //viewPort.outlined = true;
    //viewPort.drawColor = "rgb(255,200,0)";
    //viewPort.setPosition(0.0, 0.0);
    //viewPort.isSelectable = false;
    //addChild(viewPort, 10, 1010);

    //---------------------------------------------------------------
    // Create a three node hiearchy
    //---------------------------------------------------------------
    SquarePolygonNode basicBox = new SquarePolygonNode();
    basicBox.solid = true;
    basicBox.outlined = false;
    basicBox.uniformScale = 100.0;
    basicBox.fillColor = "rgba(128,128,128, 0.5)";
    basicBox.setPosition(200.0, 100.0);

    SquarePolygonNode boxChild = new SquarePolygonNode();
    boxChild.solid = true;
    boxChild.outlined = false;
    boxChild.setPosition(1.0, 0.0);
    boxChild.fillColor = "rgb(255,200,0)";
    basicBox.addChild(boxChild, -10, 102);

    CirclePolygonNode boxChild2 = new CirclePolygonNode.withSegments(5);
    boxChild2.uniformScale = 0.5;
    boxChild2.setPosition(1.0, 1.0);
    boxChild2.fillColor = "rgb(100,200,0)";
    boxChild2.outlined = true;
    boxChild.addChild(boxChild2, 10, 103);

    //---------------------------------------------------------------
    // A container for the basicBox node and aabox node.
    //---------------------------------------------------------------
    AABBContainerNode container = new AABBContainerNode.withLead(basicBox);
    _zoomControl.addChild(container, 10, 106);


    //---------------------------------------------------------------
    // Create independent nodes.
    //---------------------------------------------------------------
    SquarePolygonNode squarePolyNode = new SquarePolygonNode();
    squarePolyNode.setPosition(-350.0, 0.0);
    squarePolyNode.outlined = true;
    squarePolyNode.enableAABoxVisual = false;
    squarePolyNode.fillColor = "rgba(10,50,100, 0.5)";
    squarePolyNode.uniformScale = 100.0;
    //squarePolyNode.rotationByDegrees = -45.0;
    _zoomControl.addChild(squarePolyNode, 10, 703);

    //AABBContainerNode container2 = new AABBContainerNode.withLead(squarePolyNode);
    //addChild(container2, 10, 116);

    CirclePolygonNode circlePolyNode = new CirclePolygonNode.withSegments(16);
    circlePolyNode.setPosition(-100.0, -100.0);
    circlePolyNode.fillColor = "rgb(100,50,100)";
    circlePolyNode.uniformScale = 100.0;
    circlePolyNode.outlined = true;
    _zoomControl.addChild(circlePolyNode, 10, 704);

    //---------------------------------------------------------------
    // A simple marker.
    //---------------------------------------------------------------
    LeafPoint orangeCircle = new LeafPoint();
    orangeCircle.setPosition(640.0, 400.0);
    orangeCircle.color = Ranger.Color3IOrange;
    orangeCircle.uniformScale = 10.0;
    _zoomControl.addChild(orangeCircle, 100, 109);

    //---------------------------------------------------------------
    // A node to view the world AABBox of a selected node.
    //---------------------------------------------------------------
    worldAABB = new SquarePolygonNode();
    worldAABB.solid = false;
    worldAABB.outlined = false;
    worldAABB.showRectBox = true;
    worldAABB.showAABBox = true;
    worldAABB.enableAABoxVisual = true;
    worldAABB.drawColor = "rgb(0,255,0)";
    worldAABB.setPosition(0.0, 0.0);
    worldAABB.isSelectable = false;
    worldAABB.visible = false;
    worldAABB.uniformScale = 1.0;
    _zoomControl.addChild(worldAABB, 10, 1020);

    //---------------------------------------------------------------
    // Paricle system
    //---------------------------------------------------------------
    Ranger.ParticleSystemVisual visual = ps.emitterVisual;
    visual.size = 25.0;
    _zoomControl.addChild(visual, 200, 5001);

    app.scheduler.scheduleTimingTarget(ps);
    
    pVelocity.maxMagnitude = 5.0;
    pVelocity.increaseSpeed(2.0);
    
    _tweenParticleTest();
    
    ps.active = true;
    
    _zoomChanged();
    
    scheduleUpdate();
  }

  void spriteLoaded() {
    print("sprite loaded");
    //---------------------------------------------------------------
    // A sprite
    //---------------------------------------------------------------
    Ranger.Sprite sprite = new Ranger.CanvasSprite.initWith(gTypeSheet);
    sprite.setPosition(100.0, -100.0);
    
    List<int> frmRts = [0, 1, 5, 10, 15, 30, 60];
    int i = 0;
    for(int frmRt in frmRts) {
      if (frmRt == sprite.frameRate) {
        _frameRateElement.selectedIndex = i;
      }
      i++;
    }
    
    //sprite.uniformScale = 3.0;
    addChild(sprite, 1, 4000);
    Ranger.Application app = Ranger.Application.instance; 
    app.scheduler.scheduleTimingTarget(sprite);

  }
  
  void _setSpriteFrame() {
    if (_spriteFrameElement.value.length > 0) {
      int frame = int.parse(_spriteFrameElement.value);
  
      Ranger.CanvasSprite node;
  
      Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
      Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
  
      node = sceneGB.getChildByTag(4000);
      node.nextFrame(frame);
    }
  }
  
  void _changeFrameRate() {
    int rate = int.parse(_frameRateElement.value);
    
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
    Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;

    Ranger.CanvasSprite node;
    node = sceneGB.getChildByTag(4000);
    node.changeFrameRate(rate);
  }
  
  void _changeStepEnable() {
    Ranger.Application app = Ranger.Application.instance;
    app.stepEnabled = stepEnabledElement.checked;
    stepElement.disabled = !app.stepEnabled;
  }
  
  bool _isPointInsideNode(Ranger.BaseNode node, int viewX, int viewY) {
    Ranger.Application app = Ranger.Application.instance;
    
    bool inside = false;
    
    // Map mouse-space to local-space of child node
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, viewX, viewY);
    
    if (node.pointInside(nodeP.v)) {
      inside = true;
      
      // Map view-space point to local-space of node's parent node for
      // tracking.
      Ranger.Vector2P layerP = app.drawContext.mapViewToNode(node.parent, viewX, viewY);

      _touchBegin.setFrom(layerP.v);
      _prevPos.setFrom(layerP.v);

      layerP.moveToPool();
    }
    
    nodeP.moveToPool();
    
    return inside;
  }
  
  Ranger.BaseNode _isOverNode(int viewX, int viewY) {
    Ranger.Application app = Ranger.Application.instance; 

    for(Ranger.Node child in children) {
      if (!child.isVisible())
        continue;
      
      if (child is PolygonNode) {
        if (!child.isSelectable)
          continue;
      }

      if (child is Ranger.GroupingBehavior) {
        Ranger.GroupingBehavior gb = child as Ranger.GroupingBehavior;
        if (gb.children != null && gb.children.isNotEmpty) {
          Ranger.BaseNode over = _isOverNodeRecurse(gb.children, viewX, viewY);
          if (over != null)
            return over;
        }
      }
      
      if (_isPointInsideNode(child, viewX, viewY))
        return child;
    }
    
    return null;
  }

  Ranger.BaseNode _isOverNodeRecurse(List<Ranger.BaseNode> children, int viewX, int viewY) {
    Ranger.Application app = Ranger.Application.instance; 

    for(Ranger.BaseNode child in children) {
      if (!child.isVisible())
        continue;
      
      if (child is PolygonNode) {
        if (!child.isSelectable)
          continue;
      }

      if (child is Ranger.GroupingBehavior) {
        Ranger.GroupingBehavior gb = child as Ranger.GroupingBehavior;
        if (gb.children != null && gb.children.isNotEmpty) {
          Ranger.BaseNode over = _isOverNodeRecurse(gb.children, viewX, viewY);
          if (over != null)
            return over;
        }
      }
      
      if (_isPointInsideNode(child, viewX, viewY))
        return child;
    }
    
    return null;
  }
  
  void _clearSelected() {
    for(Ranger.Node child in children) {
      if (child is PolygonNode) {
        child.unSelect();
      }

      if (child is Ranger.GroupingBehavior) {
        Ranger.GroupingBehavior gb = child as Ranger.GroupingBehavior;
        if (gb.children != null && gb.children.isNotEmpty) {
          _clearSelectedRecurse(gb.children);
        }
      }
    }
  }
   
  void _clearSelectedRecurse(List<Ranger.BaseNode> children) {
    for(Ranger.Node child in children) {
      if (child is PolygonNode) {
        child.unSelect();
      }

      if (child is Ranger.GroupingBehavior) {
        Ranger.GroupingBehavior gb = child as Ranger.GroupingBehavior;
        if (gb.children != null && gb.children.isNotEmpty) {
          _clearSelectedRecurse(gb.children);
        }
      }
    }
  }
   
  // TODO add touch capability back similar to keyboard
//  @override
//  bool onTouchsBegan(Ranger.MutableEvent event) {
//
//    _clearSelected();
//
//    _selectedNode = _isOverNode(event.mouse.offset.x, event.mouse.offset.y); 
//
//    if (_selectedNode != null && _selectedNode is PolygonNode) {
//
//      PolygonNode pNode = _selectedNode as PolygonNode;
//      pNode.showAABBox = true;
//      pNode.select();
//
//      worldAABB.visible = true;
//      
//      // For teal aabbox
//      Ranger.MutableRectangle<double> nodeAABBox = pNode.calcParentAABB();
//      
//      worldAABB.rect.left = nodeAABBox.left;
//      worldAABB.rect.bottom = nodeAABBox.bottom;
//      worldAABB.rect.width = nodeAABBox.width;
//      worldAABB.rect.height = nodeAABBox.height;
//
//    }
//    else {
//      worldAABB.visible = false;
//    }
//    
//    //event.touch.preventDefault();
//    return Ranger.TouchDelegate.CLAIMED;
//  }

//  @override
//  void onTouchsDrag(Ranger.MutableEvent event) {
//    if (_selectedNode != null && _selectedNode is PolygonNode) {
//      PolygonNode pNode = _selectedNode as PolygonNode;
//
//      Ranger.Application app = Ranger.Application.instance; 
//
//      Ranger.Vector2P layerP = app.drawContext.mapViewToNode(_selectedNode.parent, event.mouse.offset.x, event.mouse.offset.y);
//      
//      _delta.setValues(layerP.v.x - _prevPos.x, layerP.v.y - _prevPos.y);
//      
//      _selectedNode.setPosition(_selectedNode.position.x + _delta.x, _selectedNode.position.y + _delta.y);
//      
//      Ranger.MutableRectangle<double> nodeAABBox = _selectedNode.calcParentAABB();
//
//      worldAABB.rect.left = nodeAABBox.left;
//      worldAABB.rect.bottom = nodeAABBox.bottom;
//      worldAABB.rect.width = nodeAABBox.width;
//      worldAABB.rect.height = nodeAABBox.height;
//      
//      if (_selectedNode is Ranger.GroupingBehavior) {
//        Ranger.GroupingBehavior gb = _selectedNode as Ranger.GroupingBehavior;
//        gb.rippleDirty();
//      }
//
//      _prevPos.setFrom(layerP.v);
//      layerP.moveToPool();
//    }
//  }
  
//  @override
//  void onTouchsEnded(Ranger.MutableEvent event) {
//  }

//  @override
//  bool onTouchsMoved(Ranger.MutableEvent event) {
//    Ranger.Application app = Ranger.Application.instance; 
//    _showViewMouse(event.mouse.offset.x, event.mouse.offset.y);
//    
//    // Find the box node by Tag. Note you don't really want to do this
//    // on "moves" you really should cache the Tagged Node.
//    int nodeTage = int.parse(_nodeTagElement.value);
//
//    Ranger.Vector2P gP = app.drawContext.mapViewToNode(this, event.mouse.offset.x, event.mouse.offset.y);
//    _showNodePos(gP.v.x, gP.v.y);
//    gP.moveToPool();
//    
//    if (_isOverNode(event.mouse.offset.x, event.mouse.offset.y) != null) {
//      app.canvas.style.cursor = Ranger.CURSOR_STYLE.MOVE;
//    }
//    else {
//      app.canvas.style.cursor = Ranger.CURSOR_STYLE.DEFAULT;
//    }
//
////    Ranger.BaseNode redBox = getChildByTag(105);
////    if (redBox != null) {
////      Ranger.Vector2P wP = app.drawContext.mapViewToWorld(event.mouse.offset.x, event.mouse.offset.y);
////      Ranger.Vector2P nP = redBox.convertToNodeSpace(wP.v);
////      app.showLocalPos(nP.v.x, nP.v.y);
////      nP.moveToPool();
////      wP.moveToPool();
////    }
//
//    Ranger.Vector2P wP = app.drawContext.mapViewToWorld(event.mouse.offset.x, event.mouse.offset.y);
//    _showWorldPos(wP.v.x, wP.v.y);
//
//    Ranger.Vector2P dP = app.drawContext.mapViewToDesign(event.mouse.offset.x, event.mouse.offset.y);
//    _showDesignPos(dP.v.x, dP.v.y);
//    dP.moveToPool();
//
//    if (_selectedNode != null) {
//      Ranger.Vector2P nP;
//      nP = app.drawContext.mapViewToNode(_selectedNode, event.mouse.offset.x, event.mouse.offset.y);
//      // Not really required, but good for visually showing.
//      nP.v.setValues(nP.v.x * _selectedNode.scale.x, nP.v.y * _selectedNode.scale.y);
//      
//      _showLocalPos(nP.v.x, nP.v.y);
//      nP.moveToPool();
//    }
//
//    return Ranger.TouchDelegate.CLAIMED;
//  }

  @override
  bool onKeyDown(KeyboardEvent event) {
    //print("key onKeyDown ${event.keyEvent.keyCode}");

    switch (event.keyCode) {
      case 83://a
        // CCW
        _turnCCW = true;
        return true;
      case 65://s
        // CW
        _turnCW = true;
        return true;
      case 70://f
        _fireParticle = true;
        break;
      case 69://e
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyUp(KeyboardEvent event) {
    //print("key onKeyUp ${event.keyEvent.keyCode}");
    switch (event.keyCode) {
      case 83://a
        // CCW
        _turnCCW = false;
        return true;
      case 65://s
        // CW
        _turnCW = false;
        return true;
      case 70://f
        _fireParticle = false;
        break;
      case 69://e
        return true;
    }
    
    return false;
  }

  @override
  bool onKeyPress(KeyboardEvent event) {
    //print("key press ${event.keyEvent.keyCode}");
    
    switch (event.keyCode) {
      case 101://e
        ps.explodeByStyle(Ranger.ParticleActivation.OMNI_DIRECTIONAL);
        return true;
    }
    
    return false;
  }
 
  void _showViewMouse(int x, int y) {
    viewMouseElement.text = "(${x}, ${y})";
  }

  void _showDesignPos(double x, double y) {
    designPosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _showWorldPos(double x, double y) {
    worldPosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _showNodePos(double x, double y) {
    nodePosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _showLocalPos(double x, double y) {
    localPosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _zoomChanged() {
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

    Element zoomText = querySelector("#zoomValue");
    int value = int.parse(zoomSlider.value);
    double zValue = value / 100.0;
    
    zoomText.text = zValue.toStringAsFixed(2);
    
    Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
//    Ranger.BaseNode layer = sceneGB.getChildByTag(2525);
//    if (layer != null) {
//      layer.uniformScale = zValue;
//    }

    _zoomControl.uniformScale = zValue;
    
    Ranger.BaseNode grid = sceneGB.getChildByTag(123);
    if (grid != null) {
      grid.dirty = true;
    }

    Ranger.Application app = Ranger.Application.instance; 

    // We want the viewport to remain fixed relative to view-space.
    // Hence, if the Layer zooms in we want the viewport to do the
    // opposite.
    // Instead of mapping the viewPort Node into world-space we
    // map app.viewPortAABB to world-space.
    Ranger.DrawContext dc = app.drawContext;
    Ranger.MutableRectangle<double> worldRect = dc.mapViewRectToWorld(app.viewPortAABB);
    //print("worldRect: $worldRect");
    
    // and then for visuals we map the worldRect to the viewPort Node
    // for rendering. The viewPort Node is a centered square.
    Ranger.MutableRectangle<double> nodeRect = convertWorldRectToNode(worldRect);
    //print("nodeRect: $nodeRect");
    //viewPort.scaleTo(nodeRect.width, nodeRect.height);

    worldRect.moveToPool();
    nodeRect.moveToPool();

    app.viewPortWorldAABB.setWith(worldRect);
    
    //print("_zoomChanged: ${app.viewPortWorldAABB}");

    // Mark all Nodes dirty so that their boxes are updated as well.
    rippleDirty();
  }

  void _tweenParticleTest() {
    SquareParticleNode particlePrototypeVisual;
//    Ranger.UniversalParticle prototype;
    Ranger.TweenParticle prototype;

    Ranger.Color4<int> orangeTo = new Ranger.Color4<int>.withRGBA(255, 127, 0, 255);

    particlePrototypeVisual = new SquareParticleNode.initWithColorAndScale(Ranger.Color4IBlue, 1.0);
    particlePrototypeVisual.tag = 8;
    particlePrototypeVisual.visible = false;
    particlePrototypeVisual.uniformScale = 10.0;
    
    prototype = new Ranger.TweenParticle.withNode(particlePrototypeVisual);
    prototype.fromColor.setWith(orangeTo);
    prototype.toColor.setWith(Ranger.Color4IBlue);
    prototype.fromRotation = 0.0;
    prototype.toRotation = 45.0;
    prototype.fromScale = 5.0;
    prototype.toScale = 50.0;
    
//    prototype = new Ranger.UniversalParticle.withNode(particlePrototypeVisual);
//    prototype.initWithColor(orangeTo, Ranger.Color4IBlue);
//    prototype.initWithRotation(0.0, 45.0, 10.0, Ranger.ParticleRotationBehavior.CONSTANT);
//    prototype.initWithScale(5.0, 50.0);
    
    ps.addByPrototype(_zoomControl, prototype, maxParticles);
    prototype.moveToPool();
  }


 
}