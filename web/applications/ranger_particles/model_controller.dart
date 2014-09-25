library app_model;

import 'dart:async';
import 'package:ranger/ranger.dart' as Ranger;

import 'panels/emitters_tab.dart';
import 'panels/emitter_properties_tab.dart';
import 'particle_layer.dart';
import 'resources/resources.dart';
import 'panels/active_emitter_title_panel.dart';
import 'data/emitter.dart';

/*
  */
class ModelController {
  EmittersTab emitterTab;
  EmitterPropertiesTab emitterPropertiesTab;
  
  ParticleLayer particleLayer;
  Resources _resources;
  
  Emitter _activeMap;
  
  Map<int, String> _emitterTypesNToName = {
                                           0: 'UniDirectional', 
                                           1: 'OmniDirectional', 
                                           2: 'DriftDirectional', 
                                           3: 'FixedDirectional', 
                                           4: 'RangeSweepPingPong', 
                                           5: 'FullRadialSweep'};
  Map<String, int> _emitterTypesNameToN = {
                                           'UniDirectional': 0, 
                                           'OmniDirectional': 1, 
                                           'DriftDirectional': 2, 
                                           'FixedDirectional': 3, 
                                           'RangeSweepPingPong': 4,
                                           'FullRadialSweep': 5};

  ActiveEmitterTitlePanel _activeEmitterTitleControl;
  
  ModelController(Resources resources) {
    _resources = resources;
    
    _activeEmitterTitleControl = new ActiveEmitterTitlePanel(this);
    _activeEmitterTitleControl.init();
  }
  
  Iterable<Emitter> get maps => _resources.files.values;
  Resources get resources => _resources;
  Emitter get defaultEmitter => resources.defaultParticleSystem;
  
  set activateEmitter(Emitter m) {
    _activeMap = m;
    activeEmitterTitle = _activeMap.name;
  }
  
  Emitter get activeMap => _activeMap;
  
  String get selectedMapName => _activeMap.name;
  
  set selectMapByName(String name) {
    activateEmitter = getMapByName(name);
  }
  
  Emitter getMapByName(String name) {
    Emitter map;
    if (name == "_default")
      map = _resources.defaultParticleSystem;
    else {
      try {
        map = maps.firstWhere((Emitter m) => m.name == name);
      }
      catch (e) {
        map = _resources.defaultParticleSystem;
      }
    }
    return map;
  }
  
  set activeEmitterTitle(String title) => _activeEmitterTitleControl.title = title;

  Emitter addCloneOf(String name, String prototypeName) {
    Emitter map = getMapByName(prototypeName);
    
    // NOTE! Map.from only performs a shallow copy!
    //Map clone = new Map.from(map);
    Emitter clone = new Emitter.clone(map);
    clone.name = name;
    
    return clone;
  }

  void renameMapByName(String mapName, String name) {
    Emitter map = getMapByName(mapName);
    map.name = name;
  }
  
  void emitterChanged() {
    emitterTab.selectEmitter(selectedMapName);
  }
  
  void clean() {
    _activeEmitterTitleControl.dirty = false;
  }
  
  void dirty() {
    _activeEmitterTitleControl.dirty = true;
  }
  
  void fireParticle() {
    particleLayer.fireParticle = true;
  }
  
  void explode() {
    particleLayer.explode();
  }
  
