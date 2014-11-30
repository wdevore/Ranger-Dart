part of ranger;

/*
 * Libraries researched:
 * https://github.com/pstoica/web-audio-synth
 */
class WASfxr {
  static const String SQUARE = "square";
  static const String SAWTOOTH = "sawtooth";
  static const String SINE = "sine";
  static const String TRIANGLE = "triangle";
  static const String NOISE = "noise";  // White
  static const String NOISE_PINK = "pink";  // Pink
  static const String NOISE_BROWNIAN = "brown";  // Brownian/Red
  
  static const String PICKUP_COIN = "PickupCoin";
  static const String LASER_SHOOT = "LaserShoot";
  static const String EXPLOSION = "Explosion";
  static const String POWERUP = "PowerUp";
  static const String HIT_HURT = "HitHurt";
  static const String JUMP = "Jump";
  static const String BLIP_SELECT = "BlipSelect";
  static const String ALIEN_SHIPS = "AlienShips";
  static const String HIGH_ALARMS = "HighAlarms";
  static const String LOW_ALARMS = "LowAlarms";
  static const String RANDOM = "Random";
  static const String TONE = "Tone";
  static const String MUTATE = "Mutate";

  static const double DEFAULT_GAIN = 0.5;
  
  AudioContext _context;
  
  WAGenerator generator;
  WAEnvelope envelope;
  WAVibrato vibrato;
  
  WATremolo tremolo;
  bool _tremoloConnected = false;
  
  WAFrequencySlider freq;
  WAArpeggio arpeggio;
  WALowPassFilter lowPass;
  WAHighPassFilter highPass;
  WAFlangerFilter flanger;
  bool _flangerConnected = false;
//  WABitCrusher _crusher;
  
//  DynamicsCompressorNode _compressor;
  
  int retriggerCount = 1;
  int retriggerCountDown = 0;
  double retriggerRate = 0.1;
  
//  WAPhaserFilter phaser;
  
//  double _frequency = 340.0;
  
  GainNode _masterGain;
  DelayNode channelDelay;
  
  String category;
  String name = "";
  
  bool _buffered = false;
  
  bool enabled = false;
  
  WASfxr();
  
