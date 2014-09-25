library start_scale_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
  */
class StartScalePanel {
  EmitterPropertiesTab _containerTab;

  InputElement _min;
  InputElement _max;
  InputElement _variance;
  ImageElement _refreshIcon;

  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;

  StartScalePanel(this._containerTab);

  void init() {
    _min = querySelector("#startScaleMin");
    _max = querySelector("#startScaleMax");
    _variance = querySelector("#startScaleVariance");

    _refreshIcon = querySelector("#panelStartScaleRefresh");
    _refreshIcon.onClick.listen((Event event) => _refresh());

    _meanSlider = querySelector("#startScaleMeanSliderId");
    _meanSlider.onMouseDown.listen((Event event) => _sliderBeingDragged = true);
    _meanSlider.onMouseMove.listen(
        (Event event) => _sliderDragged()
    );
    _meanSlider.onClick.listen(
        (Event event) => _sliderClicked()
    );
    _meanSlider.onMouseUp.listen((Event event) => _sliderBeingDragged = false);
  }

  set min(num v) => _min.value = v.toString();
  set max(num v) => _max.value = v.toString();
  set variance(num v) => _variance.value = v.toString();
  set mean(num v) => _meanSlider.value = v.toString();

  void _sliderDragged() {
    if (_sliderBeingDragged) {
      _sliderClicked();
    }
  }
  
  void _sliderClicked() {
    _containerTab.modelController.activeMap.meanStartScale = int.parse(_meanSlider.value);
    _controlPanelChanged();
  }

  void dataChanged() {
    min = _containerTab.modelController.activeMap.minStartScale;
    max = _containerTab.modelController.activeMap.maxStartScale;
    variance = _containerTab.modelController.activeMap.varianceStartScale;
    mean = _containerTab.modelController.activeMap.meanStartScale;
  }

  void _refresh() {
    _containerTab.modelController.activeMap.minStartScale = double.parse(_min.value);
    _containerTab.modelController.activeMap.maxStartScale = double.parse(_max.value);
    _containerTab.modelController.activeMap.varianceStartScale = double.parse(_variance.value);
    _containerTab.modelController.activeMap.meanStartScale = int.parse(_meanSlider.value);

    _controlPanelChanged();
  }

  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}
