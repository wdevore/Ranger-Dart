part of ranger;

/*
 * Consider adding a custom periodic wave such as a horn
 * http://www.sitepoint.com/using-fourier-transforms-web-audio-api/
 */
class WAGenerator {
  AudioContext _context;
  static const double DEFAULT_FREQUENCY = 340.0;
  
  OscillatorNode _osc;
  String _oscType = WASfxr.SINE;
  String _prevOscType = "";
  bool _oscEnabled = false;
  double _frequency = DEFAULT_FREQUENCY;
  
  bool _oscDisconnected = true;
  
  // Square/Sawtooth
  DelayNode _delay;
  GainNode _inverter;
  
  // Main output
  GainNode _mixer;
  double signalGain = 0.25;
  double _prevSignalGain = 0.0;
  
  // Noise
  // 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384
  // 5   6   7    --->                              14 
  int _bufferSize = 10;
  int _prevBufferSize = 0;
  GainNode _noiseAmp;
  AudioBuffer _noise;
  AudioBufferSourceNode _noiseSrc;
  double _playbackRate = 2.0;
  double _prevPlaybackRate = 0.0;
  bool _noiseEnabled = false;
  double _noiseVolume = 1.0;
  double _prevNoiseVolume = 0.0;
  
  // Overdrives
  double _overdrive = 0.0;
  double _prevOverdrive = 0.0;
  double _noiseDistortion = 5.0;
  double _pinkNoiseDistortion = 2.5;
  double _brownNoiseDistortion = 150.0;
  
  // Distortion
  WADistortion distortion;

  // Optional DC offset.
  //AudioBuffer _dcOffsetBuffer;
  //AudioBufferSourceNode _dcOffsetNode;
  //GainNode _dcGain;
  
  double _dutyCycle = 0.5;
  // Sweep starts from the current cycle and ramps in the direction of
  // the sign. If < 0 then ramps to 0.0 else ramp to 1.0
  // The magnitude effects the time component. Smaller value means faster
  // sweep.
  double _deltaSweep = 0.0;
  double _sweepScaler = 1.0;
  
  AudioNode _output;
  
  WAGenerator();
  
  factory WAGenerator.basic(AudioContext ac) {
    WAGenerator e = new WAGenerator();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _osc = _context.createOscillator();
    _osc.type = _oscType;
    _osc.frequency.value = DEFAULT_FREQUENCY;
    
    _noiseAmp = _context.createGain();
    
    //_createDCOffset();

    _inverter = _context.createGain();
    _inverter.gain.value = -1.0;
    
    _delay = _context.createDelay();
    _mixer = _context.createGain();
    _mixer.gain.value = signalGain;
    
    // Optional
    //_dcGain.connectNode(_add);

    _noiseAmp.connectNode(_mixer);

    enableFrequency = _oscEnabled;
    _inverter.connectNode(_delay);
    
    _delay.connectNode(_mixer);

    _delay.delayTime.value = _dutyCycle/frequency;
    
    distortion = new WADistortion.basic(_context);
    
    _output = _mixer;
    
    return true;
  }
  
  AudioNode get output => _output;
  AudioNode get input => _osc;

  void disconnectOutput() {
    if (distortion.enabled) {
      _mixer.disconnect(0);
      distortion.output.disconnect(0);
    }
    else {
      _mixer.disconnect(0);
    }
  }
  
  void configureOutput() {
    if (distortion.enabled)
      _output = distortion.output;
    else
      _output = _mixer;
  }
  
  AudioParam get frequencyParam => _osc.frequency;
  
  void reset() {
    double now = _context.currentTime;
    _osc.frequency.cancelScheduledValues(now);
    _osc.frequency.setValueAtTime(0.0, now);
    _delay.delayTime.cancelScheduledValues(now);
    _delay.delayTime.setValueAtTime(0.0, now);

    _oscType = WASfxr.SINE;

    signalGain = 0.25;
    
    _bufferSize = 10;
    _playbackRate = 2.0;
    _noiseEnabled = false;
    _noiseVolume = 1.0;
    _pinkNoiseDistortion = 2.5;  // Overdrive
    _brownNoiseDistortion = 50.0;
    
    _dutyCycle = 0.5;
    _deltaSweep = 0.0;
    _sweepScaler = 1.0;
    distortion.reset();
  }
  
