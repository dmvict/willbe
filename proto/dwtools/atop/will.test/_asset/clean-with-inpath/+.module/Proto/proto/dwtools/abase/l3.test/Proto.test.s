( function _ModuleForTesting12_test_s_( ) {

'use strict';

/*
xxx : split the test suite
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../dwtools/ModuleForTesting1.s' );

  _.include( 'wTesting' );
  _.include( 'wEqualer' );

  require( '../../abase/l3_proto/Include.s' );

}

var _global = _global_;
var _ = _global_.wModuleForTesting1;

// --
// test
// --

function instanceIs( t )
{
  var self = this;

  t.will = 'pure map';
  t.is( !_.instanceIs( Object.create( null ) ) );

  t.will = 'map';
  t.is( !_.instanceIs( {} ) );

  t.will = 'primitive';
  t.is( !_.instanceIs( 0 ) );
  t.is( !_.instanceIs( 1 ) );
  t.is( !_.instanceIs( '1' ) );
  t.is( !_.instanceIs( null ) );
  t.is( !_.instanceIs( undefined ) );

  t.will = 'routine';
  t.is( !_.instanceIs( Date ) );
  t.is( !_.instanceIs( F32x ) );
  t.is( !_.instanceIs( function(){} ) );
  t.is( !_.instanceIs( Self.constructor ) );

  t.will = 'long';
  t.is( _.instanceIs( [] ) );
  t.is( _.instanceIs( new F32x() ) );

  t.will = 'object-like';
  t.is( _.instanceIs( /x/ ) );
  t.is( _.instanceIs( new Date() ) );
  t.is( _.instanceIs( new (function(){})() ) );
  t.is( _.instanceIs( Self ) );

  t.will = 'object-like prototype';
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( [] ) ) );
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( /x/ ) ) );
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( new Date() ) ) );
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( new F32x() ) ) );
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( new (function(){})() ) ) );
  t.is( !_.instanceIs( Object.getModuleForTesting12typeOf( Self ) ) );

}

//

function instanceIsStandard( t )
{
  var self = this;

  t.will = 'pure map';
  t.is( !_.instanceIsStandard( Object.create( null ) ) );

  t.will = 'map';
  t.is( !_.instanceIsStandard( {} ) );

  t.will = 'primitive';
  t.is( !_.instanceIsStandard( 0 ) );
  t.is( !_.instanceIsStandard( 1 ) );
  t.is( !_.instanceIsStandard( '1' ) );
  t.is( !_.instanceIsStandard( null ) );
  t.is( !_.instanceIsStandard( undefined ) );

  t.will = 'routine';
  t.is( !_.instanceIsStandard( Date ) );
  t.is( !_.instanceIsStandard( F32x ) );
  t.is( !_.instanceIsStandard( function(){} ) );
  t.is( !_.instanceIsStandard( Self.constructor ) );

  t.will = 'long';
  t.is( !_.instanceIsStandard( [] ) );
  t.is( !_.instanceIsStandard( new F32x() ) );

  t.will = 'object-like';
  t.is( !_.instanceIsStandard( /x/ ) );
  t.is( !_.instanceIsStandard( new Date() ) );
  t.is( !_.instanceIsStandard( new (function(){})() ) );
  t.is( _.instanceIsStandard( Self ) );

  t.will = 'object-like prototype';
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( [] ) ) );
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( /x/ ) ) );
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( new Date() ) ) );
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( new F32x() ) ) );
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( new (function(){})() ) ) );
  t.is( !_.instanceIsStandard( Object.getModuleForTesting12typeOf( Self ) ) );

}

//

function prototypeIs( t )
{
  var self = this;

  t.will = 'pure map';
  t.is( !_.prototypeIs( Object.create( null ) ) );

  t.will = 'map';
  t.is( !_.prototypeIs( {} ) );

  t.will = 'primitive';
  t.is( !_.prototypeIs( 0 ) );
  t.is( !_.prototypeIs( 1 ) );
  t.is( !_.prototypeIs( '1' ) );
  t.is( !_.prototypeIs( null ) );
  t.is( !_.prototypeIs( undefined ) );

  t.will = 'routine';
  t.is( !_.prototypeIs( Date ) );
  t.is( !_.prototypeIs( F32x ) );
  t.is( !_.prototypeIs( function(){} ) );
  t.is( !_.prototypeIs( Self.constructor ) );

  t.will = 'object-like';
  t.is( !_.prototypeIs( [] ) );
  t.is( !_.prototypeIs( /x/ ) );
  t.is( !_.prototypeIs( new Date() ) );
  t.is( !_.prototypeIs( new F32x() ) );
  t.is( !_.prototypeIs( new (function(){})() ) );
  t.is( !_.prototypeIs( Self ) );

  t.will = 'object-like prototype';
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( [] ) ) );
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( /x/ ) ) );
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( new Date() ) ) );
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( new F32x() ) ) );
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( new (function(){})() ) ) );
  t.is( _.prototypeIs( Object.getModuleForTesting12typeOf( Self ) ) );

}

//

function constructorIs( t )
{
  var self = this;

  t.will = 'pure map';
  t.is( !_.constructorIs( Object.create( null ) ) );

  t.will = 'map';
  t.is( !_.constructorIs( {} ) );

  t.will = 'primitive';
  t.is( !_.constructorIs( 0 ) );
  t.is( !_.constructorIs( 1 ) );
  t.is( !_.constructorIs( '1' ) );
  t.is( !_.constructorIs( null ) );
  t.is( !_.constructorIs( undefined ) );

  t.will = 'routine';
  t.is( _.constructorIs( Date ) );
  t.is( _.constructorIs( F32x ) );
  t.is( _.constructorIs( function(){} ) );
  t.is( _.constructorIs( Self.constructor ) );

  t.will = 'object-like';
  t.is( !_.constructorIs( [] ) );
  t.is( !_.constructorIs( /x/ ) );
  t.is( !_.constructorIs( new Date() ) );
  t.is( !_.constructorIs( new F32x() ) );
  t.is( !_.constructorIs( new (function(){})() ) );
  t.is( !_.constructorIs( Self ) );

  t.will = 'object-like prototype';
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( [] ) ) );
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( /x/ ) ) );
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( new Date() ) ) );
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( new F32x() ) ) );
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( new (function(){})() ) ) );
  t.is( !_.constructorIs( Object.getModuleForTesting12typeOf( Self ) ) );

}

//

function prototypeIsStandard( t )
{
  var self = this;

  t.will = 'pure map';
  t.is( !_.prototypeIsStandard( Object.create( null ) ) );

  t.will = 'map';
  t.is( !_.prototypeIsStandard( {} ) );

  t.will = 'primitive';
  t.is( !_.prototypeIsStandard( 0 ) );
  t.is( !_.prototypeIsStandard( 1 ) );
  t.is( !_.prototypeIsStandard( '1' ) );
  t.is( !_.prototypeIsStandard( null ) );
  t.is( !_.prototypeIsStandard( undefined ) );

  t.will = 'routine';
  t.is( !_.prototypeIsStandard( Date ) );
  t.is( !_.prototypeIsStandard( F32x ) );
  t.is( !_.prototypeIsStandard( function(){} ) );
  t.is( !_.prototypeIsStandard( Self.constructor ) );

  t.will = 'object-like';
  t.is( !_.prototypeIsStandard( [] ) );
  t.is( !_.prototypeIsStandard( /x/ ) );
  t.is( !_.prototypeIsStandard( new Date() ) );
  t.is( !_.prototypeIsStandard( new F32x() ) );
  t.is( !_.prototypeIsStandard( new (function(){})() ) );
  t.is( !_.prototypeIsStandard( Self ) );

  t.will = 'object-like prototype';
  t.is( !_.prototypeIsStandard( Object.getModuleForTesting12typeOf( [] ) ) );
  t.is( !_.prototypeIsStandard( Object.getModuleForTesting12typeOf( /x/ ) ) );
  t.is( !_.prototypeIsStandard( Object.getModuleForTesting12typeOf( new Date() ) ) );
  t.is( !_.prototypeIsStandard( Object.getModuleForTesting12typeOf( new F32x() ) ) );
  t.is( !_.prototypeIsStandard( Object.getModuleForTesting12typeOf( new (function(){})() ) ) );
  t.is( _.prototypeIsStandard( Object.getModuleForTesting12typeOf( Self ) ) );

}

//

function accessor( test )
{

  /* */

  test.case = 'setter';
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      _aSet : function( src )
      {
        this[ Symbol.for( 'a' ) ] = src * 2;
      },
      Composes : {}
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );
  var x = new Alpha();
  x.a = 5;
  var got = x.a;
  var expected = 10;
  test.identical( got, expected );

  /* */

  test.case = 'getter';
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      _aGet : function()
      {
        return this[ Symbol.for( 'a' ) ] * 2;
      },
      Composes : {}
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );
  var x = new Alpha();
  x.a = 5;
  var got = x.a;
  var expected = 10;
  test.identical( got, expected );

  /* */

  test.case = 'getter & setter';
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      _aSet : function( src )
      {
        this[ Symbol.for( 'a' ) ] = src * 2;
      },
      _aGet : function()
      {
        return this[ Symbol.for( 'a' ) ] / 2;
      },
      Composes : {}
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );
  var x = new Alpha();
  x.a = 5;
  var got = x.a;
  var expected = 5;
  test.identical( got, expected );

  /* */

  test.case = 'has constructor only';
  var dst = { constructor : function(){}, };
  var exp = { 'constructor' : dst.constructor, 'a' : 'a1' };
  _.accessor.declare( dst, { a : 'a' } );
  dst[ Symbol.for( 'a' ) ] = 'a1';
  test.identical( dst, exp );

  /* */

  test.case = 'has Composes only';
  var dst = { Composes : {}, };
  var exp = { Composes : dst.Composes, 'a' : 'a1' };
  _.accessor.declare( dst, { a : 'a' } );
  dst[ Symbol.for( 'a' ) ] = 'a1';
  test.identical( dst, exp );

  /* - */

  if( !Config.debug )
  return;

  /* */

  test.case = 'empty call';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.declare( );
  });

  /* */

  test.case = 'invalid first argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.declare( 1, { a : 'a' } );
  });

  /* */

  test.case = 'invalid second argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.declare( {}, [] );
  });

}

