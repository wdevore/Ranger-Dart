library active_emitter_title_panel;

import 'dart:html';

import '../model_controller.dart';
import '../controls/icon_button_control.dart';
import '../resources/resources.dart';

/*
 * 
 */
class ActiveEmitterTitlePanel {
  ModelController _modelController;
  
  LabelElement _labelTitle;
  SpanElement _spanContainer;
  IconButtonControl _dirtyIcon;
  
  ActiveEmitterTitlePanel(this._modelController);
  
  void init() {
    _labelTitle = querySelector("#activeEmitterTitleNameId");
    _spanContainer = querySelector("#activeEmitterDirtyIconId");
    
    // Add the icons
    Resources res = _modelController.resources;
    _dirtyIcon = new IconButtonControl(false, _spanContainer, res.emitterDirtyIcon, res.emitterDirtyIconDisabled);
  }
  
  set title(String s) => _labelTitle.text = s;
  
  set dirty(bool flag) => flag ? _dirtyIcon.setEnabled() : _dirtyIcon.setDisabled();
}