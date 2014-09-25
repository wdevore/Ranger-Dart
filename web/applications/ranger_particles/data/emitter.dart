library emitter_data;

import 'package:ranger/ranger.dart' as Ranger;

/*
 * Emitter supports "deep" cloning.
  */
class Emitter {
  String _name;
  Map _emitterControl;
  Map _emissionRateControl;
  Map _lifeControl;
  Map _speedControl;
  Map _startScaleControl;
  Map _endScaleControl;
  Map _rotationRateControl;
  Map _accelerationControl;

  Map _generalControl;
  Map _perParticleDelayControl;

  Map _durationControl;
  List<Map> _tintControl;

  Emitter();
  
  factory Emitter.withMap(Map map) {
    Emitter e = new Emitter();
    e.name = map["name"];
    Map data = map["data"];
    
    e._emitterControl = new Map.from(data["EmitterControl"]);
    e._emissionRateControl = new Map.from(data["EmissionRate"]);
    e._lifeControl = new Map.from(data["Life"]);
    e._speedControl = new Map.from(data["Speed"]);
    e._startScaleControl = new Map.from(data["StartScale"]);
    e._endScaleControl = new Map.from(data["EndScale"]);
    e._rotationRateControl = new Map.from(data["RotationRate"]);
    e._generalControl = new Map.from(data["General"]);
    e._perParticleDelayControl = new Map.from(data["PerParticleDelay"]);
    e._durationControl = new Map.from(data["Duration"]);
    e._accelerationControl = new Map.from(data["Acceleration"]);
    
    e._tintControl = new List<Map>();
    
    List<Map> tints = data["Tints"];
    for(Map item in tints) {
      Map color = new Map.from(item["Color"]);
      Map dark = new Map.from(item["Darkness"]);
      Map bright = new Map.from(item["Brightness"]);
      num gv = item["GradientLocation"] as num;
      num cv = item["ColorLocation"] as num;
      Map nItem = {
        "Color": color,
        "Darkness": dark,
        "Brightness": bright,
        "GradientLocation" : gv.toDouble(), 
        "ColorLocation" : cv.toDouble(), 
        "EndStop" : item["EndStop"] as bool 
      };
      e._tintControl.add(nItem);
    }
    
    return e;
  }
  
  factory Emitter.clone(Emitter other) {
    Emitter e = new Emitter();
    
    e._emitterControl = new Map.from(other._emitterControl);
    e._emissionRateControl = new Map.from(other._emissionRateControl);
    e._lifeControl = new Map.from(other._lifeControl);
    e._speedControl = new Map.from(other._speedControl);
    e._startScaleControl = new Map.from(other._startScaleControl);
    e._endScaleControl = new Map.from(other._endScaleControl);
    e._rotationRateControl = new Map.from(other._rotationRateControl);
    e._generalControl = new Map.from(other._generalControl);
    e._perParticleDelayControl = new Map.from(other._perParticleDelayControl);
    e._durationControl = new Map.from(other._durationControl);
    e._accelerationControl = new Map.from(other._accelerationControl);
    
    e._tintControl = new List<Map>();
    
    List<Map> tints = other._tintControl;
    for(Map item in tints) {
      Map color = new Map.from(item["Color"]);
      Map dark = new Map.from(item["Darkness"]);
      Map bright = new Map.from(item["Brightness"]);
      num gv = item["GradientLocation"] as num;
      num cv = item["ColorLocation"] as num;
      Map nItem = {
        "Color": color,
        "Darkness": dark,
        "Brightness": bright,
        "GradientLocation" : gv.toDouble(), 
        "ColorLocation" : cv.toDouble(), 
        "EndStop" : item["EndStop"] as bool 
      };
      e._tintControl.add(nItem);
    }

    return e;
  }
  
  Map get general => _generalControl;
  
  String get name => _name;
  set name(String name) => _name = name;
  
