import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;

import 'particle_layer.dart';

import 'resources/resources.dart';

import 'panels/emitters_tab.dart';
import 'panels/emitter_properties_tab.dart';
import 'panels/animation_panel.dart';
import 'model_controller.dart';

InputElement _btnLocalStorageLoadElement;
InputElement _btnLocalStorageSaveElement;

//Store _appStore;
Map _appConfig;
Ranger.Application _app;
//LocalStorageDialog _localStoragePicker;
ParticleLayer _particleLayer;

Resources _resources;
ModelController _modelController;

// ------------------------------------------------------
// Panels and tabs
// ------------------------------------------------------
EmittersTab _emittersTab;
EmitterPropertiesTab _emitterPropertiesTab;
AnimationPanel _animationPanel;

int designWidth = 400;
int designHeight = 600;

void main() {
  
  window.onUnload.listen(
      (Event event) => _unLoad()
  );
  
  /*
   * Boot sequence:
   * 1) Ranger construct
   * 2) _rangerReady
   * 3) Resources loaded (includes: icons, default PS, app config)
   * 4) Construct GUI
   * 5) Add default emitter
   * 6) Load local storage
   * 7) Add emitters
   * 8) Configure GUI based on app config.
   * 9) -- Done.
   */
  // ------------------------------------------------------
  // Ranger is the first component bootstraped
  // ------------------------------------------------------
  // Create the Ranger Engine application. When the engine is ready
  // your Callback will be called allowing you to start adding nodes etc...
  _app = new Ranger.Application.fitDesignToContainer(
      window, 
      Ranger.CONFIG.surfaceTag,
      _rangerReady,
      _sceneReady,
      designWidth, designHeight
      );
}

void _configure() {
  _configureStates(_resources.appConfig);
}

void _configureGUIBindings() {
  // ------------------------------------------------------
  // local storage loading.
  // ------------------------------------------------------
  _btnLocalStorageLoadElement = querySelector("#btnLoadLocalStorage");
//  _btnLocalStorageLoadElement.onClick.listen(
//      (event) => _loadLocalStorageFile()
//  );

  _btnLocalStorageSaveElement = querySelector("#btnSaveAsLocalStorage");
//  _btnLocalStorageSaveElement.onClick.listen(
//      (event) => _saveLocalStorageFile()
//  );

  // ------------------------------------------------------
  // Emitters loaded panel
  // ------------------------------------------------------
  _emittersTab = new EmittersTab();
  _emittersTab.init(_modelController, _emitterTabSelected);
  
  _emitterPropertiesTab = new EmitterPropertiesTab();
  _emitterPropertiesTab.init(_modelController, _emitterPropertiesTabSelected);
  
  _animationPanel = new AnimationPanel();
  _animationPanel.init(_animationPanelChanged);
  _animationPanel.app = _app;
}

void _configureScene() {
  //---------------------------------------------------------------
  // Simple color layer
  //---------------------------------------------------------------
  _particleLayer = new ParticleLayer.withColor(Ranger.color4IFromHex("#222222"), true, designWidth, designHeight);
  _modelController.particleLayer = _particleLayer;

  Ranger.Scene scene = new Ranger.AnchoredScene.withPrimaryLayer(_particleLayer, _completeVisit);
  scene.tag = 2001;

  _animationPanel.particleLayer = _particleLayer;
  _emittersTab.particleLayer = _particleLayer;
  
  _app.sceneManager.pushScene(scene);
}

//-----------------------------------------------------------------
// Local storage and file loading
//-----------------------------------------------------------------
//void _loadLocalStorageFile() {
//  _particleLayer.ignoreKeyInput = true;
//  _localStoragePicker.loadFile(_fileLoaded);
//}
//
//// used by formal dialog box
//void _saveLocalStorageFile() {
//  _particleLayer.ignoreKeyInput = true;
//  _localStoragePicker.saveFile(_particleLayer.configuration, _fileSaved);
//}

//void _fileSaved() {
//  print("file saved.");
//  _particleLayer.ignoreKeyInput = false;
//}

