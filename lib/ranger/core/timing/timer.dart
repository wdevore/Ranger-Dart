part of ranger;

class Timer extends ComponentPoolable {
  static int _genId = 0;  // unique id.
  int id;
  
  double interval = 0.0;
  double elapsed = 0.0;
  
  bool runForever = false;
  
  bool useDelay = false;
  
  bool paused = false;
  
  int timesExecuted = 0;

  bool expired = false;
  
  static const int REPEAT_FOREVER = 9007199255000000; // 2^53
  /// 0 = once, 1 is 2 x executed
  int repeat = 0;
  
  double delay = 0.0;

  UpdateTarget target;
  
  // ----------------------------------------------------------
  // Constructors and Factories
  // ----------------------------------------------------------
  /**
   * 
   */
  factory Timer(UpdateTarget target, double seconds, int repeat, double delay, bool paused) {
    Timer poolable = new Poolable.of(Timer, _constructor);
    poolable.id = _genId++;
    poolable.target = target;
    poolable.elapsed = -1.0;
    poolable.interval = seconds;
    poolable.repeat = repeat - 1;
    poolable.delay = delay;
    poolable.paused = paused;
    poolable.runForever = poolable.repeat == REPEAT_FOREVER;
    return poolable;
  }

  factory Timer.withTarget(UpdateTarget target, double seconds, bool paused) {
    Timer poolable = new Poolable.of(Timer, _constructor);
    poolable.id = _genId++;
    poolable.target = target;
    poolable.elapsed = -1.0;
    poolable.interval = seconds;
    poolable.repeat = REPEAT_FOREVER;    
    poolable.delay = 0.0;
    poolable.runForever = true;
    poolable.paused = paused;
    return poolable;
  }
  
  Timer._();
  static Timer _constructor() => new Timer._();
  static Timer createPoolable() => _constructor();
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  String toString() => "id: $id, timesExecuted: $timesExecuted, paused: $paused";
  
  void arm() {
    elapsed = -1.0;
    expired = false;
  }
  
  /**
   * [dt] is a delta time.
   */
  void update(double dt) {
    if (paused || expired)
      return;
    
    if (elapsed == -1.0) {
      elapsed = 0.0;
      timesExecuted = 0;
    }
    else {
      if (runForever && !useDelay) {
        //standard timer usage
        elapsed += dt;

        if (elapsed >= interval) {
          target(elapsed);
          elapsed = 0.0;
        }
      }
      else {
        //advanced usage
        elapsed += dt;
        if (useDelay) {
          if (elapsed >= delay) {
            target(elapsed);

            elapsed = elapsed - delay;
            timesExecuted++;
            useDelay = false;
          }
        }
        else {
          if (elapsed >= interval) {
            if (target == null)
              Logging.error("Timer: target is null!");
            else
              target(elapsed);

            elapsed = 0.0;
            timesExecuted++;
          }
        }

        if (!runForever && (timesExecuted > repeat)) {
          expired = true;
          //Logging.info("Timer expired: $this");
        }
      }
    }
  }
  
}