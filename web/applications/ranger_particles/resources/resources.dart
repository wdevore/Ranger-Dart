library app_resources;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:lawndart/lawndart.dart';
import '../data/emitter.dart';

/*
  */
class Resources {
  ImageElement checkedIcon;
  ImageElement uncheckedIcon;

  ImageElement checkedSquareIcon;
  ImageElement uncheckedSquareIcon;

  ImageElement local;
  ImageElement localDisabled;

  ImageElement gdrive;
  ImageElement gdriveDisabled;

  ImageElement copyIcon;
  ImageElement deleteIcon;
  ImageElement resetIcon;

  ImageElement emitterDirtyIcon;
  ImageElement emitterDirtyIconDisabled;

  ImageElement pulseIcon;
  ImageElement pulseIconDisabled;

  ImageElement explodeIcon;

  static const int BASE_ICON_SIZE = 25;
  
  int _iconLoadCount = 0;
  int _iconTotal = 0;
  
  Map appConfig;
  bool _appConfigLoaded = false;
  Store appStore;
  
  Emitter defaultParticleSystem;

  // fileStore holds both the directory and individual emitters stored
  // as json maps.
  Store fileStore;
  bool _fileStoreLoaded = false;
  
  List<String> directory;
  int _fileCount = 0;
  int _fileTotal = 0;
  Map<String, Emitter> files = new Map<String, Emitter>();
  
  bool _nukeFileSystem = true;
  
  Completer _completer;
  
