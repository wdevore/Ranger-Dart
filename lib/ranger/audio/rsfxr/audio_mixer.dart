part of ranger;

class AudioMixer {
  AudioContext _context;

  static const int MAX_CHANNELS = 10;
  
  List<WASfxr> _effects = new List<WASfxr>(MAX_CHANNELS);

  GainNode _mixer;
  
  int activeChannel = 0;
  WASfxr effect;
  
  String name = "None";
  
  AudioMixer();

  factory AudioMixer.basic(AudioContext context) {
    AudioMixer s = new AudioMixer();
    s._context = context;
    
    if (s.init())
      return s;
    
    return null;
  }

  bool init() {
    _mixer = _context.createGain();
    gain = 1.0;
    
    _mixer.connectNode(_context.destination);

    return true;
  }
  
  Iterable<WASfxr> get channels => _effects.where((WASfxr wa) => wa != null && wa.enabled);
  int get enabledChannels => channels.length;
  
  set gain(double g) => _mixer.gain.value = g;
  double get gain => _mixer.gain.value;
  
  set setEffectName(String name) {
    effect.name = name;
  }
  
  void channelsCallback(int index, String action, bool enabled, bool active, double gain, double delay) {
    if (action == "ActiveChecked") {
      selectChannel(index);
      effect.trigger(_context.currentTime);
      return;
    }

    if (action == "EnableChecked") {
      if (_effects[index] == null)
        _buildChannel(index);
      
      WASfxr effect = _effects[index];
      effect.enabled = enabled;
      
      // The GainNode is additive so we scale by the total effects active.
      int chans = enabledChannels;
      if (chans > 0)
        _mixer.gain.value = 1.0 - ((chans - 1) / 10.0);
      else
        _mixer.gain.value = 1.0;
      
      trigger();
      return;
    }
    
    if (action == "GainChange") {
      WASfxr wa = _effects[index];
      wa.gain = gain;
      wa.trigger(_context.currentTime);
      return;
    }

    if (action == "DelayChange") {
      WASfxr wa = _effects[index];
      wa.channelDelay.delayTime.value = delay;
      wa.trigger(_context.currentTime);
      return;
    }
  }

  double getChannelGain(int index) => _effects[index].gain;
  void setChannelGain(int index, double g) {
    _effects[index].gain = g;
  }
  
  double getChannelDelay(int index) => _effects[index].channelDelay.delayTime.value;
  void setChannelDelay(int index, double t) {
    _effects[index].channelDelay.delayTime.value = t;
  }
  
  bool getEnableChannel(int index) => _effects[index].enabled;
  void enableChannel(int index, bool b) {
    _effects[index].enabled = b;
  }
  
  void _buildChannel(int index) {
    WASfxr wa = new WASfxr.basic(_context);
    _effects[index] = wa;
    wa.output.connectNode(_mixer);
  }
  
  void selectChannel(int index) {
    if (_effects[index] == null) {
      _buildChannel(index);
    }
    effect = _effects[index];
  }
  
  void trigger() {
    double now = _context.currentTime;
    channels.forEach((WASfxr ef) => ef.trigger(now));   
  }
  
  void configureWithJSON(Map m) {
    print("Loading...");
    if (m["Format"] == null) {
      print("Format value not found. Nothing done.");
      return;
    }

    String format = m["Format"] as String;
    if (format != "RSfxr") {
      print("Format $format not recognized. Nothing done.");
      return;
    }

    channels.forEach((WASfxr ef) => ef.output.disconnect(0));   

    for(int i = 0; i < MAX_CHANNELS; i++)
      _effects[i] = null;
    
    name = m["Name"] as String;

    List chans = m["Channels"];

    for(int i = 0; i < chans.length; i++) {
      WASfxr wa = new WASfxr.basic(_context);
      Map channel = chans[i] as Map;
      wa.configureWithJSON(channel);
      _effects[i] = wa;
      wa.output.connectNode(_mixer);
    }

    _mixer.gain.value = 1.0 - ((chans.length - 1) / 10.0);

    selectChannel(0);
  }
  
  Map toMapAsSettings() {
    
    List<Map> chans = new List<Map>();

    channels.forEach((WASfxr ef) => chans.add(ef.toMapAsSettings()));   
    
    Map m = {
      "Format": "RSfxr",
      "Name": name,
      "Channels": chans
    };
    
    return m;
  }
}