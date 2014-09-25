part of ranger;

/** 
 * A rarely used Scene. Use with caution.
 */
class BasicScene extends Scene {
  Function _completeVisit;
  
  // Base class constructor runs first.
  BasicScene([Function completeVisit = null]) {
    _completeVisit = completeVisit;
  }

  @override
  void completeVisit() {
    if (_completeVisit != null)
      _completeVisit();
  }
}
