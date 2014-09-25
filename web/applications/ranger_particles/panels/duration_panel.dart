library duration_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';
import '../controls/checkbox_control.dart';
import '../resources/resources.dart';
import '../controls/icon_button_control.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * __ Continuous, [Fire]
   __ Duration ________, Pause ________
   Chart control
 * 
  */
class DurationPanel {
  EmitterPropertiesTab _containerTab;

  CheckBoxControl _continuousEnabledControl;
  CheckBoxControl _durationEnabledControl;
  InputElement _duration;
  InputElement _pauseFor;
  
  IconButtonControl _fireParticleButton;
  IconButtonControl _explodeButton;
  
  ImageElement _refreshIcon;
  DivElement _container;
  
  DurationPanel(this._containerTab);
  
  void init() {
    _container = querySelector("#durationContainerId");
    
    _refreshIcon = querySelector("#panelDurationRefresh");
    _refreshIcon.onClick.listen((Event event) => _refresh());

    DivElement row = new DivElement();
    row.classes.add("general_row_item");

    Resources resources = _containerTab.modelController.resources;
    
    _continuousEnabledControl = new CheckBoxControl(false, row, resources.checkedSquareIcon, resources.uncheckedSquareIcon, _checkBoxChanged, "Continuous");
    
    LabelElement name = new LabelElement();
    name.classes.add("panel_label panel_control_text");
    name.text = "Continuous";
    row.nodes.add(name);
    
    _fireParticleButton = new IconButtonControl(false, row, resources.pulseIcon, resources.pulseIconDisabled, _fireParticle);
    _fireParticleButton.enableTitle = "Click to fire a particle manually.";
    _fireParticleButton.disabledTitle = "Disable Continuous and Duration in order to fire a particle manually.";

    _explodeButton = new IconButtonControl(true, row, resources.explodeIcon, resources.explodeIcon, _explode);
    _explodeButton.enableTitle = "Click to trigger an explosion.";

    _container.nodes.add(row);

    // Next Row
    row = new DivElement();
    row.classes.add("general_row_item");
    _durationEnabledControl = new CheckBoxControl(false, row, resources.checkedSquareIcon, resources.uncheckedSquareIcon, _checkBoxChanged, "Duration");
    
    name = new LabelElement();
    name.classes.add("panel_label panel_control_text");
    name.text = "Duration:";
    row.nodes.add(name);
    
    _duration = new InputElement();
    _duration.classes.add("panel_input_text");
    row.nodes.add(_duration);
    
    name = new LabelElement();
    name.classes.add("panel_label panel_control_text");
    name.text = "Pause for:";
    row.nodes.add(name);

    _pauseFor = new InputElement();
    _pauseFor.classes.add("panel_input_text");
    row.nodes.add(_pauseFor);

    _container.nodes.add(row);
    
  }
  
  set continuousEnabled(bool v) => _continuousEnabledControl.setCheckWith = v;
  set durationEnabled(bool v) => _durationEnabledControl.setCheckWith = v;
  
  set duration(num v) => _duration.value = v.toString();
  int get duration => int.parse(_duration.value);
  
  set pauseFor(num v) => _pauseFor.value = v.toString();
  int get pauseFor => int.parse(_pauseFor.value);
  
  void _fireParticle(IconButtonControl button) {
    _containerTab.modelController.fireParticle();
  }
  
  void _explode(IconButtonControl button) {
    _containerTab.modelController.explode();
  }
  
  void _checkBoxChanged(CheckBoxControl checkbox, String data) {
    if (data == "Continuous") {
      if (_continuousEnabledControl.isChecked && _durationEnabledControl.isChecked) {
        durationEnabled = _containerTab.modelController.activeMap.durationEnabled = false;
      }
      _containerTab.modelController.activeMap.continuousEnabled = _continuousEnabledControl.isChecked;
    }
    else if (data == "Duration") {
      if (_durationEnabledControl.isChecked && _continuousEnabledControl.isChecked)
        continuousEnabled = _containerTab.modelController.activeMap.continuousEnabled = false;
      _containerTab.modelController.activeMap.durationEnabled = _durationEnabledControl.isChecked;
    }

    // Has fields changed prior to checking box.
    if (_containerTab.modelController.activeMap.pauseFor != pauseFor ||
        _containerTab.modelController.activeMap.emitterDuration != duration)
      _refresh();

    if (!_containerTab.modelController.activeMap.continuousEnabled &&
        !_containerTab.modelController.activeMap.durationEnabled) {
      _fireParticleButton.setEnabled();
    }
    else {
      _fireParticleButton.setDisabled();
    }
    
    _controlPanelChanged();
  }
  
  void dataChanged() {
    continuousEnabled = _containerTab.modelController.activeMap.continuousEnabled;
    durationEnabled = _containerTab.modelController.activeMap.durationEnabled;
    duration = _containerTab.modelController.activeMap.emitterDuration;
    pauseFor = _containerTab.modelController.activeMap.pauseFor;
  }
  
  void _refresh() {
    _containerTab.modelController.activeMap.emitterDuration = duration;
    _containerTab.modelController.activeMap.pauseFor = pauseFor;
    
    _controlPanelChanged();
  }
  
  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}