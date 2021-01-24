
if( typeof module !== 'undefined' )
require( './BaseClass.s' );

var base1 = new BaseClass({ name : 'base1' });
var base2 = new BaseClass({ name : 'base2' });
var base3 = new BaseClass({ name : 'base3' });

var base2Maybe = BaseClass.instanceByName( 'base2' );
console.log( 'base2Maybe === base2 :', base2Maybe === base2 );
// base2Maybe === base2 : true

for( let i = 0 ; i < BaseClass.Instances.length ; i++ )
console.log( 'instance', i, BaseClass.Instances[ i ].name );
// instance 0 base1
// instance 1 base2
// instance 2 base3

for( var name in BaseClass.InstancesMap )
for( var i = 0 ; i < BaseClass.InstancesMap[ name ].length ; i++ )
console.log( ( i + 1 ) + 'st instance with name', name, ':', BaseClass.InstancesMap[ name ][ i ].name );
// 1st instance with name base1 : base1
// 1st instance with name base2 : base2
// 1st instance with name base3 : base3
