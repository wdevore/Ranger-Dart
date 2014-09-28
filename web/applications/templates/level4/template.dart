library template4;

import 'dart:html';
import 'dart:async';

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;

part 'resources/resources.dart';
part 'game_manager.dart';

// The main game scene where the fun happens.
part 'scenes/game/game_scene.dart';
part 'scenes/game/game_layer.dart';
part 'scenes/game/rotate_tween_accessor.dart';

// The splash scene is where resources are loaded.
part 'scenes/splash/splash_scene.dart';
part 'scenes/splash/splash_layer.dart';

// Ranger application access
Ranger.Application _app;

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
  splashScene.pauseFor = 1.0;
  
  // Create BootScene and push it onto the currently empty scene stack. 
  Ranger.BootScene bootScene = new Ranger.BootScene(splashScene);

  // Once the boot scene's onEnter is called it will immediately replace
  // itself with the replacement Splash screen.
  _app.sceneManager.pushScene(bootScene);
  
  // Now complete the pre configure by signaling Ranger.
  _app.gameConfigured();
}
