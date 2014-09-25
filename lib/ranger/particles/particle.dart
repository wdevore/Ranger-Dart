part of ranger;

/**
 * The base for all particles. It is a none visual class.
 * For particles to be seen you must implement a "visual".
 */
abstract class Particle extends ComponentPoolable {
  Object data;
  bool pooled = false;
  
  double elapsed = 0.0;
  double lifespan = 0.0;
  
  Velocity velocity = new Velocity();
  
  bool active = false;
  
  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  bool initWithLifespan(double lifespan) {
    this.lifespan = lifespan;
    elapsed = 0.0;
    return true;
  }

  Particle clone();
  
  BaseNode get visual;
  
  void update(double dt) {
    elapsed += dt;

    double t = elapsed / lifespan;
    t = t < 1.0 ? t : 1.0;  // clamp at 1.0

    step(t > 0.0 ? t : 0.0);
  }
  
  void step(double time);
  
  bool get isDead => elapsed >= lifespan;

  void deActivate() {
    active = false;
  }
  
  void activate(double x, double y, Velocity velocity, double lifespan);
  void activateAt(double x, double y);
  
  void activateWithVelocityAndLife(Velocity velocity, double lifespan) {
    active = true;
    elapsed = 0.0;
    this.velocity.setTo(velocity);
    this.lifespan = lifespan;
  }
  
  String toString() => "lifespan: $lifespan, velocity:$velocity";
}