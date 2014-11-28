part of ranger;

// Sound generation parameters are on [0,1] unless noted SIGNED & thus
// on [-1,1]
class SoundUtilities {
  static math.Random _randGen = new math.Random();

  static double frnd(double range) => _randGen.nextDouble() * range;

  static double rndr(double from, double to) => _randGen.nextDouble() * (to - from) + from;

  static int rnd(double max) => (_randGen.nextDouble() * (max + 1.0)).floor();

  static bool get yes => _randGen.nextBool();

  static double sqr(double v) =>  v*v;
  static double cube(double v) =>  v*v*v;
  static double log(double x, double b) => math.log(x) / math.log(b);
  static double flurp(x) => x / (1.0 - x);
  
  static double randomDouble() => _randGen.nextDouble();
}