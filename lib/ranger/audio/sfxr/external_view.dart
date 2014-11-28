part of ranger;

class ExternalView extends ParamView {
  double frequency;              // Hz
  double frequencyMin;           // Hz
  double frequencySlide;      // 8va/sec
  double frequencySlideSlide; // 8va/sec/sec

  double vibratoDepth; // proportion
  double vibratoRate;     // Hz

  double arpeggioFactor;   // multiple of frequency
  double arpeggioDelay;    // sec  
    
  double dutyCycle;        // proportion of wavelength
  double dutyCycleSweep;   // proportion/second

  double retriggerRate; // Hz

  double flangerOffset;   // sec
  double flangerSweep;    // offset/sec

  double lowPassFrequency;    // Hz
  double lowPassSweep;     // ^sec
  double lowPassResonance; // proportion

  double highPassFrequency; // Hz
  double highPassSweep;  // ^sec
  
  bool enableFrequencyCutoff;
  bool enableLowPassFilter;
  
  double gain; // dB

  ExternalView();
  
  bool init() {
    setToDefault();
    return true;
  }

  factory ExternalView.basic() {
    ExternalView sp = new ExternalView();
    if (sp.init()) {
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asPickupCoin() {
    ExternalView sp = new ExternalView();
    
    if (sp.init()) {
      sp.frequency = SoundUtilities.rndr(568.0, 2861.0);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.227);
      sp.decay = SoundUtilities.rndr(0.227, 0.567);
      sp.punch = SoundUtilities.rndr(0.3, 0.6);
      if (SoundUtilities.yes) {
        sp.arpeggioFactor = SoundUtilities.rndr(1.037, 1.479);
        sp.arpeggioDelay = SoundUtilities.rndr(0.042, 0.114);
      }
      
      return sp;
    }
    
    return null;
  }

  factory ExternalView.asLaserShoot() {
    ExternalView sp = new ExternalView();
    
    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(2.0);
      if (sp.waveShape == Generator.SINE && SoundUtilities.yes)
        sp.waveShape = SoundUtilities.rnd(1.0);
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.frequency = SoundUtilities.rndr(321.0, 2861.0);
        sp.frequencyMin = SoundUtilities.frnd(38.8);
        sp.frequencySlide = SoundUtilities.rndr(-27.3, -174.5);
      } else {
        sp.frequency = SoundUtilities.rndr(321.0, 3532.0);
        sp.frequencyMin = SoundUtilities.rndr(144.0, 2/3 * sp.frequency);
        sp.frequencySlide = SoundUtilities.rndr(-2.15, -27.27);
      }
      if (sp.waveShape == Generator.SAWTOOTH)
        sp.dutyCycle = 0.0;
      if (SoundUtilities.yes) {
        sp.dutyCycle = SoundUtilities.rndr(1/4, 1/2);
        sp.dutyCycleSweep = SoundUtilities.rndr(0.0, -3.528);
      } else {
        sp.dutyCycle = SoundUtilities.rndr(0.05, 0.3);
        sp.dutyCycleSweep = SoundUtilities.frnd(12.35);
      }
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.rndr(0.02, 0.2);
      sp.decay = SoundUtilities.frnd(0.36);
      if (SoundUtilities.yes)
        sp.punch = SoundUtilities.frnd(0.3);
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.flangerOffset = SoundUtilities.frnd(0.001);
        sp.flangerSweep = -SoundUtilities.frnd(0.04);
      }
      if (SoundUtilities.yes)
        sp.highPassFrequency = SoundUtilities.frnd(3204.0);
      
