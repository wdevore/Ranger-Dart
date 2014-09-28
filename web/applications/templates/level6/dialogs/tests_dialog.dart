part of template6;

typedef Function SelectCallback(String title);

/**
 * The dialog moves in from the right.
 * This class also shows how to implement a [Tweenable].
 * .---------------------------.
 * |                        X  |
 * .---------------------------.
 * |  I    text                |
 * |  I    text                |
 * |  I    text                |
 * |  I    text                |
 * |  I    text                |
 * .---------------------------.
 * 
 * Clicking the "X" icon will dismiss dialog to the right.
 * Sizing:
 * The dialog needs to determine if it can fit horizontally (preferred)
 * or vertically.
 */
class TestsDialog extends BaseModalDialog implements UTE.Tweenable {
  static const int X = 1;
  
  int _widthDelta;
  int _width;
  int _height;
  int _panelWidth;
  
  bool _built = false;
  bool _transitioning = false;

  SelectCallback _hideCallback;
  
  TestsDialog() {
  }
  
  TestsDialog.withHideCallback(SelectCallback hideCallback) {
    _hideCallback = hideCallback;
  }

  void init() {
  }
  
  // ----------------------------------------------------------------
  // Animation
  // ----------------------------------------------------------------
  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
    switch(tweenType) {
      case X:
        int pos = content.style.left.indexOf("p");
        returnValues[0] = double.parse(content.style.left.substring(0, pos));
        return 1;
    }
    
