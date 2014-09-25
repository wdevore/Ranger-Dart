part of ranger;

/**
 * Data that is passed to a particle once a [ParticleActivation] activator
 * has filled it with activation values.
 * See [RandomValueParticleActivator] or [ SimpleParticleActivator] for
 * examples.
 */
class ActivationData {
  double lifespan = 0.0;
  double endScale = 0.0;
  double startScale = 0.0;
  double rotationRate = 0.0;
  Velocity velocity = new Velocity();
  double acceleration = 0.0;
  set speed(double s) => velocity.speed = s;
  double get speed => velocity.speed;
  Color4<int> startColor = Color4IRed;
  Color4<int> endColor = Color4IRed;
  double delay = 0.0;
}