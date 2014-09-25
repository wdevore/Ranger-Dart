library end_scale_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
  */
class EndScalePanel {
  EmitterPropertiesTab _containerTab;

  InputElement _min;
  InputElement _max;
  InputElement _variance;
  ImageElement _refreshIcon;

  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;

  EndScalePanel(this._containerTab);

  void init() {
    _min = querySelector("#endScaleMin");
    _max = querySelector("#endScaleMax");
    _variance = querySelector("#endScaleVariance");

    _refreshIcon = querySelector("#panelEndScaleRefresh");
    _refreshIcon.onClick.listen((Event event) => _refresh());

    _meanSlider = querySelector("#endScaleMeanSliderId");
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
    _containerTab.modelController.activeMap.meanEndScale = int.parse(_meanSlider.value);
    _controlPanelChanged();
  }

  void dataChanged() {
    min = _containerTab.modelController.activeMap.minEndScale;
    max = _containerTab.modelController.activeMap.maxEndScale;
    variance = _containerTab.modelController.activeMap.varianceEndScale;
    mean = _containerTab.modelController.activeMap.meanEndScale;
  }

  void _refresh() {
    _containerTab.modelController.activeMap.minEndScale = double.parse(_min.value);
    _containerTab.modelController.activeMap.maxEndScale = double.parse(_max.value);
    _containerTab.modelController.activeMap.varianceEndScale = double.parse(_variance.value);
    _containerTab.modelController.activeMap.meanEndScale = int.parse(_meanSlider.value);

    _controlPanelChanged();
  }

  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}
