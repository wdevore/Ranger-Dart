part of ranger;

/**
 * All components extend from this class.
 * Components serve as little more than bags of data.
 * They have no update function, no internal logic.
 * If you want to use a poolable component that will be added to a FreeList when
 * it is being removed use [ComponentPoolable] instead.
 */
abstract class Component {
  /// Does nothing in [Component], only relevant for [ComponentPoolable].
  void _removed() {}
}

/**
 * All components that should be managed in a [ObjectPool] must extend this class
 * and have a factory constructor that calls `new Poolable.of(...)` to create
 * a component. By doing so, Ranger can handle the construction of
 * [ComponentPoolable]s and reuse them when they are no longer needed.
 */
class ComponentPoolable extends Component with Poolable {

  void _removed() {
    moveToPool();
  }

  /**
   * If you need to do some cleanup when removing this component override this
   * method.
   */
  void cleanUp() {}
}