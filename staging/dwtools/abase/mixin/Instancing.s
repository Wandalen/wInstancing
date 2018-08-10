( function _Instancing_s_() {

'use strict';

/**
  @module Tools/mixin/Instancing - Mixin adds instances accounting functionality to a class. Instancing makes possible to iterate instances of the specific class, optionally create names map or class name map in case of a complicated hierarchical structure. Use Instancing to don't repeat yourself. Refactoring required.
*/

/**
 * @file Instancing.s.
 */

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wProto' );

}

//

var _global = _global_;
var _ = _global_.wTools;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

//

/**

 * Mixin instancing into prototype of another object.
 * @param {object} dstPrototype - prototype of another object.
 * @method onMixin
 * @memberof wInstancing#

 * @example of constructor cloning source
  var Self = function ClassName( o )
  {
    if( !( this instanceof Self ) )
    return new( _.routineJoin( Self, Self, arguments ) );
    return Self.prototype.init.apply( this,arguments );
  }

  * @example of constructor returning source if source is instance
  var Self = function ClassName( o )
  {
  return _.instanceConstructor( Self, this, arguments );
}

 */

function onMixin( mixinDescriptor, dstClass )
{
  /* xxx : clean it */

  var dstPrototype = dstClass.prototype;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.routineIs( dstClass ) );
  _.assert( !dstPrototype.instances,'class already has mixin',Self.name );
  _.assert( _.mapKeys( Supplement ).length === 8 );

  _.mixinApply( this, dstPrototype );

  // _.mixinApply
  // ({
  //   dstPrototype : dstPrototype,
  //   descriptor : Self,
  // });
  //
  // var instances = [];
  // var instancesMap = Object.create( null );

  _.accessorForbid
  ({
    object : dstPrototype.constructor.instancesMap,
    prime : 0,
    names : { null : 'null', undefined : 'undefined' },
  });

  _.assert( _.mapKeys( Supplement ).length === 8 );

  /* */

  // _.constant( dstPrototype.constructor,{ usingUniqueNames : dstPrototype.usingUniqueNames } );
  // _.constant( dstPrototype,{ usingUniqueNames : dstPrototype.usingUniqueNames } );
  //
  // _.constant( dstPrototype.constructor,{ instances : instances });
  // _.constant( dstPrototype,{ instances : instances });
  //
  // _.constant( dstPrototype.constructor,{ instancesMap : instancesMap });
  // _.constant( dstPrototype,{ instancesMap : instancesMap });

  _.accessorReadOnly
  ({
    object : [ dstPrototype.constructor, dstPrototype ],
    methods : Supplement,
    names :
    {
      firstInstance : { readOnlyProduct : 0 },
    },
    preserveValues : 0,
    prime : 0,
  });

  // _.assert( _.mapKeys( Supplement ).length === 8 );
  // debugger;
  _.accessorReadOnly
  ({
    object : dstPrototype.constructor.prototype,
    methods : Supplement,
    names :
    {
      instanceIndex : { readOnly : 1, readOnlyProduct : 0 },
    },
    preserveValues : 0,
    combining : 'supplement',
  });
  // _.assert( _.mapKeys( Supplement ).length === 8 );
  // debugger;

  _.accessor
  ({
    object : dstPrototype.constructor.prototype,
    methods : Supplement,
    names :
    {
      name : 'name',
    },
    preserveValues : 0,
    combining : 'supplement',
  });

  _.accessorForbid
  ({
    object : dstPrototype.constructor,
    prime : 0,
    names : { instance : 'instance' },
  });

  _.assert( _.mapIs( dstPrototype.instancesMap ) );
  _.assert( dstPrototype.instancesMap === dstPrototype.constructor.instancesMap );
  _.assert( _.arrayIs( dstPrototype.instances ) );
  _.assert( dstPrototype.instances === dstPrototype.constructor.instances );
  _.assert( _.mapKeys( Supplement ).length === 8 );

}

//

/**
 * Functors to produce init.
 * @param { routine } original - original method.
 * @method init
 * @memberof wInstancing#
 */

function init( original )
{

  return function initInstancing()
  {
    var self = this;

    self.instances.push( self );
    self.instancesCounter[ 0 ] += 1;

    return original ? original.apply( self,arguments ) : undefined;
  }

}

//

/**
 * Functors to produce finit.
 * @param { routine } original - original method.
 * @method finit
 * @memberof wInstancing#
 */

