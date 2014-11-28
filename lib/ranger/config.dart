part of ranger;

/**
 * Most of these settings can be overridden by your
 * web/resources/config.json file. Ranger will read your config file
 * during start up.
 */
class CONFIG {
  /**
   * The current version of Ranger-dart being used.
   * Please DO NOT remove this String, it is an important flag for bug tracking.
   * If you post a bug to the forum, please attach this flag.
   */
  static const String ENGINE_NAME = "Ranger-Dart";
  static const String ENGINE_VERSION = "0.9.5";
  
  static const String CONFIG_OVERRIDE_FILE = r"resources/config.json";
  
  /**
   *  If enabled, the texture coordinates will be calculated by using this formula: 
   *      - texCoord.left = (rect.origin.x*2+1) / (texture.wide*2);
   *      - texCoord.right = texCoord.left + (rect.size.width*2-2)/(texture.wide*2);
   *
   *  The same for bottom and top.                                                   
   *
   *  This formula prevents artifacts by using 99% of the texture.                   
   *  The "correct" way to prevent artifacts is by using the spritesheet-artifact-fixer.py or a similar tool.
   *
   *  Affected nodes:                                                                 
   *      - Sprite / SpriteBatchNode and subclasses: LabelBMFont, TMXTiledMap
   *      - LabelAtlas
   *      - QuadParticleSystem
   *      - TileMap
   *
   *  To enabled set it to 1. Disabled by default.
   */
  static const int FIX_ARTIFACTS_BY_STRECHING_TEXEL = 0;

  /**
   *   Seconds between FPS updates.
   *   0.5 seconds, means that the FPS number will be updated every 0.5 seconds.
   *   Having a bigger number means a more reliable FPS
   *
   *   Default value: 1.0f
   */
  static const double DIRECTOR_FPS_INTERVAL = 1.0;

  /**
   *    If enabled, the Node objects (Sprite, Label,etc) will be rendered in subpixels.
   *    If disabled, integer pixels will be used.
   *    
   *    To enable set it to 1. Enabled by default.
   */
  static const int NODE_RENDER_SUBPIXEL = 1;

  /**
   *   If enabled, the Sprite objects rendered with SpriteBatchNode will be able to render in subpixels.
   *   If disabled, integer pixels will be used.
   *   
   *   To enable set it to 1. Enabled by default.
   */
  static const int SPRITEBATCHNODE_RENDER_SUBPIXEL = 1;

  /**
   *   If most of your imamges have pre-multiplied alpha, set it to 1 (if you are going to use .PNG/.JPG file images).
   *   Only set to 0 if ALL your images by-pass Apple UIImage loading system (eg: if you use libpng or PVR images)
   *     
   *   To enable set it to a value different than 0. Enabled by default.
   */
  static const int OPTIMIZE_BLEND_FUNC_FOR_PREMULTIPLIED_ALPHA = 0;

  /**
   *   Use GL_TRIANGLE_STRIP instead of GL_TRIANGLES when rendering the texture atlas.
   *   It seems it is the recommend way, but it is much slower, so, enable it at your own risk
   *   
   *   To enable set it to a value different than 0. Disabled by default.
   */
  static const int TEXTURE_ATLAS_USE_TRIANGLE_STRIP = 0;

  /**
   *    By default, TextureAtlas (used by many classes) will use VAO (Vertex Array Objects).
   *    Apple recommends its usage but they might consume a lot of memory, specially if you use many of them.
   *    So for certain cases, where you might need hundreds of VAO objects, it might be a good idea to disable it.
   *    
   *    To disable it set it to 0. disable by default.(Not Supported on WebGL)
   */
  static const int TEXTURE_ATLAS_USE_VAO = 0;

  /**
   *  If enabled, NPOT textures will be used where available. Only 3rd gen (and newer) devices support NPOT textures.
   *  NPOT textures have the following limitations:
   *     - They can't have mipmaps
   *     - They only accept GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}
   *  
   *  To enable set it to a value different than 0. Disabled by default. 
   *  
   *  This value governs only the PNG, GIF, BMP, images.
   *  This value DOES NOT govern the PVR (PVR.GZ, PVR.CCZ) files. If NPOT PVR is loaded, then it will create an NPOT texture ignoring this value.
   * 
   * @deprecated This value will be removed in 1.1 and NPOT textures will be loaded by default if the device supports it.
   */
  static const int TEXTURE_NPOT_SUPPORT = 0;

  /** 
   *    If enabled, supports retina display.
   *    For performance reasons, it's recommended disable it in games without retina display support, like iPad only games.
   *    
   *    To enable set it to 1. Use 0 to disable it. Enabled by default.
   *    
   *    This value governs only the PNG, GIF, BMP, images.
   *    This value DOES NOT govern the PVR (PVR.GZ, PVR.CCZ) files. If NPOT PVR is loaded, then it will create an NPOT texture ignoring this value.
   * 
   * @deprecated This value will be removed in 1.1 and NPOT textures will be loaded by default if the device supports it.
   */
  static const int RETINA_DISPLAY_SUPPORT = 1;

  /**
   *    It's the suffix that will be appended to the files in order to load "retina display" images.
   *    
   *    On an iPhone4 with Retina Display support enabled, the file @"sprite-hd.png" will be loaded instead of r"sprite.png".
   *    If the file doesn't exist it will use the non-retina display image.
   *    
   *    Platforms: Only used on Retina Display devices like iPhone 4S.
   */
  static const String RETINA_DISPLAY_FILENAME_SUFFIX = "-hd";