//

function accessorOptionReadOnly( test )
{

  /* */

  test.case = 'control, str';

  var dst =
  {
    aGet : function() { return 'a1' },
  };

  var exp = { 'a' : 'a1', 'aGet' : dst.aGet }
  _.accessor.declare
  ({
    object : dst,
    names : { a : 'a' },
    prime : 0,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'control, map';

  var dst =
  {
    aGet : function() { return 'a1' },
  };

  var exp = { 'a' : 'a1', 'aGet' : dst.aGet }
  _.accessor.declare
  ({
    object : dst,
    names : { a : {} },
    prime : 0,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'read only explicitly, value in descriptor';

  var dst =
  {
  };

  var exp = { 'a' : 'a1' }
  _global_.debugger = 1; debugger;
  _.accessor.declare
  ({
    object : dst,
    names : { a : { readOnly : 1, get : 'a1' } },
    prime : 0,
  });
  debugger;
  test.identical( dst, exp );
  test.shouldThrowErrorSync( () => dst.a = 'a1' );

  /* */

  test.case = 'read only explicitly, value in object';

  var dst =
  {
    a : 'a1',
  };

  var exp = { 'a' : 'a1' }
  _.accessor.declare
  ({
    object : dst,
    names : { a : { readOnly : 1 } },
    prime : 0,
  });
  test.identical( dst, exp );
  test.shouldThrowErrorSync( () => dst.a = 'a1' );

  /* */

  test.case = 'read only implicitly, value in object';

  var dst =
  {
    a : 'a1',
  };

  var exp = { 'a' : 'a1' }
  _.accessor.declare
  ({
    object : dst,
    names : { a : { set : false } },
    prime : 0,
  });
  test.identical( dst, exp );
  test.shouldThrowErrorSync( () => dst.a = 'a1' );

  /* */

  test.case = 'read only implicitly, value in descriptor';

  var dst =
  {
  };

  var exp = { 'a' : 'a1' }
  _.accessor.declare
  ({
    object : dst,
    names : { a : { set : false, get : 'a1' } },
    prime : 0,
  });
  test.identical( dst, exp );
  test.shouldThrowErrorSync( () => dst.a = 'a1' );

  /* */

}

//

function accessorOptionAddingMethods( test )
{

  /* */

  test.case = 'deduce setter from put, object does not have methods, with _, addingMethods:1';
  var methods =
  {
    _aGet : function() { return this.b },
    _aPut : function( src ) { this.b = src },
  }
  var dst =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
  }
  _.accessor.declare
  ({
    object : dst,
    methods,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 0,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'deduce setter from put, object has methods, addingMethods:0';
  var dst =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aPut : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aGet : dst.aGet,
    aPut : dst.aPut,
  }
  _.accessor.declare
  ({
    object : dst,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 0,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'deduce setter from put, object has methods, addingMethods:1';
  var dst =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aPut : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aGet : dst.aGet,
    aSet : dst.aPut,
    aPut : dst.aPut,
  }
  _.accessor.declare
  ({
    object : dst,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'deduce setter from put, object has methods, with _, addingMethods:1';
  var dst =
  {
    'a' : 'a1',
    'b' : 'b1',
    _aGet : function() { return this.b },
    _aPut : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    _aGet : dst._aGet,
    aSet : dst._aPut,
    _aPut : dst._aPut,
  }
  _.accessor.declare
  ({
    object : dst,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  test.identical( dst, exp );

  /* */

  test.case = 'deduce setter from put, object does not have methods, with _, addingMethods:1';
  var methods =
  {
    _aGet : function() { return this.b },
    _aPut : function( src ) { this.b = src },
  }
  var dst =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aGet : methods._aGet,
    aSet : methods._aPut,
    aPut : methods._aPut,
  }
  _.accessor.declare
  ({
    object : dst,
    methods,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  test.identical( dst, exp );

  /* */

}

//

function accessorOptionPreserveValues( test )
{

  /* */

  test.case = 'not symbol, explicit put, preservingValue : 1';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aSet : function( src ) { this.b = src },
    aPut : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aGet : object.aGet,
    aSet : object.aSet,
    aPut : object.aPut,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    preservingValue : 1,
    prime : 0,
  });
  test.identical( object, exp );

  /* */

  test.case = 'not symbol, explicit put, preservingValue : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aSet : function( src ) { this.b = src },
    aPut : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'b1',
    'b' : 'b1',
    aGet : object.aGet,
    aSet : object.aSet,
    aPut : object.aPut,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    preservingValue : 0,
    prime : 0,
  });
  test.identical( object, exp );

  /* */

  test.case = 'not symbol, no put, preservingValue : 1';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aSet : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aGet : object.aGet,
    aSet : object.aSet,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    preservingValue : 1,
    prime : 0,
  });
  test.identical( object, exp );

  /* */

  test.case = 'not symbol, no put, preservingValue : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : function() { return this.b },
    aSet : function( src ) { this.b = src },
  };
  var exp =
  {
    'a' : 'b1',
    'b' : 'b1',
    aGet : object.aGet,
    aSet : object.aSet,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    preservingValue : 0,
    prime : 0,
  });
  test.identical( object, exp );

  /* */

  test.case = 'default getter/setter, preservingValue : 1';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
  }
  var names =
  {
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 0,
    preservingValue : 1,
  });
  test.identical( object, exp );

  /* */

  test.case = 'default getter/setter, preservingValue : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var exp =
  {
    'a' : undefined,
    'b' : 'b1',
  }
  var names =
  {
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 0,
    preservingValue : 0,
  });
  test.identical( object, exp );

  /* */

}

