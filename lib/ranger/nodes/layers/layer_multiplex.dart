part of ranger;

/** 
 * TODO not complete.
 * [LayerMultiplex] is a subclass of [Layer].
 */
class LayerMultiplex extends Layer {
  int _enabledLayer = 0;
  List<Layer> _layers = new List<Layer>();
  
  LayerMultiplex._();

  factory LayerMultiplex(Layer layer) {
    LayerMultiplex layer = new LayerMultiplex._();
    
    layer.init();

    return layer;
  }
  
  @override
  bool init([int width, int height]) {
    return super.init(width, height);
  }
  
  void addLayer(Layer layer) {
    if (layer == null) {
      Logging.warning("LayerMultiplex.addLayer layer is null. Nothing done.");
      return;
    }
    
    _layers.add(layer);
  }
  
  /**
   * Switches to [index] layer.
   * The current active layer will be removed from it's parent with cleanup.
   */
  void switchTo(int index) {
    if (index >= _layers.length) {
      Logging.error("LayerMultiplex.switchTo: Invalid index.");
      return;
    }

    removeChild(_layers[_enabledLayer]);
    
    _enabledLayer = index;
    
    addChild(_layers[index]);
  }

  /** 
   * Release the current layer and Switch to [index] layer
   * The current active layer will be removed from it's parent with cleanup.
   */
  void switchToAndReleaseActive(int index) {
    if (index >= _layers.length){
      Logging.error("LayerMultiplex.switchToAndReleaseActive: Invalid index.");
      return;
    }

    removeChild(_layers[_enabledLayer]);

    _layers[_enabledLayer] = null;
    _enabledLayer = index;
    addChild(_layers[index]);
  }
  
}

