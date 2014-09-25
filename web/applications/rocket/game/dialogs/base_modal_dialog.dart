library base_modal_dialog;

import 'dart:html';

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
    
    window.onAnimationEnd.listen(
        (AnimationEvent e) => _animationEnd(e)
        );
    
    _blackOverlay.id = "modalOverlay";
  }

  DivElement get content => _content;
  DivElement get blackOverlay => _blackOverlay;
  
  void _animationEnd(AnimationEvent ae);
  
  void hide();

  void show();

}

