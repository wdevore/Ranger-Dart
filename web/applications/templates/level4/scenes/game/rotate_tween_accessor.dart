library rotate_tween_accessor;

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;

/**
 * A very simple Tween accessor.
 */
class RotateAnimationAccessor extends UTE.TweenAccessor<Ranger.SpriteImage> {
  static const int ROTATE = 50;

  RotateAnimationAccessor();
  
  int getValues(Ranger.SpriteImage target, UTE.Tween tween, int tweenType, List<num> returnValues) {
    switch (tweenType) {
      case ROTATE:
        returnValues[0] = target.rotationInDegrees;
        return 1;
    }
    
    return 0;
  }
  
  void setValues(Ranger.SpriteImage target, UTE.Tween tween, int tweenType, List<num> newValues) {
    switch (tweenType) {
      case ROTATE:
        target.rotationByDegrees = newValues[0];
        target.dirty = true;
        break;
    }
  }
}