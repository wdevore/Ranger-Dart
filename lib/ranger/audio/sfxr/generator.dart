part of ranger;

/**
 * Generates buffer values between -1.0, 1.0.
 */
class Generator {
  // Wave shapes
  static const int SQUARE = 0;
  static const int SAWTOOTH = 1;
  static const int SINE = 2;
  static const int NOISE = 3;  // White
  static const int NOISE_PINK = 4;  // Pink
  static const int NOISE_BROWNIAN = 5;  // Brownian/Red
  
  // Playback volume
  static const double MASTER_VOLUME = 1.0;
  static const double SOUND_VOLUME = 0.25;
  
  // Sampling
  static const int SAMPLE_RATE = 44100;
  static const int SAMPLE_SIZE = 8;
  static const int OVERSAMPLING = 8;

  // Envelope
  static const int ENVELOPE_ATTACK = 0;
  static const int ENVELOPE_SUSTAIN = 1;
  static const int ENVELOPE_DECAY = 2;
  static const int ENVELOPE_RELEASE = 3;

  double elapsedSinceRepeat;

  double period;
  double periodMax;
  bool enableFrequencyCutoff;
  double periodMult;
  double periodMultSlide;

  double dutyCycle;
  double dutyCycleSlide;

  double arpeggioMultiplier;
  int arpeggioTime;

  int _waveShape;
  int prevWaveShape;
  
  // Filter
  double fltw;
  bool enableLowPassFilter;
  double fltw_d;
  double fltdmp;
  double flthp;
  double flthp_d;

  // Vibrato
  double vibratoSpeed;
  double vibratoAmplitude;

  // Envelope
  List<int> envelopeLength;

  double envelopePunch;

  // Flanger
  double flangerOffset;
  double flangerOffsetSlide;

  // Repeat
  int repeatTime;

  int sampleRate;
  int bitsPerChannel;

  ParamView parms;
  
  List<double> _samples = new List<double>();
  List<double> noise_buffer;

  Generator();
  
  factory Generator.withInternalView(InternalView iv) {
    Generator sg = new Generator();
    sg.parms = iv;
    iv.setForRepeat(sg);
    
    // Waveform shape
    sg._waveShape = iv.waveShape;

//    // Filter
//    sg.fltw = math.pow(iv.p_lpf_freq, 3.0) * 0.1;
//    sg.enableLowPassFilter = (iv.p_lpf_freq != 1.0);
//    sg.fltw_d = 1.0 + iv.p_lpf_ramp * 0.0001;
//    sg.fltdmp = 5.0 / (1.0 + math.pow(iv.p_lpf_resonance, 2.0) * 20.0) * (0.01 + sg.fltw);
//    if (sg.fltdmp > 0.8)
//      sg.fltdmp = 0.8;
//    sg.flthp = math.pow(iv.p_hpf_freq, 2.0) * 0.1;
//    sg.flthp_d = 1 + iv.p_hpf_ramp * 0.0003;

    //sg.gain = math.exp(iv.sound_vol) - 1.0;

    sg.sampleRate = iv.sampleRate;
    sg.bitsPerChannel = iv.sampleSize;
    
    return sg;
  }
  
  factory Generator.withExternalView(ExternalView ev) {
    Generator sg = new Generator();
    sg.parms = ev;
    ev.setForRepeat(sg);
    
    // Waveform shape
    sg._waveShape = ev.waveShape;

//    // Low pass filter
//    sg.fltw = ev.lowPassFrequency / (OVERSAMPLING * 44100.0 + ev.lowPassFrequency);
//    sg.enableLowPassFilter = ev.lowPassFrequency < 44100.0;
//    sg.fltw_d = math.pow(ev.lowPassSweep, 1.0/44100.0);
//    sg.fltdmp = (1.0 - ev.lowPassResonance) * 9.0 * (0.01 + sg.fltw);
//
//    // High pass filter
//    sg.flthp = ev.highPassFrequency / (OVERSAMPLING * 44100.0 + ev.highPassFrequency);
//    sg.flthp_d = math.pow(ev.highPassSweep, 1.0/44100.0);

//    // Flanger
//    sg.flangerOffset = ev.flangerOffset * 44100.0;
//    sg.flangerOffsetSlide = ev.flangerSweep;

    // Gain
    //sg.gain = math.sqrt(math.pow(10, ev.gain/10));

    sg.sampleRate = ev.sampleRate;
    sg.bitsPerChannel = ev.sampleSize;

    return sg;
  }
  
  List<double> get samples => _samples;
  
  int get waveShape => _waveShape;
  set waveShape(int shape) {
    prevWaveShape = _waveShape;
    _waveShape = shape;
  }
  
