( function _Instancing_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath )/*hhh*/;
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath )/*hhh*/;
  }

  var _ = _global_.wTools;

  _.include( 'wProto' );

}

//

var _ = _global_.wTools;
var _hasOwnProperty = Object.hasOwnProperty;

//

/**

 * Mixin instancing into prototype of another object.
 * @param {object} dstProto - prototype of another object.
 * @method _mixin
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

function _mixin( cls )
{

  var dstProto = cls.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( cls ) );
  _.assert( !dstProto.instances,'class already has mixin',Self.name );
  _.assert( _.mapKeys( Supplement ).length === 7 );

  //debugger;

  _.mixinApply
  ({
    dstProto : dstProto,
    descriptor : Self,
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

  _.assert( dstProto.usingUniqueNames !== undefined );

  _.constant( dstProto.constructor,{ usingUniqueNames : dstProto.usingUniqueNames } );
  _.constant( dstProto,{ usingUniqueNames : dstProto.usingUniqueNames } );

  _.constant( dstProto.constructor,{ instances : instances });
  _.constant( dstProto,{ instances : instances });

  _.constant( dstProto.constructor,{ instancesMap : instancesMap });
  _.constant( dstProto,{ instancesMap : instancesMap });

  _.accessorReadOnly
  ({
    object : dstProto.constructor,
    methods : Supplement,
    names :
    {
      firstInstance : { readOnlyProduct : 0 },
    },
    preserveValues : 0,
    prime : 0,
  });

  _.accessorReadOnly
  ({
    object : dstProto.constructor.prototype,
    methods : Supplement,
    names :
    {
      instanceIndex : { readOnlyProduct : 0 },
    },
    preserveValues : 0,
  });

  _.accessor
  ({
    object : dstProto.constructor.prototype,
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
    object : dstProto.constructor,
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
    self.instancesMade[ 0 ] += 1;

    return original ? original.apply( self,arguments ) : undefined;
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
  _.assert( arguments.length === 1 );

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
  var nameWas = self[ nameSymbol ];

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
        ( self.instancesMap[ name ].suitFileLocation ? ( '\nat ' + self.instancesMap[ name ].suitFileLocation ) : '' )
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

// --
// proto
// --

var nameSymbol = Symbol.for( 'name' );

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
  instancesMade : [ 0 ],

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

  _mixin : _mixin,
  supplement : Supplement,
  functor : Functor,
  name : 'wInstancing',
  nameShort : 'Instancing',

}

_global_[ Self.name ] = _[ Self.nameShort ] = _.mixinMake( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