//

function accessorDeducingMethods( test )
{

  /* */

  function symbolPut_functor( o )
  {
    o = _.routineOptions( symbolPut_functor, arguments );
    let symbol = Symbol.for( o.fieldName );
    return function put( val )
    {
      this[ symbol ] = val;
      return val;
    }
  }

  symbolPut_functor.defaults =
  {
    fieldName : null,
  }

  symbolPut_functor.rubrics = [ 'accessor', 'put', 'functor' ];

  /* */

  test.case = 'set : false, put : explicit';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    a : { set : false, put : symbolPut_functor },
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
    preservingValue : 1,
  });
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  test.shouldThrowErrorSync( () => object.a = 'c' );
  test.identical( object, exp );

  var exp =
  {
    'a' : 'd',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  object.aPut( 'd' );
  test.identical( object, exp );

  /* */

  test.case = 'set : false';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    a : { set : false },
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
    preservingValue : 1,
  });
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  test.shouldThrowErrorSync( () => object.a = 'c' );
  test.identical( object, exp );

  var exp =
  {
    'a' : 'd',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  object.aPut( 'd' );
  test.identical( object, exp );

  /* */

  test.case = 'put : false';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    a : { put : false },
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
    preservingValue : 1,
  });
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  var exp =
  {
    'a' : 'd',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  object.aSet( 'd' );
  test.identical( object, exp );

  var exp =
  {
    'a' : 'e',
    'b' : 'b1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  object.a = 'e';
  test.identical( object, exp );

  /* */

}

//

function accessorIsClean( test )
{

  /* - */

  test.open( 'with class, readOnly:1' );

  test.case = 'setup';

  function BasicConstructor()
  {
    _.workpiece.initFields( this );
  }

  var Accessors =
  {
    f1 : { readOnly : 1 },
  }

  var Extend =
  {
    Accessors,
  }

  _.classDeclare
  ({
    cls : BasicConstructor,
    extend : Extend,
  });

  var methods = Object.create( null );
  _.accessor.declare
  ({
    object : BasicConstructor.prototype,
    names : { f2 : { readOnly : 1 } },
    methods,
  });

  var instance = new BasicConstructor();

  test.case = 'methods';

  var exp =
  {
    f2Get : methods.f2Get,
    f2Put : methods.f2Put,
  }
  test.identical( methods, exp );
  test.is( _.routineIs( methods.f2Get ) );
  test.is( _.routineIs( methods.f2Put ) );
  test.identical( _.mapKeys( methods ).length, 2 );

  test.case = 'inline no method';

  test.identical( instance._f1Get, undefined );
  test.identical( instance._f1Set, undefined );
  test.identical( BasicConstructor._f1Get, undefined );
  test.identical( BasicConstructor._f1Set, undefined );
  test.identical( BasicConstructor.prototype._f1Get, undefined );
  test.identical( BasicConstructor.prototype._f1Set, undefined );

  test.identical( instance._f2Get, undefined );
  test.identical( instance._f2Set, undefined );
  test.identical( BasicConstructor._f2Get, undefined );
  test.identical( BasicConstructor._f2Set, undefined );
  test.identical( BasicConstructor.prototype._f2Get, undefined );
  test.identical( BasicConstructor.prototype._f2Set, undefined );

  test.close( 'with class, readOnly:1' );

}

//

function accessorDeducingPrime( test )
{

  /* */

  test.case = '_.accessor.declare';

  var proto = Object.create( null );
  proto.a = 'a1';
  proto.abcGet = function()
  {
    return 'abc1';
  }

  var object = Object.create( proto );
  object.b = 'b2';

  var exp = { 'b' : 'b2', 'abc' : 'abc1' }
  var names = { abc : 'abc' }
  var o2 =
  {
    object : object,
    names : names,
  }
  _.accessor.declare( o2 );

  test.identical( o2.prime, null );
  test.identical( o2.strict, 1 );
  test.contains( object, exp );

  /* */

  test.case = '_.accessor.readOnly';

  var proto = Object.create( null );
  proto.a = 'a1';
  proto.abcGet = function()
  {
    return 'abc1';
  }

  var object = Object.create( proto );
  object.b = 'b2';

  var exp = { 'b' : 'b2', 'abc' : 'abc1' }
  var names = { abc : 'abc' }
  var o2 =
  {
    object : object,
    names : names,
  }
  _.accessor.readOnly( o2 );

  test.identical( o2.prime, null );
  test.identical( o2.strict, 1 );
  test.contains( object, exp );

  /* */

  test.case = '_.accessor.forbid';

  var proto = Object.create( null );
  proto.a = 'a1';
  proto.abcGet = function()
  {
    return 'abc1';
  }

  var object = Object.create( proto );
  object.b = 'b2';

  var exp = { 'b' : 'b2' }
  var names = { abc : 'abc' }
  var o2 =
  {
    object : object,
    names : names,
  }
  _.accessor.forbid( o2 );

  test.identical( o2.prime, 0 );
  test.identical( o2.strict, 0 );
  test.contains( object, exp );
  test.shouldThrowErrorSync( () => dst.abc );

  /* */

}

//

function accessorUnfunct( test )
{

  /* */

  test.case = 'unfunct getter';
  var counter = 0;
  function getter_functor( fop )
  {
    counter += 1;
    var exp = { fieldName : 'a' };
    test.identical( fop, exp );
    return function get()
    {
      counter += 1;
      return this.b;
    }
  }
  getter_functor.rubrics = [ 'accessor', 'getter', 'functor' ];
  getter_functor.defaults =
  {
    fieldName : null,
  }
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aGet : getter_functor,
  };
  var exp =
  {
    'a' : 'b1',
    'b' : 'b1',
    aGet : object.aGet,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    prime : 0,
    strict : 0,
  });
  test.identical( object, exp );
  test.identical( counter, 2 );

  /* */

  test.case = 'unfunct setter';
  var counter = 0;
  function setter_functor( fop )
  {
    counter += 1; debugger;
    var exp = { fieldName : 'a' };
    test.identical( fop, exp );
    return function set( src )
    {
      counter += 1; debugger;
      return this.b = src;
    }
  }
  setter_functor.rubrics = [ 'accessor', 'setter', 'functor' ];
  setter_functor.defaults =
  {
    fieldName : null,
  }
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aSet : setter_functor,
    aGet : function() { return this.b },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aSet : object.aSet,
    aGet : object.aGet,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    prime : 0,
    strict : 0,
  });
  test.identical( object, exp );
  test.identical( counter, 3 );

  object.a = 'c';
  var exp =
  {
    'a' : 'c',
    'b' : 'c',
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );
  test.identical( counter, 4 );

  /* */

  test.case = 'unfunct putter';
  var counter = 0;
  function putter_functor( fop )
  {
    counter += 1;
    var exp = { fieldName : 'a' };
    test.identical( fop, exp );
    return function set( src )
    {
      counter += 1;
      return this.b = src;
    }
  }
  putter_functor.rubrics = [ 'accessor', 'put', 'functor' ];
  putter_functor.defaults =
  {
    fieldName : null,
  }
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aPut : putter_functor,
    aGet : function() { return this.b },
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    prime : 0,
    strict : 0,
  });
  test.identical( object, exp );
  test.identical( counter, 3 );

  object.a = 'c';
  var exp =
  {
    'a' : 'c',
    'b' : 'c',
    aPut : object.aPut,
    aGet : object.aGet,
  }
  test.identical( object, exp );
  test.identical( counter, 4 );

  /* */

  test.case = 'unfunct suite';
  var counter = 0;
  function accessor_functor( fop )
  {
    counter += 1;
    var exp = { fieldName : 'a' };
    test.identical( fop, exp );
    return {
      get : function() { return this.b },
      set : function set( src )
      {
        counter += 1;
        return this.b = src;
      }
    }
  }
  accessor_functor.rubrics = [ 'accessor', 'functor' ];
  accessor_functor.defaults =
  {
    fieldName : null,
  }
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var exp =
  {
    'a' : 'a1',
    'b' : 'a1',
  }
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    suite : accessor_functor,
    prime : 0,
    strict : 0,
  });
  test.identical( object, exp );
  test.identical( counter, 2 );

  object.a = 'c';
  var exp =
  {
    'a' : 'c',
    'b' : 'c',
  }
  test.identical( object, exp );
  test.identical( counter, 3 );

  /* */

}

