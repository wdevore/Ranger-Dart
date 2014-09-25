part of ranger;

/**
 * [TweenParticle] controls a single [BaseNode]'s
 * position, color, scale and rotation. Use with the Universal Tween Engine.
 */
class TweenParticle extends PositionalParticle implements UTE.Tweenable {
  static const int SCALE = 1;
  static const int COLOR = 2;
  static const int ROTATE = 3;

  double fromScale = 1.0;
  double toScale = 1.0;
  Color4<int> fromColor = Color4IOrange;
  Color4<int> toColor = Color4IBlue;
  Color4<int> color = Color4IWhite;

  double fromRotation = 0.0;
  double toRotation = 359.0;
  double rate;
  int interpolate;

  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  TweenParticle._();
  
  /**
   * Construct a poolable [TweenParticle]
   * [node] - The affected node by this particle.
   */
  factory TweenParticle.withNode(BaseNode node) {
    TweenParticle p = new TweenParticle._poolable();
    
    p.initWithNode(node);
    
    return p;
  }

  factory TweenParticle._poolable() {
    TweenParticle poolable = new Poolable.of(TweenParticle, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  static TweenParticle _createPoolable() => new TweenParticle._();

  TweenParticle clone() {
    // First clone the visual
    BaseNode nodeClone = node.clone();
    
    // Now create a new particle behavior that will affect the cloned visual.
    TweenParticle p = new TweenParticle.withNode(nodeClone);
    
    // Copy the properties from this particle to the cloned version.
    p.fromColor.setWith(fromColor);
    p.color.setWith(fromColor);
    p.toColor.setWith(toColor);
    
    p.fromRotation = fromRotation;
    p.toRotation = toRotation;
    
    p.fromScale = fromScale;
    p.toScale = toScale;
    p.node.uniformScale = fromScale;
    
    p.interpolate = interpolate;
    p.rate = rate;
    
    return p;
  }
  
  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
    //print("getTweenableValues: ${node}, tweenType:$tweenType, values: ${returnValues}");
    switch(tweenType) {
      case SCALE:
        returnValues[0] = node.uniformScale;
        return 1;
      case ROTATE:
        returnValues[0] = node.rotationInDegrees;
        return 1;
      case COLOR:
        returnValues[0] = color.r;
        returnValues[1] = color.g;
        returnValues[2] = color.b;
        returnValues[3] = color.a;
        return 4;
    }
    
    return 0;
  }

  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
    //print("setTweenableValues: ${node}, tweenType:$tweenType, values: ${newValues}");
    switch(tweenType) {
      case SCALE:
        node.uniformScale = newValues[0];
        node.dirty = true;
        break;
      case ROTATE:
        // newValue has the interpolated value. We are ignoring it
        // here in favor of our own linear rate. Of course I could just
        // as easily implemented the step() method and modify rotation
        // their alternatively.
        // Doing the "rate" here means I am nulling the purpose of the
        // Tween engine.
        //node.rotationByDegrees = newValues[0];
        node.rotationByDegrees = node.rotationInDegrees + rate;
        node.dirty = true;
        break;
      case COLOR:
        color.r = newValues[0].ceil();
        color.g = newValues[1].ceil();
        color.b = newValues[2].ceil();
        color.a = newValues[3].ceil();
        
        if (node is Color4Mixin) {
          Color4Mixin cb = node as Color4Mixin;
          cb.color.setWith(color);
        }
        break;
    }
  }

//  void _tweenCallbackHandler(int type, Tween.BaseTween source) {
//    switch(type) {
//      case Tween.TweenCallback.BEGIN:
//        break;
//      default:
//        print('DEFAULT CALLBACK CAUGHT ; type = ' + type.toString());
//    }
//  }

  /**
   * [activateAt] requires that the particle's [data] property
   * be populated otherwise an Exception is thrown. 
   */
  @override
  void activateAt(double x, double y) {
    super.activateAt(x, y);
    
    color.setWith(fromColor);
    
    if (data != null) {
      ActivationData pd = data as ActivationData;

      rate = pd.rotationRate;
      fromScale = pd.startScale;
      toScale = pd.endScale;
      fromColor.setWith(pd.startColor);
      toColor.setWith(pd.endColor);
      node.uniformScale = fromScale;
      acceleration = pd.acceleration;
      //velocity.setTo(pd.velocity);
      //print(acceleration);
      //velocity.speed = pd.speed;
      //velocity.limitMagnitude = pd.velocity.limitMagnitude;
      
      activateWithVelocityAndLife(pd.velocity, pd.lifespan);

      UTE.Tween.combinedAttributesLimit = 4;
      UTE.Timeline par = new UTE.Timeline.parallel();

      UTE.Timeline seq = new UTE.Timeline.sequence();
      double scaleSegtime = (pd.lifespan - pd.delay).abs();
      
      seq..pushPause(pd.delay)
         ..push(
          new UTE.Tween.to(this, SCALE, scaleSegtime / 2.0)
                ..easing = UTE.Elastic.OUT
                ..targetValues = [toScale]
          )
          ..push(
           new UTE.Tween.to(this, SCALE, scaleSegtime / 5.0)
                 ..easing = UTE.Linear.INOUT
                 ..targetValues = [fromScale]
           );
      
      par..push(seq)
         ..push(
            new UTE.Tween.to(this, COLOR, pd.lifespan)
                ..easing = UTE.Linear.INOUT
                ..targetValues = [toColor.r, toColor.g, toColor.b, toColor.a]
            )
        ..push(
            new UTE.Tween.to(this, ROTATE, pd.lifespan)
                ..easing = UTE.Linear.INOUT
                ..targetRelative = [toRotation]
            )
        ..start(RandomValueParticleActivator.tweenMan);
    }
    else {
      // TODO throw exception
      print("!!!!!!!! Particle data not present");
    }
        
 }

  void step(double time) {
    super.step(time);
  }

}