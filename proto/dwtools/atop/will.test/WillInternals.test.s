( function _WillInternals_test_s_( ) {

'use strict';

/*
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );;
  _.include( 'wAppBasic' );
  _.include( 'wFiles' );

  require( '../will/MainBase.s' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.tempDir = _.path.pathDirTempOpen( _.path.join( __dirname, '../..'  ), 'willbe' );
  self.assetDirPath = _.path.join( __dirname, '_asset' );
  self.repoDirPath = _.path.join( self.assetDirPath, '_repo' );
  self.find = _.fileProvider.filesFinder
  ({
    filter :
    {
      recursive : 2,
    },
    withTerminals : 1,
    withDirs : 1,
    withTransient/*maybe withStem*/ : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
  });

}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.tempDir, '/willbe-' ) )
  _.fileProvider.filesDelete( self.tempDir );
}

//

function abs_functor( routinePath )
{
  _.assert( _.strIs( routinePath ) );
  _.assert( arguments.length === 1 );
  return function abs( filePath )
  {
    if( arguments.length === 1 && filePath === null )
    return filePath;
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return _.uri.s.join.apply( _.uri.s, args );
  }
}

//

function rel_functor( routinePath )
{
  _.assert( _.strIs( routinePath ) );
  _.assert( arguments.length === 1 );
  return function rel( filePath )
  {
    _.assert( arguments.length === 1 );
    if( arguments.length === 1 && filePath === null )
    return filePath;
    return _.uri.s.relative.apply( _.uri.s, [ routinePath, filePath ] );
  }
}

// --
// tests
// --

function preCloneRepos( test )
{
  let self = this;
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let execPath = _.path.nativize( _.path.join( _.path.normalize( __dirname ), '../will/Exec' ) );
  let ready = new _.Consequence().take( null )

  let shell = _.sheller
  ({
    currentPath : self.repoDirPath,
    outputCollecting : 1,
    ready : ready,
  })

  _.fileProvider.dirMake( self.repoDirPath );

  /* - */

  clone( 'Color', '2d408bf82b168a39a29aa1261bf13face8bd3e95' );
  clone( 'PathBasic', '95b741c8820a6d6234f59f1fa549c6b59f2d5a5c' );
  clone( 'Procedure', '829ea81d342db66df60edf80c99687a1cd011a96' );
  clone( 'Proto', 'f4c04dbe078f3c00c84ff13edcc67478d320fddf' );
  clone( 'Tools', 'e58dc6a1637603c2151840f5bfb5729eb71d4e34' );
  clone( 'UriBasic', 'df28c5245b2e01bcc0dbc9693bed070a58268e77' );

  ready
  .then( () =>
  {
    test.is( _.fileProvider.isDir( _.path.join( self.repoDirPath, 'Tools' ) ) );
    return null;
  })

  return ready;

  function clone( name, version )
  {

    if( !_.fileProvider.isDir( _.path.join( self.repoDirPath, name ) ) )
    shell( 'git clone https://github.com/Wandalen/w' + name + '.git ' + name );
    shell({ execPath : 'git checkout ' + version, currentPath : _.path.join( self.repoDirPath, name ) });

  }

}

//

function buildSimple( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'simple' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( outPath );

  var opener = will.openerMake({ willfilesPath : modulePath });
  opener.find();

  return opener.open().split().then( () =>
  {

    var expected = [];
    var files = self.find( outPath );

    let builds = opener.openedModule.buildsResolve();

    test.identical( builds.length, 1 );

    let build = builds[ 0 ];

    return build.perform()
    .finally( ( err, arg ) =>
    {

      var expected = [ '.', './debug', './debug/File.js' ];
      var files = self.find( outPath );
      test.identical( files, expected );

      opener.finit();

      test.description = 'no grabage left';
      test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
      test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
      test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

      if( err )
      throw err;
      return arg;
    });

  });
}

//

