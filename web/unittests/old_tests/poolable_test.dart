import 'package:ranger/ranger.dart' as Ranger;

class _StringComponent extends Ranger.ComponentPoolable {
  String s;

  _StringComponent._();
  factory _StringComponent(String s) {
    _StringComponent poolable = new Ranger.Poolable.of(_StringComponent, _constructor);
    poolable.s = s;
    return poolable;
  }

  static _StringComponent _constructor() => new _StringComponent._();
  static _StringComponent createPoolable() => _constructor();
  
  String toString() => s;
}

class _IntComponent extends Ranger.ComponentPoolable {
  int i;

  _IntComponent._();
  factory _IntComponent(int i) {
    _IntComponent poolable = new Ranger.Poolable.of(_IntComponent, _constructor);
    poolable.i = i;
    return poolable;
  }
  
  static _IntComponent _constructor() => new _IntComponent._();
  static _IntComponent createPoolable() => _constructor();
  
  String toString() => i.toString();
}

void poolsTests() {
//  _StringComponent ps = new _StringComponent("Hello1");
//  ps.moveToPool();
//  expect(ObjectPool.types, equals(1));
//  expect(ObjectPool.getSize(_StringComponent), equals(1));
//
//  _StringComponent ps = new _StringComponent("Hello1");
//  ps.moveToPool();
//  _StringComponent ps2 = new _StringComponent("Hello2");
//  ps2.moveToPool();
//  // We still only expect their to be only one "Type" of object
//  // in the object pools.
//  expect(ObjectPool.types, equals(1));
//  expect(ObjectPool.getSize(_StringComponent), equals(1));
//
//  _StringComponent ps = new _StringComponent("Hello1");
//  ps.moveToPool();
//  _IntComponent ps2 = new _IntComponent(42);
//  ps2.moveToPool();
//  // We expect their to be two "Type"s of objects
//  // in the object pools.
//  expect(ObjectPool.types, equals(2));
//  expect(ObjectPool.getSize(_StringComponent), equals(1));
//  expect(ObjectPool.getSize(_IntComponent), equals(1));
//
//  _StringComponent ps = new _StringComponent("Hello1");
//  ps.moveToPool();
//  // "add"s a component type if it does exist or it
//  // removes the component from the pool and returns it.
//  _IntComponent ps2 = ObjectPool.get(_IntComponent, _IntComponent.createPoolable);
//  ps2.i = 42;
//  // We expect their to be two "Type"s of object pools.
//  expect(ObjectPool.types, equals(2));
//  // The string component is still in the pool
//  expect(ObjectPool.getSize(_StringComponent), equals(1));
//  // The integer component was retrieved from the pool
//  // so the size should be zero.
//  expect(ObjectPool.getSize(_IntComponent), equals(0));
//  
//  // We are done with the integer component. put it back in
//  // the pool.
//  ps2.moveToPool();
//  expect(ObjectPool.getSize(_IntComponent), equals(1));
//
//  // "add"s a component type if it does exist or it
//  // removes the component from the pool and returns it.
//  _IntComponent ps2 = ObjectPool.get(_IntComponent, _IntComponent.createPoolable);
//  // The previous test put "42" back in the pool. We just pull it out.
//  expect(ps2.i, equals(42));
//  
//  // The integer component was retrieved from the pool
//  // so the size should be zero.
//  expect(ObjectPool.getSize(_IntComponent), equals(0));
//  
//  ps2.i = 666;
//  // We are done with the integer component. put it back in
//  // the pool.
//  ps2.moveToPool();
//  expect(ObjectPool.getSize(_IntComponent), equals(1));
//
//  // "add"s a component type if it does exist or it
//  // removes the component from the pool and returns it.
//  _IntComponent c = new _IntComponent(13163);
//  c.moveToPool();
//  c.moveToPool();
//  // The integer component was retrieved from the pool
//  // so the size should be zero.
//  expect(ObjectPool.getSize(_IntComponent), equals(2));      
//
//  ObjectPool.drain(_IntComponent);
//  expect(ObjectPool.getSize(_IntComponent), equals(0));
//  
//  // "add"s a component type if it does exist or it
//  // removes the component from the pool and returns it.
//  _IntComponent c = new _IntComponent(13163);
//  expect(ObjectPool.getSize(_IntComponent), equals(0));
//  c.moveToPool();
//  expect(ObjectPool.getSize(_IntComponent), equals(1));
//  // We shouldn't consider it's value in multi-threaded environments.
//  expect(c.i, equals(13163));
//
//  // 13163 was pulled from the pool and is now overridden with 42
//  // Note: "new" pulls from the pool, so the size shrinks.
//  _IntComponent c2 = new _IntComponent(42);
//  expect(ObjectPool.getSize(_IntComponent), equals(0));
//  expect(c2.i, equals(42));
//
//  ObjectPool.addMany(_IntComponent, _IntComponent.createPoolable, 10);
//  // At this point in the test their should already
//  // be 2 types in the type pools.
//  expect(ObjectPool.types, equals(2));
//  expect(ObjectPool.getSize(_StringComponent), equals(1));
//  expect(ObjectPool.getSize(_IntComponent), equals(12));
}