part of ranger;

/** 
 * [GroupingBehavior] is a mixin.
 * Mix with a [BaseNode] that you want children behavior.
 */
abstract class GroupingBehavior {
  BaseNode _this;

  set children(List<BaseNode> children) => _children = children;

  List<BaseNode> get children => _children;

  int _highestZOrder = 1000000000;

  bool hasNegZOrders = false;

  List<BaseNode> _children;

  /**
   * Enable/Disable parent traversal on this [Node]. Some situations where
   * a [Node] becomes dirty the parent(s) need to marked dirty as well.
   * The default is "disabled".
   */
  bool enableParentDirting = false;
  
  void initGroupingBehavior(BaseNode context) {
    _this = context;
    
    if (_children == null)
      _children = new List<BaseNode>();
    
    _highestZOrder = 1000000000;
  }

  void onEnterNode() {
    _this.isTransitionFinished = false;
    _this._running = true; // mark running before resumeTiming
    
    if (children != null && children.isNotEmpty)
      children.forEach((BaseNode child) => child.onEnter());

    _this.resumeTiming();
  }

  void onEnterTransitionDidFinishNode() {
    _this.isTransitionFinished = true;
    
    if (children != null && children.isNotEmpty)
      children.forEach((BaseNode child) => child.onEnterTransitionDidFinish());
  }

  void onExitTransitionDidStartNode() {
    if (_children != null && _children.isNotEmpty)
      _children.forEach((BaseNode child) => child.onExitTransitionDidStart());
  }

  void onExitNode() {
    if (_children != null && _children.isNotEmpty)
      _children.forEach((BaseNode child) => child.onExit());
  }

  void cleanUpNode([bool cleanUp = true]) {
    if (_children != null && _children.isNotEmpty) {
      _children.forEach((BaseNode child) => child.cleanup(cleanUp));
      if (cleanUp)
        removeAllChildren(cleanUp);
    }
  }

  void updateTransforms() {
    if (_children != null && _children.isNotEmpty)
      _children.forEach((BaseNode child) => child.updateTransform());
  }

  bool visitNode(DrawContext context) {
    if (!_this.isVisible())
      return false;

    // Save context state first
    context.save();
    
    // Set to current transform. The DrawingContext call's this Node's
    // nodeToParentTransform.
    context.transform(_this);
    
    if (_children != null && _children.isNotEmpty) {
      // Visit negative Z orders first. This allows children with -Zs
      // to be drawn "above" their parent.
      if (hasNegZOrders) {
        _children.where((BaseNode n) => n.drawOrder < 0)
                 .forEach((BaseNode child) => child.visit(context));
      }

      _this.preDraw(context);

      // Now draw parent.
      // This draw could leave the context in a certain state that other
      // child nodes may not expect.
      _this.draw(context);
      
      _this.postDraw(context);

      // Visit 0 and +Z orders last.
      _children.where((BaseNode n) => n.drawOrder >= 0)
               .forEach((BaseNode child) => child.visit(context));
    }
    else {
      // No children. Just draw this node.
      _this.draw(context);
    }
    
    // Restore context state.
    context.restore();
    
    return true;// continue visiting.
  }

  set dirtyNode(bool dirty) {
    _this._transformDirty = _this._inverseDirty = dirty;
    
    // Parent traversal isn't really appropriate here.
    // It should only apply to aabboxes traversals.
    
    // If a Node changes then its transform is dirty including
    // any of its children.
    rippleDirty();

    // My perception is that traversing up the tree applies to aaboxes.
    // If a child is dirty then the parent's aabbox has changed too.
    // TODO continue to monitor this code
    // we may move this to VisibilityBehavior or somewhere were aabboxes are computed.
    if (enableParentDirting) {
      BaseNode p = _this._parent;
      while (p != null) {
        p._transformDirty = p._inverseDirty = dirty;
        p = p._parent;
      }
    }
    
    // TODO dirtyChanged callback disable for now. My deprecate.
    //_this.dirtyChanged(_this);
  }

