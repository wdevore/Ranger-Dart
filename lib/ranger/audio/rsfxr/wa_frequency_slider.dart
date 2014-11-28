part of ranger;

//    double currentTime = _context.currentTime;
//    generator.frequencyParam.cancelScheduledValues(currentTime);
//    generator.frequencyParam.setValueAtTime(frequency, currentTime);
//    
//    double rampTo = frequency + 1500.0;
//    generator.frequencyParam.exponentialRampToValueAtTime(rampTo, currentTime + 1.1);

class WAFrequencySlider {
  AudioContext _context;
  
  double frequencyCutoff = 0.0;
  double frequencySlide = 0.0;      // Slide
  double frequencyTime = 0.0;  // Slide^Slide
  
  WAGenerator _generator;
  
  WAFrequencySlider();
  
  factory WAFrequencySlider.basic(AudioContext ac) {
    WAFrequencySlider e = new WAFrequencySlider();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    return true;
  }
  
  set whatToControl(WAGenerator generator) => _generator = generator;
  
  void reset() {
    frequencyCutoff = 0.0;
    frequencySlide = 0.0;      // Slide
    frequencyTime = 0.0;  // Slide^Slide
  }
  
  void resetFreqSlide() {
    frequencySlide = 0.0;
  }
  
  void update(double frequency, double now) {
    // We want to ramp to a given frequency (aka Target = TF) relative to
    // the current frequency (F).
    // - We can change the acceleration towards the TF.
    // - TF can't be < 0
    // We use the current frequency as the center point. When then
    // calc a delta target frequency relative to the center freq.
    // 
    // The Slide control controls the direction and target frequency.
    // frequencySlide bar
    // <----------------- 0 ------------------->
    // -1.0              none              1.0
    //
    // The delta-slide control controls the acceleration towards TF.
    // <----------------- 0 ------------------->
    // -fast             none                fast
    if (frequency > frequencyCutoff && frequencySlide != 0.0) {
      double freqDelta = 0.0;
      double rampToFreq = 0.0;
      
      if (frequencySlide < 0.0) {
        freqDelta = frequency - (frequency * frequencySlide.abs());
        rampToFreq = 0.001 + freqDelta.clamp(0.0, 4000.0);
      }
      else {
        freqDelta = frequency + (4000.0 * frequencySlide.abs());
        rampToFreq = 0.001 + freqDelta.clamp(0.0, 4000.0);
        rampToFreq = math.pow(rampToFreq, 1.01);
      }
      
      double time = frequencyTime.abs();// * math.pow(frequencyTime.abs(), 1.2);
      //print("rampToFreq:$rampToFreq, frequencyTime: ${frequencyTime.abs()}, frequencySlide:${frequencySlide}, freqDelta:$freqDelta, time: $time");
      _generator.setSlide(rampToFreq, now + time);
//      _osc.frequency.exponentialRampToValueAtTime(rampToFreq, now + time);
//      _osc.frequency.linearRampToValueAtTime(rampToFreq, now + time);
    }
  }
  
  // This is just an experiment. It kind of drops the freq then raises forward.
//  void updateDoubleBack(double frequency, double now) {
//    if (frequency > frequencyCutoff && frequencySlide != 1.0) {
//      _osc.frequency.cancelScheduledValues(now);
//      _osc.frequency.setValueAtTime(frequency, now);
//      
//      // Slide delta centers around frequency
//      //  <------------- f ---------------->
//      //  0.0           time              3.0
//      double rampToR = frequency - (frequency * 0.3);
//      double rampTo = (frequency * (1.0 + math.pow(frequencySlide, 3))).abs();
//      //print("rampToR: $rampToR, rampTo:$rampTo");
//      // TODO add two ramps, one for reverse and another for forward.
//      _osc.frequency.linearRampToValueAtTime(rampToR, now + 0.25);
//      now += frequencyTime;
//      _osc.frequency.exponentialRampToValueAtTime(rampTo, now + frequencyTime);
//    }
//    else {
//      // TODO turn off gain instead to avoid popclicks.
////      _osc.frequency.cancelScheduledValues(now);
////      _osc.frequency.setValueAtTime(0.0, now);
//    }
//  }
}