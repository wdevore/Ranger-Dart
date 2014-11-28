part of ranger;


class WAEnvelope {
  // [TIME] = time, [VALUE] = value
  static const int TIME = 0;
  static const int VALUE = 1;
  
  List<double> attack = new List<double>(2);
  List<double> decay = new List<double>(2);
  List<double> sustain = new List<double>(2);
  double sustainPunch = 0.0;
  List<double> release = new List<double>(2);
  
  AudioContext _context;
  
  GainNode _envelope;
  
  WAEnvelope();
  
  factory WAEnvelope.basic(AudioContext ac) {
    WAEnvelope e = new WAEnvelope();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    _envelope = _context.createGain();
    
    reset();
    
    return true;
  }
  
  AudioNode get output => _envelope;
  AudioNode get input => _envelope;

  void reset() {
    double now = _context.currentTime;
    _envelope.gain.cancelScheduledValues(now);
    _envelope.gain.setValueAtTime(0.0, now);

    _envelope.gain.value = 0.0;
    attack[TIME] = 0.0; attack[VALUE] = 1.0;
    decay[TIME] = 0.0; decay[VALUE] = 1.0;
    sustain[TIME] = 1.0; sustain[VALUE] = 1.0;
    release[TIME] = 0.0; release[VALUE] = 0.0;
  }
  
  void setAttack(double value, double time) {
    attack[TIME] = time; attack[VALUE] = value;
  }
  
  void setDecay(double value, double time) {
    decay[TIME] = time; decay[VALUE] = value;
  }
  
  void setSustain(double value, double time) {
    sustain[TIME] = time; sustain[VALUE] = value;
  }
  
  void setRelease(double value, double time) {
    release[TIME] = time; release[VALUE] = value;
  }
  
  set volume(double value) => _envelope.gain.value = value;
  
  double trigger(double now) {
    // Time is "relative" and it is relative to the currentTime maintained
    // internally by the AudioContext.
    AudioParam gainParam = _envelope.gain;
    
    // Cancel any ramping in progress
    gainParam.cancelScheduledValues(now);

    // Reset to the starting position of "now"
    gainParam.setValueAtTime(0.0, now);

    // Configure Attack window
    // We want to ramp from the 0 value to the Attack value.
    gainParam.linearRampToValueAtTime(attack[VALUE], now + attack[TIME]);
    
    // Advance time.
    now += attack[TIME];

    // Configure Decay window.
    // We want to ramp from the Attack value to the Decay value.
    gainParam.linearRampToValueAtTime(decay[VALUE], now + decay[TIME]);

    // Advance time.
    now += decay[TIME];

    // Configure Sustain window
    // We want to ramp from the Sustain value to the Release value.
    gainParam.linearRampToValueAtTime(sustain[VALUE], now + sustain[TIME]);

    // Advance time.
    now += sustain[TIME];

    // Configure Release window
    // We want to ramp from the Release value to 0 value.
    gainParam.linearRampToValueAtTime(0.0, now + release[TIME]);

    now += release[TIME];
    
    return now;
  }
}