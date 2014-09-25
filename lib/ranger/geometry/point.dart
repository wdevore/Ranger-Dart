part of ranger;

class Point extends ComponentPoolable {
  double x = 0.0;
  double y = 0.0;
  
  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  Point(this.x, this.y);
  
  Point.withPoint(Point point) {
    x = point.x;
    y = point.y;
  }
  
  Point.withSize(Size<double> other) {
    x = other.width;
    y = other.height;
  }

  Point.zero();
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  Point._();
  
  factory Point.withPointPartsP(double x, double y) {
    Point p = new Point.poolable(x, y);
    return p;
  }
  
  factory Point.withPointP(Point point) {
    Point p = new Point.poolable(point.x, point.y);
    return p;
  }
  
  factory Point.withSizeP(Size<double> other) {
    Point p = new Point.poolable(other.width, other.height);
    return p;
  }
  
  factory Point.zeroP() {
    Point p = new Point.poolable(0.0, 0.0);
    return p;
  }
  
  factory Point.poolable(double x, double y) {
    Point poolable = new Poolable.of(Point, createPoolable);
    poolable.x = x;
    poolable.y = y;
    return poolable;
  }

  static Point createPoolable() => new Point._();

  // ----------------------------------------------------------
  // Operators
  // ----------------------------------------------------------
  bool operator ==(Point other) {
    return ((x - other.x).abs() < EPSILON)
        && ((y - other.y).abs() < EPSILON);
  }

  Point operator +(Point right) {
    return new Point(this.x + right.x, this.y + right.y);
  }

  Point operator -(Point right) {
    return new Point(this.x - right.x, this.y - right.y);
  }

  Point operator *(double a) {
    return new Point(this.x * a, this.y * a);
  }

  Point operator /(double a) {
    assert(a == 0.0);
    return new Point(this.x / a, this.y / a);
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void scale(double s) {
    x *= s;
    y *= s;
  }
  
  void set(double x, double y) {
    this.x = x;
    this.y = y;
  }
  
  bool fuzzyEquals(Point b, double variance) {
    if(x - variance <= b.x && b.x <= x + variance)
        if(y - variance <= b.y && b.y <= y + variance)
            return true;
    return false;
  }

  /** Calculates distance between point an origin
   */
  double length() => math.sqrt(x * x + y * y);
  
  /** Calculates the square length of a Point (not calling sqrt() )
   */
  double lengthSq() => dot(this); //x*x + y*y;

  /** Calculates the square distance between two points (not calling sqrt() )
  */
  double getDistanceSq(Point other) => (this - other).lengthSq();

  /** Calculates the distance between two points
   */
  double getDistance(Point other) => (this - other).length();

  /** returns the angle in radians between this vector and the x axis
  */
  double angle() => math.atan2(y, x);

  /** returns the angle in radians between two vector directions
  */
  double angleBetweenVectors(Point other) {
  Point a2 = normalize();
  Point b2 = other.normalize();
    double angle = math.atan2(a2.cross(b2), a2.dot(b2));
    if ( angle.abs() < EPSILON ) return 0.0;
    return angle;
  }

  /** Calculates dot product of two points.
   */
  double dot(Point other) => x * other.x + y * other.y;

  /** Calculates cross product of two points.
   */
  double cross(Point other) => x * other.y - y * other.x;

  /** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
   */
  Point getPerp() => new Point(-y, x);

  /** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
   */
  Point getRPerp() => new Point(y, -x);

  /** Calculates the projection of this over other.
   */
  Point project(Point other) => other * (dot(other)/other.dot(other));

  /** Complex multiplication of two points ("rotates" two points).
  @return CCPoint vector with an angle of this.getAngle() + other.getAngle(),
  and a length of this.getLength() * other.getLength().
   */
  Point rotate(Point other) {
    return new Point(x*other.x - y*other.y, x*other.y + y*other.x);
  }

  /** Unrotates two points.
  @return CCPoint vector with an angle of this.getAngle() - other.getAngle(),
  and a length of this.getLength() * other.getLength().
   */
  Point unrotate(Point other) {
    return new Point(x*other.x + y*other.y, y*other.x - x*other.y);
  }

  /** Returns point multiplied to a length of 1.
   * If the point is 0, it returns (1, 0)
   */
  Point normalize()  {
    if(length() == 0.0)
      return new Point(1.0, 0.0);
    return this / length();
  }

  /** Linear Interpolation between two points a and b
  @returns
  alpha == 0 ? a
  alpha == 1 ? b
  otherwise a value between a..b
   */
  Point lerp(Point other, double alpha) => this * (1.0 - alpha) + other * alpha;

  /** Rotates a point counter clockwise by the angle around a pivot
  @param pivot is the pivot, naturally
  @param angle is the angle of rotation ccw in radians
  @returns the rotated point
   */
  Point rotateByAngle(Point pivot, double angle) => pivot + (this - pivot).rotate(forAngle(angle));

  static Point forAngle(double a) => new Point(math.cos(a), math.sin(a));
  
  String toString() {
    return "($x, $y)";
  }
}
