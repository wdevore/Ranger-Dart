Ranger-Dart - v0.1.0
![Logo](docs/RangerDart_logo.png)
===========

##Contents:
- [About](#about-dart)
- [Screen shots](#shots)
- [Features](#features)
- [Getting started](#getting-started)
- [Templates, Applications and Unit tests](#templates)
- [Libraries (Pubs)](#libraries)
- [Folder layout](#folders)
- [Documentation](#documentation)
- [Google Blog](#blog)
- [Author](#author)
- [License](#license)
- [RoadMap](#roadmap)
- [TODOs](#todos)
- [Further reading](#readings)
- [Showcases](#showcases)
- [Contributing](#contributing)

###[About](#about-dart)
**Ranger-Dart** (Ranger for short) is a game engine written in [Dart](https://www.dartlang.org/) and slightly modeled after an older version of [Cocos2d-js 1.x](http://www.cocos2d-x.org/products#cocos2dx-js). If you have ever worked with Cocos2Dx then you will recognize a fair amount of the examples. However, several things have changed, most notebly Animations and Messaging.

Initially **Ranger**'s code base was structured similar to Cocos2d. However, after using Dart design patterns and libraries (aka Pubs) the code base diverged and has changed considerably. The only *concepts* remaining are Scenes, Layers and Scheduler.

**Ranger** is a game engine currently centric around an HTML5-Canvas and a [Scene graph](http://en.wikipedia.org/wiki/Scene_graph). Rendering of the scene graph is rendered to a Context of type [CanvasRenderingContext2D](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D). In the future the [WebGLRenderingContext](https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext) will be supported.

###[Screen shots](#shots)
**Ranger** in action: [ScreenShots and videos](docs/Screenshots.md)

###[Features](#features)
- Scene graph (heirarchical spatial organization) including space mappings.
- Animations using [Universal Tween Engine](https://pub.dartlang.org/packages/tweenengine) pub.
- Message system using [EventBus](https://pub.dartlang.org/packages/event_bus) pub.
- Sprites and sprite sheets. (PNG, SVG etc...)
- Particle systems.
- Html5 Canvas rendering.
- Design resolution that is independent of device resolution.
- Scene transitions.
- Optional Updates-per-second for slower devices.
- Examples, starter templates and Unit tests.

###[Getting started](#getting-started)
Where to start? Easy, just follow these steps:

1. Download the [Dart SDK](https://www.dartlang.org/) and install it. If you are on a Mac then it is as easy as installing the .dmg.
2. Go to GitHub and download [Ranger-Dart](https://github.com/wdevore/Ranger-Dart). To do that choose to either *Clone in Desktop* or *Download ZIP*. If choose the Zip option then uncompress it to a location of your choosing. You should now have a folder called "Ranger-Dart".
3. Launch the [Dart Editor](https://www.dartlang.org/tools/editor/) that came with the SDK.
4. In the editor navigate to the file menu and choose *Open Existing Folder*.
 * Navigate to the location of either the uncompressed Zip or
 * The local Git repository that you cloned to your "desktop".
5. With the project open, run one of the *Templates* called "level0"
 * Navigate into the "level0" template folder located under:
```
web/
    applications/
        templates/
            level0
```
6. Right-click on **level0.html** and choose *Run in Dartium*.

Once [Dartium](https://www.dartlang.org/tools/dartium/) (which comes with the SDK) has launched it will automatically navigate to "http://localhost:8080/applications/templates/level0/level0.html" and start running. First you will see a splash scene for 3 seconds and then instaneously transition to a GameLayer with dark blue text displaying "*Ranger GameLayer*" on a dark grey background.
![GameLayer](docs/template0_gamelayer.png)
7. Congratulations. You have successfully installed and ran **Ranger**!

###[Templates, Applications and Unit tests](#templates)
**Ranger** comes with a suite of Templates, Applications and Unit tests. Each serves as a *howto* for starting a project or referencing during project development. When starting a new project you will copy one of the Templates and begin coding from there. The Applications and Unit tests are for later, after you have a project underway and want to know how to do something.

#### Templates
There are currently 7 Templates located under the *web* folder.
```
web/
    applications/
        templates/
```
Each Template progressively adds on a feature showing how to perform a basic task. For example, *level0* is the most basic: a Splace Scene and Splash Layer, and a GameScene and GameLayer.

- Level 0 - A stripped down basic framework template.
- Level 1 - Loads a single sprite asyncronously.
- Level 2 - Loads 5 sprites asyncronously and adds an overlay busy spinner.
- Level 3 - Basic keyboard activation and usage.
- Level 4 - Demonstrates basic Scene transition and animations.
- Level 5 - Demonstrates icon animation and HTML panel animation.
- Level 6 - Demonstrates a particle system.

#### Applications
There are currently 2 applications.
```
web/
    applications/
        ranger_particles/
        rocket/
```
*Ranger_particles* is a hand built HTML/CSS application that uses **Ranger** to display the particles. The application itself is not complete meaning you can only save to local-storage. There is code to save to the GDrive but it hasn't been completely wired up. I know the GDrive code works because it is used in the [SpritePatch]() application to save and load sprite sheets.

*Rocket* is a demonstration of complex Node usage. In there you will find examples on how to map between "world-space" and "node-space" in order to handle particle placing and collision detection. It also shows the proper way of handling key presses.

#### Unit tests
There are many unit tests. Some are non-visual but many are visual. The original unit tests have all of the non-visual tests, for example, pooling and affine transformations; and they are a bit outdated so use with caution.
> A side note: When first looking to port Cocos2D-js the first thing I noticed was that the transform stack appeared as a mess. I couldn't make complete sense of it and I didn't want to use something that I couldn't follow or understand. So the very first thing I did was scrap Cocos2D-js code and learn to make a transform stack myself. Forturnately I had worked with [Piccolo2D](http://www.cs.umd.edu/hcil/piccolo/) and understood how its stack worked.

The old test (some may not work as they were created almost a year ago) are located under the *old_tests* folder. The newest tests are under the *scenes/tests* folder.
```
web/
    unittests/
        old_tests/
        scenes/
            tests/
                colors/
                fonts/
                inputs/
                particlesystems/
                spaces/
                sprites/
                transforms/
                transitions/
```
The new tests cover pretty much all aspects of **Ranger**. They serve as both unit tests and as a resource to learn from.

###[Libraries (Pubs)](#libraries)
**Ranger** relies on several Dart [Pubs](https://pub.dartlang.org/). However, you may notice several other Pubs in the [pubspec.yaml](https://www.dartlang.org/tools/pub/) file: color_slider_control, gradient_colorstops_control, lawndart. These Pubs are used by the particle system application and aren't really a part of **Ranger**. Here are the actual Pub dependencies:
- [EventBus](https://pub.dartlang.org/packages/event_bus) by Marco Jakob
- [Tween Engine](https://pub.dartlang.org/packages/tweenengine) by Xavier Guzman
- [Vector Math](https://pub.dartlang.org/packages/vector_math) by John McCutchan
- Browser. Every Dartium app relies on this Pub.

###[Folder layout](#folders)
**Ranger** is a Pub and the core code is located under the *lib* folder. Here is a brief overview:
```
lib/
    ranger/
        animation/      -- Tween animation wrapper/helper
        core/           -- Pooling and timing (aka the Scheduler)
        geometry/       -- (Optional) Basic geometric shapes
        mixins/         -- Color, Input behaviors
        nodes/          -- The main visuals (Scenes, Layers etc...)
        particles/      -- (Optional) particle systems
        physics/        -- (Optional) Velocity
        rendering/      -- DrawContext (includes default implementations.)
        resources/      -- Imageloading and Embedded Base64 resources
        sprites/        -- Includes Canvas implementations
        utilities/      -- Misc
```
Basically there are 4 critical folders that matter when developing a game: *animation*, *core*, *mixins* and *nodes*. Other than that you are not required to use anything else. *geometry*, *particles*, *physics* and even *sprites* are not required.

The optional folders simply provide examples on how to build Nodes, and they are used mostly for the unit tests and templates.

###[Documentation](#documentation)
In progress... I hope to have several Google Docs prepared that guide you through setting up a simple framework exactly like Templates.

###[Google Blog](#blog)
**Ranger** has a [Blog](https://plus.google.com/u/0/b/109136453872758385259/109136453872758385259/posts) where I periodically post statues.

###[Author](#author)
Hello, I am [Will DeVore](https://plus.google.com/u/0/b/104513085420089025698/104513085420089025698/posts) the current developer of **Ranger**. I find it a pleasure working with the [Dart](https://www.dartlang.org/) language. Its integration with HTML/CSS/Canvas/WebGL is solid and functional.

###[License](#license)
See [MIT license](LICENSE)

###[TODOs](#todos)
**Ranger**'s code is still sprinkled with TODOs. Most are minor in nature. Some of the top areas are:
- Performance. Things like String conversions in places where code runs in tight loops.
- Pause/Resume. I need to add the pause/resume code when Scenes are transitioning. An early version was present but once I replaced the old dispatch code with Dart's Streams that code became obsolete.
- Visibility of browser/tabs. When a tab or the whole browser focus is lost the engine needs to recognize this and pause.
- Accelerometer code.
- Several pieces of code should be optimized to check for dirty flag on transformations. I have slacked off is a few areas.
- A better more full proof way of handling Infinite animations. At the moment the developer needs to track the Infinite animations. If they are not "killed" then cycles are wasted as the animation continues to animate objects that may be gone or invisible.

###[RoadMap](#roadmap)
There are still manys things that need to be done in **Ranger**. It will probably never really be complete, nonetheless, I have a list of things that I would like to add as time permits in no particular order.

- Color/Alpha Cascading. Color cascading was low on my list but I really need to add it otherwise fading in and out of entire Scenes and Layers is on the onus of the user.
- [WebGL](https://www.khronos.org/registry/webgl/specs/latest/). **Ranger** has preliminary polymophic support to accomodate WebGL. It is quite possible that an underlying library will be used; perhaps the [Three.dart Pub](https://pub.dartlang.org/packages/three) may be a viable candidate. Worst case is to follow something similar to Cocos2dx-3.x.
- Quad tree culling
- Physics with [Box2D Pub](https://pub.dartlang.org/packages/box2d)
- Fullscreen support
- Textures. Assuming WebGL is added.
- Additional transition effects.
- Create a "Ranger-sack" github repo. This repo would hold extensions to **Ranger**. For example, collision, zooming, zones, tracking etc.
- Components.

###[Further reading](#readings)
- [Dart language](https://www.dartlang.org/)
- [WebGL](https://www.khronos.org/webgl/)
- [Html Canvas](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Canvas_tutorial)
- [Core Html5 Canvas](http://www.amazon.com/Core-HTML5-Canvas-Animation-Development/dp/0132761610/ref=sr_1_2?ie=UTF8&qid=1411696766&sr=8-2&keywords=html5+canvas)
- [Cocos2D 3.0](http://www.amazon.com/Learning-iPhone-Game-Development-Cocos2D-ebook/dp/B00LB6DJ0U/ref=sr_1_1?ie=UTF8&qid=1411696840&sr=8-1&keywords=cocos2d)
- [Learning Cocos2D](http://www.amazon.com/Learning-Cocos2D-Hands--Building-Chipmunk-ebook/dp/B005BOMFIU/ref=sr_1_4?ie=UTF8&qid=1411696840&sr=8-4&keywords=cocos2d)

###[Showcases](#showcases)
None at the moment.

###[Contributing](#contributing)
There is still a fair amount of stuff to do to make **Ranger** feature complete. Contributing to **Ranger** would be helpful as the spirit of **Ranger** is maintained.

End.