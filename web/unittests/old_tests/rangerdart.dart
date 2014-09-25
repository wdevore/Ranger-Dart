import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;
//import 'ranger/unittests/bag_test.dart' as bagTest;
//import 'ranger/unittests/poolable_test.dart' as poolTest;
//import 'ranger/unittests/scheduler_test.dart' as schedulerTest;
//import 'ranger/unittests/scene_test.dart' as sceneTest;
//import 'ranger/unittests/node_tests.dart' as nodeTests;
//import 'ranger/unittests/spacemapping_tests.dart' as mappingTests;
//import 'ranger/unittests/affine_transform_tests.dart' as affineTests;
//import 'ranger/unittests/animation_tests.dart' as animationTests;

import '../old_tests/spacemapping_tests.dart';
import '../old_tests/animation_tests.dart';
import '../old_tests/scene_tests.dart';
import '../old_tests/particle_systems_tests.dart';
import '../old_tests/aabbox_visibility_tests.dart';

SelectElement _sceneGroupElement;
Ranger.Application _app;
Element windowInfoElement;
InputElement shutdownElement;

//----#############################################################
// NOTE: If you are forced to run an earlier version of Dart you may
//      need to supply this --user-data flag after having created the
//      actually file path.
// --user-data-dir=/Users/williamdevore/Documents/Development/dart_1.4x/profile
//----#############################################################

void main() {
  
  _sceneGroupElement = querySelector("#sceneGroups");
  _sceneGroupElement.onChange.listen(
      (Event event) => _changeScenes()
  );

  // Non skewing
//  Ranger.Application app = new Ranger.Application(
//      window, 
//      Ranger.CONFIG.surfaceTag, 
//      1280, 800,
//      Ranger.CONTAINER_FIT_HINT.MAX_WINDOW_BOTH_EXTENT,
//      Ranger.CANVAS_FIT_POLICY.SCALE_EXTENTS, 
//      Ranger.CANVAS_ALIGNMENT_POLICY.CENTER);

  // Skewing arrangement
//  Ranger.Application app = new Ranger.Application(
//      window, 
//      Ranger.CONFIG.surfaceTag, 
//      1280, 800,
//      Ranger.CONTAINER_FIT_HINT.MAX_WINDOW_BOTH_EXTENT,
//      Ranger.CANVAS_FIT_POLICY.MAX_EXTENTS, 
//      Ranger.CANVAS_ALIGNMENT_POLICY.CENTER);

  // Skewing at max fill.
//  Ranger.Application app = new Ranger.Application(
//      window, 
//      Ranger.CONFIG.surfaceTag, 
//      1280, 800,
//      Ranger.CONTAINER_FIT_HINT.MAX_WINDOW_EXTENTS,
//      Ranger.CANVAS_FIT_POLICY.MAX_EXTENTS, 
//      Ranger.CANVAS_ALIGNMENT_POLICY.CENTER);

  // Note: placing a breakpoint here will cause the Application to miss
  // the resize event neccessary to bootstrap the Engine.
  // Nexus 7 = 1280, 800
  // Generic = 640, 400
  // Container = 720, 700
  // The Container is "peach"
  _app = new Ranger.Application.fitDesignToWindow(
      window, 
      Ranger.CONFIG.surfaceTag,
      runUnitTests,
      1280, 800
      );

  Ranger.Logging.info("main: App started");
  
  windowInfoElement = querySelector("#windowInfo");

  window.onResize.listen(
      (Event e) => _windowResize(e)
      );

  shutdownElement = querySelector("#shutDown");
  shutdownElement.onClick.listen(
      (Event event) => _shutdown()
      );

}

void _shutdown() {
  Ranger.Application.instance.shutdown();
}

void _windowResize(Event e) {
  showWindowInfo();
}

void showWindowInfo() {
  windowInfoElement.text = "{${window.innerWidth} x ${window.innerHeight}}";
}

void runUnitTests() {
  //bagTest.main();
  //poolTest.main();
  //schedulerTest.main(Ranger.Application.instance);
  //nodeTests.main(Ranger.Application.instance);
 
//  mappingTests.main(Ranger.Application.instance);
//  affineTests.main(Ranger.Application.instance);

//  sceneTests(Ranger.Application.instance);
//  animationTests(Ranger.Application.instance);
  _changeScenes();

  _app.gameConfigured();
}

void _changeScenes() {
  int group = int.parse(_sceneGroupElement.value);
  Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

  sm.popScene();
  Ranger.Scene scene;
  
  switch (group) {
    case 1:
      scene = animationTests(Ranger.Application.instance);
      break;
    case 2:
      scene = sceneTests(Ranger.Application.instance);
      break;
    case 3:
      scene = spaceMappingTest(Ranger.Application.instance);
      break;
    case 5:
      scene = particleSystemsTest(Ranger.Application.instance);
      break;
    case 6:
      scene = aabboxVisibilityTest(Ranger.Application.instance);
      break;
  }
  
  _app.sceneManager.pushScene(scene);
}