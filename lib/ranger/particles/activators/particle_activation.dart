part of ranger;

typedef Function ActivateParticleCallback(Particle p, double posX, double posY);
typedef Function DeactivateParticleCallback(Particle p);

abstract class ParticleActivation {
  /// Straigt line (beem effect)
  static const UNI_DIRECTIONAL = 0;
  /// Sparkler effect
  static const OMNI_DIRECTIONAL = 1;
  /// Spray hose effect
  static const DRIFT_DIRECTIONAL = 2;
  /// Rocket exhaust effect
  static const VARIANCE_DIRECTIONAL = 3;
  /// Flag waving effect
  static const PINGPONG_DIRECTIONAL = 4;
  /// Spinning around effect
  static const RADIALSWEEP_DIRECTIONAL = 5;
  
  Direction direction = new Direction();
  double angleVariance = 10.0;
  double angleDirection = -90.0;
  double sweepAngle = -90.0;
  double sweepAngleRate = 1.0;
  
  math.Random _randGen = new math.Random();
  
  ActivationData activationData = new ActivationData();
  
  ActivateParticleCallback activateCallback;
  DeactivateParticleCallback deactivateCallback;

  void update(double dt) {
    
  }
  
  math.Random get randGen => _randGen;
  
  void activate(Particle particle, int emissionStyle, double posX, double posY);
  void deactivate(Particle particle);
  
  void set directionByDegrees(double angle) {
    direction.directionByDegrees = angle;
  }
  
  double get directionInDegrees => direction.asAngleInDegrees;
  double get directionInRadians => direction.asAngle;

  double _genValueFrom(double min, double max, double variance, double mean) {
    // The "value" must stay > 0 including the variance. The variance
    // can +-. It is a max swing centering around the Min.
    // min + Mean * (max - min)
    //
    //
    //   max --------------------------------------------
    //                 .       .    .
    //           ...       ..
    //   --------------------------------------------  distribution epic center
    //              ..   .   .   ..
    //                .            .
    //   min --------------------------------------------
    //
    //   0.0 --------------------------------------------
    //double mean = (max - min) / 2.0;
    double epic = min + mean * (max - min);
    
    double swing = _randGen.nextDouble() * variance;
    swing = _randGen.nextDouble() > 0.5 ? -swing : swing;
    double value = epic + swing;
    
    value = math.min(max, value);
    value = math.max(min, value);
    return value;
  }
  
  int _genIntValueFrom(int min, int max, int variance, double mean) {
    // The "value" must stay > 0 including the variance. The variance
    // can +-. It is a max swing centering around the Min.
    // min + Mean * (max - min)
    //
    //
    //   max --------------------------------------------
    //                 .       .    .
    //           ...       ..
    //   --------------------------------------------  distribution epic center
    //              ..   .   .   ..
    //                .            .
    //   min --------------------------------------------
    //
    //   0.0 --------------------------------------------
    //double mean = (max - min) / 2.0;
    double epic = min + mean * (max - min);
    
    double swing = _randGen.nextDouble() * variance;
    swing = _randGen.nextDouble() > 0.5 ? -swing : swing;
    double value = epic + swing;
    
    value = math.min(max.toDouble(), value);
    value = math.max(min.toDouble(), value);
    return value.floor();
  }

}