library emitter_properties_panel;

import 'dart:html';

import 'life_panel.dart';
import 'emitter_control_panel.dart';
import 'speed_panel.dart';
import 'acceleration_panel.dart';
import 'startscale_panel.dart';
import 'endscale_panel.dart';
import 'rotation_rate_panel.dart';
import 'general_panel.dart';
import 'delay_panel.dart';
import 'duration_panel.dart';
import 'tint_panel.dart';
import 'emission_rate_panel.dart';

import '../model_controller.dart';
import '../data/emitter.dart';

class EmitterPropertiesTab {
  DivElement _emitterPropertiesElement;
  DivElement _emitterPropertiesTabElement;

  // Panels
  LifePanel _lifePanel;
  EmitterControlPanel _emitterControlPanel;
  EmissionRatePanel _emissionRateControlPanel;
  SpeedPanel _speedPanel;
  AccelerationPanel _accelerationPanel;
  StartScalePanel _startScalePanel;
  EndScalePanel _endScalePanel;
  RotationRatePanel _rotationRatePanel;
  GeneralPanel _generalPanel;
  DelayPanel _delayPanel;
  DurationPanel _durationPanel;
  TintPanel _tintPanel;
  
  bool _bindOccurred = false;
  
  Function _tabChanged;
  
  ModelController modelController;

  void init(ModelController modelController, Function tabChanged) {
    this.modelController = modelController;
    this.modelController.emitterPropertiesTab = this;
    
    _tabChanged = tabChanged;
    
    _emitterPropertiesTabElement = querySelector("#emittersPropertiesTabId");

    _emitterPropertiesElement = querySelector("#emitterPropertiesId");
    _emitterPropertiesElement.onClick.listen(
        (Event event) => tabSelected()
    );

    // ------------------------------------------------------
    // Emitters loaded panel
    // ------------------------------------------------------
    _lifePanel = new LifePanel(this);
    _lifePanel.init();

    _emitterControlPanel = new EmitterControlPanel(this);
    _emitterControlPanel.init();

    _emissionRateControlPanel = new EmissionRatePanel(this);
    _emissionRateControlPanel.init();

    _speedPanel = new SpeedPanel(this);
    _speedPanel.init();

    _accelerationPanel = new AccelerationPanel(this);
    _accelerationPanel.init();

    _startScalePanel = new StartScalePanel(this);
    _startScalePanel.init();

    _endScalePanel = new EndScalePanel(this);
    _endScalePanel.init();

    _rotationRatePanel = new RotationRatePanel(this);
    _rotationRatePanel.init();

    _delayPanel = new DelayPanel(this);
    _delayPanel.init();

    _durationPanel = new DurationPanel(this);
    _durationPanel.init();

    _tintPanel = new TintPanel(this);
    _tintPanel.init();

    _generalPanel = new GeneralPanel(this);
    _generalPanel.init();
    // Use the default emitter to add Sync items. They will eventually
    // be configured once an emitter is selected.
    Emitter e = modelController.defaultEmitter;
    //e.general.forEach((String k, bool v) => _generalPanel.addItem(k));
    _generalPanel.enableParticleDelayControl = _generalPanel.addItem("Enable Particle Delay");
    _generalPanel.enableParticleDelayControl.checkedTitle = "Click to disable particle delay.";
    _generalPanel.enableParticleDelayControl.unCheckedTitle = "Click to enable particle delay";

    _generalPanel.syncSpeedToScaleControl = _generalPanel.addItem("Divide Speed based on Scale");
    _generalPanel.syncSpeedToScaleControl.checkedTitle = "Click to disable speed to scale ratio";
    _generalPanel.syncSpeedToScaleControl.unCheckedTitle = "Click to enable speed to scale ratio";
  }
  
  void bind() {
    _tintPanel.bind();
    _bindOccurred = true;
  }
  
  void nowVisible () {
    bind();
  }
  
  void dataChanged(bool changedByUser) {
    // Propagate to all panels.
    _emitterControlPanel.dataChanged();
    _emissionRateControlPanel.dataChanged();
    _lifePanel.dataChanged();
    _speedPanel.dataChanged();
    _accelerationPanel.dataChanged();
    _startScalePanel.dataChanged();
    _endScalePanel.dataChanged();
    _rotationRatePanel.dataChanged();
    _delayPanel.dataChanged();
    _generalPanel.dataChanged();
    _durationPanel.dataChanged();
    _tintPanel.dataChanged(changedByUser);
  }
  
  void tabSelected() {
    _emitterPropertiesTabElement.style.display = "block";
    _emitterPropertiesElement.style.backgroundColor = "#aa3355";
    _emitterPropertiesElement.style.height = "25px";
    _emitterPropertiesElement.style.fontSize = "14px";
    _emitterPropertiesElement.style.paddingLeft = "15px";
    _emitterPropertiesElement.style.paddingRight = "15px";
    _tabChanged();
  }

  void hideTab() {
    _emitterPropertiesTabElement.style.display = "none";
    _emitterPropertiesElement.style.height = "20px";
    _emitterPropertiesElement.style.backgroundColor = "#aaaaaa";
    _emitterPropertiesElement.style.fontSize = "10px";
    _emitterPropertiesElement.style.paddingLeft = "5px";
    _emitterPropertiesElement.style.paddingRight = "5px";
  }
  
}