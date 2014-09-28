library template0;

import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;

// The main game scene where the fun happens.
part '../level0/scenes/game/game_scene.dart';
part '../level0/scenes/game/game_layer.dart';

// The splash scene is where resources are loaded.
part 'scenes/splash/splash_scene.dart';
part 'scenes/splash/splash_layer.dart';

// Ranger application access
Ranger.Application _app;

//----#############################################################
// NOTE: If you are forced to run an earlier version of Dartium you may
//      need to supply this "--user-data" flag after having created the
//      actually file path.
// --user-data-dir=/Users/williamdevore/Documents/Development/dart_1.4x/profile
//----#############################################################

void main() {
  // Note: placing a breakpoint here will cause the Application to miss
  // the resize event neccessary to bootstrap the Engine. Use at your own
  // discresion.
  
  // Design sizes:
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

}

void _shutdown() {
  Ranger.Application.instance.shutdown();
}

/*
 * A helpful scene graph layout of this template.
 * GameScene = 2001
 *  AnchorBase = 2525
 *    GroupNode = 2011 = primary
 *      GameLayer = 2010
 *        TextNode = 445
 *      --> MainMoveInScene = 409 (Transition = 9091)
 * 
 * SplashScene = 405 (Transition = 9090)
 *  AnchorBase = 2525
 *    SplashLayer = 404 = primary
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
  splashScene.pauseFor = 3.0;
  
  // Create BootScene and push it onto the currently empty scene stack. 
  Ranger.BootScene bootScene = new Ranger.BootScene(splashScene);

  // Once the boot scene's onEnter is called it will immediately replace
  // itself with the replacement Splash screen.
  _app.sceneManager.pushScene(bootScene);
  
  // Now complete the pre configure by signaling Ranger.
  _app.gameConfigured();
}
