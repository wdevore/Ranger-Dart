Ranger-Dart - v0.1.0
===========

##Contents:
- [About](#about-dart)
- [Features](#features)
- [Getting started](#getting-started)
- [Templates, Applications and Unit tests](#templates)
- [Libraries (Pubs)](#libraries)
- [Folder layout](#folders)
- [Google Blog](#blog)

###[About](#about-dart)
**Ranger-Dart** (Ranger for short) is a game engine written in [Dart](https://www.dartlang.org/) and slightly modeled after an older version of [Cocos2d-js 1.x](http://www.cocos2d-x.org/products#cocos2dx-js).

Initially **Ranger**'s code base was structured similar to Cocos2d. However, after using Dart design patterns and libraries (aka Pubs) the code base diverged and has changed considerably. The only *concepts* remaining are Scenes, Layers and Scheduler.

**Ranger** is a game engine currently centric around an HTML5-Canvas and a [Scene graph](http://en.wikipedia.org/wiki/Scene_graph). Rendering of the scene graph is rendered to a Context of type [CanvasRenderingContext2D](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D). In the future the [WebGLRenderingContext](https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext) will be supported.

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
2. Go to GitHub and download [Ranger-Dart](https://github.com/wdevore/Ranger-Dart). Then choose to either *Clone in Desktop* or *Download ZIP*. If choose the Zip option then uncompress it to a location of your choosing. You should now have a folder called "Ranger-Dart".
3. Launch the [Dart Editor](https://www.dartlang.org/tools/editor/) that came with the SDK.
4. In the editor navigate to the file menu and choose *Open Existing Folder*.
 * Navigate to the location of either the uncompressed Zip or
 * The local Git repository after you cloned.
5. With the project open, run one of the *Templates* called "level0"
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

###[Templates, Applications and Unit tests](#templates)
**Ranger** comes with a suite of Templates, Applications and Unit tests. Each serves as a *howto* for starting a project or during project development. When starting a new project you will copy one of the Templates and begin coding from there. The Applications and Unit tests are more for later, after you have a project underway and want to know how to do something.

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
Basically there are 4 critical folders that matter when developing a game: *animation*, *core*, *mixins* and *nodes*. Other than that you are not required to anything else. *geometry*, *particles*, *physics* and even *sprites* are not required.

The optional folders simply provide examples on how to build Nodes, and they are used mostly for the unit tests and templates.

Docs section

###[Google Blog](#blog)

Author section
Team and Contacts
License
Roadmap
    WebGL
    Color Cascading
Known issues TODOs
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