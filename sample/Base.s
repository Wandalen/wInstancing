
if( typeof module !== 'undefined' )
require( './BaseClass.s' );

var base1 = new BaseClass({ name : 'base1' });
var base2 = new BaseClass({ name : 'base2' });
var base3 = new BaseClass({ name : 'base3' });

var base2Maybe = BaseClass.instanceByName( 'base2' );

console.log( 'base2Maybe === base2 :',base2Maybe === base2 );
