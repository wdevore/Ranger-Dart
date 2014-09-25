library emitters_panel;

import 'dart:html';

import '../particle_layer.dart';
import '../controls/checkbox_control.dart';
import '../controls/icon_button_control.dart';
import '../dialogs/new_emitter_dialog.dart';
import '../dialogs/yes_no_dialog.dart';
import '../resources/resources.dart';
import '../model_controller.dart';
import '../data/emitter.dart';

class _emitterRow {
  String map;
  CheckBoxControl checkbox;
  IconButtonControl localButton;
  IconButtonControl gdriveIcon;
  LabelElement name;
}

class EmittersTab {
  ParticleLayer particleLayer;
  
  DivElement _emittersTabElement;
  DivElement _emittersElement;

  DivElement _emittersLoadedOuterDivElement;
  /*
   * Note: the DIV element must NOT have spaces defined in it, and this
   * includes \r and \n characters.
   * BAD:
   * <DIV>
   * </DIV>
   * 
   * GOOD:
   * <DIV></DIV>
   */ 
  DivElement _emittersLoadedPanelElement;
  CheckBoxControl _currentCheckBox;
  
  Function _tabChanged;
  
  List<_emitterRow> _emitterRows = new List<_emitterRow>();
  
  static const int BASE_ICON_SIZE = 25;
  
  ModelController _modelController;
  
  _emitterRow _actionRow;
  
  void init(ModelController modelController, Function tabChanged) {
    _modelController = modelController;
    _modelController.emitterTab = this;
    
    _tabChanged = tabChanged;
    
    _emittersLoadedPanelElement = querySelector("#emittersLoadedPanel");
    _emittersTabElement = querySelector("#emittersTabId");

    _emittersElement = querySelector("#emittersId");
    _emittersElement.style.backgroundColor = "#aa3355";
    _emittersElement.onClick.listen(
        (Event event) => tabSelected()
    );
  }
  
  void reload() {
    Map<String, Emitter> files = _modelController.resources.files;
    // Add them according to the directory order.
    List<String> directory = _modelController.resources.directory;
    
    directory.forEach((String file) => addNewEmitter(files[file], false, false));
  }
  
  // Data can change during the load process or by the user.
  // We need to distinguish between them. If changed by the user then
  // we need to update the icons.
  void dataChanged(bool changedByUser) {
    // Using selected emitter update the icons.
    _emitterRow eRow = _emitterRows.firstWhere((_emitterRow er) => er.map == _modelController.selectedMapName);
    if (changedByUser)
      enableIOButtons(eRow);
  }
  
  void enableIOButtons(_emitterRow eRow) {
    if (eRow != null) {
      if (eRow.localButton != null)
        eRow.localButton.setEnabled();
      if (eRow.gdriveIcon != null)
        eRow.gdriveIcon.setEnabled();
    }
  }
  
  void addDefaultEmitter(Emitter map) {
    _modelController.activateEmitter = map;

    Resources resources = _modelController.resources;
    
    DivElement row = new DivElement();
    row.classes.add("emitter_row_item");
    
    _emitterRow eRow = new _emitterRow();
    eRow.map = "_default";
    _emitterRows.add(eRow);

    CheckBoxControl checkbox = new CheckBoxControl(true, row, resources.checkedIcon, resources.uncheckedIcon, _checkBoxChanged);
    eRow.checkbox = checkbox;
    _currentCheckBox = checkbox;
    checkbox.map = eRow.map;
    
    LabelElement name = new LabelElement();
    name.classes.add("emitter_name");
    name.text = "Default particle system";
    
    row.nodes.add(name);
    
    ImageElement copyIcon = resources.copyIcon.clone(false);
    copyIcon.classes.add("emitter_svg_icon");
    copyIcon.title = "Click to make a duplicate of the default emitter.";
    copyIcon.onClick.listen((event) {
      _emitterCopy(eRow, map);
    });
    row.nodes.add(copyIcon);

    _emittersLoadedPanelElement.nodes.add(row);
  }
  
