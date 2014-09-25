library tint_panel;

import 'dart:html';
import 'package:ranger/ranger.dart' as Ranger;

import 'emitter_properties_tab.dart';
import 'package:color_slider_control/color_slider_control.dart';
import 'package:gradient_colorstops_control/gradient_colorstops_control.dart';

/*
 * Left color blue(loc = 0.6659090909090909)
 * right color orange(loc = 0.08409090909090909)
 * or 0.32954545454545453 = green
 * 
  */
class TintPanel {
  EmitterPropertiesTab _containerTab;

  DivElement _targetColorContainer;
  DivElement _targetGradientContainer;
  
  ImageElement _refreshIcon;
  ColorSliderWidget _colorWidget;
  GradientColorStopWidget _gradientWidget;
  
  ColorData startColor;
  ColorData endColor;
  bool _bound = false;
  
  TintPanel(this._containerTab);
  
  void init() {
    _colorWidget = new ColorSliderWidget();
    _targetColorContainer = querySelector("#color_pickerId");
    _targetColorContainer.nodes.add(_colorWidget.container);

    // We want the gradient widget to only send the colorstop of the marker
    // not the marker's color stop on the bar.
    _gradientWidget = new GradientColorStopWidget(gradientChanged);
    _gradientWidget.colorWidget = _colorWidget;
    
    _targetGradientContainer = querySelector("#gradient_pickerId");
    _targetGradientContainer.nodes.add(_gradientWidget.container);
    
    _colorWidget.colorChangeCallback = colorChanged;
    
    _refreshIcon = querySelector("#panelDelayRefresh");
    _refreshIcon.onClick.listen(
        (Event event) => _refresh()
    );
    
  }
  
  void colorChanged(ColorData data) {
    // The color has changed on the Color widget.
    // Pass to gradient widget.
    //print("data: ${data.color}, loc:${data.colorLocation}, gradLoc: ${data.gradientlocation}");
    if (data.gradientlocation == 0.0) {
      startColor = new ColorData();
      startColor.colorLocation = data.colorLocation;
      if (data.displayColor != null)
        startColor.color = new ColorValue.copy(data.displayColor);
      else
        startColor.color = new ColorValue.copy(data.color);
    }
    else {
      endColor = new ColorData();
      endColor.colorLocation = data.colorLocation;
      if (data.displayColor != null)
        endColor.color = new ColorValue.copy(data.displayColor);
      else
        endColor.color = new ColorValue.copy(data.color);
    }
    //print("color: ${endColor.color}, loc:${endColor.colorLocation}");
    
    _gradientWidget.externalColorChange(data);
    
    // Update model which will then update this control.
    _refresh();
  }
  
  void gradientChanged(ColorData data) {
    // They selected a color stop, pass to color widget.
    _colorWidget.externalColorChange(data);
  }

  void bind() {
    List<ColorData> stops = new List<ColorData>();
    
    stops.add(getColorData(0));
    gradientChanged(stops[0]);
    
    stops.add(getColorData(1));
    gradientChanged(stops[1]);
    
    _colorWidget.bind();
    _gradientWidget.bind(stops);
    
    _bound = true;
  }
  
  ColorData getColorData(int index) {
    ColorData cd = new ColorData();
    
    cd.colorLocation = _containerTab.modelController.activeMap.getColorLocation(index);
    cd.gradientlocation = _containerTab.modelController.activeMap.getGradientLocation(index);
    
    Ranger.Color4<int> c = _containerTab.modelController.activeMap.getColor(index);
    cd.color = new ColorValue.fromRGB(c.r, c.g, c.b);
    
    c = _containerTab.modelController.activeMap.getBrightness(index);
    cd.whiteness = new ColorValue.fromRGB(c.r, c.g, c.b);
    
    c = _containerTab.modelController.activeMap.getDarkness(index);
    cd.darkness = new ColorValue.fromRGB(c.r, c.g, c.b);
    
    cd.isEndStop = _containerTab.modelController.activeMap.getIsEndStop(index);
    
    cd.displayColor = cd.calcDisplayColor();
    
    return cd;
  }
  
  // This is called when the model changes.
  // Or when _refresh/_controlPanelChanged is called.
  void dataChanged([bool changedByUser = true]) {
    Ranger.Color4<int> s = _containerTab.modelController.activeMap.getColor(0);

    if (startColor == null)
      startColor = new ColorData();
    startColor.color = new ColorValue.fromRGB(s.r, s.g, s.b);
    //startColor.gradientlocation = _containerTab.modelController.activeMap.getGradientLocation(0);
    startColor.colorLocation = _containerTab.modelController.activeMap.getColorLocation(0);
    
    Ranger.Color4<int> e = _containerTab.modelController.activeMap.getColor(1);
    if (endColor == null)
      endColor = new ColorData();
    endColor.color = new ColorValue.fromRGB(e.r, e.g, e.b);
    endColor.colorLocation = _containerTab.modelController.activeMap.getColorLocation(1);

    // The bind may not have happened yet.
    if (_bound && !changedByUser) {
      // Potential spot for something.
    }
  }
  
  // Update model based on active map.
  void _refresh() {
    _containerTab.modelController.activeMap.setColor(0, startColor.color.r, startColor.color.g, startColor.color.b, 255);
    _containerTab.modelController.activeMap.setColorLocation(0, startColor.colorLocation);

    _containerTab.modelController.activeMap.setColor(1, endColor.color.r, endColor.color.g, endColor.color.b, 255);
    _containerTab.modelController.activeMap.setColorLocation(1, endColor.colorLocation);
    _controlPanelChanged();
  }
  
  void _controlPanelChanged() {
    // This will cause a dataChanged call on this panel.
    _containerTab.modelController.dataChanged();
  }

}