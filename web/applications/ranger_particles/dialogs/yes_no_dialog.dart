library yes_no_modal_dialog;

import 'dart:html';

/**
* Generic dialog
*/
class YesNoDialog {
  final DivElement _content;
  final DivElement _blackOverlay;
  final ButtonElement _button;

  InputElement _name;
  Function _finishCallback;
  
  YesNoDialog(String message, Function finishCallback) :
    _content = new DivElement(),
    _blackOverlay = new DivElement(),
    _button = new ButtonElement()
  {
    _finishCallback = finishCallback;
    
    _content.id = "modalContent";
    _content.classes.add("modal_white_content");
    
    _blackOverlay.id = "modalOverlay";
    _blackOverlay.classes.add("modal_black_overlay");

    DivElement msgEle = new DivElement();
    msgEle.classes.add("modal_dialog_title");
    msgEle.innerHtml = message;
    _content.nodes.add(msgEle);

    DivElement buttons = new DivElement();
    buttons.classes.add("modal_dialog_button_group");

    _button.text = "Yes";
    _button.classes.add("modal_dialog_button");
    _button.onClick.listen((event) {
      _done();
    });
    buttons.nodes.add(_button);

    ButtonElement cancelButton = new ButtonElement();
    cancelButton.classes.add("modal_dialog_button");
    cancelButton.text = "No";
    cancelButton.onClick.listen((event) {
      _cancel();
    });
    buttons.nodes.add(cancelButton);

    _content.nodes.add(buttons);
  }

  void _done() {
    hide();
    _finishCallback("Yes");
  }
  
  void _cancel() {
    hide();
    _finishCallback("No");
  }
  
  //remove the modal dialog div's from the dom.
  hide() {
    //find the element and remove it.
    //there is no list.remove(x) statement at present,
    // so we have to do it manually.
    document.body.nodes.remove(_content);
    document.body.nodes.remove(_blackOverlay);
  }

  //add the modal dialog div's to the dom
  show() {
    document.body.nodes.add(_content);
    document.body.nodes.add(_blackOverlay);
  }

}

