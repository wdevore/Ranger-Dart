library speed_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
  */
class SpeedPanel {
  EmitterPropertiesTab _containerTab;

  InputElement _speedMin;
  InputElement _speedMax;
  InputElement _speedVariance;
  
  ImageElement _refreshIcon;
  
  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;
  
  SpeedPanel(this._containerTab);
  
  void init() {
    _speedMin = querySelector("#speedMin");
    _speedMax = querySelector("#speedMax");
    _speedVariance = querySelector("#speedVariance");
    
    _refreshIcon = querySelector("#panelSpeedRefresh");
    _refreshIcon.onClick.listen(
        (Event event) => _refresh()
    );
    
    _meanSlider = querySelector("#speedMeanSliderId");
    _meanSlider.onMouseDown.listen((Event event) => _sliderBeingDragged = true);
    _meanSlider.onMouseMove.listen(
        (Event event) => _sliderDragged()
    );
    _meanSlider.onClick.listen(
        (Event event) => _sliderClicked()
    );
    _meanSlider.onMouseUp.listen((Event event) => _sliderBeingDragged = false);
  }
  
  set minSpeed(num v) => _speedMin.value = v.toString();
  set maxSpeed(num v) => _speedMax.value = v.toString();
  set varianceSpeed(num v) => _speedVariance.value = v.toString();
  set meanSpeed(num v) => _meanSlider.value = v.toString();
  
  void _sliderDragged() {
    if (_sliderBeingDragged) {
      _sliderClicked();
    }
  }
  
  void _sliderClicked() {
    _containerTab.modelController.activeMap.meanSpeed = int.parse(_meanSlider.value);
    _controlPanelChanged();
  }
  
  void dataChanged() {
    minSpeed = _containerTab.modelController.activeMap.minSpeed;
    maxSpeed = _containerTab.modelController.activeMap.maxSpeed;
    varianceSpeed = _containerTab.modelController.activeMap.varianceSpeed;
    meanSpeed = _containerTab.modelController.activeMap.meanSpeed;
  }
  
  void _refresh() {
    _containerTab.modelController.activeMap.minSpeed = double.parse(_speedMin.value);
    _containerTab.modelController.activeMap.maxSpeed = double.parse(_speedMax.value);
    _containerTab.modelController.activeMap.varianceSpeed = double.parse(_speedVariance.value);
    _containerTab.modelController.activeMap.meanSpeed = int.parse(_meanSlider.value);
    
    _controlPanelChanged();
  }
  
  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}