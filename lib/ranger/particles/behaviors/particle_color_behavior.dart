part of ranger;

/** 
 * [ParticleColorBehavior] is a simple Linear interpolator of a single
 * color value.
 * 
 * Mix with a [BaseNode] that you want Color tinting [Animation]s applied to.
 */
abstract class ParticleColorBehavior {
  Color4<int> fromColor = Color4IBlue;
  Color4<int> toColor = Color4IOrange;
  Color4<int> color = Color4IWhite;
  
  void initWithColor(Color4<int> from, Color4<int> to) {
    fromColor.setWith(from);
    toColor.setWith(to);
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------

  void stepColorBehavior(double time) {
    color.r = (fromColor.r + (toColor.r - fromColor.r) * time).toInt();
    color.g = (fromColor.g + (toColor.g - fromColor.g) * time).toInt();
    color.b = (fromColor.b + (toColor.b - fromColor.b) * time).toInt();
    color.a = (fromColor.a + (toColor.a - fromColor.a) * time).toInt();
  }

}

