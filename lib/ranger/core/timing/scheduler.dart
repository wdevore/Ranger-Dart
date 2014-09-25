part of ranger;

/**
 * Custom target signature.
 */
typedef void UpdateTarget(double dt);

/**
 * [Scheduler] is responsible of updating the scheduled callbacks.
 *   There are 2 different types of callbacks:
 *     - [TimingTarget]: the callback will be called every frame.
 *       You can customize the priority.
 *     - [UpdateTarget]: A custom target that will be called every frame,
 *       or with a custom interval of time,
 */
class Scheduler {
  // Typically the AnimationMaster is scheduled with system high priority.
  static const int SYSTEM_HIGH_PRIORITY = -10000000000;
  static const int NON_SYSTEM_HIGH_PRIORITY = SYSTEM_HIGH_PRIORITY + 1;
  static const int NORMAL_PRIORITY = 0;
  
  double timeScale = 1.0;
  
  // TimingTargets may come from ObjectPools.
  List<TimingTarget> _highPriorityTargets;
  List<TimingTarget> _normalPriorityTargets;
  List<TimingTarget> _lowPriorityTargets;

  List<Timer> _updateTargets;

  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  Scheduler() {
    // Setup a pool of timers.
    ObjectPool.addMany(Timer, Timer.createPoolable, 16);
    
    _highPriorityTargets = new List<TimingTarget>();
    _normalPriorityTargets = new List<TimingTarget>();
    _lowPriorityTargets = new List<TimingTarget>();

    _updateTargets = new List<Timer>();
  }

  /**
   * Generally the [Core.step] method will call this. 
   */
  void update(double dt) {
    
    // if timeScale < 1.0 then slow-motion
    // if timeScale > 1.0 then hyper-motion
    if (timeScale != 1.0) {
      dt *= timeScale;
    }
    
    // Update selectors from lowest to highest priority.
    for(TimingTarget target in _highPriorityTargets) {
      if (!target.paused)
        target.update(dt);
    }

    for(TimingTarget target in _normalPriorityTargets) {
      if (!target.paused)
        target.update(dt);
    }
    
    for(TimingTarget target in _lowPriorityTargets) {
      if (!target.paused)
        target.update(dt);
    }

    if (_updateTargets.length > 0) {
      // Update the timers. Some may expire.
      _updateTargets.forEach((Timer timer) => timer.update(dt));
      
      // Sweep the expired timers.
      // First remove them from the pool.
      for(Timer timer in _updateTargets) {
        if (timer.expired)
          unScheduleUpdateTargetByTimer(timer);
      }
      
      // And remove any from the collection too.
      _updateTargets.removeWhere((Timer timer) => timer.expired);      
    }
  }
  
  void unScheduleAll() {
    _highPriorityTargets.clear();
    _normalPriorityTargets.clear();
    _lowPriorityTargets.clear();
    
    // First move Timers back to the pool
    _updateTargets.forEach((Timer timer) => unScheduleUpdateTargetByTimer(timer));
    _updateTargets.clear();
  }
  
  // ----------------------------------------------------------
  // TimingTargets
  // ----------------------------------------------------------
  /**
   * The more negative [TimingTarget.priority]s is the higher priority,
   * meaning they will be updated first then progressing to the lower priority
   * [TimingTarget]s (aka higher priority values).
   * 
   * Adding a [TimingTarget] here means it will be called forever which also
   * means it will never be added back to the [ObjectPool].
   */
  void scheduleTimingTarget(TimingTarget target) {
    // Check normals first as they are the most occurring.
    bool contains = _normalPriorityTargets.contains(target);
    if (!contains) {
      contains = _highPriorityTargets.contains(target);
      if (!contains)
        contains = _lowPriorityTargets.contains(target);
    }    
    
    if (contains)
      return;
    
    // What collection is the Target destine for.
    if (target.priority < 0) {
      _highPriorityTargets.add(target);
      _highPriorityTargets.sort((TimingTarget a, TimingTarget b) => a.priority.compareTo(b.priority));
    }
    else if (target.priority == NORMAL_PRIORITY) {
      _normalPriorityTargets.add(target);
    }
    else if (target.priority > 0) {
      _lowPriorityTargets.add(target);
      _lowPriorityTargets.sort((TimingTarget a, TimingTarget b) => a.priority.compareTo(b.priority));
    }    
  }
  