  void dataChanged([bool changedByUser = true]) {
    Ranger.ModerateParticleSystem ps = particleLayer.ps;
    
    particleLayer.emissionType = emitterTypeAsIndex;
    
    Ranger.ParticleActivation pa = ps.particleActivation;
    Ranger.RandomValueParticleActivator rvpa = ps.particleActivation as Ranger.RandomValueParticleActivator;
    
    rvpa.angleDirection = pa.sweepAngle = _activeMap.angle;
    rvpa.angleVariance = _activeMap.variance;
    rvpa.sweepAngleRate = _activeMap.sweepRate;

    rvpa.lifespan.min = _activeMap.minLife;
    rvpa.lifespan.max = _activeMap.maxLife;
    rvpa.lifespan.variance = _activeMap.varianceLife;
    rvpa.lifespan.mean = _activeMap.meanLife / 100.0;

    rvpa.speed.min = _activeMap.minSpeed;
    rvpa.speed.max = _activeMap.maxSpeed;
    rvpa.speed.variance = _activeMap.varianceSpeed;
    rvpa.speed.mean = _activeMap.meanSpeed / 100.0;

    rvpa.acceleration.min = _activeMap.minAcceleration;
    rvpa.acceleration.max = _activeMap.maxAcceleration;
    rvpa.acceleration.variance = _activeMap.varianceAcceleration;
    rvpa.acceleration.mean = _activeMap.meanAcceleration / 100.0;

    rvpa.startScale.min = _activeMap.minStartScale;
    rvpa.startScale.max = _activeMap.maxStartScale;
    rvpa.startScale.variance = _activeMap.varianceStartScale;
    rvpa.startScale.mean = _activeMap.meanStartScale / 100.0;

    rvpa.endScale.min = _activeMap.minEndScale;
    rvpa.endScale.max = _activeMap.maxEndScale;
    rvpa.endScale.variance = _activeMap.varianceEndScale;
    rvpa.endScale.mean = _activeMap.meanEndScale / 100.0;

    rvpa.rotationRate.min = _activeMap.minRotationRate;
    rvpa.rotationRate..max = _activeMap.maxRotationRate;
    rvpa.rotationRate.variance = _activeMap.varianceRotationRate;
    rvpa.rotationRate.mean = _activeMap.meanRotationRate / 100.0;

    rvpa.delay.min = _activeMap.minParticleDelay / 1000.0;
    rvpa.delay.max = _activeMap.maxParticleDelay / 1000.0;
    rvpa.delay.variance = _activeMap.varianceParticleDelay / 1000.0;
    rvpa.delay.mean = _activeMap.meanParticleDelay / 100.0;

    ps.delayParticles = _activeMap.EnabledParticleDelay;
    
    particleLayer.constantFire = _activeMap.continuousEnabled;
    
    rvpa.syncSpeedToScale = _activeMap.syncSpeedToScale;
    
    ps.emitterDuration = _activeMap.emitterDuration / 1000.0;
    ps.pauseFor = _activeMap.pauseFor / 1000.0;
    ps.durationEnabled = _activeMap.durationEnabled;
    
    // Tint
    // We currently only handle the first and last color stop values.
    rvpa.startColor = _activeMap.getColor(0);
    rvpa.endColor = _activeMap.getColor(1);
    
    // Emission Rate
    ps.emissionRate = _activeMap.emissionRate;
    //ps.emissionRateMax = _activeMap.maxEmissionRate;
    //ps.emissionRateVariance = _activeMap.varianceEmissionRate;
    //ps.meanEmissionRate = _activeMap.meanEmissionRate / 100.0;
    //ps.calcEmissionRate();
    
    particleLayer.reconfigure();
    
    emitterTab.dataChanged(changedByUser);
    if (changedByUser)
      dirty();
    
    emitterPropertiesTab.dataChanged(changedByUser);
  }

  Future<String> addToLocal(Emitter map) {
    return storeMap(map);
  }

  Future<String> storeToLocalByName(String name) {
    Emitter map = getMapByName(name);
    return storeMap(map);
  }

  Future<String> storeMap(Emitter map) {
    Future<String> f = _resources.saveFile(map.name, map);    
    
    return f;
  }

  Future<String> removeMap(Emitter map) {
    Future<String> f = _resources.removeFile(map.name);    
    
    return f;
  }

  Future<String> renameMap(String newName, String oldName) {
    Emitter map = getMapByName(oldName);
    Future<String> f = _resources.renameFile(newName, map.name);    
    
    return f;
  }

  set emitterTypeByIndex(int index) {
    _activeMap.emitterType = getEmitterTypeAsName(index);
  }
  
  set emitterTypeByName(String name) {
    _activeMap.emitterType = name;
  }
  
  int get emitterTypeAsIndex {
    String type = _activeMap.emitterType;
    return _emitterTypesNameToN[type];
  }
  
  String getEmitterTypeAsName(int index) {
    return _emitterTypesNToName[index];
  }
  
  @override
  String toString() {
    String s = "---------------\n";
    maps.forEach((Emitter m) => s += m.toString() + "\n");
    s += defaultEmitter.toString();
    return s; 
  }
}