library checkbox_control;

import 'dart:html';

class CheckBoxControl {
  ImageElement _checkedIcon;
  ImageElement _uncheckedIcon;
  Function _changedCallback;
  bool _checked = false;
  
  String map;
  Object _data;
  String title;
  
  CheckBoxControl(bool checked, HtmlElement parent, ImageElement checkedIcon, ImageElement uncheckedIcon, [Function changedCallback = null, Object data = null]) {
    _changedCallback = changedCallback;
    _data = data;
    this.title = data as String;
    
    _checked = checked;
    
    _checkedIcon = checkedIcon.clone(false);
    _checkedIcon.classes.add("checkbox_svg_icon");
    _checkedIcon.title = "Click to deactivate this particle system.";
    
    _uncheckedIcon = uncheckedIcon.clone(false);
    _uncheckedIcon.classes.add("checkbox_svg_icon");
    _uncheckedIcon.title = "Click to activate this particle system.";
    
    _checkedIcon.onClick.listen((event) {
      _clickedCheckedIcon();
    });
    
    _uncheckedIcon.onClick.listen((event) {
      _clickedUnCheckedIcon();
    });
    
    if (_checked)
      _uncheckedIcon.style.display = "none";
    else
      _checkedIcon.style.display = "none";
      
    parent.nodes.add(_checkedIcon);
    parent.nodes.add(_uncheckedIcon);
  }

  get isChecked => _checked;
  set setCheckWith(bool v) => v ? setChecked() : setUnChecked();
  
  set checkedTitle(String t) => _checkedIcon.title = t;
  set unCheckedTitle(String t) => _uncheckedIcon.title = t;
  
  void _clickedCheckedIcon() {
    // They clicked the "checked" icon. So hide it and show the "unchecked" icon.
    setUnChecked();
    if (_changedCallback != null)
      _changedCallback(this, _data);
  }

  void setChecked() {
    _checkedIcon.style.display = "inline-block";
    _uncheckedIcon.style.display = "none";
    _checked = true;
  }

  void _clickedUnCheckedIcon() {
    // They clicked the "unchecked" icon. So hide it and show the "checked" icon.
    setChecked();
    if (_changedCallback != null)
      _changedCallback(this, _data);
  }

  void setUnChecked() {
    _checkedIcon.style.display = "none";
    _uncheckedIcon.style.display = "inline-block";
    _checked = false;
  }
}