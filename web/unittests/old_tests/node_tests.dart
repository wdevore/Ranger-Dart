import 'package:ranger/ranger.dart' as Ranger;

import 'scenes_and_nodes.dart';

void nodeTests(Ranger.Application engine) {
  Ranger.Scene scene = _scheduleUpdateTest();
  
  engine.sceneManager.pushScene(scene);
  
  engine.gameConfigured();
  print("------------ engine started ------------");
}

Ranger.Scene _layerTest() {
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  // TODO unittest: Test keyboard and color cascading ...
  Ranger.BackgroundLayer layer = new Ranger.BackgroundLayer();
  // Note: we don't have to return the object returned by color4IFromHex
  // back to the pool. It is just like any other object such that
  // then when it goes out of scope it is collected. If for some reason
  // I didn't want it collected--by the GC--then I would capture the
  // object first and move it to the pool when done.
  // But in this case I need it just to set the color.
  layer.color = Ranger.color4IFromHex("#dddddd");
  //layer.opacity = 128;
  scene.addChild(layer, 0, 333);
  
  NodePoint point = new NodePoint();
  point.setPosition(150.0, 150.0);
  point.scaleX = 3.0;
  point.scaleY = 3.0;
//  point.uniformScale = 3.0;
  layer.addChild(point, 100, 33);

  return scene;
}

Ranger.Scene _scheduleUpdateTest() {
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  //Ranger.BackgroundLayer lc = new Ranger.BackgroundLayer();
  //scene.addChild(lc, -10, 200);
  
  //Ranger.Color3<double> c = Ranger.color3DFromHex("#aabbcc");
  //String c = Ranger.rgbaDToHex(0.1, 0.2, 0.3, 0.4);
  
  NodePoint point = new NodePoint();
  point.setPosition(150.0, 150.0);
    point.scaleX = 3.0;
    point.scaleY = 3.0;
//  point.uniformScale = 3.0;
  scene.addChild(point, 100, 33);

  NodePoint point2 = new NodePoint();
  point2.setPosition(0.0, 0.0);
  point2.scaleX = 5.0;
  point2.scaleY = 5.0;
//  point2.uniformScale = 5.0;
  scene.addChild(point2, 101, 34);

  NodePoint point3 = new NodePoint();
  point3.setPosition(600.0, 338.0);
    point3.scaleX = 5.0;
    point3.scaleY = 5.0;
//  point3.uniformScale = 5.0;
  scene.addChild(point3, 102, 35);

//  NodePoint point4 = new NodePoint();
//  point4.setPosition(400.0, 300.0);
//  point4.uniformScale = 5.0;
//  scene.addChild(point4, 103, 35);
//
//  NodePoint point5 = new NodePoint();
//  point5.setPosition(1280.0, 800.0);
//  point5.uniformScale = 5.0;
//  scene.addChild(point5, 104, 35);

  SquareNode rect = new SquareNode();
  rect.solid = true;
  rect.outlined = true;
  rect.size = 50.0;
  rect.center();
  rect.setPosition(150.0, 150.0);
  rect.scheduleUpdate();
  //rect.rotationByDegrees = 45.0;
  scene.addChild(rect, -1, 101);

  SquareNode rect2 = new SquareNode();
  rect2.solid = true;
  rect2.outlined = true;
  rect2.size = 50.0;
  rect2.setPosition(170.0, 170.0);
  rect2.scheduleUpdate();
  scene.addChild(rect2, -2, 102);

  NodeCenteredBox box = new NodeCenteredBox();
  box.setPosition(250.0, 150.0);
  box.size = 50.0;
  scene.addChild(box, 0, 99);

  return scene;
}

Ranger.Scene _zOrderTest() {
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 1;

  //Ranger.Color3<double> c = Ranger.color3DFromHex("#aabbcc");
  //String c = Ranger.rgbaDToHex(0.1, 0.2, 0.3, 0.4);
  
  NodePoint point = new NodePoint();
  point.setPosition(150.0, 150.0);
  point.scaleX = 5.0;
  point.scaleY = 5.0;
//point.uniformScale = 3.0;
  scene.addChild(point, 100, 33);

  SquareNode rect = new SquareNode();
  rect.solid = true;
  rect.outlined = true;
  rect.size = 50.0;
  rect.center();
  rect.setPosition(150.0, 150.0);
  //rect.rotationByDegrees = 45.0;
  scene.addChild(rect, -1, 101);

  SquareNode rect2 = new SquareNode();
  rect2.solid = true;
  rect2.outlined = true;
  rect2.size = 50.0;
  rect2.center();
  rect2.setPosition(170.0, 170.0);
  //rect.rotationByDegrees = 45.0;
  scene.addChild(rect2, -2, 102);

  NodeCenteredBox box = new NodeCenteredBox();
  box.setPosition(250.0, 150.0);
  box.size = 50.0;
  scene.addChild(box, 0, 99);

  return scene;
}

Ranger.Scene _basicTests() {
  BasicScene scene1 = new BasicScene.withPrimary(null);
  scene1.tag = 1;
  //scene1.rotationByDegrees = 20.0;
  //scene1.setPosition(50.0, 50.0);
  //scene1.scheduleUpdate();
  
  // Non pooled
  AnchorNode anchor = new AnchorNode();
  anchor.uniformScale = 0.5;
  anchor.setPosition(100.0, 100.0);
  anchor.scheduleUpdate();
  
  NodeCenteredBox box = new NodeCenteredBox();
  box.setPosition(150.0, 150.0);
  box.uniformScale = 2.0;
  box.size = 50.0;
  //box.rotationByDegrees = 45.0;
  //box.skewX = 45.0;
  anchor.addChild(box, 0, 99);

  NodePoint point = new NodePoint();
  point.setPosition(10.0, 10.0);
  //point.scale = new Vector2(5.0, 5.0);
  box.addChild(point, 0, 33);

  scene1.addChild(anchor, 0, 11);
  
//      Ranger.NodeBox box2 = new Ranger.NodeBox();
//      box2.setPosition(250.0, 250.0);
//      box2.size = 50.0;
//      //box.rotationByDegrees = 45.0;
//      scene1.addChild(box2, 0, 100);

//      Ranger.BasicScene scene2 = new Ranger.BasicScene();
//      scene2.scheduleUpdate();
//      scene2.rotationByDegrees = 15.0;
  //scene2.setPosition(50.0, 50.0);
//      scene2.tag = 2;
//      Ranger.NodeLine line = new Ranger.NodeLine(0.0, 0.0, 25.0, 25.0);
//      line.setPosition(200.0, 200.0);
  //line.rotationByDegrees = -90.0;
//      scene2.addChild(line, 0, 0);
  
//      Scene1 scene3 = new Scene1();
//      scene3.tag = 3;
  
//      Scene1 scene4 = new Scene1();
//      scene4.tag = 4;
//      Scene1 scene5 = new Scene1();
//      scene5.tag = 5;

  return scene1;
}