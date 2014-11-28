part of ranger;

class WAArpeggio {
  static const int STEP_UP = 0;
  static const int STEP_DOWN = 1;
  static const int STEP_BOUNCE = 2;
  
  AudioContext _context;
  
  WAGenerator _generator;
  
  int notes = 0;
  int stepType = STEP_UP;
  double timeStep = 0.1;
  double stepSize = 200.0;
  double expoDecay = 0.0;
  
  WAArpeggio();
  
  factory WAArpeggio.basic(AudioContext ac) {
    WAArpeggio e = new WAArpeggio();
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
    stepType = STEP_UP;
    notes = 0;
    timeStep = 0.1;
    stepSize = 200.0;
    expoDecay = 0.0;
  }
  
  void update(double frequency, double now) {
    
    // Create N frequency steps.
    
    switch (stepType) {
      case STEP_UP:
        double fStep = frequency + stepSize;
        for (int i = 0; i < notes; i++) {
          _generator.setArpeggio(fStep, now + timeStep, expoDecay);
          fStep += stepSize;
          now += timeStep;
        }
        break;
      case STEP_DOWN:
        double fStep = frequency - stepSize;
        if (fStep < 0.0)
          fStep = 0.0;
        for (int i = 0; i < notes; i++) {
          _generator.setArpeggio(fStep, now + timeStep, expoDecay);
          fStep -= stepSize;
          if (fStep < 0.0)
            fStep = 0.0;
          now += timeStep;
        }
        break;
      case STEP_BOUNCE:
        double fStepUp = frequency + stepSize;
        double fStepDown = frequency - stepSize;
        if (fStepDown < 0.0)
          fStepDown = 0.0;
        for (int i = 0; i < notes; i++) {
          _generator.setArpeggio(fStepUp, now + timeStep, expoDecay);
          now += timeStep;
          _generator.setArpeggio(fStepDown, now + timeStep, expoDecay);
          now += timeStep;
        }
        break;
    }
  }
}