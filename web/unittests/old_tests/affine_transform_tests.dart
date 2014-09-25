import 'package:ranger/ranger.dart' as Ranger;

import 'scenes_and_nodes.dart';
import 'package:vector_math/vector_math.dart';

Vector2 worldPoint = new Vector2(150.0, 100.0);
Ranger.Point anchorPoint = new Ranger.Point(100.0, 100.0);
Ranger.Point transformedPoint = new Ranger.Point.zero();
Vector2 invsersePoint = new Vector2(0.0, 0.0);

Ranger.Point baseSystem = new Ranger.Point(100.0, 100.0);
Ranger.Point childToBase = new Ranger.Point(100.0, 100.0);
Ranger.Point childToChild = new Ranger.Point(100.0, 100.0);

Ranger.Point baseSystemV = new Ranger.Point.zero();
Ranger.Point childToBaseV = new Ranger.Point.zero();
Ranger.Point childToChildV = new Ranger.Point.zero();

Vector2 aPoint = new Vector2.zero();

void main(Ranger.Application engine) {
  Ranger.Scene scene = _simpleHeiarchyStyle4();
//      Ranger.Scene scene = _matrixParentToChildOrder();
  
  if (scene != null) {
    engine.sceneManager.pushScene(scene);
    
    engine.gameConfigured();
    print("------------ engine started ------------");
  }
}

Ranger.Scene _matrixParentToChildOrder() {
  // Concatenate matrices
  // ----------------------------------------------------------
  //                     [baseSystemT]
  //                               |
  //                               v
  //             [childToBaseT] x [t] 
  //                               |
  //                               v
  //            [childToChildT] x [t]
  //
  // equals
  // Pre multiply
  // [childToChildT] x [childToBaseT] x [baseSystemT]
  //
  // Post multiply
  // [baseSystemT] x [childToBaseT] x [childToChildT]
  // ----------------------------------------------------------

  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform t = new Ranger.AffineTransform.Identity();

  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);
  
  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  childToChildT.rotate(Ranger.degreesToRadians(45.0));
  print("childToChildT");
  print(childToChildT);

  at.setWithAT(baseSystemT);
  Ranger.affineTransformMultiplyTo(childToBaseT, at);
  print("result:");
  print(at);

  Ranger.affineTransformMultiplyTo(childToChildT, at);
  print("result:");
  print(at);

  at.invert();
  print("at inv:");
  print(at);
  
  print("---------------------------------------------------");
  // Method 2
  t.setWithAT(baseSystemT);
  print("t:");
  print(t);
  
  Ranger.AffineTransform pT = t;
  t = Ranger.affineTransformMultiply(childToBaseT, t);
  pT.moveToPool();
  print("t:");
  print(t);
  pT = t;

  pT = t;
  t = Ranger.affineTransformMultiply(childToChildT, t);
  pT.moveToPool();
  print("t:");
  print(t);
  pT = t;
  
  
  return null;
}

Ranger.Scene _matrixMultiplicationCommunative() {
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();

  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);
  
  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  childToChildT.rotate(Ranger.degreesToRadians(45.0));
  print("childToChildT");
  print(childToChildT);

  at.setWithAT(baseSystemT);
  /*
   * result:
|0.71, 0.71, 200.00|
|-0.71, 0.71, 200.00|
   */
  Ranger.affineTransformMultiplyTo(at, childToBaseT);
  
  /*
   * result:
|0.71, 0.71, 100.00|
|-0.71, 0.71, 100.00|
   */
//  Ranger.affineTransformMultiplyTo(childToBaseT, at);
  print("result:");
  print(childToBaseT);

  return null;
}

