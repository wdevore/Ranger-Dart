part of unittests;

/**
* base modal dialog class.
*/
abstract class BaseModalDialog {
  final DivElement _content;
  final DivElement _blackOverlay;
  bool isShowing = false;
  bool isTransitioningIn = true;
  
  BaseModalDialog() :
    _content = new DivElement(),
    _blackOverlay = new DivElement()
  {
    _content.id = "modalContent";
    
    _blackOverlay.id = "modalOverlay";
  }

  DivElement get content => _content;
  DivElement get blackOverlay => _blackOverlay;
  
  void hide();

  void show();

}

