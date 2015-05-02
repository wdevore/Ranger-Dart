part of ranger;

typedef MouseEventHandler(Html.MouseEvent event);
typedef WheelEventHandler(Html.WheelEvent event);

/** 
 * [MouseInputMixin] is a mixin for mouse streams.
 * Mix with a [Node] that you want mouse behavior.
 */
abstract class MouseInputMixin {
  bool _mouseEnabled = false;

  StreamSubscription<Html.MouseEvent> _mouseDownSubscription;
  StreamSubscription<Html.MouseEvent> _mouseMouseMoveSubscription;
  StreamSubscription<Html.MouseEvent> _mouseMouseUpSubscription;
  StreamSubscription<Html.MouseEvent> _mouseMouseWheelSubscription;
  
  bool get mouseEnabled => _mouseEnabled;
  set enableMouse(bool v) => _mouseEnabled = v;

  void bindMouseEvents() {
    bindMouseDownEvents(onMouseDown);
    bindMouseMoveEvents(onMouseMove);
    bindMouseUpEvents(onMouseUp);
    bindMouseWheelEvents(onMouseWheel);
  }
  
  bool onMouseDown(Html.MouseEvent event) { return false; }
  bool onMouseMove(Html.MouseEvent event) { return false; }
  bool onMouseUp(Html.MouseEvent event) { return false; }
  bool onMouseWheel(Html.WheelEvent event) { return false; }

  StreamSubscription<Html.MouseEvent> bindMouseDownEvents(MouseEventHandler handler) {
    _mouseDownSubscription = Application.instance.window.onMouseDown.listen(handler);
    return _mouseDownSubscription;
  }
  
  StreamSubscription<Html.MouseEvent> bindMouseMoveEvents(MouseEventHandler handler) {
    _mouseMouseMoveSubscription = Application.instance.window.onMouseMove.listen(handler);
    return _mouseMouseMoveSubscription;
  }
  
  StreamSubscription<Html.MouseEvent> bindMouseUpEvents(MouseEventHandler handler) {
    _mouseMouseUpSubscription = Application.instance.window.onMouseUp.listen(handler);
    return _mouseMouseUpSubscription;
  }
  
  StreamSubscription<Html.MouseEvent> bindMouseWheelEvents(WheelEventHandler handler) {
    _mouseMouseWheelSubscription = Application.instance.window.onMouseWheel.listen(handler);
    return _mouseMouseWheelSubscription;
  }
  
  void unbindMouseEvents() {
    if (_mouseDownSubscription != null)
      _mouseDownSubscription.cancel();
    if (_mouseMouseMoveSubscription != null)
      _mouseMouseMoveSubscription.cancel();
    if (_mouseMouseUpSubscription != null)
      _mouseMouseUpSubscription.cancel();
    if (_mouseMouseWheelSubscription != null)
      _mouseMouseWheelSubscription.cancel();
  }
  
  set pauseMouseInputEvents(bool pauseResume) {
    _pauseResumeMouseStreamSubscription(_mouseDownSubscription, pauseResume);
    _pauseResumeMouseStreamSubscription(_mouseMouseMoveSubscription, pauseResume);
    _pauseResumeMouseStreamSubscription(_mouseMouseUpSubscription, pauseResume);
    _pauseResumeMouseStreamSubscription(_mouseMouseWheelSubscription, pauseResume);
  }

  void _pauseResumeMouseStreamSubscription(StreamSubscription stream, bool pauseResume) {
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
