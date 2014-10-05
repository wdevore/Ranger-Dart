library ranger_rocket;

import 'dart:html';
import 'dart:async';
import 'dart:math';

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;
import 'package:vector_math/vector_math.dart';

// Resources
part 'resources/resources.dart';

// Management
part 'game/game_manager.dart';
part 'game/message_data.dart';

// Panels and dialogs
part 'game/dialogs/controls_dialog.dart';
part 'game/dialogs/base_modal_dialog.dart';

// The main game scene where the fun happens.
part 'game/scenes/game/game_scene.dart';
part 'game/scenes/game/game_layer.dart';
part 'game/scenes/game/hud_layer.dart';

// The splash scene is where resources are loaded.
part 'game/scenes/splash/splash_scene.dart';
part 'game/scenes/splash/splash_layer.dart';

part 'game/scenes/zoom_group.dart';

// Actors
part 'game/nodes/triangle_ship.dart';
part 'game/nodes/dual_cell_ship.dart';

// Geometry
part 'game/geometry/point_color.dart';
part 'game/geometry/square_polygon_node.dart';
part 'game/geometry/triangle_polygon_node.dart';
part 'game/geometry/circle_particle_node.dart';
part 'game/geometry/polygon_node.dart';

// The Ranger application access
Ranger.Application _app;
GameManager _manager = GameManager.instance;

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
 * There are 3 ships.
 * There are two obstacles. Hit one and it shakes. Hit the other and the
 * scene shakes.
 * A slide out menu activated by an upper-right button.
 *  Select ship 1 or 2 or 3.
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
      1920, 1080
      );

  Ranger.Logging.info("Ranger: App started");
  window.onResize.listen(
      (Event e) => _windowResize(e)
      );
  
  // NOTE: this keypress is simply for doing screen recordings. It isn't
  // required for Ranger at all.
  // Normally you would create the BootScene using the default behavior
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
  //print("{${window.innerWidth} x ${window.innerHeight}}");
}

void preConfigure() {
  //---------------------------------------------------------------
  // The main game scene that contains the game layers.
  // It is also the Incoming scene after the splash screen.
  //---------------------------------------------------------------
  GameScene gameScene = new GameScene();

  //---------------------------------------------------------------
  // Create a splash scene with a layer that will be shown prior
  // to transitioning to the main game scene.
  //---------------------------------------------------------------
  SplashScene splashScene = new SplashScene.withReplacementScene(gameScene);
  splashScene.pauseFor = 0.0;
  
  // Note: typically we push a boot scene for release.
  // A simple dummy scene to allow Ranger to complete boot sequence.
  _bootScene = new Ranger.BootScene(splashScene, !_bootSimulate);
  _app.sceneManager.pushScene(_bootScene);
  
  // We go straight to the game scene while developing.
//  _app.sceneManager.pushScene(gameScene);
  
  _app.gameConfigured();
}
