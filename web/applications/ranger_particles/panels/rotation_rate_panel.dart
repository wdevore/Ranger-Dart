library rotation_rate_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
  */
class RotationRatePanel {
  EmitterPropertiesTab _containerTab;

  InputElement _rotationRateMin;
  InputElement _rotationRateMax;
  InputElement _rotationRateVariance;
  ImageElement _refreshIcon;

  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;

  RotationRatePanel(this._containerTab);

  void init() {
    _rotationRateMin = querySelector("#rotationRateMin");
    _rotationRateMax = querySelector("#rotationRateMax");
    _rotationRateVariance = querySelector("#rotationRateVariance");

    _refreshIcon = querySelector("#panelRotationRateRefresh");
    _refreshIcon.onClick.listen((Event event) => _refresh());

    _meanSlider = querySelector("#rotationRateMeanSliderId");
    _meanSlider.onMouseDown.listen((Event event) => _sliderBeingDragged = true);
    _meanSlider.onMouseMove.listen(
        (Event event) => _sliderDragged()
    );
    _meanSlider.onClick.listen(
        (Event event) => _sliderClicked()
    );
    _meanSlider.onMouseUp.listen((Event event) => _sliderBeingDragged = false);
  }

  set minRotationRateScale(num v) => _rotationRateMin.value = v.toString();
  set maxRotationRate(num v) => _rotationRateMax.value = v.toString();
  set varianceRotationRate(num v) => _rotationRateVariance.value = v.toString();
  set meanRotationRate(num v) => _meanSlider.value = v.toString();

  void _sliderDragged() {
    if (_sliderBeingDragged) {
      _sliderClicked();
    }
  }
  
  void _sliderClicked() {
    _containerTab.modelController.activeMap.meanRotationRate = int.parse(_meanSlider.value);
    _controlPanelChanged();
  }

  void dataChanged() {
    minRotationRateScale = _containerTab.modelController.activeMap.minRotationRate;
    maxRotationRate = _containerTab.modelController.activeMap.maxRotationRate;
    varianceRotationRate = _containerTab.modelController.activeMap.varianceRotationRate;
    meanRotationRate = _containerTab.modelController.activeMap.meanRotationRate;
  }

  void _refresh() {
    _containerTab.modelController.activeMap.minRotationRate = double.parse(_rotationRateMin.value);
    _containerTab.modelController.activeMap.maxRotationRate = double.parse(_rotationRateMax.value);
    _containerTab.modelController.activeMap.varianceRotationRate = double.parse(_rotationRateVariance.value);
    _containerTab.modelController.activeMap.meanRotationRate = int.parse(_meanSlider.value);

    _controlPanelChanged();
  }

  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}
