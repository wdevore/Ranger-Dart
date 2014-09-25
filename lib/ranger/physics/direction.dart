part of ranger;

/**
 * [Direction]
 * Default direction is +X axis.
 */
class Direction {
  Vector2 vector = new Vector2(1.0, 0.0);
  
  Direction();
  
  Direction.withVelocity(Direction velocity) {
    vector.setFrom(velocity.vector);
  }

  Direction.withComponents(double x, double y) {
    vector.setValues(x, y);
  }
  
  set directionByDegrees(double angle) {
    directionByRadians = degreesToRadians(angle);
  }

  set directionByRadians(double angle) {
    vector.setValues(math.cos(angle), math.sin(angle));
  }

  set directionByVector(Vector2 v) {
    vector.setFrom(v);
  }
  
  double get asAngle => math.atan2(vector.y, vector.x);
  double get asAngleInDegrees => radiansToDegrees(math.atan2(vector.y, vector.x));
  
  void setTo(Direction dir) {
    vector.setFrom(dir.vector);
  }
  
  String toString() => "$vector";
  
}