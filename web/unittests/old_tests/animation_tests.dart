library aniLibtests;

import 'dart:html';
import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as Tween;

import 'scenes_and_nodes.dart';

SelectElement _animationsElement;
InputElement _applyAnimationElement;
InputElement angleSlider;

Ranger.Scene animationTests(Ranger.Application app) {
  _animationsElement = querySelector("#animations");
  _animationsElement.onChange.listen(
      (Event event) => _setupAnimation()
  );

  _applyAnimationElement = querySelector("#applyAnimation");
  _applyAnimationElement.onClick.listen(
      (Event event) => _applyAnimation()
  );

  angleSlider = querySelector("#angleSlider");
  angleSlider.onChange.listen((e) => _angleChanged(e));

  Ranger.Scene scene = _buildScene();
  
  return scene;
}

void _applyAnimation() {
  int test = int.parse(_animationsElement.value);
  Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
  Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
  Ranger.Application app = Ranger.Application.instance;
  
  Ranger.BaseNode node;
  print("ani test: $test");
  
  switch (test) {
    case 1:
      node = sceneGB.getChildByTag(102);
      app.animations.blink(node, 0.2, 0.05);
      break;
    case 3: // fade in
      node = sceneGB.getChildByTag(309);
      if (node is Ranger.Color4Mixin) {
        Ranger.Color4Mixin cb = node as Ranger.Color4Mixin;
        cb.opacity = 0;
      }
      app.animations.fadeIn(node, 2.0, Tween.Linear.INOUT);
      break;
    case 130: // fade out
      node = sceneGB.getChildByTag(309);
      if (node is Ranger.Color4Mixin) {
        Ranger.Color4Mixin cb = node as Ranger.Color4Mixin;
        cb.opacity = 255;
      }
      app.animations.fadeOut(node, 2.0, Tween.Linear.INOUT);
      break;
    case 4: // fade to 50%
      node = sceneGB.getChildByTag(309);
      if (node is Ranger.Color4Mixin) {
        Ranger.Color4Mixin cb = node as Ranger.Color4Mixin;
        cb.opacity = 255;
      }
      app.animations.fadeTo(node, 2.0, 128.0, Tween.Linear.INOUT);
      break;
    case 5:
      node = sceneGB.getChildByTag(101);
      app.animations.moveBy(node, 2.0, 25.0, 25.0, Tween.Cubic.OUT);
      break;
    case 6:
      node = sceneGB.getChildByTag(101);
      app.animations.moveTo(node, 2.0, 300.0, 300.0, Tween.Cubic.OUT);
      break;
    case 7:
      node = sceneGB.getChildByTag(101);
      app.animations.rotateTo(node, 2.0, 45.0, Tween.Cubic.OUT);
      break;
    case 8:
      node = sceneGB.getChildByTag(101);
      app.animations.rotateBy(node, 2.0, 10.0, Tween.Cubic.OUT);
      break;
    case 9:
      node = sceneGB.getChildByTag(101);
      app.animations.scaleTo(node, 2.0, 2.0, 2.0, Tween.Cubic.OUT);
      break;
    case 10:
      node = sceneGB.getChildByTag(101);
      app.animations.scaleBy(node, 2.0, 1.5, 1.5, Tween.Cubic.OUT);
      break;
    case 11:
      node = sceneGB.getChildByTag(309);
      app.animations.tintTo(node, 2.0, 255.0, 0.0, 0.0, Tween.Cubic.OUT);
      break;
    case 12:
      node = sceneGB.getChildByTag(309);
      app.animations.tintTo(node, 2.0, 0.0, 255.0, 0.0, Tween.Cubic.OUT);
      break;
    case 13:
      node = sceneGB.getChildByTag(309);
      app.animations.tintTo(node, 2.0, 0.0, 0.0, 255.0, Tween.Cubic.OUT);
      break;
    case 14:
      node = sceneGB.getChildByTag(102);
      app.animations.hide(node);
      break;
    case 15:
      node = sceneGB.getChildByTag(102);
      app.animations.show(node);
      break;
    case 16:
      break;
    case 17:
      node = sceneGB.getChildByTag(102);
      app.animations.toggleVisible(node);
      break;
    case 18:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Quad.IN);
      break;
    case 181:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Quad.OUT);
      break;
    case 182:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Quad.INOUT);
      break;
    case 19:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Back.IN);
      break;
    case 20:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Back.OUT);
      break;
    case 21:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Back.INOUT);
      break;
    case 22:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Bounce.IN);
      break;
    case 23:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Bounce.OUT);
      break;
    case 24:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Bounce.INOUT);
      break;
    case 25:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Elastic.IN);
      break;
    case 26:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Elastic.OUT);
      break;
    case 27:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Elastic.INOUT);
      break;
    case 28:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Expo.IN);
      break;
    case 29:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Expo.OUT);
      break;
    case 30:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Expo.INOUT);
      break;
    case 31:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Sine.IN);
      break;
    case 32:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Sine.OUT);
      break;
    case 33:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      app.animations.moveTo(node, 1.0, 500.0, 500.0, Tween.Sine.INOUT);
      break;
    case 1000:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      node.rotationByDegrees = 0.0;

      Tween.Timeline tw = new Tween.Timeline.sequence();
      tw..push(app.animations.rotateBy(node, 2.0, 90.0, Tween.Cubic.OUT, null, false))
        ..push(app.animations.moveBy(node, 2.0, 200.0, 200.0, Tween.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_XY, null, false))
        ..start();
      
      break;
    case 1001:
      node = sceneGB.getChildByTag(102);
      node.setPosition(400.0, 100.0);
      node.rotationByDegrees = 0.0;
      
      Tween.Timeline tw = new Tween.Timeline.parallel();
      tw..push(app.animations.rotateBy(node, 2.0, 90.0, Tween.Cubic.OUT, null, false))
        ..push(app.animations.moveBy(node, 2.0, 200.0, 200.0, Tween.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_XY, null, false))
        ..start();

      break;
    case 80:
