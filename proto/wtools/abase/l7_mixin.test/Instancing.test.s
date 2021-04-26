( function _Instancing_test_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );
  _.include( 'wConsequence' );

  require( '../l7_mixin/Instancing.s' );
}

const _global = _global_;
const _ = _global_.wTools;

// --
// test
// --

function basic( test )
{
  let context = this;

  /* */

  test.case = 'basic';

  var Obj1 = BaseClass;
  function BaseClass()
  {
    return _.workpiece.construct( Obj1, this, arguments );
  }

  function init( o )
  {
    var self = this; /* context */
    _.workpiece.initFields( self );/* extends object by fields from relationships */
    Object.preventExtensions( self ); /* disables object extending */
    if( o ) /* copy fields from options */
    self.copy( o );
  }

  var Composes =
  {
    name : '',
  }

  var extension =
  {
    init,
    Composes,
  }

  _.classDeclare
  ({
    cls : Obj1,
    extend : extension,
  });

  wCopyable.mixin( Obj1 );
  wInstancing.mixin( Obj1 );

  var base1 = new Obj1({ name : 'base1' });
  var base2 = new Obj1({ name : 'base2' });
  var base3 = new Obj1({ name : 'base3' });

  var base2Maybe = Obj1.instanceByName( 'base2' );
  test.true( base2Maybe === base2 );

  test.identical( Obj1.Instances[ 0 ].name, 'base1' );
  test.identical( Obj1.Instances[ 1 ].name, 'base2' );
  test.identical( Obj1.Instances[ 2 ].name, 'base3' );
  test.identical( Obj1.Instances.length, 3 );

  test.identical( Obj1.InstancesMap[ 'base1' ][ 0 ].name, 'base1' );
  test.identical( Obj1.InstancesMap[ 'base1' ].length, 1 );
  test.identical( Obj1.InstancesMap[ 'base2' ][ 0 ].name, 'base2' );
  test.identical( Obj1.InstancesMap[ 'base2' ].length, 1 );
  test.identical( Obj1.InstancesMap[ 'base3' ][ 0 ].name, 'base3' );
  test.identical( Obj1.InstancesMap[ 'base3' ].length, 1 );
  test.identical( _.entity.lengthOf( Obj1.InstancesMap ), 3 );

  /* */

}

//

function severalClasses( test )
{
  let context = this;

  /* */

  test.case = 'basic';

  var Obj1 = BaseClass1;
  function BaseClass1()
  {
    return _.workpiece.construct( Obj1, this, arguments );
  }

  var Obj2 = BaseClass2;
  function BaseClass2()
  {
    return _.workpiece.construct( Obj2, this, arguments );
  }

  function init( o )
  {
    var self = this; /* context */
    _.workpiece.initFields( self );/* extends object by fields from relationships */
    Object.preventExtensions( self ); /* disables object extending */
    if( o ) /* copy fields from options */
    self.copy( o );
  }

  var Composes =
  {
    name : '',
  }

  var extension =
  {
    init,
    Composes,
  }

  _.classDeclare
  ({
    cls : Obj1,
    extend : extension,
  });

  wCopyable.mixin( Obj1 );
  wInstancing.mixin( Obj1 );

  _.classDeclare
  ({
    cls : Obj2,
    extend : extension,
  });

  wCopyable.mixin( Obj2 );
  wInstancing.mixin( Obj2 );

  var base1 = new Obj1({ name : 'base1' });
  var base2 = new Obj1({ name : 'base2' });
  var base3 = new Obj1({ name : 'base3' });

  test.identical( Obj1.Instances[ 0 ].name, 'base1' );
  test.identical( Obj1.Instances[ 1 ].name, 'base2' );
  test.identical( Obj1.Instances[ 2 ].name, 'base3' );
  test.identical( Obj1.Instances.length, 3 );

  var base1 = new Obj2({ name : 'base1' });
  var base2 = new Obj2({ name : 'base2' });
  var base3 = new Obj2({ name : 'base3' });

  test.identical( Obj2.Instances[ 0 ].name, 'base1' );
  test.identical( Obj2.Instances[ 1 ].name, 'base2' );
  test.identical( Obj2.Instances[ 2 ].name, 'base3' );
  test.identical( Obj2.Instances.length, 3 );

  /* */

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.InstancingMixin',
  silencing : 1,

  tests :
  {

    basic,
    severalClasses,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