  void equal(Emitter other) {
    //_name = other.name;  copy only the values not the name.
    _emitterControl.addAll(other._emitterControl);
    _emissionRateControl = new Map.from(other._emissionRateControl);
    _lifeControl.addAll(other._lifeControl);
    _speedControl.addAll(other._speedControl);
    _startScaleControl.addAll(other._startScaleControl);
    _endScaleControl.addAll(other._endScaleControl);
    _rotationRateControl.addAll(other._rotationRateControl);
    _generalControl.addAll(other._generalControl);
    _perParticleDelayControl.addAll(other._perParticleDelayControl);
    _durationControl.addAll(other._durationControl);
    _tintControl.addAll(other._tintControl);
    _accelerationControl.addAll(other._accelerationControl);

    _tintControl = new List<Map>();
    
    List<Map> tints = other._tintControl;
    for(Map item in tints) {
      Map color = new Map.from(item["Color"]);
      Map dark = new Map.from(item["Darkness"]);
      Map bright = new Map.from(item["Brightness"]);
      num gv = item["GradientLocation"] as num;
      num cv = item["ColorLocation"] as num;
      Map nItem = {
        "Color": color,
        "Darkness": dark,
        "Brightness": bright,
        "GradientLocation" : gv.toDouble(), 
        "ColorLocation" : cv.toDouble(), 
        "EndStop" : item["EndStop"] as bool 
      };
      _tintControl.add(nItem);
    }

}
  
  set variance(double v) {
    _emitterControl["Variance"] = v;
  }
  
  double get variance {
    num n = _emitterControl["Variance"] as num;
    return n.toDouble();
  }

  set angle(num v) {
    _emitterControl["Angle"] = v;
  }
  
  double get angle {
    num n = _emitterControl["Angle"] as num;
    return n.toDouble();
  }

  set sweepRate(num v) => _emitterControl["SweepRate"] = v;
  
  double get sweepRate {
    num n = _emitterControl["SweepRate"] as num;
    return n.toDouble();
  }

  set emitterType(String name) => _emitterControl["Type"] = name;
  String get emitterType => _emitterControl["Type"];
  
  //----------------------------------------------------------------
  // Emission Rate panel
  //----------------------------------------------------------------
  set minEmissionRate(int v) => _emissionRateControl["Min"] = v;
  
  int get minEmissionRate => _emissionRateControl["Min"] as int;

  set maxEmissionRate(int v) => _emissionRateControl["Max"] = v;
  
  int get maxEmissionRate => _emissionRateControl["Max"] as int;
  
  set varianceEmissionRate(int v) => _emissionRateControl["Variance"] = v;
  
  int get varianceEmissionRate => _emissionRateControl["Variance"] as int;

  set meanEmissionRate(int v) => _emissionRateControl["Mean"] = v;
  
  int get meanEmissionRate => _emissionRateControl["Mean"] as int;

  set emissionRate(int v) => _emissionRateControl["Rate"] = v;
  
  int get emissionRate => _emissionRateControl["Rate"] as int;

  //----------------------------------------------------------------
  // Life panel
  //----------------------------------------------------------------
  set minLife(num v) => _lifeControl["Min"] = v;
  
  double get minLife {
    num n = _lifeControl["Min"] as num;
    return n.toDouble();
  }

  set maxLife(num v) => _lifeControl["Max"] = v;
  
