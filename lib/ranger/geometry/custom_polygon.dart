part of ranger;

class CustomPolygon extends Polygon {
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  CustomPolygon._();
  
  /// [CustomPolygon] points along the +X axis.
  factory CustomPolygon.basic() {
    CustomPolygon poolable = new Poolable.of(CustomPolygon, _create);
    return poolable;
  }

  static CustomPolygon _create() => new CustomPolygon._();
}