  factory WASfxr.basic(AudioContext ac) {
    WASfxr e = new WASfxr();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  factory WASfxr.withJSON(Map m, AudioContext ac) {
    WASfxr e = new WASfxr();
    if (e.init(ac)) {
      e.configureWithJSON(m);
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    generator = new WAGenerator.basic(_context);
    generator.configure("sine", frequency);
    
    envelope = new WAEnvelope.basic(_context);
    envelope.setSustain(1.0, 1.0); // Default
    
    freq = new WAFrequencySlider.basic(_context);
    freq.whatToControl = generator;
    
    arpeggio = new WAArpeggio.basic(_context);
    arpeggio.whatToControl = generator;
    
    generator.start();

    _masterGain = _context.createGain();
    gain = 0.5;

    channelDelay = _context.createDelay();
    
//    _crusher = new WABitCrusher.basic(_context);
    
    // There isn't enough frequency gap to really need this.
//    _compressor = _context.createDynamicsCompressor();
    
    //---------------------------------------------------------------
    // Connect the nodes together
    //---------------------------------------------------------------
    _connect();
    
    return true;
  }

  void _connect() {
    // Distortion
    generator.output.connectNode(envelope.input);

    envelope.output.connectNode(_masterGain);

    _masterGain.connectNode(channelDelay);

//    envelope.output.connectNode(_crusher.input);
//    _crusher.output.connectNode(_masterGain);
  }
  
  double get frequency => generator.frequency;
  set frequency(double f) => generator.frequency = f;

  double get gain => _masterGain.gain.value;
  set gain(double g) => _masterGain.gain.value = g;
  
  AudioNode get output => channelDelay;
  
  // -------------------------------------------------------------
  // Vibrato
  // -------------------------------------------------------------
  set vibratoStrength(double s) {
    if (vibrato != null)
      vibrato.strength = s;
  }
  double get vibratoStrength {
    if (vibrato != null)
      return vibrato.strength;
    else
      return 0.0;
  }
  
  set vibratoFrequency(double f) {
    if (vibrato != null)
      vibrato.frequency = f;
  }
  double get vibratoFrequency {
    if (vibrato != null)
      return vibrato.frequency;
    else
      return 0.0;
  }

  bool get vibratoEnabled => vibrato != null;
  
  bool toggleVibrato() {
    if (vibrato == null) {
      connectVibrato(true);
      return true;
    }
    else {
      // Disconnect
      connectVibrato(false);
      return false;
    }
  }

  void connectVibrato(bool connect) {
    if (connect && vibrato == null) {
      vibrato = new WAVibrato.basic(_context);
      // TODO add radio buttons to change type.
      vibrato.configure(WASfxr.SINE, 8.0, 20.0);
      vibrato.start();
      vibrato.enabled = true;
      print("Connecting Vibrato");
      vibrato.output.connectParam(generator.frequencyParam);
    }
    else if (!connect && vibrato != null) {
      print("Disconnecting Vibrato");
      vibrato.output.disconnect(0);
      vibrato = null;
    }
  }

  // -------------------------------------------------------------
  // Tremolo
  // -------------------------------------------------------------
  set tremoloStrength(double s) {
    if (tremolo != null)
      tremolo.strength = s;
  }
  double get tremoloStrength {
    if (tremolo != null)
      return tremolo.strength;
    else
      return 0.0;
  }
  
  set tremoloFrequency(double f) {
    if (tremolo != null)
      tremolo.frequency = f;
  }
  double get tremoloFrequency {
    if (tremolo != null)
      return tremolo.frequency;
    else
      return 0.0;
  }

  bool get tremoloEnabled => tremolo != null;

  bool toggleTremolo() {
    _connectTremolo(tremolo == null);
    return tremolo != null;
  }
  
  void disableTremolo() {
    _connectTremolo(false);
  }
  
  void enableTremolo() {
    _connectTremolo(true);
  }

  void _connectTremolo(bool connect) {
    if (connect && !_tremoloConnected) {
      tremolo = new WATremolo.basic(_context);
      // TODO add radio buttons to change type.
      tremolo.configure(WASfxr.SQUARE, 8.0, 1.0); // Typically 8Hz
      tremolo.start();

      // Connect Tremolo
      print("--Connecting Tremolo");
      _tremoloConnected = true;
      
      envelope.output.disconnect(0);
      
      print("  Connecting envelope to tremolo");
      envelope.output.connectNode(tremolo.input);
      print("  Connecting tremolo to masterGain");
      tremolo.output.connectNode(_masterGain);
      tremolo.enabled = true;
    }
    else if (!connect && _tremoloConnected) {
      // Disconnect Tremolo
      print("--Disconnecting Tremolo");
      _tremoloConnected = false;

      tremolo.output.disconnect(0);
      print("  Disconnecting envelope");
      envelope.output.disconnect(0);
      
      print("  Connecting envelope to masterGain");
      envelope.output.connectNode(_masterGain);
      
      tremolo = null;
    }
  }

  // -------------------------------------------------------------
  // Frequency
  // -------------------------------------------------------------
  set slideFrequency(double f) => freq.frequencySlide = f;
  double get slideFrequency => freq.frequencySlide;
  
  set slideTime(double f) => freq.frequencyTime = f;
  double get slideTime => freq.frequencyTime;
  
  set slideCutoff(double f) => freq.frequencyCutoff = f;
  double get slideCutoff => freq.frequencyCutoff;
  
  set frequencyGain(double s) => generator.signalGain = s;
  double get frequencyGain => generator.signalGain;
  
  // -------------------------------------------------------------
  // Arpeggio
  // 1) A start freq with up steps
  // 2) A start freq with down steps
  // 3) A center freq with up/down toggle
  // -------------------------------------------------------------
  set arpefrequencyStep(double f) => arpeggio.stepSize = f;
  double get arpefrequencyStep => arpeggio.stepSize;

  set arpeTimeStep(double f) => arpeggio.timeStep = f;
  double get arpeTimeStep => arpeggio.timeStep;

  set arpeExpoDecay(double f) => arpeggio.expoDecay = f;
  double get arpeExpoDecay => arpeggio.expoDecay;

  set arpeNotes(int n) => arpeggio.notes = n;
  int get arpeNotes => arpeggio.notes;

  set arpeStepType(int i) => arpeggio.stepType = i;
  int get arpeStepType => arpeggio.stepType;

  // -------------------------------------------------------------
  // Duty cycle
  // -------------------------------------------------------------
  set dutyCycle(double percent) => generator.dutyCycle = percent;
  double get dutyCycle => generator.dutyCycle;

  set dutySweep(double percent) => generator.dutySweep = percent;
  double get dutySweep => generator.dutySweep;

  // -------------------------------------------------------------
  // Low pass
  // -------------------------------------------------------------
  bool toggleLowPass() {
    if (lowPass == null) {
      connectLowPass(true);
      return true;
    }
    else {
      connectLowPass(!lowPass.enabled);
      return false;
    }
  }

  bool get lowPassEnabled {
    if (lowPass == null)
      return false;
    else
      return lowPass.enabled;
  }
  
  void connectLowPass(bool connect) {
    // To connect lowPass we need to "look" backward and forwards.
    // We look backwards until we reach the Generator and we look
    // forward until we reach the Envelope.
    if (connect && lowPass == null) {
      // lowPass isn't connected to anything. So we splice it in.
      print("--Connecting lowPass");
      if (lowPass == null)
        lowPass = new WALowPassFilter.basic(_context);

      lowPass.enabled = true;

      // Backward will be either the Flanger or Generator.
      if (flanger != null) {
        // Disconnect from whatever it is currently connected to.
        print("  Redirecting Flanger to lowPass");
        flanger.output.disconnect(0);
        flanger.output.connectNode(lowPass.input);
      }
      else {
        print("  Redirecting Generator to lowPass");
        generator.output.disconnect(0);
        generator.output.connectNode(lowPass.input);
      }
      
      // Forward will be either highPass or Envelope
      if (highPass != null) {
        print("  Connecting lowPass to highPass");
        lowPass.output.connectNode(highPass.input);
      }
      else {
        print("  Connecting lowPass to envelope");
        lowPass.output.connectNode(envelope.input);
      }
    }
    else if (!connect && lowPass != null) {
      print("--Disconnecting lowPass");
      lowPass.enabled = false;
      lowPass.output.disconnect(0);

      lowPass = null;
      
      // If the Flanger is connected we want to redirect its output forward.
      // We either connect it to highPass or Envelope
      if (flanger != null) {
        print("  Disconnecting flanger");
        flanger.output.disconnect(0);
        if (highPass != null) {
          print("  Connecting flanger to highPass");
          flanger.output.connectNode(highPass.input);
        }
        else {
          print("  Connecting flanger to envelope");
          flanger.output.connectNode(envelope.input);
        }
      }
      else {
        // The Flanger is disconnected so redirect the Generator output.
        print("  Disconnecting generator");
        generator.output.disconnect(0);
        if (highPass != null) {
          print("  Connecting generator to highPass");
          generator.output.connectNode(highPass.input);
        }
        else {
          print("  Connecting generator to envelope");
          generator.output.connectNode(envelope.input);
        }
      }
    }
  }
  
  set lowPassFrequency(double percent) {
    if (lowPass != null)
      lowPass.frequencyCutoff = percent;
  }
  double get lowPassFrequency {
    if (lowPass != null)
      return lowPass.frequencyCutoff;
    return 0.0;
  }

  set lowPassSweep(double df) {
    if (lowPass != null)
      lowPass.cutoffSweep = df;
  }
  double get lowPassSweep {
    if (lowPass != null)
      return lowPass.cutoffSweep;
    return 0.0;
  }

  set lowPassResonance(double q) {
    if (lowPass != null)
      lowPass.qResonance = q;
  }
  double get lowPassResonance {
    if (lowPass != null)
      return lowPass.qResonance;
    return 0.0;
  }

  // -------------------------------------------------------------
  // High pass
  // -------------------------------------------------------------
  bool toggleHighPass() {
    if (highPass == null) {
      connectHighPass(true);
      return true;
    }
    else {
      connectHighPass(false);
      return false;
    }
  }

  bool get highPassEnabled {
    if (highPass != null)
      return highPass.enabled;
    else
      return false;
  }

  void connectHighPass(bool connect) {
    // To connect highPass we need to "look" backward and forwards.
    // We look backwards until we reach the Generator and we look
    // forward until we reach the Envelope.
    if (connect && highPass == null) {
      highPass = new WAHighPassFilter.basic(_context);
      highPass.enabled = true;
      print("--Connecting highPass");
      
      if (lowPass != null) {
        print("  Disconnecting lowPass");
        // Disconnect lowPass from whatever it is currently connected.
        lowPass.output.disconnect(0);
        // And reconnect it to highPass
        print("  Connecting lowPass to highPass");
        lowPass.output.connectNode(highPass.input);
      }
      else {
        // Continue to check backwards.
        if (flanger != null) {
          print("  Disconnecting flanger");
          flanger.output.disconnect(0);
          print("  Connecting flanger to highPass");
          flanger.output.connectNode(highPass.input);
        }
        else {
          // Neither lowPass or Flanger are connected. So Generator needs
          // to be disconnected.
          print("  Disconnecting generator");
          generator.output.disconnect(0);
          print("  Connecting generator to highPass");
          generator.output.connectNode(highPass.input);
        }
      }
      
      // Now connect highPass forward.
      print("  Connecting highPass to envelope");
      highPass.output.connectNode(envelope.input);
    }
    else if (!connect && highPass != null) {
      // Disconnect highPass then route anything backward to envelope
      print("--Disconnecting highPass");
      highPass.enabled = false;
      highPass.output.disconnect(0);

      highPass = null;

      if (lowPass != null) {
        print("  Redirecting lowPass to envelope");
        lowPass.output.disconnect(0);
        lowPass.output.connectNode(envelope.input);
      }
      else {
        if (flanger != null) {
          print("  Redirecting flanger to envelope");
          flanger.output.disconnect(0);
          flanger.output.connectNode(envelope.input);
        }
        else {
          print("  Redirecting generator to envelope");
          generator.output.disconnect(0);
          generator.output.connectNode(envelope.input);
        }
      }
    }
  }

  set highPassFrequency(double percent) {
    if (highPass != null)
      highPass.frequencyCutoff = percent;
  }
  double get highPassFrequency {
    if (highPass != null)
      return highPass.frequencyCutoff;
    else
      return 0.0;
  }

  set highPassSweep(double df) {
    if (highPass != null)
      highPass.cutoffSweep = df;
  }
  double get highPassSweep {
    if (highPass != null)
      return highPass.cutoffSweep;
    else
      return 0.0;
  }

  set highPassResonance(double q) {
    if (highPass != null)
      highPass.qResonance = q;
  }
  
  double get highPassResonance {
    if (highPass != null)
      return highPass.qResonance;
    else
      return 0.0;
  }

  // -------------------------------------------------------------
  // Flanger
  // -------------------------------------------------------------
  set FlangerFrequency(double f) {
    if (flanger != null)
      flanger.Frequency = f;
  }
  double get FlangerFrequency {
    if (flanger != null)
      return flanger.Frequency;
    else
      return 0.0;
  }

  set FlangerDelayScaler(double s) {
    if (flanger != null)
      flanger.DelayScaler = s;
  }
  double get FlangerDelayScaler {
    if (flanger != null)
      return flanger.DelayScaler;
    else
      return 0.0;
  }

  set FlangerFeedback(double f) {
    if (flanger != null)
      flanger.Feedback = f;
  }
  double get FlangerFeedback {
    if (flanger != null)
      return flanger.Feedback;
    else
      return 0.0;
  }

  set FlangerFeedbackSweep(double d) {
    if (flanger != null)
      flanger.FeedbackSweep = d;
  }
  double get FlangerFeedbackSweep {
    if (flanger != null)
      return flanger.FeedbackSweep;
    else
      return 0.0;
  }

  set FlangerBaseDelay(double d) {
    if (flanger != null)
      flanger.BaseDelay = d;
  }
  double get FlangerBaseDelay {
    if (flanger != null)
      return flanger.BaseDelay;
    else
      return 0.0;
  }

  bool toggleFlanger() {
    if (_flangerConnected)
      disconnectFlanger();
    else
      connectFlanger();
    
    return _flangerConnected;
  }
  
  bool get flangerEnabled => _flangerConnected;

  void enableFlanger() {
    connectFlanger();
  }
  
  void disableFlanger() {
    disconnectFlanger();
  }
  
  void connectFlanger() {
    // Disconnect generator from lowpass
    print("--Connecting flanger");
    print("  Disconnecting generator");
    generator.output.disconnect(0);

    if (flanger == null)
      flanger = new WAFlangerFilter.basic(_context);

    flanger.enabled = true;

    print("  Connecting generator to flanger");
    generator.output.connectNode(flanger.input);
    
    if (lowPass != null) {
      print("  Connecting flanger to lowPass");
      flanger.output.connectNode(lowPass.input);
    }
    else {
      if (highPass != null) {
        print("  Connecting flanger to highPass");
        flanger.output.connectNode(highPass.input);
      }
      else {
        print("  Connecting flanger to envelope");
        flanger.output.connectNode(envelope.input);
      }
    }

    _flangerConnected = true;
  }
  
  void disconnectFlanger() {
    print("--Disconnecting flanger");
    flanger.output.disconnect(0);
    
    flanger = null;
    
    print("  Disconnecting generator");
    generator.output.disconnect(0);
    
    if (lowPass != null) {
      print("  Connecting to lowPass");
      generator.output.connectNode(lowPass.input);
    }
    else {
      if (highPass != null) {
        print("  Connecting to highPass");
        generator.output.connectNode(highPass.input);
      }
      else { 
        print("  Connecting to envelope");
        generator.output.connectNode(envelope.input);
      }
    }
    
    _flangerConnected = false;
  }
  
  // -------------------------------------------------------------
  // Distortion
  // -------------------------------------------------------------
  set DistortionEnabled(bool d) => generator.distortion.enabled = d;
  bool get DistortionEnabled => generator.distortion.enabled;
  
  set DistortionScale(double d) => generator.distortion.scale = d;
  double get DistortionScale => generator.distortion.scale;

  set DistortionParts(int d) => generator.distortion.sumParts = d;
  int get DistortionParts => generator.distortion.sumParts;

  set DistortionMag1(double d) => generator.distortion.mag1 = d;
  double get DistortionMag1 => generator.distortion.mag1;

  set DistortionMag2(double d) => generator.distortion.mag2 = d;
  double get DistortionMag2 => generator.distortion.mag2;

  set DistortionMag3(double d) => generator.distortion.mag3 = d;
  double get DistortionMag3 => generator.distortion.mag3;

  set DistortionEquation(int d) => generator.distortion.equation = d;
  int get DistortionEquation => generator.distortion.equation;

  set DistortionClamp(double d) => generator.distortion.clamp = d;
  double get DistortionClamp => generator.distortion.clamp;

  bool toggleDistortion() {
    connectDistortion(!generator.distortion.enabled);
    return generator.distortion.enabled;
  }

  void connectDistortion(bool connect) {
    if (connect && !generator.distortion.enabled) {
      generator.distortion.enabled = true;
      print("--Connecting Distortion");
      print("  Disconnecting generator");
      generator.output.disconnect(0);
      
      generator.connectDistortion();
      _connectGeneratorOutput();
    }
    else if (!connect && generator.distortion.enabled) {
      print("--Disconnecting Distortion");
      generator.distortion.enabled = false;
      print("  Disconnecting generator");
      generator.disconnectOutput();
      
      generator.configureOutput();
      
      _connectGeneratorOutput();
    }
  }
  
  void _connectGeneratorOutput() {
    if (lowPass != null) {
      print("  Connecting generator to lowPass");
      generator.output.connectNode(lowPass.input);
    }
    else {
      if (highPass != null) {
        print("  Connecting generator to highPass");
        generator.output.connectNode(highPass.input);
      }
      else {
        print("  Connecting generator to envelope");
        generator.output.connectNode(envelope.input);
      }
    }
  }
  // -------------------------------------------------------------
  // Noise
  // -------------------------------------------------------------
  set NoisePlaybackRate(double d) => generator.NoisePlaybackRate = d;
  double get NoisePlaybackRate => generator.NoisePlaybackRate;

  set NoiseBufferSize(int i) => generator.NoiseBufferSize = i;
  int get NoiseBufferSize => generator.NoiseBufferSize;

  set NoiseVolume(double d) => generator.NoiseVolume = d;
  double get NoiseVolume => generator.NoiseVolume;

  set NoiseOverdrive(double d) => generator.NoiseOverdrive = d;
  double get NoiseOverdrive => generator.NoiseOverdrive;
  
  // -------------------------------------------------------------
  // Oscillator type
  // -------------------------------------------------------------
  bool toggleFrequency() {
    generator.enableFrequency = !generator.enableFrequency;
    return generator.enableFrequency;
  }
  
  void disableFrequency() {
    generator.enableFrequency = false;
  }
  
  void enableFrequency() {
    generator.enableFrequency = true;
  }
  
  bool get frequencyEnabled => generator.enableFrequency;
  
  set OscillatorType(String type) => generator.OscillatorType = type; 
  String get OscillatorType => generator.OscillatorType;
  
  set Buffered(bool b) => _buffered = b;
  bool get Buffered => _buffered;
  
  // -------------------------------------------------------------
  // Resets
  // -------------------------------------------------------------
  void resetDutyCycle() {
    generator.resetDutyCycle();
  }

  void resetDutySweep() {
    generator.resetDutySweep();
  }

  void resetFreqSlide() {
    freq.resetFreqSlide();
  }

  // -------------------------------------------------------------
  // Known sets
  // -------------------------------------------------------------
  void genAsteroidShooter() {
    reset();

    enableFrequency();

    // 0.356
    envelope.sustain[WAEnvelope.TIME] = 0.516;
    // 921.497
    frequency = 1043.478;
    
    // -0.355
    slideFrequency = -0.410;
    // 0.265
    slideTime = 0.457;

    // 57.62
    dutyCycle = 0.337;
    OscillatorType = WASfxr.SAWTOOTH;
  }

  // -------------------------------------------------------------
  // Random sets
  // -------------------------------------------------------------
  void genPickupCoin() {
    reset();

    enableFrequency();
    disableTremolo();
    connectVibrato(false);
    connectHighPass(false);
    connectLowPass(false);
    
    // Mostly around 587 - 1111 - 1200 Hz
    double baseFreq = 587.0 + (SoundUtilities.randomDouble() * 613.0);
    frequency = baseFreq;
    
    // Arpeggio of 1 or 2 note steps.
    arpeNotes = SoundUtilities.randomDouble() > 0.5 ? 1 : 2;
    
    // 50% square wave
    OscillatorType = WASfxr.SQUARE;
  }
  
  void genLaserShoot() {
    reset();

    disableTremolo();
    connectVibrato(false);
    connectHighPass(false);
    connectLowPass(false);

    enableFrequency();

    envelope.sustain[WAEnvelope.TIME] = (0.516 - 0.2) + (SoundUtilities.randomDouble() * (0.516 + 0.2));
    frequency = (1043.478 - 200.0) + (SoundUtilities.randomDouble() * (1043.478 + 200.0));
    
    slideFrequency = (-0.410 - 0.3) + (SoundUtilities.randomDouble() * (-0.410 + 3.0));
    
    slideTime = (0.457 - 0.4) + (SoundUtilities.randomDouble() * (0.457 + 0.4));

    dutyCycle = (0.337 - 0.2) + (SoundUtilities.randomDouble() * (0.337 + 0.2));
    OscillatorType = WASfxr.SAWTOOTH;
    
    // TODO add random for lowpass
  }
  
  void genExplosion() {
    reset();
    // Envelope decay
    // 0.424
    envelope.decay[WAEnvelope.TIME] = (0.543 - 0.2) + (SoundUtilities.randomDouble() * (0.543 + 0.2));

    OscillatorType = WASfxr.NOISE;

    disableTremolo();
    connectDistortion(false);
    disableFrequency();
    connectHighPass(false);
    connectLowPass(true);

    // 5.028
    NoisePlaybackRate = (2.609 - 2.0) + (SoundUtilities.randomDouble() * (2.609 + 3.0));
    
    // 1
    retriggerCount = ((1) + (SoundUtilities.randomDouble() * (2))).floor();
    
    // 403.022
    lowPassFrequency = (543.480 - 300.0) + (SoundUtilities.randomDouble() * (543.480 + 300.0));
    // 512.307
    lowPassSweep = (392.910 - 100.0) + (SoundUtilities.randomDouble() * (392.910 + 100.0));
    // 14.13
    lowPassResonance = (7.07 - 3.0) + (SoundUtilities.randomDouble() * (7.07 + 3.0));
  }
  
  void genPowerUp() {
    reset();
    OscillatorType = WASfxr.SAWTOOTH;
    disableTremolo();
    connectVibrato(false);
    enableFrequency();
    connectHighPass(false);
    connectLowPass(false);
    frequency = (585.217 - 100.0) + (SoundUtilities.randomDouble() * (585.217 + 500.0));
    slideFrequency = (0.2 - 0.2) + (SoundUtilities.randomDouble() * (0.2 + 0.2));
    
    slideTime = (0.462 - 0.3) + (SoundUtilities.randomDouble() * (0.462 + 0.3));
  }
  
  void genHitHurt() {
    reset();
    OscillatorType = WASfxr.SAWTOOTH;
    enableFrequency();
    disableTremolo();
    connectVibrato(false);
    connectHighPass(false);
    connectLowPass(true);

    envelope.decay[WAEnvelope.TIME] = (0.109 - 0.05) + (SoundUtilities.randomDouble() * (0.109 + 0.1));
    envelope.sustain[WAEnvelope.TIME] = (0.109 - 0.05) + (SoundUtilities.randomDouble() * (0.109 + 0.1));

    frequency = (782.609 - 200.0) + (SoundUtilities.randomDouble() * (782.609 + 200.0));
    slideFrequency = (-0.860 - 0.2) + (SoundUtilities.randomDouble() * (-0.860 + 0.2));
    
    slideTime = (0.152 - 0.1) + (SoundUtilities.randomDouble() * (0.152 + 0.1));

    lowPassFrequency = (18342.390 - 1000.0) + (SoundUtilities.randomDouble() * (18342.390 + 100.0));
    lowPassSweep = (66.150 - 50.0) + (SoundUtilities.randomDouble() * (66.150 + 50.0));
    lowPassResonance = (9.24 - 5.0) + (SoundUtilities.randomDouble() * (9.24 + 5.0));
  }
  
  void genJump() {
    reset();
    OscillatorType = WASfxr.SQUARE;
    disableTremolo();
    connectVibrato(false);
    enableFrequency();
    connectHighPass(false);
    connectLowPass(true);

    dutyCycle = (0.707 - 0.5) + (SoundUtilities.randomDouble() * (0.707 + 0.5));

    envelope.sustain[WAEnvelope.TIME] = (0.326 - 0.2) + (SoundUtilities.randomDouble() * (0.326 + 0.2));
    envelope.release[WAEnvelope.TIME] = (0.109 - 0.05) + (SoundUtilities.randomDouble() * (0.109 + 0.05));

    frequency = (543.478 - 200.0) + (SoundUtilities.randomDouble() * (543.478 + 200.0));
    slideFrequency = (0.01 - 0.005) + (SoundUtilities.randomDouble() * (0.01 + 0.005));
    slideTime = (0.190 - 0.1) + (SoundUtilities.randomDouble() * (0.190 + 0.1));

    lowPassFrequency = (5978.260 - 2000.0) + (SoundUtilities.randomDouble() * (5978.260 + 2000.0));
    lowPassSweep = (93.300 - 50.0) + (SoundUtilities.randomDouble() * (93.300 + 50.0));
    lowPassResonance = (5.43 - 3.0) + (SoundUtilities.randomDouble() * (5.43 + 3.0));
  }
  
  void genBlipSelect() {
    reset();
    OscillatorType = WASfxr.SQUARE;
    enableFrequency();
    disableTremolo();
    connectVibrato(false);
    connectHighPass(false);
    connectLowPass(true);

    envelope.decay[WAEnvelope.TIME] = (0.109 - 0.05) + (SoundUtilities.randomDouble() * (0.109 + 0.1));
    envelope.sustain[WAEnvelope.TIME] = (0.109 - 0.05) + (SoundUtilities.randomDouble() * (0.109 + 0.1));

    frequency = (543.609 - 200.0) + (SoundUtilities.randomDouble() * (543.609 + 200.0));

    lowPassFrequency = (4347.390 - 2000.0) + (SoundUtilities.randomDouble() * (4347.390 + 2000.0));
    lowPassSweep = (60.0 - 30.0) + (SoundUtilities.randomDouble() * (60.0 + 30.0));
    lowPassResonance = (12.24 - 10.0) + (SoundUtilities.randomDouble() * (12.24 + 10.0));
  }
  
  void genAlienShips() {
    reset();
    
    enableFrequency();
    double n =  SoundUtilities.randomDouble();
    if (n < 0.25)
      OscillatorType = WASfxr.SINE;
    else if (n < 0.5)
      OscillatorType = WASfxr.SQUARE;
    else if (n < 0.75)
      OscillatorType = WASfxr.SAWTOOTH;
    else
      OscillatorType = WASfxr.TRIANGLE;

    frequency = SoundUtilities.rndr(300.0, 850.0);

    envelope.decay[WAEnvelope.TIME] = (0.209 - 0.05) + (SoundUtilities.randomDouble() * (0.409 + 0.1));
    envelope.sustain[WAEnvelope.TIME] = (0.209 - 0.05) + (SoundUtilities.randomDouble() * (0.409 + 0.1));

    arpeNotes = SoundUtilities.rndr(0.0, 1.0).floor();

    connectHighPass(true);
    connectLowPass(false);

    // hipass freq 0 - 1500, sweep 1000, 0 res
    if (SoundUtilities.randomDouble() > 0.7)
      highPassFrequency = SoundUtilities.rndr(0.0, 1500.0);
    highPassSweep = SoundUtilities.rndr(100.0, 1000.0);

    if (SoundUtilities.yes) {
      connectVibrato(true);
      vibratoStrength = SoundUtilities.rndr(7.0, 14.0);
      vibratoFrequency = SoundUtilities.rndr(8.0, 20.0);
    }
    else {
      connectVibrato(false);
    }
    
    if (SoundUtilities.yes) {
      toggleTremolo();
      if (tremolo != null) {
        tremoloStrength = SoundUtilities.rndr(2.0, 3.0);
        tremoloFrequency = SoundUtilities.rndr(8.0, 20.0);
      }
    }
  }
  
  void genHighAlarms() {
    reset();
    
    enableFrequency();
    connectHighPass(false);
    connectLowPass(false);
    double n =  SoundUtilities.randomDouble();
    if (n < 0.25)
      OscillatorType = WASfxr.SINE;
    else if (n < 0.5)
      OscillatorType = WASfxr.SQUARE;
    else if (n < 0.75)
      OscillatorType = WASfxr.SAWTOOTH;
    else
      OscillatorType = WASfxr.TRIANGLE;

    frequency = SoundUtilities.rndr(1300.0, 2500.0);
    
    connectVibrato(false);

    enableTremolo();
    tremoloStrength = SoundUtilities.rndr(0.1, 2.0);
    tremoloFrequency = SoundUtilities.rndr(8.0, 200.0);

    arpeNotes = SoundUtilities.rndr(0.0, 10.0).floor();
    arpeStepType = SoundUtilities.rndr(1.0, 3.0).floor();
    
    retriggerCount = SoundUtilities.rndr(2.0, 4.0).floor();
    retriggerRate = SoundUtilities.rndr(0.1, 0.15);
  }
  
  void genLowAlarms() {
    reset();
    
    enableFrequency();
    double n =  SoundUtilities.randomDouble();
    if (n < 0.25)
      OscillatorType = WASfxr.SINE;
    else if (n < 0.5)
      OscillatorType = WASfxr.SQUARE;
    else if (n < 0.75)
      OscillatorType = WASfxr.SAWTOOTH;
    else
      OscillatorType = WASfxr.TRIANGLE;

    frequency = SoundUtilities.rndr(200.0, 500.0);
    
    connectVibrato(false);
    connectHighPass(false);
    connectLowPass(true);

    enableTremolo();
    tremoloStrength = SoundUtilities.rndr(0.1, 2.0);
    tremoloFrequency = SoundUtilities.rndr(8.0, 100.0);

    arpeNotes = SoundUtilities.rndr(0.0, 10.0).floor();
    arpeStepType = SoundUtilities.rndr(2.0, 3.0).floor();
    
    retriggerCount = SoundUtilities.rndr(2.0, 4.0).floor();
    retriggerRate = SoundUtilities.rndr(0.1, 0.15);
    
    lowPassFrequency = (400.0 - 100.0) + (SoundUtilities.randomDouble() * (9000.0 + 100.0));
    lowPassSweep = (60.0 - 30.0) + (SoundUtilities.randomDouble() * (400.0 + 30.0));
    lowPassResonance = (4.0) + (SoundUtilities.randomDouble() * (9.0));
  }
  
  void genRandom() {
    reset();
    
    // Noise or Wave
    bool noise = SoundUtilities.yes;
    if (noise) {
      double n =  SoundUtilities.randomDouble();
      if (n < 0.33) {
        OscillatorType = WASfxr.NOISE;
        NoiseOverdrive = SoundUtilities.rndr(0.1, 0.5);
      }
      else if (n < 0.66) {
        OscillatorType = WASfxr.NOISE_PINK;
        NoiseOverdrive = SoundUtilities.rndr(0.3, 0.8);
      }
      else {
        OscillatorType = WASfxr.NOISE_BROWNIAN;
        NoiseOverdrive = SoundUtilities.rndr(0.3, 0.8);
      }

      NoisePlaybackRate = SoundUtilities.rndr(2.0, 4.0);
      
      if (SoundUtilities.yes)
        enableFrequency();
      else
        disableFrequency();
    }
    else {
      enableFrequency();
      double n =  SoundUtilities.randomDouble();
      if (n < 0.25)
        OscillatorType = WASfxr.SINE;
      else if (n < 0.5)
        OscillatorType = WASfxr.SQUARE;
      else if (n < 0.75)
        OscillatorType = WASfxr.SAWTOOTH;
      else
        OscillatorType = WASfxr.TRIANGLE;
    }
    
    // Envelope
    if (noise) {
      envelope.attack[WAEnvelope.TIME] = SoundUtilities.frnd(0.1);
      envelope.decay[WAEnvelope.TIME] = SoundUtilities.frnd(0.1);
      envelope.sustain[WAEnvelope.TIME] = SoundUtilities.frnd(0.1);
      envelope.release[WAEnvelope.TIME] = SoundUtilities.frnd(0.1);
    }
    else {
      frequency = SoundUtilities.rndr(50.0, 2000.0);
      envelope.attack[WAEnvelope.TIME] = SoundUtilities.randomDouble() * 5.0;
      envelope.decay[WAEnvelope.TIME] = SoundUtilities.randomDouble() * 5.0;
      envelope.sustain[WAEnvelope.TIME] = SoundUtilities.randomDouble() * 5.0;
      envelope.release[WAEnvelope.TIME] = SoundUtilities.randomDouble() * 5.0;

      // Vibrato
      if (SoundUtilities.yes) {
        if (vibratoEnabled) {
          vibratoStrength = SoundUtilities.rndr(2.0, 20.0);
          vibratoFrequency = SoundUtilities.rndr(2.0, 20.0);
          int wt = SoundUtilities.rnd(3.0);
          switch (wt) {
            case 0: vibrato.waveType = WASfxr.SINE; break;
            case 1: vibrato.waveType = WASfxr.SQUARE; break;
            case 2: vibrato.waveType = WASfxr.SAWTOOTH; break;
            case 3: vibrato.waveType = WASfxr.TRIANGLE; break;
          }
        }
      }
    }
    
    if (envelope.attack[WAEnvelope.TIME] + envelope.sustain[WAEnvelope.TIME] + envelope.decay[WAEnvelope.TIME] < 0.2) {
      envelope.sustain[WAEnvelope.TIME] += 0.2 + SoundUtilities.frnd(0.3);
      envelope.decay[WAEnvelope.TIME] += 0.2 + SoundUtilities.frnd(0.3);
    }
    
    if (SoundUtilities.yes) {
      toggleTremolo();
      if (tremolo != null) {
        tremoloStrength = SoundUtilities.rndr(2.0, 10.0);
        tremoloFrequency = SoundUtilities.rndr(8.0, 100.0);
        int wt = SoundUtilities.rnd(3.0);
        switch (wt) {
          case 0: tremolo.waveType = WASfxr.SINE; break;
          case 1: tremolo.waveType = WASfxr.SQUARE; break;
          case 2: tremolo.waveType = WASfxr.SAWTOOTH; break;
          case 3: tremolo.waveType = WASfxr.TRIANGLE; break;
        }
      }
    }
    
    // Arpeggiation
    if (SoundUtilities.yes) {
      arpefrequencyStep = SoundUtilities.rndr(20.0, 400.0);
      arpeTimeStep = SoundUtilities.rndr(0.0, 2.0);
      arpeExpoDecay = SoundUtilities.rndr(0.0, 2.0);
      arpeNotes = SoundUtilities.rndr(0.0, 5.0).floor();
      arpeStepType = SoundUtilities.rndr(0.0, 2.0).floor();
    }
    
    // Duty if square/saw
    if (OscillatorType == WASfxr.SQUARE || OscillatorType == WASfxr.SAWTOOTH) {
      if (SoundUtilities.yes) {
        dutyCycle = SoundUtilities.rndr(0.05, 0.95);
      }
      if (SoundUtilities.yes) {
        dutySweep = SoundUtilities.rndr(-1.0, 1.0);
      }
    }
    
    // Retrigger
    if (SoundUtilities.yes) {
      retriggerCount = SoundUtilities.rndr(1.0, 4.0).floor();
    }
    if (SoundUtilities.yes) {
      retriggerRate = SoundUtilities.rndr(0.0, 0.5);
    }
    
    // Flanger
    if (SoundUtilities.yes) {
      toggleFlanger();
      if (flanger != null) {
        FlangerFrequency = SoundUtilities.rndr(0.0, 100.0);
        FlangerDelayScaler = SoundUtilities.rndr(0.0, 2.0);
        FlangerFeedback = SoundUtilities.rndr(0.4, 1.0);
        FlangerFeedbackSweep = SoundUtilities.rndr(-1.0, 1.0);
        FlangerBaseDelay = SoundUtilities.rndr(0.0, 1.0);
      }
    }
    
    // lowpass
    if (SoundUtilities.yes) {
      if (SoundUtilities.randomDouble() > 0.7)
        lowPassFrequency = SoundUtilities.rndr(0.0, 25000.0);
      lowPassSweep = SoundUtilities.rndr(0.0, 1000.0);
      lowPassResonance = SoundUtilities.rndr(0.0, 25.0);
    }
    
    // highpass
    if (SoundUtilities.yes) {
      if (SoundUtilities.randomDouble() > 0.7)
        highPassFrequency = SoundUtilities.rndr(0.0, 10000.0);
      highPassSweep = SoundUtilities.rndr(0.0, 2000.0);
      highPassResonance = SoundUtilities.rndr(0.0, 50.0);
    }
    
    // Distortion
    if (SoundUtilities.yes) {
      if (OscillatorType == WASfxr.SINE || OscillatorType == WASfxr.SQUARE || OscillatorType == WASfxr.SAWTOOTH || OscillatorType == WASfxr.TRIANGLE) {
        connectDistortion(true);
        DistortionScale = SoundUtilities.rndr(0.0, 1.0);
        DistortionParts = SoundUtilities.rndr(0.0, 3.0).floor();
        DistortionMag1 = SoundUtilities.rndr(0.0, 1.0);
        DistortionMag2 = SoundUtilities.rndr(0.0, 1.0);
        DistortionMag3 = SoundUtilities.rndr(0.0, 1.0);
        DistortionEquation = SoundUtilities.rndr(0.0, 5.0).floor();
        DistortionClamp = SoundUtilities.rndr(0.0, 10.0);
      }
    }
    else {
      connectDistortion(false);
    }
  }
  
  void genTone() {
    reset();
    OscillatorType = WASfxr.SINE;
    enableFrequency();
    disableTremolo();
    connectVibrato(false);
    frequency = 340.0;
  }
  
  void mutate() {
    if (OscillatorType == WASfxr.NOISE || OscillatorType == WASfxr.NOISE_PINK || OscillatorType == WASfxr.NOISE_BROWNIAN) {
      NoiseOverdrive = mutateDouble(NoiseOverdrive, 0.05, 0.2, 0.0, 1.0);
      NoisePlaybackRate = mutateDouble(NoisePlaybackRate, 0.1, 0.2, 0.0, 10.0);
    }
    else {
      if (OscillatorType == WASfxr.SQUARE || OscillatorType == WASfxr.SAWTOOTH) {
        dutyCycle = mutateDouble(dutyCycle, 0.05, 0.1, 0.0, 1.0);
        dutySweep = mutateDouble(dutySweep, -0.2, 0.2, 0.0, 2.0);
      }
    }
    
    envelope.attack[WAEnvelope.TIME] = mutateDouble(envelope.attack[WAEnvelope.TIME], 0.1, 0.2, 0.0, 5.0);
    envelope.decay[WAEnvelope.TIME] = mutateDouble(envelope.decay[WAEnvelope.TIME], 0.1, 0.2, 0.0, 5.0);
    envelope.sustain[WAEnvelope.TIME] = mutateDouble(envelope.sustain[WAEnvelope.TIME], 0.1, 0.2, 0.0, 5.0);
    envelope.release[WAEnvelope.TIME] = mutateDouble(envelope.release[WAEnvelope.TIME], 0.1, 0.2, 0.0, 5.0);
    
    vibratoStrength = mutateDouble(vibratoStrength, 1.5, 2.2, 0.0, 200.0);
    vibratoFrequency = mutateDouble(vibratoFrequency, 1.5, 2.2, 0.0, 100.0);

    if (tremoloEnabled) {
      tremoloStrength = mutateDouble(tremoloStrength, 0.5, 1.2, 0.0, 20.0);
      tremoloFrequency = mutateDouble(tremoloFrequency, 1.5, 2.2, 0.0, 200.0);
    }
    
    if (arpeNotes > 0) {
      arpefrequencyStep = mutateDouble(arpefrequencyStep, 2.5, 5.2, 0.0, 1000.0);
      arpeTimeStep = mutateDouble(arpeTimeStep, 0.01, 0.02, 0.0, 2.0);
      arpeExpoDecay = mutateDouble(arpeExpoDecay, 0.01, 0.02, 0.0, 2.0);
    }
    
    retriggerCount = mutateDouble(retriggerCount.toDouble(), 0.5, 1.5, 0.0, 10.0).floor();
    
    if (flangerEnabled) {
      FlangerFrequency = mutateDouble(FlangerFrequency, 1.1, 1.2, 0.0, 100.0);
      FlangerDelayScaler = mutateDouble(FlangerDelayScaler, 0.1, 0.2, 0.0, 2.0);
      FlangerFeedback = mutateDouble(FlangerFeedback, 0.1, 0.2, 0.0, 1.0);
      FlangerFeedbackSweep = mutateDouble(FlangerFeedbackSweep, -0.1, 0.1, -1.0, 1.0);
      FlangerBaseDelay = mutateDouble(FlangerBaseDelay, 0.1, 0.2, 0.0, 1.0);
    }

    if (lowPassFrequency < 25000.0) {
      lowPassFrequency = mutateDouble(lowPassFrequency, 10.1, 10.2, 0.0, 25000.0);
      lowPassSweep = mutateDouble(lowPassSweep, 2.1, 2.2, 0.0, 1000.0);
      lowPassResonance = mutateDouble(lowPassResonance, 1.1, 1.2, 0.0, 100.0);
    }

    if (highPassFrequency > 0.0) {
      highPassFrequency = mutateDouble(highPassFrequency, 10.1, 10.2, 0.0, 10000.0);
      highPassSweep = mutateDouble(highPassSweep, 2.1, 2.2, 0.0, 2000.0);
      highPassResonance = mutateDouble(highPassResonance, 1.1, 1.2, 0.0, 50.0);
    }
  }
  
  double mutateDouble(double v, double s, double e, double min, double max) {
    if (SoundUtilities.yes) {
      double d = 0.0;
      if (SoundUtilities.yes) {
        d = v + SoundUtilities.rndr(s, e);
        if (v < 0.0)
          d = 0.0;
        else {
          d = d.clamp(min, max);
        }
      }
      else {
        d = v - SoundUtilities.rndr(s, e);
        if (v < 0.0)
          d = 0.0;
        else
          d = d.clamp(min, v);
      }
      v = SoundUtilities.rndr(v, d);
    }
    
    return v;
  }
  
  void reset() {
    gain = DEFAULT_GAIN;
    
    if (flanger != null)
      disableFlanger();
    
    generator.reset();
    envelope.reset();
    arpeggio.reset();
    freq.reset();
    if (vibrato != null)
      vibrato.reset();
    retriggerCount = 1;
    if (flanger != null)
      flanger.reset();
    if (tremolo != null)
      tremolo.reset();
    if (lowPass != null)
      lowPass.reset();
    if (highPass != null)
      highPass.reset();
  }
  
  // -------------------------------------------------------------
  // Triggering
  // -------------------------------------------------------------
  void trigger(double now) {
    if (!enabled)
      return;
    
    if (retriggerCount > 1) {
      _trigger(now);
      
      int delay = (retriggerRate * 1000.0).toInt();
      
      Duration triggerDelay = new Duration(milliseconds: delay);
      retriggerCountDown = retriggerCount - 1;
      
      Timer t = new Timer.periodic(triggerDelay, _timer);
    }
    else {
      _trigger(now);
    }
  }
  
  void _timer(Timer t) {
    retriggerCountDown--;
    if (retriggerCountDown <= 0)
      t.cancel();
    _trigger(_context.currentTime);
  }
  
  void _trigger(double now) {
    generator.update(now);
    
    arpeggio.update(frequency, now);
    freq.update(frequency, now);
    
    if (lowPass != null)
      lowPass.update(now);
    if (highPass != null)
      highPass.update(now);
    if (flanger != null)
      flanger.update(now);
    
    envelope.trigger(now);
  }
  
  // -------------------------------------------------------------
  // Configuration
  // -------------------------------------------------------------
  void configureWithJSON(Map m) {
    category = m["Category"] as String;
    name = m["Name"] as String;
    generator.OscillatorType = m["WaveShape"] as String;
    gain = toDouble(m["Gain"]);
    channelDelay.delayTime.value = toDouble(m["Delay"]);
    
    enabled = toBool(m["Enabled"]);
    _buffered = toBool(m["Buffered"]);
    
    Map mEnv = m["Envelope"];
    List<num> v = mEnv["Attack"] as List<num>;
    envelope.setAttack(v[WAEnvelope.VALUE].toDouble(), v[WAEnvelope.TIME].toDouble());
    v = mEnv["Decay"] as List<num>;
    envelope.setDecay(v[WAEnvelope.VALUE].toDouble(), v[WAEnvelope.TIME].toDouble());
    v = mEnv["Sustain"] as List<num>;
    envelope.setSustain(v[WAEnvelope.VALUE].toDouble(), v[WAEnvelope.TIME].toDouble());
    v = mEnv["Release"] as List<num>;
    envelope.setRelease(v[WAEnvelope.VALUE].toDouble(), v[WAEnvelope.TIME].toDouble());
    
    Map mFreq = m["Frequency"];
    generator.enableFrequency = toBool(mFreq["Enabled"]);
    generator.frequency = toDouble(mFreq["Frequency"]);
    slideCutoff = toDouble(mFreq["MinCutoff"]);
    slideFrequency = toDouble(mFreq["Slide"]);
    slideTime = toDouble(mFreq["Acceleration"]);
    frequencyGain = toDouble(mFreq["Gain"]);
    
    Map mNoi = m["Noise"];
    NoisePlaybackRate = toDouble(mNoi["PlaybackRate"]);
    NoiseBufferSize = toInt(mNoi["BufferSize"]);
    NoiseVolume = toDouble(mNoi["Volume"]);
    NoiseOverdrive = toDouble(mNoi["Overdrive"]);
    
    Map mVib = m["Vibrato"];
    connectVibrato(toBool(mVib["Enabled"]));
    if (vibratoEnabled) {
      vibratoStrength = toDouble(mVib["Depth"]);
      vibratoFrequency = toDouble(mVib["Speed"]);
      vibrato.waveType = jToString(mVib["waveType"]);
    }

    Map mTre = m["Tremolo"];
    _connectTremolo(toBool(mTre["Enabled"]));
    if (tremoloEnabled) {
      tremoloStrength = toDouble(mTre["Depth"]);
      tremoloFrequency = toDouble(mTre["Speed"]);
      tremolo.waveType = jToString(mTre["waveType"]);
    }

    Map mArp = m["Arpreggiation"];
    arpeStepType = toInt(mArp["StepType"]);
    arpefrequencyStep = toDouble(mArp["FrequencyStep"]);
    arpeTimeStep = toDouble(mArp["TimePeriod"]);
    arpeExpoDecay = toDouble(mArp["DecayTime"]);
    arpeNotes = toInt(mArp["Notes"]);

    Map mDuty = m["DutyCycle"];
    dutyCycle = toDouble(mDuty["Percent"]);
    dutySweep = toDouble(mDuty["Sweep"]);

    Map mTrig = m["Retrigger"];
    retriggerCount = toInt(mTrig["Count"]);
    retriggerRate = toDouble(mTrig["Rate"]);

    Map mFlanger = m["Flanger"];
    if (toBool(mFlanger["Enabled"]))
      enableFlanger();
      
    FlangerFrequency = toDouble(mFlanger["Frequency"]);
    FlangerDelayScaler = toDouble(mFlanger["DelayScaler"]);
    FlangerFeedback = toDouble(mFlanger["Feedback"]);
    FlangerFeedbackSweep = toDouble(mFlanger["Sweep"]);
    FlangerBaseDelay = toDouble(mFlanger["BaseDelay"]);

    Map mLowPass = m["LowPass"];
    connectLowPass(toBool(mLowPass["Enabled"]));
    lowPassFrequency = toDouble(mLowPass["Frequency"]);
    lowPassSweep = toDouble(mLowPass["Sweep"]);
    lowPassResonance = toDouble(mLowPass["Resonance"]);

    Map mHighPass = m["HighPass"];
    connectHighPass(toBool(mHighPass["Enabled"]));
    highPassFrequency = toDouble(mHighPass["Frequency"]);
    highPassSweep = toDouble(mHighPass["Sweep"]);
    highPassResonance = toDouble(mHighPass["Resonance"]);
    
    Map mDist = m["Distortion"];
    if (mDist != null) {
      connectDistortion(toBool(mDist["Enabled"]));
      DistortionScale = toDouble(mDist["Scale"]);
      DistortionParts = toInt(mDist["SummationParts"]);
      DistortionMag1 = toDouble(mDist["Mag1"]);
      DistortionMag2 = toDouble(mDist["Mag2"]);
      DistortionMag3 = toDouble(mDist["Mag3"]);
      DistortionEquation = toInt(mDist["Equation"]);
      DistortionClamp = toDouble(mDist["Clamp"]);
    }
    else {
      connectDistortion(false);
    }
  }
  
  String jToString(Object o) {
    if (o == null)
      return "";
    String d = o as String;
    return d;
  }
  
  double toDouble(Object o) {
    if (o == null)
      return 0.0;
    num d = o as num;
    return d.toDouble();
  }
  
  int toInt(Object o) {
    if (o == null)
      return 0;
    num d = o as num;
    return d.toInt();
  }
  
  bool toBool(Object o) {
    if (o == null)
      return false;
    bool d = o as bool;
    return d;
  }
  
  Map toMapAsSettings() {
    Map m = {
      "Category": category,
      "Name": name,
      "WaveShape": generator.OscillatorType,
      "Gain": gain,
      "Buffered": Buffered,
      "Delay": channelDelay.delayTime.value,
      "Enabled": enabled,
      "Envelope": 
        {
          "Attack": envelope.attack,
          "Decay": envelope.decay,
          "Sustain": envelope.sustain,
          "Release": envelope.release
        },
      "Frequency":
        {
          "Enabled": generator.enableFrequency,
          "Frequency": generator.frequency,
          "MinCutoff": slideCutoff,
          "Slide": slideFrequency,
          "Acceleration": slideTime,
          "Gain": frequencyGain
        },
      "Noise":
        {
          "PlaybackRate": NoisePlaybackRate,
          "BufferSize": NoiseBufferSize,
          "Volume": NoiseVolume,
          "Overdrive": NoiseOverdrive
        },
      "Vibrato":
        {
          "Enabled": vibrato == null ? false : vibrato.enabled,
          "waveType": vibrato == null ? WASfxr.SINE : vibrato.waveType,
          "Depth": vibratoStrength,
          "Speed": vibratoFrequency
        },
      "Tremolo":
        {
          "Enabled": tremolo == null ? false : tremolo.enabled,
          "waveType": tremolo == null ? WASfxr.SINE : tremolo.waveType,
          "Depth": tremoloStrength,
          "Speed": tremoloFrequency
        },
      "Arpreggiation":
        {
          "StepType": arpeStepType,
          "FrequencyStep": arpefrequencyStep,
          "TimePeriod": arpeTimeStep,
          "DecayTime": arpeExpoDecay,
          "Notes": arpeNotes
        },
      "DutyCycle":
        {
          "Percent": dutyCycle,
          "Sweep": dutySweep
        },
      "Retrigger":
        {
          "Count": retriggerCount,
          "Rate": retriggerRate
        },
      "Flanger":
        {
          "Enabled": flanger == null ? false : flanger.enabled,
          "Frequency": FlangerFrequency,
          "DelayScaler": FlangerDelayScaler,
          "Feedback": FlangerFeedback,
          "Sweep": FlangerFeedbackSweep,
          "BaseDelay": FlangerBaseDelay
        },
      "LowPass":
        {
          "Enabled": lowPass == null ? false : lowPass.enabled,
          "Frequency": lowPassFrequency,
          "Sweep": lowPassSweep,
          "Resonance": lowPassResonance
        },
      "HighPass":
        {
          "Enabled": highPass == null ? false : highPass.enabled,
          "Frequency": highPassFrequency,
          "Sweep": highPassSweep,
          "Resonance": highPassResonance
        },
      "Distortion":
        {
          "Enabled": DistortionEnabled,
          "Scale": DistortionScale,
          "SummationParts": DistortionParts,
          "Mag1": DistortionMag1,
          "Mag2": DistortionMag2,
          "Mag3": DistortionMag3,
          "Equation": DistortionEquation,
          "Clamp": DistortionClamp
        }
    };
    
    return m;
  }
}