part of ranger;

typedef TouchEventHandler(Html.TouchEvent event);

/** 
 * [TouchInputMixin] is a mixin for touch streams.
 * Mix with a [Node] that you want touch behavior.
 */
abstract class TouchInputMixin {
  bool _touchEnabled = false;

  bool get touchEnabled => _touchEnabled;
  set enableTouch(bool v) => _touchEnabled = v;
  
  void bindTouchEvents() {
    bindTouchStartEvents(onTouchStart);
    bindTouchMoveEvents(onTouchMove);
    bindTouchEndEvents(onTouchEnd);
    bindTouchCancelEvents(onTouchCancel);
  }
  
  bool onTouchStart(Html.TouchEvent event) { return false; }
  bool onTouchMove(Html.TouchEvent event) { return false; }
  bool onTouchEnd(Html.TouchEvent event) { return false; }
  bool onTouchCancel(Html.TouchEvent event) { return false; }

  StreamSubscription<Html.TouchEvent> _touchStartSubscription;
  StreamSubscription<Html.TouchEvent> _touchMoveSubscription;
  StreamSubscription<Html.TouchEvent> _touchEndSubscription;
  StreamSubscription<Html.TouchEvent> _touchCancelSubscription;

  StreamSubscription<Html.TouchEvent> bindTouchStartEvents(TouchEventHandler handler) {
    _touchStartSubscription = Application.instance.window.onTouchStart.listen(handler);
    return _touchStartSubscription;
  }
  
  StreamSubscription<Html.TouchEvent> bindTouchMoveEvents(TouchEventHandler handler) {
    _touchMoveSubscription = Application.instance.window.onTouchMove.listen(handler);
    return _touchMoveSubscription;
  }
  
  StreamSubscription<Html.TouchEvent> bindTouchEndEvents(TouchEventHandler handler) {
    _touchEndSubscription = Application.instance.window.onTouchEnd.listen(handler);
    return _touchEndSubscription;
  }
  
  StreamSubscription<Html.TouchEvent> bindTouchCancelEvents(TouchEventHandler handler) {
    _touchCancelSubscription = Application.instance.window.onTouchCancel.listen(handler);
    return _touchCancelSubscription;
  }
  
  void unbindTouchEvents() {
    if (_touchStartSubscription != null)
      _touchStartSubscription.cancel();
    if (_touchMoveSubscription != null)
      _touchMoveSubscription.cancel();
    if (_touchEndSubscription != null)
      _touchEndSubscription.cancel();
    if (_touchCancelSubscription != null)
      _touchCancelSubscription.cancel();
  }
  
  set pauseMouseInputEvents(bool pauseResume) {
    _pauseResumeTouchStreamSubscription(_touchStartSubscription, pauseResume);
    _pauseResumeTouchStreamSubscription(_touchMoveSubscription, pauseResume);
    _pauseResumeTouchStreamSubscription(_touchEndSubscription, pauseResume);
    _pauseResumeTouchStreamSubscription(_touchCancelSubscription, pauseResume);
  }

  void _pauseResumeTouchStreamSubscription(StreamSubscription stream, bool pauseResume) {
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