//      double angle = double.parse(angleSlider.value);
//      animation = new Ranger.RotateRelativeToX.withDuration(1.0, angle);
//      node = sceneGB.getChildByTag(102);
//      node.setPosition(400.0, 100.0);
      break;
    case 1002:
//      animation = new Ranger.AnimationTween.withDuration(2.0, _tweenDelegate, 0.5, 2.0);
//      node = sceneGB.getChildByTag(102);
//      node.setPosition(400.0, 100.0);
      break;
    case 1003:
//      Ranger.Blink blink = new Ranger.Blink.withDuration(2.0, 10, 95.0);
//      Ranger.Place place = new Ranger.Place.withPosition(200.0, 200.0);
//      Ranger.MoveBy moveBy = new Ranger.MoveBy.withDurationAndDeltaByComps(1.0, 200.0, 0.0);
//      Ranger.MoveBy moveBy2 = new Ranger.MoveBy.withDurationAndDeltaByComps(1.0, 0.0, 200.0);
//      Ranger.RotateBy rotateBy = new Ranger.RotateBy.withDuration(1.0, 90.0);
//      Ranger.CallFunction callFunc = new Ranger.CallFunction.withFunction(_callFunc, "Complete");
//      Ranger.Sequence sequence = new Ranger.Sequence.withAnimation(blink);
//      sequence.add(place);
//      sequence.add(moveBy);
//      sequence.add(rotateBy);
//      sequence.add(moveBy2);
//      sequence.add(callFunc);
//      animation = sequence;
//      node = sceneGB.getChildByTag(102);
//      node.setPosition(400.0, 100.0);
      break;
    case 1004:
      node = sceneGB.getChildByTag(2002);
      app.animations.shake(node, 2.0, 10.0);
      
      break;
  }
  
}

void _setupAnimation() {

}

Ranger.Scene _buildScene() {
  // Map a view-space coord to world-space.
  // View-space = mouse-space = display-space.
  //---------------------------------------------------------------
  // Scene
  //---------------------------------------------------------------
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 3001;

  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#dddddd"));
  scene.addChild(layer, 0, 2002);

  //---------------------------------------------------------------
  // Basic grid
  //---------------------------------------------------------------
  Ranger.Size<double> size = Ranger.Application.instance.designSize;
  GridNode grid = new GridNode.withDimensions(size.width, size.height, false);
  layer.addChild(grid, 0, 99);

  return scene;
}

class FadingBox extends SquareNode with Ranger.Color4Mixin, Ranger.RotationBehavior {

  void initWithColor(Ranger.Color4<int> color) {
    super.initWithColor(color);
    fillColor = color.toString();
  }
  
  @override
  void set opacity(int opacity) {
    super.opacity = opacity;
    fillColor = color.toString();
  }

