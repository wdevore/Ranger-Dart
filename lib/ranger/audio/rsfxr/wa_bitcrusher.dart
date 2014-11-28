part of ranger;

/**
 * Warning: this is a script processor.
 * https://github.com/kevincennis/crusher/blob/master/crusher.js
 * https://github.com/jaz303/bitcrusher/blob/master/demo/bundle.js
 * http://webaudio.github.io/web-audio-api/#a-bitcrusher-node
 */
class WABitCrusher {
  AudioContext _context;
  
  ScriptProcessorNode _script;
  int bits;
  double reduction;
  int bufferSize = 2048;   // powers of 2
  
  WABitCrusher();
  
  factory WABitCrusher.basic(AudioContext ac) {
    WABitCrusher e = new WABitCrusher();
    if (e.init(ac)) {
      return e;
    }
    
    return null;
  }
  
  bool init(AudioContext ac) {
    _context = ac;
    
    _script = _context.createScriptProcessor(bufferSize, 1, 1);
    
//    _script.addEventListener("message", _onProcess);
    _script.setEventListener(_onProcess);
    return true;
  }
  
  AudioNode get input => _script;
  AudioNode get output => _script;

  void _onProcess(AudioProcessingEvent e) {
    // Perform bit crush algorithm
    AudioBuffer inp = e.inputBuffer;
    AudioBuffer out = e.outputBuffer;
    Float32List iL = inp.getChannelData(0);
    Float32List iR = inp.getChannelData(1);
    Float32List oL = out.getChannelData(0);
    Float32List oR = out.getChannelData(1);
    double step = math.pow(0.5, this.bits - 1);
    int len = inp.length;
    int sample = 0;
    double lastL = 0.0;
    double lastR = 0.0;
    int i = 0;
    for ( ; i < len; ++i ) {
      if ( (sample += this.reduction) >= 1 ) {
        sample--;
        lastL = (step * (iL[i] / step)).floor().toDouble();
        lastR = (step * (iR[i] / step)).floor().toDouble();
      }
      oL[i] = lastL;
      oR[i] = lastR;
    }
  }
  
  void reset() {
  }
  
}