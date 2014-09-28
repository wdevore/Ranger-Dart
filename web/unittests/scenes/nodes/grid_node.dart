part of unittests;

class GridNode extends Ranger.Node {
  double width;
  double height;
  double majorSpacing = 100.0;
  double minorSpacing = 25.0;
  
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  String majorColor = "#555555";
  String minorColor = "#aaaaaa";
  
  bool centered;
  
  Vector2 dimension = new Vector2.zero();
  
  Ranger.AffineTransform ainv;

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  //GridNode(this.width, this.height, this.centered);
  GridNode();
  
  GridNode._();

  factory GridNode.withDimensions(double width, double height, [bool centered = false]) {
    GridNode poolable = new Ranger.Poolable.of(GridNode, _createPoolable);
    poolable.init();
    poolable.width = width;
    poolable.height = height;
    poolable.centered = centered;
    return poolable;
  }

  static GridNode _createPoolable() => new GridNode._();

  @override
  set dirty(bool dirty) {
    super.dirty = dirty;
    
    // To draw the grid full dimensions we need to use non-transformed
    // dimensions.
    if (parent != null) {
      ainv = parent.calcInverseTransform();

      dimension.setValues(width, height);
      Ranger.Vector2P tp = Ranger.PointApplyAffineTransform(dimension, ainv);
      dimension.setFrom(tp.v);

      tp.moveToPool();
    }
  }

  // This GridNode needs to know that it was added as a child.
  @override
  void addedAsChild() {
    dirty = true;
  }
  
  @override
  void draw(Ranger.DrawContext context) {

    // Note: we really should extract the length
    if (parent.uniformScale > 1.0)
      context.lineWidth = 1.0 / parent.uniformScale;
    
    if (!centered)
      _drawNonCentered(context, dimension.x, dimension.y);
    else
      _drawCentered(context, dimension.x, dimension.y);
    Ranger.Application.instance.objectsDrawn++;

  }
  
  void _drawCentered(Ranger.DrawContext context, double w, double h) {
    context.drawColor = minorColor;
    
    // Draw horizontal lines moving toward +Y
    for (double r = minorSpacing; r <= h; r += minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(-w, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }
    
    // Draw horizontal lines moving toward -Y
    for (double r = -minorSpacing; r >= -h; r -= minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(-w, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }

    // vertical lines
    for (double c = minorSpacing; c <= w; c += minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, -h);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }

    for (double c = -minorSpacing; c >= -w; c -= minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, -h);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }

    context.drawColor = majorColor;
    // horizontal lines
    for (double r = majorSpacing; r <= h; r += majorSpacing) {
      ls.setValues(-w, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double r = -majorSpacing; r >= -h; r -= majorSpacing) {
      ls.setValues(-w, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double c = majorSpacing; c <= w; c += majorSpacing) {
      ls.setValues(c, -h);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
    for (double c = -majorSpacing; c >= -w; c -= majorSpacing) {
      ls.setValues(c, -h);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
    
    ls.setValues(0.0, -h);
    le.setValues(0.0, h);
    context.drawLine(ls, le);

    ls.setValues(-w, 0.0);
    le.setValues(w, 0.0);
    context.drawLine(ls, le);
    
  }

  void _drawNonCentered(Ranger.DrawContext context, double w, double h) {
    context.drawColor = minorColor;
    for (double r = 0.0; r <= h; r += minorSpacing) {
      if (r % majorSpacing != 0) {
        ls.setValues(0.0, r);
        le.setValues(w, r);
        context.drawLine(ls, le);
      }
    }

    // vertical lines
    for (double c = 0.0; c <= w; c += minorSpacing) {
      if (c % majorSpacing != 0) {
        ls.setValues(c, 0.0);
        le.setValues(c, h);
        context.drawLine(ls, le);
      }
    }
    
    context.drawColor = majorColor;
    // horizontal lines
    for (double r = 0.0; r <= h; r += majorSpacing) {
      ls.setValues(0.0, r);
      le.setValues(w, r);
      context.drawLine(ls, le);
    }

    for (double c = 0.0; c <= w; c += majorSpacing) {
      ls.setValues(c, 0.0);
      le.setValues(c, h);
      context.drawLine(ls, le);
    }
  }
}