  void unScheduleTimingTarget(TimingTarget target) {
    if (target.priority < 0) {
      _highPriorityTargets.remove(target);
    }
    else if (target.priority == NORMAL_PRIORITY) {
      _normalPriorityTargets.remove(target);
    }
    else if (target.priority > 0) {
      _lowPriorityTargets.remove(target);
    }    
  }

  void pauseTimingTargetsWithPriority(int priority) {
    if (priority < 0) {
      _highPriorityTargets.forEach((TimingTarget target) => target.paused = true);
    }
    else if (priority == NORMAL_PRIORITY) {
      _normalPriorityTargets.forEach((TimingTarget target) => target.paused = true);
    }
    else if (priority > 0) {
      _lowPriorityTargets.forEach((TimingTarget target) => target.paused = true);
    }    
  }
  
  void resumeTimingTargetsWithPriority(int priority) {
    if (priority < 0) {
      _highPriorityTargets.forEach((TimingTarget target) => target.paused = false);
    }
    else if (priority == NORMAL_PRIORITY) {
      _normalPriorityTargets.forEach((TimingTarget target) => target.paused = false);
    }
    else if (priority > 0) {
      _lowPriorityTargets.forEach((TimingTarget target) => target.paused = false);
    }    
  }
  
  // ----------------------------------------------------------
  // UpdateTargets
  // ----------------------------------------------------------
  /**
   * [UpdateTarget]s are wrapped inside of [Poolable] [Timer]s.
   * If the [target] is already wrapped then adjust
   * only the interval.
   */
  Timer scheduleUpdateTarget(UpdateTarget target, [double interval = 0.0, int repeat = Timer.REPEAT_FOREVER, double delay = 0.0, bool paused = false]) {
    assert(target is UpdateTarget);
    
    // Check if the target is already contained.
    Timer timer = _getTimerForUpdateTarget(target);
    
    if (timer != null) {
      // update associated timer's interval instead.
      timer.interval = interval;
    }
    else {
      // The Timer's factory will actually get a Timer from the pool.
      // We must remember to move it back to the pool when done.
      // Note: Dart has the concept of factories. The "new" operator is
      // designed to "pull" from the pool first before attempting to create.
      timer = new Timer(target, interval, repeat, delay, paused);
      timer.arm();
      _updateTargets.add(timer);
    }
    
    return timer;
  }
  
  
  /**
   * Schedules an [UpdateTarget] that runs only once,
   * with a delay of 0 or larger.
   */
  void scheduleUpdateTargetOnce(UpdateTarget target, double delay, bool pause) {
    scheduleUpdateTarget(target, 0.0, 0, delay, pause);
  }

  void unScheduleUpdateTargetByTimer(Timer timer) {
    // Mark expired such it is picked up on the next tick.
    timer.expired = true;
    
    // Put back in pool.
    timer.moveToPool();
  }
  
  void unScheduleUpdateTarget(UpdateTarget target) {
    Timer timer = _getTimerForUpdateTarget(target);
    
    if (timer != null) {
      unScheduleUpdateTargetByTimer(timer);
    }
  }
  
  void unSheduleUpdateTargetsFor(UpdateTarget target) {
    // TODO maybe
  }
  
  void pauseUpdateTarget(UpdateTarget target) {
    Timer timer = _getTimerForUpdateTarget(target);
    if (timer != null) {
      timer.paused = true;
    }
  }

  void resumeUpdateTarget(UpdateTarget target) {
    Timer timer = _getTimerForUpdateTarget(target);
    if (timer != null) {
      timer.paused = false;
    }
  }
  
  bool isUpdateTargetPaused(UpdateTarget target) {
    Timer timer = _getTimerForUpdateTarget(target);
    if (timer != null) {
      return timer.paused;
    }
    
    return false;
  }
  
  Timer _getTimerForUpdateTarget(UpdateTarget target) {
    Iterable<Timer> itr = _updateTargets.where((Timer timer) => timer.target == target);
    
    if (itr.length > 0) {
      Timer timer = itr.first;
      return timer;
    }
    
    return null;
  }
}