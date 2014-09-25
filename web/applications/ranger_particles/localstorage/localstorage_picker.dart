library dialogs;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:lawndart/lawndart.dart';
import '../resources/resources.dart';

/*
 * A simple local storage file system with no directory support.
 * All files are contained in a Map
 * {"file": name, "data": json+base64}
 * 
  */
class LocalStorageDialog {
  // The main shell to hold everything.
  DivElement _content;
  
  // The disabled background.
  DivElement _blackOverlay;

  // Inner yellow container.
  DivElement _innerContent;

  // Button row
  DivElement _buttons;

  // Google title
  LabelElement _headerTitle;

  // File area
  DivElement _fileArea;

  DivElement _filesContent;
  
  ButtonElement _cancelButton;
  ButtonElement _selectButton;
  
  TextInputElement _enteredFileNameElement;
  
  // How many file items are being fetched.
  int _fileItems = 0;
  
  Map _selectedFile;
  CheckboxInputElement _previousCheckBox;
  
  Function _selectedCallBack;
  Function _savedCallBack;
  Function _loadedCallBack;
  
  bool _visible = false;
  Store _store;
  Map _fileSystem = new Map();
  
  Resources _resources;

  LocalStorageDialog(Resources resources) {
    _resources = resources;
    _buildGUI();
  }

  Map get files => _fileSystem["Files"];
  
  void newSystem() {
    _fileSystem = {"Files": []};
    _store = new Store("RangerParticlesDB", "RangerParticlesFS");
    _store.open().then((_) {
      _store.nuke();
    });
  }
  
  Future<Map> refresh(bool forceNew) {
    Completer completer = new Completer();
    
    _store = new Store("RangerParticlesDB", "RangerParticlesFS");
    
    if (forceNew) {
      print("New File system forced.");
      newSystem();
      completer.complete(_fileSystem);
    }
    else {
      _store.open().then((_) {
        _store.getByKey("files").then((Map value) {
          if (value == null) {
            print("New File system loaded.");
            newSystem();
          }
          else {
            // If there are no files then we load a default and store.
            List files = value["Files"];
            if (files == null || files.isEmpty) {
              newSystem();
            }
            else {
              // We have to copy the files into a new allocation because
              // the loaded Map is non-mutable.
              _fileSystem = {"Files": []};
              
              List files = _fileSystem["Files"];
              // TODO may have to make clones.
              files.addAll(value["Files"]);
              print("File system loaded.");
            }
          }
  
          completer.complete(_fileSystem);
        });
      });
    }
    
    return completer.future;
  }
  
  bool get isVisible => _visible;
  
  void hide() {
    document.body.nodes.remove(_content);
    document.body.nodes.remove(_blackOverlay);
    _visible = false;
  }

  void _selectFileToSaveTo(Function selectedCallBack) {
    document.body.nodes.add(_content);
    document.body.nodes.add(_blackOverlay);
    _visible = true;
    _selectedCallBack = selectedCallBack;
    
    _selectedFile = null;

    _selectButton.text = "Save";
  }

  Map _selectFileToLoadFrom(Function selectedCallBack) {
    document.body.nodes.add(_content);
    document.body.nodes.add(_blackOverlay);
    _visible = true;
    
    _selectedCallBack = selectedCallBack;
    
    _selectedFile = null;
    
    _selectButton.text = "Load";
    
    // Load GUI with file list.
    List files = _fileSystem["Files"];
    files.forEach((Map file) => _addFile(file));
  }

  Map get selectedFile => _selectedFile;
  
  void _storeFile(String fileName, Map data) {
    Map file = {
      "name" : fileName,
      "data" : data
    };

    List files = _fileSystem["Files"];

    files.add(file);
  }
  
  Future<String> storeMap(Map map) {
    List files = _fileSystem["Files"];
    
    files.removeWhere((Map m) => m["name"] == map["name"]);

    files.add(map);

    Future<String> f = _store.save(_fileSystem, "files");
    
    return f;
  }

  Future<String> removeMap(Map map) {
    List files = _fileSystem["Files"];
    
    files.removeWhere((Map m) => m["name"] == map["name"]);

    Future<String> f = _store.save(_fileSystem, "files");
    
    return f;
  }

  void _handleSaveError(Error error) {
    print("LocalStorageDialog._handleSaveError: $error");
  }
  
  void loadFile(Function loadedCallBack) {
    _loadedCallBack = loadedCallBack;
    _clearFileArea();
    _selectFileToLoadFrom(_selectedToLoad);
  }

  void _selectedToLoad() {
    _loadedCallBack(_selectedFile);
    
    hide();
  }
  
  void saveFile(Map data, Function savedCallBack, [bool showDialog = true]) {
    _savedCallBack = savedCallBack;
    if (showDialog) {
      _clearFileArea();
      _selectFileToSaveTo(() => _selectedToSave(data));
    }
    else
      storeMap(data);
  }
  
  void removeFile(Map data, [Function removedCallBack = null]) {
    List files = _fileSystem["Files"];
    files.removeWhere((Map m) => m["name"] == data["name"]);
    
    _store.save(_fileSystem, "files").then((_) {
      if (removedCallBack != null)
        removedCallBack();
    });
  }
  
