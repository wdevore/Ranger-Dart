part of ranger;

/**
 * [AudioEffects] can load either Sfxr or RSfxr json maps.
 * Sfxr are buffered only. RSfxr can optionally be buffered depending on
 * performance.
 * 
 * When you load an effect your are given an [eID] in return. This id
 * is used to play the effect--so don't lose it.
 */
class AudioEffects {
  AudioContext _context;

  static int _sfxr_effectId = 0;
  static int _rsfxr_effectId = 10000;
  
  Map<int, AudioMixer> _rsfxr_effects;
  
  Sfxr _sfxr;
  Map<int, String> _sfxr_effects;
  
  AudioEffects();

  factory AudioEffects.basic(AudioContext context) {
    AudioEffects s = new AudioEffects();
    
    s._context = context;
    
    if (s.init())
      return s;
    
    return null;
  }

  bool init() {
    _sfxr = new Sfxr.basic(_context);

    return true;
  }

  AudioContext get context => _context;
  
  /**
   * Keep the returned integer as a key for later use when you want to
   * play the effect. The key is referred to as [eID].
   */
  int loadEffect(String json) {
    Map m = JSON.decode(json);
    int id;
    
    // -------------------------------------------------------------
    // Auto detect what type of effect the incoming json is.
    // -------------------------------------------------------------
    bool effectType = false;  // default to RSfxr
    
    if (m["Format"] == null) {
      throw new Exception("Format key missing.");
    }
    
    String format = m["Format"] as String;
    if (format != "RSfxr")
      effectType = true; // must be an Sfxr effect.
    
    if (effectType) {
      id = _sfxr_effectId++;
      _loadSfxr(id, m);
    }
    else {
      id = _rsfxr_effectId++;
      _loadRSfxr(id, m);
    }

    return id;
  }
  
  void _loadSfxr(int eID, Map m) {
    if (_sfxr_effects == null) {
      _sfxr_effects = new Map<int, String>();
    }
    
    //String name = m["Name"] as String;
    
    _sfxr.addEffect(m);
    
    _sfxr_effects[eID] = "Name$_sfxr_effectId";
  }
  
  void _loadRSfxr(int eID, Map m) {
    if (_rsfxr_effects == null)
      _rsfxr_effects = new Map<int, AudioMixer>();
      
    AudioMixer audioMixer = new AudioMixer.basic(context);
    audioMixer.configureWithJSON(m);
    
    _rsfxr_effects[eID] = audioMixer;
  }
  
  /**
   * [eID] is a key you obtained when you called [loadEffect].
   */
  void play(int eID) {
    if (eID >= 10000) {
      // Play RSfxr
      _rsfxr_effects[eID].trigger();
    }
    else {
      // Play Sfxr
      _sfxr.play(_sfxr_effects[eID]);
    }
  }
}