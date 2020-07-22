( function _BaseClass_s_()
{

'use strict';


if( typeof module !== 'undefined' )
{
  let _ = require( 'wTools' )
  _.include( 'wCopyable' );
  _.include( 'wInstancing' );
}

// --
// constructor
// --

let _ = wTools;
let Parent = null;
let Self = BaseClass;
function BaseClass()
{
  return _.workpiece.construct( Self, this, arguments );
}

// --
// routines
// --

/* optional method to initialize instance with options */

function init( o )
{
  var self = this; /* context */

  _.workpiece.initFields( self );/* extends object by fields from relationships */

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
  init,
  Composes,
}

/* make class */

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

/* mixin copy/clone functionality */

wCopyable.mixin( Self );

/* mixin instances tracking functionality */

wInstancing.mixin( Self );

/* make the class global */

_global_[ Self.name ] = Self;

console.log( `self.finit`, _.routineIs( Self.prototype.finit ) );

})();
