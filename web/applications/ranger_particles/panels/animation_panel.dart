library animation_panel;

import 'dart:html';

import 'package:ranger/ranger.dart' as Ranger;

import '../particle_layer.dart';

/*
 * This panel is sits just below the animation window.
  */
class AnimationPanel {
  Ranger.Application app;
  ParticleLayer particleLayer;

  bool _loopEnabled = false;

  SelectElement _frameRateElement;

  SpanElement _animeEnabledElement;
  InputElement _chkAnimeEnabledElement;
  
  Function _panelChanged;
  
  double simFrameRate = 0.0;

  void init(Function panelChanged) {
    _panelChanged = panelChanged;
    
    _frameRateElement = querySelector("#frameRateId");
    _frameRateElement.onChange.listen(
        (Event event) => _changeFrameRate()
    );

    _animeEnabledElement = querySelector("#animeEnabled");
    _chkAnimeEnabledElement = querySelector("#chkAnimationEnabled");
    _chkAnimeEnabledElement.onChange.listen(
        (Event event) => _animeEnabledChanged()
    );
    
    
  }
  
  set frameRate(int fps) {
    List<int> frmRts = [1, 5, 10, 15, 30, 60];
    int i = 0;
    for(int frmRt in frmRts) {
      if (frmRt == fps) {
        _frameRateElement.selectedIndex = i;
      }
      i++;
    }
    _changeFrameRate();
  }
  
  void _refresh() {
    if (_panelChanged != null)
      _panelChanged();
  }
  
  void _animeEnabledChanged() {
    if (_chkAnimeEnabledElement.checked)
      _animeEnabledElement.text = "Animation enabled";
    else
      _animeEnabledElement.text = "Animation disabled";
    
    _loopEnabled = _chkAnimeEnabledElement.checked;
    
    app.stepEnabled = _loopEnabled;
  }

  void _changeFrameRate() {
    int rate = int.parse(_frameRateElement.value);
    //_appConfig["FPS"] = rate;

    // map from 60fps to rate.
    // 60fps = 16.78ms/f
    // 15fps = 4 * 16.77/f = 66.67ms/f
    double fixedRate = 1.0 / 60.0 * 1000.0;
    
    simFrameRate = (fixedRate * (60.0 / rate));
  }

}