      return sp;
    }
    
    return null;
  }

  factory ExternalView.asExplosion() {
    ExternalView sp = new ExternalView();
    
    if (sp.init()) {
      sp.waveShape = Generator.NOISE;
      if (SoundUtilities.yes) {
        sp.frequency = SoundUtilities.rndr(4.0, 224.0);
        sp.frequencySlide = SoundUtilities.rndr(-0.623, 17.2);
      } else {
        sp.frequency = SoundUtilities.rndr(9.0, 2318.0);
        sp.frequencySlide = SoundUtilities.rndr(-5.1, -40.7);
      }
      if (SoundUtilities.rnd(4.0) == 0)
        sp.frequencySlide = 0.0;
      if (SoundUtilities.rnd(2.0) == 0)
        sp.retriggerRate = SoundUtilities.rndr(4.5, 53.0);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.rndr(0.0227, 0.363);
      sp.decay = SoundUtilities.frnd(0.567);
      if (SoundUtilities.yes) {
        sp.flangerOffset = SoundUtilities.rndr(-0.0021, 0.0083);
        sp.flangerSweep = -SoundUtilities.frnd(0.09);
      }
      sp.punch = 0.2 + SoundUtilities.frnd(0.6);
      if (SoundUtilities.yes) {
        sp.vibratoDepth = SoundUtilities.frnd(0.35);
        sp.vibratoRate = SoundUtilities.frnd(24.8);
      }
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.arpeggioFactor = SoundUtilities.rndr(0.135, 2.358);
        sp.arpeggioDelay = SoundUtilities.rndr(0.00526, 0.0733);
      }
  
      return sp;
    }
    
    return null;
  }

  factory ExternalView.asPowerUp() {
    ExternalView sp = new ExternalView();

    if (sp.init()) {
      if (SoundUtilities.yes) {
        sp.waveShape = Generator.SAWTOOTH;
        sp.dutyCycle = 0.0;
      } else {
        sp.dutyCycle = SoundUtilities.rndr(0.2, 0.5);
      }
      sp.frequency = SoundUtilities.rndr(145.0, 886.0);
      if (SoundUtilities.yes) {
        sp.frequencySlide = SoundUtilities.rndr(0.636, 79.6);
        sp.retriggerRate = SoundUtilities.rndr(6.0, 53.0);
      } else {
        sp.frequencySlide = SoundUtilities.rndr(0.0795, 9.94);
        if (SoundUtilities.yes) {
          sp.vibratoDepth = SoundUtilities.frnd(0.35);
          sp.vibratoRate = SoundUtilities.frnd(24.8);
        }
      }
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.363);
      sp.decay = SoundUtilities.rndr(0.023, 0.57);
     
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asHitHurt() {
    ExternalView sp = new ExternalView();

    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(2.0);
      if (sp.waveShape == Generator.SINE)
        sp.waveShape = Generator.NOISE;
      if (sp.waveShape == Generator.SQUARE)
        sp.dutyCycle = SoundUtilities.rndr(0.2, 0.5);
      if (sp.waveShape == Generator.SAWTOOTH)
        sp.dutyCycle = 0.0;
      sp.frequency = SoundUtilities.rndr(145.0, 2261.0);
      sp.frequencySlide = SoundUtilities.rndr(-17.2, -217.9);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.023);
      sp.decay = SoundUtilities.rndr(0.023, 0.2);
      if (SoundUtilities.yes)
        sp.highPassFrequency = SoundUtilities.frnd(3204.0);
     
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asJump() {
    ExternalView sp = new ExternalView();

    if (sp.init()) {
      sp.waveShape = Generator.SQUARE;
      sp.dutyCycle = SoundUtilities.rndr(0.2, 0.5);
      sp.frequency = SoundUtilities.rndr(321.0, 1274.0);
      sp.frequencySlide = SoundUtilities.rndr(0.64, 17.2);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.rndr(0.023, 0.36);
      sp.decay = SoundUtilities.rndr(0.023, 0.2);
      if (SoundUtilities.yes)
        sp.highPassFrequency = SoundUtilities.frnd(3204.0);
      if (SoundUtilities.yes)
        sp.lowPassFrequency = SoundUtilities.rndr(2272.0, 44100.0);
     
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asBlipSelect() {
    ExternalView sp = new ExternalView();

    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(1.0);
      if (sp.waveShape == Generator.SQUARE)
        sp.dutyCycle = SoundUtilities.rndr(0.2, 0.5);
      else
        sp.dutyCycle = 0.0;
      sp.frequency = SoundUtilities.rndr(145.0, 1274.0);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.rndr(0.023, 0.09);
      sp.decay = SoundUtilities.frnd(0.09);
      sp.highPassFrequency = 353.0;
     
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asTone() {
    ExternalView sp = new ExternalView();
    
    if (sp.init()) {
      sp.waveShape = Generator.SINE;
      sp.frequency = 440.0;
      sp.attack = 0.0;
      sp.sustain = 1.0;
      sp.decay = 0.0;
      
      return sp;
    }
    
    return null;
  }
  
  factory ExternalView.asRandom() {
    ExternalView sp = new ExternalView();

    if (sp.init()) {
      if (SoundUtilities.yes)
        sp.frequency = SoundUtilities.rndr(885.5, 7941.5);
      else
        sp.frequency = SoundUtilities.rndr(3.5, 3532.0);
      sp.frequencySlide = SoundUtilities.rndr(-633.0, 639.0);
      if (sp.frequency > 1732 && sp.frequencySlide > 5)
        sp.frequencySlide = -sp.frequencySlide;
      if (sp.frequency < 145 && sp.frequencySlide < -0.088)
        sp.frequencySlide = -sp.frequencySlide;
      sp.frequencySlideSlide = SoundUtilities.rndr(-0.88, 0.88);
      sp.dutyCycle = SoundUtilities.frnd(1.0);
      sp.dutyCycleSweep = SoundUtilities.rndr(-17.64, 17.64);
      sp.vibratoDepth = SoundUtilities.rndr(-0.5, 0.5);
      sp.vibratoRate = SoundUtilities.rndr(0.0, 69.0);
      sp.attack = SoundUtilities.cube(SoundUtilities.frnd(1.0)) * 2.26;
      sp.sustain = SoundUtilities.sqr(SoundUtilities.frnd(1.0)) * 2.26 + 0.09;
      sp.decay = SoundUtilities.frnd(1.0) * 2.26;
      sp.punch = SoundUtilities.sqr(SoundUtilities.frnd(1.0)) * 0.64;
      if (sp.attack + sp.sustain + sp.decay < 0.45) {
        sp.sustain += SoundUtilities.rndr(0.5, 1.25);
        sp.decay += SoundUtilities.rndr(0.5, 1.25);
      }
      sp.lowPassResonance = SoundUtilities.rndr(0.444, 0.97);
      sp.lowPassFrequency = SoundUtilities.frnd(39200.0);
      sp.lowPassSweep = SoundUtilities.rndr(0.012, 82.0);
      if (sp.lowPassFrequency < 35 && sp.lowPassSweep < 0.802)
        sp.lowPassSweep = 1 - sp.lowPassSweep;
      sp.highPassFrequency = 39200 * math.pow(SoundUtilities.frnd(1.0), 5);
      sp.highPassSweep = 555718 * math.pow(SoundUtilities.rndr(-1.0, 1.0), 5);
      sp.flangerOffset = 0.023 * SoundUtilities.cube(SoundUtilities.frnd(2.0) - 1);
      sp.flangerSweep = SoundUtilities.cube(SoundUtilities.frnd(2.0) - 1);
      sp.retriggerRate = SoundUtilities.frnd(1378.0);
      sp.arpeggioDelay = SoundUtilities.frnd(1.81);
      sp.arpeggioFactor = SoundUtilities.rndr(0.09, 10.0);
     
      return sp;
    }
    
    return null;
  }
  
  void setForRepeat(Generator sg) {
    super.setForRepeat(sg);
    
    sg.elapsedSinceRepeat = 0.0;

    sg.period = Generator.OVERSAMPLING * 44100.0 / frequency;
    sg.periodMax = Generator.OVERSAMPLING * 44100.0 / frequencyMin;
    sg.enableFrequencyCutoff = (frequencyMin > 0.0);
    sg.periodMult = math.pow(.5, frequencySlide / 44100.0);
    sg.periodMultSlide = frequencySlideSlide * math.pow(2.0, -44101.0/44100.0) / 44100.0;

    sg.dutyCycle = dutyCycle;
    sg.dutyCycleSlide = dutyCycleSweep / (Generator.OVERSAMPLING * 44100.0);

    sg.arpeggioMultiplier = 1.0 / arpeggioFactor;
    sg.arpeggioTime = (arpeggioDelay * 44100.0).floor();
    
    // Vibrato
    sg.vibratoSpeed = vibratoRate * 64.0 / 44100.0 / 10.0;
    sg.vibratoAmplitude = vibratoDepth;

    // Repeat
    sg.repeatTime = retriggerRate > 0 ? (1.0 / (44100.0 * retriggerRate)).floor() : 0;

    // Flanger
    sg.flangerOffset = flangerOffset * 44100.0;
    sg.flangerOffsetSlide = flangerSweep;

    // Low pass filter
    sg.fltw = lowPassFrequency / (Generator.OVERSAMPLING * 44100.0 + lowPassFrequency);
    sg.enableLowPassFilter = lowPassFrequency < 44100.0;
    sg.fltw_d = math.pow(lowPassSweep, 1.0/44100.0);
    sg.fltdmp = (1.0 - lowPassResonance) * 9.0 * (0.01 + sg.fltw);

    // High pass filter
    sg.flthp = highPassFrequency / (Generator.OVERSAMPLING * 44100.0 + highPassFrequency);
    sg.flthp_d = math.pow(highPassSweep, 1.0/44100.0);
  }

  void setToDefault() {
    waveShape = Generator.SQUARE;

    attack = 0.0;   // sec
    sustain = 0.2; // sec
    punch = 0.0;   // proportion
    decay = 0.2; // sec

    frequency = 1000.0; // Hz
    frequencyMin = 0.0; // Hz
    frequencySlide = 0.0; // 8va/sec
    frequencySlideSlide = 0.0; // 8va/sec/sec

    vibratoDepth = 0.0; // proportion
    vibratoRate = 10.0; // Hz

    arpeggioFactor =1.0;   // multiple of frequency
    arpeggioDelay = 0.1; // sec  
      
    dutyCycle = 0.5; // proportion of wavelength
    dutyCycleSweep = 0.0;   // proportion/second

    retriggerRate = 0.0; // Hz

    flangerOffset = 0.0; // sec
    flangerSweep = 0.0; // offset/sec

    lowPassFrequency = 44100.0; // Hz
    lowPassSweep = 1.0;     // ^sec
    lowPassResonance = 0.5;   // proportion

    highPassFrequency = 0.0; // Hz
    highPassSweep = 0.0; // ^sec
    
    enableFrequencyCutoff = false;
    enableLowPassFilter = false;
    
    gain = -10.0; // dB

    sampleRate = 44100; // Hz
    sampleSize = 8;     // bits per channel
  }
  
  // Translate from internal values to readable external values.
  ExternalView convert(InternalView sp) {
    waveShape = sp.waveShape;

    attack = SoundUtilities.sqr(sp.attack) * 100000.0 / 44100.0;
    sustain = SoundUtilities.sqr(sp.sustain) * 100000.0 / 44100.0;
    punch = sp.punch;
    decay = SoundUtilities.sqr(sp.decay) * 100000.0 / 44100.0;

    frequency = Generator.OVERSAMPLING * 441.0 * (SoundUtilities.sqr(sp.p_base_freq) + 0.001);
    if (sp.p_freq_limit > 0.0)
      frequencyMin = Generator.OVERSAMPLING * 441.0 * (SoundUtilities.sqr(sp.p_freq_limit) + 0.001);
    else
      frequencyMin = 0.0;
    enableFrequencyCutoff = (sp.p_freq_limit > 0.0);
    frequencySlide = 44100.0 * SoundUtilities.log(1.0 - SoundUtilities.cube(sp.p_freq_ramp) / 100.0, 0.5);
    frequencySlideSlide = -SoundUtilities.cube(sp.p_freq_dramp) / 1000000.0 * 
      44100.0 * math.pow(2.0, 44101.0/44100.0);

    vibratoRate = 44100.0 * 10.0 / 64.0 * SoundUtilities.sqr(sp.p_vib_speed) / 100.0;
    vibratoDepth = sp.p_vib_strength * 50.0;  // "/2.0" ???

    arpeggioFactor = 1.0 / ((sp.p_arp_mod >= 0.0) ? 
                               1.0 - SoundUtilities.sqr(sp.p_arp_mod) * 0.9 : 
                               1.0 + SoundUtilities.sqr(sp.p_arp_mod) * 10.0);
    arpeggioDelay = ((sp.p_arp_speed == 1) ? 0.0 :
                  (SoundUtilities.sqr(1 - sp.p_arp_speed) * 20000.0 + 32.0) / 44100.0);

    dutyCycle = (1.0 - sp.p_duty) / 2.0 * 100.0;
    dutyCycleSweep = Generator.OVERSAMPLING * 44100.0 * -sp.p_duty_ramp / 20000.0;

    retriggerRate = 44100.0 / ((sp.p_repeat_speed == 0.0) ? 0.0 :
                         (SoundUtilities.sqr(1 - sp.p_repeat_speed) * 20000.0) + 32.0);

    flangerOffset = (sp.p_pha_offset).sign * SoundUtilities.sqr(sp.p_pha_offset) * 1020.0 / 44100.0 * 1000.0;
    flangerSweep = (sp.p_pha_ramp).sign * SoundUtilities.sqr(sp.p_pha_ramp) * 1000.0;

    enableLowPassFilter = (sp.p_lpf_freq != 1.0);
    
    lowPassFrequency = sp.p_lpf_freq == 1.0 ? 44100.0 :
      (Generator.OVERSAMPLING * 44100.0 * SoundUtilities.flurp(SoundUtilities.cube(sp.p_lpf_freq) / 10.0));
    lowPassSweep = math.pow(1.0 + sp.p_lpf_ramp / 10000.0, 44100.0);
    lowPassResonance = (1.0 - (5.0 / (1.0 + SoundUtilities.sqr(sp.p_lpf_resonance) * 20.0)) / 9.0) * 100.0;

    highPassFrequency = (Generator.OVERSAMPLING * 44100.0 * SoundUtilities.flurp(SoundUtilities.sqr(sp.p_hpf_freq) / 10.0));
    highPassSweep = math.pow(1.0 + sp.p_hpf_ramp * 0.0003, 44100.0);

    gain = 10.0 * SoundUtilities.log(SoundUtilities.sqr(math.exp(sp.sound_vol) - 1.0), 10.0);

    sampleRate = sp.sampleRate;
    sampleSize = sp.sampleSize;

    return this;
  }
}