part of ranger;

/**
 * [BaseNode] is the parent to all [Node]s that participate in Ranger's
 * Scene graph.
 */
abstract class BaseNode extends ComponentPoolable with TimingTarget, ScaleBehavior, RotationBehavior, PositionalBehavior {
  bool isTransitionFinished = true;
  bool _running = false;

  Size<double> _contentSize = new Size<double>(0.0, 0.0);

  /**
   * Indicates if this [Node] is participating in pooling. It determines
   * how the [Node] is cleaned when removed or detached.
   */
  bool _pooled = false;
  
  // Non-pooled transforms.
  /**
   * The current transformation being applied this [Node]
   */
  AffineTransform transform = new AffineTransform.Identity();
  AffineTransform inverseTransform = new AffineTransform.Identity();

  bool _transformDirty = true;
  bool _inverseDirty = true;

  /**
   * If this [Node] is invisible then the [draw] method is not called.
   */
  bool visible = true;

  BaseNode _parent;

  /**
   * [tag]s are used to identify [BaseNode]s by Ids. They can both be
   * handy for developement or for finding [BaseNode]s.
   *
   * Ex:
   * static const int TAG_PLAYER = 1;
   * node1.tag = TAG_PLAYER;
   * node2.tag = TAG_MONSTER;
   * node3.tag = TAG_BOSS;
   */
  int tag;

  /**
   * The a number for controlling the drawing order when the Node is a
   * child of a grouping behavior. Otherwise, first added first draw is
   * the rule.
   *                                                                                                                    
   * The number is relative to its "siblings": children of 
   * the same [parent].                               
   * It's nothing to do with [WebGL]'s z vertex. This one only affects 
   * the draw order of [BaseNode]s.         
   * The larger the number, the later this [BaseNode] will be drawn.
   */
  int drawOrder = 0;

  /**
   * override if you want you [Node] to be clonable. Typically used for
   * transient objects like particles from particle systems.
   */
  BaseNode clone();

  // ----------------------------------------------------------
  // Methods
  // ----------------------------------------------------------
  bool get isRunning => _running;
  bool get pooled => _pooled;
  set pooled(bool p) => _pooled = p;
  
  void _init() {
    _parent = null;
    isTransitionFinished = true;
    _running = false;
    _transformDirty = _inverseDirty = true;
    tag = null;
  }
  
  bool init() {
    _init();
    
    _contentSize.set(0.0, 0.0);

    initWithPositionComponents(this, 0.0, 0.0);

    initWithRotation(this, 0.0);

    initWithScaleComponents(this, 1.0, 1.0);

    return true;
  }

  bool initWith(BaseNode node) {
    _init();
    
    _contentSize.set(node.contentSize.width, node.contentSize.height);

    initWithPositionVector(this, node.position);

    initWithRotation(this, node.rotation);

    initWithScaleVector(this, node.scale);
    
    tag = node.tag;

    return true;
  }
  
  void release();
  
  set parent(BaseNode node) => _parent = node;
  
  BaseNode get parent => _parent;
  
  void setContentSize(double width, double height) {
    if (!_contentSize.equalByWidthHeight(width, height)) {
      _contentSize.set(width, height);
//      _textureAnchorPointInPoints.x = _contentSize.width * _textureAnchorPoint.x;
//      _textureAnchorPointInPoints.y = _contentSize.height * _textureAnchorPoint.y;
      dirty = true;
    }
  }
  
  /**
   * The untransformed [Size] of the node. 
   * The [contentSize] remains the same no matter how the [BaseNode] is transformed.
   * All [BaseNode]s have a size.
   * [Layer] and [Scene] have the same [Size] of the screen.
   */
  Size get contentSize => _contentSize;
  
  /**
   * Event callback that is invoked every time when [BaseNode] enters the 'stage'.                                   
   * If the [BaseNode] enters the 'stage' with a transition, 
   * this event is called when the transition starts.        
   * During [onEnter] you can't access a sibling [BaseNode].                                                    
   * If you override [onEnter], you should call its parent, 
   * e.g., super.[onEnter].
   */
  void onEnter();

  /// This would be overridden by a Mixin/Behavior
  void onEnterNode() {
    isTransitionFinished = false;
    _running = true; // mark running before resumeTiming

    resumeTiming();
  }

