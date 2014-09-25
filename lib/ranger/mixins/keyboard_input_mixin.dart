part of ranger;

typedef KeyboardEventHandler(Html.KeyboardEvent event);

/** 
 * [KeyboardInputMixin] is a mixin for keyboard streams.
 * Mix with a [Node] that you want keyboard behavior. [Layer]s typically
 * do this for you.
 */
abstract class KeyboardInputMixin {
  bool _keyboardEnabled = false;

  bool get keyboardEnabled => _keyboardEnabled;
  set enableKeyboard(bool v) => _keyboardEnabled = v;
  
  void bindKeyboardEvents() {
    bindKeyPressEvents(onKeyPress);
    bindKeyDownEvents(onKeyDown);
    bindKeyUpEvents(onKeyUp);
  }
  
  bool onKeyDown(Html.KeyboardEvent event) { return false; }
  bool onKeyUp(Html.KeyboardEvent event) { return false; }
  bool onKeyPress(Html.KeyboardEvent event) { return false; }

  StreamSubscription<Html.KeyboardEvent> _keyDownSubscription;
  StreamSubscription<Html.KeyboardEvent> _keyUpSubscription;
  StreamSubscription<Html.KeyboardEvent> _keyPressSubscription;
  
  StreamSubscription<Html.KeyboardEvent> bindKeyDownEvents(KeyboardEventHandler handler) {
    _keyDownSubscription = Application.instance.window.onKeyDown.listen(handler);
    return _keyDownSubscription;
    // KeyboardEventStream is new to Dart >= 1.5.8
    //return Html.KeyboardEventStream.onKeyDown(canvas).listen(handler);
  }
  
  StreamSubscription<Html.KeyboardEvent> bindKeyUpEvents(KeyboardEventHandler handler) {
    _keyUpSubscription = Application.instance.window.onKeyUp.listen(handler);
    return _keyUpSubscription;
  }
  
  StreamSubscription<Html.KeyboardEvent> bindKeyPressEvents(KeyboardEventHandler handler) {
    _keyPressSubscription = Application.instance.window.onKeyPress.listen(handler);
    return _keyPressSubscription;
  }

  void unbindKeyboardEvents() {
    if (_keyDownSubscription != null)
      _keyDownSubscription.cancel();
    if (_keyUpSubscription != null)
      _keyUpSubscription.cancel();
    if (_keyPressSubscription != null)
      _keyPressSubscription.cancel();
  }
  
  set pauseKeyboardInputEvents(bool pauseResume) {
    _pauseResumeKeyboardStreamSubscription(_keyDownSubscription, pauseResume);
    _pauseResumeKeyboardStreamSubscription(_keyUpSubscription, pauseResume);
    _pauseResumeKeyboardStreamSubscription(_keyPressSubscription, pauseResume);
  }

  void _pauseResumeKeyboardStreamSubscription(StreamSubscription stream, bool pauseResume) {
    if (stream != null)
      if (pauseResume) {
        if (stream.isPaused)
          stream.resume();
      }
      else {
        if (!stream.isPaused)
          stream.pause();
      }
  }
}
