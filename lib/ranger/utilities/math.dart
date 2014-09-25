part of ranger;

const double PIOver180 = 0.017453292519943295;
const double TWO_PI = 2.0 * math.PI;
const double EPSILON = 0.0000001192092896;

final double MAX_DOUBLE = math.pow(2.0, 29);

double degreesToRadians(double degrees) {
  return degrees * PIOver180;
}

double radiansToDegrees(double radians) {
  return radians / PIOver180;
}

double angleBetween(Vector2 a, Vector2 b) {
  a.normalize();
  b.normalize();
  double angle = math.atan2(a.cross(b), a.dot(b));

  if (angle.abs() < EPSILON)
    return 0.0;

  return angle;
}

void perpendicular(Vector2 v) {
  double t = v.x;
  v.x = -v.y;
  v.y = t;
}

class Vectors {
  static List<Vector2> v = new List<Vector2>.generate(10, (int index) => new Vector2.zero()); 
}