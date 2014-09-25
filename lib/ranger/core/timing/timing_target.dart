part of ranger;

/**
 * Objects that want to participate in scheduling need to
 * implement [TimingTarget].
 * The [ActionManager] and [BaseNode] are targets.
 */
abstract class TimingTarget {
  /// The more negative the value the "higher" the priority
  /// meaning your target will be updated before more positive
  /// values.
  /// A value of [Scheduler.NORMAL_PRIORITY] is most often the case.
  int priority = Scheduler.NORMAL_PRIORITY;
  
  bool paused = false;
  
  /// [dt] is a number between 0.0 and 1/60
  void update(double dt);
}