library life_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * Min, Max, Variance
 * 
 * TODO add a Chart-control. This allows the life span to be controlled
 * by a sequence of values over the unit-lifespan.
  */
class LifePanel {
  EmitterPropertiesTab _containerTab;

  InputElement _lifeMin;
  InputElement _lifeMax;
  InputElement _lifeVariance;
  ImageElement _refreshIcon;
  
  RangeInputElement _meanSlider;
  bool _sliderBeingDragged = false;

  LifePanel(this._containerTab);
  
  void init() {
    _lifeMin = querySelector("#lifeMin");
    _lifeMax = querySelector("#lifeMax");
    _lifeVariance = querySelector("#lifeVariance");
    
    _refreshIcon = querySelector("#panelLifeRefresh");
    _refreshIcon.onClick.listen(
        (Event event) => _refresh()
    );
    
    _meanSlider = querySelector("#lifeMeanSliderId");
    _meanSlider.onMouseDown.listen((Event event) => _sliderBeingDragged = true);
    _meanSlider.onMouseMove.listen(
        (Event event) => _sliderDragged()
    );
    _meanSlider.onClick.listen(
        (Event event) => _sliderClicked()
    );
    _meanSlider.onMouseUp.listen((Event event) => _sliderBeingDragged = false);

  }
  
  set minLife(num v) => _lifeMin.value = v.toString();
  set maxLife(num v) => _lifeMax.value = v.toString();
  set varianceLife(num v) => _lifeVariance.value = v.toString();
  set meanLife(num v) => _meanSlider.value = v.toString();

  void _sliderDragged() {
    if (_sliderBeingDragged) {
      _sliderClicked();
    }
  }
  
  void _sliderClicked() {
    _containerTab.modelController.activeMap.meanLife = int.parse(_meanSlider.value);
    _controlPanelChanged();
  }

  void dataChanged() {
    minLife = _containerTab.modelController.activeMap.minLife;
    maxLife = _containerTab.modelController.activeMap.maxLife;
    varianceLife = _containerTab.modelController.activeMap.varianceLife;
    meanLife = _containerTab.modelController.activeMap.meanLife;
  }
  
  void _refresh() {
    _containerTab.modelController.activeMap.minLife = double.parse(_lifeMin.value);
    _containerTab.modelController.activeMap.maxLife = double.parse(_lifeMax.value);
    _containerTab.modelController.activeMap.varianceLife = double.parse(_lifeVariance.value);
    _containerTab.modelController.activeMap.meanLife = int.parse(_meanSlider.value);

    _controlPanelChanged();
  }
  
  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}