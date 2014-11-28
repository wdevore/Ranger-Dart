part of ranger;

/**
 * A WebAudio adaptation of jsfxr/sfxr.
 * [Sfxr] will generate and create audio buffers and track audio state. 
 * You can also pass a JSON [Map] that contains both data and info to
 * reload a sound effect.
 * 
 * See [toMapAsSettings] for [Map] structure.
 * 
 * https://github.com/grumdrig/jsfxr
 * Notes about porting jsfxr. jsfxr was chuck full of bugs:
 * - out-of-range array errors.
 * - used vars
 * - setting values to wrong vars
 * - haphazard int/double bouncing.
 * - divide by zero
 * 
 * http://www.soundonsound.com/sos/nov99/articles/synthsecrets.htm
 * http://blog.chrislowis.co.uk/2013/06/17/synthesis-web-audio-api-envelopes.html
 */
class Sfxr {
  AudioContext _context;

  Map<String, AudioBuffer> _buffers;
  
  /// The currently active [AudioBuffer]
  String current;
  
  static const String PICKUP_COIN = "PickupCoin";
  static const String LASER_SHOOT = "LaserShoot";
  static const String EXPLOSION = "Explosion";
  static const String POWERUP = "PowerUp";
  static const String HIT_HURT = "HitHurt";
  static const String JUMP = "Jump";
  static const String BLIP_SELECT = "BlipSelect";
  static const String RANDOM = "Random";
  static const String TONE = "Tone";
  
  String category;
  
  Generator generator;
  ExternalView uiView;
  InternalView view;
  
  Sfxr() {
    uiView = new ExternalView.basic();
    _buffers = new Map<String, AudioBuffer>();
  }

  factory Sfxr.basic(AudioContext context) {
    Sfxr o = new Sfxr();
    o._context = context;
    
    return o;
  }
  
  factory Sfxr.withJSON(Map sfxr, AudioContext context) {
    Sfxr o = new Sfxr();
    o._context = context;
    
    if (o.initWithMap(sfxr)) {
      
      return o;
    }
    
    return null;
  }
  
  bool initWithMap(Map sfxr) {
    String format = sfxr["Format"] as String;
    String name = sfxr["Name"] as String;
    category = sfxr["Category"] as String;
    
    if (format == "AutoGen") {
      autoGenByCategory(name, sfxr);
      return true;
    }
    else if (format == "Samples") {
      // Use Unit data provided.
      List<double> data = sfxr["Data"] as List<double>;
      Float32List samples = new Float32List(data.length);
      int i = 0;
      data.forEach((num n) => samples[i++] = n.toDouble());
      
      num nSampleRate = sfxr["SampleRate"] as num;
      _transferSamplesToAudioBuffer(name, samples, nSampleRate.toInt());
      return true;
    }
    else if (format == "InternalView") {
      addEffect(sfxr);
      return true;
    }
    
    return false;
  }
  
  void addEffect(Map sfxr) {
    current = sfxr["Name"] as String;
    print("Configuring $current...");

    view = new InternalView.withJSON(sfxr);
    
    generator = new Generator.withInternalView(view);
    
    view.setForRepeat(generator);

    if (sfxr["Noise"] != null) {
      List<num> noise = sfxr["Noise"] as List<num>;
      generator.noise_buffer = new List<double>.from(noise);
    }

    generator.generate();  // This is computatively intensive.
    
    // Now we have samples in Unit form. Transfer them to WebAudio.
    _tranferGenToAudioBuffer(current, generator);
  }
  
  void updateByWaveShape(int waveShape) {
    _buffers.remove(current);
    
    view.waveShape = waveShape;
    view.setForRepeat(generator);
    generator.generate();  // This is computatively intensive.
    
    // Now we have samples in Unit form. Transfer them to WebAudio.
    _tranferGenToAudioBuffer(current, generator);
  }
  
  InternalView _createInternalView(String category, [int waveShape = Generator.NOISE]) {
    InternalView iv;

    if (category == "Tone") {
      iv = new InternalView.asTone(waveShape);
    }
    else if (category == "PickupCoin") {
      iv = new InternalView.asPickupCoin(waveShape);
    }
    else if (category == "LaserShoot") {
      iv = new InternalView.asLaserShoot();
    }
    else if (category == "Explosion") {
      iv = new InternalView.asExplosion(waveShape);
    }
    else if (category == "HitHurt") {
      iv = new InternalView.asHitHurt();
    }
    else if (category == "PowerUp") {
      iv = new InternalView.asPowerUp();
    }
    else if (category == "Jump") {
      iv = new InternalView.asJump();
    }
    else if (category == "BlipSelect") {
      iv = new InternalView.asBlipSelect();
    }
    else if (category == "Random") {
      iv = new InternalView.asRandom();
    }
    
    return iv;
  }
  