function openNamedFast( test )
{
  let self = this;
  let assetName = 'import-in/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var opener1 = will.openerMake({ willfilesPath : modulePath });
  let ready1 = opener1.open();

  var opener2 = will.openerMake({ willfilesPath : modulePath });
  let ready2 = opener2.open();

  /* - */

  ready1.then( ( arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    check( opener1 );
    return null;
  })

  /* - */

  ready1.finally( ( err, arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready2.then( ( arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    check( opener2 );
    return null;
  })

  /* - */

  ready2.finally( ( err, arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ ready1, ready2 ])
  .finally( ( err, arg ) =>
  {
    if( err )
    throw err;

    test.is( opener1.openedModule === opener2.openedModule );

    var exp = [ 'super' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );

    var exp = [ 'super.ex.will.yml', 'super.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( _.mapKeys( will.willfileWithFilePathPathMap ), abs( exp ) );
    var exp = [ 'super' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );

    opener1.finit();

    var exp = [ 'super' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );

    var exp = [ 'sub.out/sub.out', 'super' ];
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
    test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );

    var exp = [ 'super.ex.will.yml', 'super.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );

    opener2.finit();

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return arg;
  });

  /* - */

  function check( opener )
  {

    let pathMap =
    {

      'proto' : './proto',
      'temp' : [ './super.out', './sub.out' ],
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',

      'local' : abs( 'super' ),
      'remote' : null,
      'current.remote' : null,
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( '.' ),
      'module.willfiles' : abs( [ './super.ex.will.yml', './super.im.will.yml' ] ),
      'module.peer.willfiles' : abs( 'super.out/supermodule.out.will.yml' ),
      'module.original.willfiles' : null,
      'module.common' : abs( 'super' ),

    }

    test.identical( opener.nickName, 'module::supermodule' );
    test.identical( opener.absoluteName, 'module::supermodule' );
    // test.identical( opener.inPath, routinePath );
    // test.identical( opener.outPath, abs( './super.out' ) );
    test.identical( opener.fileName, 'super' );
    test.identical( opener.aliasName, null );
    test.identical( opener.localPath, abs( './super' ) );
    test.identical( opener.remotePath, null );
    // test.identical( opener.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.dirPath, abs( '.' ) );
    test.identical( opener.commonPath, abs( 'super' ) );
    test.identical( opener.willfilesPath, abs( [ './super.ex.will.yml', './super.im.will.yml' ] ) );
    test.identical( opener.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.identical( opener.openedModule.nickName, 'module::supermodule' );
    test.identical( opener.openedModule.absoluteName, 'module::supermodule' );
    test.identical( opener.openedModule.inPath, routinePath );
    test.identical( opener.openedModule.outPath, abs( './super.out' ) );
    test.identical( opener.openedModule.localPath, abs( './super' ) );
    test.identical( opener.openedModule.remotePath, null );
    test.identical( opener.openedModule.currentRemotePath, null );
    test.identical( opener.openedModule.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.openedModule.dirPath, abs( '.' ) );
    test.identical( opener.openedModule.commonPath, abs( 'super' ) );
    test.identical( opener.openedModule.willfilesPath, abs( [ './super.ex.will.yml', './super.im.will.yml' ] ) );
    test.identical( opener.openedModule.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.is( !!opener.openedModule.about );
    test.identical( opener.openedModule.about.name, 'supermodule' );
    test.identical( opener.openedModule.pathMap, pathMap );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.submoduleMap ), [ 'Submodule' ] );
    test.setsAreIdentical( _.filter( _.mapKeys( opener.openedModule.reflectorMap ), ( e, k ) => _.strHas( e, 'predefined.' ) ? undefined : e ), [ 'reflect.submodules.', 'reflect.submodules.debug' ] );

    let steps = _.select( opener.openedModule.resolve({ selector : 'step::*', criterion : { predefined : 0 } }), '*/name' );
    test.setsAreIdentical( steps, [ 'reflect.submodules.', 'reflect.submodules.debug', 'export.', 'export.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.buildMap ), [ 'debug', 'release', 'export.', 'export.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.exportedMap ), [] );

  }

} /* end of function openNamedFast */

//

function openNamedForming( test )
{
  let self = this;
  let assetName = 'import-in/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  let opener1 = will.openerMake({ willfilesPath : modulePath });
  let ready1 = opener1.open({ forming : 1 });

  test.case = 'skipping of stages of module';
  var stager = opener1.openedModule.stager;
  test.identical( stager.stageStateSkipping( 'preformed' ), false );
  test.identical( stager.stageStateSkipping( 'picked' ), false );
  test.identical( stager.stageStateSkipping( 'opened' ), false );
  test.identical( stager.stageStateSkipping( 'attachedWillfilesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'peerModulesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'subModulesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'resourcesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'formed' ), false );

  let opener2 = will.openerMake({ willfilesPath : modulePath });
  let ready2 = opener2.open();

  test.case = 'skipping of stages of module';
  var stager = opener1.openedModule.stager;
  test.identical( stager.stageStateSkipping( 'preformed' ), false );
  test.identical( stager.stageStateSkipping( 'picked' ), false );
  test.identical( stager.stageStateSkipping( 'opened' ), false );
  test.identical( stager.stageStateSkipping( 'attachedWillfilesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'peerModulesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'subModulesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'resourcesFormed' ), false );
  test.identical( stager.stageStateSkipping( 'formed' ), false );

  test.case = 'structure consistency';
  test.is( will.mainOpener === opener1 );
  test.is( opener1.openedModule === opener2.openedModule );

  /* - */

  ready1.then( ( arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    check( opener1 );
    return null;
  })

  /* - */

  ready1.finally( ( err, arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready2.then( ( arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    check( opener2 );
    return null;
  })

  /* - */

  ready2.finally( ( err, arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ ready1, ready2 ])
  .finally( ( err, arg ) =>
  {
    if( err )
    throw err;

    test.is( opener1.openedModule === opener2.openedModule );

    test.case = 'stages';
    var stager = opener1.openedModule.stager;
    test.identical( stager.stageStatePerformed( 'preformed' ), true );
    test.identical( stager.stageStatePerformed( 'picked' ), true );
    test.identical( stager.stageStatePerformed( 'opened' ), true );
    test.identical( stager.stageStatePerformed( 'attachedWillfilesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'peerModulesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'subModulesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'resourcesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'formed' ), true );

    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'super.out/supermodule.out.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );
    debugger;

    opener1.finit();

    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'super.out/supermodule.out.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );

    opener2.finit();

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return arg;
  });

  /* - */

  function check( opener )
  {

    let pathMap =
    {

      'proto' : './proto',
      'temp' : [ './super.out', './sub.out' ],
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',

      'local' : abs( 'super' ),
      'remote' : null,
      'current.remote' : null,
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( '.' ),
      'module.willfiles' : abs( [ './super.ex.will.yml', './super.im.will.yml' ] ),
      'module.original.willfiles' : null,
      'module.peer.willfiles' : abs( './super.out/supermodule.out.will.yml' ),
      'module.common' : abs( 'super' ),

    }

    test.identical( opener.nickName, 'module::supermodule' );
    test.identical( opener.absoluteName, 'module::supermodule' );
    // test.identical( opener.inPath, routinePath );
    // test.identical( opener.outPath, abs( './super.out' ) );
    test.identical( opener.fileName, 'super' );
    test.identical( opener.aliasName, null );
    // test.identical( opener.localPath, null );
    test.identical( opener.localPath, abs( './super' ) );
    test.identical( opener.remotePath, null );
    // test.identical( opener.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.dirPath, abs( '.' ) );
    test.identical( opener.commonPath, abs( 'super' ) );
    test.identical( opener.willfilesPath, abs( [ './super.ex.will.yml', './super.im.will.yml' ] ) );
    test.identical( opener.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.identical( opener.openedModule.nickName, 'module::supermodule' );
    test.identical( opener.openedModule.absoluteName, 'module::supermodule' );
    test.identical( opener.openedModule.inPath, routinePath );
    test.identical( opener.openedModule.outPath, abs( './super.out' ) );
    test.identical( opener.openedModule.localPath, abs( './super' ) );
    test.identical( opener.openedModule.remotePath, null );
    test.identical( opener.openedModule.currentRemotePath, null );
    test.identical( opener.openedModule.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.openedModule.dirPath, abs( '.' ) );
    test.identical( opener.openedModule.commonPath, abs( 'super' ) );
    test.identical( opener.openedModule.willfilesPath, abs( [ './super.ex.will.yml', './super.im.will.yml' ] ) );
    test.identical( opener.openedModule.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.is( !!opener.openedModule.about );
    test.identical( opener.openedModule.about.name, 'supermodule' );
    test.identical( opener.openedModule.pathMap, pathMap );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.submoduleMap ), [ 'Submodule' ] );
    test.setsAreIdentical( _.filter( _.mapKeys( opener.openedModule.reflectorMap ), ( e, k ) => _.strHas( e, 'predefined.' ) ? undefined : e ), [ 'reflect.submodules.', 'reflect.submodules.debug' ] );

    let steps = _.select( opener.openedModule.resolve({ selector : 'step::*', criterion : { predefined : 0 } }), '*/name' );
    test.setsAreIdentical( steps, [ 'reflect.submodules.', 'reflect.submodules.debug', 'export.', 'export.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.buildMap ), [ 'debug', 'release', 'export.', 'export.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.exportedMap ), [] );

  }

} /* end of function openNamedForming */

//

function openSkippingSubButAttachedWillfilesSkippingMainPeers( test )
{
  let self = this;
  let assetName = 'import-in/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener1;
  let ready1;
  let opener2;
  let ready2;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'first run';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

    will.prefer
    ({
      formingOfMain : 1,
      formingPeerModulesOfMain : 0,
      formingAttachedWillfilesOfSub : 1,
    });

    opener1 = will.openerMake({ willfilesPath : modulePath })
    ready1 = opener1.open();
    opener2 = will.openerMake({ willfilesPath : modulePath });
    ready2 = opener2.open({});

    return _.Consequence.AndTake([ ready1, ready2 ])
  })

  .finally( ( err, arg ) => check( err, arg ) );

  /* - */

  ready
  .then( () =>
  {
    test.description = 'second run';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

    will.instanceDefaultsReset();

    will.prefer
    ({
      formingOfMain : 1,
      formingPeerModulesOfMain : 0,
      formingAttachedWillfilesOfSub : 1,
    });

    opener1 = will.openerMake({ willfilesPath : modulePath })
    ready1 = opener1.open();
    opener2 = will.openerMake({ willfilesPath : modulePath });
    ready2 = opener2.open({});

    return _.Consequence.AndTake([ ready1, ready2 ])
  })

  .finally( ( err, arg ) => check( err, arg ) );

  /* - */

  return ready;

  /* - */

  function check( err, arg )
  {
    if( err )
    throw err;

    test.case = 'skipping of stages of module';
    var stager = opener1.openedModule.stager;
    test.identical( stager.stageStateSkipping( 'preformed' ), false );
    test.identical( stager.stageStateSkipping( 'picked' ), false );
    test.identical( stager.stageStateSkipping( 'opened' ), false );
    test.identical( stager.stageStateSkipping( 'attachedWillfilesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'peerModulesFormed' ), true );
    test.identical( stager.stageStateSkipping( 'subModulesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'resourcesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'formed' ), false );

    test.case = 'structure consistency';
    test.is( will.mainOpener === opener1 );
    test.is( opener1.openedModule === opener2.openedModule );

    var exp = [ 'super', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    var exp = [ 'super', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );

    opener1.finit();

    var exp = [ 'super', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'sub.out/sub.out', 'super' ];
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
    test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );
    opener2.finit();

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return arg;
  }

} /* end of function openSkippingSubButAttachedWillfilesSkippingMainPeers */

//

function openSkippingSubButAttachedWillfiles( test )
{
  let self = this;
  let assetName = 'import-in/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener1;
  let ready1;
  let opener2;
  let ready2;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'first run';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

    will.prefer
    ({
      formingOfMain : 1,
      formingAttachedWillfilesOfSub : 1,
    });

    opener1 = will.openerMake({ willfilesPath : modulePath })
    ready1 = opener1.open();
    opener2 = will.openerMake({ willfilesPath : modulePath });
    ready2 = opener2.open();

    return _.Consequence.AndTake([ ready1, ready2 ])
  })
  .finally( ( err, arg ) => check( err, arg ) );

  /* - */

  ready
  .then( () =>
  {
    test.description = 'second run';

    will.instanceDefaultsReset();

    will.prefer
    ({
      formingOfMain : 1,
      formingAttachedWillfilesOfSub : 1,
    });

    opener1 = will.openerMake({ willfilesPath : modulePath })
    ready1 = opener1.open();
    opener2 = will.openerMake({ willfilesPath : modulePath });
    ready2 = opener2.open();

    return _.Consequence.AndTake([ ready1, ready2 ])
  })
  .finally( ( err, arg ) => check( err, arg ) );

  /* - */

  return ready;

  /* - */

  function check( err, arg )
  {
    if( err )
    throw err;

    test.case = 'skipping of stages of module';
    var stager = opener1.openedModule.stager;
    test.identical( stager.stageStateSkipping( 'preformed' ), false );
    test.identical( stager.stageStateSkipping( 'picked' ), false );
    test.identical( stager.stageStateSkipping( 'opened' ), false );
    test.identical( stager.stageStateSkipping( 'attachedWillfilesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'peerModulesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'subModulesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'resourcesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'formed' ), false );
    test.identical( stager.stageStatePerformed( 'preformed' ), true );
    test.identical( stager.stageStatePerformed( 'picked' ), true );
    test.identical( stager.stageStatePerformed( 'opened' ), true );
    test.identical( stager.stageStatePerformed( 'attachedWillfilesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'peerModulesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'subModulesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'resourcesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'formed' ), true );

    test.case = 'skipping of stages of module';
    var stager = will.moduleWithNameMap.Submodule.stager;
    test.identical( stager.stageStateSkipping( 'preformed' ), false );
    test.identical( stager.stageStateSkipping( 'picked' ), false );
    test.identical( stager.stageStateSkipping( 'opened' ), false );
    test.identical( stager.stageStateSkipping( 'attachedWillfilesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'peerModulesFormed' ), false );
    test.identical( stager.stageStateSkipping( 'subModulesFormed' ), true );
    test.identical( stager.stageStateSkipping( 'resourcesFormed' ), true );
    test.identical( stager.stageStateSkipping( 'formed' ), false );

    test.identical( stager.stageStatePerformed( 'preformed' ), true );
    test.identical( stager.stageStatePerformed( 'picked' ), true );
    test.identical( stager.stageStatePerformed( 'opened' ), true );
    test.identical( stager.stageStatePerformed( 'attachedWillfilesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'peerModulesFormed' ), true );
    test.identical( stager.stageStatePerformed( 'subModulesFormed' ), false );
    test.identical( stager.stageStatePerformed( 'resourcesFormed' ), false );
    test.identical( stager.stageStatePerformed( 'formed' ), true );

    test.case = 'structure consistency';
    test.is( will.mainOpener === opener1 );
    test.is( opener1.openedModule === opener2.openedModule );

    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'super', 'sub.out/sub.out', 'sub.out/sub.out', 'super' ];
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
    test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'super.out/supermodule.out.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );

    opener1.finit();

    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [ 'sub.out/sub.out', 'sub.out/sub.out', 'super' ];
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
    test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );
    var exp = [ 'super.ex.will.yml', 'super.im.will.yml', 'super.out/supermodule.out.will.yml', 'sub.out/sub.out.will.yml', 'sub.ex.will.yml', 'sub.im.will.yml' ];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );
    var exp = [ 'super', 'super.out/supermodule.out', 'sub.out/sub.out', 'sub' ];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );

    opener2.finit();

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return arg;
  }

} /* end of function openSkippingSubButAttachedWillfiles */

//

function openAnon( test )
{
  let self = this;
  let assetName = 'two-anon-exported/.';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-anon-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );

  /* */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  var opener1 = will.openerMake({ willfilesPath : modulePath });
  let ready1 = opener1.open();
  var opener2 = will.openerMake({ willfilesPath : modulePath + '/' });
  let ready2 = opener2.open();

  /* - */

  ready1.then( ( arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    check( opener1 );
    return null;
  })

  /* - */

  ready1.finally( ( err, arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    opener1.finit();
    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready2.then( ( arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    check( opener2 );
    return null;
  })

  /* - */

  ready2.finally( ( err, arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    opener2.finit();
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ ready1, ready2 ])
  .finally( ( err, arg ) =>
  {
    debugger;
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function check( opener )
  {

    let pathMap =
    {
      'current.remote' : null,
      'will' : path.join( __dirname, '../will/Exec' ),
      'local' : abs( '.' ),
      'remote' : null,
      'proto' : './proto',
      'temp' : [ './super.out', './sub.out' ],
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',
      'module.willfiles' :
      [
        abs( './.ex.will.yml' ),
        abs( './.im.will.yml' ),
      ],
      'module.dir' : abs( '.' ),
      'module.common' : abs( './' ),
      'module.original.willfiles' : null,
      'module.peer.willfiles' : abs( './super.out/supermodule.out.will.yml' )
    }

    // {
    //
    //   'proto' : '.',
    //   'in' : 'proto',
    //   'out' : '../out',
    //   'out.debug' : '../out/debug',
    //   'out.release' : '../out/release',
    //   'local' : null,
    //   'remote' : null,
    //   'current.remote' : null,
    //   'will' : path.join( __dirname, '../will/Exec' ),
    //   'module.dir' : abs( '/' ),
    //   'module.willfiles' : abs([ '.im.will.yml', '.ex.will.yml' ] ),
    //   'module.original.willfiles' : null,
    //   'module.peer.willfiles' : abs( 'super.out/supermodule.out.will.yml' ),
    //   'temp' : [ '../out', '../super.out' ],
    //   'module.common' : abs( './' ),
    //
    // }

    test.identical( opener.nickName, 'module::supermodule' );
    test.identical( opener.absoluteName, 'module::supermodule' );
    // test.identical( opener.inPath, abs( './proto' ) );
    // test.identical( opener.outPath, abs( './out' ) );
    test.identical( opener.dirPath, abs( '.' ) );
    test.identical( opener.commonPath, abs( '.' ) + '/' );
    test.setsAreIdentical( opener.willfilesPath, abs([ '.im.will.yml', '.ex.will.yml' ]) );
    test.identical( opener.fileName, 'openAnon' );
    test.identical( opener.aliasName, null );
    test.identical( opener.localPath, abs( '.' ) );
    test.identical( opener.remotePath, null );
    // test.identical( opener.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.identical( opener.openedModule.nickName, 'module::supermodule' );
    test.identical( opener.openedModule.absoluteName, 'module::supermodule' );
    test.identical( opener.openedModule.inPath, abs( '.' ) );
    test.identical( opener.openedModule.outPath, abs( './super.out' ) );
    test.identical( opener.openedModule.dirPath, abs( '.' ) );
    test.identical( opener.openedModule.commonPath, abs( './' ) );
    test.setsAreIdentical( opener.openedModule.willfilesPath, abs([ '.im.will.yml', '.ex.will.yml' ]) );
    // test.identical( opener.openedModule.fileName, 'openAnon' );
    test.identical( opener.openedModule.localPath, abs( '.' ) );
    test.identical( opener.openedModule.remotePath, null );
    test.identical( opener.openedModule.currentRemotePath, null );
    test.identical( opener.openedModule.willPath, path.join( __dirname, '../will/Exec' ) );
    test.identical( opener.openedModule.willfilesArray.length, 2 );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.willfileWithRoleMap ), [ 'import', 'export' ] );

    test.is( !!opener.openedModule.about );
    test.identical( opener.openedModule.about.name, 'supermodule' );
    test.identical( opener.openedModule.pathMap, pathMap );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.submoduleMap ), [ 'Submodule' ] );
    test.setsAreIdentical( _.filter( _.mapKeys( opener.openedModule.reflectorMap ), ( e, k ) => _.strHas( e, 'predefined.' ) ? undefined : e ), [ 'reflect.submodules.', 'reflect.submodules.debug' ] );

    let steps = _.select( opener.openedModule.resolve({ selector : 'step::*', criterion : { predefined : 0 } }), '*/name' );
    test.setsAreIdentical( steps, [ 'export.', 'export.debug', 'reflect.submodules.', 'reflect.submodules.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.buildMap ), [ 'export.', 'export.debug', 'debug', 'release' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.exportedMap ), [] );

  }

}

//

function openOutNamed( test )
{
  let self = this;
  let assetName = 'import-in/super.out/supermodule';
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let moduleDirPath = abs( 'super.out' );
  let moduleFilePath = abs( 'super.out/supermodule' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var opener1 = will.openerMake({ willfilesPath : moduleFilePath });
  let ready1 = opener1.open();
  var opener2 = will.openerMake({ willfilesPath : moduleFilePath });
  let ready2 = opener2.open();

  /* - */

  ready1.then( ( arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    check( opener1 );
    return null;
  })

  ready1.finally( ( err, arg ) =>
  {
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    opener1.finit();
    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready2.then( ( arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    check( opener2 );
    return null;
  })

  ready2.finally( ( err, arg ) =>
  {
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    opener2.finit();
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ ready1, ready2 ])
  .finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function check( opener )
  {

    let pathMap =
    {
      'current.remote' : null,
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.original.willfiles' :
      [
        abs( './super.ex.will.yml' ),
        abs( './super.im.will.yml' ),
      ],
      'local' : 'supermodule.out.will.yml',
      'remote' : null,
      'proto' : '../proto',
      'temp' : [ '.', '../sub.out' ],
      'in' : '.',
      'out' : '.',
      'out.debug' : 'debug',
      'out.release' : 'release',
      'exported.dir.export.' : 'release',
      'exported.files.export.' : [ 'release', 'release/File.debug.js', 'release/File.release.js' ],
      'exported.dir.export.debug' : 'debug',
      'exported.files.export.debug' : [ 'debug', 'debug/File.debug.js', 'debug/File.release.js' ],
      'module.willfiles' : abs( './super.out/supermodule.out.will.yml' ),
      'module.dir' : abs( './super.out' ),
      'module.common' : abs( './super.out/supermodule.out' ),
      'module.peer.willfiles' :
      [
        abs( './super.ex.will.yml' ),
        abs( './super.im.will.yml' )
      ]
    }

    test.identical( opener.nickName, 'module::supermodule' );
    test.identical( opener.absoluteName, 'module::supermodule' );
    // test.identical( opener.inPath, abs( './super.out' ) );
    // test.identical( opener.outPath, abs( './super.out' ) );
    test.identical( opener.dirPath, abs( './super.out' ) );
    test.identical( opener.localPath, 'supermodule.out.will.yml' );
    test.identical( opener.willfilesPath, abs( './super.out/supermodule.out.will.yml' ) );
    test.identical( opener.commonPath, abs( 'super.out/supermodule.out' ) );
    test.identical( opener.fileName, 'supermodule.out' );
    test.identical( opener.aliasName, null );

    test.is( !!opener.openedModule.about );
    test.identical( opener.openedModule.about.name, 'supermodule' );

    test.identical( opener.openedModule.pathMap, pathMap ); debugger; // xxx
    test.identical( opener.openedModule.willfilesArray.length, 1 );
    test.identical( _.mapKeys( opener.openedModule.willfileWithRoleMap ), [ 'single' ] );
    test.identical( _.mapKeys( opener.openedModule.submoduleMap ), [ 'Submodule' ] );
    test.setsAreIdentical( _.filter( _.mapKeys( opener.openedModule.reflectorMap ), ( e, k ) => _.strHas( e, 'predefined.' ) ? undefined : e ), [ 'reflect.submodules.', 'reflect.submodules.debug', 'exported.export.debug', 'exported.files.export.debug', 'exported.export.', 'exported.files.export.' ] );

    let steps = _.select( opener.openedModule.resolve({ selector : 'step::*', criterion : { predefined : 0 } }), '*/name' );
    test.setsAreIdentical( steps, [ 'reflect.submodules.', 'reflect.submodules.debug', 'export.', 'export.debug', 'exported.export.debug', 'exported.files.export.debug', 'exported.export.', 'exported.files.export.' ] );

    test.setsAreIdentical( _.mapKeys( opener.openedModule.buildMap ), [ 'debug', 'release', 'export.', 'export.debug' ] );
    test.setsAreIdentical( _.mapKeys( opener.openedModule.exportedMap ), [ 'export.', 'export.debug' ] );

  }

}

//

function clone( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'open';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {
    test.case = 'clone';

    test.description = 'paths of module';
    test.identical( rel( opener.openedModule.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.openedModule.dirPath ), '.' );
    test.identical( rel( opener.openedModule.commonPath ), 'super' );
    test.identical( rel( opener.openedModule.inPath ), '.' );
    test.identical( rel( opener.openedModule.outPath ), 'super.out' );
    test.identical( rel( opener.openedModule.localPath ), 'super' );
    test.identical( rel( opener.openedModule.remotePath ), null );
    test.identical( opener.openedModule.willPath, path.join( __dirname, '../will/Exec' ) );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    var opener2 = opener.clone();

    test.description = 'elements';
    test.identical( opener2.willfilesArray.length, 0 );
    test.setsAreIdentical( _.mapKeys( opener2.willfileWithRoleMap ), [] );
    test.is( !!opener.openedModule );
    test.is( opener2.openedModule === null );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    test.description = 'paths of opener2';
    test.identical( rel( opener2.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener2.dirPath ), '.' );
    test.identical( rel( opener2.commonPath ), 'super' );
    test.identical( rel( opener2.localPath ), 'super' );
    test.identical( rel( opener2.remotePath ), null );

    opener2.close();

    test.description = 'elements';
    test.identical( opener2.willfilesArray.length, 0 );
    test.setsAreIdentical( _.mapKeys( opener2.willfileWithRoleMap ), [] );
    test.is( !!opener.openedModule );
    test.is( opener2.openedModule === null );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    test.description = 'paths of opener2';
    test.identical( rel( opener2.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener2.dirPath ), '.' );
    test.identical( rel( opener2.commonPath ), 'super' );
    test.identical( rel( opener2.localPath ), 'super' );
    test.identical( rel( opener2.remotePath ), null );

    opener2.find();

    test.case = 'compare elements';
    test.is( opener.openedModule === opener2.openedModule );
    test.identical( opener.nickName, opener2.nickName );
    test.identical( opener.absoluteName, opener2.absoluteName );
    test.is( opener.openedModule.about === opener2.openedModule.about );
    test.is( opener.openedModule.pathMap === opener2.openedModule.pathMap );
    test.identical( opener.openedModule.pathMap, opener2.openedModule.pathMap );

    test.is( opener.willfilesArray !== opener2.willfilesArray );
    test.is( opener.willfileWithRoleMap !== opener2.willfileWithRoleMap );

    test.case = 'finit';

    opener2.finit();

    return null;
  })

  ready.then( ( arg ) =>
  {
    test.case = 'clone';

    test.description = 'paths of module';
    test.identical( rel( opener.openedModule.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.openedModule.dirPath ), '.' );
    test.identical( rel( opener.openedModule.commonPath ), 'super' );
    test.identical( rel( opener.openedModule.inPath ), '.' );
    test.identical( rel( opener.openedModule.outPath ), 'super.out' );
    test.identical( rel( opener.openedModule.localPath ), 'super' );
    test.identical( rel( opener.openedModule.remotePath ), null );
    test.identical( opener.openedModule.willPath, path.join( __dirname, '../will/Exec' ) );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    var opener2 = opener.cloneExtending({ willfilesPath : abs( 'sub' ) });

    test.description = 'elements';
    test.identical( opener2.willfilesArray.length, 0 );
    test.setsAreIdentical( _.mapKeys( opener2.willfileWithRoleMap ), [] );
    test.is( !!opener.openedModule );
    test.is( opener2.openedModule === null );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    test.description = 'paths of opener2';
    test.identical( rel( opener2.willfilesPath ), 'sub' );
    test.identical( rel( opener2.dirPath ), '.' );
    test.identical( rel( opener2.commonPath ), 'sub' );
    test.identical( rel( opener2.localPath ), 'super' );
    test.identical( rel( opener2.remotePath ), null );

    opener2.close();

    test.description = 'elements';
    test.identical( opener2.willfilesArray.length, 0 );
    test.setsAreIdentical( _.mapKeys( opener2.willfileWithRoleMap ), [] );
    test.is( !!opener.openedModule );
    test.is( opener2.openedModule === null );

    test.description = 'paths of original opener';
    test.identical( rel( opener.willfilesPath ), [ 'super.ex.will.yml', 'super.im.will.yml' ] );
    test.identical( rel( opener.dirPath ), '.' );
    test.identical( rel( opener.commonPath ), 'super' );
    test.identical( rel( opener.localPath ), 'super' );
    test.identical( rel( opener.remotePath ), null );

    test.description = 'paths of opener2';
    test.identical( rel( opener2.willfilesPath ), 'sub' );
    test.identical( rel( opener2.dirPath ), '.' );
    test.identical( rel( opener2.commonPath ), 'sub' );
    test.identical( rel( opener2.localPath ), 'super' );
    test.identical( rel( opener2.remotePath ), null );

    opener2.find();

    test.description = 'paths of opener2';
    test.identical( rel( opener2.willfilesPath ), [ 'sub.ex.will.yml', 'sub.im.will.yml' ] );
    test.identical( rel( opener2.dirPath ), '.' );
    test.identical( rel( opener2.commonPath ), 'sub' );
    test.identical( rel( opener2.localPath ), 'sub' );
    test.identical( rel( opener2.remotePath ), null );

    test.case = 'compare elements';
    test.is( opener.openedModule !== opener2.openedModule );
    test.identical( opener2.nickName, 'module::sub' );
    test.identical( opener2.absoluteName, 'module::sub' );
    test.is( opener.willfilesArray !== opener2.willfilesArray );
    test.is( opener.willfileWithRoleMap !== opener2.willfileWithRoleMap );

    test.case = 'finit';

    opener2.finit();

    return null;
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );

    opener.finit();

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return arg;
  });

  return ready;

  /* */

  function checkMap( opener2, mapName )
  {
    test.open( mapName );

    test.is( module.openedModule[ mapName ] !== opener2.openedModule[ mapName ] );
    test.setsAreIdentical( _.mapKeys( module.openedModule[ mapName ] ), _.mapKeys( opener2.openedModule[ mapName ] ) );
    for( var k in module.openedModule[ mapName ] )
    {
      var resource1 = module.openedModule[ mapName ][ k ];
      var resource2 = opener2.openedModule[ mapName ][ k ];
      test.is( !!resource1 );
      test.is( !!resource2 );
      if( !resource1 || !resource2 )
      continue;
      test.is( resource1 !== resource2 );
      test.is( resource1.module === module.openedModule );
      test.is( resource2.module === opener2.openedModule );
      if( resource1 instanceof will.Resource )
      {
        test.is( !!resource1.willf || ( resource1.criterion && !!resource1.criterion.predefined ) );
        test.is( resource1.willf === resource2.willf );
      }
    }

    test.close( mapName );
  }

} /* end of function clone */

clone.timeOut = 130000;

//

/*
test
  - following exports preserves followed export
  - openers should throw 2 openning errors
*/

function exportSeveralExports( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'inconsistent-outfile' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let subInPath = abs( 'sub' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let subOutPath = abs( 'sub.out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export debug';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( subOutPath );
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'second export debug';
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export release';
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug', 'export.' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'second export release';
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug', 'export.' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportSeveralExports */

//

function exportSuper( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let superInPath = abs( 'super' );
  let subInPath = abs( 'sub' );
  let superOutFilePath = abs( 'super.out/supermodule.out.will.yml' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export sub, first';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( abs( 'super.out' ) );
    _.fileProvider.filesDelete( abs( 'sub.out' ) );

    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
    ]
    test.identical( files, exp );

    opener = will.openerMake({ willfilesPath : subInPath });

    will.prefer
    ({
      formingOfMain : 0,
      formingOfSub : 0,
    });

    will.readingBegin();
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( module ) =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( module ) =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( module ) =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug', 'export.' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'sub.out', '../sub' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'sub.out' ];
    test.setsAreIdentical( outfile.root, exp );

    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './sub.out/release',
      './sub.out/release/File.release.js'
    ]
    test.identical( files, exp );

    module.finit();

    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export super debug';

    opener = will.openerMake({ willfilesPath : superInPath });

    will.prefer
    ({
      formingOfMain : 0,
      formingOfSub : 0,
    });

    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( superOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'supermodule.out', '../sub.out/sub.out', '../sub', '../super' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'supermodule.out', '../sub.out/sub.out', '../sub', '../super' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'supermodule.out' ];
    test.setsAreIdentical( outfile.root, exp );

    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './sub.out/release',
      './sub.out/release/File.release.js',
      './super.out',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/debug/File.release.js'
    ]
    test.identical( files, exp );

    return null;
  })

  .then( () =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( () =>
  {
    let builds = opener.openedModule.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( superOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'supermodule.out', '../sub.out/sub.out', '../sub', '../super' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug', 'export.' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'supermodule.out', '../sub.out/sub.out', '../sub', '../super' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'supermodule.out' ];
    test.setsAreIdentical( outfile.root, exp );

    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './sub.out/release',
      './sub.out/release/File.release.js',
      './super.out',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/debug/File.release.js',
      './super.out/release',
      './super.out/release/File.debug.js',
      './super.out/release/File.release.js'
    ]
    test.identical( files, exp );

    module.finit();

    return null;
  })

  /* - */

  ready
  .then( ( arg ) =>
  {

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportSuper */

//

/*
test
  - step module.export use path::export if not defined other
*/

function exportDefaultPath( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-default-path' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export willfile with default path';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( 'path' ) });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( _.path.join( outPath, 'path.out.will' ) );
    var modulePaths = _.select( outfile.module[ outfile.root[ 0 ] ], 'path/exported.files.export.debug/path' );
    var exp = [ '..', '../File.txt', '../nofile.will.yml', '../nonglob.will.yml', '../nopath.will.yml', '../path.will.yml', '../reflector.will.yml' ];
    test.identical( modulePaths, exp );
    /* xxx : should include out willfile? */

    var exp = [ '.', './path.out.will.yml' ]
    var files = self.find( outPath );
    test.identical( files, exp )

    module.finit();
    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export willfile with default reflector';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( 'reflector' ) });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( _.path.join( outPath, 'reflector.out.will' ) );
    var modulePaths = _.select( outfile.module[ outfile.root[ 0 ] ], 'path/exported.files.export.debug/path' );
    var exp = [ '..', '../File.txt', '../nofile.will.yml', '../nonglob.will.yml', '../nopath.will.yml', '../path.will.yml', '../reflector.will.yml' ];
    test.identical( modulePaths, exp );

    var exp = [ '.', './reflector.out.will.yml' ]
    var files = self.find( outPath );
    test.identical( files, exp )

    module.finit();
    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export willfile with no default export path';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( 'nopath' ) });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .finally( ( err, arg ) =>
  {
    var module = opener.openedModule;

    test.is( _.errIs( err ) );
    test.is( _.strHas( String( err ), 'Failed to export module::nopath / exported::export.debug' ) );
    test.is( _.strHas( String( err ), 'step::module.export should have defined path or reflector to export. Alternatively module could have defined path::export or reflecotr::export' ) );

    var exp = []
    var files = self.find( outPath );
    test.identical( files, exp )

    module.finit();
    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export willfile with default export path, no file found';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( 'nofile' ) });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .finally( ( err, arg ) =>
  {
    var module = opener.openedModule;

    test.is( _.errIs( err ) );
    test.is( _.strHas( String( err ), 'Failed to export module::nofile / exported::export.debug' ) );
    test.is( _.strHas( String( err ), 'No file found at' ) );

    var exp = []
    var files = self.find( outPath );
    test.identical( files, exp )

    module.finit();
    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export willfile with default nonglob export path';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( 'nonglob' ) });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .finally( ( err, arg ) =>
  {
    var module = opener.openedModule;

    test.is( err === undefined );

    // test.is( _.errIs( err ) );
    // test.is( _.strHas( String( err ), 'Failed to export module::nonglob / exported::export.debug' ) );
    // test.is( _.strHas( String( err ), 'is not glob. Only glob allowed' ) );

    var exp = [ '.', './nonglob.out.will.yml' ];
    var files = self.find( outPath );
    test.identical( files, exp );

    module.finit();
    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'no garbage left';

    var exp = [];
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
    test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
    var exp = [];
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
    test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );
    var exp = [];
    test.identical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), exp );
    var exp = [];
    test.identical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), exp );
    var exp = [];
    test.identical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), exp );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportDefaultPath */

exportDefaultPath.timeOut = 300000;

//

/*
test
  - outdate outfile should not used to preserve its content
*/

function exportInconsistent( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'inconsistent-outfile' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let subInPath = abs( 'sub' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let subOutPath = abs( 'sub.out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export debug';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( subOutPath );
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export release, but input willfile is changed';
    _.fileProvider.fileAppend( abs( 'sub.ex.will.yml' ), '\n' );
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 0 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.' ];
    test.setsAreIdentical( exported, exp );

    var exp = [ '.', './sub.out.will.yml' ];
    var files = self.find( subOutPath );
    test.identical( files, exp )

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 2 errors, because 2 attempt to open outwillfile';
    // test.identical( will.openersErrorsArray.length, 2 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportInconsistent */

//

/*
test
  - corrupted outfile is not a problem to reexport a module
  - try to open corrupted out file only 1 time
  - does not try to open corrupted file during reset opening options
*/

function exportCourrputedOutfileUnknownSection( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'corrupted-outfile-unknown-section' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let subInPath = abs( 'sub' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export sub';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

    opener = will.openerMake({ willfilesPath : subInPath });

    will.prefer
    ({
      formingOfMain : 0,
      formingOfSub : 0,
    });

    will.readingBegin();

    return opener.open({ forming : 0, formingPeerModules : 1 });
  })

  .then( ( module ) =>
  {
    return opener.open({ forming : 1 });
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'sub.out', '../sub' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'sub.out' ];
    test.setsAreIdentical( outfile.root, exp );

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportCourrputedOutfileUnknownSection */

//

/*
test
  - corrupted outfile with syntax error is not a problem to reexport a module
  - try to open corrupted out file only 1 time
  - does not try to open corrupted file during reset opening options
*/

function exportCourruptedOutfileSyntax( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'corrupted-outfile-syntax' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let subInPath = abs( 'sub' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export sub';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

    opener = will.openerMake({ willfilesPath : subInPath });

    will.prefer
    ({
      formingOfMain : 0,
      formingOfSub : 0,
    });

    will.readingBegin();

    return opener.open({ forming : 0, formingPeerModules : 1 });
  })

  .then( ( module ) =>
  {
    return opener.open({ forming : 1 });
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    will.readingEnd();
    return build.perform();
  })

  .then( ( arg ) =>
  {
    var module = opener.openedModule;
    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'sub.out', '../sub' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'sub.out' ];
    test.setsAreIdentical( outfile.root, exp );

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportCourruptedOutfileSyntax */

//

/*
test
  - no extra errors made
  - corrupted outfile of submodule is not a problem
  - recursive export works
*/

function exportCourrputedSubmoduleOutfileUnknownSection( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'corrupted-submodule-outfile-unknown-section' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let superInPath = abs( 'super' );
  let subInPath = abs( 'sub' );
  let superOutFilePath = abs( 'super.out/supermodule.out.will.yml' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export super';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : superInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    return build.perform();
  })

  .finally( ( err, arg ) =>
  {
    var module = opener.openedModule;

    test.is( _.errIs( err ) );

    var exp = [ '.', './sub.ex.will.yml', './sub.im.will.yml', './super.ex.will.yml', './super.im.will.yml', './sub.out', './sub.out/sub.out.will.yml' ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    test.description = 'should be only 3 errors, because 1 attempt to open corrupted outwillfile of submodule and 2 attempt to open outwillfiles of supermodule which does not exist';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 3 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - xxx - */

  // ready
  // .then( () =>
  // {
  //   test.description = 'export super, recursive : 2';
  //   _.fileProvider.filesDelete( routinePath );
  //   _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  //   opener = will.openerMake({ willfilesPath : superInPath });
  //   return opener.open();
  // })
  //
  // .then( ( module ) =>
  // {
  //   let builds = module.exportsResolve({ criterion : { debug : 1 } });
  //   let build = builds[ 0 ];
  //   let run = new will.BuildRun
  //   ({
  //     build,
  //     recursive : 2,
  //     withIntegrated : 2,
  //   });
  //   return build.perform({ run });
  // })
  //
  // .finally( ( err, arg ) =>
  // {
  //   var module = opener.openedModule;
  //
  //   test.is( err === undefined );
  //
  //   var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
  //   var modulePaths = _.mapKeys( outfile.module );
  //   var exp = [ 'sub.out', '../sub' ];
  //   test.identical( modulePaths, exp );
  //   var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
  //   var exp = [ 'export.debug' ];
  //   test.setsAreIdentical( exported, exp );
  //   var sections = _.mapKeys( outfile );
  //   var exp = [ 'format', 'root', 'consistency', 'module' ];
  //   test.setsAreIdentical( sections, exp );
  //   var exp = [ 'sub.out', '../sub' ];
  //   test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
  //   var exp = [ 'sub.out' ];
  //   test.setsAreIdentical( outfile.root, exp );
  //
  //   var exp =
  //   [
  //     '.',
  //     './sub.ex.will.yml',
  //     './sub.im.will.yml',
  //     './super.ex.will.yml',
  //     './super.im.will.yml',
  //     './sub.out',
  //     './sub.out/sub.out.will.yml',
  //     './super.out',
  //     './super.out/supermodule.out.will.yml'
  //   ]
  //   var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
  //   test.identical( files, exp );
  //
  //   module.finit();
  //
  //   test.is( module.finitedIs() );
  //   test.is( opener.finitedIs() );
  //
  //   // test.description = 'should be only 3 errors, because 1 attempt to open corrupted outwillfile of submodule and 2 attempt to open outwillfiles of supermodule which does not exist';
  //   // test.identical( will.openersErrorsArray.length, 3 );
  //   test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
  //   test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
  //   will.openersErrorsRemoveAll();
  //   test.identical( will.openersErrorsArray.length, 0 );
  //
  //   test.description = 'no grabage left';
  //   test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
  //   test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
  //   test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );
  //
  //   return null;
  // });

  /* - */

  return ready;

} /* end of function exportCourrputedSubmoduleOutfileUnknownSection */

//

/*
test
  - no extra errors made
  - outfile of submodule with not-supported version of format is not a problem
  - recursive export works
*/

function exportCourrputedSubmoduleOutfileFormatVersion( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'corrupted-submodule-outfile-format-version' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let superInPath = abs( 'super' );
  let subInPath = abs( 'sub' );
  let superOutFilePath = abs( 'super.out/supermodule.out.will.yml' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  // ready
  // .then( () =>
  // {
  //   test.description = 'export super';
  //   _.fileProvider.filesDelete( routinePath );
  //   _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  //   opener = will.openerMake({ willfilesPath : superInPath });
  //   return opener.open();
  // })
  //
  // .then( ( module ) =>
  // {
  //   let builds = module.exportsResolve({ criterion : { debug : 1 } });
  //   let build = builds[ 0 ];
  //   return build.perform();
  // })
  //
  // .finally( ( err, arg ) =>
  // {
  //   var module = opener.openedModule;
  //
  //   test.is( _.errIs( err ) );
  //
  //   var exp = [ '.', './sub.ex.will.yml', './sub.im.will.yml', './super.ex.will.yml', './super.im.will.yml', './sub.out', './sub.out/sub.out.will.yml' ]
  //   var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
  //   test.identical( files, exp );
  //
  //   module.finit();
  //
  //   test.is( module.finitedIs() );
  //   test.is( opener.finitedIs() );
  //
  //   test.description = 'should be only 3 errors, because 1 attempt to open corrupted outwillfile of submodule and 2 attempt to open outwillfiles of supermodule which does not exist';
  //   test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 3 );
  //   will.openersErrorsRemoveAll();
  //   test.identical( will.openersErrorsArray.length, 0 );
  //
  //   test.description = 'no grabage left';
  //   test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
  //   test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
  //   test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
  //   test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
  //   test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );
  //
  //   return null;
  // });

  /* */

  ready
  .then( () =>
  {
    test.description = 'export super, recursive : 2';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : superInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {
    let builds = module.exportsResolve({ criterion : { debug : 1 } });
    let build = builds[ 0 ];
    let run = new will.BuildRun
    ({
      build,
      recursive : 2,
      withIntegrated : 2,
    });
    return build.perform({ run });
  })

  .finally( ( err, arg ) =>
  {
    var module = opener.openedModule;

    test.is( err === undefined );

    debugger; return null; xxx

    var outfile = _.fileProvider.fileConfigRead( subOutFilePath );
    var modulePaths = _.mapKeys( outfile.module );
    var exp = [ 'sub.out', '../sub' ];
    test.identical( modulePaths, exp );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );
    var sections = _.mapKeys( outfile );
    var exp = [ 'format', 'root', 'consistency', 'module' ];
    test.setsAreIdentical( sections, exp );
    var exp = [ 'sub.out', '../sub' ];
    test.setsAreIdentical( _.mapKeys( outfile.module ), exp );
    var exp = [ 'sub.out' ];
    test.setsAreIdentical( outfile.root, exp );

    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './super.out',
      './super.out/supermodule.out.will.yml'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    module.finit();

    test.is( module.finitedIs() );
    test.is( opener.finitedIs() );

    // test.description = 'should be only 3 errors, because 1 attempt to open corrupted outwillfile of submodule and 2 attempt to open outwillfiles of supermodule which does not exist';
    // test.identical( will.openersErrorsArray.length, 3 );
    test.description = 'should be only 1 error, because 1 attempt to open corrupted outwillfile, 2 times in the list, because for different openers';
    test.identical( _.longOnce( _.select( will.openersErrorsArray, '*/err' ) ).length, 1 );
    will.openersErrorsRemoveAll();
    test.identical( will.openersErrorsArray.length, 0 );

    test.description = 'no grabage left';
    test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
    test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
    test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
    test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

    return null;
  });

  /* - */

  return ready;

} /* end of function exportCourrputedSubmoduleOutfileFormatVersion */

//

function resolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'make' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'v1' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( '', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    test.description = 'export super';
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  .then( () =>
  {

    test.case = 'array of numbers';
    debugger;
    var module = opener.openedModule;
    var got = module.openedModule.resolve
    ({
      selector : [ 1, 3 ],
      prefixlessAction : 'resolved',
    });
    var expected = [ 1, 3 ];
    test.identical( got, expected );

    return null;
  })

  .finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    var module = opener.openedModule;
    module.finit();
    return arg;
  })

  /* - */

  return ready;
}

//

function resolveExport( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'corrupted-submodule-outfile-unknown-section' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let superInPath = abs( 'super' );
  let subInPath = abs( 'sub' );
  let superOutFilePath = abs( 'super.out/supermodule.out.will.yml' );
  let subOutFilePath = abs( 'sub.out/sub.out.will.yml' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : subInPath });
    return opener.open();
  })

  .then( ( module ) =>
  {

    test.case = 'default';
    var builds = module.exportsResolve();
    test.setsAreIdentical( _.select( builds, '*/name' ), [ 'export.', 'export.debug' ] );

    test.case = 'debug : 1';
    var builds = module.exportsResolve({ criterion : { debug : 1 } });
    test.setsAreIdentical( _.select( builds, '*/name' ), [ 'export.debug' ] );

    test.case = 'raw : 1, strictCriterion : 1';
    var builds = module.exportsResolve({ criterion : { raw : 1 }, strictCriterion : 1 });
    test.setsAreIdentical( _.select( builds, '*/name' ), [] );

    test.case = 'raw : 1, strictCriterion : 0';
    var builds = module.exportsResolve({ criterion : { raw : 1 }, strictCriterion : 0 });
    test.setsAreIdentical( _.select( builds, '*/name' ), [ 'export.', 'export.debug' ] );

    module.finit();
    return null;
  })

  /* - */

  return ready;

} /* end of function resolveExport */

//

function reflectorResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'composite-reflector' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( filePath );
  }

  function pout( filePath )
  {
    return abs( 'super.out', filePath );
  }

  // _.fileProvider.filesDelete( routinePath );
  // _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  // _.fileProvider.filesDelete( outPath );
  //
  // var module = will.openerMake({ willfilesPath : modulePath });

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'reflector::reflect.proto.0.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.0.debug' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug' },
      'criterion' : { 'debug' : 1, 'variant' : 0 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.0.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.0.debug' )
    var expected =
    {
      'src' :
      {
        'filePath' : { 'path::proto' : 'path::out.*=1' }
      },
      'criterion' : { 'debug' : 1, 'variant' : 0 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1
    }
    resolved.form();
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.1.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.1.debug' )
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug' },
      'criterion' : { 'debug' : 1, 'variant' : 1 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.1.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.1.debug' )
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { 'path::proto' : 'path::out.*=1' }
      },
      'criterion' : { 'debug' : 1, 'variant' : 1 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }

    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.2.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.2.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug' },
      'criterion' : { 'debug' : 1, 'variant' : 2 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.2.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.2.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { 'path::proto' : 'path::out.*=1' }
      },
      'criterion' : { 'debug' : 1, 'variant' : 2 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.3.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.3.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug' },
      'criterion' : { 'debug' : 1, 'variant' : 3 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport({ formed:1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.3.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.3.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '{path::proto}' : '{path::out.*=1}' }
      },
      'criterion' : { 'debug' : 1, 'variant' : 3 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto.4.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.4.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto/dir2',
      },
      'dst' : { 'prefixPath' : 'out/debug/dir1' },
      'criterion' : { 'debug' : 1, 'variant' : 4 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1' ) );

    test.case = 'reflector::reflect.proto.4.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.4.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '{path::proto}/{path::dir2}' : '{path::out.*=1}/{path::dir1}' }
      },
      'criterion' : { 'debug' : 1, 'variant' : 4 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1' ) );

    test.case = 'reflector::reflect.proto.5.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.5.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'maskAll' : { 'excludeAny' : true },
        'prefixPath' : 'proto/dir2',
      },
      'dst' : { 'prefixPath' : 'out/debug/dir1' },
      'criterion' : { 'debug' : 1, 'variant' : 5 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1' ) );

    test.case = 'reflector::reflect.proto.5.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.5.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : '{path::proto}/{path::dir2}'
      },
      'dst' : { 'prefixPath' : '{path::out.*=1}/{path::dir1}' },
      'criterion' : { 'debug' : 1, 'variant' : 5 },
      'inherit' : [ 'predefined.*' ],
      'mandatory' : 1
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1' ) );

    test.case = 'reflector::reflect.proto.6.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.6.debug' );
    resolved.form();
    var expected =
    {
      'src' : { 'prefixPath' : 'proto/dir2/File.test.js' },
      'dst' : { 'prefixPath' : 'out/debug/dir1/File.test.js' },
      'criterion' : { 'debug' : 1, 'variant' : 6 },
      'mandatory' : 1
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2/File.test.js' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1/File.test.js' ) );

    test.case = 'reflector::reflect.proto.6.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.6.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'prefixPath' : '{path::proto}/{path::dir2}/{path::testFile}'
      },
      'dst' :
      {
        'prefixPath' : '{path::out.*=1}/{path::dir1}/{path::testFile}'
      },
      'criterion' : { 'debug' : 1, 'variant' : 6 },
      'mandatory' : 1
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2/File.test.js' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1/File.test.js' ) );

    test.case = 'reflector::reflect.proto.7.debug formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.7.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto/dir2/File.test.js',
      },
      'dst' : { 'prefixPath' : 'out/debug/dir1/File.test.js' },
      'criterion' : { 'debug' : 1, 'variant' : 7 },
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2/File.test.js' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1/File.test.js' ) );

    test.case = 'reflector::reflect.proto.7.debug';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto.7.debug' );
    resolved.form();
    var expected =
    {
      'src' :
      {
        'filePath' :
        {
          '{path::proto}/{path::dir2}/{path::testFile}' : '{path::out.*=1}/{path::dir1}/{path::testFile}'
        }
      },
      'criterion' : { 'debug' : 1, 'variant' : 7 },
      'mandatory' : 1,
    }
    var resolvedData = resolved.structureExport();
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );
    test.identical( resolved.src.prefixPath, pin( 'proto/dir2/File.test.js' ) );
    test.identical( resolved.dst.prefixPath, pin( 'out/debug/dir1/File.test.js' ) );

    return null;
  });

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  return ready;
}