  Future loadBaseResources() {
    _completer = new Completer();
    
    checkedIcon = _loadIcon("resources/checkbox-checked-icon.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);
    uncheckedIcon = _loadIcon("resources/checkbox-unchecked-icon.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);
    
    checkedSquareIcon = _loadIcon("resources/checkbox-checked_square.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);
    uncheckedSquareIcon = _loadIcon("resources/checkbox-unchecked_square.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);
    
    copyIcon = _loadIcon("resources/copy-icon.svg", BASE_ICON_SIZE + 5, BASE_ICON_SIZE + 5);

    local = _loadIcon("resources/cpu-2-icon.svg", BASE_ICON_SIZE + 5, BASE_ICON_SIZE + 5);
    localDisabled = _loadIcon("resources/cpu-2-icon_disabled.svg", BASE_ICON_SIZE + 5, BASE_ICON_SIZE + 5);

    gdrive = _loadIcon("resources/Google_Drive_Logo.svg", BASE_ICON_SIZE, BASE_ICON_SIZE);
    gdriveDisabled = _loadIcon("resources/Google_Drive_Logo_disabled.svg", BASE_ICON_SIZE, BASE_ICON_SIZE);

    emitterDirtyIcon = _loadIcon("resources/change.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);
    emitterDirtyIconDisabled = _loadIcon("resources/change_disabled.svg", BASE_ICON_SIZE - 5, BASE_ICON_SIZE - 5);

    pulseIcon = _loadIcon("resources/pulse.svg", BASE_ICON_SIZE + 10, BASE_ICON_SIZE + 10);
    pulseIconDisabled = _loadIcon("resources/pulse_disabled.svg", BASE_ICON_SIZE + 10, BASE_ICON_SIZE + 10);

    explodeIcon = _loadIcon("resources/explode.svg", BASE_ICON_SIZE + 10, BASE_ICON_SIZE + 10);

    resetIcon = _loadIcon("resources/reset-icon.svg", BASE_ICON_SIZE + 5, BASE_ICON_SIZE + 5);
    deleteIcon = _loadIcon("resources/close11.svg", BASE_ICON_SIZE, BASE_ICON_SIZE);
    //_deleteIcon = _loadIcon(src: "resources/Red_x.svg", width: BASE_ICON_SIZE, height: BASE_ICON_SIZE);
    
    // Load the default particle system.
    HttpRequest.getString("resources/default_system.json")
      .then(_processDefaultSystem)
      .catchError(_handleDefaultSystemLoadError);

    // Load Configure map.
    appStore = new Store("RangerParticlesDB", "RangerParticlesAppConfig");

    appStore.open().then((_) {
      appStore.getByKey("Config").then((Map value) {
        _appConfigLoaded = true;
        if (value == null) {
          print("No app configuration present. Defaulting to preset.");
        }
        else {
          print("App config present.");
          appConfig = value;
        }
        _checkForCompleteness();
      });
    });

    _loadFileStore(_nukeFileSystem).then((_) {
      _fileStoreLoaded = true;
      print("File store loaded");
      _checkForCompleteness();
    });
    
    return _completer.future;
  }
  
  Future _newSystem(Store store, Function nukeComplete) {
    return store.open().then((_) {
      print("Store opened. Nuking contents.");
      store.nuke().then((_) {
        print("Contents nuked.");
        nukeComplete();
      }).catchError((Error e) => print(e));
    }).catchError((DomException e) => print(e));
  }

  // To load the local store file system we need to read the directory
  // first.
  Future _loadFileStore(bool forceNew) {
    Completer completer = new Completer();
    
    fileStore = new Store("RangerParticlesDB", "RangerParticlesFS");
    
    if (forceNew) {
      print("New File system being forced.");
      _newSystem(fileStore, () => _nukeComplete(completer));
    }
    else {
      // A new system has no files, but does have an empty directory map.
      fileStore.open().then((_) {
        // Load the directory so we can load the emitters.
        fileStore.getByKey("directory").then((List value) {
          if (value == null) {
            print("New File system loaded.");
            // The directory doesn't exist yet, one hasn't been saved yet.
            // So there are no emitters to load as well.
            _newSystem(fileStore, () => _nukeComplete(completer));
          }
          else {
            // A directory exists. Iterate it while loading emitters.
            directory = new List.from(value);
            
            if (directory.isNotEmpty) {
              _fileTotal = directory.length;
              print("directory: $directory");
              
              for(String file in directory) {
                fileStore.getByKey(file).then((Map value) {
                  _fileCount++;
                  
                  // Allocate emitter
                  Emitter emitter = new Emitter.withMap(value);
                  files[value["name"]] = emitter;
                  
                  _checkForCompleteness();
                });
              }
            }
          }
  
          completer.complete();
        });
      });
    }
    
    return completer.future;
  }

  void _nukeComplete(Completer completer) {
    print("Nuke complete.");
    directory = new List<String>();
    _fileCount = _fileTotal;
    fileStore.save(directory, "directory").then((_) {
      print("Saved new directory.");
      completer.complete();
    });
  }
  
  Future<String> saveFile(String name, Emitter data) {
    // If file hasn't been saved prior then there won't be a directory
    // entry. We add one and then save.
    if (!directory.contains(name)) {
      directory.add(name);
      
      return fileStore.save(directory, "directory")
        .whenComplete(() => fileStore.save(data.toMap(), name));
    }
    
    return fileStore.save(data.toMap(), name);
  }
  
  Future<String> removeFile(String name) {
    // Remove from directory as well.
    directory.removeWhere((String e) => e == name);
    
    // Remove it from the files collection.
    files.remove(name);
    
    // Now save modified directory and remove it from storage as well.
    return fileStore.save(directory, "directory")
      .whenComplete(() => fileStore.removeByKey(name));
  }
  
  Future<String> renameFile(String newName, String oldName) {
    // Overrite old name with new one.
    directory[directory.indexOf(oldName)] = newName;
    
    // First get the emitter under the old name.
    Emitter e = files[oldName];
    // remove emitter from files
    files.remove(oldName);
    // Update its name.
    e.name = newName;
    // Add it back in.
    files[newName] = e;
    
    // Now remove old stored file and add new one.
    return fileStore.save(directory, "directory")
        .then((_) => fileStore.removeByKey(oldName))
        .then((_) => fileStore.save(e.toMap(), newName));
  }
  
  ImageElement _loadIcon(String source, int iWidth, int iHeight) {
    _iconTotal++;
    ImageElement i = new ImageElement(src: source, width: iWidth, height: iHeight);
    i.onLoad.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
    return i;
  }
  
  void _onData(Event e) {
    _iconLoadCount++;
    _checkForCompleteness();
  }

  void _onError(Event e) {
    print("Resources error: $e");
  }

  void _onDone() {
    print("done");
  }
  
  bool get isLoaded => 
      _iconLoadCount == _iconTotal && 
      defaultParticleSystem != null && 
      _appConfigLoaded &&
      _fileStoreLoaded &&
      _fileCount == _fileTotal;
  
  void _checkForCompleteness() {
//    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
//    print("_iconLoadCount: $_iconLoadCount");
//    print("_iconTotal: $_iconTotal"); 
//    print("defaultParticleSystem: $defaultParticleSystem"); 
//    print("_appConfigLoaded: $_appConfigLoaded");
//    print("_fileStoreLoaded: $_fileStoreLoaded");
//    print("_fileCount: $_fileCount");

    if (isLoaded) {
      print("Completed.");
      _completer.complete();
    }
  }
  
  void _processDefaultSystem(String jsonString) {
    Map data = JSON.decode(jsonString);
    
    Map dfMap = {
      "name" : "_default",
      "data" : data
    };

    defaultParticleSystem = new Emitter.withMap(dfMap);
    
    _checkForCompleteness();    
  }

  void _handleDefaultSystemLoadError(Error error) {
    print("EmittersTab._handleDefaultSystemLoadError: $error");
  }

}