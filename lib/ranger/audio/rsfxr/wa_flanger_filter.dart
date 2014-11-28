part of ranger;

// http://www.soundonsound.com/sos/mar06/articles/qa0306_1.htm
class WAFlangerFilter {
  AudioContext _context;
  
  double _frequency = 8.0;
  double _prevFrequency = 0.0;
  
  // Feedback sweep ramps in either direction. If < 0 then ramp towards
  // 0.0 else towards 1.0.
  // We always ramp from the current feedback.
  double _feedbackSweep = 0.0;
  double _prevfeedbackSweep = 0.0;

  double _baseDelay = 0.1;
  double _prevBaseDelay = 0.0;
  
  double _delayScaler = 0.01;  // default +-10ms
  double _prevDelayScaler = 0.0;

  double _feedBack = 0.5;
  double _prevFeedBack = 0.0;

  DelayNode _delay;
  OscillatorNode _lfo;

  GainNode _feedbackGain;
  GainNode _mix;
  GainNode _scaler;
  GainNode _input;
  
  bool enabled = false;
  
  WAFlangerFilter();
  
  factory WAFlangerFilter.basic(AudioContext ac) {
    WAFlangerFilter e = new WAFlangerFilter();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _lfo = _context.createOscillator();
    _lfo.frequency.value = _frequency;
    
    _feedbackGain = _context.createGain();
    _feedbackGain.gain.value = _feedBack;

    _scaler = _context.createGain();
    _scaler.gain.value = _delayScaler;

    _mix = _context.createGain();
    
    _input = _context.createGain();
    
    _delay = _context.createDelay();
    _delay.delayTime.value = _baseDelay;
    
    // ------------------------------------------------------
    // Connect nodes
    // ------------------------------------------------------
    _input.connectNode(_mix); // Delay bypass
    _delay.connectNode(_mix);

    // Creates a feedback loop
    _delay.connectNode(_feedbackGain);
    _feedbackGain.connectNode(_delay);

    _input.connectNode(_delay);

    _scaler.connectParam(_delay.delayTime);
    _lfo.connectNode(_scaler);
    
    return true;
  }
  
  AudioNode get input => _input;
  AudioNode get output => _mix;
  
  double get Frequency => _frequency;
  set Frequency(double f) => _frequency = f;
  
  double get DelayScaler => _delayScaler;
  set DelayScaler(double s) => _delayScaler = s;
  
  double get Feedback => _feedBack;
  set Feedback(double s) => _feedBack = s;
  
  double get FeedbackSweep => _feedbackSweep;
  set FeedbackSweep(double d) => _feedbackSweep = d;
  
  double get BaseDelay => _baseDelay;
  set BaseDelay(double t) => _baseDelay = t;
  
  void reset() {
    double now = _context.currentTime;

    _lfo.frequency.cancelScheduledValues(now);
    _feedbackGain.gain.cancelScheduledValues(now);
    _scaler.gain.cancelScheduledValues(now);
    _mix.gain.cancelScheduledValues(now);
    _input.gain.cancelScheduledValues(now);
    _delay.delayTime.cancelScheduledValues(now);

    Frequency = 8.0;
    FeedbackSweep = 0.0;
    BaseDelay = 0.1;
    DelayScaler = 0.01;  // default +-10ms
    Feedback = 0.5;

//    _lfo.frequency.setValueAtTime(Frequency, now);
//    _feedbackGain.gain.setValueAtTime(Feedback, now);
//    _scaler.gain.setValueAtTime(DelayScaler, now);
//    _mix.gain.setValueAtTime(1.0, now);
//    _input.gain.setValueAtTime(1.0, now);
//    _delay.delayTime.setValueAtTime(BaseDelay, now);
  }
  
  void update(double now) {
    if (_frequency != _prevFrequency) {
      _lfo.frequency.cancelScheduledValues(now);
      _lfo.frequency.setValueAtTime(_frequency, now);
    }

    if (_delayScaler != _prevDelayScaler) {
      _scaler.gain.value = _delayScaler;
    }
    
    if (_feedBack != _prevFeedBack) {
      _feedbackGain.gain.value = _feedBack;
    }
    
    if (_feedbackSweep != 0.0) {
      _feedbackGain.gain.cancelScheduledValues(now);
      _feedbackGain.gain.setValueAtTime(_feedBack, now);
      double rampTo = 1.0;
      double time = _feedbackSweep.abs();
      
      if (_feedbackSweep < 0.0) {
        rampTo = 0.0;
      }
      
      _feedbackGain.gain.linearRampToValueAtTime(rampTo, time);
    }

    if (_baseDelay != _prevBaseDelay) {
      _delay.delayTime.value = _baseDelay;
    }

    _prevBaseDelay = _baseDelay;
    _prevfeedbackSweep = _feedbackSweep;
    _prevFrequency = _frequency;
    _prevDelayScaler = _delayScaler;
    _prevFeedBack = _feedBack;
  }
}