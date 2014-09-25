library spaceLibtests;

import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;

import 'scenes_and_nodes.dart';

InputElement _nodeTagElement;
Element viewMouseElement;
Element nodePosElement;
Element localPosElement;

Ranger.Scene spaceMappingTest(Ranger.Application engine) {
  _nodeTagElement = querySelector("#nodeTag");

  Ranger.Scene scene = _mapFromViewToWorld();
  
  return scene;
}

Ranger.Scene _mapFromViewToWorld() {
  // Map a view-space coord to world-space.
  // View-space = mouse-space = display-space.
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 2001;

  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ddffdd"));
  scene.addChild(layer, 0, 2001);

  //---------------------------------------------------------------
  // Basic grid
  //---------------------------------------------------------------
  Ranger.Size<double> size = Ranger.Application.instance.designSize;
  GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
  layer.addChild(grid, 0, 99);

  //---------------------------------------------------------------
  // A box.
  //---------------------------------------------------------------
  SquareNode baseSystemN = new SquareNode();
  baseSystemN.solid = true;
  baseSystemN.outlined = true;
  baseSystemN.size = 100.0;
  baseSystemN.center();
  baseSystemN.setPosition(100.0, 100.0);
//  baseSystemT.scaleX = 2.0;
//  baseSystemT.scaleY = 2.0;
//  baseSystemN.rotationByDegrees = 45.0;  // CW
  layer.addChild(baseSystemN, 10, 101);

  SquareNode childToBaseN = new SquareNode();
  childToBaseN.solid = true;
  childToBaseN.outlined = true;
  childToBaseN.size = 100.0;
  childToBaseN.center();
  childToBaseN.setPosition(200.0, 200.0);  // relative to parent
  childToBaseN.uniformScale = 1.5;
  //childToBaseN.rotationByDegrees = -45.0;  // CW
  baseSystemN.addChild(childToBaseN, 11, 201);

  SquareNode childToChildN = new SquareNode();
  childToChildN.solid = true;
  childToChildN.outlined = true;
  childToChildN.size = 100.0;
  childToChildN.center();
  childToChildN.setPosition(100.0, 100.0);  // relative to parent
//  childToChildN.scaleX = 2.0;
//  childToChildN.scaleY = 2.0;
  childToChildN.rotationByDegrees = 45.0;  // CW
  childToBaseN.addChild(childToChildN, 12, 202);

  SquareNode child2ToChildN = new SquareNode();
  child2ToChildN.solid = true;
  child2ToChildN.outlined = true;
  child2ToChildN.size = 100.0;
  child2ToChildN.center();
  child2ToChildN.setPosition(100.0, 100.0);  // relative to parent
//  childToChildN.scaleX = 2.0;
//  childToChildN.scaleY = 2.0;
  child2ToChildN.rotationByDegrees = -45.0;  // CW
  childToChildN.addChild(child2ToChildN, 12, 203);

  //---------------------------------------------------------------
  // A point "inside" of the box for reference and comparison.
  //---------------------------------------------------------------
  NodePoint boxPointNode = new NodePoint();
  boxPointNode.setPosition(50.0, 0.0);
  boxPointNode.color = Ranger.Color3IBlue;
  child2ToChildN.addChild(boxPointNode, 100, 102);

  // The test is actually embedded in BackgroundLayer.
  
  //---------------------------------------------------------------
  // AffineTransform replication
  // [childToChildT] x [childToBaseT] x [baseSystemT]
  //---------------------------------------------------------------
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform t;
  
  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  //subChild.scale(2.0, 2.0);
  baseSystemT.translate(100.0, 100.0);
  //baseSystemT.rotate(Ranger.degressToRadians(45.0)); //CW
  //print("baseSystemT");
  //print(baseSystemT);
  Ranger.affineTransformMultiplyTo(baseSystemT, at);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(100.0, 100.0);
  //childToBaseT.scale(2.0, 2.0);
  //childToBaseT.rotate(45.0 * Ranger.PIOver180);
  //print("childToBaseT");
  //print(childToBaseT);
  Ranger.affineTransformMultiplyTo(childToBaseT, at);
  //print("at:");
  //print(at);
  
  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(100.0, 100.0);
  //childToChildT.rotate(45.0 * Ranger.PIOver180);
  //print("childToChildT");
  //print(childToChildT);
  Ranger.affineTransformMultiplyTo(childToChildT, at);
  //print("at:");
  //print(at);
  
  at.invert();
  //print("at inverted");
  //print(at);
  
//  Ranger.Point worldPoint = new Ranger.Point(250.0, 450.0 + 12.5);
  Ranger.Vector2P worldPoint = new Ranger.Vector2P.withCoords(250.0, 395.0);
  //Ranger.Point worldPoint = new Ranger.Point(250.0, 395.0);

  Ranger.Vector2P p = Ranger.PointApplyAffineTransform(worldPoint.v, at);
  //print("p: $p");
  p.moveToPool();
  
  Ranger.Vector2P wp1 = childToChildN.convertWorldToNodeSpace(worldPoint.v);
  //print("node space: $wp1");
  wp1.moveToPool();
  worldPoint.moveToPool();
  
  return scene;
}

