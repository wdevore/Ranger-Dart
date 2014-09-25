part of ranger;

/**
 * A base class for representing two-dimensional axis-aligned rectangles.
 *
 * This rectangle uses a left-handed Cartesian coordinate system, with x
 * directed to the right and y directed up.
 *
 */
abstract class RectangleBase<T extends num> extends ComponentPoolable {

  /** The x-coordinate of the left edge. */
  T get left;
  /** The y-coordinate of the bottom edge. */
  T get bottom;
  /** The `width` of the rectangle. */
  T get width;
  /** The `height` of the rectangle. */
  T get height;

  /** The x-coordinate of the right edge. */
  T get right => left + width;
  /** The y-coordinate of the top edge. */
  T get top => bottom + height;

  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  RectangleBase();

  String toString() {
    return 'Rectangle ('
      'l:${left.toStringAsFixed(2)}, b:${bottom.toStringAsFixed(2)}, '
      'r:${right.toStringAsFixed(2)}, t:${top.toStringAsFixed(2)}) '
      '{${width.toStringAsFixed(2)} x ${height.toStringAsFixed(2)}} '
      'ratio: ${(width/height).toStringAsFixed(2)}';
  }

  bool operator ==(other) {
    if (other is !MutableRectangle) return false;
    return left == other.left && bottom == other.bottom && width == other.width &&
        height == other.height;
  }

  /**
   * Computes the intersection of `this` and [other].
   *
   * The intersection of two axis-aligned rectangles, if any, is always another
   * axis-aligned rectangle.
   *
   * Returns the intersection of this and `other`, or `null` if they don't
   * intersect.
   */
  MutableRectangle<T> intersection(MutableRectangle<T> other) {
    T x0 = math.max(left, other.left);
    T x1 = math.min(left + width, other.left + other.width);

    if (x0 <= x1) {
      T y0 = math.max(bottom, other.bottom);
      T y1 = math.min(bottom + height, other.bottom + other.height);

      if (y0 <= y1) {
        other.left = x0;
        other.bottom = y0;
        other.width = x1 - x0;
        other.height = y1 - y0;
        return other;
      }
    }
    return null;
  }


  /**
   * Returns true if `this` intersects [other].
   */
  bool intersects(MutableRectangle<T> other) {
    return (
        left <= other.left + other.width &&
        other.left <= left + width &&
        bottom <= other.bottom + other.height &&
        other.bottom <= bottom + height);
  }

  bool overlaps(MutableRectangle<T> rect) {
    return !(
        (left + width < rect.left) ||
        (rect.left + rect.width < left) ||
        (bottom + height < rect.bottom) ||
        (rect.bottom + rect.height < bottom)
        );    
  }
  
  /**
   * Returns the smallest rectangle that contains the two source rectangles.
   */
  void unionTo(MutableRectangle<T> rect) {
    T _left = left < rect.left ? left : rect.left;
    T _top = top > rect.top ? top : rect.top;
    T _bottom = bottom < rect.bottom ? bottom : rect.bottom;
    T _right = right > rect.right ? right : rect.right;
    
    rect.left = _left;
    rect.bottom = _bottom;
    rect.width = _right - _left;
    rect.height = _top - _bottom;
  }

  /**
   * Returns a new rectangle which completely contains `this` and [other].
   */
  MutableRectangle<T> boundingBox(MutableRectangle<T> other) {
    T right = math.max(this.left + this.width, other.left + other.width);
    T bottom = math.max(this.bottom + this.height, other.bottom + other.height);

    T left = math.min(this.left, other.left);
    T top = math.min(this.bottom, other.bottom);

    other.left = left;
    other.bottom = top;
    other.width = right - left;
    other.height = bottom - top;

    return other;
  }

  /**
   * Tests whether `this` entirely contains [another].
   */
  bool containsRectangle(MutableRectangle<T> another) {
    return left <= another.left &&
           left + width >= another.left + another.width &&
           bottom <= another.bottom &&
           bottom + height >= another.bottom + another.height;
  }

  /**
   * Tests whether [another] is inside or along the edges of `this`.
   */
  bool containsPoint(Html.Point<T> another) {
    return another.x >= left &&
           another.x <= left + width &&
           another.y >= bottom &&
           another.y <= bottom + height;
  }

  /**
   * Tests whether [another] is inside or along the edges of `this`.
   */
  bool containsPointByComp(T x, T y) {
    return x >= left &&
           x <= left + width &&
           y >= bottom &&
           y <= bottom + height;
  }

  Html.Point<T> get topLeft => new Html.Point<T>(this.left, this.bottom);
  Html.Point<T> get topRight => new Html.Point<T>(this.left + this.width, this.bottom);
  Html.Point<T> get bottomRight => new Html.Point<T>(this.left + this.width,
      this.bottom + this.height);
  Html.Point<T> get bottomLeft => new Html.Point<T>(this.left,
      this.bottom + this.height);
}

/**
 * A class for representing two-dimensional axis-aligned rectangles with mutable
 * properties.
 */
class MutableRectangle<T extends num> extends RectangleBase<T> {
  T left;
  T bottom;
  T width;
  T height;

  MutableRectangle(this.left, this.bottom, this.width, this.height);

  MutableRectangle.zero();
  
  factory MutableRectangle.fromPoints(Html.Point<T> a, Html.Point<T> b) {
    T left = math.min(a.x, b.x);
    T width = math.max(a.x, b.x) - left;
    T top = math.min(a.y, b.y);
    T height = math.max(a.y, b.y) - top;
    return new MutableRectangle<T>(left, top, width, height);
  }
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  MutableRectangle._();

  factory MutableRectangle.withP(T left, T bottom, T width, T height) {
    MutableRectangle r = new MutableRectangle._poolable(left, bottom, width, height);
    return r;
  }

  factory MutableRectangle.zeroP() {
    MutableRectangle r = new MutableRectangle._poolable(0.0, 0.0, 0.0, 0.0);
    return r;
  }
  
  factory MutableRectangle.withRectP(MutableRectangle<T> rect) {
    MutableRectangle r = new MutableRectangle._poolable(rect.left, rect.bottom, rect.width, rect.height);
    return r;
  }

  factory MutableRectangle._poolable(T left, T bottom, T width, T height) {
    MutableRectangle poolable = new Poolable.of(MutableRectangle, createPoolable);
    poolable.left = left;
    poolable.bottom = bottom;
    poolable.width = width;
    poolable.height = height;
    return poolable;
  }

  static MutableRectangle createPoolable() => new MutableRectangle._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void setWith(MutableRectangle<T> rect) {
    left = rect.left;
    bottom = rect.bottom;
    width = rect.width;
    height = rect.height;
  }

  void setValues(T left, T bottom, T width, T height) {
    this.left = left;
    this.bottom = bottom;
    this.width = width;
    this.height = height;
  }

//  union(MutableRectangle<T> rect) {
//    T _left = math.min(left, rect.left);
//    //T _top = math.min(top, rect.top);
//    T _bottom = math.min(bottom, rect.bottom);
//    
//    left = _left;
//    bottom = _bottom;
//    width = math.max(left + width, rect.left + rect.width) - _left;
//    height = math.max(bottom + height, rect.bottom + rect.height) - _bottom;
//  }

  union(MutableRectangle<T> rect) {
    T _left = left < rect.left ? left : rect.left;
    T _top = top > rect.top ? top : rect.top;
    T _bottom = bottom < rect.bottom ? bottom : rect.bottom;
    T _right = right > rect.right ? right : rect.right;
    
    left = _left;
    bottom = _bottom;
    width = _right - _left;
    height = _top - _bottom;
  }
}
