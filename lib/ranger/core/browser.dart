part of ranger;

class Browser {
  String userAgent;
  String platform;
  bool isMobile;
  String type = "unknown";
  
  void detect(Html.Navigator navigator) {
    userAgent = navigator.userAgent.toLowerCase();
    platform = navigator.platform.toLowerCase();
    
    isMobile = (userAgent.contains('mobile') || userAgent.contains('android'));
    
    RegExp exp = new RegExp(r"/micromessenger|qqbrowser|mqqbrowser|ucbrowser|360browser|baidubrowser|maxthon|ie|opera|firefox/");
    Iterable<Match> matches = exp.allMatches(userAgent);
    if (matches.length > 0) {
      Match m = matches.first;
      String t = m.group(0);
      if (t.contains("micromessenger"))
        type = "wechat";    // Chinese chat browser.
      else
        type = t;
    }
    else {
      exp = new RegExp(r"chrome|safari");
      matches = exp.allMatches(userAgent);
      if (matches.length > 0) {
        Match m = matches.first;
        type = m.group(0);
      }
    }
    
      
  }
}