//

function reflectorInheritedResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'reflect-inherit' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( filePath );
  }

  function pout( filePath )
  {
    return abs( 'super.out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'reflector::reflect.proto1 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto1' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug1' },
      'mandatory' : 1
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto2 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto2' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug2' },
      'mandatory' : 1,
      'inherit' : [ 'reflect.proto1' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto3 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto3' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug1' },
      'mandatory' : 1,
      'inherit' : [ 'reflect.proto1' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto4 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto4' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug2' },
      'mandatory' : 1,
      'inherit' : [ 'reflect.proto1' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.proto5 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.proto5' )
    var expected =
    {
      'src' :
      {
        'filePath' : { '.' : '.' },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out/debug2' },
      'mandatory' : 1,
      'inherit' : [ 'reflect.proto1' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.not.test.only.js.v1 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.not.test.only.js.v1' )
    var expected =
    {
      'src' :
      {
        'filePath' :
        {
          '.' : [ 'debug1', 'debug2' ],
          '**.test**' : false
        },
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out' },
      'mandatory' : 1,
      'inherit' : [ 'not.test', 'only.js' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.files1 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.files1' )
    var expected =
    {
      'src' :
      {
        'filePath' : { 'File.js' : '.', 'File.s' : '.' },
        'basePath' : '.',
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out' },
      'mandatory' : 1,
      'inherit' : [ 'reflector::files3' ]
    }
    debugger;
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.files2 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.files2' )
    var expected =
    {
      'src' :
      {
        'filePath' : { 'File.js' : '.', 'File.s' : '.' },
        'basePath' : '.',
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out' },
      'mandatory' : 1,
      'inherit' : [ 'reflector::files3' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    test.case = 'reflector::reflect.files3 formed:1';
    var resolved = module.openedModule.resolve( 'reflector::reflect.files3' )
    var expected =
    {
      'src' :
      {
        'filePath' : { 'File.js' : '.', 'File.s' : '.' },
        'basePath' : '.',
        'prefixPath' : 'proto'
      },
      'dst' : { 'prefixPath' : 'out' },
      'mandatory' : 1,
      'inherit' : [ 'reflector::files3' ]
    }
    resolved.form();
    var resolvedData = resolved.structureExport({ formed : 1 });
    if( resolvedData.src && resolvedData.src.maskAll )
    resolvedData.src.maskAll.excludeAny = !!resolvedData.src.maskAll.excludeAny;
    test.identical( resolved.formed, 3 );
    test.identical( resolvedData, expected );

    return null;
  });

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  return ready;
}

//

function superResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-multiple' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'build::*';
    var resolved = module.openedModule.resolve( 'build::*' );
    test.identical( resolved.length, 4 );

    test.case = '*::*a*';
    var resolved = module.openedModule.resolve
    ({
      selector : '*::*a*',
      pathUnwrapping : 0,
      missingAction : 'undefine',
    });
    test.identical( resolved.length, 15 );

    test.case = '*::*a*/nickName';
    var resolved = module.openedModule.resolve
    ({
      selector : '*::*a*/nickName',
      pathUnwrapping : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      missingAction : 'undefine',
    });
    test.identical( resolved, [ 'path::module.original.willfiles', 'path::local', 'path::out.release', 'reflector::predefined.release.v1', 'reflector::predefined.release.v2', 'step::timelapse.begin', 'step::timelapse.end', 'step::files.transpile', 'step::npm.generate', 'step::submodules.download', 'step::submodules.update', 'step::submodules.reload', 'step::submodules.clean', 'step::clean', 'build::release' ] );

    test.case = '*';
    var resolved = module.openedModule.resolve
    ({
      selector : '*',
      pathUnwrapping : 1,
      pathResolving : 0
    });
    test.identical( resolved, '*' );

    test.case = '*::*';
    var resolved = module.openedModule.resolve
    ({
      selector : '*::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 0,
    });
    test.identical( resolved.length, 45 );

    test.case = '* + defaultResourceKind';
    var resolved = module.openedModule.resolve
    ({
      selector : '*',
      defaultResourceKind : 'path',
      prefixlessAction : 'default',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 0,
    });
    test.identical( resolved.length, 14 );

    return null;
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  return ready;
}

superResolve.timeOut = 130000;

//

function buildsResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-multiple' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'build::*'; /* */

    var resolved = module.openedModule.resolve({ selector : 'build::*' });
    test.identical( resolved.length, 4 );

    var expected = [ 'debug', 'release', 'export.', 'export.debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected =
    [
      [ 'step::submodules.download', 'step::reflect.submodules.*=1' ],
      [ 'step::submodules.download', 'step::reflect.submodules.*=1' ],
      [ 'build::*=1', 'step::export*=1' ],
      [ 'build::*=1', 'step::export*=1' ]
    ];
    var got = _.select( resolved, '*/steps' );
    test.identical( got, expected );

    test.case = 'build::*, with criterion'; /* */

    var resolved = module.openedModule.resolve({ selector : 'build::*', criterion : { debug : 1 } });
    test.identical( resolved.length, 2 );

    var expected = [ 'debug', 'export.debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    test.case = 'build::*, currentContext is build::export.'; /* */

    var build = module.openedModule.resolve({ selector : 'build::export.' });
    test.is( build instanceof will.Build );
    test.identical( build.nickName, 'build::export.' );
    test.identical( build.absoluteName, 'module::supermodule / build::export.' );

    var resolved = module.openedModule.resolve({ selector : 'build::*', currentContext : build, singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'release' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected = { 'debug' : 0 };
    var got = resolved[ 0 ].criterion;
    test.identical( got, expected );

    test.case = 'build::*, currentContext is build::export.debug'; /* */

    var build = module.openedModule.resolve({ selector : 'build::export.debug' });
    var resolved = module.openedModule.resolve({ selector : 'build::*', currentContext : build, singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected = { 'debug' : 1, 'default' : 1 };
    var got = resolved[ 0 ].criterion;
    test.identical( got, expected );

    test.case = 'build::*, currentContext is build::export.debug, short-cut'; /* */

    var build = module.openedModule.resolve({ selector : 'build::export.debug' });
    var resolved = build.resolve({ selector : 'build::*', singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    test.case = 'build::*, short-cut, explicit criterion'; /* */

    var build = module.openedModule.resolve({ selector : 'build::export.*', criterion : { debug : 1 } });
    var resolved = build.resolve({ selector : 'build::*', singleUnwrapping : 0, criterion : { debug : 0 } });
    test.identical( resolved.length, 2 );

    var expected = [ 'release', 'export.' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    return null;
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  return ready;
}

buildsResolve.timeOut = 130000;

//

function pathsResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-multiple' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let execPath = _.path.join( __dirname, '../will/Exec' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    if( _.arrayIs( filePath ) )
    return filePath.map( ( e ) => abs( e ) );
    return abs( filePath );
  }

  function pout( filePath )
  {
    if( _.arrayIs( filePath ) )
    return filePath.map( ( e ) => abs( 'super.out', e ) );
    return abs( 'super.out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'resolved, .';
    var resolved = module.openedModule.resolve({ prefixlessAction : 'resolved', selector : '.' })
    var expected = '.';
    test.identical( resolved, expected );

    return null;
  })

  ready.then( ( arg ) =>
  {

    test.case = 'path::in*=1, pathResolving : 0';
    var resolved = module.openedModule.resolve({ prefixlessAction : 'resolved', selector : 'path::in*=1', pathResolving : 0 })
    var expected = '.';
    test.identical( resolved, expected );

    test.case = 'path::in*=1';
    var resolved = module.openedModule.resolve({ prefixlessAction : 'resolved', selector : 'path::in*=1' })
    var expected = routinePath;
    test.identical( resolved, expected );

    test.case = 'path::out.debug';
    var resolved = module.openedModule.resolve( 'path::out.debug' )
    var expected = pin( 'super.out/debug' );
    test.identical( resolved, expected );

    test.case = '[ path::out.debug, path::out.release ]';
    var resolved = module.openedModule.resolve( [ 'path::out.debug', 'path::out.release' ] );
    var expected = pin([ 'super.out/debug', 'super.out/release' ]);
    test.identical( resolved, expected );

    test.case = '{path::in*=1}/proto, pathNativizing : 1';
    var resolved = module.openedModule.resolve({ selector : '{path::in*=1}/proto', pathNativizing : 1, selectorIsPath : 1 })
    var expected = _.path.nativize( pin( 'proto' ) );
    test.identical( resolved, expected );

    test.case = '{path::in*=1}/proto, pathNativizing : 1';
    var resolved = module.openedModule.resolve({ selector : '{path::in*=1}/proto', pathNativizing : 1, selectorIsPath : 0 })
    var expected = _.path.nativize( pin( '.' ) ) + '/proto';
    test.identical( resolved, expected );

    return null;
  })

  /* - */

  ready.then( ( arg ) =>
  {

    test.case = 'path::* - implicit'; /* */
    var resolved = module.openedModule.resolve( 'path::*' );
    var expected = pin([ './super.im.will.yml', './super.ex.will.yml', '.', path.join( __dirname, '../will/Exec' ), './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ]);

    var expected = pin
    ([
      './super.im.will.yml',
      './super.ex.will.yml',
      null,
      './',
      'super',
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      './super.out',
      './super.out/debug',
      './super.out/release'
    ]);

    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:in'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
      pathResolving : 'in',
    });
    var expected = pin
    ([
      [
        './super.im.will.yml',
        './super.ex.will.yml'
      ],
      null,
      './',
      'super',
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      './super.out',
      './super.out/debug',
      './super.out/release',
    ]);
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:out'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
      pathResolving : 'out',
    });
    var expected = pout
    ([
        pin
        ([
          './super.im.will.yml',
          './super.ex.will.yml'
        ]),
        null,
        pin( './' ),
        pin( 'super' ),
        null,
        null,
        null,
        execPath,
        './proto',
        './super.out',
        '.',
        '.',
        './super.out/debug',
        './super.out/release'
    ]);
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:null'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
      pathResolving : null,
    });
    var expected =
    [
      [
        pin( './super.im.will.yml' ),
        pin( './super.ex.will.yml' ),
      ],
      null,
      pin( './' ),
      pin( 'super' ),
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      './super.out',
      './super.out/debug',
      './super.out/release'
    ];
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:0 pr:null'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
      pathResolving : null,
    });
    var expected =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ './super.im.will.yml', './super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );
    _.any( resolved, ( e, k ) => test.is( e.identicalWith( module.openedModule.pathResourceMap[ k ] ) ) );
    _.any( resolved, ( e, k ) => test.is( e.module === module || e.module === module.openedModule ) );
    _.any( resolved, ( e, k ) => test.is( !e.original ) );

    test.case = 'path::* - pu:0 mvu:0 pr:in'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      pathResolving : 'in',
    });
    var expected =
    {
      'proto' : pin( './proto' ),
      'temp' : pin( './super.out' ),
      'in' : pin( '.' ),
      'out' : pin( './super.out' ),
      'out.debug' : pin( './super.out/debug' ),
      'out.release' : pin( './super.out/release' ),
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ '/super.im.will.yml', '/super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null,
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:0 pr:out'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      pathResolving : 'out',
    });
    var expected =
    {
      'proto' : pout( './proto' ),
      'temp' : pout( './super.out' ),
      'in' : pout( '.' ),
      'out' : pout( '.' ),
      'out.debug' : pout( './super.out/debug' ),
      'out.release' : pout( './super.out/release' ),
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ './super.im.will.yml', './super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:null'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : null,
    });
    var expected =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ './super.im.will.yml', './super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:in'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : 'in',
    });
    var expected =
    {
      'proto' : pin( './proto' ),
      'temp' : pin( './super.out' ),
      'in' : pin( '.' ),
      'out' : pin( './super.out' ),
      'out.debug' : pin( './super.out/debug' ),
      'out.release' : pin( './super.out/release' ),
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ './super.im.will.yml', './super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:out'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : 'out',
    });
    var expected =
    {
      'proto' : pout( './proto' ),
      'temp' : pout( './super.out' ),
      'in' : pout( '.' ),
      'out' : pout( '.' ),
      'out.debug' : pout( './super.out/debug' ),
      'out.release' : pout( './super.out/release' ),
      'will' : path.join( __dirname, '../will/Exec' ),
      'module.dir' : abs( './' ),
      'module.willfiles' : abs([ './super.im.will.yml', './super.ex.will.yml' ]),
      'module.common' : abs( './super' ),
      'module.original.willfiles' : null,
      'local' : null,
      'remote' : null,
      'current.remote' : null
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:null'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : null,
    });
    var expected =
    [
      [
        pin( './super.im.will.yml' ),
        pin( './super.ex.will.yml' ),
      ],
      null,
      pin( './' ),
      pin( 'super' ),
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      './super.out',
      './super.out/debug',
      './super.out/release'
    ];
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:in'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 'in',
    });
    var expected = pin
    ([
      [
        './super.im.will.yml',
        './super.ex.will.yml'
      ],
      null,
      './',
      'super',
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      './super.out',
      './super.out/debug',
      './super.out/release'
    ])
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:out'; /* */
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 'out',
    });
    var expected = pout
    ([
      [
        pin( './super.im.will.yml' ),
        pin( './super.ex.will.yml' ),
      ],
      null,
      pin( './' ),
      pin( 'super' ),
      null,
      null,
      null,
      execPath,
      './proto',
      './super.out',
      '.',
      '.',
      './super.out/debug',
      './super.out/release',
    ]);
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    return null;
  });

  /* - */

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  return ready;
}

