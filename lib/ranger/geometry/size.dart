part of ranger;

class Size<T extends num> {
  T width;
  T height;
  
  // ----------------------------------------------------------
  // Constructors
  // ----------------------------------------------------------
  Size(this.width, this.height);

  Size.withPoint(math.Point point) {
    set(point.x, point.y);
  }
  
  Size.withSize(Size other) {
    width = other.width;
    height = other.height;
  }
  
  Size.zero();
  
  Size.withWidthHeight(T width, T height) {
    this.width = width;
    this.height = height;
  }
  
  // ----------------------------------------------------------
  // Operators
  // ----------------------------------------------------------
  bool operator ==(Size target) {
    return ((width == target.width) && (height == target.height));
  }
  
  Size operator /(T a) {
    return new Size(width / a, height / a);
  }
  
  Size operator +(Size right) {
    return new Size(this.width + right.width, this.height + right.height);
  }

  Size operator -(Size right) {
    return new Size(this.width - right.width, this.height - right.height);
  }

  Size operator *(T a) {
    return new Size(this.width * a, this.height * a);
  }

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  void set(T width, T height) {
    this.width = width;
    this.height = height;
  }

  static bool equal(Size size1, Size size2) => ((size1.width == size2.width) && (size1.height == size2.height));

  bool equalByWidthHeight(T width, T height) => ((this.width == width) && (this.height == height));
  
  String toString() => "[$width, $height]";
}
