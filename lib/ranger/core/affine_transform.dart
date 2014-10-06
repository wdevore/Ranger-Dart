part of ranger;

/**
 * A minified affine transform.
 *  column major (form used by this class)
 *     x'   |a c tx| |x|
 *     y' = |b d ty| |y|
 *     1    |0 0  1| |1|
 *  or
 *  Row major
 *                           |a  b   0|
 *     |x' y' 1| = |x y 1| x |c  d   0|
 *                           |tx ty  1|
 *  
 */
class AffineTransform extends ComponentPoolable {
  double a, b, c, d;
  double tx, ty;
  
  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  AffineTransform(this.a, this.b, this.c, this.d, this.tx, this.ty);

  AffineTransform.Identity() {
    a = d = 1.0;
    b = c = tx = ty = 0.0;
  }
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  AffineTransform._();
  
  factory AffineTransform.IdentityP() {
    AffineTransform t = new AffineTransform._poolable(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    return t;
  }
  
  factory AffineTransform.withAffineTransformP(AffineTransform t) {
    AffineTransform at = new AffineTransform._poolable(t.a, t.b, t.c, t.d, t.tx, t.ty);
    return at;
  }

  factory AffineTransform._poolable(double a, double b, double c, double d, double tx, double ty) {
    AffineTransform poolable = new Poolable.of(AffineTransform, createPoolable);
    poolable.a = a;
    poolable.b = b;
    poolable.c = c;
    poolable.d = d;
    poolable.tx = tx;
    poolable.ty = ty;
    return poolable;
  }

  static AffineTransform createPoolable() => new AffineTransform._();

  factory AffineTransform.asTranslate(double tx, double ty) {
    AffineTransform t = new AffineTransform._poolable(1.0, 0.0, 0.0, 1.0, tx, ty);
    return t;
  }

  factory AffineTransform.asScale(double sx, double sy) {
    AffineTransform t = new AffineTransform._poolable(sx, 0.0, 0.0, sy, 0.0, 0.0);
    return t;
  }

  // ----------------------------------------------------------
  // Operators
  // ----------------------------------------------------------
  bool operator ==(AffineTransform t) {
    return (a == t.a && b == t.b && c == t.c && d == t.d && tx == t.tx && ty == t.ty);
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void toIdentity() {
    a = d = 1.0;
    b = c = tx = ty = 0.0;
  }
  
  void ApplyToPoint(Point point) {
    point.x = (a * point.x) + (c * point.y) + tx;
    point.y = (b * point.x) + (d * point.y) + ty;
  }

  void ApplyToVectorPoint(Vector2 point) {
    point.x = (a * point.x) + (c * point.y) + tx;
    point.y = (b * point.x) + (d * point.y) + ty;
  }

  void ApplyToSize(Size size) {
    size.width = (a * size.width + c * size.height).toInt();
    size.height = (b * size.width + d * size.height).toInt();
  }
  
  void ApplyToRect(MutableRectangle<double> rect) {
    double top    = rect.bottom;
    double left   = rect.left;
    double right  = rect.width;
    double bottom = rect.height;
    
    Point topLeft = new Point(left, top);
    Point topRight = new Point(right, top);
    Point bottomLeft = new Point(left, bottom);
    Point bottomRight = new Point(right, bottom);
    ApplyToPoint(topLeft);
    ApplyToPoint(topRight);
    ApplyToPoint(bottomLeft);
    ApplyToPoint(bottomRight);

    double minX = math.min(math.min(topLeft.x, topRight.x), math.min(bottomLeft.x, bottomRight.x));
    double maxX = math.max(math.max(topLeft.x, topRight.x), math.max(bottomLeft.x, bottomRight.x));
    double minY = math.min(math.min(topLeft.y, topRight.y), math.min(bottomLeft.y, bottomRight.y));
    double maxY = math.max(math.max(topLeft.y, topRight.y), math.max(bottomLeft.y, bottomRight.y));
  }
  
  void set(double a, double b, double c, double d, double tx, double ty) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
  }
  
  void setWithAT(AffineTransform t) {
    this.a = t.a;
    this.b = t.b;
    this.c = t.c;
    this.d = t.d;
    this.tx = t.tx;
    this.ty = t.ty;
  }
  
  /// Concatenate translation
  void translate(double x, double y)
  {
    tx += (a * x) + (c * y);
    ty += (b * x) + (d * y);
  }

  void setToTranslate(double tx, double ty)
  {
    set(1.0, 0.0, 0.0, 1.0, tx, ty);
  }

  void setToScale(double sx, double sy)
  {
    set(sx, 0.0, 0.0, sy, 0.0, 0.0);
  }

  /// Concatenate scale
  void scale(double sx, double sy) {
    a *= sx;
    b *= sx;
    c *= sy;
    d *= sy;
  }
  
  /**
   * Concatinate a rotation (radians) onto this transform.
   * 
   * Rotation is just a matter of perspective. A CW rotation can be seen as
   * CCW depending on what you are talking about rotating. For example,
   * if the coordinate system is thought as rotating CCW then objects are
   * seen as rotating CW, and that is what the 2x2 matrix below represents
   * with Canvas2D. It is also the frame of reference we use.
   *     |cos  -sin|   object appears to rotate CW.
   *     |sin   cos|
   * 
   * In the matrix below the object appears to rotate CCW.
   *     |cos  sin|   
   *     |-sin cos|
   *     
   *     |a  c|    |cos  -sin|
   *     |b  d|  x |sin   cos|
   *     
   */
  void rotate(double angle) {
    double sin = math.sin(angle);
    double cos = math.cos(angle);
    double _a = a;
    double _b = b;
    double _c = c;
    double _d = d;
    
    /*
     * |a1 c1|   |a2 c2|   |a1a2 + a1b2, a1c2 + c1d2|
     * |b1 d1| x |b2 d2| = |b1a2 + d1b2, b1c2 + d1d2|
     * 
     * |_a, _c|   |cos, -sin|   |_acos + _csin, _a(-sin) + _ccos|
     * |_b, _d| x |sin,  cos| = |_bcos + _dsin, _b(-sin) + _dcos|
     */
    a = _a * cos + _c * sin;
    b = _b * cos + _d * sin;
    c = _c * cos - _a * sin;
    d = _d * cos - _b * sin;
    
    /*
     * |_a, _c|   |cos,  sin|   |_acos + _c(-sin), _a(sin) + _ccos|
     * |_b, _d| x |-sin, cos| = |_bcos + _d(-sin), _b(sin) + _dcos|
     */
//    a = _a * cos - _c * sin;
//    b = _b * cos - _d * sin;
//    c = _c * cos + _a * sin;
//    d = _d * cos + _b * sin;
  }

  /**
   * A minified affine transform.
   *     |a c tx|
   *     |b d ty|
   *     |0 0  1|
   *     
   *     |- y -|
   *     |x - -|
   *     |0 0 1|
   */
  /// Concatenate skew/shear
  /// [x] and [y] are in radians
  void skew(double x, double y) {
    c += math.tan(y);
    b += math.tan(x);
  }
  
  /**
   * A pre multiply order.
   */
  void preMultiply(AffineTransform t) {
    double _a = a;
    double _b = b;
    double _c = c;
    double _d = d;
    double _tx = tx;
    double _ty = ty;
    
    a = _a * t.a + _b * t.c;
    b = _a * t.b + _b * t.d;
    c = _c * t.a + _d * t.c;
    d = _c * t.b + _d * t.d;
    tx = (_tx * t.a) + (_ty * t.c) + t.tx;
    ty = (_tx * t.b) + (_ty * t.d) + t.ty;
  }
  
  void multiply(AffineTransform t1, AffineTransform t2) {
    a = t1.a * t2.a + t1.b * t2.c;
    b = t1.a * t2.b + t1.b * t2.d;
    c = t1.c * t2.a + t1.d * t2.c;
    d = t1.c * t2.b + t1.d * t2.d;
    tx = t1.tx * t2.a + t1.ty * t2.c + t2.tx;
    ty = t1.tx * t2.b + t1.ty * t2.d + t2.ty;
  }

  void invert() {
    double determinant = 1.0 / (a * d - b * c);
    double _a = a;
    double _b = b;
    double _c = c;
    double _d = d;
    double _tx = tx;
    double _ty = ty;

    a =  determinant * _d;
    b = -determinant * _b;
    c = -determinant * _c;
    d =  determinant * _a;
    tx = determinant * (_c * _ty - _d * _tx);
    ty = determinant * (_b * _tx - _a * _ty);
  }
  
  /**
   * Converts either from or to pre or post multiplication.
   *     a c
   *     b d
   * to
   *     a b
   *     c d
   */
  void transpose() {
    double _c = c;
   
    c = b;
    b = _c;
    // tx and ty are implied for partial 2x3 matrices
  }
  
  double extractUniformScale() {
    Vector2P p = new Vector2P.withCoords(0.0, 0.0);
    double length = 0.0;
    
    CompApplyAffineTransformTo(1.0, 0.0, p.v, this);
    length = p.v.length;
    p.moveToPool();
    
    return length;
  }
  
  String toString() {
    StringBuffer s = new StringBuffer();
    s.writeln("|${a.toStringAsFixed(2)}, ${b.toStringAsFixed(2)}, ${tx.toStringAsFixed(2)}|");
    s.writeln("|${c.toStringAsFixed(2)}, ${d.toStringAsFixed(2)}, ${ty.toStringAsFixed(2)}|");
    return s.toString();
  }
}

/// Returns a pooled object.
Vector2P PointApplyAffineTransform(Vector2 point, AffineTransform t) {
  return CompApplyAffineTransform(point.x, point.y, t);
}

Vector2P CompApplyAffineTransform(double x, double y, AffineTransform t) {
  return new Vector2P.withCoords(
      (t.a * x) + (t.c * y) + t.tx,
      (t.b * x) + (t.d * y) + t.ty);
}

void CompApplyAffineTransformTo(double x, double y, Vector2 out, AffineTransform t) {
  out.setValues(
      (t.a * x) + (t.c * y) + t.tx,
      (t.b * x) + (t.d * y) + t.ty);
}

void SizeApplyAffineTransform(Size size, AffineTransform t) {
  size.width = (t.a * size.width + t.c * size.height).toInt();
  size.height = (t.b * size.width + t.d * size.height).toInt();
}

/// Returns a poolable object.
MutableRectangle<double> RectApplyAffineTransform(MutableRectangle<double> rect, AffineTransform at) {
  double top    = rect.top;
  double right  = rect.right;
  double left   = rect.left;
  double bottom = rect.bottom;
  
  Vector2 topLeft = Vectors.v[0];
  Vector2 topRight = Vectors.v[1];
  Vector2 bottomLeft = Vectors.v[2];
  Vector2 bottomRight = Vectors.v[3];

  topLeft.setValues(
      (at.a * left) + (at.c * top) + at.tx,
      (at.b * left) + (at.d * top) + at.ty);
  topRight.setValues(
      (at.a * right) + (at.c * top) + at.tx,
      (at.b * right) + (at.d * top) + at.ty);
  bottomLeft.setValues(
      (at.a * left) + (at.c * bottom) + at.tx,
      (at.b * left) + (at.d * bottom) + at.ty);
  bottomRight.setValues(
      (at.a * right) + (at.c * bottom) + at.tx,
      (at.b * right) + (at.d * bottom) + at.ty);

  double mm1 = topLeft.x < topRight.x ? topLeft.x : topRight.x;
  double mm2 = bottomLeft.x < bottomRight.x ? bottomLeft.x : bottomRight.x;
  double minX = mm1 < mm2 ? mm1 : mm2;

  mm1 = topLeft.x > topRight.x ? topLeft.x : topRight.x;
  mm2 = bottomLeft.x > bottomRight.x ? bottomLeft.x : bottomRight.x;
  double maxX = mm1 > mm2 ? mm1 : mm2;
  
  mm1 = topLeft.y < topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y < bottomRight.y ? bottomLeft.y : bottomRight.y;
  double minY = mm1 < mm2 ? mm1 : mm2;

  mm1 = topLeft.y > topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y > bottomRight.y ? bottomLeft.y : bottomRight.y;
  double maxY = mm1 > mm2 ? mm1 : mm2;
  
  return new MutableRectangle<double>.withP(minX, minY, (maxX - minX), (maxY - minY));
}
/**
 * [rect] rectangle to transform.
 * [rectOut] the results.
 * [at] The transform to use.
 */
void RectApplyAffineTransformTo(MutableRectangle<double> rect, MutableRectangle<double> rectOut, AffineTransform at) {
  double top    = rect.top;
  double right  = rect.right;
  double left   = rect.left;
  double bottom = rect.bottom;
  
  Vector2 topLeft = Vectors.v[0];
  Vector2 topRight = Vectors.v[1];
  Vector2 bottomLeft = Vectors.v[2];
  Vector2 bottomRight = Vectors.v[3];

  topLeft.setValues(
      (at.a * left) + (at.c * top) + at.tx,
      (at.b * left) + (at.d * top) + at.ty);
  topRight.setValues(
      (at.a * right) + (at.c * top) + at.tx,
      (at.b * right) + (at.d * top) + at.ty);
  bottomLeft.setValues(
      (at.a * left) + (at.c * bottom) + at.tx,
      (at.b * left) + (at.d * bottom) + at.ty);
  bottomRight.setValues(
      (at.a * right) + (at.c * bottom) + at.tx,
      (at.b * right) + (at.d * bottom) + at.ty);

  //CompApplyAffineTransformTo(left, top, topLeft, at);
  //CompApplyAffineTransformTo(right, top, topRight, at);
  //CompApplyAffineTransformTo(left, bottom, bottomLeft, at);
  //CompApplyAffineTransformTo(right, bottom, bottomRight, at);

  double mm1 = topLeft.x < topRight.x ? topLeft.x : topRight.x;
  double mm2 = bottomLeft.x < bottomRight.x ? bottomLeft.x : bottomRight.x;
  double minX = mm1 < mm2 ? mm1 : mm2;
  //double minX = math.min(math.min(topLeft.x, topRight.x), math.min(bottomLeft.x, bottomRight.x));

  mm1 = topLeft.x > topRight.x ? topLeft.x : topRight.x;
  mm2 = bottomLeft.x > bottomRight.x ? bottomLeft.x : bottomRight.x;
  double maxX = mm1 > mm2 ? mm1 : mm2;
  //double maxX = math.max(math.max(topLeft.x, topRight.x), math.max(bottomLeft.x, bottomRight.x));
  
  mm1 = topLeft.y < topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y < bottomRight.y ? bottomLeft.y : bottomRight.y;
  double minY = mm1 < mm2 ? mm1 : mm2;
  //double minY = math.min(math.min(topLeft.y, topRight.y), math.min(bottomLeft.y, bottomRight.y));

  mm1 = topLeft.y > topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y > bottomRight.y ? bottomLeft.y : bottomRight.y;
  double maxY = mm1 > mm2 ? mm1 : mm2;
  //double maxY = math.max(math.max(topLeft.y, topRight.y), math.max(bottomLeft.y, bottomRight.y));
  
  rectOut.left = minX;
  rectOut.bottom = minY;
  rectOut.width = maxX - minX;
  rectOut.height = maxY - minY;
}

/// [rect] is overlayed
void RectangleApplyAffineTransform(MutableRectangle<double> rect, AffineTransform at) {
  double top    = rect.top;
  double right  = rect.right;
  double left   = rect.left;
  double bottom = rect.bottom;
  
  Vector2 topLeft = Vectors.v[0];
  Vector2 topRight = Vectors.v[1];
  Vector2 bottomLeft = Vectors.v[2];
  Vector2 bottomRight = Vectors.v[3];

  topLeft.setValues(
      (at.a * left) + (at.c * top) + at.tx,
      (at.b * left) + (at.d * top) + at.ty);
  topRight.setValues(
      (at.a * right) + (at.c * top) + at.tx,
      (at.b * right) + (at.d * top) + at.ty);
  bottomLeft.setValues(
      (at.a * left) + (at.c * bottom) + at.tx,
      (at.b * left) + (at.d * bottom) + at.ty);
  bottomRight.setValues(
      (at.a * right) + (at.c * bottom) + at.tx,
      (at.b * right) + (at.d * bottom) + at.ty);

  double mm1 = topLeft.x < topRight.x ? topLeft.x : topRight.x;
  double mm2 = bottomLeft.x < bottomRight.x ? bottomLeft.x : bottomRight.x;
  double minX = mm1 < mm2 ? mm1 : mm2;

  mm1 = topLeft.x > topRight.x ? topLeft.x : topRight.x;
  mm2 = bottomLeft.x > bottomRight.x ? bottomLeft.x : bottomRight.x;
  double maxX = mm1 > mm2 ? mm1 : mm2;
  
  mm1 = topLeft.y < topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y < bottomRight.y ? bottomLeft.y : bottomRight.y;
  double minY = mm1 < mm2 ? mm1 : mm2;

  mm1 = topLeft.y > topRight.y ? topLeft.y : topRight.y;
  mm2 = bottomLeft.y > bottomRight.y ? bottomLeft.y : bottomRight.y;
  double maxY = mm1 > mm2 ? mm1 : mm2;

  rect.left = minX;
  rect.bottom = minY;
  rect.width = maxX - minX;
  rect.height = maxY - minY;
}

AffineTransform AffineTransformTranslate(AffineTransform t, double tx, double ty) {
  return new AffineTransform._poolable(
      t.a, 
      t.b, 
      t.c, 
      t.d, 
      t.tx + t.a * tx + t.c * ty, 
      t.ty + t.b * tx + t.d * ty);
}

AffineTransform AffineTransformScale(AffineTransform t, double sx, double sy) {
  return new AffineTransform._poolable(
      t.a * sx, 
      t.b * sx, 
      t.c * sy, 
      t.d * sy, 
      t.tx, 
      t.ty);
}

/**
 * Rotation is just a matter of perspective. A CW rotation can be seen as
 * CCW depending on what you are talking about rotating. For example,
 * if the coordinate system is thought as rotating CCW then objects are
 * seen as rotating CW. And that is what the 2x2 matrix below represents
 * with Canvas2D.
 *     |cos  -sin|   object appears to rotate CW.
 *     |sin   cos|
 * 
 * In the matrix below the object appears to rotate CCW.
 *     |cos  sin|   
 *     |-sin cos|
 *     
 *     |a  c|    |cos  -sin|
 *     |b  d|  x |sin   cos|
 *     
 */
AffineTransform AffineTransformRotate(AffineTransform t, double anAngle) {
  double sin = math.sin(anAngle);
  double cos = math.cos(anAngle);

  AffineTransform at = new AffineTransform._poolable(
      t.a * cos + t.c * sin,
      t.b * cos + t.d * sin,
      t.c * cos - t.a * sin,
      t.d * cos - t.b * sin,
      t.tx,
      t.ty);

//  AffineTransform at = new AffineTransform._poolable(
//      t.a * cos - t.c * sin,
//      t.b * cos - t.d * sin,
//      t.c * cos + t.a * sin,
//      t.d * cos + t.b * sin,
//      t.tx,
//      t.ty);

  return at;
}

/**
 * Concatenate `t2' to `t1' and return the result: t' = t1 * t2
 * returns a [Poolable]ed [AffineTransform].     
 */
AffineTransform affineTransformMultiply(AffineTransform t1, AffineTransform t2) {
  AffineTransform t = new AffineTransform._poolable(
      t1.a * t2.a + t1.b * t2.c,
      t1.a * t2.b + t1.b * t2.d,
      t1.c * t2.a + t1.d * t2.c, 
      t1.c * t2.b + t1.d * t2.d,
      t1.tx * t2.a + t1.ty * t2.c + t2.tx,
      t1.tx * t2.b + t1.ty * t2.d + t2.ty);
  return t;
}

/**
 * Multiply [tA] x [tB] and place in [tB]
 */
void affineTransformMultiplyTo(AffineTransform tA, AffineTransform tB) {
  double a = tA.a * tB.a + tA.b * tB.c;
  double b = tA.a * tB.b + tA.b * tB.d;
  double c = tA.c * tB.a + tA.d * tB.c; 
  double d = tA.c * tB.b + tA.d * tB.d;
  double tx = tA.tx * tB.a + tA.ty * tB.c + tB.tx;
  double ty = tA.tx * tB.b + tA.ty * tB.d + tB.ty;
  tB.a = a;
  tB.b = b;
  tB.c = c;
  tB.d = d;
  tB.tx = tx;
  tB.ty = ty;
}

/**
 * Multiply [tA] x [tB] and place in [tA]
 */
void affineTransformMultiplyFrom(AffineTransform tA, AffineTransform tB) {
  double a = tA.a * tB.a + tA.b * tB.c;
  double b = tA.a * tB.b + tA.b * tB.d;
  double c = tA.c * tB.a + tA.d * tB.c; 
  double d = tA.c * tB.b + tA.d * tB.d;
  double tx = tA.tx * tB.a + tA.ty * tB.c + tB.tx;
  double ty = tA.tx * tB.b + tA.ty * tB.d + tB.ty;
  tA.a = a;
  tA.b = b;
  tA.c = c;
  tA.d = d;
  tA.tx = tx;
  tA.ty = ty;
}

/* Return true if `t1' and `t2' are equal, false otherwise. */
bool AffineTransformEqualToTransform(AffineTransform t1, AffineTransform t2) {
  return (t1.a == t2.a && t1.b == t2.b && t1.c == t2.c && t1.d == t2.d && t1.tx == t2.tx && t1.ty == t2.ty);
}

AffineTransform AffineTransformInvert(AffineTransform t) {
  double determinant = 1.0 / (t.a * t.d - t.b * t.c);

  AffineTransform at = new AffineTransform._poolable(
      determinant * t.d,
     -determinant * t.b,
     -determinant * t.c,
      determinant * t.a,
      determinant * (t.c * t.ty - t.d * t.tx),
      determinant * (t.b * t.tx - t.a * t.ty) );
  
  return at;
}

/**
 * Invert [t] to [to].
 */
void AffineTransformInvertTo(AffineTransform t, AffineTransform to) {
  double determinant = 1.0 / (t.a * t.d - t.b * t.c);

   to.a = determinant * t.d;
   to.b = -determinant * t.b;
   to.c = -determinant * t.c;
   to.d = determinant * t.a;
   to.tx = determinant * (t.c * t.ty - t.d * t.tx);
   to.ty = determinant * (t.b * t.tx - t.a * t.ty);
}