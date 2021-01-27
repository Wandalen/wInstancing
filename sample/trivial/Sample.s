
let _ = require( 'wTools' )
_.include( 'wInstancing' );

// --
// class declaration
// --

let Parent = null;
let Self = BaseClass;
function BaseClass()
{
  return _.workpiece.construct( Self, this, arguments );
}

//

/* optional method to initialize instance with options */

function init( o )
{
  var self = this;
  _.workpiece.initFields( self );/* extends object by fields from relationships */
  Object.preventExtensions( self ); /* disables object extending */
  if( o )
  _.mapExtend( self, o );
}

//

var Composes =
{
  name : '',
};

var Proto =
{
  init,
  Composes,
};

/* make class */

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

/* mixin instances tracking functionality */

wInstancing.mixin( Self );


var base1 = new BaseClass({ name : 'base1' });
var base2 = new BaseClass({ name : 'base2' });
var base3 = new BaseClass({ name : 'base3' });

let filtered = BaseClass.instancesByFilter( ( e ) => e.name === 'base3' ? e : undefined );
console.log( filtered );

/* log : [ BaseClass { [Symbol(name)]: 'base3' } ] */

