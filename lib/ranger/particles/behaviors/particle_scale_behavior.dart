part of ranger;

/** 
 * [ParticleScaleBehavior] is a mixin.
 * Mix with a [BaseNode] that you want absolute Scaling [Animation]s applied to.
 */
abstract class ParticleScaleBehavior {
  double fromScale = 1.0;
  double toScale = 1.0;
  double scale = 1.0;
  
  void initWithScale(double from, double to) {
    fromScale = from;
    toScale = to;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------

  void stepScaleBehavior(double time) {
    scale = fromScale + (toScale - fromScale) * time;
  }

}

