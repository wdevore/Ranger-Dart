library unittests;

import 'dart:html';
import 'dart:async';

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;
import 'package:vector_math/vector_math.dart';

part 'dialogs/base_modal_dialog.dart';
part 'dialogs/tests_dialog.dart';

part 'resources/resources.dart';

// The main game scene where the fun happens.
part 'scenes/game/game_scene.dart';
part 'scenes/game/game_manager.dart';
part 'scenes/game/game_layer.dart';
part 'scenes/game/hud_layer.dart';

part 'scenes/nodes/circle_particle_node.dart';
part 'scenes/nodes/grid_node.dart';
part 'scenes/nodes/point_color.dart';
part 'scenes/nodes/point_color_4i.dart';
part 'scenes/nodes/point_color_tween.dart';
part 'scenes/nodes/rectangle_node.dart';
part 'scenes/nodes/square_particle_node.dart';

// The splash scene is where resources are loaded.
part 'scenes/splash/splash_scene.dart';
part 'scenes/splash/splash_layer.dart';

part 'scenes/tests/transitions/movein_scene.dart';
part 'scenes/tests/transitions/movein_layer.dart';
part 'scenes/tests/transitions/slidein_scene.dart';
part 'scenes/tests/transitions/slidein_layer.dart';
part 'scenes/tests/transitions/misc_in_transitions_scene.dart';
part 'scenes/tests/transitions/misc_in_transitions_layer.dart';
part 'scenes/tests/transitions/misc_transitions_scene.dart';
part 'scenes/tests/transitions/misc_transitions_layer.dart';
part 'scenes/tests/inputs/keyboard_scene.dart';
part 'scenes/tests/inputs/keyboard_layer.dart';
part 'scenes/tests/inputs/mouse_scene.dart';
part 'scenes/tests/inputs/mouse_layer.dart';
part 'scenes/tests/inputs/touch_scene.dart';
part 'scenes/tests/inputs/touch_layer.dart';
part 'scenes/tests/transforms/transforms_scene.dart';
part 'scenes/tests/transforms/transforms_layer.dart';
part 'scenes/tests/colors/colors_scene.dart';
part 'scenes/tests/colors/colors_layer.dart';
part 'scenes/tests/particlesystems/particlesystems_scene.dart';
part 'scenes/tests/particlesystems/particlesystems_layer.dart';
part 'scenes/tests/particlesystems/particlesystems2_scene.dart';
part 'scenes/tests/particlesystems/particlesystems2_layer.dart';
part 'scenes/tests/fonts/fonts_scene.dart';
part 'scenes/tests/fonts/fonts_layer.dart';
part 'scenes/tests/sprites/sprites_scene.dart';
part 'scenes/tests/sprites/sprites_layer.dart';
part 'scenes/tests/spaces/spaces_scene.dart';
part 'scenes/tests/spaces/spaces_layer.dart';

// The Ranger application access
Ranger.Application _app;

/*
 * In order to record the boot sequence of this app I needed to be able
 * to control the sequence while a screen recorder was running.
 * There is no other purpose to _bootSimulate other than to control
 * when the splash scene appears. This isn't required for "normal" code.
 */
bool _bootSimulate = false;
StreamSubscription _bootKeypress;

Ranger.BootScene _bootScene;

/*
 * There are two ships.
 * There are two obstacles. Hit one and it shakes. Hit the other and the
 * scene shakes.
 * A slide out menu activated by an upper-right button.
 *  Select ship 1 or 2.
 *  toggle hud.
 * 
 */

//----#############################################################
// NOTE: If you are forced to run an earlier version of Dartium you may
//      need to supply this "--user-data" flag after having created the
//      actually file path.
// --user-data-dir=/Users/williamdevore/Documents/Development/dart_1.4x/profile
//----#############################################################

void main() {
  // Note: placing a breakpoint here will cause the Application to miss
  // the resize event neccessary to bootstrap the Engine.
  // Nexus 5 = 1920 x 1080 (default design base)
  // Nexus 7 = 1920 x (800 = 2012Year) or (1200 = 2013Year)
  // Generic = 640, 400
  // Container = 720, 700
  _app = new Ranger.Application.fitDesignToWindow(
      window, 
      Ranger.CONFIG.surfaceTag,
      preConfigure,
      1280, 800
      );

  Ranger.Logging.info("Ranger: App started");
  window.onResize.listen(
      (Event e) => _windowResize(e)
      );
  
  // NOTE: this keypress is simply for doing screen recordings. It isn't
  // required for Ranger at all.
  // Normally you could create the BootScene using the default behavior
  // which is to auto transition.
  if (_bootSimulate) {
    _bootKeypress = window.onKeyPress.listen(
        (KeyboardEvent e) => _simBoot(e)
        );
  }
}

void _simBoot(KeyboardEvent e) {
  _bootKeypress.cancel();
  _bootScene.forceTransition();
}

void _shutdown() {
  Ranger.Application.instance.shutdown();
}

void _windowResize(Event e) {
  showWindowInfo();
}

void showWindowInfo() {
  print("{${window.innerWidth} x ${window.innerHeight}}");
}

/*
 * GameScene = 2001
 *  AnchorBase = 2525
 *    GroupNode = 2011 = primary
 *      GameLayer = 2010
 *        SpriteImage = 911
 *        TextNode = 445
 *      HudLayer = 2012
 *        TextNode = 8111
 *        TextNode = 8112
 *      --> MainMoveInScene = 409 (Transition = 9091)
 * 
 * MainMoveInScene = 409 (410)
 *  AnchorBase = 2525
 *    MotionLayer = 509 = primary
 *      SpriteImage = 117
 *      SpriteImage = 118
 *      SpriteImage = 119
 *      SpriteImage = 120
 *      TextNode = 222
 * 
 *      --> MainMoveInScene = 410 (Transition = 9092)
 * 
 * 
 * SplashScene = 405 (Transition = 9090)
 *  AnchorBase = 2525
 *    SplashLayer = 404 = primary
 *      SpriteImage = 700
 *      TextNode = 701
 *      TextNode = 702
 * 
 */
void preConfigure() {
  //---------------------------------------------------------------
  // The main game scene that contains the game layers.
  // It is also the Incoming scene after the splash screen.
  //---------------------------------------------------------------
  GameScene gameScene = new GameScene(2001);

  //---------------------------------------------------------------
  // Create a splash scene with a layer that will be shown prior
  // to transitioning to the main game scene.
  //---------------------------------------------------------------
  SplashScene splashScene = new SplashScene.withReplacementScene(gameScene);
  splashScene.pauseFor = 2.5;
  
  // Note: typically we push a boot scene for release.
  // A simple scene to allow Ranger to complete its boot sequence.
  _bootScene = new Ranger.BootScene(splashScene, !_bootSimulate);
  _app.sceneManager.pushScene(_bootScene);
  
  // We go straight to the game scene while developing.
//  _app.sceneManager.pushScene(gameScene);
  
  _app.gameConfigured();

}
