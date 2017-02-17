( function _BaseClass_s_(){

'use strict';

if( typeof module !== 'undefined' )
{
  require( 'wCopyable' );
  require( 'wInstancing' );
}

// --
// constructor
// --

var _ = wTools;
var Parent = null;
var Self = function BaseClass()
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

// --
// routines
// --

/* optional method to initialize instance with options */

function init( o )
{
  var self = this; /* context */

  _.instanceInit( self );/* extends object by fields from relationships */

  Object.preventExtensions( self ); /* disables object extending */

  if( o ) /* copy fields from options */
  self.copy( o );

}

// --
// relationships
// --

var Composes =
{
  name : '',
}

// --
// proto
// --

var Proto =
{

  init : init,

  constructor : Self,
  Composes : Composes,

}

/* make class */

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

/* mixin copy/clone functionality */

wCopyable.mixin( Self );

/* mixin instances tracking functionality */

wInstancing.mixin( Self );

/* make the class global */

_global_[ Self.name ] = Self;

})();