  void rippleDirty([List<BaseNode> children]) {
    if (children != null) {
      for(BaseNode child in children) {
        if (child is GroupingBehavior) {
          GroupingBehavior gb = child as GroupingBehavior;
          if (gb.children != null) {
            rippleDirty(gb.children);
          }
          else {
            // By directly setting the flags we bypass recursion
            // However, the node must be added before calling any
            // transform methods like setPosition(...)
            //child._transformDirty = child._inverseDirty = true;
            // I prefer not requiring any order so I use .dirty.
            child.dirty = true;
          }
        }
        else {
          //child._transformDirty = child._inverseDirty = true;
          child.dirty = true;
        }
      }
    }
    else {
      if (_children != null) {
        for(BaseNode child in _children) {
          if (child is GroupingBehavior) {
            GroupingBehavior gb = child as GroupingBehavior;
            if (gb.children != null) {
              rippleDirty(gb.children);
            }
            else {
              //child._transformDirty = child._inverseDirty = true;
              child.dirty = true;
            }
          }
          else {
            //child._transformDirty = child._inverseDirty = true;
            child.dirty = true;
          }
        }
      }
    }
  }

  BaseNode getChildByTag(int tag) {
    BaseNode tagChild = null;
    
    if (_children != null && _children.isNotEmpty) {
      tagChild = _children.firstWhere(
          (BaseNode child) => child.tag == tag,
          orElse: () => _searchForChildByTag(tag));
    }
    
    return tagChild;
  }

  // A left travesal.
  BaseNode _searchForChildByTag(int tag) {
    BaseNode tagChild = null;

    // Iterate into each child
    for(BaseNode child in _children) {
      if (child is GroupingBehavior) {
        GroupingBehavior gb = child as GroupingBehavior;
        if (gb.children != null && gb.children.isNotEmpty) {
          tagChild = gb.children.firstWhere(
              (BaseNode node) => node.tag == tag,
              orElse: () => gb._searchForChildByTag(tag));
          if (tagChild != null)
            break;
        }
      }
      else {
        // This child is a leaf type Node.
        if (child.tag == tag)
          tagChild = child;
      }
    }
    
    return tagChild;
  }

  /**
   * Add a [child] to this [GroupingBehavior]'s children.
   * If the node is added to a 'running' [Node], then [onEnter] 
   * and [onEnterTransitionDidFinish] will be called immediately.
   *
   * [zOrder] controls drawing priority. Default is 0.
   * [tag] is an integer to identify the [Node] easily.
   */
  void addChild(BaseNode child, [int zOrder = 0, int tag = 0]) {
    if (child == this) {
      Logging.error("GroupingBehavior.addChild: A node can't be added as a child to itself.");
      return;
    }

    if (child._parent != null) {
      // This node already has a parent which means it has been parented
      // to another node. This scenegraph is a DAG, hence no circular potentials.
      Logging.error("GroupingBehavior.addChild: ${child} is already parented to ${child._parent}. This node is ${_this},P:${_this._parent}.");
      return;
    }

    if (zOrder < 0)
      hasNegZOrders = true;
    
    int zO = child.drawOrder;
    int t = child.tag;
    if (zOrder != 0)
      zO = zOrder;
    if (tag != 0)
      t = tag;

    child.drawOrder = zO;

    child.tag = t;

    // If the new node's Z-Order is greater than the highest
    // Z-Order then simply add it to the collection.
    // Otherwise add and then sort.

    _children.add(child);
    //Logging.info("GroupingBehavior.addChild: added ${node} as child to parent ${_this} whos parent is ${_this._parent}.");
    
    // The new child's parent is "this" node.
    child._parent = _this;

    if (child.drawOrder < _highestZOrder && _children.length > 1) {
      _children.sort((BaseNode a, BaseNode b) => a.drawOrder.compareTo(b.drawOrder));
    }

    _highestZOrder = _children.last.drawOrder;

    if (_this.isRunning) {
      child.onEnter();
      // prevent onEnterTransitionDidFinish from being called twice when
      // a node is added in the onEnter method.
      if (_this.isTransitionFinished)
        child.onEnterTransitionDidFinish();
    }
    
    child.addedAsChild();
  }

