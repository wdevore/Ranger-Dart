part of ranger;

/**
 * [Velocity]'s direction is alway defined relative to the +X axis.
 * Default direction is +X axis.
 */
class Velocity {
  double magnitude = 0.0;
  double minMagnitude = 0.0;
  double maxMagnitude = 0.0;
  
  Vector2 direction = new Vector2(0.0, 0.0);
  
  bool limitMagnitude = true;
  
  Velocity();
  
  Velocity.withVelocity(Velocity velocity) {
    magnitude = velocity.magnitude;
    minMagnitude = velocity.minMagnitude;
    maxMagnitude = velocity.maxMagnitude;
    
    direction.setFrom(velocity.direction);
  }

  Velocity.withComponents(double x, double y, double speed) {
    magnitude = speed;
    direction.setValues(x, y);
  }

  set velocity(Velocity velocity) {
    magnitude = velocity.magnitude;
    minMagnitude = velocity.minMagnitude;
    maxMagnitude = velocity.maxMagnitude;
    
    direction.setFrom(velocity.direction);
  }


  void setSpeedRange(double min, double max) {
    minMagnitude = min;
    maxMagnitude = max;    
  }
  
  set speed(double mag) {
    if (limitMagnitude) {
      magnitude = mag > maxMagnitude ? maxMagnitude : mag;
      magnitude = mag < minMagnitude ? minMagnitude : mag;
    }
    else {
      magnitude = mag;
    }
  }
  double get speed => magnitude;
  
  void accelerate(double acceleration) {
    magnitude += acceleration;
    if (limitMagnitude) {
      magnitude = magnitude > maxMagnitude ? maxMagnitude : magnitude;
      magnitude = magnitude < minMagnitude ? minMagnitude : magnitude;
    }
  }

  void increaseSpeed(double mag) {
    magnitude += mag;
    if (limitMagnitude) {
      magnitude = magnitude > maxMagnitude ? maxMagnitude : magnitude;
    }
  }
  
  void decreaseSpeed(double mag) {
    magnitude -= mag;
    if (limitMagnitude) {
      magnitude = magnitude < minMagnitude ? minMagnitude : magnitude;
    }
  }

  set directionByDegrees(double angle) {
    directionByRadians = degreesToRadians(angle);
  }

  set directionByRadians(double angle) {
    direction.setValues(math.cos(angle), math.sin(angle));
  }

  set directionByVector(Vector2 v) {
    direction.setFrom(v);
  }
  
  /// Returns a poolable object.
  Vector2P get asVector {
    Vector2P v = new Vector2P();
    v.v.setValues(direction.x * magnitude, direction.y * magnitude);
    return v;
  }
  
  double get asAngle => math.atan2(direction.y, direction.x);
  double get asAngleInDegrees => radiansToDegrees(math.atan2(direction.y, direction.x));
  
  void setTo(Velocity velocity) {
    direction.setFrom(velocity.direction);
    minMagnitude = velocity.minMagnitude;
    maxMagnitude = velocity.maxMagnitude;
    magnitude = velocity.magnitude;
    limitMagnitude = velocity.limitMagnitude;
  }
  
  void add(Velocity velocity) {
    Vector2P v1 = asVector;
    Vector2P v2 = velocity.asVector;
    
    v1.v.add(v2.v);
    double len = v1.v.length;
    
    // Clamp to max
    magnitude = len < maxMagnitude ? len : maxMagnitude;
    
    direction.setFrom(v1.v);
    direction.normalize();
    
    v1.moveToPool();
    v2.moveToPool();
  }
  
  void sub(Velocity velocity) {
    Vector2P v1 = asVector;
    Vector2P v2 = velocity.asVector;
    
    v2.v.sub(v1.v);
    double len = v2.v.length;
    
    // Clamp to max
    magnitude = len < maxMagnitude ? len : maxMagnitude;
    
    direction.setFrom(v2.v);
    direction.normalize();
    
    v1.moveToPool();
    v2.moveToPool();
  }
  
  /// Apply velocity to vector/point.
  void applyTo(Vector2 vector) {
    Vector2P v1 = asVector;

    vector.add(v1.v);
        
    v1.moveToPool();
  }
  
  /// Apply [velocity] to this velocity.
  void applyToVelocity(Velocity velocity) {
    direction.add(velocity.direction);
    direction.normalize();
    
    magnitude += velocity.magnitude;
    
    // Clamp to max
    magnitude = magnitude > maxMagnitude ? maxMagnitude : magnitude;
  }
  
  String toString() => "mag: ${magnitude.toStringAsFixed(4)}, dir: [${direction.x.toStringAsFixed(2)}, ${direction.y.toStringAsFixed(2)}], min/max:(${minMagnitude.toStringAsFixed(2)}, ${maxMagnitude.toStringAsFixed(2)})";
  
}