  @override
  void set color(Ranger.Color4<int> c) {
    super.color.r = c.r;
    super.color.g = c.g;
    super.color.b = c.b;
    fillColor = c.toString();
  }
  
}

class TestLayer extends Ranger.BackgroundLayer {
  
  TestLayer();
  
  factory TestLayer.withColor([Ranger.Color4<int> color, int width, int height]) {
    TestLayer layer = new TestLayer();
    layer.init(width, height);
    layer.color = color;
    return layer;
  }
  
  void addedAsChild() {
    
  }

  @override
  void onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish();
    Ranger.Application app = Ranger.Application.instance;

    Tween.Tween.registerAccessor(TestLayer, app.animations);

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
    addChild(baseSystemN, 10, 101);

    Tween.Tween.registerAccessor(SquareNode, app.animations);
    
    //---------------------------------------------------------------
    // A point "inside" of the box for reference and comparison.
    //---------------------------------------------------------------
    NodePoint boxPointNode = new NodePoint();
    boxPointNode.setPosition(50.0, 0.0);
    boxPointNode.color = Ranger.Color3IBlue;
    baseSystemN.addChild(boxPointNode, 100, 102);
    Tween.Tween.registerAccessor(NodePoint, app.animations);

    FadingBox fadingBox = new FadingBox();
    fadingBox.initWithColor(Ranger.Color4IOrange);
    fadingBox.solid = true;
    fadingBox.outlined = true;
    fadingBox.size = 100.0;
    fadingBox.center();
    fadingBox.setPosition(400.0, 100.0);
    //fadingBox.rotationByDegrees = 95.0;  // CW
    addChild(fadingBox, 11, 102);
    Tween.Tween.registerAccessor(FadingBox, app.animations);

    NodePoint boxPoint2Node = new NodePoint();
    boxPoint2Node.setPosition(50.0, 0.0);
    boxPoint2Node.color = Ranger.Color3IBlue;
    boxPoint2Node.uniformScale = 3.0;
    fadingBox.addChild(boxPoint2Node, 101, 202);

    ColorPoint colorPointNode = new ColorPoint.initWith(Ranger.Color4IGreen);
    colorPointNode.setPosition(250.0, 250.0);
    colorPointNode.uniformScale = 25.0;
    colorPointNode.visible = true;
    addChild(colorPointNode, 101, 309);
    Tween.Tween.registerAccessor(ColorPoint, app.animations);
  }
  
//  @override
//  bool onKeyDown(MutableEvent event) {
//    print("onKeyDown: $event");
//    return true; // claiming key.
//  }
//
//  @override
//  bool onTouchsBegan(MutableEvent event) {
//    print("onTouchsBegan: $event");
//    return TouchDelegate.CLAIMED;
//  }

//  @override
//  bool onTouchsMoved(Ranger.MutableEvent event) {
//    Ranger.Application app = Ranger.Application.instance; 
//    app.showViewMouse(event.mouse.offset.x, event.mouse.offset.y);
//    
//    Ranger.Point wP = app.drawContext.mapViewToWorld(event.mouse.offset.x, event.mouse.offset.y);
//    //wP.set(350.0, 350.0);
//    app.showWorldPos(wP.x, wP.y);
//    wP.moveToPool();
//    
//    // Find the box node by Tag. Note you don't really want to do this
//    // on "moves" you really should cache the Tagged Node.
//    Ranger.Node box = getChildByTag(101);
//    
//    if (box != null) {
//      Ranger.Point nP = box.convertToNodeSpace(wP);
//      app.showLocalPos(nP.x, nP.y);
//      nP.moveToPool();
//    }
//    
//    return Ranger.TouchDelegate.CLAIMED;
//  }
  
//
//  @override
//  bool onTouchsDrag(MutableEvent event) {
//    print("onTouchsDrag: $event");
//    return TouchDelegate.CLAIMED;
//  }

}

void _callFunc(Object data) {
  if (data is String) {
    print(data);
  }
}

void _tweenDelegate(double value) {
  Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
  Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;

  Ranger.BaseNode node = sceneGB.getChildByTag(102);
  //node.uniformScale = value;
  node.scaleX = value;
  node.scaleY = value;
}

void _angleChanged(Event e) {
  Element angleText = querySelector("#angle");
//    double angle = double.parse(angleSlider.value);
//    print("${math.cos(degressToRadians(angle))}, ${math.sin(degressToRadians(angle))} : $angle");
  angleText.text = angleSlider.value;
}