  void autoGenByCategory(String name, Map sfxr) {
    current = name;
    
    // Ignore any data present and create from scratch using one of
    // built in functions.
    category = sfxr["Category"] as String;

    int waveShape = Generator.SINE;
    
    if (category == "Explosion") {
      String noiseTypeS = sfxr["NoiseType"] as String;
      waveShape = Generator.NOISE;
      if (noiseTypeS == "Pink")
        waveShape = Generator.NOISE_PINK;
      else if (noiseTypeS == "Brownian")
        waveShape = Generator.NOISE_BROWNIAN;
    }
    else if (category == Sfxr.PICKUP_COIN) {
      waveShape = Generator.SQUARE;
    }
    else if (category == Sfxr.LASER_SHOOT) {
      waveShape = Generator.SAWTOOTH;
    }
    else if (category == Sfxr.EXPLOSION) {
      waveShape = Generator.NOISE;
    }
    else if (category == Sfxr.POWERUP) {
      waveShape = Generator.SQUARE;
    }
    else if (category == Sfxr.HIT_HURT) {
      waveShape = Generator.NOISE;
    }
    else if (category == Sfxr.JUMP) {
      waveShape = Generator.SQUARE;
    }
    else if (category == Sfxr.BLIP_SELECT) {
      waveShape = Generator.SAWTOOTH;
    }
    else if (category == Sfxr.RANDOM) {
      waveShape = Generator.SQUARE;
    }
    else if (category == Sfxr.TONE) {
      waveShape = Generator.SINE;
    }
    
    view = _createInternalView(category, waveShape);

    generator = new Generator.withInternalView(view);
    generator.generate();  // This is computatively intensive.
    
    // Now we have samples in Unit form. Transfer them to WebAudio.
    _tranferGenToAudioBuffer(name, generator);
  }
  
  void _transferSamplesToAudioBuffer(String name, Float32List samples, int sampleRate) {
    // Create audio buffer to transfer samples into
    AudioBuffer buffer = _context.createBuffer(1, samples.length, sampleRate);
    _buffers[name] = buffer;
    
    // Get the mono-channel data.
    Float32List data = buffer.getChannelData(0);

    // Copy from List to WebAudio
    int i = 0;
    samples.forEach((double sample) => data[i++] = sample);
  }
  
  void _tranferGenToAudioBuffer(String name, Generator sg) {
    int frameCount = _frameCount(sg);
    
    if (frameCount == 0)
      return;
    
    // Create audio buffer to transfer samples into
    AudioBuffer buffer = _context.createBuffer(1, frameCount, sg.sampleRate);
    _buffers[name] = buffer;
    
    // Get the mono-channel data.
    Float32List data = buffer.getChannelData(0);

    // Copy from Sfxr to WebAudio
    int i = 0;
    sg.samples.forEach((double sample) => data[i++] = sample);
  }
  
  int _frameCount(Generator sg) {
    int frameCount;
    // We could allocate buffers in sizes that are multiples of the
    // sample rate. But this isn't necessary.
    //int l = sg.samples.length;
    //int r2 = l - (l % sg.sampleRate);
    //int r3 = r2 ~/ sg.sampleRate;
    //frameCount = (r2 + 1) * sg.sampleRate;

    // Just return the sample size
    frameCount = sg.samples.length;

    return frameCount;
  }
  
  /**
   * [name] is optional. If not supplied the last effect loaded is played.
   */
  void play([String name]) {
    if (name == null)
      name = current;
    AudioBuffer ab = _buffers[name];
    
    if (ab != null) {
      AudioBufferSourceNode srcNode = _context.createBufferSource();
      srcNode.buffer = ab;
      
      GainNode amp = _context.createGain();
      amp.gain.value = view.sound_vol;
      
      // Connect everything up.
      srcNode.connectNode(amp);
      amp.connectNode(_context.destination);
      
      // Fire and forget.
      srcNode.start();
    }
  }
  
  set soundVolume(double volume) {
    if (view != null) { 
      view.sound_vol = volume;
    }
  }
  
  void convert() {
    uiView.convert(view);
  }
  
  void update() {
    if (view != null) {
      _buffers.remove(current);
  
      view.setForRepeat(generator);
      
      generator.generate();  // This is computatively intensive.
      
      // Now we have samples in Unit form. Transfer them to WebAudio.
      _tranferGenToAudioBuffer(current, generator);
    }
  }
  
  void mutate() {
    if (view != null) {
      view.mutate();
      update();
    }
  }
  
  Map toMapAsSamples(String name, String category) {
    AudioBuffer ab = _buffers[name];
    Float32List data = ab.getChannelData(0);

    Map m = {
      "Format": "Buffer",
      "Category": category,
      "Name": name,
      "Data": data
    };
    
    return m;
  }
  
  Map toMapAsSettings(String name, String category) {

    if (view == null)
      return null;
    
    Map m = {
      "Format": "InternalView",
      "Category": category,
      "Name": name,
      "BaseFrequency": view.p_base_freq,
      "FrequencyLimit": view.p_freq_limit,
      "FrequencyRamp": view.p_freq_ramp,
      "FrequencyDeltaRamp": view.p_freq_dramp,
      "VibratoStrength": view.p_vib_strength,
      "VibratoSpeed": view.p_vib_speed,
      "VibratoDelay": view.p_vib_delay,
      "ArpeggioMod": view.p_arp_mod,
      "ArpeggioSpeed": view.p_arp_speed,
      "DutyCycle": view.p_duty,
      "DutyCycleRamp": view.p_duty_ramp,
      "RepeatSpeed": view.p_repeat_speed,
      "FlangerPhaseOffset": view.p_pha_offset,
      "FlangerPhaseRamp": view.p_pha_ramp,
      "LowPassFilterFrequency": view.p_lpf_freq,
      "LowPassFilterFrequencyRamp": view.p_lpf_ramp,
      "LowPassFilterFrequencyResonance": view.p_lpf_resonance,
      "HighPassFilterFrequency": view.p_hpf_freq,
      "HighPassFilterFrequencyRamp": view.p_hpf_ramp,
      "SoundVolume": view.sound_vol,
      "WaveShape": view.waveShape,
      "EnvelopeAttack": view.attack,
      "EnvelopeSustain": view.sustain,
      "EnvelopePunch": view.punch,
      "EnvelopeDecay": view.decay,
      "SampleRate": view.sampleRate,
      "Noise": generator.noise_buffer
    };
    
    //print(JSON.encode(m));
    return m;
  }
}