( function _Instancing_s_() {

'use strict';

/**
 * Mixin adds instances accounting functionality to a class. Instancing makes possible to iterate instances of the specific class, optionally create names map or class name map in case of a complicated hierarchical structure. Use Instancing to don't repeat yourself. Refactoring required.
  @module Tools/mixin/Instancing
*/

/**
 * @file Instancing.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wProto' );

}

//

var _global = _global_;
var _ = _global_.wTools;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

//

function onMixin( mixinDescriptor, dstClass )
{
  /* xxx : clean it */

  var dstPrototype = dstClass.prototype;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.routineIs( dstClass ) );
  _.assert( !dstPrototype.instances,'class already has mixin',Self.name );
  _.assert( _.mapKeys( Supplement ).length === 8 );

  _.mixinApply( this, dstPrototype );

  // _.mixinApply
  // ({
  //   /*ttt*/dstPrototype,
  //   descriptor : Self,
  // });
  //
  // var instances = [];
  // var instancesMap = Object.create( null );

  _.accessor.forbid
  ({
    object : dstPrototype.constructor.instancesMap,
    prime : 0,
    names : { null : 'null', undefined : 'undefined' },
  });

  _.assert( _.mapKeys( Supplement ).length === 8 );

  /* */

  // _.accessor.constant( dstPrototype.constructor,{ usingUniqueNames : dstPrototype.usingUniqueNames } );
  // _.accessor.constant( dstPrototype,{ usingUniqueNames : dstPrototype.usingUniqueNames } );
  //
  // _.accessor.constant( dstPrototype.constructor,{ /*ttt*/instances });
  // _.accessor.constant( dstPrototype,{ /*ttt*/instances });
  //
  // _.accessor.constant( dstPrototype.constructor,{ /*ttt*/instancesMap });
  // _.accessor.constant( dstPrototype,{ /*ttt*/instancesMap });

  _.accessor.readOnly
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
  _.accessor.readOnly
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

  _.accessor.declare
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

  _.accessor.forbid
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
 * @classdesc Mixin adds instances accounting functionality to a class.
 * @class wInstancing
 * @memberof module:Tools/mixin/Instancing
 */

/**
 * Functors to produce init.
 * @param { routine } original - original method.
 * @method init
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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
      _.arrayRemoveElementOnce( self.instancesMap[ self.name ],self );
    }

    _.arrayRemoveElementOnce( self.instances,self );

    return original ? original.apply( self,arguments ) : undefined;
  }

}

//

/**
 * Iterate through instances of this type.
 * @param {routine} onEach - on each handler.
 * @method eachInstance
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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

  _.assert( _.strIs( name ) || name instanceof self.Self,'Expects name or suit instance itself, but got',_.strType( name ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

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

  _.assert( arguments.length === 1, 'Expects single argument' );

  var result = _.entityFilter( self.instances, filter );

  return result;
}

//

/**
 * Get first instance.
 * @method _firstInstanceGet
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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
 * @memberof module:Tools/mixin/Instancing.wInstancing#
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
    _.arrayRemoveElementOnce( self.instancesMap[ nameWas ],self );
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

  /*ttt*/init,
  /*ttt*/finit,

}

var Statics =
{

  /*ttt*/eachInstance,
  /*ttt*/instanceByName,
  /*ttt*/instancesByFilter,

  instances : _.define.contained({ value : [], readOnly : 1, shallowCloning : 1 }),
  instancesMap : _.define.contained({ value : Object.create( null ), readOnly : 1, shallowCloning : 1 }),
  usingUniqueNames : _.define.contained({ value : 0, readOnly : 1 }),
  instancesCounter : _.define.contained({ value : [ 0 ], readOnly : 1 }),

  // firstInstance : null,

}

var Supplement =
{

  /*ttt*/_firstInstanceGet,
  /*ttt*/_instanceIndexGet,
  /*ttt*/_nameSet,
  /*ttt*/_nameGet,

  /*ttt*/eachInstance,
  /*ttt*/instanceByName,
  /*ttt*/instancesByFilter,

  /*ttt*/Statics,

}

var Self =
{

  /*ttt*/onMixin,
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
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