pathsResolve.timeOut = 130000;

//

function pathsResolveImportIn( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'two-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( filePath );
  }

  function sout( filePath )
  {
    return abs( 'super.out', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'submodule::*/path::in*=1, default';
    var resolved = module.openedModule.resolve( 'submodule::*/path::in*=1' )
    var expected = pin( 'out' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, pathResolving : 0';
    var resolved = module.openedModule.resolve({ prefixlessAction : 'resolved', selector : 'submodule::*/path::in*=1', pathResolving : 0 })
    var expected = '.';
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, strange case';
    var resolved = module.openedModule.resolve
    ({
      selector : 'submodule::*/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      mapFlattening : 1,
    });
    var expected = pin( 'out' );
    test.identical( resolved, expected );

    return null;
  });

  ready.then( ( arg ) =>
  {

/*
  pathUnwrapping : 1,
  pathResolving : 0,
  mapFlattening : 1,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
*/

    /* - */

    test.open( 'in' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '.' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'Submodule/in' : '.' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      singleUnwrapping : 0,
      mapFlattening : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '.' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'Submodule' : { 'in' : '.' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';

    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pout( '.' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      singleUnwrapping : 0,
      mapFlattening : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ pout( '.' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'Submodule/in' : pout( '.' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      singleUnwrapping : 0,
      mapFlattening : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ pout( '.' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'Submodule' : { 'in' : pout( '.' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'in' );

    /* - */

    test.open( 'proto' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      mapValsUnwrapping : 1,
      singleUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = [ [ '../proto' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'Submodule/proto' : '../proto' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      singleUnwrapping : 0,
      mapFlattening : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '../proto' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'Submodule' : { 'proto' : '../proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';

    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      mapValsUnwrapping : 1,
      singleUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = [ [ pin( 'proto' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'Submodule/proto' : pin( 'proto' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ pin( 'proto' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected =
    {
      'Submodule' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'proto' );

    return null;
  })

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

pathsResolveImportIn.timeOut = 130000;

//

function pathsResolveOfSubmodules( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'submodules-local-repos' );
  let repoPath = _.path.join( self.tempDir, '_repo' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesDelete( repoPath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesReflect({ reflectMap : { [ self.repoDirPath ] : repoPath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : abs( './' ) });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {
    let builds = module.openedModule.buildsResolve({ name : 'debug.raw' });
    test.identical( builds.length, 1 );
    let build = builds[ 0 ];
    debugger;
    return build.perform();
  })

  ready.then( ( arg ) =>
  {
    debugger;

    test.case = 'resolve submodules';
    var submodules = module.openedModule.submodulesResolve({ selector : '*' });
    test.identical( submodules.length, 2 );

    test.case = 'path::in, supermodule';
    var resolved = module.openedModule.resolve( 'path::in' );
    var expected = path.join( routinePath );
    test.identical( resolved, expected );

    test.case = 'path::in, wTools';
    var submodule = submodules[ 0 ];
    var resolved = submodule.resolve( 'path::in' );
    var expected = path.join( submodulesPath, 'Tools/out' );
    test.identical( resolved, expected );

    test.case = 'path::in, wTools, through opener';
    var submodule = submodules[ 0 ].opener;
    var resolved = submodule.openedModule.resolve( 'path::in' );
    var expected = path.join( submodulesPath, 'Tools/out' );
    test.identical( resolved, expected );

    test.case = 'path::out, wTools';
    var submodule = submodules[ 0 ];
    debugger;
    var resolved = submodule.resolve( 'path::out' );
    debugger;
    var expected = path.join( submodulesPath, 'Tools/out' );
    test.identical( resolved, expected );

    test.case = 'path::out, wTools, through opener';
    var submodule = submodules[ 0 ].opener;
    var resolved = submodule.openedModule.resolve( 'path::out' );
    var expected = path.join( submodulesPath, 'Tools/out' );
    test.identical( resolved, expected );

    return null;
  })

  ready.finally( ( err, arg ) =>
  {
    debugger;
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  })

  // return ready.split().finally( ( err, arg ) =>
  // {
  //   debugger;
  //   if( err && err.finited )
  //   return null;
  //   if( err )
  //   throw err;
  //   return null;
  // });

  /* - */

  return ready;
}

pathsResolveOfSubmodules.timeOut = 130000;

//

function pathsResolveOfSubmodulesAndOwn( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'resolve-path-of-submodules' );
  let repoPath = _.path.join( self.tempDir, '_repo' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : abs( './ab/' ) });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'path::export';
    let resolved = module.openedModule.pathResolve
    ({
      selector : 'path::export',
      currentContext : null,
      pathResolving : 'in',
    });
    var expected =
    [
      'proto/a',
      'proto/a/File.js',
      'proto/b',
      'proto/b/-Excluded.js',
      'proto/b/File.js',
      'proto/b/File.test.js',
      'proto/b/File1.debug.js',
      'proto/b/File1.release.js',
      'proto/b/File2.debug.js',
      'proto/b/File2.release.js',
      'proto/dir3.test'
    ]
    expected = pin( expected );
    test.identical( resolved, expected );

    return null;
  })

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  })

  // return ready.split().finally( ( err, arg ) =>
  // {
  //   if( err && err.finited )
  //   return null;
  //   if( err )
  //   throw err;
  //   return null;
  // });

  /* - */

  return ready;
}

pathsResolveOfSubmodulesAndOwn.timeOut = 300000;

//

function pathsResolveOutFileOfExports( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-multiple-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'super.out/supermodule' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  function sout( filePath )
  {
    return abs( 'super.out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.open( 'without export' );

    test.case = 'submodule::*/path::in*=1, default';
    var resolved = module.openedModule.resolve( 'submodule::*/path::in*=1' );
    var expected = sout( '.' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, pathResolving : 0';
    var resolved = module.openedModule.resolve({ prefixlessAction : 'resolved', selector : 'submodule::*/path::in*=1', pathResolving : 0 });
    var expected = '.';
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, strange case';
    var resolved = module.openedModule.resolve
    ({
      selector : 'submodule::*/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      mapFlattening : 1,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );

    test.close( 'without export' );

    /* - */

    test.open( 'with export' );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, default';
    var resolved = module.openedModule.resolve( 'submodule::*/exported::*=1debug/path::in*=1' );
    var expected = sout( '.' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, pathResolving : 0';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/exported::*=1debug/path::in*=1',
      pathResolving : 0,
    })
    var expected = '.';
    test.identical( resolved, expected );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, strange case';
    var resolved = module.openedModule.resolve
    ({
      selector : 'submodule::*/exported::*=1debug/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      mapFlattening : 1,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );

    test.close( 'with export' );

    return null;
  });

  ready.then( ( arg ) =>
  {

/*
  pathUnwrapping : 1,
  pathResolving : 0,
  mapFlattening : 1,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
*/

    /* - */

    test.open( 'in' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      mapValsUnwrapping : 1,
      singleUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = [ [ '.' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = { 'Submodule/in' : '.' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '.' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected =
    {
      'Submodule' : { 'in' : '.' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';

    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ sout( '.' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = { 'Submodule/in' : sout( '.' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = sout( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ sout( '.' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected =
    {
      'Submodule' : { 'in' : sout( '.' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'in' );

    /* - */

    test.open( 'proto' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '../proto' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = { 'Submodule/proto' : '../proto' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = '../proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ '../proto' ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected =
    {
      'Submodule' : { 'proto' : '../proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'mapFlattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';

    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ pin( 'proto' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = { 'Submodule/proto' : pin( 'proto' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 1' );
    test.open( 'mapFlattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
      arrayFlattening : 0,
    });
    var expected = [ [ pin( 'proto' ) ] ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.openedModule.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      mapFlattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
      arrayFlattening : 0,
    });
    var expected =
    {
      'Submodule' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'mapFlattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'proto' );

    return null;
  })

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

pathsResolveOutFileOfExports.timeOut = 130000;

//

function pathsResolveComposite( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'composite-path' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( 'in', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'path::protoDir1';
    var resolved = module.openedModule.resolve( 'path::protoDir1' )
    var expected = pin( 'proto/dir' );
    test.identical( resolved, expected );

    test.case = 'path::protoDir2';
    var resolved = module.openedModule.resolve( 'path::protoDir2' )
    var expected = pin( 'protodir' );
    test.identical( resolved, expected );

    test.case = 'path::protoDir3';
    var resolved = module.openedModule.resolve( 'path::protoDir3' )
    var expected = pin( 'prefix/proto/dir/dir2' );
    test.identical( resolved, expected );

    test.case = 'path::protoDir4';
    var resolved = module.openedModule.resolve( 'path::protoDir4' )
    var expected = pin( '../prefix/aprotobdirc/dir2' );
    test.identical( resolved, expected );

    test.case = 'path::protoDir4b';
    var resolved = module.openedModule.resolve( 'path::protoDir4b' )
    var expected = pin( '../prefix/aprotobdirc/dir2/proto' );
    test.identical( resolved, expected );

    test.case = 'path::protoMain';
    debugger;
    var resolved = module.openedModule.resolve( 'path::protoMain' );
    debugger;
    var expected = pin( 'proto/Main.s' );
    test.identical( resolved, expected );

    test.case = 'path::protoMain with options defaultResourceKind';
    var resolved = module.openedModule.resolve
    ({
      selector : 'path::protoMain',
      defaultResourceKind : 'path',
      prefixlessAction : 'default',
      pathResolving : 'in',
    })
    var expected = pin( 'proto/Main.s' );
    test.identical( resolved, expected );

    test.case = '{path::proto}/Main.s';
    var resolved = module.openedModule.resolve( '{path::proto}/Main.s' )
    var expected = pin( 'proto/Main.s' );
    test.identical( resolved, expected );

    test.case = '{path::proto}/Main.s with options defaultResourceKind';
    var resolved = module.openedModule.resolve
    ({
      selector : '{path::proto}/Main.s',
      defaultResourceKind : 'path',
      prefixlessAction : 'default',
      pathResolving : 'in',
    })
    var expected = pin( 'proto/Main.s' );
    test.identical( resolved, expected );

    return null;
  });

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

pathsResolveComposite.timeOut = 130000;

//

function pathsResolveComposite2( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'import-auto' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'module/Proto' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( 'in', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  // _.fileProvider.filesDelete( routinePath );
  // _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  //
  // var module = will.openerMake({ willfilesPath : modulePath });

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'path::export';
    var resolved = module.openedModule.resolve({ selector : 'path::export', pathResolving : 0 });
    var expected = '.module/Proto/proto';
    test.identical( resolved, expected );
    return null;
  });

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

pathsResolveComposite2.timeOut = 130000;

//

function pathsResolveArray( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'make' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'v1' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( '', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  module.openedModule.ready.then( ( arg ) =>
  {

    test.case = 'path::produced.js';
    var got = module.openedModule.pathResolve
    ({
      selector : 'path::produced.js',
      pathResolving : 'in',
      missingAction : 'undefine',
    });
    var expected = pin( 'file/Produced.js2' );
    test.identical( got, expected );

    test.case = 'path::temp';
    var got = module.openedModule.pathResolve
    ({
      selector : 'path::temp',
      pathResolving : 'in',
      missingAction : 'undefine',
    });
    var expected = pin
    ([
      'out/Produced.txt2',
      'out/Produced.js2',
      'file/Produced.txt2',
      'file/Produced.js2',
      'Produced.txt2',
      'Produced.js2'
    ]);
    test.identical( got, expected );

    return null;
  });

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

//

/*
  path::path::export cant be resolved
  so error should be throwen
  but as it's composite and deep
  bug could appear here
*/

function pathsResolveFailing( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'export-with-submodules' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( 'ab/' );
  let outPath = abs( 'out' );
  let will = new _.Will;
  let path = _.fileProvider.path;
  let ready = _.Consequence().take( null );
  let opener;

  function pin( filePath )
  {
    return abs( '', filePath );
  }

  function pout( filePath )
  {
    return abs( 'out', filePath );
  }

  /* - */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready.then( ( arg ) =>
  {

    test.case = 'path::entry.*=1: null';
    debugger;
    var got = module.openedModule.pathResolve
    ({
      selector : { 'path::entry.*=1' : null },
      missingAction : 'undefine',
      mapValsUnwrapping : 0,
      singleUnwrapping : 0,
    });
    var expected = { 'path::entry.*=1' : null };
    test.identical( got, expected );
    debugger;

    test.case = 'path::entry.*=1: null';
    var got = module.openedModule.pathResolve
    ({
      selector : { 'path::entry.*=1' : null },
      missingAction : 'undefine',
      mapValsUnwrapping : 1,
    });
    var expected = null;
    test.identical( got, expected );

    test.case = 'path::entry.*=1: null';
    var got = module.openedModule.pathResolve
    ({
      selector : { 'path::entry.*=1' : null },
      missingAction : 'undefine',
      prefixlessAction : 'resolved',
      pathResolving : 0,
      pathNativizing : 0,
      selectorIsPath : 1,
      mapValsUnwrapping : 0,
      singleUnwrapping : 0,
    });
    var expected = { 'path::entry.*=1' : null };
    test.identical( got, expected );

    test.case = 'path::proto';
    var got = module.openedModule.pathResolve
    ({
      selector : 'path::proto',
      pathResolving : 0,
      missingAction : 'undefine',
    });
    var expected = '../proto';
    test.identical( got, expected );

    test.case = 'path::export';
    test.shouldThrowErrorSync( () =>
    {
      var got = module.openedModule.pathResolve
      ({
        /* selector : 'path::export', */
        selector : 'path::*',
        pathResolving : 0,
        missingAction : 'throw',
        prefixlessAction : 'throw',
      });
    });

/*

  selector : '*::*',
  criterion : [ Map:Pure with 0 elements ],
  defaultResourceKind : null,
  prefixlessAction : 'throw',
  arrayWrapping : 1,
  pathUnwrapping : 0,
  pathResolving : 0,
  mapValsUnwrapping : 0,
  strictCriterion : 1,
  currentExcluding : 0,
  missingAction : 'throw',
  visited : [ Array with 0 elements ],
  currentThis : null,
  currentContext : [ wWillOpenedModule with 27 elements ],
  baseModule : [ wWillOpenedModule with 27 elements ],
  pathNativizing : 0,
  singleUnwrapping : 1,
  mapFlattening : 1,
  arrayFlattening : 1,
  preservingIteration : 0,
  hasPath : null,
  selectorIsPath : 0

*/

    return null;
  });

  ready.finally( ( err, arg ) =>
  {
    if( err )
    throw err;
    test.is( err === undefined );
    module.finit();
    return arg;
  });

  /* - */

  return ready;
}

//

function submodulesResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'submodules-local-repos' );
  let repoPath = _.path.join( self.tempDir, '_repo' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;

  /* - */

  ready
  .then( () =>
  {
  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesDelete( repoPath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesReflect({ reflectMap : { [ self.repoDirPath ] : repoPath } });
  _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  .then( () =>
  {
    test.open( 'not downloaded' );

    test.case = 'trivial';
    var submodule = module.openedModule.submodulesResolve({ selector : 'Tools' });
    test.is( submodule instanceof will.Submodule );

    test.is( !!submodule.opener );
    test.identical( submodule.name, 'Tools' );
    test.identical( submodule.opener.openedModule, null );
    test.identical( submodule.opener.willfilesPath, abs( '.module/Tools/out/wTools.out.will' ) );
    test.identical( submodule.opener.dirPath, abs( '.module/Tools/out/' ) );
    test.identical( submodule.opener.localPath, abs( '.module/Tools' ) );
    test.identical( submodule.opener.remotePath, _.uri.join( repoPath, 'git+hd://Tools?out=out/wTools.out.will#master' ) );

    test.is( !submodule.isDownloaded );
    test.is( !submodule.opener.isDownloaded );
    test.is( !submodule.opener.openedModule );

    test.close( 'not downloaded' );
    return null;
  })

  /* */

  .then( () =>
  {
    return module.openedModule.submodulesDownload();
  })

  .then( () =>
  {
    test.open( 'downloaded' );

    test.case = 'trivial';
    var submodule = module.openedModule.submodulesResolve({ selector : 'Tools' });
    test.is( submodule instanceof will.Submodule );
    test.is( submodule.isDownloaded );
    test.is( submodule.opener.isDownloaded );
    test.is( submodule.opener.openedModule.isDownloaded );
    test.is( !!submodule.opener );
    test.identical( submodule.name, 'Tools' );

    test.identical( submodule.opener.name, 'Tools' );
    test.identical( submodule.opener.aliasName, 'Tools' );
    test.identical( submodule.opener.fileName, 'wTools.out' );
    test.identical( submodule.opener.willfilesPath, abs( '.module/Tools/out/wTools.out.will.yml' ) );
    test.identical( submodule.opener.dirPath, abs( '.module/Tools/out/' ) );
    test.identical( submodule.opener.localPath, abs( '.module/Tools' ) );
    test.identical( submodule.opener.remotePath, _.uri.join( repoPath, 'git+hd://Tools?out=out/wTools.out.will#master' ) );

    test.identical( submodule.opener.openedModule.name, 'wTools' );
    test.identical( submodule.opener.openedModule.resourcesFormed, 9 );
    test.identical( submodule.opener.openedModule.subModulesFormed, 9 );
    test.identical( submodule.opener.openedModule.willfilesPath, abs( '.module/Tools/out/wTools.out.will.yml' ) );
    test.identical( submodule.opener.openedModule.dirPath, abs( '.module/Tools/out/' ) );
    test.identical( submodule.opener.openedModule.localPath, abs( '.module/Tools' ) );
    test.identical( submodule.opener.openedModule.remotePath, _.uri.join( repoPath, 'git+hd://Tools?out=out/wTools.out.will#master' ) );
    test.identical( submodule.opener.openedModule.currentRemotePath, _.uri.join( repoPath, 'git+hd://Tools?out=out/wTools.out.will#master' ) );

    test.case = 'mask, single module';
    var submodule = module.openedModule.submodulesResolve({ selector : 'T*' });
    test.is( submodule instanceof will.Submodule );
    test.identical( submodule.name, 'Tools' );

    test.case = 'mask, two modules';
    var submodules = module.openedModule.submodulesResolve({ selector : '*s*' });
    test.identical( submodules.length, 2 );
    test.is( submodules[ 0 ] instanceof will.Submodule );
    test.identical( submodules[ 0 ].name, 'Tools' );
    test.is( submodules[ 1 ] instanceof will.Submodule );
    test.identical( submodules[ 1 ].name, 'PathBasic' );

    test.close( 'downloaded' );
    return null;
  })

  /* */

  return ready;
}

submodulesResolve.timeOut = 300000;

//

function submodulesDeleteAndDownload( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'submodules-del-download' );
  let repoPath = _.path.join( self.tempDir, '_repo' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let modulePath = abs( './' );
  let submodulesPath = abs( '.module' );
  let outPath = abs( 'out' );
  let will = new _.Will;

  /* */

  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesDelete( repoPath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
    _.fileProvider.filesReflect({ reflectMap : { [ self.repoDirPath ] : repoPath } });
    _.fileProvider.filesDelete( outPath );
    opener = will.openerMake({ willfilesPath : modulePath });
    return opener.open();
  })

  ready
  .then( () =>
  {

    let builds = module.openedModule.buildsResolve({ name : 'build' });
    test.identical( builds.length, 1 );

    let build = builds[ 0 ];
    let con = build.perform();

    con.then( ( arg ) =>
    {
      var files = self.find( submodulesPath );
      test.is( _.arrayHas( files, './Tools' ) );
      test.is( _.arrayHas( files, './PathBasic' ) );
      test.gt( files.length, 280 );
      return arg;
    })

    con.then( () => build.perform() )

    con.then( ( arg ) =>
    {
      var files = self.find( submodulesPath );
      test.is( _.arrayHas( files, './Tools' ) );
      test.is( _.arrayHas( files, './PathBasic' ) );
      test.gt( files.length, 280 );
      return arg;
    })

    con.finally( ( err, arg ) =>
    {

      var exp = [ 'xxx' ];
      test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
      test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), exp );
      test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );

      // // test.identical( will.modulesArray.length, 3 );
      // var exp = [ 'xxx' ];
      // test.identical( rel( _.select( will.modulesArray, '*/commonPath' ) ), exp );
      // test.identical( _.mapKeys( will.moduleWithIdMap ).length, exp.length );
      // // test.identical( _.mapKeys( will.moduleWithIdMap ).length, 3 );
      // test.identical( _.mapKeys( will.moduleWithCommonPathMap ).length, 3 );

      var willfilesArray = abs([ 'super.ex.will.yml', 'super.im.will.yml', 'out/submodule.out.will.yml' ]);
      willfilesArray.push( abs([ '.im.will.yml', '.ex.will.yml' ]) );
      test.setsAreIdentical( _.select( will.willfilesArray, '*/filePath' ), willfilesArray );
      // test.identical( _.mapKeys( will.willfileWithPathMap ).length, 3 );
      test.identical( _.mapKeys( will.willfileWithCommonPathMap ), [] );
      test.identical( _.mapKeys( will.willfileWithFilePathPathMap ), [] );

      // var exp = [ 'xxx' ];
      // test.identical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
      // // test.identical( will.openersArray.length, 8 );
      // test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, 8 );

      var exp = [ 'xxx' ];
      test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), exp );
      test.identical( _.mapKeys( will.openerModuleWithIdMap ).length, exp.length );

      var expected = abs
      ([
        '.will.yml',
        '.module/Tools/out/wTools.out.will.yml',
        '.module/PathBasic/out/wPathBasic.out.will.yml',
        'npm:///wFiles',
        'npm:///wcloner',
        'npm:///wstringer',
        'npm:///wTesting',
        'hd://' + abs( '.module/Tools' ),
      ])
      var got = _.select( will.openersArray, '*/willfilesPath' )
      test.identical( got, expected );

      module.finit();

      test.description = 'no grabage left';
      test.setsAreIdentical( rel( _.select( will.modulesArray, '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.select( _.mapVals( will.moduleWithIdMap ), '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.moduleWithCommonPathMap ) ), [] );
      test.setsAreIdentical( rel( _.select( will.openersArray, '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.select( _.mapVals( will.openerModuleWithIdMap ), '*/commonPath' ) ), [] );
      test.setsAreIdentical( rel( _.arrayFlatten( _.select( will.willfilesArray, '*/filePath' ) ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.willfileWithCommonPathMap ) ), [] );
      test.setsAreIdentical( rel( _.mapKeys( will.willfileWithFilePathPathMap ) ), [] );
      test.setsAreIdentical( _.mapKeys( will.moduleWithNameMap ), [] );

      if( err )
      throw err;
      return arg;
    })

    return con;
  })

  /* - */

  return ready;
}

submodulesDeleteAndDownload.timeOut = 300000;

// --
// define class
// --

var Self =
{

  name : 'Tools/atop/WillInternals',
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,
  routineTimeOut : 60000,

  context :
  {
    tempDir : null,
    assetDirPath : null,
    abs_functor,
    rel_functor
  },

  tests :
  {

    preCloneRepos,

    buildSimple,
    openNamedFast, // xxx
    openNamedForming,
    openSkippingSubButAttachedWillfilesSkippingMainPeers,
    openSkippingSubButAttachedWillfiles,
    openAnon,
    openOutNamed,
    clone,

    exportSeveralExports,
    exportSuper,
    exportDefaultPath,
    exportInconsistent,
    exportCourrputedOutfileUnknownSection,
    exportCourruptedOutfileSyntax,
    exportCourrputedSubmoduleOutfileUnknownSection,
    exportCourrputedSubmoduleOutfileFormatVersion,

    resolve,
    resolveExport,
    reflectorResolve,
    reflectorInheritedResolve,
    superResolve,
    buildsResolve,
    pathsResolve,
    pathsResolveImportIn,
    pathsResolveOfSubmodules,
    pathsResolveOfSubmodulesAndOwn,
    pathsResolveOutFileOfExports,
    pathsResolveComposite,
    pathsResolveComposite2,
    pathsResolveArray,
    pathsResolveFailing,

    submodulesResolve,
    submodulesDeleteAndDownload,

  }

}

// --
// export
// --

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
