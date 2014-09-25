part of ranger;

/** 
 * [ParticleRotationBehavior] is a simple Linear interpolator of a single
 * double value.
 * Mix with a [BaseNode] that you want absolute Rotation [Animation]s applied to.
 * Angles are in degrees.
 */
abstract class ParticleRotationBehavior {
  static const LINEAR = 1;
  static const CONSTANT = 2;
  
  double fromRotation = 0.0;
  double toRotation = 359.0;
  double angle = 0.0;
  double rate;
  int interpolate;
  
  void initWithRotation(double from, double to, [double rate = 1.0, int interpolate = CONSTANT]) {
    this.fromRotation = from;
    this.toRotation = to;
    this.rate = rate;
    this.interpolate = interpolate;
  }
  
  void reset() {
    angle = fromRotation;
  }
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------

  void stepRotationBehavior(double time) {
    if (interpolate == LINEAR) {
      angle = (fromRotation + (toRotation - fromRotation) * time);
    }
    else {
      angle += rate;
    }
  }

}

