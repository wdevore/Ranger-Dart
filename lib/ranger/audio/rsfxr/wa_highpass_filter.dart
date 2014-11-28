part of ranger;

class WAHighPassFilter {
  AudioContext _context;
  
  double frequencyCutoff = 0.0;
  double prevFrequencyCutoff = 0.0;
  // Higher values lead to more distortion.
  double _qResonance = 0.001;
  double _prevQResonance = 0.0;
  
  double cutoffSweep = 100.0;
  
  BiquadFilterNode _filter;
  GainNode _gain;
  
  bool enabled = false;
  
  WAHighPassFilter();
  
  factory WAHighPassFilter.basic(AudioContext ac) {
    WAHighPassFilter e = new WAHighPassFilter();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _filter = _context.createBiquadFilter();
    _filter.type = "highpass";
    
    _gain = _context.createGain();
    
    _filter.connectNode(_gain);
    
    return true;
  }
  
  AudioNode get input => _filter;
  AudioNode get output => _gain;
  
  double get qResonance => _qResonance;
  set qResonance(double q) {
    _qResonance = q;
  }
  
  void reset() {
    frequencyCutoff = 0.0;
    _qResonance = 0.001;
    cutoffSweep = 100.0;
    
    double now = _context.currentTime;
    _filter.Q.cancelScheduledValues(now);
    _filter.frequency.cancelScheduledValues(now);
    _filter.Q.setValueAtTime(_qResonance, now);
    _filter.frequency.setValueAtTime(frequencyCutoff, now);
  }

  void update(double now) {

    if (_qResonance != _prevQResonance) {
      _filter.Q.cancelScheduledValues(now);
      _filter.Q.setValueAtTime(_qResonance, now);
    }

    bool valueChanged = false;
    
    if (frequencyCutoff != prevFrequencyCutoff) {
      _filter.frequency.cancelScheduledValues(now);
      _filter.frequency.setValueAtTime(frequencyCutoff, now);
      valueChanged = true;
    }
    
    if (!valueChanged)
      _filter.frequency.cancelScheduledValues(now);
  
    double gain = 1.0 / (1.0 + _qResonance);
    gain.clamp(0.25, 1.0);
    
    _gain.gain.value = gain;

    // Ramping moves from the slightly above cutoff to just below cutoff
    double rampTo = cutoffSweep + 0.001;
  
    _filter.frequency.cancelScheduledValues(now);
    _filter.frequency.setValueAtTime(frequencyCutoff, now);
    _filter.frequency.exponentialRampToValueAtTime(rampTo, now + 1.0);
    
    prevFrequencyCutoff = frequencyCutoff;
    _prevQResonance = _qResonance;
  }
}