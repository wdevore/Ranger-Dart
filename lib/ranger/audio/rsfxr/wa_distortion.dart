part of ranger;

/**
 * https://developer.mozilla.org/en-US/docs/Web/API/WaveShaperNode
 * http://kevincennis.github.io/transfergraph/
 * 
 * Consider adding a wavetable.
 * http://en.wikibooks.org/wiki/Sound_Synthesis_Theory/Oscillators_and_Wavetables
 */
class WADistortion {
  AudioContext _context;
  
  WaveShaperNode _shaper;
  String overSampling = "8x";
  
  double scale = 0.1;
  double _ks;
  
  int sumParts = 2;
  
  double mag1 = 0.5;
  double mag2 = 0.5;
  double mag3 = 0.5;
  double _k1;
  double _k2;
  double _k3;
  
  int equation = 2;
  
  double clamp = 2.0;
  
  bool enabled = false;
  Float32List _curve;
  int samples;

  WADistortion();
  
  factory WADistortion.basic(AudioContext ac) {
    WADistortion e = new WADistortion();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;

    _shaper = _context.createWaveShaper();
    _shaper.oversample = overSampling;

    samples = _context.sampleRate.floor();

    _curve = new Float32List(samples);

    return true;
  }
  
  AudioNode get input => _shaper;
  AudioNode get output => _shaper;

  void createDistortion() {
    double deg = math.PI / 180.0;
    int i = 0;
    double x;
    double z = 0.0;
    
    for ( ; i < samples; ++i ) {
      x = i * 2.0 / samples - 1.0;
      switch (equation) {
        case 0:
          z = math.sin(x*x*x*_k1);
          if (sumParts > 0)
            z += math.cos(x*_k2);
          if (sumParts > 1)
            z += math.tan(x*_k3);
          if (sumParts > 2)
            z+= (1.0/x*x*x);
          z *= _ks;
          break;
        case 1:
          z = math.sin(x*x*x*_k1);
          if (sumParts > 0)
            z += math.tan(x*x*x*x*_k2);
          z *= _ks;
          break;
        case 2:
          z = math.sin(x*x*x*x*x*_k1);
          if (sumParts > 0)
            z += math.cos(x*x*_k2);
          if (sumParts > 1)
            z += math.tan(x*_k3);
          z *= _ks;
          break;
        case 3:
          z = math.sin(x*_k1);
          if (sumParts > 0)
            z += math.cos(x*_k2);
          if (sumParts > 1)
            z += math.tan(x*_k3);
          z /= _ks;
          break;
        case 4:
          z = x / (_k1 * (x*x*x*x*x*x*x*x).abs()) * math.sin(x+_k2)*math.cos(x+_k3);
          if (sumParts > 0)
            z += x*x;
          if (sumParts > 1)
            z += x*x*x*x;
          z *= _ks;
          break;
        case 5:
          z = math.pow(x*_k1,x*x*x);
          if (sumParts > 0)
            z += math.pow(_k2, x) * math.tan(x*x*x*x*x*x*x+_k3);
          if (sumParts > 1)
            z += x*x*x*x;
          if (sumParts > 2)
            z += x*x;
          z *= _ks;
          break;
      }
      _curve[i] = z.clamp(-clamp, clamp);
    }
    
    _shaper.curve = _curve;
  }
  
  void update() {
    switch (equation) {
      case 0:
        _k1 = 1000.0 * mag1;
        _k2 = 100.0 * mag2;
        _k3 = 5.0 * mag3;
        _ks = 0.1 * scale;
        break;
      case 1:
        _k1 = 100.0 * mag1;
        _k2 = 10.0 * mag2;
        _ks = 1.0 * scale;
        break;
      case 2:
        _k1 = 40.0 * mag1;
        _k2 = 10.0 * mag2;
        _k3 = 40.0 * mag2;
        _ks = 3.0 * scale;
        break;
      case 3:
        _k1 = 20.0 * mag1;
        _k2 = 20.0 * mag2;
        _k3 = 20.0 * mag2;
        _ks = 1.0 * scale;
        break;
      case 4:
        _k1 = 100.0 * mag1;
        _k2 = 100.0 * mag2;
        _k3 = 100.0 * mag2;
        _ks = 10.0 * scale;
        break;
      case 5:
        _k1 = 100.0 * mag1;
        _k2 = 100.0 * mag2;
        _k3 = 100.0 * mag2;
        _ks = 10.0 * scale;
        break;
    }
    createDistortion();
  }
  
  void reset() {
    scale = 0.1;
    
    sumParts = 2;
    
    mag1 = 0.5;
    mag2 = 0.5;
    mag3 = 0.5;
    
    equation = 2;
    
    clamp = 2.0;
  }
  
}