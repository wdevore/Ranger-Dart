part of ranger;

// Sound generation parameters are on [0,1] unless noted SIGNED & thus
// on [-1,1]
class InternalView extends ParamView {
  // Tone
  double p_base_freq;    // Start frequency
  double p_freq_limit;   // Min frequency cutoff
  double p_freq_ramp;    // Slide (SIGNED)
  double p_freq_dramp;   // Delta slide (SIGNED)

  // Vibrato
  double p_vib_strength; // Vibrato depth
  double p_vib_speed;    // Vibrato speed
  double p_vib_delay;
  
  // Tonal change
  double p_arp_mod;      // Change amount (SIGNED)
  double p_arp_speed;    // Change speed

  // Square wave duty (proportion of time signal is high vs. low)
  double p_duty;         // Square duty
  double p_duty_ramp;    // Duty sweep (SIGNED)

  // Repeat
  double p_repeat_speed; // Repeat speed

  // Flanger
  double p_pha_offset;   // Flanger offset (SIGNED)
  double p_pha_ramp;     // Flanger sweep (SIGNED)

  // Low-pass filter
  double p_lpf_freq;     // Low-pass filter cutoff
  double p_lpf_ramp;     // Low-pass filter cutoff sweep (SIGNED)
  double p_lpf_resonance;// Low-pass filter resonance
  // High-pass filter
  double p_hpf_freq;     // High-pass filter cutoff
  double p_hpf_ramp;     // High-pass filter cutoff sweep (SIGNED)

  // Sample parameters
  double sound_vol;
  
  InternalView();
  
  bool init() {
    setToDefault();
    return true;
  }

  factory InternalView.withJSON(Map sfxr) {
    InternalView sp = new InternalView();

    sp.waveShape = sfxr["WaveShape"] as int;

    sp.p_base_freq = sp.getDouble(sfxr["BaseFrequency"]);
    sp.p_freq_limit = sp.getDouble(sfxr["FrequencyLimit"]);
    sp.p_freq_ramp = sp.getDouble(sfxr["FrequencyRamp"]);
    sp.p_freq_dramp = sp.getDouble(sfxr["FrequencyDeltaRamp"]);
    sp.p_vib_strength = sp.getDouble(sfxr["VibratoStrength"]);
    sp.p_vib_speed = sp.getDouble(sfxr["VibratoSpeed"]);
    sp.p_vib_delay = sp.getDouble(sfxr["VibratoDelay"]);
    sp.p_arp_mod = sp.getDouble(sfxr["ArpeggioMod"]);
    sp.p_arp_speed = sp.getDouble(sfxr["ArpeggioSpeed"]);
    sp.p_duty = sp.getDouble(sfxr["DutyCycle"]);
    sp.p_duty_ramp = sp.getDouble(sfxr["DutyCycleRamp"]);
    sp.p_repeat_speed = sp.getDouble(sfxr["RepeatSpeed"]);
    sp.p_pha_offset = sp.getDouble(sfxr["FlangerPhaseOffset"]);
    sp.p_pha_ramp = sp.getDouble(sfxr["FlangerPhaseRamp"]);
    sp.p_lpf_freq = sp.getDouble(sfxr["LowPassFilterFrequency"]);
    sp.p_lpf_ramp = sp.getDouble(sfxr["LowPassFilterFrequencyRamp"]);
    sp.p_lpf_resonance = sp.getDouble(sfxr["LowPassFilterFrequencyResonance"]);
    sp.p_hpf_freq = sp.getDouble(sfxr["HighPassFilterFrequency"]);
    sp.p_hpf_ramp = sp.getDouble(sfxr["HighPassFilterFrequencyRamp"]);
    sp.sound_vol = sp.getDouble(sfxr["SoundVolume"]);

    sp.attack = sp.getDouble(sfxr["EnvelopeAttack"]);
    sp.sustain = sp.getDouble(sfxr["EnvelopeSustain"]);
    sp.punch = sp.getDouble(sfxr["EnvelopePunch"]);
    sp.decay = sp.getDouble(sfxr["EnvelopeDecay"]);
    sp.sampleRate = sfxr["SampleRate"] as int;
    
    return sp;
  }
  