  /**
   * Add a [child] to this [GroupingBehavior]'s children at a specific order
   * within the children.
   * Note: The children will NOT be sorted even if the [zOrder]s are out
   * of order. The [index] has higher precedence than [zOrder].
   * If the node is added to a 'running' [Node], then [onEnter] 
   * and [onEnterTransitionDidFinish] will be called immediately.
   *
   * [zOrder] controls drawing priority. Default is 0.
   * [tag] is an integer for easy [Node] identification.
   */
  void addChildAt(BaseNode child, int index, [int zOrder = 0, int tag = 0]) {
    if (child == this) {
      Logging.error("GroupingBehavior.addChild: A node can't be added as a child to itself.");
      return;
    }

    if (child._parent != null) {
      // This node already has a parent which means it has been parented
      // to another node. This scenegraph is a DAG, hence no circular potentials.
      Logging.error("GroupingBehavior.addChild: ${child} is already parented to ${child._parent}. This node is ${_this},P:${_this._parent}.");
      return;
    }

    if (zOrder < 0)
      hasNegZOrders = true;
    
    int zO = child.drawOrder;
    int t = child.tag;
    if (zOrder != 0)
      zO = zOrder;
    if (tag != 0)
      t = tag;

    child.drawOrder = zO;

    child.tag = t;

    // If the new node's Z-Order is greater than the highest
    // Z-Order then simply add it to the collection.
    // Otherwise add and then sort.

    if (_children == null)
      _children = new List<BaseNode>();

    _children.insert(index, child);
    //Logging.info("GroupingBehavior.addChild: added ${node} as child to parent ${_this} whos parent is ${_this._parent}.");
    
    // The new child's parent is "this" node.
    child._parent = _this;

    if (_this.isRunning) {
      child.onEnter();
      // prevent onEnterTransitionDidFinish from being called twice when
      // a node is added in the onEnter method.
      if (_this.isTransitionFinished)
        child.onEnterTransitionDidFinish();
    }
    
    child.addedAsChild();
  }

  /**
   * There are two ways to remove a child:
   * 1: Simply remove. Scheduling and Actions still occur
   *    but nothing else.
   * 2: Remove, unschedule and remove Actions.
   * 
   * [cleanUp] defaults to true.
   * The index of removed [child] is returned. -1 if child not found.
   * Having the index allows you to insert a new [Node] at the previous
   * location.
   */
  int removeChild(Node child, [bool cleanUp = true]) {
    int index = -1;
    
    if (_children.isEmpty)
      return index;
    
    if (_children.contains(child)) {
      index = _detachChild(child, cleanUp);
    }
    
    _this.dirty = true;
    
    return index;
  }

  /**
   * Removes all children and returns them to the [ObjectPool].
   * If you don't want to cleaned up and return to pool then explicitly
   * set [cleanUp] = false;
   */
  void removeAllChildren([bool cleanUp = true]) {
    for(BaseNode child in _children) {
      if (child.isRunning) {
        child.onExitTransitionDidStart();
        child.onExit();
      }
      
      if (cleanUp) {
        child.cleanup(cleanUp);
        if (child.pooled) {
          //print("GroupingBehavior.removeAllChildren: moving ${child.tag} to pool.");
          child.moveToPool();
        }
      }

      child._parent = null;
    }
    
    _children.clear();
  }
  
  int _detachChild(BaseNode child, bool cleanUp) {
    if (child.isRunning) {
      child.onExitTransitionDidStart();
      child.onExit();
    }
    
    if (cleanUp) {
      child.cleanup(cleanUp);
      if (child.pooled) {
        //print("GroupingBehavior._detachChild: moving ${child.tag} to pool.");
        child.moveToPool();
      }
    }

    child._parent = null;
    
    // Capture index prior to deletion.
    int index = _children.indexOf(child);
    
    _children.remove(child);
    
    return index;
  }
  
  void reorderChild(BaseNode child, int ZOrder) {
    child.drawOrder = ZOrder;
    _children.sort((BaseNode a, BaseNode b) => a.drawOrder.compareTo(b.drawOrder));
    _this.dirty = true;
  }

}

