part of ranger;

/**
 * [Core] contains the main loop of the engine.
 * It is extremely rare that you would interact directly with this class.
 */
class Core {
  // ----------------------------------------------------------
  // Properties
  // ----------------------------------------------------------
  Html.Window window;
  
  double frameInterval = 0.0;
  
  bool loopEnabled = true;
  
  /// If step is enabled then an external entity must call [step]
  /// for each frame.
  /// Typically this would be done by a keystroke event--like the "p" key.
  /// Each tap of the "p" key calls the [step] method with a frame time.
  /// For example, to step at a rate of 60fps you would call [step]
  /// with a value of 1/60*1000 ~= 16.666...7
  
  // [FRAMES_PER_SECOND] is a perfect timing value.
  int frames_per_second = CONFIG.frameRate;

  // Used for simulating during stepping.
  static const double SIM_FRAMES_PER_SECOND = 120.0;
  static const double SIM_FRAME_PERIOD = 1.0 / SIM_FRAMES_PER_SECOND;
  static const double SIM_FRAME_STEP = SIM_FRAME_PERIOD * 1000.0;
  
  // 1 frame period is equal to a fraction. For example, if
  // FRAMES_PER_SECOND = 60.0 then frame period is 0.01666666667s of a second
  // or in milliseconds it is 1000.0/60.0 = 16.66666667ms per frame.
  double _frame_period;
  // This is a perfect step and we use it against the real step.
  double _frame_step;
  
  // An accumulating value up to the FRAME_PERIOD
  double _totalExcess = 0.0;
  
  // The maximum frames to skip in worst case scenarios.
  static const int MAX_FRAME_SKIPS = 5;
  int _frameSkipCount = 0;
  /**
   * [window.animationFrame] is not perfect and it oscillates around a "perfect"
   * frame-step. If the frame-step is 16.77 then the oscillation varies
   * somewhere between ~16.00 to ~17.00. This means there will be
   * spurious excess when the oscillation is above 16.77.
   * So basically I "add in" a tolerance level that first must be achieved
   * before the UPS kicks in. 
   */
  double excessTolerance = 1.0;
  
  /**
   * Enable this if you feel like your game isn't performing as expected.
   * Warning: The caveat here is that you will begin to see "jumps" in
   * the motion of moving objects. I suggest using it sparingly and generally
   * on slower devices.
   * Enable/Disable the core's ability to provide extra updates if any
   * given loop takes an excessive amount of time.
   * Default is (disabled = false).
   */
  bool enabledUPS = false;
  
  bool _stepEnabled = false;

  double _prevTime = 0.0;
  double deltaAccum = 0.0;
  
  bool showFrameCount = true;
  int frameCount = 0;
  int _framesPerPeriod = 0;
  int _updatesPerPeriod = 0;
  
  bool calcAverageFPS = false;
  double fpsAverage;
  
  /**
   * How many frames to process before switching to step mode.
   */
  int autoStopFrameCount = 0;
  int autoStopFrameMax = 120;
  bool autoStop = false;

  Scheduler _scheduler;
  SceneManager _sceneManager;
  DrawContext _drawContext;
  
  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  Core._();
  
  factory Core(SceneManager sceneManager, Scheduler scheduler, DrawContext drawContext, Html.Window window) {
    Core core = new Core._();

    core._frame_period = 1.0 / core.frames_per_second;
    core._frame_step = core._frame_period * 1000.0;
    //print("_frame_step: ${core._frame_step}");
    core.fpsAverage = double.NAN; 
    core.window = window;
    
    core._sceneManager = sceneManager;
    core._scheduler = scheduler;
    core._drawContext = drawContext;
    
    return core;
  }
  
  // ----------------------------------------------------------
  // Core timing
  // ----------------------------------------------------------
  void shutdown() {
    if (_stepEnabled) {
      Logging.info("Shutdown: Disabling loop...");
      loopEnabled = false;
    }
    else {
      Logging.warning("Shutdown: the engine doesn't seem to be running.");
    }
  }
  
  void _completeShutdown() {
    Logging.info("Complete shut down...");

    // Flush the scheduler
    _scheduler.unScheduleAll();

    // Force the SceneManager to end all the queued scenes.
    _sceneManager.end();
    Logging.info("Shutdown complete.");
  }
  
  void start() {
    //Logging.info("Max frame skips: $MAX_FRAME_SKIPS");
    //Logging.info("Perfect fps: $FRAMES_PER_SECOND");
    //Logging.info("Perfect Frame period: $FRAME_PERIOD");
    //Logging.info("Perfect Step frame: $FRAME_STEP");
    //Logging.info("Simulated Step frame: $SIM_FRAME_STEP");
    //Logging.info("Simulated frame period: $SIM_FRAME_PERIOD");
    //Logging.info("Simulated fps: $SIM_FRAMES_PER_SECOND");
    
    deltaAccum = 0.0;
    
    if (_stepEnabled)
      return;
    
    /**
     * Note: The default frame rate seems to be 60fps or ~16.666...7 milliseconds
     * 60fr/s = 16.7ms/fr
     * 1f = 0.0167 fraction = 16.7/1000ms
     */
    window.animationFrame.then(_stabilize);
  }
  