  double getDouble(Object o) {
    num v = o as num;
    return v.toDouble();
  }
  
  factory InternalView.asPickupCoin([int waveShape = Generator.SQUARE]) {
    InternalView sp = new InternalView();
    
    if (sp.init()) {
      sp.waveShape = waveShape;
      sp.p_base_freq = 0.4 + SoundUtilities.frnd(0.5);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.1);
      sp.decay = 0.1 + SoundUtilities.frnd(0.4);
      sp.punch = 0.3 + SoundUtilities.frnd(0.3);
      if (SoundUtilities.yes) {
        sp.p_arp_speed = 0.5 + SoundUtilities.frnd(0.2);
        sp.p_arp_mod = 0.2 + SoundUtilities.frnd(0.4);
      }
      return sp;
    }
    
    return null;
  }
  
  factory InternalView.asLaserShoot() {
    InternalView sp = new InternalView();
    
    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(2.0);
      if(sp.waveShape == Generator.SINE && SoundUtilities.yes)
        sp.waveShape = SoundUtilities.rnd(1.0);
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.p_base_freq = 0.3 + SoundUtilities.frnd(0.6);
        sp.p_freq_limit = SoundUtilities.frnd(0.1);
        sp.p_freq_ramp = -0.35 - SoundUtilities.frnd(0.3);
      } else {
        sp.p_base_freq = 0.5 + SoundUtilities.frnd(0.5);
        sp.p_freq_limit = sp.p_base_freq - 0.2 - SoundUtilities.frnd(0.6);
        if (sp.p_freq_limit < 0.2) sp.p_freq_limit = 0.2;
        sp.p_freq_ramp = -0.15 - SoundUtilities.frnd(0.2);
      }
      if (sp.waveShape == Generator.SAWTOOTH)
        sp.p_duty = 1.0;
      if (SoundUtilities.yes) {
        sp.p_duty = SoundUtilities.frnd(0.5);
        sp.p_duty_ramp = SoundUtilities.frnd(0.2);
      } else {
        sp.p_duty = 0.4 + SoundUtilities.frnd(0.5);
        sp.p_duty_ramp = -SoundUtilities.frnd(0.7);
      }
      sp.attack = 0.0;
      sp.sustain = 0.1 + SoundUtilities.frnd(0.2);
      sp.decay = SoundUtilities.frnd(0.4);
      if (SoundUtilities.yes)
        sp.punch = SoundUtilities.frnd(0.3);
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.p_pha_offset = SoundUtilities.frnd(0.2);
        sp.p_pha_ramp = -SoundUtilities.frnd(0.2);
      }
  
      sp.p_hpf_freq = SoundUtilities.frnd(0.3);
      return sp;
    }
    
    return null;
  }
  
  factory InternalView.asExplosion([int noiseType = Generator.NOISE]) {
    InternalView sp = new InternalView();
    
    if (sp.init()) {
      sp.waveShape = noiseType;
      if (SoundUtilities.yes) {
        sp.p_base_freq = SoundUtilities.sqr(0.1 + SoundUtilities.frnd(0.4));
        sp.p_freq_ramp = -0.1 + SoundUtilities.frnd(0.4);
      } else {
        sp.p_base_freq = SoundUtilities.sqr(0.2 + SoundUtilities.frnd(0.7));
        sp.p_freq_ramp = -0.2 - SoundUtilities.frnd(0.2);
      }
      if (SoundUtilities.rnd(4.0) == 0)
        sp.p_freq_ramp = 0.0;
      if (SoundUtilities.rnd(2.0) == 0)
        sp.p_repeat_speed = 0.3 + SoundUtilities.frnd(0.5);
      sp.attack = 0.0;
      sp.sustain = 0.1 + SoundUtilities.frnd(0.3);
      sp.decay = SoundUtilities.frnd(0.5);
      if (SoundUtilities.yes) {
        sp.p_pha_offset = -0.3 + SoundUtilities.frnd(0.9);
        sp.p_pha_ramp = -SoundUtilities.frnd(0.3);
      }
      sp.punch = 0.2 + SoundUtilities.frnd(0.6);
      if (SoundUtilities.yes) {
        sp.p_vib_strength = SoundUtilities.frnd(0.7);
        sp.p_vib_speed = SoundUtilities.frnd(0.6);
      }
      if (SoundUtilities.rnd(2.0) == 0) {
        sp.p_arp_speed = 0.6 + SoundUtilities.frnd(0.3);
        sp.p_arp_mod = 0.8 - SoundUtilities.frnd(1.6);
      }
      return sp;
    }
    
    return null;
  }
  
  factory InternalView.asPowerUp() {
    InternalView sp = new InternalView();
    
    if (sp.init()) {
      if (SoundUtilities.yes) {
        sp.waveShape = Generator.SAWTOOTH;
        sp.p_duty = 1.0;
      } else {
        sp.p_duty = SoundUtilities.frnd(0.6);
      }
      sp.p_base_freq = 0.2 + SoundUtilities.frnd(0.3);
      if (SoundUtilities.yes) {
        sp.p_freq_ramp = 0.1 + SoundUtilities.frnd(0.4);
        sp.p_repeat_speed = 0.4 + SoundUtilities.frnd(0.4);
      } else {
        sp.p_freq_ramp = 0.05 + SoundUtilities.frnd(0.2);
        if (SoundUtilities.yes) {
          sp.p_vib_strength = SoundUtilities.frnd(0.7);
          sp.p_vib_speed = SoundUtilities.frnd(0.6);
        }
      }
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.4);
      sp.decay = 0.1 + SoundUtilities.frnd(0.4);
      
      return sp;
    }
    
    return null;
  }

  factory InternalView.asHitHurt() {
    InternalView sp = new InternalView();

    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(2.0);
      if (sp.waveShape == Generator.SINE)
        sp.waveShape = Generator.NOISE;
      if (sp.waveShape == Generator.SQUARE)
        sp.p_duty = SoundUtilities.frnd(0.6);
      if (sp.waveShape == Generator.SAWTOOTH)
        sp.p_duty = 1.0;
      sp.p_base_freq = 0.2 + SoundUtilities.frnd(0.6);
      sp.p_freq_ramp = -0.3 - SoundUtilities.frnd(0.4);
      sp.attack = 0.0;
      sp.sustain = SoundUtilities.frnd(0.1);
      sp.decay = 0.1 + SoundUtilities.frnd(0.2);
      if (SoundUtilities.yes)
        sp.p_hpf_freq = SoundUtilities.frnd(0.3);
      
      return sp;
    }
    
    return null;
  }

  factory InternalView.asJump() {
    InternalView sp = new InternalView();

    if (sp.init()) {
      sp.waveShape = Generator.SQUARE;
      sp.p_duty = SoundUtilities.frnd(0.6);
      sp.p_base_freq = 0.3 + SoundUtilities.frnd(0.3);
      sp.p_freq_ramp = 0.1 + SoundUtilities.frnd(0.2);
      sp.attack = 0.0;
      sp.sustain = 0.1 + SoundUtilities.frnd(0.3);
      sp.decay = 0.1 + SoundUtilities.frnd(0.2);
      if (SoundUtilities.yes)
        sp.p_hpf_freq = SoundUtilities.frnd(0.3);
      if (SoundUtilities.yes)
        sp.p_lpf_freq = 1 - SoundUtilities.frnd(0.6);
      
      return sp;
    }
    
    return null;
  }

  factory InternalView.asBlipSelect() {
    InternalView sp = new InternalView();

    if (sp.init()) {
      sp.waveShape = SoundUtilities.rnd(1.0);
      if (sp.waveShape == Generator.SQUARE)
        sp.p_duty = SoundUtilities.frnd(0.6);
      else
        sp.p_duty = 1.0;
      sp.p_base_freq = 0.2 + SoundUtilities.frnd(0.4);
      sp.attack = 0.0;
      sp.sustain = 0.1 + SoundUtilities.frnd(0.1);
      sp.decay = SoundUtilities.frnd(0.2);
      sp.p_hpf_freq = 0.1;
      
      return sp;
    }
    
    return null;
  }

  factory InternalView.asRandom() {
    InternalView sp = new InternalView();

    if (sp.init()) {
      if (SoundUtilities.yes)
        sp.p_base_freq = SoundUtilities.cube(SoundUtilities.frnd(2.0) - 1) + 0.5;
      else
        sp.p_base_freq = SoundUtilities.sqr(SoundUtilities.frnd(1.0));
      sp.p_freq_limit = 0.0;
      sp.p_freq_ramp = math.pow(SoundUtilities.frnd(2.0) - 1, 5);
      if (sp.p_base_freq > 0.7 && sp.p_freq_ramp > 0.2)
        sp.p_freq_ramp = -sp.p_freq_ramp;
      if (sp.p_base_freq < 0.2 && sp.p_freq_ramp < -0.05)
        sp.p_freq_ramp = -sp.p_freq_ramp;
      sp.p_freq_dramp = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      sp.p_duty = SoundUtilities.frnd(2.0) - 1;
      sp.p_duty_ramp = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      sp.p_vib_strength = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      sp.p_vib_speed = SoundUtilities.rndr(-1.0, 1.0);
      sp.attack = SoundUtilities.cube(SoundUtilities.rndr(-1.0, 1.0));
      sp.sustain = SoundUtilities.sqr(SoundUtilities.rndr(-1.0, 1.0));
      sp.decay = SoundUtilities.rndr(-1.0, 1.0);
      sp.punch = math.pow(SoundUtilities.frnd(0.8), 2);
      if (sp.attack + sp.sustain + sp.decay < 0.2) {
        sp.sustain += 0.2 + SoundUtilities.frnd(0.3);
        sp.decay += 0.2 + SoundUtilities.frnd(0.3);
      }
      sp.p_lpf_resonance = SoundUtilities.rndr(-1.0, 1.0);
      sp.p_lpf_freq = 1 - math.pow(SoundUtilities.frnd(1.0), 3);
      sp.p_lpf_ramp = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      if (sp.p_lpf_freq < 0.1 && sp.p_lpf_ramp < -0.05)
        sp.p_lpf_ramp = -sp.p_lpf_ramp;
      sp.p_hpf_freq = math.pow(SoundUtilities.frnd(1.0), 5);
      sp.p_hpf_ramp = math.pow(SoundUtilities.frnd(2.0) - 1, 5);
      sp.p_pha_offset = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      sp.p_pha_ramp = math.pow(SoundUtilities.frnd(2.0) - 1, 3);
      sp.p_repeat_speed = SoundUtilities.frnd(2.0) - 1;
      sp.p_arp_speed = SoundUtilities.frnd(2.0) - 1;
      sp.p_arp_mod = SoundUtilities.frnd(2.0) - 1;
      
      return sp;
    }
    
    return null;
  }

  factory InternalView.asTone([int waveShape = Generator.SINE]) {
    InternalView sp = new InternalView();

    if (sp.init()) {
      sp.sound_vol = Generator.SOUND_VOLUME;
      sp.sampleRate = Generator.SAMPLE_RATE;
      sp.sampleSize = Generator.SAMPLE_SIZE;
      
      sp.waveShape = waveShape;
      sp.p_base_freq = 0.35173364; // 440 Hz
      sp.attack = 0.0;
      sp.sustain = 0.6641; // 1 sec
      sp.decay = 0.0;
      sp.punch = 0.0;
      return sp;
    }
    
    return null;
  }
  
  void setToDefault() {
    waveShape = Generator.SQUARE;

    // Envelope
    attack = 0.0;
    sustain = 0.3;
    punch = 0.0;
    decay = 0.4;

    // Tone
    p_base_freq = 0.3;    // Start frequency
    p_freq_limit = 0.0;   // Min frequency cutoff
    p_freq_ramp = 0.0;    // Slide (SIGNED)
    p_freq_dramp = 0.0;   // Delta slide (SIGNED)
    
    // Vibrato
    p_vib_strength = 0.0; // Vibrato depth
    p_vib_speed = 0.0;    // Vibrato speed
    p_vib_delay = 0.0;
    
    // Tonal change
    p_arp_mod = 0.0;      // Change amount (SIGNED)
    p_arp_speed = 0.0;    // Change speed

    // Square wave duty (proportion of time signal is high vs. low)
    p_duty = 0.0;         // Square duty
    p_duty_ramp = 0.0;    // Duty sweep (SIGNED)

    // Repeat
    p_repeat_speed = 0.0; // Repeat speed

    // Flanger
    p_pha_offset = 0.0;   // Flanger offset (SIGNED)
    p_pha_ramp = 0.0;     // Flanger sweep (SIGNED)

    // Low-pass filter
    p_lpf_freq = 1.0;     // Low-pass filter cutoff
    p_lpf_ramp = 0.0;     // Low-pass filter cutoff sweep (SIGNED)
    p_lpf_resonance = 0.0;// Low-pass filter resonance
    // High-pass filter
    p_hpf_freq = 0.0;     // High-pass filter cutoff
    p_hpf_ramp = 0.0;     // High-pass filter cutoff sweep (SIGNED)

    // Sample parameters
    sound_vol = 0.25;
    sampleRate = 44100;
    sampleSize = 8;
  }
  
  void setForRepeat(Generator sg) {
    super.setForRepeat(sg);
    
    sg.waveShape = waveShape;
    sg.elapsedSinceRepeat = 0.0;
    
    sg.period = 100.0 / (p_base_freq * p_base_freq + 0.001);
    sg.periodMax = 100.0 / (p_freq_limit * p_freq_limit + 0.001);
    sg.enableFrequencyCutoff = (p_freq_limit > 0.0);
    sg.periodMult = 1 - math.pow(p_freq_ramp, 3.0) * 0.01;
    sg.periodMultSlide = -math.pow(p_freq_dramp, 3.0) * 0.000001;

    sg.dutyCycle = 0.5 - p_duty * 0.5;
    sg.dutyCycleSlide = -p_duty_ramp * 0.00005;

    if (p_arp_mod >= 0.0)
      sg.arpeggioMultiplier = 1.0 - math.pow(p_arp_mod, 2.0) * 0.9;
    else
      sg.arpeggioMultiplier = 1.0 + math.pow(p_arp_mod, 2.0) * 10.0;
    
    sg.arpeggioTime = (math.pow(1.0 - p_arp_speed, 2.0) * 20000.0 + 32.0).floor();
    if (p_arp_speed == 1.0)
      sg.arpeggioTime = 0;
    
    // Vibrato
    sg.vibratoSpeed = math.pow(p_vib_speed, 2.0) * 0.01;
    sg.vibratoAmplitude = p_vib_strength * 0.5;

    // Repeat
    sg.repeatTime = (math.pow(1.0 - p_repeat_speed, 2.0) * 20000.0).floor() + 32;
    if (p_repeat_speed == 0.0)
      sg.repeatTime = 0;
    
    sg.flangerOffset = math.pow(p_pha_offset, 2.0) * 1020.0;
    if (p_pha_offset < 0.0) sg.flangerOffset = -sg.flangerOffset;
    sg.flangerOffsetSlide = math.pow(p_pha_ramp, 2.0) * 1.0;
    if (p_pha_ramp < 0.0) sg.flangerOffsetSlide = -sg.flangerOffsetSlide;

    // Filter
    sg.fltw = math.pow(p_lpf_freq, 3.0) * 0.1;
    sg.enableLowPassFilter = (p_lpf_freq != 1.0);
    sg.fltw_d = 1.0 + p_lpf_ramp * 0.0001;
    sg.fltdmp = 5.0 / (1.0 + math.pow(p_lpf_resonance, 2.0) * 20.0) * (0.01 + sg.fltw);
    if (sg.fltdmp > 0.8)
      sg.fltdmp = 0.8;
    
    sg.flthp = math.pow(p_hpf_freq, 2.0) * 0.1;
    sg.flthp_d = 1.0 + p_hpf_ramp * 0.0003;

  }

  void mutate() {
    if (SoundUtilities.yes) p_base_freq += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_freq_ramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_freq_dramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_duty += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_duty_ramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_vib_strength += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_vib_speed += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_vib_delay += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) attack += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) sustain += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) decay += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) punch += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_lpf_resonance += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_lpf_freq += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_lpf_ramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_hpf_freq += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_hpf_ramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_pha_offset += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_pha_ramp += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_repeat_speed += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_arp_speed += SoundUtilities.frnd(0.1) - 0.05;
    if (SoundUtilities.yes) p_arp_mod += SoundUtilities.frnd(0.1) - 0.05;
  }
}