  double get maxLife {
    num n = _lifeControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceLife(num v) => _lifeControl["Variance"] = v;
  
  double get varianceLife {
    num n = _lifeControl["Variance"] as num;
    return n.toDouble();
  }

  set meanLife(num v) => _lifeControl["Mean"] = v;
  
  double get meanLife {
    num n = _lifeControl["Mean"] as num;
    return n.toDouble();
  }

  //----------------------------------------------------------------
  // Speed panel
  //----------------------------------------------------------------
  set minSpeed(num v) => _speedControl["Min"] = v;
  
  double get minSpeed {
    num n = _speedControl["Min"] as num;
    return n.toDouble();
  }

  set maxSpeed(num v) => _speedControl["Max"] = v;
  
  double get maxSpeed {
    num n = _speedControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceSpeed(num v) => _speedControl["Variance"] = v;
  
  double get varianceSpeed {
    num n = _speedControl["Variance"] as num;
    return n.toDouble();
  }

  set meanSpeed(num v) => _speedControl["Mean"] = v;
  
  int get meanSpeed {
    num n = _speedControl["Mean"] as num;
    return n.toInt();
  }

  //----------------------------------------------------------------
  // Acceleration panel
  //----------------------------------------------------------------
  set minAcceleration(num v) => _accelerationControl["Min"] = v;
  
  double get minAcceleration {
    num n = _accelerationControl["Min"] as num;
    return n.toDouble();
  }

  set maxAcceleration(num v) => _accelerationControl["Max"] = v;
  
  double get maxAcceleration {
    num n = _accelerationControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceAcceleration(num v) => _accelerationControl["Variance"] = v;
  
  double get varianceAcceleration {
    num n = _accelerationControl["Variance"] as num;
    return n.toDouble();
  }

  set meanAcceleration(num v) => _accelerationControl["Mean"] = v;
  
  int get meanAcceleration {
    num n = _accelerationControl["Mean"] as num;
    return n.toInt();
  }

  //----------------------------------------------------------------
  // Start Scale panel
  //----------------------------------------------------------------
  set minStartScale(num v) => _startScaleControl["Min"] = v;
  
  double get minStartScale {
    num n = _startScaleControl["Min"] as num;
    return n.toDouble();
  }

  set maxStartScale(num v) => _startScaleControl["Max"] = v;
  
  double get maxStartScale {
    num n = _startScaleControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceStartScale(num v) => _startScaleControl["Variance"] = v;
  
  double get varianceStartScale {
    num n = _startScaleControl["Variance"] as num;
    return n.toDouble();
  }

  set meanStartScale(num v) => _startScaleControl["Mean"] = v;
  
  double get meanStartScale {
    num n = _startScaleControl["Mean"] as num;
    return n.toDouble();
  }

  //----------------------------------------------------------------
  // End Scale panel
  //----------------------------------------------------------------
  set minEndScale(num v) => _endScaleControl["Min"] = v;
  
  double get minEndScale {
    num n = _endScaleControl["Min"] as num;
    return n.toDouble();
  }

  set maxEndScale(num v) => _endScaleControl["Max"] = v;
  
  double get maxEndScale {
    num n = _endScaleControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceEndScale(num v) => _endScaleControl["Variance"] = v;
  
  double get varianceEndScale {
    num n = _endScaleControl["Variance"] as num;
    return n.toDouble();
  }

  set meanEndScale(num v) => _endScaleControl["Mean"] = v;
  
  double get meanEndScale {
    num n = _endScaleControl["Mean"] as num;
    return n.toDouble();
  }

  //----------------------------------------------------------------
  // Rotational rate panel
  //----------------------------------------------------------------
  set minRotationRate(num v) => _rotationRateControl["Min"] = v;
  
  double get minRotationRate {
    num n = _rotationRateControl["Min"] as num;
    return n.toDouble();
  }

  set maxRotationRate(num v) => _rotationRateControl["Max"] = v;
  
  double get maxRotationRate {
    num n = _rotationRateControl["Max"] as num;
    return n.toDouble();
  }
  
  set varianceRotationRate(num v) => _rotationRateControl["Variance"] = v;
  
  double get varianceRotationRate {
    num n = _rotationRateControl["Variance"] as num;
    return n.toDouble();
  }

  set meanRotationRate(num v) => _rotationRateControl["Mean"] = v;
  
  double get meanRotationRate {
    num n = _rotationRateControl["Mean"] as num;
    return n.toDouble();
  }

  //----------------------------------------------------------------
  // General panel
  //----------------------------------------------------------------
  set maxParticle(int v) => _generalControl["MaxParticle"] = v;
  int get maxParticle => _generalControl["MaxParticle"] as int;

  set EnabledParticleDelay(bool v) => _generalControl["EnableParticleDelay"] = v;
  bool get EnabledParticleDelay => _generalControl["EnableParticleDelay"] as bool;

  set syncSpeedToScale(bool v) => _generalControl["SpeedToScale"] = v;
  
  bool get syncSpeedToScale {
    bool n = _generalControl["SpeedToScale"] as bool;
    return n;
  }
  
  //----------------------------------------------------------------
  // Duration panel
  //----------------------------------------------------------------
  set emitterDuration(int v) => _durationControl["Duration"] = v;
  int get emitterDuration => _durationControl["Duration"] as int;

  set pauseFor(int v) => _durationControl["PauseFor"] = v;
  int get pauseFor => _durationControl["PauseFor"] as int;

  set continuousEnabled(bool v) => _durationControl["ContinuousEnabled"] = v;
  bool get continuousEnabled => _durationControl["ContinuousEnabled"] as bool;

  set durationEnabled(bool v) => _durationControl["DurationEnabled"] = v;
  bool get durationEnabled => _durationControl["DurationEnabled"] as bool;

  
  //----------------------------------------------------------------
  // Per particle delay panel
  //----------------------------------------------------------------
  set minParticleDelay(int v) => _perParticleDelayControl["Min"] = v;
  int get minParticleDelay => _perParticleDelayControl["Min"] as int;

  set maxParticleDelay(int v) => _perParticleDelayControl["Max"] = v;
  int get maxParticleDelay => _perParticleDelayControl["Max"] as int;
  
  set varianceParticleDelay(int v) => _perParticleDelayControl["Variance"] = v;
  int get varianceParticleDelay => _perParticleDelayControl["Variance"] as int;

  set meanParticleDelay(int v) => _perParticleDelayControl["Mean"] = v;
  int get meanParticleDelay => _perParticleDelayControl["Mean"] as int;

  //----------------------------------------------------------------
  // Tints panel
  //----------------------------------------------------------------
  double getColorLocation(int index) {
    num v = _tintControl[index]["ColorLocation"] as num;
    return v.toDouble();
  }
  void setColorLocation(int index, double loc) {
    _tintControl[index]["ColorLocation"] = loc;
  }
  
  double getGradientLocation(int index) {
    num v = _tintControl[index]["GradientLocation"] as num;
    return v.toDouble();
  }
  void setGradientLocation(int index, double loc) {
    _tintControl[index]["GradientLocation"] = loc;
  }
  
  Ranger.Color4<int> getColor(int index) {
    Map m = _tintControl[index]["Color"];
    num r = m["Red"] as num;
    num g = m["Green"] as num;
    num b = m["Blue"] as num;
    num a = m["Alpha"] as num;
    Ranger.Color4<int> c = new Ranger.Color4<int>.withRGBA(r.toInt(), g.toInt(), b.toInt(), a.toInt());
    return c;
  }
  
  void setColor(int index, int r, int g, int b, int a) {
    Map m = _tintControl[index]["Color"];
    m["Red"] = r;
    m["Green"] = g;
    m["Blue"] = b;
    m["Alpha"] = a;
  }
  
  Ranger.Color4<int> getDarkness(int index) {
    Map m = _tintControl[index]["Darkness"];
    num r = m["Red"] as num;
    num g = m["Green"] as num;
    num b = m["Blue"] as num;
    num a = m["Alpha"] as num;
    Ranger.Color4<int> c = new Ranger.Color4<int>.withRGBA(r.toInt(), g.toInt(), b.toInt(), a.toInt());
    return c;
  }
  
  void setDarkness(int index, int r, int g, int b, int a) {
    Map m = _tintControl[index]["Darkness"];
    m["Red"] = r;
    m["Green"] = g;
    m["Blue"] = b;
    m["Alpha"] = a;
  }
  
  Ranger.Color4<int> getBrightness(int index) {
    Map m = _tintControl[index]["Brightness"];
    num r = m["Red"] as num;
    num g = m["Green"] as num;
    num b = m["Blue"] as num;
    num a = m["Alpha"] as num;
    Ranger.Color4<int> c = new Ranger.Color4<int>.withRGBA(r.toInt(), g.toInt(), b.toInt(), a.toInt());
    return c;
  }
  
  void setBrightness(int index, int r, int g, int b, int a) {
    Map m = _tintControl[index]["Brightness"];
    m["Red"] = r;
    m["Green"] = g;
    m["Blue"] = b;
    m["Alpha"] = a;
  }
  
  bool getIsEndStop(int index) {
    return _tintControl[index]["EndStop"] as bool;
  }
  void setIsEndStop(int index, bool value) {
    _tintControl[index]["EndStop"] = value;
  }

  @override
  String toString() {
    return _tintControl.toString();
  }
  
  Map toMap() {
    Map data = {
       "EmitterControl": _emitterControl,
       "Life": _lifeControl,
       "Speed": _speedControl,
       "StartScale": _startScaleControl,
       "EndScale": _endScaleControl,
       "RotationRate": _rotationRateControl,
       "General": _generalControl,
       "PerParticleDelay": _perParticleDelayControl,
       "Duration": _durationControl,
       "Tints": _tintControl,
       "Acceleration": _accelerationControl
    };
    
    Map dfMap = {
      "name" : name,
      "data" : data
    };

    return dfMap;
  }
}