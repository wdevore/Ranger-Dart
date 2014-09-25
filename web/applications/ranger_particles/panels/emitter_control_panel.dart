library emitter_control_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';

/*
 * This panel is parked on the "emitter properties" tab.
  */
class EmitterControlPanel {
  EmitterPropertiesTab _containerTab;
  
  InputElement _emitterControlVariance;
  InputElement _emitterControlAngle;
  InputElement _sweepRate;
  SelectElement _emissionTypeElement;

  ImageElement _refreshIcon;
  
  int emissionType = 0;
  
  EmitterControlPanel(this._containerTab);
  
  void init() {
    _emitterControlVariance = querySelector("#emitterControlVariance");
    _emitterControlAngle = querySelector("#emitterControlAngle");
    _sweepRate = querySelector("#radialSweepRate");
    
    _emissionTypeElement = querySelector("#emissionType");
    _emissionTypeElement.onChange.listen(
        (Event event) => _changeEmissionType()
    );

    _refreshIcon = querySelector("#panelEmitterRefresh");
    _refreshIcon.onClick.listen(
        (Event event) => _refresh()
    );
  }
  
  set variance(num v) => _emitterControlVariance.value = v.toString();
  set angle(num v) => _emitterControlAngle.value = v.toString();
  set sweepRate(num v) => _sweepRate.value = v.toString();
  set emissionControlType(int i) => _emissionTypeElement.selectedIndex = i;
  
  void dataChanged() {
    variance = _containerTab.modelController.activeMap.variance;
    angle = _containerTab.modelController.activeMap.angle;
    sweepRate = _containerTab.modelController.activeMap.sweepRate;
    emissionControlType = _containerTab.modelController.emitterTypeAsIndex;
  }
  
  void _refresh() {
    _containerTab.modelController.activeMap.variance = double.parse(_emitterControlVariance.value);
    _containerTab.modelController.activeMap.angle = double.parse(_emitterControlAngle.value);
    _containerTab.modelController.activeMap.sweepRate = double.parse(_sweepRate.value);
    
    _controlPanelChanged();
  }
  
  void _changeEmissionType() {
    _containerTab.modelController.emitterTypeByIndex = int.parse(_emissionTypeElement.value);
    _controlPanelChanged();
  }

  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }
}