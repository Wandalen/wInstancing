( function _Instancing_s_() {

'use strict';

var _ = wTools;
var _hasOwnProperty = Object.hasOwnProperty;

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  wTools.include( 'wProto' );

}

//

/**

 * Mixin instancing into prototype of another object.
 * @param {object} dst - prototype of another object.
 * @method mixin
 * @memberof wInstancing#

 * @example of constructor clonning source
  var Self = function ClassName( o )
  {
    if( !( this instanceof Self ) )
    return new( _.routineJoin( Self, Self, arguments ) );
    return Self.prototype.init.apply( this,arguments );
  }

  * @example of constructor returning source if source is instance
  var Self = function ClassName( o )
  {
    if( !( this instanceof Self ) )
    if( o instanceof Self )
    return o;
    else
    return new( _.routineJoin( Self, Self, arguments ) );
    return Self.prototype.init.apply( this,arguments );
  }

 */

function mixin( constructor )
{

  var dst = constructor.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( constructor ) );
  _.assert( !dst.instances );
  _.assert( _.mapKeys( Supplement ).length === 7 );

  //debugger;

  _.mixin
  ({
    dst : dst,
    mixin : Self,
  });

  var instances = [];
  var instancesMap = Object.create( null );

  _.accessorForbid
  ({
    object : instancesMap,
    prime : 0,
    names : { null : 'null', undefined : 'undefined' },
  });

  /* */

  _.assert( dst.usingUniqueNames !== undefined );

  _.constant( dst.constructor,{ usingUniqueNames : dst.usingUniqueNames } );
  _.constant( dst,{ usingUniqueNames : dst.usingUniqueNames } );

  _.constant( dst.constructor,{ instances : instances });
  _.constant( dst,{ instances : instances });

  _.constant( dst.constructor,{ instancesMap : instancesMap });
  _.constant( dst,{ instancesMap : instancesMap });

  _.accessorReadOnly
  ({
    object : dst.constructor,
    methods : Supplement,
    names :
    {
      firstInstance : 'firstInstance',
    },
    preserveValues : 0,
    prime : 0,
  });

  _.accessorReadOnly
  ({
    object : dst.constructor.prototype,
    methods : Supplement,
    names :
    {
      instanceIndex : 'instanceIndex',
    },
    preserveValues : 0,
  });

  _.accessor
  ({
    object : dst.constructor.prototype,
    methods : Supplement,
    names :
    {
      name : 'name',
    },
    preserveValues : 0,
  });

  _.accessorForbid
  ({
    object : dst.constructor,
    prime : 0,
    names : { instance : 'instance' },
  });

}

//

/**
 * Functor to produce init.
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

    return original.apply( self,arguments );
  }

}

//

/**
 * Functor to produce finit.
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

    if( original )
    return original.apply( self,arguments );
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

  // !!! implement classGet routine in base

  _.assert( _.strIs( name ) || name instanceof self.Self,'expects name or suite instance itself, but got',_.strTypeOf( name ) );
  _.assert( arguments.length === 1 );

  if( name instanceof self.Self )
  return name;

  if( self.usingUniqueNames )
  return self.instancesMap[ name ];
  else
  return self.instancesMap[ name ] ? self.instancesMap[ name ][ 0 ] : undefined;

  // for( var i = 0 ; i < self.instances.length ; i++ )
  // {
  //   var instance = self.instances[ i ];
  //   if( instance.name === name )
  //   return instance;
  // }

}
//

function instancesByFilter( filter )
{
  var self = this;

  _.assert( arguments.length === 1 );

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
  var nameWas = self[ symbolForName ];

  if( self.usingUniqueNames )
  {
    _.assert( self.instancesMap );
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
        ( self.instancesMap[ name ].sourceFilePath ? ( '\nat ' + self.instancesMap[ name ].sourceFilePath ) : '' )
      );
      self.instancesMap[ name ] = self;
    }
    else
    {
      self.instancesMap[ name ] = self.instancesMap[ name ] || [];
      _.arrayAppendOnce( self.instancesMap[ name ],self );
    }
  }

  self[ symbolForName ] = name;

}

// --
// proto
// --

var symbolForName = Symbol.for( 'name' );

var Functor =
{

  init : init,
  finit : finit,

}

var Statics =
{

  eachInstance : eachInstance,
  instanceByName : instanceByName,
  instancesByFilter : instancesByFilter,

  instances : null,
  instancesMap : null,
  usingUniqueNames : 0,

}

var Supplement =
{

  _firstInstanceGet : _firstInstanceGet,
  _instanceIndexGet : _instanceIndexGet,
  _nameSet : _nameSet,

  eachInstance : eachInstance,
  instanceByName : instanceByName,
  instancesByFilter : instancesByFilter,

  Statics : Statics,

}

var Self =
{

  mixin : mixin,
  Supplement : Supplement,
  Functor : Functor,
  name : 'wInstancing',
  nameShort : 'Instancing',

}

Object.setPrototypeOf( Self, Supplement );
Object.freeze( Supplement );

_global_[ Self.name ] = wTools[ Self.nameShort ] = Self;

return Self;

})();
