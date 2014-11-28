part of ranger;

// http://www.soundonsound.com/sos/mar06/articles/qa0306_1.htm
class WAPhaserFilter {
  AudioContext _context;
  
  // Higher values lead to more distortion.
  double _sharpness = 100.0;
  double _prevSharpness = 0.0;
  
  double _centerFrequency = 100.0;
  double _prevCenterFrequency = 0.0;
  
  BiquadFilterNode _filter;
  DelayNode _delay;
  GainNode _inputGain;
  OscillatorNode _lfo;
  
  bool enabled = true;
  
  WAPhaserFilter();
  
  factory WAPhaserFilter.basic(AudioContext ac) {
    WAPhaserFilter e = new WAPhaserFilter();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _filter = _context.createBiquadFilter();
    _filter.type = "allpass";
    
    _lfo = _context.createOscillator();
    _lfo.frequency.value = 100.0;
    
    _inputGain = _context.createGain();
//    _inputGain.gain.value = 0.35;
    _delay = _context.createDelay();
    _delay.delayTime.value = 0.25;
    
    _inputGain.connectNode(_delay);
//    _inputGain.connectNode(_filter);
    _delay.connectNode(_filter);
//    _filter.connectNode(_inputGain);
    _filter.connectParam(_lfo.frequency);
    _lfo.connectParam(_delay.delayTime);
    
    return true;
  }
  
  AudioNode get input => _inputGain;
  AudioNode get output => _filter;
  
  double get Sharpness => _sharpness;
  set Sharpness(double q)=> _sharpness = q;
  
  double get CenterFrequency => _centerFrequency;
  set CenterFrequency(double f)=> _centerFrequency = f;
  
  void update(double now) {
    if (_sharpness != _prevSharpness) {
      _filter.Q.cancelScheduledValues(now);
//      _filter.Q.setValueAtTime(_sharpness, now);
      _filter.Q.value = _sharpness;
    }

    if (_centerFrequency != _prevCenterFrequency) {
      _filter.frequency.cancelScheduledValues(now);
//      _filter.frequency.setValueAtTime(_centerFrequency, now);
      _filter.frequency.value = _centerFrequency;
    }
    
    _prevCenterFrequency = _centerFrequency;
    _prevSharpness = _sharpness;
  }
}