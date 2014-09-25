part of ranger;

class Logging {
  static void info(String msg) {
    if (CONFIG.debug_level == CONFIG.DEBUG_FULL)
      print("Info: $msg");
  }

  static void warning(String msg) {
    if (CONFIG.debug_level == CONFIG.DEBUG_BASIC || CONFIG.debug_level == CONFIG.DEBUG_FULL)
      print("Warning: $msg");
  }

  static void error(String msg) {
    if (CONFIG.debug_level != CONFIG.DEBUG_OFF)
      print("Error: $msg");
  }
}