//

function accessorUnfunctGetSuite( test )
{

  /* - */

  function get_functor( o )
  {

    _.assert( arguments.length === 1, 'Expects single argument' );
    _.routineOptions( get_functor, o );
    _.assert( _.strDefined( o.fieldName ) );

    if( o.accessor.configurable === null )
    o.accessor.configurable = 1;
    let configurable = o.accessor.configurable;
    if( configurable === null )
    configurable = _.accessor.AccessorPreferences.configurable;
    _.assert( _.boolLike( configurable ) );

    if( o.accessorKind === 'suite' )
    {
      let result =
      {
        get : get_functor,
        set : false,
        put : false,
      }
      return result;
    }

    return function get()
    {
      if( configurable )
      {
        let o2 =
        {
          enumerable : false,
          configurable : false,
          value : 'abc3',
        }
        Object.defineProperty( this, o.fieldName, o2 );
        return 'abc2'
      }
      return 'abc1';
    }

  }

  get_functor.defaults =
  {
    fieldName : null,
    accessor : null,
    accessorKind : null,
  }

  get_functor.rubrics = [ 'accessor', 'suite', 'getter', 'functor' ];

  /* - */

  test.case = 'configurable : 1, set : 0, put : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : get_functor, set : false, put : false, configurable : true },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_' : 'abc2',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false, value : 'abc3' }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

  test.case = 'configurable : 0, set : 0, put : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : get_functor, set : false, put : false, configurable : false },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : undefined,
    'enumerable' : true,
    'configurable' : false,
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_' : 'abc1',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp =
  {
    'get' : object._Get,
    'set' : undefined,
    'enumerable' : true,
    'configurable' : false,
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

  test.case = 'configurable : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : get_functor },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true,
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' : 'abc2',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false, 'value' : 'abc3' };
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

  test.case = 'suite';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : get_functor,
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' : 'abc2',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false, 'value' : 'abc3' };
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

  test.case = 'suite in fields';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { suite : get_functor },
    a : {},
  }

  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' : 'abc2',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false, 'value' : 'abc3' };
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

  test.case = 'suite in fields, explicit configurable';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { suite : get_functor, configurable : false },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : false
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' : 'abc1',
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : false
  }
  test.identical( _.propertyDescriptorGet( object, '_' ).descriptor, exp );

  /* */

}

//

function accessorForbid( test )
{

  test.case = 'accessor forbid getter&setter';
  var Alpha = { };
  _.accessor.forbid( Alpha, { a : 'a' } );
  try
  {
    Alpha.a = 5;
  }
  catch( err )
  {
    Alpha[ Symbol.for( 'a' ) ] = 5;
  }
  var got;
  try
  {
    got = Alpha.a;
  }
  catch( err )
  {
    got = Alpha[ Symbol.for( 'a' ) ];
  }
  var expected = 5;
  test.identical( got, expected );

  if( !Config.debug ) /* */
  return;

  test.case = 'forbid get';
  test.shouldThrowErrorSync( function()
  {
    var Alpha = { };
    _.accessor.forbid( Alpha, { a : 'a' } );
    Alpha.a;
  });

  test.case = 'forbid set';
  test.shouldThrowErrorSync( function()
  {
    var Alpha = { };
    _.accessor.forbid( Alpha, { a : 'a' } );
    Alpha.a = 5;
  });

  test.case = 'empty call';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.forbid( );
  });

  test.case = 'invalid first argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.forbid( 1, { a : 'a' } );
  });

  test.case = 'invalid second argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.forbid( {}, 1 );
  });

}

//

