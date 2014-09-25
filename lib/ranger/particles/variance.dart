part of ranger;

/**
 *    Varying     Delaying    Varying        Delay
 *   _________              _______________
 * __|       |______________|              |________
 *                           <--Duration->
 */
class Variance {
  static const int CLAMP_TO_MIN = 0;
  static const int CLAMP_TO_MAX = 1;
  static const int CLAMP_TO_MEAN = 2;
  
  double min = 0.0;
  double max = 0.0;
  double variance = 0.0;
  double mean = 0.5;
  
  /// How long the [Variance] varies. If there is no [delay] then this
  /// value has no meaning.
  double duration = 0.0;
  double _durationCount = 0.0;

  /// Delay before next variance. A Zero [delay] disables [duration]
  /// and [delay]. Default is disabled (aka continuous variation.)
  double delay = 0.0;
  
  /// The value returned when delaying. If not specified it defaults
  /// to the last value generated during the [duration] period.
  double delayValue;
  
  double _delayCount = 0.0;
  bool _delayed = false;

  double _currentValue = 0.0;
  
  math.Random _randGen = new math.Random();

  Variance();
  
  Variance.initWith(this.min, this.max, this.variance, [this.delayValue, this.mean = 0.5]);
  
  /**
   * Effectively disables variance.
   */
  void clampVarianceTo(int to) {
    variance = 0.0;
    switch (to) {
      case CLAMP_TO_MIN:
        mean = 0.0;
        break;
      case CLAMP_TO_MAX:
        mean = 1.0;
        break;
      case CLAMP_TO_MEAN:
        mean = 0.5;
        break;
    }
  }
  
  /// Get a new [value] of the variance.
  double get value {
    if (!_delayed)
      _currentValue = _genValueFrom(min, max, variance, mean);
    else {
      if (delayValue != null)
        _currentValue = delayValue;
    }
    
    return _currentValue;
  }
  
  void update(dt) {
    if (delay > 0.0) {
      _durationCount += dt;
      if (_durationCount > duration) {
        // We begin delaying
        //print("delaying");
        _delayed = true;
        _durationCount = 0.0;
      }
      
      if (_delayed) {
        _delayCount += dt;
        if (_delayCount > delay) {
          // Delay ended. Begin varying again.
          //print("delay ended");
          _delayed = false;
          _delayCount = 0.0;
        }
      }
    }
    else {
      _delayed = false;
    }
  }
  
  double _genValueFrom(double min, double max, double variance, double mean) {
    // The variance can +-. It is a max swing centering around the Min.
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

  @override
  String toString() {
    return "min: $min, max: $max, variance: $variance, mean: $mean";
  }
}