  /**
   * Event callback that is invoked when the [BaseNode] enters in the 'stage'.                                                        
   * If the [BaseNode] enters the 'stage' with a transition, this event is 
   * called when the transition finishes. Basically your [BaseNode]s will not
   * be visible until AFTER the transition finishes. Consider placing
   * your logic in [onEnter] if you want to see them during the
   * transition.
   * If you override [onEnterTransitionDidFinish], you shall call its 
   * parent's super.
   */
  void onEnterTransitionDidFinish();

  void onEnterTransitionDidFinishNode() {
    isTransitionFinished = true;
  }

  /**
   * callback that is called every time the [BaseNode] leaves the 'stage'.  
   * If the [BaseNode] leaves the 'stage' with a transition, 
   * this callback is called when the transition starts. 
   */
  void onExitTransitionDidStart();

  void onExitTransitionDidStartNode() {
  }

  /**
   * callback that is called every time the [BaseNode] leaves the 'stage'.                                         
   * If the [BaseNode] leaves the 'stage' with a transition, 
   * this callback is called when the transition finishes. 
   * During [onExit] you can't access a sibling node.                                                             
   * If you override [onExit], you should call its parent.
   */
  void onExit();

  void onExitNode() {
    _running = false;
    
    pauseTiming();
    //componentContainer.removeAll();
  }

  // ----------------------------------------------------------
  // Scheduling
  // ----------------------------------------------------------
  /**
   * Schedules the [update] method as a TimingTarget.
   * It will use the priority number 0.
   * Scheduled methods with a lower value will be called before
   * the ones that have a higher value.
   * Only one [update] method can be scheduled per node.
   */
  void scheduleUpdate() {
    scheduleUpdateWithPriority(Scheduler.NORMAL_PRIORITY);
  }
  
  void scheduleUpdateWithPriority(int priority) {
    this.priority = priority;
    paused = !_running;
    Application.instance.scheduler.scheduleTimingTarget(this);
  }

  /// Unschedules the [update] method.
  void unScheduleUpdate() {
    Application.instance.scheduler.unScheduleTimingTarget(this);
  }
  
  void resumeTiming() {
    // Resume this TimingTarget
    paused = false;
    
    // TODO Resume UpdateTargets foreach...
    //Application.instance.scheduler.pauseUpdateTarget(object);
    
    // TODO Resume Actions
  }
  
  void pauseTiming() {
    // Pause this TimingTarget
    paused = true;
    
    // TODO pause UpdateTargets foreach...
    //Application.instance.scheduler.resumeUpdateTarget(object);
    // TODO pause Actions
  }
  
  void unScheduleAll() {
    unScheduleUpdate();
    // TODO unschedule updatetargets
  }
  
  /**
   * Add this override if you need to perform work during updates.
   * [TimingTarget]'s override.
   * Use to receive updates from the [Scheduler].
   * Note: Components/ComponentContainer are not supported at the moment.
   */
  // @implements TimingTarget
  void update(double dt) {
    
  }

  void updateTransform();
  
  void updateTransforms() {
    
  }
  
  // ----------------------------------------------------------
  // Releasing
  // ----------------------------------------------------------
  void cleanup([bool cleanUp = true]);

  void cleanUpNode([bool cleanUp = true]) {
    unScheduleAll();
  }

  // ----------------------------------------------------------
  // Processing
  // ----------------------------------------------------------
  /** 
   * Visits this [BaseNode].
   */
  bool visit(DrawContext context);
  
  /**
   * Called at the end of all [visit]s. It is good place for code that
   * counts objects drawn or perhaps evaluting what the engine accomplished
   * on one pass.
   */
  void completeVisit() {
    
  }
  
  /**
   * This is the basic visit traversal. For heiarchial traversals use the
   * [GroupingBehavior.visitNode] mixin.
   */
  bool visitNode(DrawContext context) {
    if (!isVisible())
      return false;

    // Save context state first
    context.save();
    
    // Set to current transform. The DrawingContext call's this Node's
    // nodeToParentTransform.
    context.transform(this);
    
    draw(context);
    
    // Restore context state.
    context.restore();
    
    return true;
  }

  /**
   * There are two dirty states: Transform and axis-aligned bounding box (aabbox).
   * This dirty flag applies to Transforms of which I consider it a downward
   * traversal at the present time. Note: this may change.
   */
  set dirty(bool dirty);
  
