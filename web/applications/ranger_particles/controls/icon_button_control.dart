library icon_button_control;

import 'dart:html';

class IconButtonControl {
  ImageElement _enabledIcon;
  ImageElement _disabledIcon;
  Function _changedCallback;
  bool _enabled = true;
  bool autoSwitchIcons = false;

  String map;

  IconButtonControl(bool enabled, HtmlElement parent, ImageElement enabledIcon, ImageElement disabledIcon, [Function changedCallback = null]) {
    _changedCallback = changedCallback;
    _enabled = enabled;
    
    _enabledIcon = enabledIcon.clone(false);
    _enabledIcon.classes.add("iconbutton_svg_icon");
    
    _disabledIcon = disabledIcon.clone(false);
    _disabledIcon.classes.add("iconbutton_svg_icon");
    
    _enabledIcon.onClick.listen((event) {
      _clickedEnabledIcon();
    });
    
    _disabledIcon.onClick.listen((event) {
      _clickedDisabledIcon();
    });
    
    if (_enabled)
      _disabledIcon.style.display = "none";
    else
      _enabledIcon.style.display = "none";
      
    parent.nodes.add(_enabledIcon);
    parent.nodes.add(_disabledIcon);
  }

  get isEnabled => _enabled;
  set enableTitle(String title) => _enabledIcon.title = title;
  set disabledTitle(String title) => _disabledIcon.title = title;
  
  void _clickedEnabledIcon() {
    // They clicked the "enabled" icon. So hide it and show the "disabled" icon.
    if (autoSwitchIcons)
      setDisabled();
    if (_changedCallback != null)
      _changedCallback(this);
  }

  void setEnabled() {
    _enabledIcon.style.display = "inline-block";
    _disabledIcon.style.display = "none";
    _enabled = true;
  }

  void _clickedDisabledIcon() {
    // They clicked the "disabled" icon. So hide it and show the "enabled" icon.
//    if (autoSwitchIcons)
//      setEnabled();
//    if (_changedCallback != null)
//      _changedCallback(this);
  }

  void setDisabled() {
    _enabledIcon.style.display = "none";
    _disabledIcon.style.display = "inline-block";
    _enabled = false;
  }
}