  void setSlide(double frequency, double time) {
    _osc.frequency.exponentialRampToValueAtTime(frequency, time);
  }
  
  void setArpeggio(double fStep, double time, double decay) {
    _osc.frequency.setTargetAtTime(fStep, time, decay);
  }
  
  void setDutySweep(double sweep, double time) {
    if (sweep == 0.0)
      return;
    
    _deltaSweep = sweep;
    
    double deltaPeriod = 0.001;
    
    // We ramp from the current duty cycle (DCy) to a destination DCy. 
    // Duty cycle 0.0 -> 1.0;
    // Period DCy/Frequency
    
    // Sweep -1.0 -> 1.0
    double rate = sweep.abs();
    rate *= _sweepScaler;
    
    if (sweep > 0.0) {
      deltaPeriod = 1.0 / frequency; // Ramp to period
    }
    else {
      deltaPeriod = 0.001;
    }
    
    //_mixer.gain.value = 1.7 * (0.5 - deltaPeriod);
    
    _delay.delayTime.exponentialRampToValueAtTime(deltaPeriod, time + rate);
  }
  
  bool get isOscillatorNoise => _oscType == WASfxr.NOISE || _oscType == WASfxr.NOISE_PINK || _oscType == WASfxr.NOISE_BROWNIAN;
  
  set OscillatorType(String type) {
    _oscType = type;
    
    if (isOscillatorNoise) {
      _noiseEnabled = true;
      _genNoiseBuffer(_oscType);
    }
    else {
      _removeNoise();
      _osc.type = _oscType;
    }
  }
  String get OscillatorType => _oscType;
  
  void _removeNoise() {
    if (_noiseSrc != null) {
      _noiseSrc.stop();
      _noiseSrc.disconnect(0);
      _noiseSrc = null;
      _noise = null;
      _noiseEnabled = false;
    }
  }
  
