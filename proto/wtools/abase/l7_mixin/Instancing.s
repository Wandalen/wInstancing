( function _Instancing_s_() {

'use strict';

/**
 * Mixin adds instances accounting functionality to a class. Instancing makes possible to iterate instances of the specific class, optionally create names map or class name map in case of a complicated hierarchical structure. Use Instancing to don't repeat yourself. Refactoring required.
  @module Tools/mixin/Instancing
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wProto' );

}

//

var _global = _global_;
var _ = _global_.wTools;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

//

function onMixinApply( mixinDescriptor, dstClass )
{
  /* xxx : clean it */

  var dstPrototype = dstClass.prototype;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.routineIs( dstClass ) );
  _.assert( !dstPrototype.Instances,'class already has mixin',Self.name );
  _.assert( _.mapKeys( Supplement ).length === 10 );

  _.mixinApply( this, dstPrototype );

  _.assert( _.mapKeys( Supplement ).length === 10 );

  /* */

  debugger;

  _.accessor.readOnly
  ({
    object : [ dstPrototype.constructor, dstPrototype ],
    methods : Supplement,
    names :
    {
      // firstInstance : { readOnlyProduct : 0 },
      firstInstance : { set : 0, put : 0, take : 0, get : 1 },
    },
    preservingValue : 0,
    prime : 0,
  });

  debugger;

  // debugger;
  _.accessor.readOnly
  ({
    object : dstPrototype.constructor.prototype,
    methods : Supplement,
    names :
    {
      // instanceIndex : { readOnly : 1, readOnlyProduct : 0 },
      instanceIndex : { set : 0, put : 0, take : 0, get : 1 },
    },
    preservingValue : 0,
    combining : 'supplement',
  });
  // debugger;

  debugger;

  _.accessor.declare
  ({
    object : dstPrototype.constructor.prototype,
    methods : Supplement,
    names :
    {
      name : {},
    },
    preservingValue : 0,
    combining : 'supplement',
  });

  debugger;

  _.accessor.forbid
  ({
    object : dstPrototype.constructor,
    prime : 0,
    names : { instance : 'instance', instances : 'instances' },
  });

  _.assert( _.mapIs( dstPrototype.InstancesMap ) );
  _.assert( dstPrototype.InstancesMap === dstPrototype.constructor.InstancesMap );
  _.assert( _.arrayIs( dstPrototype.Instances ) );
  _.assert( dstPrototype.Instances === dstPrototype.constructor.Instances );
  _.assert( _.mapKeys( Supplement ).length === 10 );

}

//

/**
 * @classdesc Mixin adds instances accounting functionality to a class.
 * @class wInstancing
 * @namespace Tools
 * @module Tools/mixin/Instancing
 */

/**
 * Functors to produce init.
 * @param { routine } original - original method.
 * @method init
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function init( original )
{

  return function initInstancing()
  {
    var self = this;

    self.Instances.push( self );
    self.InstancesCounter[ 0 ] += 1;

    return original ? original.apply( self,arguments ) : undefined;
  }

}

//

/**
 * Functors to produce finit.
 * @param { routine } original - original method.
 * @method finit
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function finit( original )
{

  return function finitInstancing()
  {
    var self = this;

    if( self.name )
    {
      if( self.UsingUniqueNames )
      self.InstancesMap[ self.name ] = null;
      else if( self.InstancesMap[ self.name ] )
      _.arrayRemoveElementOnce( self.InstancesMap[ self.name ],self );
    }

    _.arrayRemoveElementOnce( self.Instances,self );

    return original ? original.apply( self,arguments ) : undefined;
  }

}

//

/**
 * Iterate through instances of this type.
 * @param {routine} onEach - on each handler.
 * @method eachInstance
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function eachInstance( onEach )
{
  var self = this;

  /*if( self.Self.prototype === self )*/

  for( var i = 0 ; i < self.Instances.length ; i++ )
  {
    var instance = self.Instances[ i ];
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

  if( self.UsingUniqueNames )
  return self.InstancesMap[ name ];
  else
  return self.InstancesMap[ name ] ? self.InstancesMap[ name ][ 0 ] : undefined;

}

//

function instancesByFilter( filter )
{
  var self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  var result = _.entityFilter( self.Instances, filter );

  return result;
}

//

/**
 * Get first instance.
 * @method _firstInstanceGet
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function _firstInstanceGet()
{
  var self = this;
  return self.Instances[ 0 ];
}

//

/**
 * Get index of current instance.
 * @method _instanceIndexGet
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function _instanceIndexGet()
{
  var self = this;
  return self.Instances.indexOf( self );
}

//

function _nameTake()
{
  var self = this;
  return self[ nameSymbol ];
}

//

function _nameGet()
{
  var self = this;
  return self[ nameSymbol ];
}

//

function _namePut( name )
{
  var self = this;
  self[ nameSymbol ] = name;
}

//

/**
 * Set name.
 * @method _nameSet
 * @module Tools/mixin/Instancing
 * @namespace Tools
 * @class wInstancing
 */

function _nameSet( name )
{
  var self = this;
  var nameWas = self[ nameSymbol ];

  if( self.UsingUniqueNames )
  {
    _.assert( _.mapIs( self.InstancesMap ) );
    if( nameWas )
    delete self.InstancesMap[ nameWas ];
  }
  else
  {
    if( nameWas && self.InstancesMap[ nameWas ] )
    _.arrayRemoveElementOnce( self.InstancesMap[ nameWas ], self );
  }

  if( name )
  {
    if( self.UsingUniqueNames )
    {
      if( Config.debug )
      if( self.InstancesMap[ name ] )
      throw _.err
      (
        self.Self.name,'has already an instance with name "' + name + '"',
        ( self.InstancesMap[ name ].suiteFileLocation ? ( '\nat ' + self.InstancesMap[ name ].suiteFileLocation ) : '' )
      );
      self.InstancesMap[ name ] = self;
    }
    else
    {
      self.InstancesMap[ name ] = self.InstancesMap[ name ] || [];
      _.arrayAppendOnce( self.InstancesMap[ name ], self );
    }
  }

  self[ nameSymbol ] = name;

}

// --
// declare
// --

var nameSymbol = Symbol.for( 'name' );

var Functors =
{

  init,
  finit,

}

var Statics =
{

  eachInstance,
  instanceByName,
  instancesByFilter,

  Instances : _.define.contained({ ini : [], readOnly : 1, shallowCloning : 1 }),
  InstancesMap : _.define.contained({ ini : Object.create( null ), readOnly : 1, shallowCloning : 1 }),
  UsingUniqueNames : _.define.contained({ ini : 0, readOnly : 1 }),
  InstancesCounter : _.define.contained({ ini : [ 0 ], readOnly : 1 }),

}

var Supplement =
{

  _firstInstanceGet,
  _instanceIndexGet,

  _nameTake,
  _nameGet,
  _nameSet,
  _namePut,

  eachInstance,
  instanceByName,
  instancesByFilter,

  Statics,

}

var Self =
{

  onMixinApply,
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
module[ 'exports' ] = Self;

})();