  _emitterRow addNewEmitter(Emitter map, [bool selected = false, bool changedByUser = true]) {
    _modelController.activateEmitter = map;

    Resources resources = _modelController.resources;

    DivElement row = new DivElement();
    row.classes.add("emitter_row_item");
    
    _emitterRow eRow = new _emitterRow();
    eRow.map = map.name;
    _emitterRows.add(eRow);
    
    CheckBoxControl checkbox = new CheckBoxControl(selected, row, resources.checkedIcon, resources.uncheckedIcon, _checkBoxChanged);
    eRow.checkbox = checkbox;
    _currentCheckBox = checkbox;
    checkbox.map = eRow.map;

    LabelElement name = new LabelElement();
    name.title = "Click name to change.";
    eRow.name = name;
    name.onClick.listen((event) {
      _emitterRename(eRow, map.name);
    });
    name.classes.add("emitter_name");
    name.text = map.name;
    
    row.nodes.add(name);
    
    ImageElement copyIcon = resources.copyIcon.clone(false);
    copyIcon.classes.add("emitter_svg_icon");
    copyIcon.title = "Click to make a duplicate of this emitter.";
    copyIcon.onClick.listen((event) {
      _emitterCopy(eRow, map);
    });
    row.nodes.add(copyIcon);
    
    IconButtonControl localButton = new IconButtonControl(changedByUser, row, resources.local, resources.localDisabled, _saveToLocal);
    eRow.localButton = localButton;
    localButton.map = eRow.map;
    localButton.enableTitle = "Click to save particle system to local storage.";
    localButton.disabledTitle = "Particle system already saved to local storage.";

    IconButtonControl gdriveIcon = new IconButtonControl(true, row, resources.gdrive, resources.gdriveDisabled, _saveToGDrive);
    eRow.gdriveIcon = gdriveIcon;
    gdriveIcon.map = eRow.map;
    gdriveIcon.enableTitle = "Click to save particle system to GDrive.";
    gdriveIcon.disabledTitle = "Particle system already saved to GDrive.";
    
    ImageElement resetIcon = resources.resetIcon.clone(false);
    resetIcon.classes.add("emitter_svg_icon");
    resetIcon.title = "Click to reset back to defaults.";
    resetIcon.onClick.listen((event) {
      _emitterResetToDefault(map, eRow);
    });
    row.nodes.add(resetIcon);

    ImageElement deleteIcon = resources.deleteIcon.clone(false);
    deleteIcon.classes.add("emitter_svg_icon");
    deleteIcon.title = "Click to remove from list.";
    deleteIcon.onClick.listen((event) {
      _emitterDelete(map, eRow);
    });
    row.nodes.add(deleteIcon);

    _emittersLoadedPanelElement.nodes.add(row);
    
    return eRow;
  }

  void _checkBoxChanged(CheckBoxControl checkbox, Object data) {
    if (_currentCheckBox != null)
      _currentCheckBox.setUnChecked();
    
    // If none remain checked then automagically select the default.
    _emitterRow cbc = _emitterRows.firstWhere((_emitterRow er) => er.checkbox.isChecked, orElse: () => null);

    if (cbc == null) {
      cbc = _emitterRows[0];
      _currentCheckBox = cbc.checkbox;
      _currentCheckBox.setChecked();
    }
    else
      _currentCheckBox = checkbox;
    
    _modelController.selectMapByName = _currentCheckBox.map;
    
    // See if this newly selected emitter is dirty.
    if (cbc.map != "_default") {
      if (cbc.localButton.isEnabled)
        _modelController.dirty();
      else
        _modelController.clean();
    }
    else {
      _modelController.clean();
    }
    
    _modelController.dataChanged(false);
  }
  
  void selectEmitter(String name) {
    _emitterRows.forEach((_emitterRow er) => er.checkbox.setUnChecked());
    
    _emitterRow cbc = _emitterRows.firstWhere((_emitterRow er) => er.checkbox.map == name, orElse: () => null);
    if (cbc != null) {
      cbc.checkbox.setChecked();
      _currentCheckBox = cbc.checkbox;
    }
    
    _modelController.dataChanged(false);
  }
  
  void _emitterCopy(_emitterRow eRow, Emitter map) {
    particleLayer.ignoreKeyInput = true;
    _actionRow = eRow;
    
    NewEmitterDialog dialog = new NewEmitterDialog("Enter name for new emitter", "Copy of " + map.name, _copyNameEntered);
    dialog.show();
  }
  