  void _genNoiseBuffer(String type) {
    // First dismantle any previous noise
    _removeNoise();
    
    // Create new noise
    int noiseBuffSize = math.pow(2, _bufferSize);
    
    _noise = _context.createBuffer(1, noiseBuffSize, _context.sampleRate);
    Float32List data = _noise.getChannelData(0);
    
    if (type == WASfxr.NOISE) {
      for (int i = 0; i < noiseBuffSize; i++) {
        data[i] = (SoundUtilities.randomDouble() * 2.0 - 1.0) * (1.0 + _noiseDistortion * _overdrive);
      }
    }
    else if (type == WASfxr.NOISE_PINK) {
      double b0, b1, b2, b3, b4, b5, b6;
      b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
      for (int i = 0; i < noiseBuffSize; i++) {
        double white = SoundUtilities.randomDouble() * 2.0 - 1.0;
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        data[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
        data[i] *= (0.1 + _pinkNoiseDistortion * _overdrive); // 0.1 -> 2.0 (roughly) compensate for gain
        b6 = white * 0.115926;
      }
    }
    else if (type == WASfxr.NOISE_BROWNIAN) {
      double lastOut = 0.0;
      for (int i = 0; i < noiseBuffSize; ++i) {
        double white = SoundUtilities.randomDouble() * 2.0 - 1.0;
        data[i] = (lastOut + (0.02 * white)) / 1.02;
        lastOut = data[i];
        data[i] *= (3.0 + _brownNoiseDistortion * _overdrive); // 3.0 -> 50.0 (roughly) compensate for gain
      }
    }
    
    _noiseSrc = _context.createBufferSource();
    _noiseSrc.buffer = _noise;
    _noiseSrc.loop = true;
    _noiseSrc.start();
    
    _noiseSrc.connectNode(_noiseAmp);
    _noiseSrc.playbackRate.value = _calcPlaybackRate();
    _noiseEnabled = true;
  }
  
  void configure(String type, double f) {
    OscillatorType = type;
    frequency = f;
  }
  
  set dutyCycle(double d) => _dutyCycle = d;
  double get dutyCycle => _dutyCycle;
  
  void resetDutyCycle() {
    _dutyCycle = 0.5;
  }
  
  void resetDutySweep() {
    dutySweep = 0.0;
  }
  
  set dutySweep(double d) => _deltaSweep = d;
  double get dutySweep => _deltaSweep;
  
  double get frequency => _frequency;
  set frequency(double f) => _frequency = f;

  bool get enableFrequency {
    return _oscEnabled;
  }
  
  set enableFrequency(bool b) {
    _oscEnabled = b;

    if (_oscEnabled && _oscDisconnected) {
      print("Connecting Oscillator");
      _oscDisconnected = false;
      _osc.connectNode(_inverter);
      _osc.connectNode(_mixer);
    }
    else if (!_oscEnabled && !_oscDisconnected) {
      print("Disconnecting Oscillator");
      _oscDisconnected = true;
      _osc.disconnect(0);
    }
  }

  double get NoisePlaybackRate => _playbackRate;
  set NoisePlaybackRate(double d) => _playbackRate = d;

  double _calcPlaybackRate() {
    double z = 0.0001 + 10.0 - _playbackRate;
    double rate = (1.0) / (z * z);
    return rate;
  }
  
  int get NoiseBufferSize => _bufferSize;
  set NoiseBufferSize(int i) => _bufferSize = i;

  double get NoiseVolume => _noiseVolume;
  set NoiseVolume(double d) => _noiseVolume = d;

  double get NoiseOverdrive => _overdrive;
  set NoiseOverdrive(double d) => _overdrive = d;
  
  void update(double now) {
    _osc.frequency.cancelScheduledValues(now);
    
    _osc.frequency.setValueAtTime(frequency, now);
    
    if (_dutyCycle == 1.0)
      _delay.delayTime.setValueAtTime(0.0, now);
    else
      _delay.delayTime.setValueAtTime(_dutyCycle/frequency, now);
    
    // Duty Sweep
    setDutySweep(_deltaSweep, now);
    
    if (_prevSignalGain != signalGain)
      _mixer.gain.value = signalGain;

    if (_noiseVolume != _prevNoiseVolume)
      _noiseAmp.gain.value = _noiseVolume;

    if (_noiseSrc != null) {
      if (_playbackRate != _prevPlaybackRate) {
        _noiseSrc.playbackRate.value = _calcPlaybackRate();
      }
    }

    if ((_bufferSize != _prevBufferSize || _overdrive != _prevOverdrive) && _noiseEnabled) {
      _genNoiseBuffer(_oscType);
    }
    
    if (distortion.enabled)
      distortion.update();
    
    // Optional
    //_dcGain.gain.value = 1.7 * (0.5 - _dutyCycle);
    
    _prevOverdrive = _overdrive;
    _prevBufferSize = _bufferSize;
    _prevPlaybackRate = _playbackRate;
    _prevNoiseVolume = _noiseVolume;
    _prevSignalGain = signalGain;
  }
  
  void start([double when = 0.0]) {
    _osc.start(when);
  }

  void stop([double when = 0.0]) {
    _osc.stop(when);
  }
  
  void connectDistortion() {
    _mixer.connectNode(distortion.input);
    
    configureOutput();
  }
  
  // This is optional. It can have a slight effect.
  void _createDCOffset() {
//    _dcOffsetBuffer = _context.createBuffer(1, 1024, _context.sampleRate);
//    Float32List data = _dcOffsetBuffer.getChannelData(0);
//    for (int i = 0; i < data.length; i++)
//      data[i] = -1.0;
//    _dcOffsetNode = _context.createBufferSource();
//    _dcOffsetNode.buffer = _dcOffsetBuffer;
//    _dcOffsetNode.loop = true;
//
//    _dcGain = _context.createGain();
//    _dcOffsetNode.connectNode(_dcGain);
  }
  
  /*
   * function RingGen(frequency) {
        var self = this,
            bufferSize = 1024,
            x = 0, // initial sample number
            node = context.createJavaScriptNode(bufferSize, 1, 1);

        node.onaudioprocess = function(e) {
            var out = e.outputBuffer.getChannelData(0);

            for (var i = 0; i < bufferSize; ++i) {
                var value = square(x * Math.PI * 2.0) * triangle(x * Math.PI * 2.0);
                x += frequency / context.sampleRate;
                out[i] = value;
            }
        }

        return node;
    }
   */
}