library emission_rate_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';
import '../data/emitter.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
  */
class EmissionRatePanel {
  EmitterPropertiesTab _containerTab;

  InputElement _min;
  InputElement _max;
  InputElement _variance;
  
  ImageElement _refreshIcon;
  
  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;
  
  EmissionRatePanel(this._containerTab);
  
  void init() {
    _min = querySelector("#emissionRateMin");
    _max = querySelector("#emissionRateMax");
    _variance = querySelector("#emissionRateVariance");
    
    _refreshIcon = querySelector("#panelEmissionRateRefresh");
    _refreshIcon.onClick.listen(
        (Event event) => _refresh()
    );
    
    _meanSlider = querySelector("#emissionRateMeanSliderId");
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
    Emitter e = _containerTab.modelController.activeMap;
    e.meanEmissionRate = int.parse(_meanSlider.value);
    e.emissionRate = _calcRate(e.minEmissionRate, e.maxEmissionRate, e.meanEmissionRate);
    _controlPanelChanged();
  }
  
  void dataChanged() {
    Emitter e = _containerTab.modelController.activeMap;
    min = e.minEmissionRate;
    max = e.maxEmissionRate;
    variance = e.varianceEmissionRate;
    mean = _calcMean(e.minEmissionRate, e.maxEmissionRate, e.emissionRate);
  }
  
  void _refresh() {
    Emitter e = _containerTab.modelController.activeMap;
    e.minEmissionRate = int.parse(_min.value);
    e.maxEmissionRate = int.parse(_max.value);
    e.varianceEmissionRate = int.parse(_variance.value);
    e.meanEmissionRate = int.parse(_meanSlider.value);
    e.emissionRate = _calcRate(e.minEmissionRate, e.maxEmissionRate, e.meanEmissionRate);
    _controlPanelChanged();
  }
  
  int _calcMean(int min, int max, int rate) {
    return ((rate - min) / (max - min) * 100.0).toInt();
  }
  
  int _calcRate(int min, int max, int mean) {
    return (min + (max - min) * (mean/100.0)).toInt();
  }
  
  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}