  /**
   *    If enabled, it will use LA88 (Luminance Alpha 16-bit textures) for LabelTTF objects. 
   *    If it is disabled, it will use A8 (Alpha 8-bit textures).                              
   *    LA88 textures are 6% faster than A8 textures, but they will consume 2x memory.         
   *                                                                                            
   *    This feature is enabled by default.
   */
  static const int USE_LA88_LABELS = 1;

  /**
   *   If enabled, all subclasses of Sprite will draw a bounding box
   *   Useful for debugging purposes only. It is recommened to leave it disabled.
   *   
   *   To enable set it to a value different than 0. Disabled by default:
   *      0 -- disabled
   *      1 -- draw bounding box
   *      2 -- draw texture box
   */
  static const int SPRITE_DEBUG_DRAW = 0;

  /**
   *    If enabled, all subclasses of Sprite that are rendered using an SpriteBatchNode draw a bounding box.
   *    Useful for debugging purposes only. It is recommened to leave it disabled.
   *    
   *    To enable set it to a value different than 0. Disabled by default.
   */
  static const int SPRITEBATCHNODE_DEBUG_DRAW = 0;

  /**
   *   If enabled, all subclasses of LabelBMFont will draw a bounding box 
   *   Useful for debugging purposes only. It is recommened to leave it disabled.
   *   
   *   To enable set it to a value different than 0. Disabled by default.
   */
  static const int LABELBMFONT_DEBUG_DRAW = 0;

  /**
   *    If enabled, all subclasses of LabeltAtlas will draw a bounding box
   *    Useful for debugging purposes only. It is recommened to leave it disabled.
   *    
   *    To enable set it to a value different than 0. Disabled by default.
   */
  static const int LABELATLAS_DEBUG_DRAW = 0;

  /**
   * whether or not support retina display
   */
  static const int IS_RETINA_DISPLAY_SUPPORTED = 1;

  /**
   * default engine
   */
  static String DEFAULT_ENGINE = ENGINE_VERSION + r"-canvas";

  /**
   *    If enabled, actions that alter the position property
   *    (eg: MoveBy, JumpBy, BezierBy, etc..) will be stacked.                  
   *    If you run 2 or more 'position' actions at the same time on a 
   *    node, then the end position will be the sum of all the positions.        
   *    If disabled, only the last run action will take effect.
   */
  static const bool ENABLE_STACKABLE_ANIMATIONS = true;

  /**
   * If enabled, Ranger will maintain an OpenGL state cache internally to avoid unnecessary switches.                                     
   * In order to use them, you have to use the following functions, insead of the the GL ones:                                             
   *        - GLUseProgram() instead of glUseProgram()                                                                                      
   *        - GLDeleteProgram() instead of glDeleteProgram()                                                                                
   *        - GLBlendFunc() instead of glBlendFunc()                                                                                        
   *                                                                                                                                            
   * If this functionality is disabled, then GLUseProgram(), 
   * GLDeleteProgram(), GLBlendFunc() will call the GL ones, without
   * using the cache.              
   * It is recommened to enable whenever possible to improve speed.                                                                        
   * If you are migrating your code from GL ES 1.1, then keep it disabled. Once all your code works as expected, turn it on.
   */
  static const int ENABLE_GL_STATE_CACHE = 1;

  static const int DEBUG_OFF = 0;
  static const int DEBUG_BASIC = 1;
  static const int DEBUG_FULL = 2;

  static const int RENDERMODE_DEFAULT = 0;
  static const int RENDERMODE_CANVAS_ONLY = 1;
  static const int RENDERMODE_WEBGL_ONLY = 2;
  
  /**
   * Position of the FPS (Default: 0,0 (bottom-left corner)) for WebGL
   */
  static Html.Point DIRECTOR_STATS_POSITION = new Html.Point(0.0, 0.0);
  
  static int debug_level = DEBUG_FULL;
  
  static bool box2d = false;
  static bool showFPS = true;
  
  static int frameRate = 60;
  
  static const int renderMode = RENDERMODE_CANVAS_ONLY;
  
  /// The dom element to run Ranger on
  static String surfaceTag = 'gameSurface';

  // Canvas2D and WebGL color formats differ considerably.
  // This one is formatted for Canvas2D. 
  //static const surfaceBackgroundColor = "rgba(0, 0, 0, 1.0)";
  
  static const bool LEFT_HANDED_COORDSYSTEM = true;
  static const bool RIGHT_HANDED_COORDSYSTEM = false;
  /**
   * Is the base coordinate system either left or right handed.
   * Note: Rotation changes between systems.
   * If "true" then angles specified with positive values cause
   * Counter Clockwise (CCW) rotations.
   * If "false" then angles specified with negative values cause
   * Clockwise (CW) rotations.
   * 
   * 0,0--------------> X
   * |
   * |
   * |  [_flipped] = false
   * |  positive rotations are CW
   * |  negative rotations are CCW
   * | 
   * v Y
   * 
   *    
   * ^ Y
   * |
   * | positive rotations are CCW
   * | negative rotations are CW
   * | [_flipped] = true      <-- default
   * |
   * |
   * 0,0--------------> X
   * 
   */
  static const bool base_coordinate_system = LEFT_HANDED_COORDSYSTEM;
  
}