//--------------------------------------------------------------
// Note: Style4 is correct for CW rotations.
//--------------------------------------------------------------
Ranger.Scene _simpleHeiarchyStyle4() {
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform t = new Ranger.AffineTransform.Identity();
  Ranger.Vector2P tp;
  
  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  //baseSystemT.rotate(Ranger.degressToRadians(45.0));  // CW
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);

  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  childToChildT.rotate(Ranger.degreesToRadians(45.0));
  print("childToChildT");
  print(childToChildT);

  // Concatenate matrices
  // ----------------------------------------------------------
  //                     [childToChildT]
  //                               |
  //                               v
  //             [childToBaseT] x [t] 
  //                               |
  //                               v
  //              [baseSystemT] x [t]
  //
  // equals
  // [childToChildT] x [childToBaseT] x [baseSystemT]
  // ----------------------------------------------------------
  //t = Ranger.affineTransformMultiply(baseSystemT, at);
  // or
  t.setWithAT(baseSystemT);
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  baseSystemV.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  
  Ranger.AffineTransform pT = t;  
  t = Ranger.affineTransformMultiply(childToBaseT, t);
  pT.moveToPool();
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  childToBaseV.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  pT = t;
  
  t = Ranger.affineTransformMultiply(childToChildT, t);
  pT.moveToPool();
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  childToChildV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  // Now apply composite transform
  aPoint.setValues(50.0, 0.0);
  // map from local to world.
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  print("world tp: ${tp.v}");   
  transformedPoint.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  t.invert();
  print("t inv:\n$t");   

  aPoint.setValues(200.0, 393.0);
  // map from world to local.
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  print("local tp: ${tp.v}");
  invsersePoint.setValues(tp.v.x, tp.v.y);
  tp.moveToPool();

  t.moveToPool();

  Ranger.Scene scene = _buildSimpleHeiarchyScene();

  return scene;
}
Ranger.Scene _simpleHeiarchyStyle3() {
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform inv = new Ranger.AffineTransform.Identity();
  Ranger.Vector2P tp;
  
  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);

  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  childToChildT.rotate(Ranger.degreesToRadians(45.0));
  print("childToChildT");
  print(childToChildT);

  // ----------------------------------------------------------
  // Pre-multiply style
  //                [childToChildT] x [at]
  //                                    |
  //                                    v
  //                 [childToBaseT] x [at]
  //                                    |
  //                                    v
  //                  [baseSystemT] x [at]
  //
  // equals
  //
  // [baseSystemT] x [childToBaseT] x [childToChildT]
  // ----------------------------------------------------------
  Ranger.affineTransformMultiplyTo(childToChildT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  childToChildV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  Ranger.affineTransformMultiplyTo(childToBaseT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  childToBaseV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  Ranger.affineTransformMultiplyTo(baseSystemT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  baseSystemV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  aPoint.setValues(50.0, 0.0);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  print("tp: $tp.v");
  transformedPoint.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  
  inv.setWithAT(at);
  inv.invert();
  print("inv at:");
  print(inv);

  aPoint.setValues(50.0, 0.0);
  // map from local to world.
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  print("world tp: $tp.v");   
  transformedPoint.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  // world to local
  invsersePoint.setValues(390.0, 200.0);
  //invsersePoint.set(300.0, 300.0);
  tp = Ranger.PointApplyAffineTransform(invsersePoint, inv);
  print("local: $tp");
  tp.moveToPool();

  Ranger.Scene scene = _buildSimpleHeiarchyScene();

  return scene;
}

// Note: Style3. not quite predictable
Ranger.Scene _simpleHeiarchyStyle1() {
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform inv = new Ranger.AffineTransform.Identity();
  Ranger.Vector2P tp;
  
  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);

  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  print("childToChildT");
  print(childToChildT);

  // ----------------------------------------------------------
  // Pre-multiply style
  //                        [childToChildT]
  //                                    |
  //                                    v
  //                 [childToBaseT] x [at]
  //                                    |
  //                                    v
  //                  [baseSystemT] x [at]
  //
  // equals
  //
  // [baseSystemT] x [childToBaseT] x [childToChildT]
  // ----------------------------------------------------------
  Ranger.affineTransformMultiplyTo(childToChildT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  childToChildV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  Ranger.affineTransformMultiplyTo(childToBaseT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  childToBaseV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  Ranger.affineTransformMultiplyTo(baseSystemT, at);
  print("at:");
  print(at);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  baseSystemV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  aPoint.setValues(50.0, 0.0);
  tp = Ranger.PointApplyAffineTransform(aPoint, at);
  print("tp: ${tp.v}");
  transformedPoint.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  
  inv.setWithAT(at);
  Ranger.AffineTransform inv2 = Ranger.AffineTransformInvert(at);
  inv.invert();
  print("inv at:");
  print(inv);
  print("inv2 at:");
  print(inv2);

  Ranger.AffineTransform I = Ranger.affineTransformMultiply(at, inv);
  print("I:");
  print(I);
  
  // world to local
  invsersePoint.setValues(373.0, 373.0);
  //invsersePoint.set(300.0, 300.0);
  tp = Ranger.PointApplyAffineTransform(invsersePoint, inv);
  print("inv: ${tp.v}");
  tp.moveToPool();
  
  Ranger.Scene scene = _buildSimpleHeiarchyScene();

  return scene;
}

//--------------------------------------------------------------
// Note: Style2 is verified to work correctly. for Y upwards
//--------------------------------------------------------------
Ranger.Scene _simpleHeiarchyStyle2() {
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  Ranger.AffineTransform t = new Ranger.AffineTransform.Identity();
  Ranger.Vector2P tp;
  
  Ranger.AffineTransform baseSystemT = new Ranger.AffineTransform.Identity();
  baseSystemT.translate(baseSystem.x, baseSystem.y);
  print("baseSystemT");
  print(baseSystemT);

  Ranger.AffineTransform childToBaseT = new Ranger.AffineTransform.Identity();
  childToBaseT.translate(childToBase.x, childToBase.y);
  childToBaseT.rotate(Ranger.degreesToRadians(45.0));
  print("childToBaseT");
  print(childToBaseT);

  Ranger.AffineTransform childToChildT = new Ranger.AffineTransform.Identity();
  childToChildT.translate(childToChild.x, childToChild.y);
  childToChildT.rotate(Ranger.degreesToRadians(45.0));
  print("childToChildT");
  print(childToChildT);

  // Concatenate matrices
  // This was prior to fixing affine rotation for Y axis downward.
  // ----------------------------------------------------------
  //                     [baseSystemT]
  //                               |
  //                               v
  //             [childToBaseT] x [t] 
  //                               |
  //                               v
  //            [childToChildT] x [t]
  //
  // equals
  // [childToChildT] x [childToBaseT] x [baseSystemT]
  // ----------------------------------------------------------
  //t = Ranger.affineTransformMultiply(baseSystemT, at);
  // or
  t.setWithAT(baseSystemT);
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  baseSystemV.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  
  Ranger.AffineTransform pT = t;  
  t = Ranger.affineTransformMultiply(childToBaseT, t);
  pT.moveToPool();
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  childToBaseV.set(tp.v.x, tp.v.y);
  tp.moveToPool();
  pT = t;
  
  t = Ranger.affineTransformMultiply(childToChildT, t);
  pT.moveToPool();
  print("at:");
  print(t);
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  childToChildV.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  // Or
  // ----------------------------------------------------------
  // [baseSystemT] x [at]
  //                   |
  //                   v
  //                 [at] x [childToBaseT]
  //                                    |
  //                                    v
  //                        [childToBaseT] x [childToChildT]
  //
  // equals
  // [baseSystemT] x [childToBaseT] x [childToChildT]
  // ----------------------------------------------------------
//  Ranger.affineTransformMultiplyTo(baseSystemT, at);
//  print("at:");
//  print(at);
//  tp = Ranger.PointApplyAffineTransform(aPoint, at);
//  baseSystemV.set(tp.x, tp.y);
//  tp.moveToPool();
//
//  Ranger.affineTransformMultiplyTo(at, childToBaseT);
//  print("childToBaseT:");
//  print(childToBaseT);
//  tp = Ranger.PointApplyAffineTransform(aPoint, childToBaseT);
//  childToBaseV.set(tp.x, tp.y);
//  tp.moveToPool();
//
//  Ranger.affineTransformMultiplyTo(childToBaseT, childToChildT);
//  print("childToChildT:");
//  print(childToChildT);
//  tp = Ranger.PointApplyAffineTransform(aPoint, childToChildT);
//  childToChildV.set(tp.x, tp.y);
//  tp.moveToPool();
  

  // Now apply composite transform
  aPoint.setValues(50.0, 0.0);
  // map from local to world.
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  print("world tp: ${tp.v}");   
  transformedPoint.set(tp.v.x, tp.v.y);
  tp.moveToPool();

  t.invert();
  print("t inv:\n$t");   

  aPoint.setValues(200.0, 393.0);
  // map from world to local.
  tp = Ranger.PointApplyAffineTransform(aPoint, t);
  print("local tp: ${tp.v}");
  invsersePoint.setValues(tp.v.x, tp.v.y);
  tp.moveToPool();

  t.moveToPool();

  Ranger.Scene scene = _buildSimpleHeiarchyScene();

  return scene;
}

Ranger.Scene _buildSimpleHeiarchyScene() {
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  Ranger.BackgroundLayer layer = new Ranger.BackgroundLayer();
  layer.color = Ranger.color4IFromHex("#dddddd");
  scene.addChild(layer, 0, 42);

  //---------------------------------------------------------------
  // Basic grid
  //---------------------------------------------------------------
  Ranger.Size<double> size = Ranger.Application.instance.designSize;
  GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
  layer.addChild(grid, 0, 99);
  
  NodePoint baseNode = new NodePoint();
  baseNode.setPosition(baseSystemV.x, baseSystemV.y);
  baseNode.color = Ranger.Color3IRed;
  layer.addChild(baseNode, 100, 300);

  NodePoint childToBaseNode = new NodePoint();
  childToBaseNode.setPosition(childToBaseV.x, childToBaseV.y);
  childToBaseNode.color = Ranger.Color3IGreen;
  layer.addChild(childToBaseNode, 101, 301);

  NodePoint childToChildNode = new NodePoint();
  childToChildNode.setPosition(childToChildV.x, childToChildV.y);
  childToChildNode.color = Ranger.Color3IBlue;
  layer.addChild(childToChildNode, 102, 302);

  NodePoint transNode = new NodePoint();
  transNode.setPosition(transformedPoint.x, transformedPoint.y);
  transNode.color = Ranger.Color3IOrange;
  layer.addChild(transNode, 103, 303);
  
  NodePoint invNode = new NodePoint();
  invNode.setPosition(invsersePoint.x, invsersePoint.y);
  invNode.color = Ranger.Color3IBlack;
  layer.addChild(invNode, 104, 304);
  
  return scene;
}

// Pre multiply
Ranger.Scene _simpleRotateAboutPoint() {
  //---------------------------------------------------------------
  // AffineTransform replication
  //---------------------------------------------------------------
  Ranger.AffineTransform at = new Ranger.AffineTransform.Identity();
  
  Ranger.AffineTransform rot = new Ranger.AffineTransform.Identity();
  rot.rotate(45.0 * Ranger.PIOver180); // CW
  print("rot");
  print(rot);
  
  Ranger.AffineTransform translate = new Ranger.AffineTransform.Identity();
  translate.translate(anchorPoint.x, anchorPoint.y);
  print("translate");
  print(translate);

  // We want to rotate world point around anchor point.
  // -translate
  // rot
  // translate
  translate.invert();
  Ranger.affineTransformMultiplyTo(translate, at);
  print("at:");
  print(at);
  Ranger.affineTransformMultiplyTo(rot, at);
  print("at:");
  print(at);
  translate.invert();
  Ranger.affineTransformMultiplyTo(translate, at);
  print("at:");
  print(at);

  Ranger.Vector2P p = Ranger.PointApplyAffineTransform(worldPoint, at);
  print("p: ${p.v}");
  transformedPoint.set(p.v.x, p.v.y);
  p.moveToPool();
  
  Ranger.Scene scene = _buildSimpleScene();

  return scene;
}

Ranger.Scene _buildSimpleScene() {
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  Ranger.BackgroundLayer layer = new Ranger.BackgroundLayer();
  layer.color = Ranger.color4IFromHex("#dddddd");
  scene.addChild(layer, 0, 42);

  //---------------------------------------------------------------
  // Basic grid
  //---------------------------------------------------------------
  Ranger.Size<double> size = Ranger.Application.instance.designSize;
  GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
  layer.addChild(grid, 0, 99);
  
  NodePoint anchorNode = new NodePoint();
  anchorNode.setPosition(anchorPoint.x, anchorPoint.y);
  anchorNode.color = Ranger.Color3IBlue;
  layer.addChild(anchorNode, 100, 300);

  NodePoint worldNode = new NodePoint();
  worldNode.setPosition(worldPoint.x, worldPoint.y);
  worldNode.color = Ranger.Color3IOrange;
  layer.addChild(worldNode, 101, 301);

  NodePoint transNode = new NodePoint();
  transNode.setPosition(transformedPoint.x, transformedPoint.y);
  transNode.color = Ranger.Color3IGreen;
  layer.addChild(transNode, 102, 302);

  return scene;
}

Ranger.Scene _buildScene() {
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  Ranger.BackgroundLayer layer = new Ranger.BackgroundLayer();
  layer.color = Ranger.color4IFromHex("#dddddd");
  scene.addChild(layer, 0, 42);

  //---------------------------------------------------------------
  // Basic grid
  //---------------------------------------------------------------
  Ranger.Size<double> size = Ranger.Application.instance.designSize;
  GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
  layer.addChild(grid, 0, 99);

  //---------------------------------------------------------------
  // A box.
  //---------------------------------------------------------------
  SquareNode boxBig = new SquareNode();
  boxBig.solid = true;
  boxBig.outlined = true;
  boxBig.size = 100.0;
  boxBig.center();
  boxBig.setPosition(150.0, 150.0);
//  boxBig.scaleX = 2.0;
//  boxBig.scaleY = 2.0;
  //boxBig.rotationByDegrees = 45.0;  // CW
  layer.addChild(boxBig, 10, 101);

  SquareNode boxBigChild = new SquareNode();
  boxBigChild.solid = true;
  boxBigChild.outlined = true;
  boxBigChild.size = 100.0;
  boxBigChild.center();
  boxBigChild.setPosition(100.0, 100.0);  // relative to parent
//  boxBigChild.scaleX = 2.0;
//  boxBigChild.scaleY = 2.0;
//  boxBigChild.rotationByDegrees = 45.0;  // CW
  boxBig.addChild(boxBigChild, 11, 201);

  SquareNode boxBigSubChild = new SquareNode();
  boxBigSubChild.solid = true;
  boxBigSubChild.outlined = true;
  boxBigSubChild.size = 100.0;
  boxBigSubChild.center();
  boxBigSubChild.setPosition(100.0, 100.0);  // relative to parent
//  boxBigSubChild.scaleX = 2.0;
//  boxBigSubChild.scaleY = 2.0;
  boxBigSubChild.rotationByDegrees = 45.0;  // CW
  boxBigChild.addChild(boxBigSubChild, 11, 202);

  //---------------------------------------------------------------
  // A point "inside" of the box for reference and comparison.
  //---------------------------------------------------------------
  NodePoint boxPointNode = new NodePoint();
  boxPointNode.setPosition(50.0, 0.0);
  boxPointNode.color = Ranger.Color3IBlue;
  boxBigSubChild.addChild(boxPointNode, 100, 102);
  
  Ranger.Vector2P wp1 = boxBigSubChild.convertWorldToNodeSpace(worldPoint);
  print("node space: $wp1");
  wp1.moveToPool();

  return scene;
}
