part of ranger_rocket;

abstract class PolygonNode extends Ranger.Node {
  bool solid = true;
  bool outlined = false;
  double outlineThickness = 3.0;

  // Debug
  bool showAABBox = false;
  bool enableAABoxVisual = false;
  bool showRectBox = false;
  bool isSelectable = false;
  
  String drawColor = Ranger.Color3IWhite.toString();
  String fillColor = Ranger.color4IFromHex("#aaaaaa").toString();

  Ranger.MutableRectangle<double> worldAABBox = new Ranger.MutableRectangle<double>.withP(
      0.0, 0.0, 0.0, 0.0);
  
  Ranger.Polygon polygon;
  double uniScale = 1.0;
  
  @override
  bool init() {
    if (super.init()) {
      return true;
    }
    
    return false;
  }
  
  void select() {
    uniScale = this.nodeToWorldScale();
    showAABBox = true;
  }
  
  void unSelect() {
    showAABBox = false;
    intersectsViewPort = false;
  }

  @override
  void dirtyChanged(Ranger.Node node) {
    super.dirtyChanged(node);
    uniScale = this.nodeToWorldScale();
    calcAABBToWorld();
  }

  @override
  bool isVisible() {
    Ranger.Application app = Ranger.Application.instance; 

    bool intersects = checkVisibility(worldAABBox, app.viewPortWorldAABB);
    
    if (intersects && isSelectable)
      intersectsViewPort = true;
    else
      intersectsViewPort = false;
    
    return intersects;
  }

  @override
  Ranger.MutableRectangle<double> calcAABBToWorld() {
    // The aabox will have been set by a subclass.
    worldAABBox.left = polygon.aabbox.left;
    worldAABBox.bottom = polygon.aabbox.bottom;
    worldAABBox.width = polygon.aabbox.width;
    worldAABBox.height = polygon.aabbox.height;
    
    Ranger.AffineTransform transform = nodeToWorldTransform();
    Ranger.RectangleApplyAffineTransform(worldAABBox, transform);

//    if (children == null)
//      return worldAABBox;
//
//    // Iterate children collecting Bounding Boxes
//    for(Ranger.Node child in children) {
//      if (child is PolygonNode) {
//        if (child.visible) {
//          Ranger.MutableRectangle<double> bbox = child._calcAABBOfChild(transform);
//  
//          // Accumulate bounds. Union aabbox to bbox
//          worldAABBox.union(bbox);
//  
//          bbox.moveToPool();    // Return to pool.
//        }
//      }
//    }

    transform.moveToPool();

    return worldAABBox;
  }

  // Internal recursion method. See [calcAABBToWorld].
  Ranger.MutableRectangle<double> _calcAABBOfChild(Ranger.AffineTransform parentTransform) {
    // Create a rectangle to accumulate this child's bounds.
    Ranger.MutableRectangle<double> accumBox = new Ranger.MutableRectangle<double>.withP(
        polygon.aabbox.left, polygon.aabbox.bottom, polygon.aabbox.width, polygon.aabbox.height);
    
    //AffineTransform transform = affineTransformMultiply(nodeToWorldTransform(), parentTransform);
    Ranger.AffineTransform transform = nodeToWorldTransform();
    
    Ranger.RectangleApplyAffineTransform(accumBox, transform);

//    if (children != null) {
//      // Iterate children collecting Bounding Boxes
//      for(PolygonNode child in children) {
//        if (child.visible) {
//          // Recurse into children
//          Ranger.MutableRectangle<double> childBox = child._calcAABBOfChild(transform); // A pooled rectangle
//          
//          // Accumulate bounds. Union child bbox.
//          accumBox.union(childBox);
//          
//          // Return bbox back to pool for next child.
//          childBox.moveToPool();
//        }
//      }
//    }
    
    transform.moveToPool();
    
    return accumBox;
  }

  /**
   * Iterate through this Node's children accumulating local AABBoxes.
   * An AABBox only needs to be recomputed if a Node becomes dirty.
   */
  Ranger.MutableRectangle<double> calcParentAABB() {
    Ranger.AffineTransform at = new Ranger.AffineTransform.withAffineTransformP(calcTransform());

    // Take this node's aabbox and transform it 
    Ranger.RectApplyAffineTransformTo(polygon.aabbox, rect, at);

//    if (children == null)
//      return rect;
//
//    // Iterate children collecting Bounding Boxes
//    for(PolygonNode child in children) {
//      if (child.visible) {
//        Ranger.MutableRectangle<double> bbox = child._calcParentAABB(at);
//
//        // Accumulate bounds. Union aabbox to bbox
//        rect.union(bbox);
//
//        bbox.moveToPool();    // Return to pool.
//      }
//    }

    at.moveToPool();

    return rect;
  }
  
  // Internal recursion
  Ranger.MutableRectangle<double> _calcParentAABB(Ranger.AffineTransform parentTransform) {
    // Create a rectangle to accumulate aabboxes.
    Ranger.MutableRectangle<double> accumBox = new Ranger.MutableRectangle<double>.withP(0.0, 0.0, 0.0, 0.0);
    
    Ranger.AffineTransform transform = Ranger.affineTransformMultiply(calcTransform(), parentTransform);
    
    Ranger.RectApplyAffineTransformTo(polygon.aabbox, accumBox, transform);

//    if (children != null) {
//      // Iterate children collecting Bounding Boxes
//      for(PolygonNode child in children) {
//        if (child.visible) {
//          // Recurse into children
//          Ranger.MutableRectangle<double> childBox = child._calcParentAABB(transform);
//          
//          // Accumulate bounds. Union child bbox.
//          accumBox.union(childBox);
//          
//          // Return bbox back to pool for next child.
//          childBox.moveToPool();
//        }
//      }
//    }
    
    transform.moveToPool();
    
    return accumBox;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    context.save();
    
    context.fillColor = fillColor;
    context.drawColor = drawColor;
    
    if (solid)
      context.drawPoly(polygon.points, Ranger.DrawContext.CLOSED, Ranger.DrawContext.SOLID);

    double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
    context.lineWidth = invScale;

    if (outlined) {
      context.drawPoly(polygon.points, Ranger.DrawContext.CLOSED, Ranger.DrawContext.OUTLINED);
    }

    // +X local reference axis.
    //context.drawLineByComp(0.0, 0.0, 1.0, 0.0);
    
    //if (showAABBox && enableAABoxVisual) {
    //  context.drawColor = "rgb(255,0,0)";
    //  context.drawRect(polygon.aabbox.left, polygon.aabbox.bottom, polygon.aabbox.width, polygon.aabbox.height, false, true);
    //}

    //if (showRectBox) {
    //  context.lineWidth = 1.0;
    //  context.drawColor = "rgb(0,255,255)";
    //  context.drawRect(rect.left, rect.bottom, rect.width, rect.height, false, true);
    //}
    
    //if (intersectsViewPort) {
    //  context.drawColor = "rgb(0,0,0)";
    //  context.drawLineByComp(-0.25, 0.25, 0.25, -0.25);
    //  context.drawLineByComp(-0.25, -0.25, 0.25, 0.25);
    //}
    
    context.restore();
    Ranger.Application.instance.objectsDrawn++;
  }

  bool pointInside(Vector2 point) {
    //Ranger.AffineTransform at = calcTransform();
    
    return polygon.isPointInside(point);
  }

}