  void _selectedToSave(Map data) {
    print("saving");
    // They either selected an existing file or typed a new one in.
    if (_enteredFileNameElement.value.isEmpty) {
      // They selected from the list.
    }
    else {
      print("${_enteredFileNameElement.value}");
      List files = _fileSystem["Files"];
      
      Map file = {
        "name" : "${_enteredFileNameElement.value}",
        "data" : data
      };

      files.removeWhere((Map m) => m["name"] == _enteredFileNameElement.value);
      
      files.add(file);
    }

    _store.save(_fileSystem, "files").then((_) {
      hide();
      if (_savedCallBack != null)
        _savedCallBack();
    });
    
  }
  
  void _selected() {
    _selectedCallBack();
  }
  
  // --------------------------------------------------------------
  // GUI
  // --------------------------------------------------------------
  void _buildGUI() {
    _content = new DivElement();
    _blackOverlay = new DivElement();
    
    _content.id = "modalContent";
    _content.classes.add("main_content");  //set the class for CSS
    
    _blackOverlay.id = "modalOverlay";
    _blackOverlay.classes.add("black_overlay");

    // Now we start adding HTML controls
    //------------------------------------------------------------
    // Google title
    //------------------------------------------------------------
    _headerTitle = new LabelElement();
    _headerTitle.text = "Google Drive";
    _headerTitle.classes.add("googleTitle");
    
    _content.nodes.add(_headerTitle);

    //------------------------------------------------------------
    // The inner yellow container.
    //------------------------------------------------------------
    _innerContent = new DivElement();
    _innerContent.classes.add("inner_content");
    _content.nodes.add(_innerContent);

    //------------------------------------------------------------
    // File area where network info is displayed
    //------------------------------------------------------------
    _fileArea = new DivElement();
    _fileArea.classes.add("file_area_content");
    _innerContent.nodes.add(_fileArea);

    //------------------------------------------------------------
    // Bottom button row and input
    //------------------------------------------------------------
    _buttons = new DivElement();
    _buttons.classes.add("bottom_button_content");
    _content.nodes.add(_buttons);
    
    //This is the button that will "dismiss" the dialog
    _cancelButton = new ButtonElement();
    _cancelButton.classes.add("darkButton");
    _cancelButton.text = "Cancel";
    _cancelButton.onClick.listen((event) {
      hide();
    });
    _buttons.nodes.add(_cancelButton);

    _selectButton = new ButtonElement();
    //_selectButton.text = "Select";
    _selectButton.classes.add("darkButton");
    _selectButton.onClick.listen((event) {
      _selected();
    });
    _buttons.nodes.add(_selectButton);

    SpanElement fileSpan = new SpanElement();
    fileSpan.style.marginLeft = "10px";
    
    LabelElement fileLabel = new LabelElement();
    fileLabel.text = "File name: ";
    fileSpan.nodes.add(fileLabel);
    
    _enteredFileNameElement = new TextInputElement();
    _enteredFileNameElement.style.fontSize = "18px";
    _enteredFileNameElement.style.width = "20em";
    fileSpan.nodes.add(_enteredFileNameElement);

    _buttons.nodes.add(fileSpan);

    //------------------------------------------------------------
    // Files
    //------------------------------------------------------------
    _filesContent = new DivElement();
    _filesContent.classes.add("files_content");
    _fileArea.nodes.add(_filesContent);
  }
  
  void _loadFileDisplay() {
  }
  
  void _addFile(Map file) {
    DivElement row = new DivElement();
    
    CheckboxInputElement checkBox = new CheckboxInputElement();
    checkBox.onChange.listen((event) {
      CheckboxInputElement cb = event.target as CheckboxInputElement;
      _collectCheckedFile(file, cb);
    });
    
    row.nodes.add(checkBox);
    
    LabelElement name = new LabelElement();
    name.classes.add("file_name");
    name.text = file["name"];
    row.nodes.add(name);
    
    ImageElement deleteIcon = _resources.deleteIcon.clone(false);
    deleteIcon.classes.add("emitter_svg_icon");
    deleteIcon.title = "Click to remove from local storage.";
    deleteIcon.onClick.listen((event) {
      _fileDelete(file, row);
    });
    row.nodes.add(deleteIcon);

    _filesContent.nodes.add(row);
  }
  
  void _fileDelete(Map file, DivElement row) {
    _filesContent.nodes.remove(row);
    List files = _fileSystem["Files"];

    files.removeWhere((Map m) => m["name"] == file["name"]);
    
    _store.save(_fileSystem, "files");
  }
  
  void _clearFileArea() {
    _fileArea.nodes.remove(_filesContent);
    
    _filesContent = new DivElement();
    _filesContent.classes.add("files_content");
    _fileArea.nodes.add(_filesContent);
  }
  
  void _collectCheckedFile(Map file, CheckboxInputElement checkBox) {
    if (checkBox.checked) {
      if (_previousCheckBox != null) {
        _previousCheckBox.checked = false;
      }
      _selectedFile = file;
      _previousCheckBox = checkBox;
    }
    else {
      _selectedFile = null;
    }
  }
}