function accessorReadOnly( test )
{
  test.case = 'readOnly';

  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend : { Composes : { a : null } }
  });
  _.accessor.readOnly( Alpha.prototype,{ a : 'a' });
  var x = new Alpha();
  test.shouldThrowErrorSync( () => x.a = 1 );
  var descriptor = Object.getOwnPropertyDescriptor( Alpha.prototype, 'a' );
  var got = descriptor.set ? true : false;
  var expected = false;
  test.identical( got, expected );

  test.case = 'saves field value';
  var Alpha = function _Alpha( a )
  {
    this[ Symbol.for( 'a' ) ] = a;
  }
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend : { Composes : { a : 6 } }
  });
  _.accessor.readOnly( Alpha.prototype, { a : 'a' } );
  var x = new Alpha( 5 );
  test.shouldThrowErrorSync( () => x.a = 1 );
  var descriptor = Object.getOwnPropertyDescriptor( Alpha.prototype, 'a' );
  var got = !descriptor.set && x.a === 5;
  var expected = true;
  test.identical( got, expected );

  if( !Config.debug )
  return;

  test.case = 'readonly';
  test.shouldThrowErrorSync( function()
  {
    var Alpha = { };
    _.accessor.readOnly( Alpha, { a : 'a' } );
    Alpha.a = 5;
  });

  test.case = 'setter defined';
  test.shouldThrowErrorSync( function()
  {
    var Alpha = { _aSet : function() { } };
    _.accessor.readOnly( Alpha, { a : 'a' } );
  });

  test.case = 'empty call';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.readOnly( );
  });

  test.case = 'invalid first argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.readOnly( 1, { a : 'a' } );
  });

  test.case = 'invalid second argument type';
  test.shouldThrowErrorSync( function()
  {
    _.accessor.readOnly( {}, [] );
  });

}

//

function forbids( test )
{

  test.open( 'pure map' );

  test.case = 'setup';

  var Forbids =
  {
    f1 : 'f1',
  }

  var instance = Object.create( null );

  _.accessor.forbid( instance, Forbids );

  test.case = 'inline no method';

  test.identical( instance._f1Get, undefined );
  test.identical( instance._f1Set, undefined );
  test.identical( _.mapProperties( instance ), Object.create( null ) );

  test.case = 'throwing';

  if( Config.debug )
  {
    test.shouldThrowErrorSync( () => instance.f1 );
  }

  test.close( 'pure map' );

  /* - */

  test.open( 'with class' );

  test.case = 'setup';

  function BasicConstructor()
  {
    _.workpiece.initFields( this );
  }

  var Forbids =
  {
    f1 : 'f1',
  }

  var Extend =
  {
    Forbids,
  }

  // Extend.constructor = BasicConstructor;

  _.classDeclare
  ({
    cls : BasicConstructor,
    extend : Extend,
  });

  var instance = new BasicConstructor();

  test.case = 'inline no method';

  test.identical( instance._f1Get, undefined );
  test.identical( instance._f1Set, undefined );
  test.identical( BasicConstructor._f1Get, undefined );
  test.identical( BasicConstructor._f1Set, undefined );
  test.identical( BasicConstructor.prototype._f1Get, undefined );
  test.identical( BasicConstructor.prototype._f1Set, undefined );

  test.case = 'throwing';

  if( Config.debug )
  {
    test.shouldThrowErrorSync( () => instance.f1 );
    test.shouldThrowErrorSync( () => BasicConstructor.prototype.f1 );
  }

  test.close( 'with class' );

}

// forbids.timeOut = 300000;

//

function forbidWithoutConstructor( test )
{

  /* */

  test.case = 'basic';

  var proto = Object.create( null );
  proto.a = 'a1';

  var dst = Object.create( proto );
  dst.b = 'b2';

  var exp = { 'b' : 'b2' }

  var names = { abc : 'abc' }
  _.accessor.forbid
  ({
    object : dst,
    names : names,
  });

  test.contains( dst, exp );
  test.shouldThrowErrorSync( () => dst.abc = 'abc' );

  /* */

}

//

function getterWithSymbol( test )
{

  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : _.accessor.getter.withSymbol, set : false, put : false },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      '_' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );

}

//

function getterToValue( test )
{

  /* */

  test.case = 'configurable : 1, set : 0, put : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : _.accessor.getter.toValue, set : false, put : false, configurable : true },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

  test.case = 'configurable : 0, set : 0, put : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : _.accessor.getter.toValue, set : false, put : false, configurable : false },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : undefined,
    'enumerable' : true,
    'configurable' : false,
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined,
      '_' : undefined,
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp =
  {
    'get' : object._Get,
    'set' : undefined,
    'enumerable' : true,
    'configurable' : false,
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

  test.case = 'configurable : 0';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { get : _.accessor.getter.toValue },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true,
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      '_Put' : undefined,
      '_Set' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined,
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false };
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

  test.case = 'suite';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : _.accessor.suite.toValue,
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      '_Put' : undefined,
      '_Set' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined,
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false };
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

  test.case = 'suite in fields';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { suite : _.accessor.suite.toValue },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : true
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      '_Put' : undefined,
      '_Set' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined,
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp = { 'writable' : false, 'enumerable' : false, 'configurable' : false };
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

  test.case = 'suite in fields, explicit configurable';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
  };
  var names =
  {
    _ : { suite : _.accessor.suite.toValue, configurable : false },
    a : {},
  }
  _.accessor.declare
  ({
    object,
    names,
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : false
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    'aSet' : object.aSet,
    'aGet' : object.aGet,
    'aPut' : object.aPut,
    '_Get' : object._Get,
    '_Put' : object._Put,
    '_Set' : object._Set,
    '_' :
    {
      'a' : 'a1',
      'b' : undefined,
      '_Get' : undefined,
      '_Put' : undefined,
      '_Set' : undefined,
      'aSet' : undefined,
      'aGet' : undefined,
      'aPut' : undefined,
      '_' : undefined,
    }
  }
  test.identical( object, exp );
  test.identical( object.a, exp.a );
  test.identical( object.b, exp.b );
  var exp =
  {
    'get' : object._Get,
    'set' : object._Set,
    'enumerable' : true,
    'configurable' : false
  }
  test.identical( _.mapBut( _.propertyDescriptorGet( object, '_' ).descriptor, [ 'value' ] ), exp );

  /* */

}

//

