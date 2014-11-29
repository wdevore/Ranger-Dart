part of ranger;

class WALowPassFilter {
  AudioContext _context;
  
  double frequencyCutoff = 25000.0;
  double _prevFrequencyCutoff = 0.0;
  // Higher values lead to more distortion.
  double _qResonance = 0.001;
  double _prevQResonance = 0.0;
  
  double cutoffSweep = 0.001;
  
  BiquadFilterNode _filter;
  
  bool enabled = false;
  
  WALowPassFilter();
  
  factory WALowPassFilter.basic(AudioContext ac) {
    WALowPassFilter e = new WALowPassFilter();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _filter = _context.createBiquadFilter();
    _filter.type = "lowpass";
    
    return true;
  }
  
  BiquadFilterNode get input => _filter;
  BiquadFilterNode get output => _filter;
  
  double get qResonance => _qResonance;
  set qResonance(double q) {
    _qResonance = q;
  }
  
  void reset() {
    frequencyCutoff = 25000.0;
    _qResonance = 0.001;
    cutoffSweep = 0.001;
    
    double now = _context.currentTime;
    _filter.Q.cancelScheduledValues(now);
    _filter.frequency.cancelScheduledValues(now);
    _filter.Q.setValueAtTime(_qResonance, now);
    _filter.frequency.setValueAtTime(frequencyCutoff, now);
  }
  
  void update(double now) {
    if (frequencyCutoff == 25000.0) {
      _filter.Q.cancelScheduledValues(now);
      _filter.Q.value = 0.0;
      _filter.frequency.cancelScheduledValues(now);
      _filter.frequency.setValueAtTime(frequencyCutoff, now);
      return;
    }
    
    if (_qResonance != _prevQResonance) {
      _filter.Q.cancelScheduledValues(now);
      _filter.Q.setValueAtTime(_qResonance, now);
    }

    bool valueChanged = false;
    
    if (frequencyCutoff != _prevFrequencyCutoff) {
      _filter.frequency.cancelScheduledValues(now);
      _filter.frequency.setValueAtTime(frequencyCutoff, now);
      valueChanged = true;
    }
    
    if (!valueChanged)
      _filter.frequency.cancelScheduledValues(now);
    
    // Ramping moves from the slightly above cutoff to just below cutoff
    double rampTo = cutoffSweep;
  
    _filter.frequency.cancelScheduledValues(now);
    _filter.frequency.setValueAtTime(frequencyCutoff, now);
    _filter.frequency.exponentialRampToValueAtTime(rampTo, now + 1.0);
    
    _prevFrequencyCutoff = frequencyCutoff;
    _prevQResonance = _qResonance;
  }
}