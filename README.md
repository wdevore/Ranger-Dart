Ranger-Dart - v0.1.0
===========

##Contents:
- [About][1]
- [So what is Ranger today][2]
- [Getting started][3]

[1]:about
##About
**Ranger-Dart** (Ranger for short) is a game engine written in [Dart](https://www.dartlang.org/) and slightly modeled after an older version of [Cocos2d-js 1.x](http://www.cocos2d-x.org/products#cocos2dx-js).

Initially **Ranger**'s code base was structured similar to Cocos2d. However, after using Dart design patterns and libraries (aka Pubs) the code base diverged and has changed considerably. The only *concepts* remaining are Scenes, Layers and Scheduler.

[2]:where
###So what is Ranger today?
The current version of **Ranger** is a game engine centric around an HTML5-Canvas and a [Scene graph](http://en.wikipedia.org/wiki/Scene_graph). Rendering of the scene graph is currently rendered to a Context of type [CanvasRenderingContext2D](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D). In the future the [WebGLRenderingContext](https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext) will be supported.

[3]:started
###Getting started
Where to start? Easy, just follow these steps:

1. Download the [Dart SDK](https://www.dartlang.org/) and install it. If you are on a Mac then it is as easy as installing the .dmg.
2. Go to GitHub and download [Ranger-Dart](https://github.com/wdevore/Ranger-Dart). Then choose to either *Clone in Desktop* or *Download ZIP*. If choose the Zip option then uncompress it to a location of your choosing. You should now have a folder called "Ranger-Dart".
3. Launch the [Dart Editor](https://www.dartlang.org/tools/editor/) that came with the SDK.
4. In the editor navigate to the file menu and choose *Open Existing Folder*.
 * Navigate to the location of either the uncompressed Zip or
 * The local Git repository after you cloned.
5. Now that you have the project open you run one of the *Templates*
 * Navigate into the "level0" template folder located under:
```
    web/
        applications/
            templates/
                level0
```
6. Right-click on **level0.html** and choose *Run in Dartium*.

Once [Dartium](https://www.dartlang.org/tools/dartium/) (which comes with the SDK) has launched it will autmatically navigate to "http://localhost:8080/applications/templates/level0/level0.html" and start running. First you will see a splash scene for 3 seconds and then instanously transition to a GameLayer with dark blue text displaying "*Ranger GameLayer*" on a dark grey background.
![GameLayer](docs/template0_gamelayer.png)
7. Congratulations. You have successfully installed and ran **Ranger**!

examples, templates, unit tests.
applications

code layout
libraries used

Features
    xx
    xx
    xx
Docs section

Blog site.
Install/setup
Author section
License
Roadmap
    WebGL
    Color Cascading
Team and Contacts
Known issues
TODOs
Further reading
Showcases
Contributing
    rules ...
    
Source structure
```
src/                    - blab
    core/               - blab
```

[Page 2](docs/Page2.md)