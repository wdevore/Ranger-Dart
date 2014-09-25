part of ranger;

// This is a debug visual that is a Box and Stick
class ParticleSystemVisual extends Node {
  String drawColor = Color3IBlack.toString();
  String emitterDirColor = Color3IBlue.toString();
  
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  double outlineThickness = 1.0;
  
  MutableRectangle<double> rect = new MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  ParticleSystem ps;
  
  ParticleSystemVisual();
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  ParticleSystemVisual._();
  
  factory ParticleSystemVisual.withPS(ParticleSystem ps) {
    ParticleSystemVisual poolable = new ParticleSystemVisual.pooled();
    poolable.ps = ps;
    return poolable;
  }
  
  factory ParticleSystemVisual.pooled() {
    ParticleSystemVisual poolable = new Poolable.of(ParticleSystemVisual, _createPoolable);
    poolable.pooled = true;
    poolable.init();
    return poolable;
  }

  static ParticleSystemVisual _createPoolable() => new ParticleSystemVisual._();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  @override
  bool init() {
    super.init();
    size = 1.0;
    return true;
  }
  
  void center() {
    rect.left = rect.left - (rect.width / 2.0);
    rect.bottom = rect.bottom - (rect.height / 2.0);
  }
  
  set size(double s) {
    rect.width = s;
    rect.height = s;
    center();
  }

  @override
  void update(double dt) {
  }
  
  @override
  void draw(DrawContext context) {
    context.save();
    
    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;
    
    context.fillColor = null;
    context.drawColor = drawColor;
    context.drawRect(rect.left, rect.bottom, rect.width, rect.height);
    
    // draw direction line
    ls.setValues(0.0, 0.0);
    Direction direction = ps.particleActivation.direction;
    
    le.setValues(direction.vector.x * 25.0, direction.vector.y * 25.0);
    
    context.drawColor = emitterDirColor;
    context.drawLine(ls, le);
    
    context.restore();
  }
}
