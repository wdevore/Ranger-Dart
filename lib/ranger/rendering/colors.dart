part of ranger;

/**
 * RGB color composed of 3 types of T ([double] or [int])
 * If Type is [double] format should be values of: 0.0 -> 1.0
 * If Type is [int] format should be values of: 0 -> 255
 */
class Color3<T extends num> extends ComponentPoolable {
  T r;
  T g;
  T b;
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  Color3._();

  factory Color3.withRGB(T r, T g, T b) {
    Color3 c = new Color3._poolable(r, g, b);
    return c;
  }

  factory Color3.withColor(Color3<T> color) {
    Color3 c = new Color3._poolable(color.r, color.g, color.b);
    return c;
  }

  factory Color3._poolable(T r, T g, T b) {
    Color3 poolable = new Poolable.of(Color3, _createPoolable);
    poolable.r = r;
    poolable.g = g;
    poolable.b = b;
    return poolable;
  }

//  factory Color3.clone() {
//    Color3 c = new Color3.withRGB(r, g, b);
//    return c;
//  }
  
  static Color3 _createPoolable() => new Color3._();
  
  /// Use if Type is [int]. format returned is "rgb(r,g,b)"
  String toString() => "rgb($r, $g, $b)";
  /// Use if Type is [double]. Scales values by 255. format returned is "rgb(r,g,b)"
  String toStringD() => "rgb(${r * 255.0}, ${g * 255.0}, ${b * 255.0})";
}

/**
 * RGBA color composed of 4 types of T (double or int)
 */
class Color4<T extends num> extends ComponentPoolable {
  T r;
  T g;
  T b;
  T a;
  
  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  Color4._();

  factory Color4.withRGBA(T r, T g, T b, T a) {
    Color4 c = new Color4._poolable(r, g, b, a);
    return c;
  }

  factory Color4.withColor(Color4<T> color) {
    Color4 r = new Color4._poolable(color.r, color.g, color.b, color.a);
    return r;
  }

  factory Color4._poolable(T r, T g, T b, T a) {
    Color4 poolable = new Poolable.of(Color4, _createPoolable);
    poolable.r = r;
    poolable.g = g;
    poolable.b = b;
    poolable.a = a;
    return poolable;
  }

  static Color4 _createPoolable() => new Color4._();
  
  T get alpha => a;
  double get alphaAsFraction => a / 255.0;

