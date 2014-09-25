import 'dart:html';
import 'dart:async';

import 'package:ranger/ranger.dart' as Ranger;

import 'scenes/game/game_manager.dart';

// The main game scene where the fun happens.
import 'scenes/game/game_scene.dart';

// The splash scene is where resources are loaded.
import 'scenes/splash/splash_scene.dart';

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