  /*
   * When the application is first launched. The dart framework performs
   * tasks prior to executing main. That work is included in the first
   * few frames and can make the delta quite large during those frames,
   * for example, 500~800ms.
   * The other way the delta can be large is if you put a breakpoint
   * in the path of launching, the initial delta will be huge.
   * 
   * So we loop until the delta drops to within
   * 20ish percent. This is typically 3 or 4 loops, or more if you had
   * a breakpoint.
   * This also keeps the UPS from doing excessive work upfront. With out
   * it animations seems fast at launch, then suddenly slow back down once
   * a few frames have passed.
   * 
   * Once the delta drops to a reasonable value we switch to the loop()
   * method and never look back.
   */
  bool _stabilize(num time) {
    double frameDelta = time - _prevTime;
    
    _prevTime = time;

    if (frameDelta > 1.2 * _frame_step)
      window.animationFrame.then(_stabilize); // continue to stablize
    else {
      Logging.info("Core timing stabilized.");
      window.animationFrame.then(loop);
    }
    
    return true;
  }
  
  /**
   * [time] is a monotonically increasing value between Now and
   * when the app started. It has millisecond resolution.
   * It increment size is equal to 60fps ~= "16.66666...7ms" per frame.
   */
  bool loop(num time) {
    if (_stepEnabled) {
      Logging.warning("Application.loop: stepping disabled.");
      return false;
    }
    
    // The time per frame in milliseconds.
    double frameDelta = time - _prevTime;
    
    bool continueSteps = step(frameDelta);
    
    if (!continueSteps) {
      _completeShutdown();
      return false;
    }
    
    _prevTime = time;
    
    if (autoStop) {
      autoStopFrameCount++;
      if (autoStopFrameCount == autoStopFrameMax) {
        stepEnabled = true;
      }
    }
    
    if (loopEnabled) {
      window.animationFrame.then(loop);
    }
    //else {
    //  _completeShutdown();
    //}

    return false;
  }
  
  /**
   * [frameDelta] is typically equal to [_frame_step]. It could be more
   * if the update/render cycle takes too long.
   * Note: Using [window].[animationFrame] usually causes the frameTime
   * to stay within [_frame_step] size.
   */
  bool step(double frameDelta) {
    // To convert to fractions of a single second we divide by 1000.
    // This means every 1.0 seconds FRAMES_PER_SECOND occurs.
    // [dt] is what is passed to the timing framework.
    // dt is a fraction of an interval from 0.0 -> 1.0
    double dt = frameDelta / 1000.0;
    _scheduler.update(dt);
    _updatesPerPeriod++;
    
    // Render scene(s).
    bool continueDraws = _sceneManager.step(_drawContext);
    if (!continueDraws)
      return false;   // stop stepping. There are no more scenes to render.
    
    if (enabledUPS) {
      // if frameTime > STEP_FRAME then that means a single loop took
      // to long to complete. So we collect the excess and if the total
      // exceeds 1 frame then we artifically insert extra updates to make
      // up for the overshoot.
      // However, nothing is perfect and "frameDelta" isn't always
      // equal to a perfect frame-step. So we add in a bit of a tolerance
      // so that we don't skip draws when there really isn't an excess.
      double excess = ((frameDelta - excessTolerance) - _frame_step);
      if (excess > 0.0) {
        _totalExcess += excess;
      }
      
      // Handling timing.
      // We shouldn't perform skips unless the excess reaches a
      // tolerance level.
      if (_totalExcess >= _frame_step) {
        // Fill in some updates to make up for "lost" time, however,
        // clamp to MAX_FRAME_SKIPS 
        while (_totalExcess >= _frame_step && _frameSkipCount < MAX_FRAME_SKIPS) {
          _totalExcess -= _frame_step;
          _scheduler.update(_frame_period); // use Perfect frame size.
          _frameSkipCount++;
          _updatesPerPeriod++;
        }
        // Don't reset _totalExcess to zero because we want to carry
        // over the excess into the next frame.
        // Reset skip count for next interval
        _frameSkipCount = 0;
      }
    }
    
    frameCount++;

    deltaAccum += dt;
    _framesPerPeriod++;
    
    // This stat is optional. It shows a floating average instead
    // of frameCount per interval.
    if (calcAverageFPS) {
      if (fpsAverage == null)
        fpsAverage = 1.0 / dt;
  
      fpsAverage = 1.0 / dt * 0.05 + fpsAverage * 0.95;
    }
    
    return true;  // continue stepping.
  }
  
  set stepEnabled(bool value) {
    _stepEnabled = value;
    if (!_stepEnabled) {
      // Resume the loop.
      start();
    }
  }
  
  bool get stepEnabled => _stepEnabled;
}
