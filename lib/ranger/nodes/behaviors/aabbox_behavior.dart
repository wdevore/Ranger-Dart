part of ranger;

/** 
 * [AABBoxBehavior] is a mixin.
 * Mix with a [BaseNode] that you want aabbox rendering behavior.
 */
@deprecated
abstract class AABBoxBehavior {
  Node node;

  AffineTransform localT = new AffineTransform.Identity();
  AffineTransform aabbT = new AffineTransform.Identity();

  // Visual debug
  Vector2 ls = new Vector2.zero();
  Vector2 le = new Vector2.zero();
  MutableRectangle<double> bbox = new MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);
  MutableRectangle<double> aabbox = new MutableRectangle<double>(0.0, 0.0, 0.0, 0.0);

  void initAABBoxBehavior(Node node) {
    this.node = node;
  }
  
  void aabbDirty() {
    localT.toIdentity();
    localT.scale(node.uniformScale, node.uniformScale);
    localT.invert();
    
    aabbT.toIdentity();
    aabbT.translate(node.position.x, node.position.y);
    aabbT.rotate(node.rotation);
    aabbT.scale(node.uniformScale, node.uniformScale);
    aabbT.invert();
    
  }
  
  void drawBBoxes(DrawContext context) {
    // Local bbox
    context.save();
    context.transformWith(node.calcTransform());

    context.drawColor = "rgba(200,0,0,1.0)";
    context.drawRect(aabbox.left, aabbox.bottom, aabbox.width, aabbox.height);
    
    context.restore();

    // AABbox
//    context.save();
//    context.transformWith(aabbT);
//
//    context.drawColor = "rgba(255,127,0,1.0)";
//    context.drawRect(node.aabbox.left, node.aabbox.bottom, node.aabbox.width, node.aabbox.height, false, true);
//    
//    context.restore();

//    if (node.tag != 103) {
//
//    context.save();
//    context.transformWith(aabbT);
//    context.drawColor = "rgba(255,200,0,1.0)";
//    context.drawRect(bbox.left, bbox.bottom, bbox.width, bbox.height, false, true);
//    
//    context.drawColor = "rgba(255,200,0,1.0)";
//    ls.setValues(bbox.left, bbox.bottom);
//    le.setValues(bbox.right, bbox.top);
//    context.drawLine(ls, le);
//    ls.setValues(bbox.left, bbox.top);
//    le.setValues(bbox.right, bbox.bottom);
//    context.drawLine(ls, le);
//    
//    context.restore();
//    }
//    else {
//      context.save();
//      context.transformWith(aabbT);
//      context.drawColor = "rgba(255,200,0,1.0)";
//      context.drawRect(bbox.left, bbox.bottom, bbox.width, bbox.height, false, true);
//      
//      context.drawColor = "rgba(255,200,0,1.0)";
//      ls.setValues(bbox.left, bbox.bottom);
//      le.setValues(bbox.right, bbox.top);
//      context.drawLine(ls, le);
//      ls.setValues(bbox.left, bbox.top);
//      le.setValues(bbox.right, bbox.bottom);
//      context.drawLine(ls, le);
//      
//      context.restore();
//    }
    
  }
  

}

