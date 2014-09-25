import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;

// The main game scene where the fun happens.
import '../level2/scenes/game/game_scene.dart';

// The splash scene is where resources are loaded.
import 'scenes/splash/splash_scene.dart';

// Ranger application access
Ranger.Application _app;

//----#############################################################
// NOTE: If you are forced to run an earlier version of Dartium you may
//      need to supply this "--user-data" flag after having created the
//      actually file path.
// --user-data-dir=/Users/williamdevore/Documents/Development/dart_1.4x/profile
//----#############################################################

void main() {
  _app = new Ranger.Application.fitDesignToWindow(
      window, 
      Ranger.CONFIG.surfaceTag,
      preConfigure,
      1280, 800
      );
}

// Optional.
void _shutdown() {
  Ranger.Application.instance.shutdown();
}

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
  splashScene.pauseFor = 2.0;
  
  // Create BootScene and push it onto the currently empty scene stack. 
  Ranger.BootScene bootScene = new Ranger.BootScene(splashScene);

  // Once the boot scene's onEnter is called it will immediately replace
  // itself with the replacement Splash screen.
  _app.sceneManager.pushScene(bootScene);
  
  // Now complete the pre configure by signaling Ranger.
  _app.gameConfigured();
}
