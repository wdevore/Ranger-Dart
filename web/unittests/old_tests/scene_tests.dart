library sceneLibtests;

import 'dart:html';
import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as Tween;

import 'scenes_and_nodes.dart';

InputElement _debugAction1Element;
InputElement _debugAction2Element;
//InputElement _debugAction3Element;
SelectElement _sceneTransitions;
InputElement _applyAnimationElement;

bool sceneToggle = false;

//Ranger.Scene _scene;
Ranger.AnchoredScene _scene;
TestLayer _layer;

/*
 * Test Scenes:
 * Popping,
 * Replacing,
 * Transitioning
 * 
 */
Ranger.Scene sceneTests(Ranger.Application app) {
  _debugAction1Element = querySelector("#debugAction1");
  _debugAction1Element.onClick.listen(
      (Event event) => _popScene(app)
  );
  
  _debugAction2Element = querySelector("#debugAction2");
  _debugAction2Element.onClick.listen(
      (Event event) => _replaceScene()
  );
  
  _sceneTransitions = querySelector("#sceneTransitions");
  _sceneTransitions.onChange.listen(
      (Event event) => _transitionToSelectedScene(event)
  );


  _applyAnimationElement = querySelector("#applyAnimation");
  _applyAnimationElement.onClick.listen(
      (Event event) => _applyAnimation(event)
  );

//  _scene = _setupForSceneTransition(app);
  _scene = _setupForAnchoredTransition(app);
  
  return _scene;
}

void _applyAnimation(Event e) {
  _layer.applyAnimation();
}

void _transitionToSelectedScene(Event e) {
  int test = int.parse(_sceneTransitions.value);

  if (test > 0) {
    Ranger.Scene inScene = _getIncomingScene();
  
    Ranger.TransitionScene transition;
    
    switch (test) {
      case 1:
        transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(1.0, inScene, Ranger.TransitionMoveInFrom.FROM_LEFT);   
        break;
      case 2:
        transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(1.0, inScene, Ranger.TransitionMoveInFrom.FROM_RIGHT);   
        break;
      case 3:
        transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(1.0, inScene, Ranger.TransitionMoveInFrom.FROM_BOTTOM);   
        break;
      case 4:
        transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(1.0, inScene, Ranger.TransitionMoveInFrom.FROM_TOP);   
        break;
      case 5:
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, inScene, Ranger.TransitionSlideIn.FROM_LEFT);   
        break;
      case 6:
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, inScene, Ranger.TransitionSlideIn.FROM_RIGHT);   
        break;
      case 7:
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, inScene, Ranger.TransitionSlideIn.FROM_BOTTOM);   
        break;
      case 8:
        transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, inScene, Ranger.TransitionSlideIn.FROM_TOP);   
        break;
      case 9:
        transition = new Ranger.TransitionShrinkGrow.initWithDurationAndScene(1.5, inScene);   
        break;
      case 10:
        transition = new Ranger.TransitionFanInFanOut.initWithDurationAndScene(1.5, inScene);   
        break;
      case 11:
        transition = new Ranger.TransitionRotateAndZoom.initWithDurationAndScene(2.0, inScene);   
        break;
    }
    
    transition.tag = 3030;
  
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
    sm.replaceScene(transition);
  }

}

Ranger.Scene _getIncomingScene() {
  Ranger.Scene scene;
  
  if (sceneToggle) {
    scene = _buildOutGoiingAnchoredScene();
//    scene = _buildAnchoredScene1();
  }
  else {
    scene = _buildInComingAnchoredScene();
//    scene = _buildAnchoredScene2();
  }
  
  sceneToggle = !sceneToggle;
  
  return scene;
}

Ranger.Scene _setupForAnchoredTransition(Ranger.Application app) {
  Ranger.Scene scene1 = _buildOutGoiingAnchoredScene();
  app.sceneManager.pushScene(scene1);
  return scene1;
}

Ranger.Scene _setupForSceneTransition(Ranger.Application app) {
  Ranger.Scene scene1 = _buildScene1();
  app.sceneManager.pushScene(scene1);
  
  return scene1;
}

void _transitionToAnchoredScene() {
  Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

  Ranger.Scene scene2 = _buildScene2();
  scene2.tag = 2;

//  Ranger.TransitionRotateAndZoom transition = new Ranger.TransitionRotateAndZoom.initWithDurationAndScene(4.0, scene2);
//  Ranger.TransitionSlideIn transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, scene2, Ranger.TransitionMoveInFrom.FROM_BOTTOM);
  Ranger.TransitionShrinkGrow transition = new Ranger.TransitionShrinkGrow.initWithDurationAndScene(1.0, scene2);
  transition.tag = 3;
  sm.replaceScene(transition);
}

void _transitionToScene() {
  Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

  Ranger.Scene scene2 = _buildInComingAnchoredScene();
  scene2.tag = 2;

//  Ranger.TransitionRotateAndZoom transition = new Ranger.TransitionRotateAndZoom.initWithDurationAndScene(4.0, scene2);
//  Ranger.TransitionMoveInFrom transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(1.0, scene2, Ranger.TransitionMoveInFrom.FROM_BOTTOM);
//  Ranger.TransitionSlideIn transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, scene2, Ranger.TransitionMoveInFrom.FROM_BOTTOM);
  Ranger.TransitionShrinkGrow transition = new Ranger.TransitionShrinkGrow.initWithDurationAndScene(1.0, scene2);
  transition.tag = 3;
  sm.replaceScene(transition);
}

