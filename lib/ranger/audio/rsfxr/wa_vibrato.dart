part of ranger;

//OscillatorNode saw = context.createOscillator();  //<-- source
//OscillatorNode     sine = context.createOscillator();  //<-- LFO
//GainNode      oscGain = context.createGain();  //<-- LFO strength
//
////set up our oscillator types
//saw.type = "Sawtooth";   //<--- input/source
//saw.frequency.value = 240;
//
//sine.type = "Sine";  //<-- LFO
//sine.frequency.value = 8;
//
////set the amplitude of the modulation
//oscGain.gain.value = 20;
//
//// Connect the output of the LFO into the osc gain node.
//sine.connectNode(oscGain);
//
//// Connect one output of the current node to one input of an audio parameter
//oscGain.connectParam(saw.frequency);
//saw.connectNode(context.destination);
//
//saw.start(0);
//sine.start(0);

class WAVibrato {
  AudioContext _context;
  
  AudioNode _input;
  
  OscillatorNode _lfo;
  GainNode _gain;   // Strength
  
  bool enabled = false;
  
  WAVibrato();
  
  factory WAVibrato.basic(AudioContext ac) {
    WAVibrato e = new WAVibrato();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _lfo = _context.createOscillator();
    
    _gain = _context.createGain();
    _gain.gain.value = 0.0;
    
    _lfo.connectNode(_gain);
    
    return true;
  }
  
  AudioNode get input => _lfo;
  AudioNode get output => _gain;

  void reset() {
    frequency = 0.0;
    strength = 20.0;//Math.pow(s, 1.5)
    
    double now = _context.currentTime;
    _gain.gain.cancelScheduledValues(now);
    _lfo.frequency.cancelScheduledValues(now);
//    _gain.gain.setValueAtTime(strength, now);
//    _lfo.frequency.setValueAtTime(frequency, now);
  }
  
  void configure(String type, double frequency, double strength) {
    _gain.gain.value = strength;
    _lfo.frequency.value = frequency;
  }
  
  double get frequency => _lfo.frequency.value;
  set frequency(double f) => _lfo.frequency.value = f;
  
  double get strength => _gain.gain.value;
  set strength(double s) => _gain.gain.value = s;
  
  void start([double when = 0.0]) {
    _lfo.start(when);
  }

  void stop([double when = 0.0]) {
    _lfo.stop(when);
  }
}