  void set(T r, T g, T b, T a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  void setWith(Color4<T> color) {
    r = color.r;
    g = color.g;
    b = color.b;
    a = color.a;
  }

  /// Use if Type is [double]. Multiplies RGB by 255.
  String toStringD() => "rgba(${r * 255.0}, ${g * 255.0}, ${b * 255.0}, $a)";
  /// Use if Type is [int]. Divides alpha by 255.
  String toString() => "rgba($r, $g, $b, ${a / 255.0})";
  String toStringRGB() => "rgb($r, $g, $b)";
}

/// Convert Color3<int> to Color4<double>. Remember to move to pool when
/// done. Otherwise it is reclaimed by the GC.
Color4<double> color3ITo4D(Color3<int> color) {
  Color4<double> color4 = new Color4.withRGBA(color.r.toDouble() / 255.0, color.g.toDouble() / 255.0, color.b / 255.0, 1.0);
  return color4;
}

/// [hex] is of the format: "#aabbcc" or "aabbcc"
Color3<double> color3DFromHex(String hex) {
  int r = _hexToR(hex);  
  int g = _hexToG(hex);  
  int b = _hexToB(hex);
  return new Color3<double>.withRGB(r.toDouble(), g.toDouble(), b.toDouble());
}

/// [hex] is of the format: "#aabbcc" or "aabbcc"
Color3<int> color3IFromHex(String hex) {
  int r = _hexToR(hex);  
  int g = _hexToG(hex);  
  int b = _hexToB(hex);
  return new Color3<int>.withRGB(r, g, b);
}

/// [hex] is of the format: "#aabbcc" or "aabbcc"
Color4<int> color4IFromHex(String hex) {
  int r = _hexToR(hex);  
  int g = _hexToG(hex);  
  int b = _hexToB(hex);
  
  int a = 255;
  if (hex.length > 7)
    a = _hexToA(hex);
  
  return new Color4<int>.withRGBA(r, g, b, a);
}

/// [r],[g],[b],[a] are fractional values: 0.0 -> 1.0
String rgbaDToHex(double r, double g, double b, double a) {
  return "#" + _componentIToHex((r * 255.0).toInt()) + _componentIToHex((g * 255.0).toInt()) + _componentIToHex((b * 255.0).toInt()) + _componentIToHex((a * 255.0).toInt());
}

/// [r],[g],[b],[a] are whole numbers: 0.0 -> 255.0
String rgbaIToHex(int r, int g, int b, int a) {
  return "#" + _componentIToHex(r) + _componentIToHex(g) + _componentIToHex(b) + _componentIToHex(a);
}

int _hexToR(String h) => int.parse((_cutHex(h)).substring(0,2), radix: 16);

int _hexToG(String h) => int.parse((_cutHex(h)).substring(2,4), radix: 16);

int _hexToB(String h) => int.parse((_cutHex(h)).substring(4,6), radix: 16);

int _hexToA(String h) => int.parse((_cutHex(h)).substring(6,8), radix: 16);

String _cutHex(String h) => h.contains("#") ? h.substring(1,h.length) : h;


String _componentIToHex(int c) {
  String hex = c.toRadixString(16);
  return hex.length == 1 ? "0" + hex : hex;
}

// ----------------------------------------------------------
// Colors
// ----------------------------------------------------------
Color4<int> get Color4ITransparent => new Color4<int>.withRGBA(0, 0, 0, 0);
Color4<int> get Color4IWhite => new Color4<int>.withRGBA(255, 255, 255, 255);
Color4<int> get Color4IBlack => new Color4<int>.withRGBA(0, 0, 0, 255);
Color4<int> get Color4IGrey => new Color4<int>.withRGBA(128, 128, 128, 255);
Color4<int> get Color4IRed => new Color4<int>.withRGBA(255, 0, 0, 255);
Color4<int> get Color4IGreen => new Color4<int>.withRGBA(0, 255, 0, 255);
Color4<int> get Color4IBlue => new Color4<int>.withRGBA(0, 0, 255, 255);
Color4<int> get Color4IYellow => new Color4<int>.withRGBA(255, 255, 0, 255);
Color4<int> get Color4INavyBlue => new Color4<int>.withRGBA(10, 20, 100, 255);
Color4<int> get Color4ILightBlue => new Color4<int>.withRGBA(128, 128, 255, 255);
Color4<int> get Color4IGreyBlue => new Color4<int>.withRGBA(72, 100, 180, 255);
Color4<int> get Color4IDarkBlue => new Color4<int>.withRGBA(10, 50, 100, 255);
Color4<int> get Color4IDartBlue => new Color4<int>.withRGBA(109, 157, 235, 255);
Color4<int> get Color4IOrange => new Color4<int>.withRGBA(255, 127, 0, 255);
Color4<int> get Color4IGoldYellow => new Color4<int>.withRGBA(255, 200, 0, 255);
Color4<int> get Color4IGreenYellow => new Color4<int>.withRGBA(173, 255, 47, 255);
Color4<int> get Color4IYellowGreen => new Color4<int>.withRGBA(154, 205, 50, 255);

// Pantone colors
// http://damonbauer.github.io/Pantone-Sass/
Color4<int> get Color4ISkin => color4IFromHex("#fcc89b");
Color4<int> get Color4IPurple => color4IFromHex("#8031a7"); //527-C

Color3<int> get Color3IOrange => new Color3<int>.withRGB(255, 127, 0);
Color3<int> get Color3IRed => new Color3<int>.withRGB(255, 0, 0);
Color3<int> get Color3IGreen => new Color3<int>.withRGB(0, 255, 0);
Color3<int> get Color3IBlue => new Color3<int>.withRGB(0, 0, 255);
Color3<int> get Color3IBlack => new Color3<int>.withRGB(0, 0, 0);
Color3<int> get Color3IWhite => new Color3<int>.withRGB(255, 255, 255);