  void _copyNameEntered(String name) {
    particleLayer.ignoreKeyInput = false;
    
    if (name != "") {
      // Uncheck any other emitter rows
      _emitterRows.forEach((_emitterRow er) => er.checkbox.setUnChecked());

      Emitter clone = _modelController.addCloneOf(name, _actionRow.map);

      _modelController.resources.files[name] = clone;
      
      _emitterRow eRow = addNewEmitter(clone, true);
      eRow.checkbox.setChecked();
      
      _modelController.activateEmitter = clone;
      
      _modelController.storeMap(clone).then((_) {
        print("Copy saved: $name");
        eRow.localButton.setDisabled();
        _modelController.dataChanged(false);
      });
    }
  }
  
  void _saveToLocal(IconButtonControl button) {
    // We don't want to use the formal dialog box as we already have
    // a name for the emitter.
    _modelController.storeToLocalByName(button.map).then((String s) {
      _saveToLocalComplete(button);
    });
  }
  
  void _saveToLocalComplete(IconButtonControl button) {
    print("stored ${button.map}");
    button.setDisabled();
    _modelController.clean();
  }
  
  void _saveToGDrive(IconButtonControl button) {
    
  }
  
  void _emitterRename(_emitterRow eRow, String name) {
    _actionRow = eRow;

    NewEmitterDialog dialog = new NewEmitterDialog("Enter new name", name, _newNameEntered);
    dialog.show();
  }
  
  void _newNameEntered(String name) {
    if (name.length > 0 && name != _actionRow.name.text) {
      _modelController.renameMap(name, _actionRow.map).then((_) {
        _actionRow.name.text = name;
        _actionRow.map = name;
      });
    }
  }
  
  void _emitterDelete(Emitter map, _emitterRow row) {
    _actionRow = row;

    YesNoDialog dialog = new YesNoDialog("Are you sure you want to Delete this emitter?", _deleteYesNoEntered);
    dialog.show();
  }
  
  void _deleteYesNoEntered(String answer) {
    if (answer == "Yes") {
      // Update local storage.
      Emitter map = _modelController.getMapByName(_actionRow.map);

      _modelController.removeMap(map).then((String message) {
        print("Map deleted: ${map.name}. Message: $message");

        List<Node> nodes = _emittersLoadedPanelElement.nodes;
        
        nodes.clear();
        _emitterRows.clear();
        
        addDefaultEmitter(_modelController.resources.defaultParticleSystem);
        
        reload();
        
        // When an emitter is deleted the behaviour is to automatically
        // select the default emitter.
        _modelController.selectMapByName = "_default";
        _emitterRows[0].checkbox.setChecked();
        
        // Finally signal that we have switched to a different emitter.
        _modelController.dataChanged(false);
      });
    }
  }

  void _emitterResetToDefault(Emitter map, _emitterRow row) {
    _actionRow = row;

    YesNoDialog dialog = new YesNoDialog("Are you sure you want to reset to defaults?", _yesNoEntered);
    dialog.show();
  }
  
  void _yesNoEntered(String answer) {
    if (answer == "Yes") {
      // Basically copy the default values.
      Emitter map = _modelController.getMapByName(_actionRow.map);
      map.equal(_modelController.resources.defaultParticleSystem);
      
      _actionRow.localButton.setEnabled();

      _modelController.dataChanged();
    }
  }

  void tabSelected() {
    _emittersTabElement.style.display = "block";
    _emittersElement.style.backgroundColor = "#aa3355";
    _emittersElement.style.height = "25px";
    _emittersElement.style.fontSize = "14px";
    _emittersElement.style.paddingLeft = "25px";
    _emittersElement.style.paddingRight = "15px";
    _tabChanged();
  }

  void hideTab() {
    _emittersTabElement.style.display = "none";
    _emittersElement.style.backgroundColor = "#aaaaaa";
    _emittersElement.style.height = "20px";
    _emittersElement.style.fontSize = "10px";
    _emittersElement.style.paddingLeft = "5px";
    _emittersElement.style.paddingRight = "5px";
  }
}