  set dirtyNode(bool dirty) {
    _transformDirty = _inverseDirty = dirty;
    
    // TODO dirtyChanged disabled for now. It is used mostly by 
    // dependency Nodes with a relationship with hierarchys. May deprecate.
    //dirtyChanged(this);
  }
  
  bool get dirty => _transformDirty;
  
  void dirtyChanged(BaseNode node);

  /**
   * override to manage visibility for culling situations.
   */
  bool isVisible();
  
  /// A mixin/behaviour could override this providing a different behavior.
  /// The default is to reflect the current state.
  bool checkVisibility(MutableRectangle<double> aabbox, [MutableRectangle<double> viewport]) {
    return visible;
  }
  
  /**
   * Sent when a [Node] has been added as a child. Helpful for watching
   * grouping activities.
   */
  void addedAsChild();
  
  /**
   * You must override this method in order for your [BaseNode] to be
   * visually rendered.
   */
  void draw(DrawContext context);
  
  // ----------------------------------------------------------
  // Transforms
  // ----------------------------------------------------------
  MutableRectangle<double> calcParentAABB();
  
  /**
   */
  AffineTransform calcInverseTransform() {
    if (_inverseDirty) {
      AffineTransformInvertTo(calcTransform(), inverseTransform);
      _inverseDirty = false;
    }
    return inverseTransform;
  }

  /**
   * Calculates the transform stack's scale component only.
   * Note: remember to call [moveToPool] on the returned [Vector2P].
   * Note2: If you want the uniform scale then use [calcUniformScaleComponent].
   */
  Vector2P calcScaleComponent() {
    BaseNode p = _parent;
    
    Vector2P aScale = new Vector2P.withCoords(scale.x, scale.y);
    
    while (p != null) {
      Vector2 s = p.scale;
      aScale.v.multiply(s);
      // next parent upwards 
      p = p._parent;
    }
    
    return aScale;
  }
  
  /**
   * Calculates the transform stack's uniform scale component only.
   * Note2: If you want the non-uniform scale then use [calcScaleComponent].
   */
  double calcUniformScaleComponent() {
    BaseNode p = _parent;
    
    double uScale = uniformScale;
    
    while (p != null) {
      uScale *= p.uniformScale;
      // next parent upwards 
      p = p._parent;
    }
    
    return uScale;
  }
  
  /**
   * Calculates the transform stack's uniform scale component only.
   * Remember to call the object's [moveToPool] method when done
   * with the returned [AffineTransform].
   */
  AffineTransform calcScaleRotationComponents() {
    AffineTransform comp = new AffineTransform.withAffineTransformP(calcTransform());
    comp.tx = 0.0;
    comp.ty = 0.0;
    
    BaseNode p = _parent;

    while (p != null) {
      AffineTransform parentT = new AffineTransform.withAffineTransformP(p.calcTransform());
      parentT.tx = 0.0;
      parentT.ty = 0.0;
      
      affineTransformMultiplyFrom(comp, parentT);
      
      parentT.moveToPool();
      
      // next parent upwards 
      p = p._parent;
    }

    return comp;  // return pooled object
  }
  
  /**
   * Returns the world [AffineTransform] matrix.
   * Note: The returned object is pooled.
   * Remember to call the object's [moveToPool] method when done
   * with the returned [AffineTransform].
   * If you don't move the object back to the pool
   * the GC will have something to collect and you may not want that.
   */
  AffineTransform nodeToWorldTransform([BaseNode psuedoRoot]) {
    // Get a pooled transform to accumulate the parent transforms.
    // child = comp
    AffineTransform comp = new AffineTransform.withAffineTransformP(calcTransform());

    // Iterate "upwards" starting with the child towards the parents
    // starting with this child's parent.
    BaseNode p = _parent;

    while (p != null) {
      AffineTransform parentT = p.calcTransform(); // Non-pooled object 

      // Because we are iterating upwards we need to pre-multiply each
      // child. Ex: [child] x [parent]
      // ----------------------------------------------------------
      //           [comp] x [parentT]
      //                  |
      //                  v
      //                 [comp] x [parentT] 
      //                  |
      //                  v
      //                 [comp] x [parentT...]
      //
      // This is a pre-multiply order
      // [child] x [parent ofchild] x [parent of parent of child]...
      //
      // In other words the child is mutiplied "into" the parent.
      
      affineTransformMultiplyFrom(comp, parentT);   // <--- correct

      if (p == psuedoRoot)
        break;
      
      // next parent upwards 
      p = p._parent;
    }

    return comp;  // return pooled object
  }
  