void _setupForPopScene(Ranger.Application app) {
  // Push 2 scenes then pop the last one off.
  Ranger.Scene scene1 = _buildScene1();
  app.sceneManager.pushScene(scene1);

  BasicScene scene2 = _buildScene2();
  app.sceneManager.pushScene(scene2);
}

// Build the starting scene that will also be the out going scene during
// the transition.
Ranger.AnchoredScene _buildOutGoiingAnchoredScene() {
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ffaaddff"));
  
  Ranger.AnchoredScene scene = new Ranger.AnchoredScene.withPrimaryLayer(layer);
  scene.tag = 4001;

  return scene;
}

// During the transition this is the scene that will be entering the
// stage (aka the in coming scene).
Ranger.AnchoredScene _buildInComingAnchoredScene() {
  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ffddaaff"));

  Ranger.AnchoredScene scene = new Ranger.AnchoredScene.withPrimaryLayer(layer);
  scene.tag = 4002;

  return scene;
}

BasicScene _buildScene1() {
  BasicScene scene = new BasicScene.withPrimary(null);
  scene.tag = 4003;

  Ranger.SceneAnchor anchorBase = new Ranger.SceneAnchor();
  anchorBase.iconVisible = true;
  scene.addChild(anchorBase, 0, 2525);
  
  Ranger.SceneAnchor anchor = new Ranger.SceneAnchor();
  anchorBase.addChild(anchor, 0, 2526);

  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ffddddff"));
  anchor.addChild(layer, 0, 333);

  return scene;
}

Ranger.BaseNode _buildScene2() {
  BasicScene scene = new BasicScene.withPrimary(null);
  
  scene.tag = 4004;

  TestLayer layer = new TestLayer.withColor(Ranger.color4IFromHex("#ddffddff"));
  scene.addChild(layer, 0, 334);

  return scene;
}

void _popScene(Ranger.Application app) {
  print("pop scene");
  app.sceneManager.popScene();
}

void _replaceScene() {
//    Logging.info("replace scene");
//    SceneBox2 scene = new SceneBox2();
//    scene.tag = 66;
//    NodePoint2 points = new NodePoint2();
//    points.point2.setValues(20.0, 20.0);
//    points.setPosition(200.0, 200.0);
//    scene.addChild(points, 0, 0);
//    sceneManager.replaceScene(scene);
}

class TestLayer extends Ranger.BackgroundLayer {
  
  TestLayer();
  
  factory TestLayer.withColor([Ranger.Color4<int> color, int width, int height]) {
    _layer = new TestLayer();
    _layer.centered = true;
    _layer.showOriginAxis = true;
    // app.designSize.width.toInt(), app.designSize.height.toInt()
    _layer.init(width, height);
    _layer.color = color;
    return _layer;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    Ranger.Application app = Ranger.Application.instance;
    
    double centerX = app.designSize.width / 2.0;
    double centerY = app.designSize.height / 2.0;

    
    double anchorPosX = centerX;
    double anchorPosY = app.designSize.height;
    // Some test anchor locations.
//    _scene.setAnchorBasePosition(centerX, app.designSize.height);
//    _scene.setAnchorBasePosition(centerX, centerY + 100.0);
//    _scene.setAnchorBasePosition(centerX, centerY);
//    _scene.setAnchorBasePositionByPercent(50.0, 50.0);

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
    boxPointNode.uniformScale = 10.0;
    baseSystemN.addChild(boxPointNode, 100, 102);

    // Spin the box forever.
    Tween.Tween.registerAccessor(SquareNode, app.animations);
    Tween.BaseTween tw = app.animations.rotateBy(baseSystemN, 5.0, 360.0, Tween.Cubic.INOUT, null, false);
    tw..repeat(Tween.Tween.INFINITY, 0.0)
      ..start();
  }
 
  // A test method attached to the animate button
  void applyAnimation() {
    Ranger.Application app = Ranger.Application.instance;
    double centerX = app.designSize.width / 2.0;
    double centerY = app.designSize.height / 2.0;
//    _scene.setAnchorPosition(centerX, app.designSize.height + 400.0);
    _scene.anchor.rotationByDegrees = 0.0;
//    _scene.setAnchorBasePosition(centerX, app.designSize.height);
//    _scene.setAnchorPosition(100.0, 100.0);
    
    Tween.Timeline par = new Tween.Timeline.parallel();
    
//    par..push(Tween.Tween.to(_scene, Ranger.AnchoredScene.TRANSLATE_Y, 1.2)
//            ..targetRelative = [-800.0]
//            ..easing = Tween.Linear.INOUT);
    
    par..push(new Tween.Tween.to(_scene, Ranger.AnchoredScene.ROTATE, 1.0)
            ..targetRelative = [360.0]
            ..easing = Tween.Linear.INOUT);
    
    par.start(app.animations.tweenMan);
  }
  
  @override
  void onEnterTransitionDidFinish() {
    print("Scenetest.TestLayer.onEnterTransitionDidFinish");
    Ranger.Application app = Ranger.Application.instance;
  }
  
}