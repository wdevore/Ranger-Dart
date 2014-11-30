part of ranger;

// Tremolo
//  OscillatorNode  osc = context.createOscillator();
//  OscillatorNode  lfo = context.createOscillator();
//  GainNode  volume = context.createGain();
//
//  osc.frequency.value = 240;
//  lfo.frequency.value = 8;
//
//  osc.connectNode(volume);
//  lfo.connectParam(volume.gain);
//  volume.connectNode(context.destination);
//  osc.start(0);
//  lfo.start(0);

class WATremolo {
  AudioContext _context;
  
  AudioNode _input;
  OscillatorNode lfo;
  
  // The node that will vary the incoming signal
  GainNode gain;   // Strength
  
  bool enabled = false;
  
  WATremolo();
  
  factory WATremolo.basic(AudioContext ac) {
    WATremolo e = new WATremolo();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    lfo = _context.createOscillator();
    
    gain = _context.createGain();
    
    lfo.connectParam(gain.gain);
    
    return true;
  }
  
  AudioNode get output => gain;
  AudioNode get input => gain;
  
  void reset() {
    frequency = 0.0;
    strength = 0.0;
    
    double now = _context.currentTime;
    gain.gain.cancelScheduledValues(now);
    lfo.frequency.cancelScheduledValues(now);
    gain.gain.setValueAtTime(1.0, now);
    lfo.frequency.setValueAtTime(frequency, now);
  }
  
  void configure(String type, double frequency, double strength) {
    gain.gain.value = strength;
    lfo.frequency.value = frequency;
  }
  
  String get waveType => lfo.type;
  set waveType(String f) => lfo.type = f;

  double get frequency => lfo.frequency.value;
  set frequency(double f) => lfo.frequency.value = f;
  
  double get strength => gain.gain.value;
  set strength(double s) => gain.gain.value = s;
  
  void start([double when = 0.0]) {
    lfo.start(when);
  }

  void stop([double when = 0.0]) {
    lfo.stop(when);
  }
}