  List<double> _generateNoise(int noiseType) {
    const int NOISE_BUFFER_SIZE = 32;
    List<double> noise_buffer;
    
    switch (noiseType) {
      case NOISE:
        noise_buffer = new List<double>(NOISE_BUFFER_SIZE);
        // Noise between [-1.0, 1.0]
        for (int i = 0; i < NOISE_BUFFER_SIZE; ++i)
          noise_buffer[i] = SoundUtilities.randomDouble() * 2.0 - 1.0;
        break;
      case NOISE_PINK:
        double b0, b1, b2, b3, b4, b5, b6;
        b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
        noise_buffer = new List<double>(NOISE_BUFFER_SIZE);
        for (int i = 0; i < NOISE_BUFFER_SIZE; ++i) {
          double white = SoundUtilities.randomDouble() * 2.0 - 1.0;
          b0 = 0.99886 * b0 + white * 0.0555179;
          b1 = 0.99332 * b1 + white * 0.0750759;
          b2 = 0.96900 * b2 + white * 0.1538520;
          b3 = 0.86650 * b3 + white * 0.3104856;
          b4 = 0.55000 * b4 + white * 0.5329522;
          b5 = -0.7616 * b5 - white * 0.0168980;
          noise_buffer[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
          noise_buffer[i] *= 0.11; // (roughly) compensate for gain
          noise_buffer[i] = noise_buffer[i].clamp(-1.0, 1.0);
          b6 = white * 0.115926;
        }
        break;
      case NOISE_BROWNIAN:
        double lastOut = 0.0;
        noise_buffer = new List<double>(NOISE_BUFFER_SIZE);
        for (int i = 0; i < NOISE_BUFFER_SIZE; ++i) {
          double white = SoundUtilities.randomDouble() * 2.0 - 1.0;
          noise_buffer[i] = (lastOut + (0.02 * white)) / 1.02;
          lastOut = noise_buffer[i];
          noise_buffer[i] *= 3.5; // (roughly) compensate for gain
          noise_buffer[i] = noise_buffer[i].clamp(-1.0, 1.0);
        }
        break;
    }
    return noise_buffer;
  }
  
  /**
   * Generates samples in the range: [-1.0, 1.0]. This data is suitable
   * for WebAudio.
   * A quick way to hear the sound is to get the RIFF-[wave] version of
   * the samples and load into an [AudioElement].
   */
  void generate() {
    double filterPass = 0.0;
    double fltdp = 0.0;
    double filterPassHigh = 0.0;

    const int NOISE_BUFFER_SIZE = 32;
    const int FLANGER_BUFFER_SIZE = 1024;
    
    _samples.clear();
    
    if (_waveShape != prevWaveShape || noise_buffer == null) {
      if (_waveShape == NOISE || _waveShape == NOISE_PINK || _waveShape == NOISE_BROWNIAN)
        noise_buffer = _generateNoise(_waveShape);
      else {
        if (noise_buffer != null) {
          noise_buffer = null;
        }
      }
    }
    
    int envelopeStage = 0;
    int envelopeElapsed = 0;

    double vibratoPhase = 0.0;

    int phase = 0;
    int flangerIndex = 0;
    
    List<double> flanger_buffer = new List<double>(FLANGER_BUFFER_SIZE);
    flanger_buffer.fillRange(0, FLANGER_BUFFER_SIZE, 0.0);
    
    double sample_sum = 0.0;
    int num_summed = 0;
    int summands = (44100 / sampleRate).floor();

    for(int t = 0; ; ++t) {
      // Repeats
      if (repeatTime != 0 && ++elapsedSinceRepeat >= repeatTime)
        parms.setForRepeat(this);

      // Arpeggio (single)
      if(arpeggioTime != 0 && t >= arpeggioTime) {
        arpeggioTime = 0;
        period *= arpeggioMultiplier;
      }

      // Frequency slide, and frequency slide slide!
      periodMult += periodMultSlide;
      period *= periodMult;
      if (period > periodMax) {
        period = periodMax;
        if (enableFrequencyCutoff)
          break;
      }

      // Vibrato
      double rfperiod = period;
      if (vibratoAmplitude > 0.0) {
        vibratoPhase += vibratoSpeed;
        rfperiod = period * (1.0 + math.sin(vibratoPhase) * vibratoAmplitude);
      }
      
      int iPeriod = rfperiod.floor();
      if (iPeriod < OVERSAMPLING)
        iPeriod = OVERSAMPLING;

      // Square/Sawtooth wave duty cycle
      dutyCycle += dutyCycleSlide;
      dutyCycle = dutyCycle.clamp(0.0, 0.5);

      // Volume envelope
      if (++envelopeElapsed > envelopeLength[envelopeStage]) {
        envelopeElapsed = 0;
        if (++envelopeStage > ENVELOPE_DECAY)
          break;  // Hit Release stage
      }

      double envelopeVolume = 0.0;
      if (envelopeLength[envelopeStage] != 0)
        envelopeVolume = envelopeElapsed / envelopeLength[envelopeStage]; // Envelope Attack
      
      switch (envelopeStage) {
        case ENVELOPE_ATTACK:
          break;
        case ENVELOPE_SUSTAIN:
          envelopeVolume = 1.0 + (1.0 - envelopeVolume) * 2.0 * envelopePunch;
          break;
        case ENVELOPE_DECAY:
          envelopeVolume = 1.0 - envelopeVolume;
          break;
      }

      // Flanger step
      flangerOffset += flangerOffsetSlide;
      int iPhase = flangerOffset.floor().abs();
      if (iPhase > FLANGER_BUFFER_SIZE - 1) iPhase = FLANGER_BUFFER_SIZE - 1;

      if (flthp_d != 0) {
        flthp *= flthp_d;
        flthp = flthp.clamp(0.00001, 0.1);
      }

      // The final sample after oversampling.
      double sample = 0.0;
      
      // Use Oversampling to calculate the final sample
      for (int si = 0; si < OVERSAMPLING; ++si) {
        double sub_sample = 0.0;
        phase++;
        
        if (phase >= iPeriod) {
          phase %= iPeriod;
          if (_waveShape == NOISE)
            for(int i = 0; i < NOISE_BUFFER_SIZE; ++i)
              noise_buffer[i] = SoundUtilities.randomDouble() * 2.0 - 1.0;
        }

        // Base waveform
        double fp = phase / iPeriod;
        switch(_waveShape) {
          case SQUARE:
            if (fp < dutyCycle)
              sub_sample = 0.5;
            else
              sub_sample = -0.5;
            break;
          case SAWTOOTH:
            if (fp < dutyCycle)
              sub_sample = -1.0 + 2.0 * fp/dutyCycle;
            else
              sub_sample = 1.0 - 2.0 * (fp-dutyCycle)/(1-dutyCycle);
            break;
          case SINE:
            sub_sample = math.sin(fp * 2.0 * math.PI);
            break;
          case NOISE:
          case NOISE_PINK:
          case NOISE_BROWNIAN:
            sub_sample = noise_buffer[(phase * NOISE_BUFFER_SIZE ~/ iPeriod)];
            break;
          default:
            throw "ERROR: Bad wave type: $_waveShape";
            break;
        }
        
        // Low-pass filter
        double pp = filterPass;
        fltw *= fltw_d;
        fltw = fltw.clamp(0.0, 0.1);
        if (enableLowPassFilter) {
          fltdp += (sub_sample - filterPass) * fltw;
          fltdp -= fltdp * fltdmp;
        }
        else {
          filterPass = sub_sample;
          fltdp = 0.0;
        }
        filterPass += fltdp;

        // High-pass filter
        filterPassHigh += filterPass - pp;
        filterPassHigh -= filterPassHigh * flthp;
        sub_sample = filterPassHigh;

        // Flanger
        flanger_buffer[flangerIndex & (FLANGER_BUFFER_SIZE - 1)] = sub_sample;
        sub_sample += flanger_buffer[(flangerIndex - iPhase + FLANGER_BUFFER_SIZE) & (FLANGER_BUFFER_SIZE - 1)];
        flangerIndex = (flangerIndex + 1) & (FLANGER_BUFFER_SIZE - 1);

        // final accumulation and envelope application
        sample += (sub_sample * envelopeVolume);
      }

      // Accumulate sub-samples appropriately for sample rate
      sample_sum += sample;
      if (++num_summed >= summands) {
        num_summed = 0;
        sample = sample_sum / summands;
        sample_sum = 0.0;
      }
      else {
        continue;
      }

      // Reference O'Reilly's WebAudio book for Volume verses Gain.
      sample = sample / OVERSAMPLING;// * MASTER_VOLUME;
      //sample *= gain;
      
      _samples.add(sample);
    }
  }
 
  /**
   * Creates a RIFF-Wave object that you can load into an [AudioElement].
   * Note: You should only use this approach if you are creating some
   * sort of GUI. It is recommended that you load the samples into
   * WebAudio for normal use.
   * 
   * To hear the sound simply load the RIFF-wave into an [AudioElement].
   *     SfxrGenerator sg = new SfxrGenerator.withInternalView(GameManager.instance.internalSoundParms);
   *     sg.generate();
   *     Wave wav = sg.wave;
   *     AudioElement audio = new AudioElement(wav.dataURI);
   *     audio.play();
   */
  Wave get wave {
    List<int> byteBuffer = new List<int>();
    int num_clipped = 0;
    int max16Bit = 1 << 15;

    // Convert samples from unit to integer-scaled.
    for(double sample in _samples) {
      if (bitsPerChannel == 8) {
        // Rescale [-1, 1) to [0, 256)
        int bSample = ((sample + 1.0) * 128.0).floor();
        if (bSample > 255) {
          bSample = 255;
          ++num_clipped;
        } else if (bSample < 0) {
          bSample = 0;
          ++num_clipped;
        }
        
        byteBuffer.add(bSample);
      }
      else {
        // Rescale [-1, 1) to [-32768, 32768)
        int bSample = (sample * max16Bit).floor();
        
        if (bSample >= max16Bit) {
          bSample = max16Bit - 1;
          ++num_clipped;
        } else if (bSample < -max16Bit) {
          bSample = -max16Bit;
          ++num_clipped;
        }
  
        byteBuffer.add(bSample & 0xFF); // lower
        byteBuffer.add((bSample >> 8) & 0xFF); // upper
      }
    }
    
    Wave wave = new Wave();
    wave.sampleRate = sampleRate;
    wave.bitsPerSample = bitsPerChannel;
    wave.create(byteBuffer);
    wave.clipping = num_clipped;
    
    return wave;
  }
  
}