//void _fileLoaded(Emitter map) {
//  // Update gui to show new map.
//  _emittersTab.addNewEmitter(map, true);
//  
//  _particleLayer.ignoreKeyInput = false;
//
//  // TODO Update model. model will update ui.
////  _emitterPropertiesTab.update(map);
//}

//-----------------------------------------------------------------
// Shutdown by using Command-Q. Note: using "stop" button in editor will
// not trigger this unload.
//-----------------------------------------------------------------
void _unLoad() {
  if (_appConfig != null) {
    if (_appConfig.containsKey("SelectedMap")) {
      _appConfig["SelectedMap"] = _modelController.selectedMapName;
    }
  
    _resources.appStore.save(_appConfig, "Config").then((_) {
    }).catchError(_handleSaveConfigError);
  }
}

//-----------------------------------------------------------------
// Ranger is now bootstrapped.
//-----------------------------------------------------------------
void _rangerReady() {
  _resources = new Resources();
  print("Loading resources....");
  _resources.loadBaseResources().then((_) {
    print("Resources loaded.");
    
    _modelController = new ModelController(_resources);
    
    _configureGUIBindings();
    
    _configureScene();

    _app.gameConfigured();

    _emittersTab.addDefaultEmitter(_resources.defaultParticleSystem);
  }).catchError((Error e) => print(e));
}

// This is called after the a node's onEnter has completed.
// The particle system has been created at this point.
void _sceneReady() {
  _emittersTab.reload();
//  _emitterPropertiesTab.bind();
  
  // Attempt to select previously selected map.
  _configure();
}

// This is called by Ranger after a complete visitation of the scenegraph.
// Typically things like FPS display updates happen here.
void _completeVisit() {
  //Ranger.Application app = Ranger.Application.instance;
  
  // TODO add stats
//  if (app.updateStats) {
//    objectsDrawnElement.text = "${app.objectsDrawn}";
//    framePerPeriodElement.text = "${app.framesPerPeriod} , UPS: ${app.updatesPerPeriod}";
//    frameCountElement.text = "${app.frameCount}";
//    
//    app.framesPerPeriod = 0;
//    app.updatesPerPeriod = 0;
//    app.deltaAccum = 0.0;
//    
//    if (!(app.fpsAverage.isInfinite || app.fpsAverage.isNaN))
//      fpsElement.text = "${app.fpsAverage.toStringAsFixed(2)}";
//    else
//      fpsElement.text = "Not enabled";
//  }
}

//-----------------------------------------------------------------
// Configuration
//-----------------------------------------------------------------
void _configureStates(Map config) {
  // Does storage have our map.
  if (config != null) {
    _appConfig = config;
    _processConfig(_appConfig);
  }
  else {
    // Gen a new one and save it.
    _appConfig = {
      'FPS': 60,
      'AnimationEnabled': false,
      'SelectedMap': '_default'
    };
    
    _resources.appStore.save(_appConfig, "Config").then((_) {
      _processConfig(_appConfig);
    }).catchError(_handleSaveConfigError);
  }

}

void _handleSaveConfigError(Error error) {
  print("main._handleSaveConfigError: $error");
}

void _processConfig(Map configMap) {
  if (configMap.containsKey("FPS")) {
    int fps = configMap["FPS"] as int;
    _animationPanel.frameRate = fps;
  }
  
  if (configMap.containsKey("SelectedMap")) {
    String map = configMap["SelectedMap"] as String;
    _modelController.selectMapByName = map;
  }
  else {
    _modelController.selectMapByName = "_default";
  }

  _modelController.emitterChanged();
  _modelController.dataChanged(false);
}

//-----------------------------------------------------------------
// GUI
//-----------------------------------------------------------------
int _findValuePart(String value) {
  RegExp nameMatcher = new RegExp(r"[0-9]+");
  String v = nameMatcher.stringMatch(value);
  return int.parse(v);
}

void _emitterTabSelected() {
  _emitterPropertiesTab.hideTab();
}

void _emitterPropertiesTabSelected() {
  _emittersTab.hideTab();
  _emitterPropertiesTab.nowVisible();
}

void _animationPanelChanged() {
  
}
