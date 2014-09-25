library sync_panel;

import 'dart:html';

import 'emitter_properties_tab.dart';
import '../controls/checkbox_control.dart';
import '../resources/resources.dart';

/*
 * This panel is parked on the "emitter properties" tab.
 * It contains checkboxes.
 * This panel loads based on a list on items. Each item is a checkbox.
 * 
  */
class GeneralPanel {
  Map _selectedMap;
  EmitterPropertiesTab _containerTab;

  DivElement _checkBoxContainer;
  ImageElement _refreshIcon;

  CheckBoxControl syncSpeedToScaleControl;
  CheckBoxControl enableParticleDelayControl;
  
  GeneralPanel(this._containerTab);

  void init() {
    _checkBoxContainer = querySelector("#generalCheckboxesId");

    _refreshIcon = querySelector("#panelGeneralRefresh");
    _refreshIcon.onClick.listen((Event event) => _refresh());
  }

  set selectedMap(Map m) => _selectedMap = m;

  CheckBoxControl addItem(String title) {
    // Add an svg image checkbox followed by a label.
    DivElement row = new DivElement();
    row.classes.add("general_row_item");

    Resources resources = _containerTab.modelController.resources;
    
    CheckBoxControl checkbox = new CheckBoxControl(false, row, resources.checkedSquareIcon, resources.uncheckedSquareIcon, _checkBoxChanged, title);
    
    LabelElement name = new LabelElement();
    name.classes.add("panel_label panel_control_text");
    name.text = title;
    row.nodes.add(name);

    _checkBoxContainer.nodes.add(row);
    
    return checkbox;
  }
  
  set syncSpeedToScale(bool v) => syncSpeedToScaleControl.setCheckWith = v;
  set enableParticleDelay(bool v) => enableParticleDelayControl.setCheckWith = v;

  void _checkBoxChanged(CheckBoxControl checkbox, String data) {
    if (checkbox.title == "Divide Speed based on Scale") {
      _containerTab.modelController.activeMap.syncSpeedToScale = syncSpeedToScaleControl.isChecked;
    }
    else if (checkbox.title == "Enable Particle Delay") {
      _containerTab.modelController.activeMap.EnabledParticleDelay = enableParticleDelayControl.isChecked;
    }
    
    _controlPanelChanged();
  }

  void dataChanged() {
    syncSpeedToScale = _containerTab.modelController.activeMap.syncSpeedToScale;
    enableParticleDelay = _containerTab.modelController.activeMap.EnabledParticleDelay;
  }

  void _refresh() {
    _containerTab.modelController.activeMap.syncSpeedToScale = syncSpeedToScaleControl.isChecked;
    _containerTab.modelController.activeMap.EnabledParticleDelay = enableParticleDelayControl.isChecked;

    _controlPanelChanged();
  }

  void _controlPanelChanged() {
    _containerTab.modelController.dataChanged();
  }

}