class TestLayer extends Ranger.BackgroundLayer {
  
  TestLayer() {
    viewMouseElement = querySelector("#viewMouse");
    nodePosElement = querySelector("#nodePos");
    localPosElement = querySelector("#localPos");

  }
  
  factory TestLayer.withColor([Ranger.Color4<int> color, int width, int height]) {
    TestLayer layer = new TestLayer();
    layer.init(width, height);
    layer.color = color;
    return layer;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    //---------------------------------------------------------------
    // A box.
    //---------------------------------------------------------------
    SquareNode baseSystemN = new SquareNode();
    baseSystemN.solid = true;
    baseSystemN.outlined = true;
    baseSystemN.size = 100.0;
    baseSystemN.center();
    baseSystemN.setPosition(100.0, 100.0);
    addChild(baseSystemN, 10, 101);

    //---------------------------------------------------------------
    // A point "inside" of the box for reference and comparison.
    //---------------------------------------------------------------
    NodePoint boxPointNode = new NodePoint();
    boxPointNode.setPosition(50.0, 0.0);
    boxPointNode.color = Ranger.Color3IBlue;
    baseSystemN.addChild(boxPointNode, 100, 102);

    NodePoint boxPoint2Node = new NodePoint();
    boxPoint2Node.setPosition(50.0, 0.0);
    boxPoint2Node.color = Ranger.Color3IBlue;
    baseSystemN.addChild(boxPoint2Node, 101, 202);

  }
  
//  @override
//  bool onTouchsMoved(Ranger.MutableEvent event) {
//    Ranger.Application app = Ranger.Application.instance; 
//    _showViewMouse(event.mouse.offset.x, event.mouse.offset.y);
//    
//    Ranger.Vector2P wP = app.drawContext.mapViewToWorld(event.mouse.offset.x, event.mouse.offset.y);
//    //wP.set(350.0, 350.0);
//    _showNodePos(wP.v.x, wP.v.y);
//    wP.moveToPool();
//    
//    // Find the box node by Tag. Note you don't really want to do this
//    // on "moves" you really should cache the Tagged Node.
//    int nodeTage = int.parse(_nodeTagElement.value);
//
//    Ranger.BaseNode box = getChildByTag(nodeTage);
//    
//    if (box != null) {
//      Ranger.Vector2P nP = box.convertWorldToNodeSpace(wP.v);
//      _showLocalPos(nP.v.x, nP.v.y);
//      nP.moveToPool();
//    }
//    
//    return Ranger.TouchDelegate.CLAIMED;
//  }

  void _showViewMouse(int x, int y) {
    viewMouseElement.text = "(${x}, ${y})";
  }

  void _showNodePos(double x, double y) {
    nodePosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

  void _showLocalPos(double x, double y) {
    localPosElement.text = "(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
  }

}