    return 0;
  }

  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
    switch(tweenType) {
      case X:
        content.style.left = "${newValues[0]}px";
        break;
    }
  }

  void _tweenCallbackHandler(int type, UTE.BaseTween source) {
    switch(type) {
      case UTE.TweenCallback.COMPLETE:
        _transitioning = false;
        if (!isShowing) {
          // The dialog has finished hiding off to the side. Now hide it
          // just in case the container is wider than the surface.
          // Note: if the container (aka browser) is wider there will be
          // a gap. The dialog lock horizontally based on the surface
          // edge not the container edge.
          content.style.visibility = "hidden";
        }
        break;
      //default:
        //print('DEFAULT CALLBACK CAUGHT ; type = ' + type.toString());
    }
  }
  
  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------
  void _build() {
    if (_built)
      return;
    
    HtmlElement surface = Ranger.Application.instance.surface;
    HtmlElement canvas = Ranger.Application.instance.canvas;

    int surfaceWidth = surface.clientWidth;
    int surfaceHeight = surface.clientHeight;
    int border = 3;
    int panelWidth = 350;
    
    DivElement titleBar = new DivElement();
    DivElement testsList = new DivElement();
    
    // If the canvas is narrower than the surface then we need to calc
    // the inset distance. This can occur on desktops where the browser
    // is sized larger than the design-view.
    int canvasInset = surfaceWidth - canvas.clientWidth;
    
    // Remove any old html.
    surface.nodes.remove(content);

    // We want the Div removed from the document flow.
    content.style.display = "block";
    content.style.position = "absolute";

    // "canvasInset ~/ 2.0" could be off by 1 pixel but that is okay because
    // it will still be off screen.
    content.style.left = "${(surfaceWidth - (canvasInset / 2.0)).floor()}px";

    // Note: The DIV's positioning is in HTML space which means the
    // coordinate system is right-handed (aka +Y axis is downward).
    int verticalPadding = ((surfaceHeight - (surfaceHeight * 0.95))) ~/ 2;
    content.style.top = "${verticalPadding}px";

    int panelHeight = surfaceHeight - (verticalPadding * 2.0).ceil();
    content.style.width = "${panelWidth}px";
    content.style.height = "${panelHeight}px";
    // Set the background color to a brownish pantone color.
    // http://damonbauer.github.io/Pantone-Sass/
    content.style.backgroundColor = Ranger.color4IFromHex("#4a3041").toString();
    content.style.borderLeft = "black solid ${border}px";

    content.style.overflowX = "hidden";
    
    surface.nodes.add(content);
    
    _panelWidth = panelWidth + border;
    
    int itemHeight = 40;
    
    _addPanelTitle(titleBar);
    titleBar.style.zIndex = "10";
    titleBar.style.position = "absolute";
    titleBar.style.top = "0px";
    titleBar.style.left = "0px";
    titleBar.style.width = "100%";
    titleBar.style.height = "${itemHeight}px";
    titleBar.style.backgroundColor = Ranger.color4IFromHex("#6d4f47").toString();
    titleBar.style.borderBottom = "black solid 3px";
    content.nodes.add(titleBar);
    
    _addItems(testsList);
    testsList.style.zIndex = "-10";
    testsList.style.top = "${itemHeight + 3}px";
    testsList.style.left = "0px";
    testsList.style.width = "100%";
    testsList.style.height = "100%";
    testsList.style.overflowY = "scroll";
    testsList.style.overflowX = "hidden";
    content.nodes.add(testsList);

    _built = true;
  }
  
  void _addPanelTitle(DivElement container) {
    SpanElement titleContent = new SpanElement();
    titleContent.style.fontFamily = "Verdana";
    titleContent.style.fontSize = "18pt";
    titleContent.style.color = Ranger.color4IFromHex("#f3cfb3").toString();
    titleContent.text = "Particle control";
    titleContent.style.width = "80%";
    titleContent.style.paddingLeft = "5%";
    titleContent.style.display = "inline-block";
    titleContent.style.position = "relative";
    container.nodes.add(titleContent);
    
    Resources resources = GameManager.instance.resources;
    resources.loadImage("resources/reply.svg", 32, 32, true).then(
    (ImageElement ime) {
      ImageElement panelDismissIcon = ime;
      panelDismissIcon.style.top = "5px";
      panelDismissIcon.style.display = "inline-block";
      panelDismissIcon.style.position = "relative";
      panelDismissIcon.onClick.listen(
        (Event e) => _cancel()
        );
      container.nodes.add(panelDismissIcon);
    });
  }
  
  void _addItems(DivElement container) {
    bool alternate = false;

    // Add a place holder to push the top item below the title bar.
    // TODO need a better way to do this.
    DivElement item = _makeItem(null, "", alternate);
    alternate = !alternate;
    container.nodes.add(item);

    item = _makeItem(null, "Pause/Resume", alternate);
    alternate = !alternate;
    container.nodes.add(item);

    item = _makeItem(null, "Sparkler", alternate);
    alternate = !alternate;
    container.nodes.add(item);

    item = _makeItem(null, "Hose", alternate);
    alternate = !alternate;
    container.nodes.add(item);

    item = _makeItem(null, "Thrust", alternate);
    alternate = !alternate;
    container.nodes.add(item);
  }
  
  DivElement _makeItem(ImageElement icon, String itemTitle, bool alternate) {
    DivElement title = new DivElement();
    title.style.width = "100%";
    title.style.height = "3em";
    title.style.paddingLeft = "5px";
    if (alternate)
      title.style.backgroundColor = Ranger.color4IFromHex("#dbc8b6").toString();
    else
      title.style.backgroundColor = Ranger.color4IFromHex("#d3bba8").toString();
     
    if (icon != null) {
      ImageElement testIcon = icon;//.clone(false);
      testIcon.style.top = "5px";
      testIcon.style.display = "inline-block";
      testIcon.style.position = "relative";
      title.nodes.add(testIcon);
    }
    
    SpanElement titleContent = new SpanElement();
    titleContent.style.fontFamily = "Verdana";
    titleContent.style.fontSize = "15pt";
    titleContent.style.color = Ranger.color4IFromHex("#222222").toString();
    titleContent.text = itemTitle;
    titleContent.style.width = "80%";
    titleContent.style.paddingLeft = "5%";
    titleContent.style.top = "10px";
    titleContent.style.display = "inline-block";
    titleContent.style.position = "relative";
    titleContent.onClick.listen(
      (Event e) => _doAction(itemTitle)
      );
    titleContent.onMouseEnter.listen(
        (Event e) =>  
            titleContent.style.color = Ranger.color4IFromHex("#dddddd").toString()
        );
    titleContent.onMouseLeave.listen(
        (Event e) =>  
            titleContent.style.color = Ranger.color4IFromHex("#222222").toString()
        );
    title.nodes.add(titleContent);

    return title;
  }
  
  _doAction(String test) {
    //hide();
    _hideCallback(test);
  }

  void _cancel() {
    hide();
    if (_hideCallback != null)
      _hideCallback("");
  }
  
  // ----------------------------------------------------------------
  // Show/Hide
  // ----------------------------------------------------------------
  void hide() {
    if (_transitioning)
      return;

    isShowing = false;

    Ranger.Application app = Ranger.Application.instance;
    
    UTE.Tween tw = new UTE.Tween.to(this, X, 0.25);
    tw..targetRelative = [_panelWidth.toDouble()]
      ..easing = UTE.Cubic.OUT
      ..callback = _tweenCallbackHandler
      ..callbackTriggers = UTE.TweenCallback.COMPLETE;
      app.animations.add(tw);

    _transitioning = true;
  }

  void show() {
    if (_transitioning)
      return;
    
    _build();
    content.style.visibility = "visible";

    Ranger.Application app = Ranger.Application.instance;

    UTE.Tween tw = new UTE.Tween.to(this, X, 0.5);
    tw..targetRelative = [-_panelWidth.toDouble()]
      ..easing = UTE.Cubic.OUT
      ..callback = _tweenCallbackHandler
      ..callbackTriggers = UTE.TweenCallback.COMPLETE;
      app.animations.add(tw);

    isShowing = true;
    _transitioning = true;
  }
  
}