  double nodeToWorldScale() {
    double scale = uniformScale;
    
    BaseNode p = _parent;
    while (p != null) {
      scale *= p.uniformScale;
      p = p._parent;
    }

    return scale;
  }
  
  double nodeToParentScale() {
    double scale = uniformScale;
    
    if (_parent != null)
      scale *= _parent.uniformScale;

    return scale;
  }
  
  /**
   * Returns the inverse world [AffineTransform] matrix.
   * Note: The returned object is poolable.
   *     Remember to call the object's [moveToPool] method when done
   *     with object.
   * [pseudoRoot] is a [Node] that you are sure is a common ancestor
   * to the Nodes you are mapping between. However, there is one caveat,
   * All the ancestor to the pseudo root must be statically Identity
   * transforms. Otherwise you will get improper mapping.
   * Providing a pseudoRoot could save a few matrix multiplications.
   * 
   * When in doubt simply omit providing a pseudoRoot.
   */
  AffineTransform worldToNodeTransform([BaseNode pseudoRoot]) {
    AffineTransform nwt = nodeToWorldTransform(pseudoRoot);
    AffineTransform invt = AffineTransformInvert(nwt);
    nwt.moveToPool();
    return invt; // return pooled object.
  }

  /**
   * Converts a [point] in world-space to [BaseNode] local-space coordinates.
   * You can pass a [Touch].getLocation() point as an example.
   * The result are in [Point]s.
   * Note: The returned object is poolable.
   *     Remember to call the object's [moveToPool] method when finished.
   * 
   * [pseudoRoot] is a [Node] that you are sure is a common ancestor
   * to the Nodes you are mapping between. However, there is one caveat,
   * All the ancestor to the pseudo root must be statically Identity
   * transforms. Otherwise you will get improper mapping.
   * Providing a pseudoRoot could save a few matrix multiplications.
   * 
   * When in doubt simply omit providing a pseudoRoot.
   */
  Vector2P convertWorldToNodeSpace(Vector2 point, [BaseNode pseudoRoot]) {
    AffineTransform wnt = worldToNodeTransform(pseudoRoot);
    Vector2P p = PointApplyAffineTransform(point, wnt);
    wnt.moveToPool();
    return p; // Remember to call moveToPool on "p"
  }

  MutableRectangle<double> convertWorldRectToNode(MutableRectangle<double> worldRect) {
    AffineTransform wnt = worldToNodeTransform();
    MutableRectangle<double> r = RectApplyAffineTransform(worldRect, wnt);
    wnt.moveToPool();
    return r;
  }

  /**
   * Converts a local-space [Point] to world-space coordinates.
   * World-space = Root-space.
   * Note: The returned object is poolable.
   *     Remember to call the object's [moveToPool] method when finished.
   * 
   * [pseudoRoot] is a [Node] that you are sure is a common ancestor
   * to the Nodes you are mapping between. However, there is one caveat,
   * All the ancestor to the pseudo root must be statically Identity
   * transforms. Otherwise you will get improper mapping.
   * Providing a pseudoRoot could save a few matrix multiplications.
   * 
   * When in doubt simply omit providing a pseudoRoot.
   */
  Vector2P convertToWorldSpace(Vector2 nodePoint, [BaseNode pseudoRoot]) {
    AffineTransform nwt = nodeToWorldTransform(pseudoRoot);
    
    Vector2P p = PointApplyAffineTransform(nodePoint, nwt);
    
    nwt.moveToPool();
    return p; // Caller should call moveToPool on "p"
  }

  /**
   * Converts a local-space [Point] to view/window-space coordinates.
   * The point is in pixels.
   * Note: The returned object is poolable.
   *     Remember to call the object's [moveToPool] method when finished.
   */
  Vector2P convertToViewSpace(Vector2 point) {
    // TODO complete convertToViewSpace 
    Vector2P worldPoint = convertToWorldSpace(point);
    Vector2P uiP = Application.instance.drawContext.mapWorldToView(worldPoint.v.x, worldPoint.v.y);
    worldPoint.moveToPool();
    return uiP;
  }