function putterSymbol( test )
{

  /* */

  test.case = 'addingMethods : 1';
  var object =
  {
    'a' : 'a1',
    'b' : 'b1',
    aPut : _.accessor.putter.symbol,
    aSet : function( src ) { this[ Symbol.for( 'a' ) ] = src; this.b = src },
    aGet : function() { return this[ Symbol.for( 'a' ) ] },
  };
  _.accessor.declare
  ({
    object,
    names : { a : {} },
    prime : 0,
    strict : 0,
    addingMethods : 1,
  });
  var exp =
  {
    'a' : 'a1',
    'b' : 'b1',
    aPut : object.aPut,
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );
  test.is( object.aPut !== _.accessor.putter.symbol );

  object.aPut( 'c' );
  var exp =
  {
    'a' : 'c',
    'b' : 'b1',
    aPut : object.aPut,
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  object.aSet( 'd' );
  var exp =
  {
    'a' : 'd',
    'b' : 'd',
    aPut : object.aPut,
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  object.a = 'e';
  var exp =
  {
    'a' : 'e',
    'b' : 'e',
    aPut : object.aPut,
    aSet : object.aSet,
    aGet : object.aGet,
  }
  test.identical( object, exp );

  /* */

  // test.case = 'addingMethods : 0';
  // var methods =
  // {
  //   aPut : _.accessor.putter.symbol,
  //   aSet : function( src ) { this[ Symbol.for( 'a' ) ] = src; this.b = src },
  //   aGet : function() { return this[ Symbol.for( 'a' ) ] },
  // }
  // var object =
  // {
  //   'a' : 'a1',
  //   'b' : 'b1',
  // };
  // _.accessor.declare
  // ({
  //   object,
  //   methods,
  //   names : { a : {} },
  //   prime : 0,
  //   strict : 0,
  //   addingMethods : 0,
  // });
  // var exp =
  // {
  //   'a' : 'a1',
  //   'b' : 'b1',
  // }
  // test.identical( object, exp );
  // test.is( object.aPut !== _.accessor.putter.symbol );
  //
  // _.put( object, 'a', 'c' );
  // var exp =
  // {
  //   'a' : 'c',
  //   'b' : 'b1',
  // }
  // test.identical( object, exp );
  //
  // _.set( object, 'a', 'd' );
  // var exp =
  // {
  //   'a' : 'd',
  //   'b' : 'd',
  // }
  // test.identical( object, exp );
  //
  // object.a = 'e';
  // var exp =
  // {
  //   'a' : 'e',
  //   'b' : 'e',
  // }
  // test.identical( object, exp );

  /* */

}

//

function propertyConstant( test )
{

  test.case = 'second argument is map';
  var dstMap = {};
  _.propertyConstant( dstMap, { a : 5 } );
  var descriptor = Object.getOwnPropertyDescriptor( dstMap, 'a' );
  test.identical( descriptor.writable, false );
  test.identical( dstMap.a, 5 );

  test.case = 'rewrites existing field';
  var dstMap = { a : 5 };
  _.propertyConstant( dstMap, { a : 1 } );
  var descriptor = Object.getOwnPropertyDescriptor( dstMap, 'a' );
  test.identical( descriptor.writable, false );
  test.identical( dstMap.a, 1 );

  test.case = '3 arguments';
  var dstMap = {};
  _.propertyConstant( dstMap, 'a', 5 );
  var descriptor = Object.getOwnPropertyDescriptor( dstMap, 'a' );
  test.identical( descriptor.writable, false );
  test.identical( dstMap.a, 5 );

  test.case = '2 arguments, no value';
  var dstMap = {};
  _.propertyConstant( dstMap, 'a' );
  var descriptor = Object.getOwnPropertyDescriptor( dstMap, 'a' );
  test.identical( descriptor.writable, false );
  test.identical( dstMap.a, undefined );
  test.is( 'a' in dstMap );

  test.case = 'second argument is array';
  var dstMap = {};
  _.propertyConstant( dstMap, [ 'a' ], 5 );
  var descriptor = Object.getOwnPropertyDescriptor( dstMap, 'a' );
  test.identical( descriptor.writable, false );
  test.identical( dstMap.a, 5 );

  if( !Config.debug )
  return;

  test.case = 'empty call';
  test.shouldThrowErrorSync( function()
  {
    _.propertyConstant( );
  });

  test.case = 'invalid first argument type';
  test.shouldThrowErrorSync( function()
  {
    _.propertyConstant( 1, { a : 'a' } );
  });

  test.case = 'invalid second argument type';
  test.shouldThrowErrorSync( function()
  {
    _.propertyConstant( {}, 13 );
  });

}

//

function classDeclare( test )
{
  var context = this;

  /* */

  test.case = 'first classDeclare';

  function C1()
  {
    this.instances.push( this );
  }
  var Statics1 =
  {
    instances : [],
    f1 : [],
    f2 : [],
    f3 : [],
  }
  var Extend1 =
  {
    Statics : Statics1,
    f1 : [],
    f2 : [],
    f4 : [],
  }
  var classMade = _.classDeclare
  ({
    cls : C1,
    parent : null,
    extend : Extend1,
  });

  test.identical( C1, classMade );
  test.is( C1.instances === Statics1.instances );

  test1({ Class : C1 });
  testFields( Statics1.f3 );

  /* */

  test.case = 'classDeclare with parent';

  function C2()
  {
    C1.call( this );
  }
  var classMade = _.classDeclare
  ({
    cls : C2,
    parent : C1,
  });

  test.identical( C2, classMade );

  test1({ Class : C1, Statics : Statics1 });

  test.is( C1.instances === Statics1.instances );
  test.is( C2.instances === C1.instances );

  test1({ Class : C2, Class0 : C1, Statics : Statics1, ownStatics : 0 });

  /* */

  test.case = 'classDeclare with supplement';

  function Csupplement()
  {
    C1.call( this );
  }
  var Statics2 =
  {
    instances : [],
  }
  var classMade = _.classDeclare
  ({
    cls : Csupplement,
    parent : C1,
    supplement : { Statics : Statics2 },
  });

  test.identical( Csupplement,classMade );

  test1({ Class : C1, Statics : Statics1 });
  test1({ Class : Csupplement, Class0 : C1, Statics : Statics1, ownStatics : 0 });

  /* */

  test.case = 'classDeclare with extend';

  function C3()
  {
    C1.call( this );
  }
  var Associates =
  {
  }
  var Statics2 =
  {
    instances : [],
    f1 : [],
    f4 : [],
  }
  var Extend2 =
  {
    Statics : Statics2,
    Associates,
    f2 : [],
    f3 : [],
  }
  var classMade = _.classDeclare
  ({
    cls : C3,
    parent : C1,
    extend : Extend2,
    allowingExtendStatics : 1,
  });

  test.identical( C3, classMade );

  test1({ Class : C1, Statics : Statics1 });
  test1
  ({
    Class : C3,
    Class0 : C1,
    Statics : Statics2,
    Extend : Extend2,
    keys : [ 'instances', 'f1', 'f4', 'f2', 'f3' ],
    vals : [ C3.instances, C3.f1, C3.f4, C1.f2, C1.f3 ],
  });

  testFields( Extend2.f3 );
  testFields2();

  if( !Config.debug )
  return;

  test.case = 'attempt to extend statics without order';

  test.shouldThrowErrorSync( function()
  {

    function C3()
    {
      C1.call( this );
    }
    var Associates =
    {
    }
    var Statics2 =
    {
      instances : [],
      f1 : [],
      f4 : [],
    }
    var Extend2 =
    {
      Statics : Statics2,
      Associates,
      f2 : [],
      f3 : [],
    }
    var classMade = _.classDeclare
    ({
      cls : C3,
      parent : C1,
      extend : Extend2,
    });

  });

  /* */

  function test1( o )
  {

    if( o.ownStatics === undefined )
    o.ownStatics = 1;

    if( !o.Statics )
    o.Statics = Statics1;

    if( !o.Extend )
    o.Extend = Extend1;

    if( !o.keys )
    o.keys = _.mapKeys( o.Statics );

    if( !o.vals )
    o.vals = _.mapVals( o.Statics );

    var C0proto = null;
    if( !o.Class0 )
    {
      o.Class0 = Function.prototype;
    }
    else
    {
      C0proto = o.Class0.prototype;
    }

    test.case = 'presence of valid prototype and constructor fields on class and prototype';

    test.identical( o.Class, o.Class.prototype.constructor );
    test.identical( Object.getModuleForTesting12typeOf( o.Class ), o.Class0 );
    test.identical( Object.getModuleForTesting12typeOf( o.Class.prototype ), C0proto );

    test.case = 'presence of valid static field on class and prototype';

    test.identical( o.Class.instances, o.Class.prototype.instances );

    test.case = 'getting property descriptor of static field from constructor';

    var cd = Object.getOwnPropertyDescriptor( o.Class, 'instances' );
    if( !o.ownStatics )
    {
      test.identical( cd, undefined );
    }
    else
    {
      test.identical( cd.configurable, true );
      test.identical( cd.enumerable, true );
      test.is( !!cd.get );
      test.is( !!cd.set );
    }

    var pd = Object.getOwnPropertyDescriptor( o.Class.prototype, 'instances' );

    if( !o.ownStatics )
    {
      test.identical( pd, undefined );
    }
    else
    {
      test.identical( pd.configurable, true );
      test.identical( pd.enumerable, false );
      test.is( !!pd.get );
      test.is( !!pd.set );
    }

    test.case = 'making the first instance';

    var c1a = new o.Class();

    test.case = 'presence of valid static field on all';

    if( o.Class !== C1 && !o.ownStatics )
    test.is( o.Class.instances === C1.instances );
    test.is( o.Class.instances === o.Class.prototype.instances );
    test.is( o.Class.instances === c1a.instances );
    test.is( o.Class.instances === o.Statics.instances );
    test.identical( o.Class.instances.length, o.Statics.instances.length );
    test.identical( o.Class.instances[ o.Statics.instances.length-1 ], c1a );

    test.case = 'presence of valid prototype and constructor fields on instance';

    test.identical( Object.getModuleForTesting12typeOf( c1a ), o.Class.prototype );
    test.identical( c1a.constructor, o.Class );

    test.case = 'presence of valid Statics descriptor';

    test.is( o.Statics !== o.Class.prototype.Statics );
    test.is( o.Statics !== c1a.Statics );

    test.identical( _.mapKeys( c1a.Statics ), o.keys );
    test.identical( _.mapVals( c1a.Statics ), o.vals );
    test.identical( o.Class.Statics, undefined );

    if( !C0proto )
    {
      var r = _.entityIdentical( o.Class.prototype.Statics, o.Statics );
      test.identical( o.Class.prototype.Statics, o.Statics );
      test.identical( c1a.Statics, o.Statics );
    }

    test.case = 'presence of conflicting fields';

    test.is( o.Class.prototype.f1 === c1a.f1 );
    test.is( o.Class.prototype.f2 === c1a.f2 );
    test.is( o.Class.prototype.f3 === c1a.f3 );
    test.is( o.Class.prototype.f4 === c1a.f4 );

    test.case = 'making the second instance';

    var c1b = new o.Class();
    test.identical( o.Class.instances, o.Class.prototype.instances );
    test.identical( o.Class.instances, c1a.instances );
    test.identical( o.Class.instances.length, o.Statics.instances.length );
    test.identical( o.Class.instances[ o.Statics.instances.length-2 ], c1a );
    test.identical( o.Class.instances[ o.Statics.instances.length-1 ], c1b );

    test.case = 'setting static field with constructor';

    o.Class.instances = o.Class.instances.slice();
    // test.is( o.Class === C1 || o.Class.instances !== C1.instances );
    debugger;
    test.is( o.Class.instances === C1.instances || _.mapOwnKey( o.Class.prototype.Statics, 'instances' ) );
    debugger;
    test.is( o.Class.instances === o.Class.prototype.instances );
    test.is( o.Class.instances === c1a.instances );
    test.is( o.Class.instances === c1b.instances );
    test.is( o.Class.instances !== o.Statics.instances );
    o.Class.instances = Statics1.instances;

    test.case = 'setting static field with prototype';

    o.Class.prototype.instances = o.Class.prototype.instances.slice();
    // if( o.Class !== C1 && !o.ownStatics )
    // test.is( o.Class === C1 || o.Class.instances !== C1.instances );
    test.is( o.Class.instances === C1.instances || _.mapOwnKey( o.Class.prototype.Statics, 'instances' ) );
    test.is( o.Class.instances === o.Class.prototype.instances );
    test.is( o.Class.instances === c1a.instances );
    test.is( o.Class.instances === c1b.instances );
    test.is( o.Class.instances !== o.Statics.instances );
    o.Class.instances = Statics1.instances;

    test.case = 'setting static field with instance';

    c1a.instances = o.Class.instances.slice();
    // if( o.Class !== C1 && !o.ownStatics )
    // test.is( o.Class === C1 || o.Class.instances !== C1.instances );
    test.is( o.Class.instances === C1.instances || _.mapOwnKey( o.Class.prototype.Statics, 'instances' ) );
    test.is( o.Class.instances === o.Class.prototype.instances );
    test.is( o.Class.instances === c1a.instances );
    test.is( o.Class.instances === c1b.instances );
    test.is( o.Class.instances !== o.Statics.instances );
    o.Class.instances = Statics1.instances;

  }

  /* */

  function testFields( f3 )
  {

    test.case = 'presence of conflicting fields in the first class';

    test.is( Statics1.f1 === C1.f1 );
    test.is( Extend1.f1 === C1.prototype.f1 );

    test.is( Statics1.f2 === C1.f2 );
    test.is( Extend1.f2 === C1.prototype.f2 );

    test.is( f3 === C1.f3 );
    test.is( f3 === C1.prototype.f3 );

    test.is( Statics1.f4 === undefined );
    test.is( Statics1.f4 === C1.f4 );
    test.is( Extend1.f4 === C1.prototype.f4 );

    var d = Object.getOwnPropertyDescriptor( C1,'f1' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

    var d = Object.getOwnPropertyDescriptor( C1.prototype,'f1' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

    var d = Object.getOwnPropertyDescriptor( C1,'f2' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

    var d = Object.getOwnPropertyDescriptor( C1.prototype,'f2' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

    var d = Object.getOwnPropertyDescriptor( C1,'f3' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    var d = Object.getOwnPropertyDescriptor( C1.prototype,'f3' );
    test.is( d.enumerable === false );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    var d = Object.getOwnPropertyDescriptor( C1,'f4' );
    test.is( !d );

    var d = Object.getOwnPropertyDescriptor( C1.prototype,'f4' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

  }

  /* */

  function testFields2()
  {

    test.case = 'presence of conflicting fields in the second class';

    test.is( Statics2.f1 === C3.f1 );
    test.is( Statics2.f1 === C3.prototype.f1 );

    test.is( Statics1.f2 === C3.f2 );
    test.is( Extend2.f2 === C3.prototype.f2 );

    test.is( Extend2.f3 === C3.f3 );
    test.is( Extend2.f3 === C3.prototype.f3 );

    test.is( Statics2.f4 === C3.f4 );
    test.is( Statics2.f4 === C3.prototype.f4 );

    var d = Object.getOwnPropertyDescriptor( C3,'f1' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    var d = Object.getOwnPropertyDescriptor( C3.prototype,'f1' );
    test.is( d.enumerable === false );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    var d = Object.getOwnPropertyDescriptor( C3,'f2' );
    test.is( !d );

    var d = Object.getOwnPropertyDescriptor( C3.prototype,'f2' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( d.writable === true );
    test.is( !!d.value );

    var d = Object.getOwnPropertyDescriptor( C3,'f3' );
    test.is( !d );

    var d = Object.getOwnPropertyDescriptor( C3.prototype,'f3' );
    test.is( !d );

    var d = Object.getOwnPropertyDescriptor( C3,'f4' );
    test.is( d.enumerable === true );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    var d = Object.getOwnPropertyDescriptor( C3.prototype,'f4' );
    test.is( d.enumerable === false );
    test.is( d.configurable === true );
    test.is( !!d.get );
    test.is( !!d.set );

    test.case = 'assigning static fields';

    C1.f1 = 1;
    C1.f2 = 2;
    C1.f3 = 3;
    C1.f4 = 4;

    C1.prototype.f1 = 11;
    C1.prototype.f2 = 12;
    C1.prototype.f3 = 13;
    C1.prototype.f4 = 14;

    C2.f1 = 21;
    C2.f2 = 22;
    C2.f3 = 23;
    C2.f4 = 24;

    C2.prototype.f1 = 31;
    C2.prototype.f2 = 32;
    C2.prototype.f3 = 33;
    C2.prototype.f4 = 34;

    test.identical( C1.f1,1 );
    test.identical( C1.f2,2 );
    debugger;
    test.identical( C1.f3,33 );
    debugger;
    test.identical( C1.f4,4 );

    test.identical( C1.prototype.f1,11 );
    test.identical( C1.prototype.f2,12 );
    test.identical( C1.prototype.f3,33 );
    test.identical( C1.prototype.f4,14 );

    test.identical( C2.f1,21 );
    test.identical( C2.f2,22 );
    test.identical( C2.f3,33 );
    test.identical( C2.f4,24 );

    test.identical( C2.prototype.f1,31 );
    test.identical( C2.prototype.f2,32 );
    test.identical( C2.prototype.f3,33 );
    test.identical( C2.prototype.f4,34 );

  }

}

//

function callable( test )
{

  class Cls extends _.CallableObject
  {
    constructor()
    {
      let self = super();
      self.x = 1;
      return self;
    }
    __call__( y )
    {
      return this.x+y;
    }
  }

  var ins = new Cls;
  var got = ins( 5 );
  test.identical( got, 6 );
  var got = ins.x;
  test.identical( got, 1 );

}

//

function accessorSupplement( test )
{
  test.case = 'supplement Beta with accessor "a" declared on Alpha'
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      Composes : {},
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );

  var Beta = function _Beta(){}
  _.classDeclare
  ({
    cls : Beta,
    parent : null,
    extend :
    {
      Accessors : {}
    }
  });
  _.accessor.supplement( Beta.prototype,Alpha.prototype );

  var x = new Beta();
  x.a = 2;
  test.identical( x.a, 2 );

  test.case = 'supplement Beta with accessor "a" declared on Alpha, Beta has accessor "b"'
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      Composes : {},
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );

  var Beta = function _Beta(){}
  _.classDeclare
  ({
    cls : Beta,
    parent : null,
    extend :
    {
      Accessors : {}
    }
  });
  _.accessor.declare( Beta.prototype, { b : 'b' } );

  _.accessor.supplement( Beta.prototype,Alpha.prototype );

  var x = new Beta();
  x.a = 2;
  x.b = 4;
  test.identical( x.a, 2 );
  test.identical( x.b, 4 );

  //

  test.case = 'supplement Beta with accessors of Alpha, both have same accessor'
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      Composes : {},
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );

  var Beta = function _Beta(){}
  _.classDeclare
  ({
    cls : Beta,
    parent : null,
    extend :
    {
      _aGet : function()
      {
        return this[ Symbol.for( 'a' ) ] * 2;
      },
      Accessors : {}
    }
  });
  _.accessor.declare( Beta.prototype, { a : 'a' } );

  _.accessor.supplement( Beta.prototype,Alpha.prototype );

  var x = new Beta();
  x.a = 2;
  test.identical( x.a, 4 );

  //

  test.case = 'Alpha: a, b - getter, c - setter, Beta: a - getter'
  var Alpha = function _Alpha(){}
  _.classDeclare
  ({
    cls : Alpha,
    parent : null,
    extend :
    {
      _bGet : function()
      {
        return this[ Symbol.for( 'b' ) ] * 2;
      },
      _cSet : function( src )
      {
        this[ Symbol.for( 'c' ) ] = src * 2;
      },
      Composes : {},
    }
  });
  _.accessor.declare( Alpha.prototype, { a : 'a' } );
  _.accessor.declare( Alpha.prototype, { b : 'b' } );
  _.accessor.declare( Alpha.prototype, { c : 'c' } );

  var Beta = function _Beta(){}
  _.classDeclare
  ({
    cls : Beta,
    parent : null,
    extend :
    {
      _aGet : function()
      {
        return this[ Symbol.for( 'a' ) ] * 2;
      },
      Accessors : {}
    }
  });

  _.accessor.declare( Beta.prototype, { a : 'a' } );
  _.accessor.supplement( Beta.prototype,Alpha.prototype );

  var x = new Beta();
  x.a = 2;
  x.b = 3;
  x.c = 4;
  test.identical( x[ Symbol.for( 'a' ) ], 2 );
  test.identical( x[ Symbol.for( 'b' ) ], 3 );
  test.identical( x[ Symbol.for( 'c' ) ], 8 );
  test.identical( x.a, 4 );
  test.identical( x.b, 6 );
  test.identical( x.c, 8 );

}

// --
// declare
// --

var Self =
{

  name : 'ModuleForTesting1.base.l3.proto',
  silencing : 1,

  tests :
  {

    instanceIs,
    instanceIsStandard,
    prototypeIs,
    constructorIs,
    prototypeIsStandard,

    accessor,
    accessorOptionReadOnly,
    accessorOptionAddingMethods,
    accessorOptionPreserveValues,
    accessorDeducingMethods,
    accessorIsClean,
    accessorDeducingPrime,
    accessorUnfunct,
    accessorUnfunctGetSuite,

    accessorForbid,
    accessorReadOnly,
    forbids,
    forbidWithoutConstructor,

    getterWithSymbol,
    getterToValue,
    putterSymbol,

    propertyConstant,

    callable,

    accessorSupplement

  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
