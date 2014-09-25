part of ranger;

abstract class Polygon extends ComponentPoolable {
  List<Vector2> points = new List<Vector2>();
  
  MutableRectangle<double> aabbox = new MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);

  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  Polygon();
  
  bool isPointInside(Vector2 p) {
    int i = 0;
    bool c = false;
    int nvert = points.length;
    for (int j = nvert - 1; i < nvert; j = i++) {
      if ( ((points[i].y > p.y) != (points[j].y > p.y)) &&
       (p.x < (points[j].x-points[i].x) * (p.y - points[i].y) /
              (points[j].y-points[i].y) + points[i].x) ) {
        c = !c;
      }
    }
    return c;
  }
  
  void calcAABBox() {
    
    double minX = double.MAX_FINITE;
    double minY = double.MAX_FINITE;
    double maxX = -double.MAX_FINITE;
    double maxY = -double.MAX_FINITE;
    
    for(Vector2 v in points) {
      // Track min/max corners.
      if (v.x < minX)
          minX = v.x;
      if (v.x > maxX)
          maxX = v.x;
      
      if (v.y < minY)
          minY = v.y;
      if (v.y > maxY)
          maxY = v.y;
    }
    
    aabbox.left = minX;
    aabbox.bottom = minY;
    aabbox.width = maxX - minX;
    aabbox.height = maxY - minY;
  }
  
  String toString() => "points: ${points.length}";
}

