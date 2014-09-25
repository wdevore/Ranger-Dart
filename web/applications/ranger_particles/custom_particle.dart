library custom_particle;

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as Tween;

/**
 * [CustomParticle] controls a single [BaseNode]'s
 * position, color, scale and rotation.
 */
class CustomParticle extends Ranger.PositionalParticle implements Tween.Tweenable {
  static const int SCALE = 1;
  static const int COLOR = 2;
  static const int ROTATE = 3;

  double fromScale = 1.0;
  double toScale = 1.0;
  Ranger.Color4<int> fromColor = Ranger.Color4IOrange;
  Ranger.Color4<int> toColor = Ranger.Color4IBlue;
  Ranger.Color4<int> color = Ranger.Color4IWhite;

  double fromRotation = 0.0;
  double toRotation = 359.0;
  double rate;
  int interpolate;

  // ----------------------------------------------------------
  // Poolable support and Factories
  // ----------------------------------------------------------
  CustomParticle._();
  
  /**
   * Construct a poolable [CustomParticle]
   * [node] - The affected node by this particle.
   */
  factory CustomParticle.withNode(Ranger.BaseNode node) {
    CustomParticle p = new CustomParticle._poolable();
    
    p.initWithNode(node);
    
    return p;
  }

  factory CustomParticle._poolable() {
    CustomParticle poolable = new Ranger.Poolable.of(CustomParticle, _createPoolable);
    return poolable;
  }

  static CustomParticle _createPoolable() => new CustomParticle._();

  CustomParticle clone() {
    // First clone the visual
    Ranger.BaseNode nodeClone = node.clone();
    
    // Now create a new particle behavior that will affect the cloned visual.
    CustomParticle p = new CustomParticle.withNode(nodeClone);
    
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
  
  int getTweenableValues(Tween.Tween tween, int tweenType, List<num> returnValues) {
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

  void setTweenableValues(Tween.Tween tween, int tweenType, List<num> newValues) {
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
        
        if (node is Ranger.Color4Mixin) {
          Ranger.Color4Mixin cb = node as Ranger.Color4Mixin;
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
      Ranger.ActivationData pd = data as Ranger.ActivationData;

      rate = pd.rotationRate;
      fromScale = pd.startScale;
      toScale = pd.endScale;
      fromColor.setWith(pd.startColor);
      toColor.setWith(pd.endColor);
      node.uniformScale = fromScale;
      acceleration = pd.acceleration;
      //velocity.speed = pd.speed;
      //velocity.limitMagnitude = pd.velocity.limitMagnitude;
      
      activateWithVelocityAndLife(pd.velocity, pd.lifespan);

      Tween.Tween.combinedAttributesLimit = 4;
      Tween.Timeline par = new Tween.Timeline.parallel();

      par..push(
           new Tween.Tween.to(this, SCALE, pd.lifespan)
                 ..easing = Tween.Linear.INOUT
                 ..targetValues = [toScale]
           )
         ..push(
            new Tween.Tween.to(this, COLOR, pd.lifespan)
                ..easing = Tween.Linear.INOUT
                ..targetValues = [toColor.r, toColor.g, toColor.b, toColor.a]
            )
        ..push(
            new Tween.Tween.to(this, ROTATE, pd.lifespan)
                ..easing = Tween.Linear.INOUT
                ..targetRelative = [toRotation]
            )
        ..start(Ranger.RandomValueParticleActivator.tweenMan);
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