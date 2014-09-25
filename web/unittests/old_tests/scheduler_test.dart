library poolable_test;

import 'package:unittest/unittest.dart';

import 'package:ranger/ranger.dart' as Ranger;

class TT extends Ranger.TimingTarget {
  double i = 0.0;
  void update(double dt) {
    i += dt;
    if (i > 1.0) {
      print("TT");
      i = 0.0;
    }
  }
}

class TT2 extends Ranger.TimingTarget {
  double i = 0.0;
  void update(double dt) {
    i += dt;
    if (i > 1.0) {
      print("TT2");
      i = 0.0;
    }
  }
}

class TT3 extends Ranger.TimingTarget {
  double i = 0.0;
  void update(double dt) {
    i += dt;
    if (i > 0.5) {
      print("TT3");
      i = 0.0;
    }
  }
}

void main(Ranger.Application app) {
  group('Scheduler tests', () {
    
    setUp(() {
    });
    
    test('One timer', () {
      TT target = new TT();
//      TT2 target2 = new TT2();
      
//  target.priority = -1;
//  app.scheduler.scheduleTimingTarget(target);

      app.scheduler.scheduleUpdateTarget(target.update, 2.0, 2, 0.0, false);
//      expectAsync0(target.update, count: 2);
//      expectAsyncUntil0(target.update, target.update);
      
      //app.scheduler.scheduleUpdateTarget(target2.update, 4.0, 2, 0.0, false);
//      expect(ObjectPool.getSize(_StringComponent), equals(1));
    });

    test('One timer scheduled twice', () {
      TT target = new TT();

      app.scheduler.scheduleUpdateTarget(target.update, 2.0, 2, 0.0, false);
      app.scheduler.scheduleUpdateTarget(target.update, 4.0, 2, 0.0, false);
    });

  });
}