  /**
   * Override to provide simply collision tests.
   */
  bool pointInside(Vector2 point);
  
  /**
   * Returns a matrix that represents this [BaseNode]'s local-space
   * transform.
   */
  AffineTransform calcTransform() {
    // Note: We could check each behaviors for dirty but that would be
    // expensive especially in this core method. So instead each
    // behavior is tightly bound to this BaseNode, and the behavior updates
    // the "dirty" state. The down side is that each behavior needs a
    // reference to a BaseNode that it affects.
    if (_transformDirty) {
      transform.toIdentity();

      transform.translate(position.x, position.y);

      if (rotation != 0.0) {
        transform.rotate(rotation);
      }

      if (scale.x != 1.0 || scale.y != 1.0) {
        transform.scale(scale.x, scale.y);
      }

      //print("BaseNode.calcTransform\n ${transform}, tag:$tag");
      _transformDirty = false;
    }

    return transform;
  }

  @override
  String toString() => "t:$tag";
  
//  @override
//  String toString() {
//    StringBuffer sb = new StringBuffer();
//    if (this is GroupingBehavior) {
//      GroupingBehavior tgb = this as GroupingBehavior;
//      if (tgb._children != null && tgb._children.isNotEmpty) {
//        for(BaseNode bn in tgb._children) {
//          if (bn is GroupingBehavior) {
//            GroupingBehavior gb = bn as GroupingBehavior;
//            sb.write(gb.toString());
//          }
//          else {
//            if (_parent != null)
//              return "{P:${_parent.tag},C:${tag}}";
//            else if (_parent == null)
//              return "{C:${tag}}";
//          }
//        }
//      }
//      else {
//        if (_parent != null)
//          return "{P:${_parent.tag},C:${tag}}";
//        else if (_parent == null)
//          return "{C:${tag}}";
//      }
//    }
//    else {
//      return "{C:${tag}}";
//    }
//    
//    return sb.toString();
//  }

}

//@deprecated
//AffineTransform nodeToParentTransformOld() {
//  if (_transformDirty) {
//    _transform.toIdentity();
//    
//    // base position
//    _transform.tx = _position.x;
//    _transform.ty = _position.y;
//
//    // rotation Cos and Sin
//    double Cos = 1.0, Sin = 0.0;
//    if (_rotation != 0.0) {
//      Cos = math.cos(_rotation);
//      Sin = math.sin(_rotation);
//    }
//
//    // base abcd
//    _transform.a = _transform.d = Cos;
//    _transform.b = -Sin;
//    _transform.c = Sin;
//
//    // skew
//    if (_skew.x != 0.0 || _skew.y != 0.0) {
//      // offset the anchorpoint
//      var skx = math.tan(_skew.x * PIOver180);
//      var sky = math.tan(-_skew.y * PIOver180);
//      var xx = _textureAnchorPointInPoints.y * skx * _scale.x;
//      var yy = _textureAnchorPointInPoints.x * sky * _scale.y;
//      _transform.a = Cos + -Sin * sky;
//      _transform.b = Cos * skx + -Sin;
//      _transform.c = Sin + Cos * sky;
//      _transform.d = Sin * skx + Cos;
//      _transform.tx += Cos * xx + -Sin * yy;
//      _transform.ty += Sin * xx + Cos * yy;
//    }
//
//    // scale
//    if (_scale.x != 1.0 || _scale.y != 1.0) {
//      _transform.a *= _scale.x;
//      _transform.c *= _scale.x;
//      _transform.b *= _scale.y;
//      _transform.d *= _scale.y;
//    }
//
//    // adjust for anchorPoint
//    _transform.tx += Cos * -_textureAnchorPointInPoints.x * _scale.x + -Sin * _textureAnchorPointInPoints.y * _scale.y;
//    _transform.ty -= Sin * -_textureAnchorPointInPoints.x * _scale.x + Cos * _textureAnchorPointInPoints.y * _scale.y;
//
//    // if ignore anchorPoint
//    //if (_ignoreAnchorPointForPosition) {
//    //  _transform.tx += _anchorPointInPoints.x;
//    //  _transform.ty += _anchorPointInPoints.y;
//    //}
//
//    // TODO I think this is for Armatures
//    // _additionalTransformDirty
//    
//    _transformDirty = false;
//  }
//  
//  return _transform;
//}