function finit( original )
{

  return function finitInstancing()
  {
    var self = this;

    if( self.name )
    {
      if( self.usingUniqueNames )
      self.instancesMap[ self.name ] = null;
      else if( self.instancesMap[ self.name ] )
      _.arrayRemoveOnce( self.instancesMap[ self.name ],self );
    }

    _.arrayRemoveOnce( self.instances,self );

    return original ? original.apply( self,arguments ) : undefined;
  }

}

//

/**
 * Iterate through instances of this type.
 * @param {routine} onEach - on each handler.
 * @method eachInstance
 * @memberof wInstancing#
 */

function eachInstance( onEach )
{
  var self = this;

  /*if( self.Self.prototype === self )*/

  for( var i = 0 ; i < self.instances.length ; i++ )
  {
    var instance = self.instances[ i ];
    if( instance instanceof self.Self )
    onEach.call( instance );
  }

  return self;
}

//

function instanceByName( name )
{
  var self = this;

  _.assert( _.strIs( name ) || name instanceof self.Self,'expects name or suit instance itself, but got',_.strTypeOf( name ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( name instanceof self.Self )
  return name;

  if( self.usingUniqueNames )
  return self.instancesMap[ name ];
  else
  return self.instancesMap[ name ] ? self.instancesMap[ name ][ 0 ] : undefined;

}

//

function instancesByFilter( filter )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = _.entityFilter( self.instances, filter );

  return result;
}

//

/**
 * Get first instance.
 * @method _firstInstanceGet
 * @memberof wInstancing#
 */

function _firstInstanceGet()
{
  var self = this;
  return self.instances[ 0 ];
}

//

/**
 * Get index of current instance.
 * @method _instanceIndexGet
 * @memberof wInstancing#
 */

function _instanceIndexGet()
{
  var self = this;
  return self.instances.indexOf( self );
}

//

/**
 * Set name.
 * @method _nameSet
 * @memberof wInstancing#
 */

function _nameSet( name )
{
  var self = this;
  var nameWas = self[ nameSymbol ];

  if( self.usingUniqueNames )
  {
    _.assert( _.mapIs( self.instancesMap ) );
    if( nameWas )
    delete self.instancesMap[ nameWas ];
  }
  else
  {
    if( nameWas && self.instancesMap[ nameWas ] )
    _.arrayRemoveOnce( self.instancesMap[ nameWas ],self );
  }

  if( name )
  {
    if( self.usingUniqueNames )
    {
      if( Config.debug )
      if( self.instancesMap[ name ] )
      throw _.err
      (
        self.Self.name,'has already an instance with name "' + name + '"',
        ( self.instancesMap[ name ].suiteFileLocation ? ( '\nat ' + self.instancesMap[ name ].suiteFileLocation ) : '' )
      );
      self.instancesMap[ name ] = self;
    }
    else
    {
      self.instancesMap[ name ] = self.instancesMap[ name ] || [];
      _.arrayAppendOnce( self.instancesMap[ name ],self );
    }
  }

  self[ nameSymbol ] = name;

}

//

function _nameGet()
{
  var self = this;
  return self[ nameSymbol ];
}

// --
// declare
// --

var nameSymbol = Symbol.for( 'name' );

var Functors =
{

  init : init,
  finit : finit,

}

var Statics =
{

  eachInstance : eachInstance,
  instanceByName : instanceByName,
  instancesByFilter : instancesByFilter,

  instances : _.define.contained({ value : [], readOnly : 1, shallowCloning : 1 }),
  instancesMap : _.define.contained({ value : Object.create( null ), readOnly : 1, shallowCloning : 1 }),
  usingUniqueNames : _.define.contained({ value : 0, readOnly : 1 }),
  instancesCounter : _.define.contained({ value : [ 0 ], readOnly : 1 }),

  // firstInstance : null,

}

var Supplement =
{

  _firstInstanceGet : _firstInstanceGet,
  _instanceIndexGet : _instanceIndexGet,
  _nameSet : _nameSet,
  _nameGet : _nameGet,

  eachInstance : eachInstance,
  instanceByName : instanceByName,
  instancesByFilter : instancesByFilter,

  Statics : Statics,

}

var Self =
{

  onMixin : onMixin,
  supplement : Supplement,
  functors : Functors,
  name : 'wInstancing',
  shortName : 'Instancing',

}

_global_[ Self.name ] = _[ Self.shortName ] = _.mixinDelcare( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
