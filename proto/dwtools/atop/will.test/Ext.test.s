( function _WillExternals_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );;
  _.include( 'wAppBasic' );
  _.include( 'wFiles' );

  require( '../will/MainBase.s' );

}

/* Desirable :

- Test check line is short. Use variables to reach that.

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    var exp = [ 'disabled.out', '../', '../.module/Tools/', '../.module/Tools/out/wTools.out', '../.module/PathBasic/', '../.module/PathBasic/out/wPathBasic.out' ];
    var got = _.mapKeys( outfile.module );
    test.setsAreIdentical( got, exp );

- Name return of _.process.start "op".

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    return op;
  })

- Use routine assetFor to setup environment for a test routine.

function exportCourruptedSubmodulesDisabled( test )
{
  let self = this;
  let a = self.assetFor( test, 'corrupted-submodules-disabled' );
  let outPath = a.abs( 'super.out' );
  ...

*/

var _global = _global_;
var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = _.path.pathDirTempOpen( _.path.join( __dirname, '../..'  ), 'willbe' );
  self.suiteAssetsOriginalPath = _.path.join( __dirname, '_asset' );
  self.repoDirPath = _.path.join( self.suiteAssetsOriginalPath, '_repo' );
  self.willPath = _.path.nativize( _.Will.WillPathGet() );
  self.find = _.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withStem : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      recursive : 2,
      maskAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
      maskTransientAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
    },
  });

  self.findAll = _.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withStem : 1,
    withTransient : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
  });

  let reposDownload = require( './ReposDownload.s' );
  return reposDownload().then( () =>
  {
    _.assert( _.fileProvider.isDir( _.path.join( self.repoDirPath, 'Tools' ) ) );
    return null;
  })
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/willbe-' ) )
  _.path.pathDirTempClose( self.suiteTempPath );
}

//

function assetFor( test, name )
{
  let self = this;
  let a = Object.create( null );

  a.test = test;
  a.name = name;
  a.originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, name );
  a.originalAbs = self.abs_functor( a.originalAssetPath );
  a.originalRel = self.rel_functor( a.originalAssetPath );
  a.routinePath = _.path.join( self.suiteTempPath, test.name );
  a.abs = self.abs_functor( a.routinePath );
  a.rel = self.rel_functor( a.routinePath );
  a.will = new _.Will;
  a.fileProvider = _.fileProvider;
  a.path = _.fileProvider.path;
  a.ready = _.Consequence().take( null );

  a.reflect = function reflect()
  {
    _.fileProvider.filesDelete( a.routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ a.originalAssetPath ] : a.routinePath } });
  }

  a.shell = _.process.starter
  ({
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  a.start = _.process.starter
  ({
    execPath : self.willPath,
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'fork',
  })

  a.startNonThrowing = _.process.starter
  ({
    execPath : self.willPath,
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : a.ready,
    mode : 'fork',
  })

  _.assert( a.fileProvider.isDir( a.originalAssetPath ) );

  return a;
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
    if( filePath === null )
    return filePath;
    if( _.arrayIs( filePath ) || _.mapIs( filePath ) )
    {
      return _.filter( filePath, ( filePath ) => rel( filePath ) );
    }
    if( _.uri.isRelative( filePath ) && !_.uri.isRelative( routinePath ) )
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
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  // let execPath = _.path.nativize( _.path.join( _.path.normalize( __dirname ), '../will/Exec' ) );
  let ready = new _.Consequence().take( null )

  let reposDownload = require( './ReposDownload.s' );

  ready.then( () => reposDownload() )
  ready.then( () =>
  {
    test.is( _.fileProvider.isDir( _.path.join( self.repoDirPath, 'Tools' ) ) );
    return null;
  })

  return ready;
}

//

function singleModuleWithSpaceTrivial( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single with space' );
  let routinePath = _.path.join( self.suiteTempPath, test.name, 'single with space' );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : _.path.dir( routinePath ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  start({ execPath : '.with "single with space/" .resources.list' })

  .then( ( got ) =>
  {
    test.case = '.with "single with space/" .resources.list';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `name : 'single with space'` ) );
    test.is( _.strHas( got.output, `description : 'Module for testing'` ) );
    test.is( _.strHas( got.output, `version : '0.0.1'` ) );
    return null;
  })

  return ready;
}

singleModuleWithSpaceTrivial.timeOut = 200000;

// --
// tests
// --

function make( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'make' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, '.' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with v1 .build'
    _.fileProvider.filesDelete( _.fileProvider.path.join( filePath, 'out/Produced.js2' ) );
    _.fileProvider.filesDelete( _.fileProvider.path.join( filePath, 'out/Produced.txt2' ) );
    return null;
  })

  start({ execPath : '.with v1 .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .+ \/ build::shell1/ ) );
    test.is( _.strHas( got.output, `node ${ _.path.nativize( 'file/Produce.js' )}` ) );
    if( process.platform === 'win32' )
    {
      test.identical( _.strCount( got.output, 'out\\Produced.txt2' ), 1 );
      test.identical( _.strCount( got.output, 'out\\Produced.js2' ), 1 );
    }
    else
    {
      test.identical( _.strCount( got.output, 'out/Produced.txt2' ), 1 );
      test.identical( _.strCount( got.output, 'out/Produced.js2' ), 1 );
    }
    test.is( _.strHas( got.output, /Built .+ \/ build::shell1/ ) );

    var files = self.find( filePath );
    test.identical( files, [ '.', './v1.will.yml', './v2.will.yml', './file', './file/File.js', './file/File.test.js', './file/Produce.js', './file/Src1.txt', './file/Src2.txt', './out', './out/Produced.js2', './out/Produced.txt2', './out/shouldbe.txt' ] );
    return null;
  })

  start({ execPath : '.with v1 .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .+ \/ build::shell1/ ) );
    test.is( !_.strHas( got.output, 'node file/Produce.js' ) );
    if( process.platform === 'win32' )
    {
      test.identical( _.strCount( got.output, 'out\\Produced.txt2' ), 0 );
      test.identical( _.strCount( got.output, 'out\\Produced.js2' ), 0 );
    }
    else
    {
      test.identical( _.strCount( got.output, 'out/Produced.txt2' ), 0 );
      test.identical( _.strCount( got.output, 'out/Produced.js2' ), 0 );
    }
    test.is( _.strHas( got.output, /Built .+ \/ build::shell1/ ) );

    var files = self.find( filePath );
    test.identical( files, [ '.', './v1.will.yml', './v2.will.yml', './file', './file/File.js', './file/File.test.js', './file/Produce.js', './file/Src1.txt', './file/Src2.txt', './out', './out/Produced.js2', './out/Produced.txt2', './out/shouldbe.txt' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with v2 .build'
    _.fileProvider.filesDelete( _.fileProvider.path.join( filePath, 'out/Produced.js2' ) );
    _.fileProvider.filesDelete( _.fileProvider.path.join( filePath, 'out/Produced.txt2' ) );
    return null;
  })

  start({ execPath : '.with v2 .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .+ \/ build::shell1/ ) );
    test.is( _.strHas( got.output, `node ${ _.path.nativize( 'file/Produce.js' )}` ) );
    if( process.platform === 'win32' )
    {
      test.identical( _.strCount( got.output, 'out\\Produced.txt2' ), 1 );
      test.identical( _.strCount( got.output, 'out\\Produced.js2' ), 1 );
    }
    else
    {
      test.identical( _.strCount( got.output, 'out/Produced.txt2' ), 1 );
      test.identical( _.strCount( got.output, 'out/Produced.js2' ), 1 );
    }
    test.is( _.strHas( got.output, /Built .+ \/ build::shell1/ ) );

    var files = self.find( filePath );
    test.identical( files, [ '.', './v1.will.yml', './v2.will.yml', './file', './file/File.js', './file/File.test.js', './file/Produce.js', './file/Src1.txt', './file/Src2.txt', './out', './out/Produced.js2', './out/Produced.txt2', './out/shouldbe.txt' ] );
    return null;
  })

  start({ execPath : '.with v2 .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .+ \/ build::shell1/ ) );
    test.is( !_.strHas( got.output, 'node file/Produce.js' ) );
    if( process.platform === 'win32' )
    {
      test.identical( _.strCount( got.output, 'out\\Produced.txt2' ), 0 );
      test.identical( _.strCount( got.output, 'out\\Produced.js2' ), 0 );
    }
    else
    {
      test.identical( _.strCount( got.output, 'out/Produced.txt2' ), 0 );
      test.identical( _.strCount( got.output, 'out/Produced.js2' ), 0 );
    }
    test.is( _.strHas( got.output, /Built .+ \/ build::shell1/ ) );

    var files = self.find( filePath );
    test.identical( files, [ '.', './v1.will.yml', './v2.will.yml', './file', './file/File.js', './file/File.test.js', './file/Produce.js', './file/Src1.txt', './file/Src2.txt', './out', './out/Produced.js2', './out/Produced.txt2', './out/shouldbe.txt' ] );
    return null;
  })

  /* - */

  return ready;
}

//

/*
Test transpilation of JS files.
*/

function transpile( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'transpile' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build debug'
    _.fileProvider.filesDelete( outPath );
    return null;
  })
  start({ execPath : '.build debug' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/dir1', './debug/dir1/Text.txt', './debug/dir2', './debug/dir2/File.js', './debug/dir2/File.test.js', './debug/dir2/File1.debug.js', './debug/dir2/File2.debug.js', './debug/dir3.test', './debug/dir3.test/File.js', './debug/dir3.test/File.test.js' ] );
    _.fileProvider.isTerminal( _.path.join( outPath, 'debug/dir3.test/File.js' ) );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build compiled.debug'
    _.fileProvider.filesDelete( outPath );
    return null;
  })
  start({ execPath : '.build compiled.debug' })
  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './compiled.debug', './compiled.debug/Main.s', './tests.compiled.debug', './tests.compiled.debug/Tests.s' ] );
    _.fileProvider.isTerminal( _.path.join( outPath, 'compiled.debug/Main.s' ) );
    _.fileProvider.isTerminal( _.path.join( outPath, 'tests.compiled.debug/Tests.s' ) );

    var read = _.fileProvider.fileRead( _.path.join( outPath, 'compiled.debug/Main.s' ) );
    test.is( !_.strHas( read, 'dir2/-Ecluded.js' ) );
    test.is( _.strHas( read, 'dir2/File.js' ) );
    test.is( !_.strHas( read, 'dir2/File.test.js' ) );
    test.is( _.strHas( read, 'dir2/File1.debug.js' ) );
    test.is( !_.strHas( read, 'dir2/File1.release.js' ) );
    test.is( _.strHas( read, 'dir2/File2.debug.js' ) );
    test.is( !_.strHas( read, 'dir2/File2.release.js' ) );

    var read = _.fileProvider.fileRead( _.path.join( outPath, 'tests.compiled.debug/Tests.s' ) );
    test.is( !_.strHas( read, 'dir2/-Ecluded.js' ) );
    test.is( !_.strHas( read, 'dir2/File.js' ) );
    test.is( _.strHas( read, 'dir2/File.test.js' ) );
    test.is( !_.strHas( read, 'dir2/File1.debug.js' ) );
    test.is( !_.strHas( read, 'dir2/File1.release.js' ) );
    test.is( !_.strHas( read, 'dir2/File2.debug.js' ) );
    test.is( !_.strHas( read, 'dir2/File2.release.js' ) );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build raw.release'
    _.fileProvider.filesDelete( outPath );
    return null;
  })
  start({ execPath : '.build raw.release' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './raw.release', './raw.release/dir1', './raw.release/dir1/Text.txt', './raw.release/dir2', './raw.release/dir2/File.js', './raw.release/dir2/File.test.js', './raw.release/dir2/File1.release.js', './raw.release/dir2/File2.release.js', './raw.release/dir3.test', './raw.release/dir3.test/File.js', './raw.release/dir3.test/File.test.js' ] );
    _.fileProvider.isTerminal( _.path.join( outPath, './raw.release/dir3.test/File.test.js' ) );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build release';
    _.fileProvider.filesDelete( outPath );
    return null;
  })
  start({ execPath : '.build release' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './release', './release/Main.s', './tests.compiled.release', './tests.compiled.release/Tests.s' ] );
    _.fileProvider.isTerminal( _.path.join( outPath, './release/Main.s' ) );
    _.fileProvider.isTerminal( _.path.join( outPath, './tests.compiled.release/Tests.s' ) );

    var read = _.fileProvider.fileRead( _.path.join( outPath, './release/Main.s' ) );
    test.is( _.strHas( read, 'dir2/File.js' ) );
    test.is( !_.strHas( read, 'dir2/File1.debug.js' ) );
    test.is( _.strHas( read, 'dir2/File1.release.js' ) );
    test.is( !_.strHas( read, 'dir2/File2.debug.js' ) );
    test.is( _.strHas( read, 'dir2/File2.release.js' ) );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build all'
    _.fileProvider.filesDelete( outPath );
    return null;
  })
  start({ execPath : '.build all' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './compiled.debug', './compiled.debug/Main.s', './debug', './debug/dir1', './debug/dir1/Text.txt', './debug/dir2', './debug/dir2/File.js', './debug/dir2/File.test.js', './debug/dir2/File1.debug.js', './debug/dir2/File2.debug.js', './debug/dir3.test', './debug/dir3.test/File.js', './debug/dir3.test/File.test.js', './raw.release', './raw.release/dir1', './raw.release/dir1/Text.txt', './raw.release/dir2', './raw.release/dir2/File.js', './raw.release/dir2/File.test.js', './raw.release/dir2/File1.release.js', './raw.release/dir2/File2.release.js', './raw.release/dir3.test', './raw.release/dir3.test/File.js', './raw.release/dir3.test/File.test.js', './release', './release/Main.s', './tests.compiled.debug', './tests.compiled.debug/Tests.s', './tests.compiled.release', './tests.compiled.release/Tests.s' ] );
    return null;
  })

  /* - */

  return ready;
}

transpile.timeOut = 200000;

//

function moduleNewDotless( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new module::moduleNewDotless at' ), 1 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 1 );
    test.identical( _.strCount( got.output, 'already exists!' ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './some.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './some',
      './some/will.yml',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new ../dir1/dir2/some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new ../dir1/dir2/some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    var exp = [ '.', './dir2', './dir2/some', './dir2/some/will.yml' ]
    var files = self.find( routinePath + '/../dir1' );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with ../dir1/dir2/some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    _.fileProvider.filesDelete( routinePath + '/../dir1' );
    return null;
  })

  /* - */

  return ready;
}

moduleNewDotless.timeOut = 200000;

//

function moduleNewDotlessSingle( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-single-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    var exp = [ '.', './will.yml', './proto', './proto/File.debug.js', './proto/File.release.js', './sub', './sub/will.yml' ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new module::moduleNewDotlessSingle at' ), 1 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 1 );
    test.identical( _.strCount( got.output, 'already exists!' ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './some.will.yml',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './some',
      './some/will.yml',
      './sub',
      './sub/will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new ../dir1/dir2/some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new ../dir1/dir2/some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp = [ '.', './will.yml', './proto', './proto/File.debug.js', './proto/File.release.js', './sub', './sub/will.yml' ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    var exp = [ '.', './dir2', './dir2/some', './dir2/some/will.yml' ]
    var files = self.find( routinePath + '/../dir1' );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with ../dir1/dir2/some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    _.fileProvider.filesDelete( routinePath + '/../dir1' );
    return null;
  })

  /* - */

  return ready;
}

moduleNewDotlessSingle.timeOut = 200000;

//

function moduleNewNamed( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new super'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new super' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new module::super at' ), 1 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 1 );
    test.identical( _.strCount( got.output, 'already exists!' ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with some .module.new'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.with some .module.new' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './some.will.yml',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with some/ .module.new'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.with some/ .module.new' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
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
      './some',
      './some/will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with some .module.new some2'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.with some .module.new some2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
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
      './some',
      './some/some2.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some2 at' ), 1 );

    return null;
  })
  start({ execPath : '.with some/some2 .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some2'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::moduleNewNamed at' ), 1 );

    return null;
  })
  start({ execPath : '.with . .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'moduleNewNamed'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new super/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new super/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
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
      './super',
      './super/will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::super at' ), 1 );

    return null;
  })
  start({ execPath : '.with super/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'super'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './some.will.yml',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
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
      './some',
      './some/will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.module.new ../dir1/dir2/some/'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    _.fileProvider.filesDelete( _.path.join( routinePath, 'sub.out' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );
    return null;
  })
  start({ execPath : '.module.new ../dir1/dir2/some/' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var exp =
    [
      '.',
      './sub.ex.will.yml',
      './sub.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    var exp = [ '.', './dir2', './dir2/some', './dir2/some/will.yml' ]
    var files = self.find( routinePath + '/../dir1' );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, 'Cant make a new' ), 0 );
    test.identical( _.strCount( got.output, 'already exists!' ), 0 );
    test.identical( _.strCount( got.output, 'Create module::some at' ), 1 );

    return null;
  })
  start({ execPath : '.with ../dir1/dir2/some/ .about.list' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled error' ), 0 );
    test.identical( _.strCount( got.output, `name : 'some'` ), 1 );

    _.fileProvider.filesDelete( routinePath + '/../dir1' );
    return null;
  })

  /* - */

  return ready;
}

moduleNewNamed.timeOut = 200000;

//

function openWith( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'open' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './submodule.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with . .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with . .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './submodule.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc .export -- deleted doc.will.yml'
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.fileDelete( _.path.join( routinePath, 'doc.ex.will.yml' ) );
    _.fileProvider.fileDelete( _.path.join( routinePath, 'doc.im.will.yml' ) );
    return null;
  })

  start({ args : [ '.with doc .export' ], throwingExitCode : 0 })

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc. .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc. .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc/. .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc/. .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with do .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ args : [ '.with do .export' ], throwingExitCode : 0 })

  .then( ( got ) =>
  {
    test.ni( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'uncaught error' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with docx .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ args : [ '.with docx .export' ], throwingExitCode : 0 })

  .then( ( got ) =>
  {
    test.ni( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'uncaught error' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc/ .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc/ .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [ '.', './submodule.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc/ .export -- deleted doc/.will.yml'

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.fileDelete( _.path.join( routinePath, 'doc/.ex.will.yml' ) );
    _.fileProvider.fileDelete( _.path.join( routinePath, 'doc/.im.will.yml' ) );

    return null;
  })

  start({ execPath : '.clean' })
  start({ args : [ '.with doc/ .export' ], throwingExitCode : 0 })

  .then( ( got ) =>
  {
    test.ni( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'uncaught error' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc/doc .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc/doc .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with doc/doc. .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with doc/doc. .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );

    return null;
  })

  /* - */

  return ready;
}

openWith.timeOut = 300000;

//

function openEach( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'open' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.each . .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each . .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './submodule.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [] );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.each doc/ .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each doc/. .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc.out' ) );
    test.identical( files, [] );
    var files = self.find( _.path.join( routinePath, 'doc/out' ) );
    test.identical( files, [ '.', './submodule.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );
    var files = self.find( _.path.join( routinePath, 'doc/doc.out' ) );
    test.identical( files, [ '.', './super.out.will.yml', './debug', './debug/File.debug.js', './debug/File.release.js' ] );

    return null;
  })

  /* - */

  return ready;
}

openEach.timeOut = 300000;

//

function withMixed( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-mixed' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with module .build'
    return null;
  })

  start({ execPath : '.with module .build' })
  .then( ( got ) =>
  {
    test.is( got.exitCode !== 0 );
    test.is( _.strHas( got.output, 'No module sattisfy criteria.' ) );
    test.identical( _.strCount( got.output, 'uncaught error' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with . .build'
    return null;
  })

  start({ execPath : '.with . .export' })
  .then( ( got ) =>
  {
    test.is( got.exitCode === 0 );
    test.identical( _.strCount( got.output, /Exported .*module::submodules-mixed \/ build::proto.export.* in/ ), 1 );
    return null;
  })

  /* - */

  return ready;
}

withMixed.timeOut = 300000;

//

function eachMixed( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-git' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.each submodule::*/path::download .shell "git status"'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.build' })
  start({ execPath : '.each submodule::*/path::download .shell "git status"' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'git status' ) );
    /*
    test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) );
    // no such string on older git
    */
    test.identical( _.strCount( got.output, 'git status' ), 1 );
    test.identical( _.strCount( got.output, 'git "status"' ), 4 );
    test.identical( _.strCount( got.output, /nothing to commit, working .* clean/ ), 4 );

    test.is( _.strHas( got.output, /eachMixed\/\.module\/Tools\/out\/wTools\.out\.will\.yml[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/\.module\/Tools[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/\.module\/PathBasic[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/out\/UriBasic\.informal\.out\.will\.yml[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/out\/UriBasic[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/out\/Proto\.informal\.out\.will\.yml[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/out\/Proto\.informal\.out\.will\.yml[^d]/ ) );
    test.is( _.strHas( got.output, /eachMixed\/out\/Proto[^d]/ ) );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.each submodule:: .shell ls'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.build' })
  start({ execPath : '.each submodule:: .shell ls -al' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'ls -al' ), 1 );
    test.identical( _.strCount( got.output, 'ls "-al"' ), 4 );
    test.identical( _.strCount( got.output, 'Module at' ), 4 );

    test.identical( _.strCount( got.output, '.module/Tools/out/wTools.out.will.yml' ), 1 );
    test.identical( _.strCount( got.output, '.module/PathBasic/out/wPathBasic.out.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'out/UriBasic.informal.out.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'out/Proto.informal.out.will.yml' ), 1 );

    test.identical( _.strCount( got.output, '.module/Tools/out/wTools' ), 2 );
    test.identical( _.strCount( got.output, '.module/PathBasic/out/wPathBasic' ), 2 );
    test.identical( _.strCount( got.output, 'out/UriBasic.informal' ), 2 );
    test.identical( _.strCount( got.output, 'out/Proto.informal' ), 2 );

    return null;
  })

  /* - */

  return ready;
}

eachMixed.timeOut = 300000;

//

function withList( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ args : '.with . .resources.list about::name' })
  .finally( ( err, got ) =>
  {
    test.case = '.with . .resources.list about::name';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'withList/.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-' ), 1 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    return null;
  })

  /* - */

  start({ args : '.with . .resources.list about::description' })
  .finally( ( err, got ) =>
  {
    test.case = '.with . .resources.list about::description';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'withList/.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'Module for testing' ), 1 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    return null;
  })

  /* - */

  start({ args : '.with . .resources.list path::module.dir' })
  .finally( ( err, got ) =>
  {
    test.case = '.with . .resources.list path::module.dir';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'withList/.will.yml' ), 1 );
    test.identical( _.strCount( got.output, routinePath ), 2 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    return null;
  })

  /* - */

  return ready;
}

//

function eachList( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'each-list' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ args : '.clean' })

  /* - */

  start({ args : '.each . .resources.list about::name' })
  .finally( ( err, got ) =>
  {
    test.case = '.each . .resources.list about::name';
    test.is( !err );
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Module at' ), 6 );
    test.identical( _.strCount( got.output, 'module-' ), 6 );

    test.identical( _.strCount( got.output, 'eachList/.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-x' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/ab-named.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-ab-named' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/a.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-a' ), 2 );
    test.identical( _.strCount( got.output, 'eachList/b.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-b' ), 2 );
    test.identical( _.strCount( got.output, 'eachList/bc-named.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-bc-named' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/c.will.yml' ), 1 );
    test.identical( _.strCount( got.output, 'module-c' ), 1 );

    return null;
  })

  /* - */

  start({ args : '.imply v:1 ; .each . .resources.list about::name' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply v:1 ; .each . .resources.list about::name';
    test.is( !err );
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Module at' ), 0 );
    test.identical( _.strCount( got.output, 'module-' ), 6 );
    test.identical( _.strLinesCount( got.output ), 8 );

    test.identical( _.strCount( got.output, 'eachList/.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-x' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/a.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-a' ), 2 );
    test.identical( _.strCount( got.output, 'eachList/ab-named.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-ab-named' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/b.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-b' ), 2 );
    test.identical( _.strCount( got.output, 'eachList/bc-named.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-bc-named' ), 1 );
    test.identical( _.strCount( got.output, 'eachList/c.will.yml' ), 0 );
    test.identical( _.strCount( got.output, 'module-c' ), 1 );

    return null;
  })

  /* - */

  start({ args : '.imply v:1 ; .each . .resources.list path::module.common' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply v:1 ; .each . .resources.list path::module.common';
    test.is( !err );
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Module at' ), 0 );
    test.identical( _.strCount( got.output, routinePath ), 6 );
    test.identical( _.strLinesCount( got.output ), 8 );

    test.identical( _.strCount( got.output, routinePath + '/' ), 6 );
    test.identical( _.strCount( got.output, routinePath + '/a' ), 2 );
    test.identical( _.strCount( got.output, routinePath + '/ab-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/b' ), 2 );
    test.identical( _.strCount( got.output, routinePath + '/bc-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/c' ), 1 );

    return null;
  })

  /* - */

  start({ args : '.imply v:1 ; .each * .resources.list path::module.common' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply v:1 ; .each * .resources.list path::module.common';
    test.is( !err );
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Module at' ), 0 );
    test.identical( _.strCount( got.output, routinePath ), 6 );
    test.identical( _.strLinesCount( got.output ), 8 );

    test.identical( _.strCount( got.output, routinePath + '/' ), 6 );
    test.identical( _.strCount( got.output, routinePath + '/a' ), 2 );
    test.identical( _.strCount( got.output, routinePath + '/ab-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/b' ), 2 );
    test.identical( _.strCount( got.output, routinePath + '/bc-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/c' ), 1 );

    return null;
  })

  /* - */

  start({ args : '.imply v:1 ; .each */* .resources.list path::module.common' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply v:1 ; .each */* .resources.list path::module.common';
    test.is( !err );
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Module at' ), 0 );
    test.identical( _.strCount( got.output, routinePath ), 9 );
    test.identical( _.strLinesCount( got.output ), 11 );

    test.identical( _.strCount( got.output, routinePath + '/' ), 9 );
    test.identical( _.strCount( got.output, routinePath + '/a' ), 5 );
    test.identical( _.strCount( got.output, routinePath + '/ab-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/b' ), 2 );
    test.identical( _.strCount( got.output, routinePath + '/bc-named' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/c' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/aabc' ), 1 );
    test.identical( _.strCount( got.output, routinePath + '/ab' ), 3 );
    test.identical( _.strCount( got.output, routinePath + '/abac' ), 1 );

    return null;
  })

  /* - */

  return ready;
}

eachList.timeOut = 300000;

//

function eachBrokenIll( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'each-broken' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ args : '.imply v:1 ; .each */* .resources.list path::module.common' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply v:1 ; .each */* .resources.list path::module.common';
    test.is( !err );
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Failed to resolve' ), 0 );
    test.identical( _.strCount( got.output, 'eachBrokenIll/' ), 6 );
    test.identical( _.strCount( got.output, 'Failed to open willfile' ), 1 );
    return null;
  })

  /* - */

  return ready;
}

eachBrokenIll.description =
`
if one or several willfiles are broken .each should pass it and output error
`

//

/*
utility should not try to open non-willfiles
*/

function eachBrokenNon( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'open-non-willfile' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ args : '.each */* .paths.list' })
  .finally( ( err, got ) =>
  {
    test.case = '.each */* .paths.list';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Read 1 willfile' ), 1 );
    test.identical( _.strCount( got.output, 'Module at' ), 1 );
    test.identical( _.strCount( got.output, 'Paths' ), 1 );
    return null;
  })

  /* - */

  return ready;
}

//

/*
utility should handle properly illformed second command
tab should not be accumulated in the output
*/

function eachBrokenCommand( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules-few' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete({ filePath : outPath })

  /* - */

  start( `.each */* .resource.list path::module.common` )
  .finally( ( err, got ) =>
  {
    test.case = '.each */* .resource.list path::module.common';
    test.is( !err );
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Unknown command ".resource.list"' ), 1 );
    test.identical( _.strCount( got.output, 'Module at' ), 3 );
    test.identical( _.strCount( got.output, '      ' ), 0 );
    return null;
  })

  /* - */

  return ready;
} /* end of function eachBrokenCommand */

//

/*
  check internal stat of will
  several commands separated with ";"" should works
*/

function openExportClean( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'open' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete({ filePath : outPath })

  /* - */

  start( '".with . .export ; .clean"' )
  .then( ( got ) =>
  {
    test.case = '.with . .export ; .clean';
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Command .*\.with \. \.export ; \.clean.*/ ), 1 );
    test.identical( _.strCount( got.output, /Exported .*module::submodule \/ build::export.*/ ), 1 );
    test.identical( _.strCount( got.output, 'Clean deleted 5 file' ), 1 );

    var exp =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './doc.ex.will.yml',
      './doc.im.will.yml',
      './doc',
      './doc/.ex.will.yml',
      './doc/.im.will.yml',
      './doc/doc.ex.will.yml',
      './doc/doc.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js'
    ]
    var got = self.find( routinePath );
    test.identical( got, exp );

    return null;
  })

  /* - */

  return ready;
} /* end of function openExportClean */

// --
// reflect
// --

function reflectNothingFromSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-nothing-from-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outDebugPath = _.path.join( routinePath, 'out/debug' );
  let outPath = _.path.join( routinePath, 'out' );
  let outWillPath = _.path.join( routinePath, 'out/reflect-nothing-from-submodules.out.will.yml' );
  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete( outDebugPath );

  /* - */

  ready.then( () =>
  {
    test.case = '.export'
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  /*
    Module has unused reflector and step : "reflect.submodules"
    Throws error if none submodule is defined
  */

  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, /Exported module::reflect-nothing-from-submodules \/ build::proto.export with 2 file\(s\) in/ ) );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );
    var files = self.find( outPath );
    test.identical( files, [ '.', './reflect-nothing-from-submodules.out.will.yml', './debug', './debug/Single.s' ] );

    test.is( _.fileProvider.fileExists( outWillPath ) )
    var outfile = _.fileProvider.fileConfigRead( outWillPath );

    outfile = outfile.module[ 'reflect-nothing-from-submodules.out' ]

    var reflector = outfile.reflector[ 'exported.files.proto.export' ];
    var expectedFilePath =
    {
      '.' : '',
      'Single.s' : ''
    }
    test.identical( reflector.src.basePath, '.' );
    test.identical( reflector.src.prefixPath, 'path::exported.dir.proto.export' );
    test.identical( reflector.src.filePath, { 'path::exported.files.proto.export' : '' } );

    var expectedReflector =
    {
      "reflect.proto" :
      {
        "src" :
        {
          "filePath" : { "path::proto" : "path::out.*=1" }
        },
        'criterion' : { 'debug' : 1 },
        "mandatory" : 1,
        "inherit" : [ "predefined.*" ]
      },
      "reflect.submodules1" :
      {
        "dst" : { "basePath" : ".", "prefixPath" : "path::out.debug" },
        "criterion" : { "debug" : 1 },
        "mandatory" : 1,
        "inherit" :
        [
          "submodule::*/exported::*=1/reflector::exported.files*=1"
        ]
      },
      "reflect.submodules2" :
      {
        "src" :
        {
          "filePath" : { "submodule::*/exported::*=1/path::exported.dir*=1" : "path::out.*=1" },
          "prefixPath" : ''
        },
        "dst" : { "prefixPath" : '' },
        "criterion" : { "debug" : 1 },
        "mandatory" : 1,
        "inherit" : [ "predefined.*" ]
      },
      "exported.proto.export" :
      {
        "src" :
        {
          "filePath" : { "**" : "" },
          "prefixPath" : "../proto"
        },
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "mandatory" : 1
      },
      "exported.files.proto.export" :
      {
        "src" : { "filePath" : { 'path::exported.files.proto.export' : '' }, "basePath" : ".", "prefixPath" : "path::exported.dir.proto.export", 'recursive' : 0 },
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "recursive" : 0,
        "mandatory" : 1
      }
    }
    test.identical( outfile.reflector, expectedReflector );
    // logger.log( _.toJson( outfile.reflector ) );

    return null;
  })

  return ready;
}

reflectNothingFromSubmodules.timeOut = 200000;

//

function reflectGetPath( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-get-path' );
  let repoPath = _.path.join( self.suiteTempPath, '_repo' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesDelete( repoPath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesReflect({ reflectMap : { [ self.repoDirPath ] : repoPath } });

  /* - */

  ready.then( () =>
  {
    test.case = '.build debug1'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug1' })
  .then( ( arg ) => validate( arg ) )

  /* - */

  ready.then( () =>
  {
    test.case = '.build debug2'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug2' })
  .then( ( arg ) => validate( arg ) )

  /* - */

  ready.then( () =>
  {
    test.case = '.build debug3'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug3' })
  .then( ( arg ) => validate( arg ) )

  /* - */

  return ready;

  function validate( arg )
  {
    test.identical( arg.exitCode, 0 );

    var expected =
    [
      '.',
      './debug',
      './debug/dwtools',
      './debug/dwtools/Tools.s',
      './debug/dwtools/abase',
      './debug/dwtools/abase/l3_proto',
      './debug/dwtools/abase/l3_proto/Include.s',
      './debug/dwtools/abase/l3_proto/l1',
      './debug/dwtools/abase/l3_proto/l1/Define.s',
      './debug/dwtools/abase/l3_proto/l1/Proto.s',
      './debug/dwtools/abase/l3_proto/l1/Workpiece.s',
      './debug/dwtools/abase/l3_proto/l3',
      './debug/dwtools/abase/l3_proto/l3/Accessor.s',
      './debug/dwtools/abase/l3_proto/l3/Class.s',
      './debug/dwtools/abase/l3_proto/l3/Complex.s',
      './debug/dwtools/abase/l3_proto/l3/Like.s',
      './debug/dwtools/abase/l3_proto.test',
      './debug/dwtools/abase/l3_proto.test/Class.test.s',
      './debug/dwtools/abase/l3_proto.test/Complex.test.s',
      './debug/dwtools/abase/l3_proto.test/Like.test.s',
      './debug/dwtools/abase/l3_proto.test/Proto.test.s'
    ]
    var files = self.find( outPath );
    test.gt( files.length, 13 );
    test.identical( files, expected );

    return null;
  }

}

reflectGetPath.timeOut = 200000;

//

function reflectSubdir( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-subdir' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'setup'
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })
  start({ execPath : '.each module .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'submodule.out.will.yml' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.build variant:1'
    _.fileProvider.filesDelete( outPath );
    return null;
  });
  start({ execPath : '.build variant:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './module/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './out/debug/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'submodule.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );

    var expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './submodule.out.will.yml',
      './module',
      './module/submodule.will.yml',
      './module/proto',
      './module/proto/File1.s',
      './module/proto/File2.s',
      './out',
      './out/debug',
      './out/debug/proto',
      './out/debug/proto/File1.s',
      './out/debug/proto/File2.s',
    ]
    var got = self.find( routinePath );
    test.identical( got, expected );

    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.build variant:2'
    _.fileProvider.filesDelete( outPath );
    return null;
  });
  start({ execPath : '.build variant:2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './module/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './out/debug/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'submodule.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );

    var expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './submodule.out.will.yml',
      './module',
      './module/submodule.will.yml',
      './module/proto',
      './module/proto/File1.s',
      './module/proto/File2.s',
      './out',
      './out/debug',
      './out/debug/proto',
      './out/debug/proto/File1.s',
      './out/debug/proto/File2.s',
    ]
    var got = self.find( routinePath );
    test.identical( got, expected );

    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.build variant:3'
    _.fileProvider.filesDelete( outPath );
    return null;
  });
  start({ execPath : '.build variant:3' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './module/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, './out/debug/proto/File1.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'submodule.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );

    var expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './submodule.out.will.yml',
      './module',
      './module/submodule.will.yml',
      './module/proto',
      './module/proto/File1.s',
      './module/proto/File2.s',
      './out',
      './out/debug',
      './out/debug/proto',
      './out/debug/proto/File1.s',
      './out/debug/proto/File2.s',
    ]
    var got = self.find( routinePath );
    test.identical( got, expected );

    return null;
  })

  return ready;
}

reflectSubdir.timeOut = 200000;

//

function reflectSubmodulesWithBase( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-submodules-with-base' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let submodule1OutFilePath = _.path.join( routinePath, 'submodule1.out.will.yml' );
  let submodule2OutFilePath = _.path.join( routinePath, 'submodule2.out.will.yml' );
  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  ready
  .then( () =>
  {
    test.case = 'setup'
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })

  /* */

  start({ execPath : '.each module .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.isTerminal( submodule1OutFilePath ) );
    test.is( _.fileProvider.isTerminal( submodule2OutFilePath ) );
    return got;
  })

  /* */

  ready.then( () =>
  {
    test.case = 'variant 0, src basePath : ../..'
    _.fileProvider.filesDelete( outPath )
    return null;
  });

  start({ execPath : '.build variant:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var expected =
    [
      '.',
      './debug',
      './debug/reflectSubmodulesWithBase',
      './debug/reflectSubmodulesWithBase/module',
      './debug/reflectSubmodulesWithBase/module/proto',
      './debug/reflectSubmodulesWithBase/module/proto/File1.s',
      './debug/reflectSubmodulesWithBase/module/proto/File2.s'
    ]
    var files = self.find( outPath );
    test.identical( files, expected );
    return got;
  })

  /* */

  ready.then( () =>
  {
    test.case = 'variant 1, src basePath : "{submodule::*/exported::*=1/path::exported.dir*=1}/../.."'
    _.fileProvider.filesDelete( outPath )
    return null;
  });

  start({ execPath : '.build variant:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var expected =
    [ '.', './debug', './debug/module', './debug/module/proto', './debug/module/proto/File1.s', './debug/module/proto/File2.s' ];
    // [ '.', './debug', './debug/proto', './debug/proto/File1.s', './debug/proto/File2.s' ]

    var files = self.find( outPath );
    test.identical( files, expected );
    return got;
  })

  /* */

  return ready;
}

reflectSubmodulesWithBase.timeOut = 150000;

//

function reflectComposite( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'composite-reflector' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:0'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:0' })
  .then( ( arg ) =>
  {
    var expected =
    [
      '.',
      './debug',
      './debug/dir1',
      './debug/dir1/for-git.txt',
      './debug/dir2',
      './debug/dir2/File.js',
      './debug/dir2/File.test.js',
      './debug/dir2/File1.debug.js',
      './debug/dir2/File2.debug.js'
    ]
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:1'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:1' })
  .then( ( arg ) =>
  {
    var expected =
    [
      '.',
      './debug',
      './debug/dir1',
      './debug/dir1/for-git.txt',
      './debug/dir2',
      './debug/dir2/File.js',
      './debug/dir2/File.test.js',
      './debug/dir2/File1.debug.js',
      './debug/dir2/File2.debug.js'
    ]
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:2'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:2' })
  .then( ( arg ) =>
  {
    var expected =
    [
      '.',
      './debug',
      './debug/dir1',
      './debug/dir1/for-git.txt',
      './debug/dir2',
      './debug/dir2/File.js',
      './debug/dir2/File.test.js',
      './debug/dir2/File1.debug.js',
      './debug/dir2/File2.debug.js'
    ]
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:3'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:3' })
  .then( ( arg ) =>
  {
    var expected =
    [
      '.',
      './debug',
      './debug/dir1',
      './debug/dir1/for-git.txt',
      './debug/dir2',
      './debug/dir2/File.js',
      './debug/dir2/File.test.js',
      './debug/dir2/File1.debug.js',
      './debug/dir2/File2.debug.js'
    ]
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:4'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:4' })
  .then( ( arg ) =>
  {
    var expected =
    [ '.', './debug', './debug/dir1', './debug/dir1/File.js', './debug/dir1/File.test.js', './debug/dir1/File1.debug.js', './debug/dir1/File2.debug.js' ]
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:5'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:5' })
  .then( ( arg ) =>
  {
    var expected = [ '.', './debug', './debug/dir1', './debug/dir1/File.js', './debug/dir1/File.test.js', './debug/dir1/File1.debug.js', './debug/dir1/File2.debug.js' ];
    var files = self.find( outPath );
    test.is( files.length > 5 );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:6'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:6' })
  .then( ( arg ) =>
  {
    var expected = [ '.', './debug', './debug/dir1', './debug/dir1/File.test.js' ];
    var files = self.find( outPath );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  /* */

  ready.then( () =>
  {
    test.case = '.build out* variant:7'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build out* variant:7' })
  .then( ( arg ) =>
  {
    var expected = [ '.', './debug', './debug/dir1', './debug/dir1/File.test.js' ]
    var files = self.find( outPath );
    test.identical( files, expected );
    test.identical( arg.exitCode, 0 );
    return null;
  })

  return ready;
}

reflectComposite.timeOut = 200000;

//

function reflectRemoteGit( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-remote-git' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )
  let local1Path = _.path.join( routinePath, 'PathBasic' );
  let local2Path = _.path.join( routinePath, 'Looker' );
  let local3Path = _.path.join( routinePath, 'Proto' );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready.then( () =>
  {
    test.case = '.build download.* variant:1'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:1' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:2'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:2' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:3'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:3' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:4'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:4' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:5'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:5' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:6'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:6' })
  .then( ( arg ) => validate1( arg ) )

  /* */

  .then( () =>
  {
    test.case = '.build download.* variant:7'
    _.fileProvider.filesDelete( local1Path );
    return null;
  })

  start({ execPath : '.build download.* variant:7' })
  .then( ( arg ) => validate2( arg ) )

  /* */

  .then( () =>
  {
    _.fileProvider.filesDelete( local1Path );
    _.fileProvider.filesDelete( local2Path );
    _.fileProvider.filesDelete( local3Path );
    return null;
  })

  /* */

  return ready;

  /* */

  function validate1( arg )
  {
    test.identical( arg.exitCode, 0 );
    var files = self.find( local1Path );
    test.ge( files.length, 30 );
    return null;
  }

  /* */

  function validate2( arg )
  {
    test.identical( arg.exitCode, 0 );

    var files = self.find( local1Path );
    test.ge( files.length, 30 );
    var files = self.find( local2Path );
    test.ge( files.length, 30 );
    var files = self.find( local3Path );
    test.ge( files.length, 30 );

    return null;
  }

}

reflectRemoteGit.timeOut = 200000;

//

function reflectRemoteHttp( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-remote-http' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )
  let outPath = _.path.join( routinePath, 'out' );
  let localFilePath = _.path.join( routinePath, 'out/Tools.s' );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready.then( () =>
  {
    test.case = '.build download'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  // debugger;
  // start({ execPath : '.builds.list' })
  start({ execPath : '.build download' })
  .then( ( arg ) =>
  {
    debugger;
    test.is( _.fileProvider.isTerminal( localFilePath ) );
    test.gt( _.fileProvider.fileSize( localFilePath ), 200 );
    return null;
  })

  return ready;
}

reflectRemoteHttp.timeOut = 200000;

//

function reflectWithOptions( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-with-options' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with mandatory .build variant1';
    return null;
  })

  start({ execPath : '.with mandatory .clean' })
  start({ execPath : '.with mandatory .build variant1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, / \+ reflector::reflect.proto1 reflected 3 file\(s\) .+\/reflectWithOptions\/.* : .*out\/debug.* <- .*proto.* in/ ) );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/File.js', './debug/File.test.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with mandatory .build variant2';
    return null;
  })

  start({ execPath : '.with mandatory .clean' })
  start({ execPath : '.with mandatory .build variant2' })
  .finally( ( err, got ) =>
  {
    test.is( !err );
    test.is( !!got.exitCode );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );
    test.is( _.strHas( got.output, /Failed .*module::.+ \/ step::reflect\.proto2/ ) );
    test.is( _.strHas( got.output, /No file found at .+/ ) );
    var files = self.find( outPath );
    test.identical( files, [] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with mandatory .build variant3';
    return null;
  })

  start({ execPath : '.with mandatory .clean' })
  start({ execPath : '.with mandatory .build variant3' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, / \+ reflector::reflect.proto3 reflected 0 file\(s\) .+\/reflectWithOptions\/.* : .*out\/debug.* <- .*proto.* in/ ) );
    var files = self.find( outPath );
    test.identical( files, [] );
    return null;
  })

  /* - */

  return ready;
}

//

function reflectWithSelectorInDstFilter( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-selecting-dst' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /*
    reflect.proto:
      filePath :
        path::proto : .
      dst :
        basePath : .
        prefixPath : path::out.*=1 #<-- doesn't work
        # prefixPath : "{path::out.*=1}" #<-- this works
      criterion :
        debug : [ 0,1 ]
  */

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build debug';
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/Single.s' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build release';
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build release' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './release', './release/Single.s' ] );
    return null;
  })

  /* - */

  return ready;
}

//

function reflectSubmodulesWithCriterion( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-with-criterion' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out/debug' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'setup'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with module/A .export' })
  start({ execPath : '.with module/B .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( routinePath );
    var expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './module',
      './module/A.out.will.yml',
      './module/A.will.yml',
      './module/B.out.will.yml',
      './module/B.will.yml',
      './module/A',
      './module/A/A.js',
      './module/B',
      './module/B/B.js'
    ]
    test.identical( files, expected );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'reflect only A'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build A' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    var expected = [ '.', './A.js' ];
    test.identical( files, expected );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'reflect only B'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build B' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    var expected = [ '.', './B.js' ];
    test.identical( files, expected );
    return null;
  })

  /* - */

  return ready;
}

//

function reflectSubmodulesWithPluralCriterionManualExport( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-submodules-with-plural-criterion' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'reflect informal submodule, manual export'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.each module .export' })

  // fails with error on first run

  start({ execPath : '.build variant1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    var expected = [ '.', './debug', './debug/File.s' ];
    test.identical( files, expected );
    return null;
  })

  return ready;
}

//

function reflectSubmodulesWithPluralCriterionEmbeddedExport( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-submodules-with-plural-criterion' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'reflect informal submodule exported using steps, two builds in a row'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  //first run works

  start({ execPath : '.build variant2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    var expected = [ '.', './debug', './debug/File.s' ];
    test.identical( files, expected );
    return null;
  })

  //second run fails

  start({ execPath : '.build variant2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    var expected = [ '.', './debug', './debug/File.s' ];
    test.identical( files, expected );
    return null;
  })

  return ready;
}

reflectSubmodulesWithPluralCriterionEmbeddedExport.timeOut = 300000;

//

function reflectNpmModules( test )
{
  let self = this;
  let a = self.assetFor( test, 'reflect-npm-modules' );

  /* - */

  a.ready
  
  .then( () =>
  {
    a.reflect();
    return null;
  })

  /* */
  
  a.start( '.build' )

  .then( ( got ) =>
  {
    test.case = 'reflect exported npm modules';
    
    test.identical( got.exitCode, 0 );

    var exp = 
    [
      '.',
      './out',
      './out/wUriBasic.out.will.yml',
      './proto',
      './proto/dwtools',
      './proto/dwtools/Tools.s',
      './proto/dwtools/abase',
      './proto/dwtools/abase/l3',
      './proto/dwtools/abase/l3/PathBasic.s',
      './proto/dwtools/abase/l4',
      './proto/dwtools/abase/l4/PathsBasic.s',
      './proto/dwtools/abase/l4/Uri.s',
      './proto/dwtools/abase/l5',
      './proto/dwtools/abase/l5/Uris.s'
    ]
    var files = self.find( a.abs( 'out' ) )
    test.identical( files, exp );

    return null;
  })
  
  /*  */

  return a.ready;
}

reflectNpmModules.timeOut = 150000;

//

/*
  moduleA exports:
  proto
    amid
      Tools.s

  moduleB exports:
    proto
      amid

  proto/amid of moduleB doesn't exist on hard drive, but its listed in out file

  main module reflects files of these modules, when assert fails
*/

function relfectSubmodulesWithNotExistingFile( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-reflect-with-not-existing' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  // let execPath = _.path.nativize( _.path.join( _.path.normalize( __dirname ), '../will/Exec' ) );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.assert( _.fileProvider.fileExists( abs( routinePath, 'module/moduleB/proto/amid/File.txt' ) ) );
  _.fileProvider.fileDelete( abs( routinePath, 'module/moduleB/proto/amid/File.txt' ) );

  /* - */

  ready
  .then( () =>
  {
    test.case = 'setup';
    return null;
  })

  start({ execPath : '.clean recursive:2' })
  start({ execPath : '.with module/moduleA/ .export' })
  start({ execPath : '.with module/moduleB/ .export' })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'reflect submodules'

    let exp =
    [
      '.',
      './.will.yml',
      './module',
      './module/moduleA.out.will.yml',
      './module/moduleB.out.will.yml',
      './module/moduleA',
      './module/moduleA/.will.yml',
      './module/moduleA/out',
      './module/moduleA/out/debug',
      './module/moduleA/out/debug/amid',
      './module/moduleA/out/debug/amid/Tools.s',
      './module/moduleA/proto',
      './module/moduleA/proto/amid',
      './module/moduleA/proto/amid/Tools.s',
      './module/moduleB',
      './module/moduleB/.will.yml',
      './module/moduleB/out',
      './module/moduleB/out/debug',
      './module/moduleB/out/debug/amid',
      './module/moduleB/proto',
      './module/moduleB/proto/amid'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    return null;
  })

  ready
  .finally( ( err, arg ) =>
  {
    test.is( err === undefined );
    if( err )
    logger.log( err );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    return arg || null;
  })

  start({ execPath : '.build' })

  ready
  .finally( ( err, arg ) =>
  {
    test.is( _.errIs( err ) );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    logger.log( err );
    if( err )
    throw err;
    return arg;
  })

  return test.shouldThrowErrorAsync( ready );
}

//

function reflectInherit( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-inherit' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.proto1'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.proto1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto1 reflected 6 file(s)' ) );
    test.is( _.strHas( got.output, /.*out\/debug1.* <- .*proto.*/ ) );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/debug1', './out/debug1/File.js', './out/debug1/File.s', './out/debug1/File.test.js', './out/debug1/some.test', './out/debug1/some.test/File2.js', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.proto2'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.proto2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto2 reflected 6 file(s)' ) );
    test.is( _.strHas( got.output, /.*out\/debug2.* <- .*proto.*/ ) );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/debug2', './out/debug2/File.js', './out/debug2/File.s', './out/debug2/File.test.js', './out/debug2/some.test', './out/debug2/some.test/File2.js', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.proto3'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.proto3' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto3 reflected 6 file(s)' ) );
    test.is( _.strHas( got.output, /.*out\/debug1.* <- .*proto.*/ ) );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/debug1', './out/debug1/File.js', './out/debug1/File.s', './out/debug1/File.test.js', './out/debug1/some.test', './out/debug1/some.test/File2.js', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.proto4'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.proto4' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto4 reflected 6 file(s)' ) );
    test.is( _.strHas( got.output, /.*out\/debug2.* <- .*proto.*/ ) );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/debug2', './out/debug2/File.js', './out/debug2/File.s', './out/debug2/File.test.js', './out/debug2/some.test', './out/debug2/some.test/File2.js', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.proto5'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.proto5' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto5 reflected 6 file(s)' ) );
    test.is( _.strHas( got.output, /.*out\/debug2.* <- .*proto.*/ ) );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/debug2', './out/debug2/File.js', './out/debug2/File.s', './out/debug2/File.test.js', './out/debug2/some.test', './out/debug2/some.test/File2.js', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build not1'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build not1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, ' + reflector::reflect.not.test.only.js.v1 reflected 4 file(s)' ) );
    test.is( _.strHas( got.output, /.*out.* <- .*proto.*/ ) );
    var exp =
    [
      '.',
      './.will.yml',
      './out',
      './out/debug1',
      './out/debug1/File.js',
      './out/debug2',
      './out/debug2/File.js',
      './proto',
      './proto/File.js',
      './proto/File.s',
      './proto/File.test.js',
      './proto/some.test',
      './proto/some.test/File2.js'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.files1'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.files1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, / \+ reflector::reflect.files1 reflected 2 file\(s\) .*:.*out.*<-.*proto/ ), 1 );
    test.identical( _.strCount( got.output, /.*out.* <- .*proto.*/ ), 1 );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/File.js', './out/File.s', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.files2'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.files2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, / \+ reflector::reflect.files2 reflected 2 file\(s\) .*:.*out.*<-.*proto/ ), 1 );
    test.identical( _.strCount( got.output, /.*out.* <- .*proto.*/ ), 1 );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/File.js', './out/File.s', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build reflect.files3'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build reflect.files3' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, / \+ reflector::reflect\.files3 reflected 2 file\(s\) .*:.*out.*<-.*proto/ ), 1 );
    test.identical( _.strCount( got.output, /.*out.* <- .*proto.*/ ), 1 );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './.will.yml', './out', './out/File.js', './out/File.s', './proto', './proto/File.js', './proto/File.s', './proto/File.test.js', './proto/some.test', './proto/some.test/File2.js' ] );
    return null;
  })

  /* - */

  return ready;
}

reflectInherit.timeOut = 300000;

//

/*
  Check reflector inheritance from multiple ancestors.
  Check exporting single file with custom base.
  Check importing single file with custom base.
*/

function reflectInheritSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflect-inherit-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'setup'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.each module .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( routinePath );
    test.identical( files, [ '.', './a.will.yml', './b.will.yml', './c.will.yml', './submodule1.out.will.yml', './submodule2.out.will.yml', './submodule3.out.will.yml', './submodule4.out.will.yml', './module', './module/submodule1.will.yml', './module/submodule2.will.yml', './module/submodule3.will.yml', './module/submodule4.will.yml', './module/proto', './module/proto/File1.s', './module/proto/File2.s', './module/proto1', './module/proto1/File1.s', './module/proto2', './module/proto2/File2.s' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with a .build'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with a .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/File1.s', './debug/File2.s' ] );
    // var read = _.fileProvider.fileRead( _.path.join( outPath, 'debug' ) );
    // test.equivalent( read, 'console.log( \'File2.s\' );' );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with b .build'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with b .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/f1', './debug/f2' ] );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with c .build'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with c .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/File1.s', './debug/File2.s' ] );
    return null;
  })

  /* - */

  return ready;
}

//

function reflectComplexInherit( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with ab/ .build';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with a .export' })
  start({ execPath : '.with b .export' })
  start({ execPath : '.with ab/ .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ reflector::files.all reflected 21 file(s)' ) );
    var exp =
    [
      '.',
      './module-a.out.will.yml',
      './module-b.out.will.yml',
      './ab',
      './ab/files',
      './ab/files/a',
      './ab/files/a/File.js',
      './ab/files/b',
      './ab/files/b/-Excluded.js',
      './ab/files/b/File.js',
      './ab/files/b/File.test.js',
      './ab/files/b/File1.debug.js',
      './ab/files/b/File1.release.js',
      './ab/files/b/File2.debug.js',
      './ab/files/b/File2.release.js',
      './ab/files/dir3.test',
      './ab/files/dir3.test/File.js',
      './ab/files/dir3.test/File.test.js'
    ]
    var files = self.find( outPath );
    test.identical( files, exp );
    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with abac/ .build';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with a .export' })
  start({ execPath : '.with b .export' })
  start({ execPath : '.with c .export' })
  start({ execPath : '.with ab/ .export' })
  start({ execPath : '.with abac/ .build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ reflector::files.all reflected 24 file(s)' ) );
    var exp =
    [
      '.',
      './module-a.out.will.yml',
      './module-b.out.will.yml',
      './module-c.out.will.yml',
      './ab',
      './ab/module-ab.out.will.yml',
      './abac',
      './abac/files',
      './abac/files/a',
      './abac/files/a/File.js',
      './abac/files/b',
      './abac/files/b/-Excluded.js',
      './abac/files/b/File.js',
      './abac/files/b/File.test.js',
      './abac/files/b/File1.debug.js',
      './abac/files/b/File1.release.js',
      './abac/files/b/File2.debug.js',
      './abac/files/b/File2.release.js',
      './abac/files/c',
      './abac/files/c/File.js',
      './abac/files/dir3.test',
      './abac/files/dir3.test/File.js',
      './abac/files/dir3.test/File.test.js'
    ]
    var files = self.find( outPath );
    test.identical( files, exp );
    return null;
  })

  /* - */

  return ready;
} /* end of function reflectComplexInherit */

reflectComplexInherit.timeOut = 300000;

//

function reflectorMasks( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'reflector-masks' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );


  test.description = 'should handle correct files';

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.build copy.' })

  .then( ( got ) =>
  {
    test.case = 'mask directory';

    var files = self.find( outPath );
    test.identical( files, [ '.', './release', './release/proto.two' ] );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, new RegExp( `\\+ reflector::reflect.copy. reflected ${files.length-1} file\\(s\\) .* in .*` ) ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.build copy.debug' })

  .then( ( got ) =>
  {
    test.case = 'mask terminal';

    var files = self.find( outPath );
    test.identical( files, [ '.', './debug', './debug/build.txt.js', './debug/manual.md', './debug/package.json', './debug/tutorial.md' ] );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, new RegExp( `\\+ reflector::reflect.copy.debug reflected ${files.length -1} file\\(s\\) .* in .*` ) ) );

    return null;
  })

  /* - */

  return ready;
}

reflectorMasks.timeOut = 200000;

// --
// with do
// --

function withDoInfo( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'dos' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start( '.clean' )
  start( '.export' )
  .then( ( got ) =>
  {
    test.case = 'setup';
    _.fileProvider.fileAppend( _.path.join( routinePath, 'will.yml' ), '\n' );

    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/proto' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/dos.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathBasic' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathTools' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/Tools' ) ) );

    return null;
  })

  /* - */

  start( '.hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with . .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with * .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 12 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    test.identical( _.strCount( got.output, 'local :' ), 7 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.imply withOut:0 ; .with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.imply withOut:0 ; .with ** .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 9 );
    test.identical( _.strCount( got.output, '! Outdated' ), 0 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    test.identical( _.strCount( got.output, 'local :' ), 7 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.imply withIn:0 ; .with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.imply withIn:0 ; .with ** .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 3 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 4 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );

    return null;
  })

  /* - */

  return ready;

} /* end of function withDoInfo */

withDoInfo.timeOut = 300000;
withDoInfo.description =
`
- do execute js script
- filtering option withIn works
- filtering option withOut works
- only one attempt to open outdate outfile
- action info works properly
- message with time printed afterwards
`

//

function withDoStatus( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'dos' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let startWill = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })
  let start = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = 'setup';

    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    start({ execPath : 'git init', currentPath : _.path.join( routinePath, 'disabled' ) });

    return null;
  })

  /* - */

  startWill( '.clean' )
  startWill( '.export' )
  .then( ( got ) =>
  {
    test.case = 'setup';

    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/proto' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/dos.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathBasic' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathTools' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/Tools' ) ) );

    return null;
  })

  /* - */

  startWill( '.with ** .do .will/hook/Status.js' )
  .then( ( got ) =>
  {
    test.case = 'no changes';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 13 );
    test.identical( _.strCount( got.output, '! Outdated' ), 0 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    return null;
  })

  /* - */

  .then( ( got ) =>
  {
    test.case = 'changs';
    _.fileProvider.fileAppend( _.path.join( routinePath, '.module/Tools/README.md' ), '\n' );
    _.fileProvider.fileAppend( _.path.join( routinePath, '.module/PathTools/README.md' ), '\nx' );
    _.fileProvider.fileAppend( _.path.join( routinePath, '.module/PathTools/LICENSE' ), '\n' );
    return null;
  })

  startWill( '.with ** .do .will/hook/Status.js' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 13 );
    test.identical( _.strCount( got.output, '! Outdated' ), 0 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    test.identical( _.strCount( got.output, /module::\w+ at / ), 2 );
    test.identical( _.strCount( got.output, 'module at' ), 2 );

    test.identical( _.strCount( got.output, 'M ' ), 3 );
    // test.identical( _.strCount( got.output, 'no changes added to commit' ), 2 );
    return null;
  })

  /* - */

  return ready;
} /* end of function withDoStatus */

withDoStatus.timeOut = 300000;
withDoStatus.description =
`
- it.shell exposed for action
- it.shell has proper current path
- errorors are brief
`

//

function withDoCommentOut( test )
{
  let self = this;
  let a = self.assetFor( test, 'dos' );

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    var outfile = _.fileProvider.fileConfigRead( a.abs( 'execution_section/will.yml' ) );
    test.is( !!outfile.execution );
    return null;
  })
  a.start( '.with ** .do .will/hook/WillfCommentOut.js execution' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'Comment out "execution" in module::execution_section at' ), 1 );
    var outfile = _.fileProvider.fileConfigRead( a.abs( 'execution_section/will.yml' ) );
    test.is( !outfile.execution );
    return null;
  })

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    var outfile = _.fileProvider.fileConfigRead( a.abs( 'execution_section/will.yml' ) );
    test.is( !!outfile.execution );
    return null;
  })
  a.start( '.with ** .do .will/hook/WillfCommentOut.js execution dry:1' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'Comment out "execution" in module::execution_section at' ), 1 );
    var outfile = _.fileProvider.fileConfigRead( a.abs( 'execution_section/will.yml' ) );
    test.is( !!outfile.execution );
    return null;
  })

  /* - */

  return a.ready;
} /* end of function withDoCommentOut */

withDoCommentOut.timeOut = 300000;
withDoCommentOut.description =
`
- commenting out works
- arguments passing to action works
`

//

function hookCallInfo( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'dos' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start( '.clean' )
  start( '.export' )
  .then( ( got ) =>
  {
    test.case = 'setup';
    _.fileProvider.fileAppend( _.path.join( routinePath, 'will.yml' ), '\n' );

    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/proto' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'out/dos.out.will.yml' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathBasic' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/PathTools' ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module/Tools' ) ) );

    return null;
  })

  /* - */

  start( '.hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with . .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with * .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 10 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 1 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.with . .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 12 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    test.identical( _.strCount( got.output, 'local :' ), 7 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.imply withOut:0 ; .with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.imply withOut:0 ; .with ** .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 9 );
    test.identical( _.strCount( got.output, '! Outdated' ), 0 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 1 );
    test.identical( _.strCount( got.output, 'local :' ), 7 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );
    return null;
  })

  /* - */

  start( '.imply withIn:0 ; .with ** .hook.call info.js' )
  .then( ( got ) =>
  {
    test.case = '.imply withIn:0 ; .with ** .hook.call info.js';
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 3 );
    test.identical( _.strCount( got.output, '! Outdated' ), 1 );
    test.identical( _.strCount( got.output, 'Willfile should not have section' ), 0 );
    test.identical( _.strCount( got.output, 'local :' ), 4 );
    test.identical( _.strCount( got.output, 'Done hook::info.js in' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function hookCallInfo */

hookCallInfo.timeOut = 300000;
hookCallInfo.description =
`
- do execute js script
- filtering option withIn works
- filtering option withOut works
- only one attempt to open outdate outfile
- action info works properly
- message with time printed afterwards
`

//

function hookGitMake( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'dos' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  test.is( true );

  let config = _.fileProvider.fileConfigUserRead();
  let user = config.about.user;
  if( !config || !config.about || !config.about[ 'github.token' ] )
  return null;

  /* - */

  start({ execPath : '.module.new New2/' })

  .then( ( got ) =>
  {
    var exp = [ '.', './will.yml' ];
    var files = self.find( _.path.join( routinePath, 'New2' ) );
    test.identical( files, exp );

    return _.git.repositoryDelete
    ({
      remotePath : `https://github.com/${user}/New2`,
      token : config.about[ 'github.token' ],
    });
  })

  start({ execPath : '.with New2/ .hook.call GitMake v:3' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `Making repository for module::New2 at` ), 1 );
    test.identical( _.strCount( got.output, `localPath :` ), 1 );
    test.identical( _.strCount( got.output, `remotePath : https://github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `Making remote repository git+https:///github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `Making a new local repository at` ), 1 );
    test.identical( _.strCount( got.output, `git init .` ), 1 );
    test.identical( _.strCount( got.output, `git remote add origin https://github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `> ` ), 2 );

    var exp = [ '.', './will.yml' ];
    var files = self.find( _.path.join( routinePath, 'New2' ) );
    test.identical( files, exp );

    return null;
  })

  .then( ( got ) =>
  {
    debugger;
    return null;
  })

  /* - */

  return ready;

} /* end of function hookGitMake */

hookGitMake.timeOut = 300000;

//

function hookPrepare( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'dos' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  test.is( true );

  let config = _.fileProvider.fileConfigUserRead();
  let user = config.about.user;
  if( !config || !config.about || !config.about[ 'github.token' ] )
  return null;

  /* - */

  ready
  .then( ( got ) =>
  {
    var exp = [];
    var files = self.find( _.path.join( routinePath, 'New2' ) );
    test.identical( files, exp );
    return _.git.repositoryDelete
    ({
      remotePath : `https://github.com/${user}/New2`,
      token : config.about[ 'github.token' ],
    });
  })

  start({ execPath : '.with New2/ .module.new.with prepare v:3' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `Making repository for module::New2 at` ), 1 );
    test.identical( _.strCount( got.output, `localPath :` ), 1 );
    test.identical( _.strCount( got.output, `remotePath : https://github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `Making remote repository git+https:///github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `Making a new local repository at` ), 1 );
    test.identical( _.strCount( got.output, `git init .` ), 1 );
    test.identical( _.strCount( got.output, `git remote add origin https://github.com/${user}/New2.git` ), 1 );
    test.identical( _.strCount( got.output, `git push -u origin --all --follow-tags` ), 1 );
    test.identical( _.strCount( got.output, `> ` ), 10 );

    var exp =
    [
      '.',
      './-will.yml',
      './.ex.will.yml',
      './.gitattributes',
      './.gitignore',
      './.im.will.yml',
      './.travis.yml',
      './LICENSE',
      './README.md',
      './was.package.json',
      './proto',
      './proto/dwtools',
      './proto/dwtools/Tools.s',
      './proto/dwtools/abase',
      './proto/dwtools/amid',
      './proto/dwtools/atop',
      './sample',
      './sample/Sample.html',
      './sample/Sample.js'
    ]
    var files = self.find( _.path.join( routinePath, 'New2' ) );
    test.identical( files, exp );

    return null;
  })

  .then( ( got ) =>
  {
    debugger;
    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    var exp = [];
    var files = self.find( _.path.join( routinePath, 'New3/New4' ) );
    test.identical( files, exp );
    return _.git.repositoryDelete
    ({
      remotePath : `https://github.com/${user}/New4`,
      token : config.about[ 'github.token' ],
    });
  })

  start({ execPath : '.with New3/New4 .module.new.with prepare v:3' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `Making repository for module::New4 at` ), 1 );
    test.identical( _.strCount( got.output, `localPath :` ), 1 );
    test.identical( _.strCount( got.output, `remotePath : https://github.com/${user}/New4.git` ), 1 );
    test.identical( _.strCount( got.output, `Making remote repository git+https:///github.com/${user}/New4.git` ), 1 );
    test.identical( _.strCount( got.output, `Making a new local repository at` ), 1 );
    test.identical( _.strCount( got.output, `git init .` ), 1 );
    test.identical( _.strCount( got.output, `git remote add origin https://github.com/${user}/New4.git` ), 1 );
    test.identical( _.strCount( got.output, `git push -u origin --all --follow-tags` ), 1 );
    test.identical( _.strCount( got.output, `> ` ), 10 );

    var exp =
    [
      '.',
      './-New4.will.yml',
      './.ex.will.yml',
      './.gitattributes',
      './.gitignore',
      './.im.will.yml',
      './.travis.yml',
      './LICENSE',
      './README.md',
      './was.package.json',
      './proto',
      './proto/dwtools',
      './proto/dwtools/Tools.s',
      './proto/dwtools/abase',
      './proto/dwtools/amid',
      './proto/dwtools/atop',
      './sample',
      './sample/Sample.html',
      './sample/Sample.js'
    ]
    var files = self.find( _.path.join( routinePath, 'New3' ) );
    test.identical( files, exp );

    return null;
  })

  .then( ( got ) =>
  {
    debugger;
    return null;
  })

  /* - */

  return ready;

} /* end of function hookPrepare */

hookPrepare.timeOut = 300000;

//

function hookLink( test )
{
  let self = this;
  let a = self.assetFor( test, 'git-conflict' );

  let originalShell = _.process.starter
  ({
    currentPath : a.abs( 'original' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  let cloneShell = _.process.starter
  ({
    currentPath : a.abs( 'clone' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    _.fileProvider.filesReflect({ reflectMap : { [ _.path.join( self.suiteAssetsOriginalPath, 'dos/.will' ) ] : a.abs( '.will' ) } });
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), '\ncopy' );
    _.fileProvider.fileAppend( a.abs( 'original/f2.txt' ), '\ncopy' );
    return null;
  })

  originalShell( 'git init' );
  originalShell( 'git add --all' );
  originalShell( 'git commit -am first' );
  a.shell( `git clone original clone` );

  a.start( '.with original/ .call link beeping:0' )
  .then( ( got ) =>
  {
    test.case = '.with original/ .call link beeping:0';

    test.identical( _.strHas( got.output, '+ hardLink' ), true );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'original/f1.txt' ) ) );
    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    return null;
  })

  a.start( '.with clone/ .call link beeping:0' )
  .then( ( got ) =>
  {
    test.case = '.with clone/ .call link beeping:0';

    test.identical( _.strHas( got.output, '+ hardLink' ), true );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'original/f1.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    return null;
  })

  /* - */

  return a.ready;
} /* end of function hookLink */

hookLink.description =
`
- same files are hardlinked
- same files from different modules are not hardlinked
`

//

function hookGitPullConflict( test )
{
  let self = this;
  let a = self.assetFor( test, 'git-conflict' );

  let originalShell = _.process.starter
  ({
    currentPath : a.abs( 'original' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  let cloneShell = _.process.starter
  ({
    currentPath : a.abs( 'clone' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    _.fileProvider.filesReflect({ reflectMap : { [ _.path.join( self.suiteAssetsOriginalPath, 'dos/.will' ) ] : a.abs( '.will' ) } });
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'copy\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f2.txt' ), 'copy\n' );
    return null;
  })

  originalShell( 'git init' );
  originalShell( 'git add --all' );
  originalShell( 'git commit -am first' );
  a.shell( `git clone original clone` );

  a.start( '.with clone/ .call link beeping:0' )

  .then( ( got ) =>
  {
    test.description = 'hardlink';

    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    _.fileProvider.fileAppend( a.abs( 'clone/f1.txt' ), 'clone\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'original\n' );

    var exp =
`
original/f.txt
copy
original
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f2.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'clone/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead2 = _.fileProvider.fileRead( a.abs( 'clone/f2.txt' ) );
    test.equivalent( orignalRead2, exp );

    return null;
  })

  originalShell( 'git commit -am second' );

  a.startNonThrowing( '.with clone/ .call GitPull' )
  .then( ( got ) =>
  {
    test.description = 'has local changes';
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'has local changes' ), 1 );

    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    var exp =
`
original/f.txt
copy
original
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f2.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'clone/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead2 = _.fileProvider.fileRead( a.abs( 'clone/f2.txt' ) );
    test.equivalent( orignalRead2, exp );

    return null;
  })

  cloneShell( 'git commit -am second' );

  a.startNonThrowing( '.with clone/ .call GitPull' )
  .then( ( got ) =>
  {
    test.description = 'conflict';
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'has local changes' ), 0 );
    test.identical( _.strCount( got.output, 'CONFLICT (content): Merge conflict in f1.txt' ), 1 );
    test.identical( _.strCount( got.output, 'Restored 1 links' ), 1 );

    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    var exp =
`
original/f.txt
copy
original
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f2.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
<<<<<<< HEAD
clone
=======
original
>>>>>>>
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'clone/f1.txt' ) );
    orignalRead1 = orignalRead1.replace( />>>> .+/, '>>>>' );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
<<<<<<< HEAD
clone
=======
original
>>>>>>>
`
    var orignalRead2 = _.fileProvider.fileRead( a.abs( 'clone/f2.txt' ) );
    orignalRead2 = orignalRead2.replace( />>>> .+/, '>>>>' );
    test.equivalent( orignalRead2, exp );
    return null;
  })

  /* - */

  return a.ready;
} /* end of function hookGitPullConflict */

hookGitPullConflict.timeOut = 300000;
hookGitPullConflict.description =
`
- pull done
- conflict is not obstacle to relink files
- if conflict then application returns error code
`

//

function hookGitSyncColflict( test )
{
  let self = this;
  let a = self.assetFor( test, 'git-conflict' );

  let originalShell = _.process.starter
  ({
    currentPath : a.abs( 'original' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  let cloneShell = _.process.starter
  ({
    currentPath : a.abs( 'clone' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    _.fileProvider.filesReflect({ reflectMap : { [ _.path.join( self.suiteAssetsOriginalPath, 'dos/.will' ) ] : a.abs( '.will' ) } });
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'copy\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f2.txt' ), 'copy\n' );
    return null;
  })

  originalShell( 'git init' );
  originalShell( 'git add --all' );
  originalShell( 'git commit -am first' );
  a.shell( `git clone original clone` );

  a.start( '.with clone/ .call link beeping:0' )

  .then( ( got ) =>
  {
    test.description = 'hardlink';

    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    _.fileProvider.fileAppend( a.abs( 'clone/f1.txt' ), 'clone\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'original\n' );

    var exp =
`
original/f.txt
copy
original
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f2.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'clone/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
clone
`
    var orignalRead2 = _.fileProvider.fileRead( a.abs( 'clone/f2.txt' ) );
    test.equivalent( orignalRead2, exp );

    return null;
  })

  originalShell( 'git commit -am second' );

  a.startNonThrowing( '.with clone/ .call GitSync -am "second"' )
  .then( ( got ) =>
  {
    test.description = 'conflict';
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'has local changes' ), 0 );
    test.identical( _.strCount( got.output, 'CONFLICT (content): Merge conflict in f1.txt' ), 1 );
    test.identical( _.strCount( got.output, 'Restored 1 links' ), 1 );
    test.identical( _.strCount( got.output, '> git add' ), 1 );
    test.identical( _.strCount( got.output, '> git commit' ), 1 );
    test.identical( _.strCount( got.output, '> git push' ), 0 );

    test.is( !_.fileProvider.filesAreHardLinked( a.abs( 'original/f1.txt' ), a.abs( 'original/f2.txt' ) ) );
    test.is( _.fileProvider.filesAreHardLinked( a.abs( 'clone/f1.txt' ), a.abs( 'clone/f2.txt' ) ) );

    var exp =
`
original/f.txt
copy
original
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f1.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'original/f2.txt' ) );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
<<<<<<< HEAD
clone
=======
original
>>>>>>>
`
    var orignalRead1 = _.fileProvider.fileRead( a.abs( 'clone/f1.txt' ) );
    orignalRead1 = orignalRead1.replace( />>>> .+/, '>>>>' );
    test.equivalent( orignalRead1, exp );

    var exp =
`
original/f.txt
copy
<<<<<<< HEAD
clone
=======
original
>>>>>>>
`
    var orignalRead2 = _.fileProvider.fileRead( a.abs( 'clone/f2.txt' ) );
    orignalRead2 = orignalRead2.replace( />>>> .+/, '>>>>' );
    test.equivalent( orignalRead2, exp );
    return null;
  })

  /* - */

  return a.ready;
} /* end of function hookGitSyncColflict */

hookGitSyncColflict.timeOut = 300000;
hookGitSyncColflict.description =
`
- pull done
- conflict is not obstacle to relink files
- if conflict then application returns error code
`

//

function hookGitSyncArguments( test )
{
  let self = this;
  let a = self.assetFor( test, 'git-conflict' );

  let originalShell = _.process.starter
  ({
    currentPath : a.abs( 'original' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  let cloneShell = _.process.starter
  ({
    currentPath : a.abs( 'clone' ),
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'shell',
  })

  /* - */

  a.ready
  .then( ( got ) =>
  {
    a.reflect();
    _.fileProvider.filesReflect({ reflectMap : { [ _.path.join( self.suiteAssetsOriginalPath, 'dos/.will' ) ] : a.abs( '.will' ) } });
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'copy\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f2.txt' ), 'copy\n' );
    return null;
  })

  originalShell( 'git init' );
  originalShell( 'git add --all' );
  originalShell( 'git commit -am first' );
  a.shell( `git clone original clone` );

  a.ready.then( ( got ) =>
  {
    test.description = 'hardlink';
    _.fileProvider.fileAppend( a.abs( 'clone/f1.txt' ), 'clone\n' );
    _.fileProvider.fileAppend( a.abs( 'original/f1.txt' ), 'original\n' );
    return null;
  })

  originalShell( 'git commit -am second' );

  // _global_.debugger = 1;
  debugger;
  a.startNonThrowing( '.with clone/ .call GitSync -am "second commit"' ) /* xxx qqq : make it working */
  // a.startNonThrowing( '.with clone/ .call GitSync -am "second"' )
  .then( ( got ) =>
  {
    debugger;
    test.description = 'conflict';
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'has local changes' ), 0 );
    test.identical( _.strCount( got.output, 'CONFLICT (content): Merge conflict in f1.txt' ), 1 );
    test.identical( _.strCount( got.output, '> git add' ), 1 );
    test.identical( _.strCount( got.output, '> git commit' ), 1 );
    test.identical( _.strCount( got.output, '> git push' ), 0 );
    return null;
  })

  /* - */

  return a.ready;
} /* end of function hookGitSyncArguments */

hookGitSyncArguments.timeOut = 300000;
hookGitSyncArguments.description =
`
- quoted argument passed to git through willbe properly
`

//

function verbositySet( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.imply verbosity:3 ; .build' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply verbosity:3 ; .build';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( _.strHas( got.output, '.imply verbosity:3 ; .build' ) );
    test.is( _.strHas( got.output, / \. Opened .+\/\.im\.will\.yml/ ) );
    test.is( _.strHas( got.output, / \. Opened .+\/\.ex\.will\.yml/ ) );
    test.is( _.strHas( got.output, 'Failed to open module::submodules / relation::Tools' ) );
    test.is( _.strHas( got.output, 'Failed to open module::submodules / relation::PathBasic' ) );
    test.is( _.strHas( got.output, '. Read 2 willfile(s) in' ) );

    test.is( _.strHas( got.output, /Building .*module::submodules \/ build::debug\.raw.*/ ) );
    test.is( _.strHas( got.output, ' + 2/2 submodule(s) of module::submodules were downloaded' ) );
    test.is( _.strHas( got.output, ' + 0/2 submodule(s) of module::submodules were downloaded' ) );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 2 );
    test.is( _.strHas( got.output, / - .*step::delete.out.debug.* deleted 0 file\(s\)/ ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto.debug reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.submodules reflected' ) );
    test.is( _.strHas( got.output, /Built .*module::submodules \/ build::debug\.raw.*/ ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.imply verbosity:2 ; .build' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply verbosity:2 ; .build';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( _.strHas( got.output, '.imply verbosity:2 ; .build' ) );
    test.is( !_.strHas( got.output, / \. Opened .+\/\.im\.will\.yml/ ) );
    test.is( !_.strHas( got.output, / \. Opened .+\/\.ex\.will\.yml/ ) );
    test.is( !_.strHas( got.output, 'Failed to open relation::Tools' ) );
    test.is( !_.strHas( got.output, 'Failed to open relation::PathBasic' ) );
    test.is( _.strHas( got.output, '. Read 2 willfile(s) in' ) );

    test.is( _.strHas( got.output, /Building .*module::submodules \/ build::debug\.raw.*/ ) );
    test.is( _.strHas( got.output, ' + 2/2 submodule(s) of module::submodules were downloaded' ) );
    test.is( _.strHas( got.output, ' + 0/2 submodule(s) of module::submodules were downloaded' ) );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 2 );
    test.is( _.strHas( got.output, / - .*step::delete.out.debug.* deleted 0 file\(s\)/ ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto.debug reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.submodules reflected' ) );
    test.is( _.strHas( got.output, /Built .*module::submodules \/ build::debug\.raw.*/ ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.imply verbosity:1 ; .build' })
  .finally( ( err, got ) =>
  {
    test.case = '.imply verbosity:1 ; .build';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( _.strHas( got.output, '.imply verbosity:1 ; .build' ) );
    test.is( !_.strHas( got.output, / \. Opened .+\/\.im\.will\.yml/ ) );
    test.is( !_.strHas( got.output, / \. Opened .+\/\.ex\.will\.yml/ ) );
    test.is( !_.strHas( got.output, ' ! Failed to open relation::Tools' ) );
    test.is( !_.strHas( got.output, ' ! Failed to open relation::PathBasic' ) );
    test.is( !_.strHas( got.output, '. Read 2 willfile(s) in' ) );

    test.is( !_.strHas( got.output, /Building .*module::submodules \/ build::debug\.raw.*/ ) );
    test.is( !_.strHas( got.output, ' + 2/2 submodule(s) of module::submodules were downloaded' ) );
    test.is( !_.strHas( got.output, ' + 0/2 submodule(s) of module::submodules were downloaded' ) );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 0 );
    test.is( !_.strHas( got.output, ' - Deleted' ) );
    test.is( !_.strHas( got.output, ' + reflect.proto.debug reflected 2 file(s) ' ) );
    test.is( !_.strHas( got.output, ' + reflect.submodules reflected' ) );
    test.is( _.strHas( got.output, /Built .*module::submodules \/ build::debug\.raw.*/ ) );

    return null;
  })

  /* - */

  return ready;
}

verbositySet.timeOut = 300000;

//

/*
  Check verbosity field of step::files.delete.
  Check logging of step::files.delete.
*/

function verbosityStepDelete( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'verbosity-step-delete' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.build files.delete.vd';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.build files.delete.vd' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.vd.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.build files.delete.v0';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.build files.delete.v0' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v0.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, 'Deleted' ), 0 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.build files.delete.v1';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.build files.delete.v1' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v1.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.build files.delete.v3';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.build files.delete.v3' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 1 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 1 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 1 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v3.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.imply v:0 ; .build files.delete.vd';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.imply v:0 ; .build files.delete.vd' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.vd.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strLinesCount( got.output ), 2 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.imply v:8 ; .build files.delete.v0';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.imply v:8 ; .build files.delete.v0' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v0.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 0 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.imply v:9 ; .build files.delete.v0';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.imply v:9 ; .build files.delete.v0' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 1 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 1 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 1 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v0.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.imply v:1 ; .build files.delete.v3';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.imply v:1 ; .build files.delete.v3' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 0 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 0 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 0 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v3.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.imply v:2 ; .build files.delete.v3';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return null;
  })

  start({ execPath : '.imply v:2 ; .build files.delete.v3' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'proto' ) ) );

    test.identical( _.strCount( got.output, /3 at .*\/verbosityStepDelete\/proto\// ), 1 );
    test.identical( _.strCount( got.output, '2 at ./A' ), 1 );
    test.identical( _.strCount( got.output, '1 at ./B' ), 1 );
    test.identical( _.strCount( got.output, /- .*step::files.delete.v3.* deleted 3 file\(s\), at .*\/verbosityStepDelete\/proto\// ), 1 );

    var files = self.find( _.path.join( routinePath, 'proto' ) );
    test.identical( files, [ '.' ] );

    return null;
  })

  /* - */

  return ready;
}

verbosityStepDelete.timeOut = 200000;

//

/*
  Checks printing name of step before it execution
*/

function verbosityStepPrintName( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'verbosity-step-print-name' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  /* - */

  ready
  .then( ( arg ) =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return arg;
  })

  start({ execPath : '.imply v:4 ; .build' })

  .then( ( got ) =>
  {
    test.description = '.imply v:4 ; .build';

    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Building .*module::verbosityStepPrintName \/ build::debug/ ), 1 );
    test.identical( _.strCount( got.output, /: .*reflector::reflect.file.*/ ), 1 );
    test.identical( _.strCount( got.output, '+ reflector::reflect.file reflected 1 file(s)' ), 1 );
    test.identical( _.strCount( got.output, '/verbosityStepPrintName/ : ./out <- ./file in' ), 1 );
    test.identical( _.strCount( got.output, /.*>.*node -e "console.log\( 'shell.step' \)"/ ), 1 );
    test.identical( _.strCount( got.output, /at.* .*verbosityStepPrintName/ ), 3 );
    test.identical( _.strCount( got.output, 'shell.step' ), 2 );
    test.identical( _.strCount( got.output, /: .*step::delete.step.*/ ), 1 );
    test.identical( _.strCount( got.output, /1 at .*\/out/ ), 1 );
    test.identical( _.strCount( got.output, /1 at \./ ), 1 );
    test.identical( _.strCount( got.output, /- .*step::delete.step.* deleted 1 file\(s\), at .*verbosityStepPrintName\/out.*/ ), 1 );
    test.identical( _.strCount( got.output, /Built .*module::verbosityStepPrintName \/ build::debug.* in / ), 1 );

    return null;
  })

  /* - */

  ready
  .then( ( arg ) =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return arg;
  })

  start({ execPath : '.imply v:3 ; .build' })

  .then( ( got ) =>
  {
    test.description = '.imply v:3 ; .build';

    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Building .*module::verbosityStepPrintName \/ build::debug/ ), 1 );
    test.identical( _.strCount( got.output, /: .*reflector::reflect.file.*/ ), 0 );
    test.identical( _.strCount( got.output, '+ reflector::reflect.file reflected 1 file(s)' ), 1 );
    test.identical( _.strCount( got.output, '/verbosityStepPrintName/ : ./out <- ./file' ), 1 );
    test.identical( _.strCount( got.output, /.*>.*node -e "console.log\( 'shell.step' \)"/ ), 1 );
    test.identical( _.strCount( got.output, /at.* .*verbosityStepPrintName/ ), 1 );
    test.identical( _.strCount( got.output, 'shell.step' ), 2 );
    test.identical( _.strCount( got.output, /: .*step::delete.step.*/ ), 0 );
    test.identical( _.strCount( got.output, /1 at .*\/out/ ), 0 );
    test.identical( _.strCount( got.output, /1 at \./ ), 0 );
    test.identical( _.strCount( got.output, /- .*step::delete.step.* deleted 1 file\(s\), at .*verbosityStepPrintName\/out.*/ ), 1 );
    test.identical( _.strCount( got.output, /Built .*module::verbosityStepPrintName \/ build::debug.* in / ), 1 );

    return null;
  })

  /* - */

  ready
  .then( ( arg ) =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return arg;
  })

  start({ execPath : '.imply v:2 ; .build' })

  .then( ( got ) =>
  {
    test.description = '.imply v:2 ; .build';

    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Building .*module::verbosityStepPrintName \/ build::debug/ ), 1 );
    test.identical( _.strCount( got.output, /: .*reflector::reflect.file.*/ ), 0 );
    test.identical( _.strCount( got.output, ' + reflector::reflect.file reflected 1 file(s)' ), 1 );
    test.identical( _.strCount( got.output, '/verbosityStepPrintName/ : ./out <- ./file in' ), 1 );
    test.identical( _.strCount( got.output, /.*>.*node -e "console.log\( 'shell.step' \)"/ ), 1 );
    test.identical( _.strCount( got.output, /at.* .*verbosityStepPrintName/ ), 1 );
    test.identical( _.strCount( got.output, 'shell.step' ), 1 );
    test.identical( _.strCount( got.output, /: .*step::delete.step.*/ ), 0 );
    test.identical( _.strCount( got.output, /1 at .*\/out/ ), 0 );
    test.identical( _.strCount( got.output, /1 at \./ ), 0 );
    test.identical( _.strCount( got.output, /- .*step::delete.step.* deleted 1 file\(s\), at .*verbosityStepPrintName\/out.*/ ), 1 );
    test.identical( _.strCount( got.output, /Built .*module::verbosityStepPrintName \/ build::debug.* in / ), 1 );

    return null;
  })

  /* - */

  ready
  .then( ( arg ) =>
  {
    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    return arg;
  })

  start({ execPath : '.imply v:1 ; .build' })

  .then( ( got ) =>
  {
    test.description = '.imply v:1 ; .build';

    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Building .*module::verbosityStepPrintName \/ build::debug/ ), 0 );
    test.identical( _.strCount( got.output, /: .*reflector::reflect.file.*/ ), 0 );
    test.identical( _.strCount( got.output, ' + reflector::reflect.file.* reflected 1 file(s) .* : .*out.* <- .*file.* in ' ), 0 );
    test.identical( _.strCount( got.output, /.*>.*node -e "console.log\( 'shell.step' \)"/ ), 0 );
    test.identical( _.strCount( got.output, /at.* .*verbosityStepPrintName/ ), 0 );
    test.identical( _.strCount( got.output, 'shell.step' ), 0 );
    test.identical( _.strCount( got.output, /: .*step::delete.step.*/ ), 0 );
    test.identical( _.strCount( got.output, /1 at .*\/out/ ), 0 );
    test.identical( _.strCount( got.output, /1 at \./ ), 0 );
    test.identical( _.strCount( got.output, /- .*step::delete.step.* deleted 1 file\(s\), at .*verbosityStepPrintName\/out.*/ ), 0 );
    test.identical( _.strCount( got.output, /Built .*module::verbosityStepPrintName \/ build::debug.* in / ), 1 );

    return null;
  })

  /* - */

/*
  Building module::verbosity-step-print-name / build::debug
   : reflector::reflect.file
   + reflector::reflect.file reflected 1 file(s) /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/verbosity-step-print-name/ : out <- file in 0.290s
 > node -e "console.log( 'shell.step' )"
   at /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/verbosity-step-print-name
shell.step
   : step::delete.step
     1 at /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/verbosity-step-print-name/out
     1 at .
   - step::delete.step deleted 1 file(s), at /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/verbosity-step-print-name/out0.017s
  Built module::verbosity-step-print-name / build::debug in 0.643s
*/

  return ready;
} /* end of function verbosityStepPrintName */

//

function modulesTreeDotless( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-single-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( './' );
  let outSuperDirPath = abs( 'super.out' );
  let outSubDirPath = abs( 'sub.out' );
  let outSuperTerminalPath = abs( 'super.out/supermodule.out.will.yml' );
  let outSubTerminalPath = abs( 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  // _.fileProvider.filesDelete( outSuperDirPath );
  // _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.imply v:1 ; .modules.tree withLocalPath:1';
    return null;
  })

  start({ execPath : '.imply v:1 ; .modules.tree withLocalPath:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+-- module::' ), 2 );
    test.identical( _.strCount( got.output, 'modulesTreeDotless/' ), 2 );
    test.identical( _.strCount( got.output, 'modulesTreeDotless/sub' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.modules.tree withLocalPath:1'
    _.fileProvider.filesDelete( outSuperDirPath );
    _.fileProvider.filesDelete( outSubDirPath );
    return null;
  })

  start({ execPath : '.modules.tree withLocalPath:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+-- module::' ), 2 );
    test.identical( _.strCount( got.output, 'modulesTreeDotless/' ), 4 );
    test.identical( _.strCount( got.output, 'modulesTreeDotless/sub' ), 2 );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeDotless */

//

function modulesTreeLocal( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  // _.fileProvider.filesDelete( outSuperDirPath );
  // _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.imply v:1 ; .with */* .modules.tree';
    return null;
  })

  start({ execPath : '.imply v:1 ; .with */* .modules.tree' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '-- module::' ), 19 );

    let exp =
`
Command ".imply v:1 ; .with */* .modules.tree"
 +-- module::module-x
 |
 +-- module::module-ab-named
 | +-- module::module-a
 | +-- module::module-b
 |
 +-- module::module-bc-named
 | +-- module::module-b
 | +-- module::module-c
 |
 +-- module::module-aabc
 | +-- module::module-a
 | +-- module::module-ab
 | | +-- module::module-a
 | | +-- module::module-b
 | +-- module::module-c
 |
 +-- module::module-abac
   +-- module::module-ab
   | +-- module::module-a
   | +-- module::module-b
   +-- module::module-a
   +-- module::module-c
`

    test.equivalent( got.output, exp );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeLocal */

//

function modulesTreeHierarchyRemote( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( submodulesPath );

  /* - */

  start({ execPath : '.with * .modules.tree' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree';
    test.identical( got.exitCode, 0 );

    let exp =
`
 +-- module::z
   +-- module::a
   | +-- module::Tools
   | +-- module::PathTools
   | +-- module::a0
   |   +-- module::PathTools
   |   +-- module::PathBasic
   +-- module::b
   | +-- module::PathTools
   | +-- module::Proto
   +-- module::c
   | +-- module::a0
   | | +-- module::PathTools
   | | +-- module::PathBasic
   | +-- module::UriBasic
   +-- module::PathTools
`
    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  start({ execPath : '.with * .modules.tree withRemotePath:1' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree withRemotePath:1';
    test.identical( got.exitCode, 0 );

    let exp =
`
 +-- module::z
   +-- module::a
   | +-- module::Tools - path::remote:=git+https:///github.com/Wandalen/wTools.git/
   | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | +-- module::a0
   |   +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   |   +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   +-- module::b
   | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/out/wPathTools.out
   | +-- module::Proto - path::remote:=git+https:///github.com/Wandalen/wProto.git/
   +-- module::c
   | +-- module::a0
   | | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   | +-- module::UriBasic - path::remote:=git+https:///github.com/Wandalen/wUriBasic.git/out/wUriBasic.out
   +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
`
    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  start({ execPath : '.with * .modules.tree withLocalPath:1' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree withLocalPath:1';
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  start({ execPath : '.with ** .modules.tree' })

  .then( ( got ) =>
  {
    test.case = '.with ** .modules.tree';
    test.identical( got.exitCode, 0 );

    let exp =
`
 +-- module::z
   +-- module::a
   | +-- module::Tools
   | +-- module::PathTools
   | +-- module::a0
   |   +-- module::PathTools
   |   +-- module::PathBasic
   +-- module::b
   | +-- module::PathTools
   | +-- module::Proto
   +-- module::c
   | +-- module::a0
   | | +-- module::PathTools
   | | +-- module::PathBasic
   | +-- module::UriBasic
   +-- module::PathTools
`
    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  start({ execPath : '.with ** .modules.tree withRemotePath:1' })

  .then( ( got ) =>
  {
    test.case = '.with ** .modules.tree withRemotePath:1';
    test.identical( got.exitCode, 0 );

    let exp =
`
 +-- module::z
   +-- module::a
   | +-- module::Tools - path::remote:=git+https:///github.com/Wandalen/wTools.git/
   | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | +-- module::a0
   |   +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   |   +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   +-- module::b
   | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/out/wPathTools.out
   | +-- module::Proto - path::remote:=git+https:///github.com/Wandalen/wProto.git/
   +-- module::c
   | +-- module::a0
   | | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   | +-- module::UriBasic - path::remote:=git+https:///github.com/Wandalen/wUriBasic.git/out/wUriBasic.out
   +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
`
    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  start({ execPath : '.with ** .modules.tree withLocalPath:1' })

  .then( ( got ) =>
  {
    test.case = '.with ** .modules.tree withLocalPath:1';
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+-- module::' ), 16 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 5 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeHierarchyRemote */

modulesTreeHierarchyRemote.timeOut = 300000;

//

function modulesTreeHierarchyRemoteDownloaded( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( submodulesPath );

  /* - */

  start({ execPath : '.with * .submodules.clean recursive:2' })
  start({ execPath : '.with * .submodules.download recursive:2' })

  /* - */

  start({ execPath : '.with * .modules.tree withRemotePath:1' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree withRemotePath:1';
    test.identical( got.exitCode, 0 );

    let exp =
`
 +-- module::z
   +-- module::a
   | +-- module::wTools - path::remote:=git+https:///github.com/Wandalen/wTools.git/
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wCloner - path::remote:=npm:///wcloner
   | | +-- module::wStringer - path::remote:=npm:///wstringer
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | | +-- module::wSelector - path::remote:=npm:///wselector
   | | +-- module::wTools
   | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::wTools - path::remote:=npm:///wTools
   | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | +-- module::wPathTools
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::a0
   |   +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   |   | +-- module::wTools - path::remote:=npm:///wTools
   |   | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   |   | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   |   | +-- module::wPathTools
   |   | +-- module::wFiles - path::remote:=npm:///wFiles
   |   | +-- module::wTesting - path::remote:=npm:///wTesting
   |   +-- module::wPathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   |     +-- module::wTools - path::remote:=npm:///wTools
   |     +-- module::wFiles - path::remote:=npm:///wFiles
   |     +-- module::wTesting - path::remote:=npm:///wTesting
   +-- module::b
   | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::wTools - path::remote:=npm:///wTools
   | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | +-- module::wPathTools
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::wProto - path::remote:=git+https:///github.com/Wandalen/wProto.git/
   |   +-- module::wTools - path::remote:=npm:///wTools
   |   +-- module::Self
   |   +-- module::wEqualer - path::remote:=npm:///wequaler
   |   +-- module::wTesting - path::remote:=npm:///wTesting
   +-- module::c
   | +-- module::a0
   | | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | | +-- module::wTools - path::remote:=npm:///wTools
   | | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | | +-- module::wPathTools
   | | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | | +-- module::wTesting - path::remote:=npm:///wTesting
   | | +-- module::wPathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   | |   +-- module::wTools - path::remote:=npm:///wTools
   | |   +-- module::wFiles - path::remote:=npm:///wFiles
   | |   +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::wUriBasic - path::remote:=git+https:///github.com/Wandalen/wUriBasic.git/
   |   +-- module::wTools - path::remote:=npm:///wTools
   |   +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   |   +-- module::wUriBasic
   |   +-- module::wFiles - path::remote:=npm:///wFiles
   |   +-- module::wTesting - path::remote:=npm:///wTesting
   +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
     +-- module::wTools - path::remote:=npm:///wTools
     +-- module::wPathBasic - path::remote:=npm:///wpathbasic
     +-- module::wArraySorted - path::remote:=npm:///warraysorted
     +-- module::wPathTools
     +-- module::wFiles - path::remote:=npm:///wFiles
     +-- module::wTesting - path::remote:=npm:///wTesting
`

    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 67 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::wTools' ), 11 );
    test.identical( _.strCount( got.output, '+-- module::wPathTools' ), 10 );
    test.identical( _.strCount( got.output, '+-- module::wPathBasic' ), 8 );
    test.identical( _.strCount( got.output, '+-- module::wUriBasic' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::wProto' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeHierarchyRemoteDownloaded */

modulesTreeHierarchyRemoteDownloaded.timeOut = 300000;

//

/*
cls && local-will .with group1/group10/a0 .clean recursive:2 && local-will .with group1/group10/a0 .export && local-debug-will .with group1/a .export
*/

function modulesTreeHierarchyRemotePartiallyDownloaded( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( submodulesPath );

  /* - */

  start({ execPath : '.with group1/group10/a0 .export' })
  start({ execPath : '.with group1/a .export' })
  start({ execPath : '.with * .modules.tree withRemotePath:1' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree withRemotePath:1';
    test.identical( got.exitCode, 0 );

    let exp =
// `
//  +-- module::z
//    +-- module::a
//    | +-- module::Tools - path::remote:=git+https:///github.com/Wandalen/wTools.git/
//    | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
//    | +-- module::a0
//    |   +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
//    |   +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
//    +-- module::b
//    | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/out/wPathTools.out
//    | +-- module::Proto - path::remote:=git+https:///github.com/Wandalen/wProto.git/
//    +-- module::c
//    | +-- module::a0
//    | | +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
//    | | +-- module::PathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
//    | +-- module::UriBasic - path::remote:=git+https:///github.com/Wandalen/wUriBasic.git/out/wUriBasic.out
//    +-- module::PathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
// `
`
 +-- module::z
   +-- module::a
   | +-- module::wTools - path::remote:=git+https:///github.com/Wandalen/wTools.git/
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wCloner - path::remote:=npm:///wcloner
   | | +-- module::wStringer - path::remote:=npm:///wstringer
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | | +-- module::wSelector - path::remote:=npm:///wselector
   | | +-- module::wTools
   | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::wTools - path::remote:=npm:///wTools
   | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | +-- module::wPathTools
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::a0
   |   +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   |   | +-- module::wTools - path::remote:=npm:///wTools
   |   | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   |   | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   |   | +-- module::wPathTools
   |   | +-- module::wFiles - path::remote:=npm:///wFiles
   |   | +-- module::wTesting - path::remote:=npm:///wTesting
   |   +-- module::wPathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   |     +-- module::wTools - path::remote:=npm:///wTools
   |     +-- module::wFiles - path::remote:=npm:///wFiles
   |     +-- module::wTesting - path::remote:=npm:///wTesting
   +-- module::b
   | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | +-- module::wTools - path::remote:=npm:///wTools
   | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | +-- module::wPathTools
   | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::Proto - path::remote:=git+https:///github.com/Wandalen/wProto.git/
   +-- module::c
   | +-- module::a0
   | | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
   | | | +-- module::wTools - path::remote:=npm:///wTools
   | | | +-- module::wPathBasic - path::remote:=npm:///wpathbasic
   | | | +-- module::wArraySorted - path::remote:=npm:///warraysorted
   | | | +-- module::wPathTools
   | | | +-- module::wFiles - path::remote:=npm:///wFiles
   | | | +-- module::wTesting - path::remote:=npm:///wTesting
   | | +-- module::wPathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git/
   | |   +-- module::wTools - path::remote:=npm:///wTools
   | |   +-- module::wFiles - path::remote:=npm:///wFiles
   | |   +-- module::wTesting - path::remote:=npm:///wTesting
   | +-- module::UriBasic - path::remote:=git+https:///github.com/Wandalen/wUriBasic.git/out/wUriBasic.out
   +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git/
     +-- module::wTools - path::remote:=npm:///wTools
     +-- module::wPathBasic - path::remote:=npm:///wpathbasic
     +-- module::wArraySorted - path::remote:=npm:///warraysorted
     +-- module::wPathTools
     +-- module::wFiles - path::remote:=npm:///wFiles
     +-- module::wTesting - path::remote:=npm:///wTesting
`

    test.identical( _.strCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 58 );
    test.identical( _.strCount( got.output, '+-- module::z' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::a' ), 3 );
    test.identical( _.strCount( got.output, '+-- module::a0' ), 2 );
    test.identical( _.strCount( got.output, '+-- module::b' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::c' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::wTools' ), 9 );
    test.identical( _.strCount( got.output, '+-- module::wPathTools' ), 10 );
    test.identical( _.strCount( got.output, '+-- module::wPathBasic' ), 7 );
    test.identical( _.strCount( got.output, '+-- module::wUriBasic' ), 0 ); /* xxx */
    test.identical( _.strCount( got.output, '+-- module::wProto' ), 0 );
    test.identical( _.strCount( got.output, '+-- module::Tools' ), 0 );
    test.identical( _.strCount( got.output, '+-- module::PathTools' ), 0 );
    test.identical( _.strCount( got.output, '+-- module::PathBasic' ), 0 );
    test.identical( _.strCount( got.output, '+-- module::UriBasic' ), 1 );
    test.identical( _.strCount( got.output, '+-- module::Proto' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeHierarchyRemotePartiallyDownloaded */

modulesTreeHierarchyRemotePartiallyDownloaded.timeOut = 300000;

//

function modulesTreeDisabledAndCorrupted( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'many-few' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.download' })
  start({ execPath : '.with ** .modules.tree withRemotePath:1' })

  .then( ( got ) =>
  {
    test.case = '.with * .modules.tree withRemotePath:1';
    test.identical( got.exitCode, 0 );

    let exp =

`+-- module::many
 | +-- module::wTools - path::remote:=git+https:///github.com/Wandalen/wTools.git#master
 | | +-- module::wFiles - path::remote:=npm:///wFiles
 | | +-- module::wCloner - path::remote:=npm:///wcloner
 | | +-- module::wStringer - path::remote:=npm:///wstringer
 | | +-- module::wTesting - path::remote:=npm:///wTesting
 | | +-- module::wSelector - path::remote:=npm:///wselector
 | | +-- module::wTools
 | +-- module::wPathBasic - path::remote:=git+https:///github.com/Wandalen/wPathBasic.git#master
 | | +-- module::wTools - path::remote:=npm:///wTools
 | | +-- module::wFiles - path::remote:=npm:///wFiles
 | | +-- module::wTesting - path::remote:=npm:///wTesting
 | +-- module::wPathTools - path::remote:=git+https:///github.com/Wandalen/wPathTools.git#master
 |   +-- module::wTools - path::remote:=npm:///wTools
 |   +-- module::wPathBasic - path::remote:=npm:///wpathbasic
 |   +-- module::wArraySorted - path::remote:=npm:///warraysorted
 |   +-- module::wPathTools
 |   +-- module::wFiles - path::remote:=npm:///wFiles
 |   +-- module::wTesting - path::remote:=npm:///wTesting
 |
 +-- module::corrupted`

    test.identical( _.strStripCount( got.output, exp ), 1 );
    test.identical( _.strCount( got.output, '+-- module::' ), 20 );

    return null;
  })

  /* - */

  return ready;
} /* end of function modulesTreeDisabledAndCorrupted */

modulesTreeDisabledAndCorrupted.timeOut = 300000;

//

function help( test )
{
  let self = this;

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
    throwingExitCode : 0,
  })

  /* */

  ready
  .then( ( got ) =>
  {

    test.case = 'simple run without args'

    return null;
  })

  start( '' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 1 );
    test.is( got.output.length );
    test.identical( _.strCount( got.output, /.*.help.* - Get help/ ), 1 );
    return null;
  })

  /* */

  ready
  .then( ( got ) =>
  {

    test.case = 'simple run without args'

    return null;
  })

  start( '.' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 1 );
    test.is( got.output.length );
    test.identical( _.strCount( got.output, /.*.help.* - Get help/ ), 1 );
    return null;
  })

  /* */

  start({ execPath : '.help' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.ge( _.strLinesCount( op.output ), 24 );
    return op;
  })

  /* */

  start({ execPath : '.' })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.ge( _.strLinesCount( op.output ), 24 );
    return op;
  })

  /* */

  start({ args : [] })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.ge( _.strLinesCount( op.output ), 24 );
    return op;
  })

  return ready;
}

//

function listSingleModule( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ execPath : '.resources.list' })
  .then( ( got ) =>
  {
    test.case = 'list';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `name : 'single'` ) );
    test.is( _.strHas( got.output, `description : 'Module for testing'` ) );
    test.is( _.strHas( got.output, `version : '0.0.1'` ) );
    return null;
  })

  /* - */

  start({ execPath : '.about.list' })
  .then( ( got ) =>
  {
    test.case = '.about.list'

    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, `name : 'single'` ));
    test.is( _.strHas( got.output, `description : 'Module for testing'` ));
    test.is( _.strHas( got.output, `version : '0.0.1'` ));
    test.is( _.strHas( got.output, `enabled : 1` ));
    test.is( _.strHas( got.output, `interpreters :` ));
    test.is( _.strHas( got.output, `'nodejs >= 8.0.0'` ));
    test.is( _.strHas( got.output, `'chrome >= 60.0.0'` ));
    test.is( _.strHas( got.output, `'firefox >= 60.0.0'` ));
    test.is( _.strHas( got.output, `'nodejs >= 8.0.0'` ));
    test.is( _.strHas( got.output, `keywords :` ));
    test.is( _.strHas( got.output, `'wTools'` ));

    return null;
  })

  /* - */

  start({ execPath : '.paths.list' })
  .then( ( got ) =>
  {
    test.case = '.paths.list';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, `proto : proto` ) );
    test.is( _.strHas( got.output, `in : .` ) );
    test.is( _.strHas( got.output, `out : out` ) );
    test.is( _.strHas( got.output, `out.debug : out/debug` ) );
    test.is( _.strHas( got.output, `out.release : out/release` ) );

    return null;
  })

  /* - */

  start({ execPath : '.paths.list predefined:1' })
  .then( ( got ) =>
  {
    test.case = '.paths.list predefined:1';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, `module.willfiles :` ) );
    test.is( _.strHas( got.output, `module.peer.willfiles :` ) );
    test.is( _.strHas( got.output, `module.dir : /` ) );
    test.is( _.strHas( got.output, `module.common : /` ) );
    test.is( _.strHas( got.output, `local : /` ) );
    test.is( _.strHas( got.output, `will :` ) );
    test.is( !_.strHas( got.output, `proto : proto` ) );
    test.is( !_.strHas( got.output, `in : .` ) );
    test.is( !_.strHas( got.output, `out : out` ) );
    test.is( !_.strHas( got.output, `out.debug : out/debug` ) );
    test.is( !_.strHas( got.output, `out.release : out/release` ) );
    test.identical( _.strCount( got.output, ':' ), 12 );

    return null;
  })

  /* - */

  start({ execPath : '.paths.list predefined:0' })
  .then( ( got ) =>
  {
    test.case = '.paths.list predefined:0';
    test.identical( got.exitCode, 0 );

    test.is( !_.strHas( got.output, `module.willfiles :` ) );
    test.is( !_.strHas( got.output, `module.peer.willfiles :` ) );
    test.is( !_.strHas( got.output, `module.dir : .` ) );
    test.is( !_.strHas( got.output, `module.common : ./` ) );
    test.is( !_.strHas( got.output, `local : .` ) );
    test.is( !_.strHas( got.output, `will :` ) );
    test.is( _.strHas( got.output, `proto : proto` ) );
    test.is( _.strHas( got.output, `in : .` ) );
    test.is( _.strHas( got.output, `out : out` ) );
    test.is( _.strHas( got.output, `out.debug : out/debug` ) );
    test.is( _.strHas( got.output, `out.release : out/release` ) );
    test.identical( _.strCount( got.output, ':' ), 6 );

    return null;
  })

  /* - */

  start({ execPath : '.submodules.list' })
  .then( ( got ) =>
  {
    test.case = 'submodules list'
    test.identical( got.exitCode, 0 );
    test.is( got.output.length );
    return null;
  })

  /* - */

  start({ execPath : '.reflectors.list' })
  .then( ( got ) =>
  {
    test.case = 'reflectors.list'
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'reflector::reflect.proto.' ) );
    test.is( _.strHas( got.output, `path::proto : path::out.*=1` ) );
    // test.is( _.strHas( got.output, `. : .` ) );
    // test.is( _.strHas( got.output, `prefixPath : proto` ) );
    // test.is( _.strHas( got.output, `prefixPath : out/release` ) );

    test.is( _.strHas( got.output, `reflector::reflect.proto.debug` ) );
    test.is( _.strHas( got.output, `path::proto : path::out.*=1` ) );
    // test.is( _.strHas( got.output, `. : .` ) );
    // test.is( _.strHas( got.output, `prefixPath : proto` ) );
    // test.is( _.strHas( got.output, `prefixPath : out/debug` ) );

    return null;
  })

  /* - */

  start({ execPath : '.steps.list' })
  .then( ( got ) =>
  {
    test.case = 'steps.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'step::reflect.proto.' ))
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ))
    test.is( _.strHas( got.output, 'step::reflect.proto.raw' ))
    test.is( _.strHas( got.output, 'step::reflect.proto.debug.raw' ))
    test.is( _.strHas( got.output, 'step::export.proto' ))

    return null;
  })

  /* - */

  start({ execPath : '.builds.list' })
  .then( ( got ) =>
  {
    test.case = '.builds.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'build::debug.raw' ));
    test.is( _.strHas( got.output, 'build::debug.compiled' ));
    test.is( _.strHas( got.output, 'build::release.raw' ));
    test.is( _.strHas( got.output, 'build::release.compiled' ));
    test.is( _.strHas( got.output, 'build::all' ));

    return null;
  })

  /* - */

  start({ execPath : '.exports.list' })
  .then( ( got ) =>
  {
    test.case = '.exports.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'build::proto.export' ));
    test.is( _.strHas( got.output, 'steps : ' ));
    test.is( _.strHas( got.output, 'build::debug.raw' ));
    test.is( _.strHas( got.output, 'step::export.proto' ));

    return null;
  })

  /* - */ /* To test output by command with glob and criterion args*/

  start({ execPath : '.resources.list *a* predefined:0' })
  .then( ( got ) =>
  {
    test.case = 'resources list globs negative';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'path::out.release' ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.raw' ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug.raw' ) );
    test.is( _.strHas( got.output, 'build::debug.raw' ) );
    test.is( _.strHas( got.output, 'build::release.raw' ) );
    test.is( _.strHas( got.output, 'build::release.compiled' ) );
    test.is( _.strHas( got.output, 'build::all' ) );
    test.identical( _.strCount( got.output, '::' ), 21 );

    return null;
  })

  start({ execPath : '.resources.list *p* debug:1' })
  .then( ( got ) =>
  {
    test.case = 'resources list globs negative';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'reflector::predefined.debug.v1'  ) );
    test.is( !_.strHas( got.output, 'reflector::predefined.debug.v2'  ) );
    test.is( _.strHas( got.output, 'reflector::reflect.proto.debug' ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug.raw' ) );
    test.is( _.strHas( got.output, 'step::export.proto' ) );
    test.is( _.strHas( got.output, 'build::debug.compiled' ) );
    test.is( _.strHas( got.output, 'build::proto.export' ) );
    test.identical( _.strCount( got.output, '::' ), 22 );

    return null;
  })

  /* Glob using positive test */
  start({ execPath : '.resources.list *proto*' })
  .then( ( got ) =>
  {
    test.case = '.resources.list *proto*';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'reflector::reflect.proto.'  ) );
    // test.is( _.strHas( got.output, `. : .` ) );

    test.is( _.strHas( got.output, 'step::reflect.proto.'  ) );
    test.is( _.strHas( got.output, `files.reflect` ) );

    test.is( _.strHas( got.output, 'build::proto.export'  ) );
    test.is( _.strHas( got.output, `step::export.proto` ) );

    return null;
  })

  /* Glob and criterion using negative test */
  start({ execPath : '.resources.list *proto* debug:0' })
  .then( ( got ) =>
  {
    test.case = 'globs and criterions negative';
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, `out.debug : './out/debug'` ) );
    test.is( !_.strHas( got.output, `reflector::reflect.proto.debug` ) );
    test.is( !_.strHas( got.output, 'step::reflect.proto.debug'  ) );
    test.is( !_.strHas( got.output, 'build::debug.raw'  ) );

    return null;
  })

  /* Glob and criterion using positive test */
  start({ execPath : '.resources.list *proto* debug:0 predefined:0' })
  .then( ( got ) =>
  {
    test.case = 'globs and criterions positive';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'path::proto'  ) );

    test.is( _.strHas( got.output, 'reflector::reflect.proto.'  ) );
    // test.is( _.strHas( got.output, `. : .` ) );

    test.is( _.strHas( got.output, 'step::reflect.proto.'  ) );
    test.is( _.strHas( got.output, `files.reflect` ) );

    test.identical( _.strCount( got.output, '::' ), 12 );

    return null;
  })

  /* Glob and two criterions using negative test */
  start({ execPath : '.resources.list * debug:1 raw:0 predefined:0' })
  .then( ( got ) =>
  {
    test.case = '.resources.list * debug:1 raw:0 predefined:0';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, `path::out.debug` ) );
    test.is( _.strHas( got.output, `reflector::reflect.proto.debug` ) );
    test.is( _.strHas( got.output, `step::reflect.proto.debug` ) );
    test.is( _.strHas( got.output, `step::export.proto` ) );
    test.is( _.strHas( got.output, `build::debug.compiled` ) );
    test.is( _.strHas( got.output, `build::proto.export` ) );
    test.identical( _.strCount( got.output, '::' ), 20 );

    return null;
  })

  /* Glob and two criterion using positive test */
  start({ execPath : '.resources.list * debug:0 raw:1' })
  .then( ( got ) =>
  {
    test.case = '.resources.list * debug:0 raw:1';
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'step::reflect.proto.raw'  ) );
    test.is( _.strHas( got.output, 'build::release.raw'  ) );
    test.identical( _.strCount( got.output, '::' ), 7 );

    return null;
  })

  return ready;
}

listSingleModule.timeOut = 200000;

//

function listWithSubmodulesSimple( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  start({ execPath : '.resources.list' })

  .then( ( got ) =>
  {
    test.case = '.resources.list';
    debugger;
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `name : 'submodules'` ) );
    test.is( _.strHas( got.output, `description : 'Module for testing'` ) );
    test.is( _.strHas( got.output, `version : '0.0.1'` ) );
    return null;
  })

  return ready;
}

listWithSubmodulesSimple.timeOut = 200000;

//

function listWithSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ execPath : '.submodules.list' })

  .then( ( got ) =>
  {
    test.case = '.submodules.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'relation::Tools' ) );
    test.is( _.strHas( got.output, 'relation::PathBasic' ) );
    return null;
  })

  /* - */

  start({ execPath : '.reflectors.list' })

  .then( ( got ) =>
  {
    test.case = 'reflectors.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'reflector::reflect.proto.' ))
    test.is( _.strHas( got.output, `reflector::reflect.proto.debug` ))
    return null;
  })

  /* - */

  start({ execPath : '.steps.list' })

  .then( ( got ) =>
  {
    test.case = 'steps.list'
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'step::delete.out.debug' ))
    test.is( _.strHas( got.output, 'step::reflect.proto.' ))
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ))
    test.is( _.strHas( got.output, 'step::reflect.submodules' ))
    test.is( _.strHas( got.output, 'step::export.proto' ))

    return null;
  })

  /* - */

  start({ execPath : '.builds.list' })

  .then( ( got ) =>
  {
    test.case = '.builds.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'build::debug.raw' ));
    test.is( _.strHas( got.output, 'build::debug.compiled' ));
    test.is( _.strHas( got.output, 'build::release.raw' ));
    test.is( _.strHas( got.output, 'build::release.compiled' ));

    return null;
  })

  /* - */

  start({ execPath : '.exports.list' })

  .then( ( got ) =>
  {
    test.case = '.exports.list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'build::proto.export' ));
    test.is( _.strHas( got.output, 'steps : ' ));
    test.is( _.strHas( got.output, 'build::debug.raw' ));
    test.is( _.strHas( got.output, 'step::export.proto' ));

    return null;
  })

  /* - */

  start({ execPath : '.about.list' })

  .then( ( got ) =>
  {
    test.case = '.about.list'

    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, `name : 'submodules'` ));
    test.is( _.strHas( got.output, `description : 'Module for testing'` ));
    test.is( _.strHas( got.output, `version : '0.0.1'` ));
    test.is( _.strHas( got.output, `enabled : 1` ));
    test.is( _.strHas( got.output, `interpreters :` ));
    test.is( _.strHas( got.output, `'nodejs >= 8.0.0'` ));
    test.is( _.strHas( got.output, `'chrome >= 60.0.0'` ));
    test.is( _.strHas( got.output, `'firefox >= 60.0.0'` ));
    test.is( _.strHas( got.output, `'nodejs >= 8.0.0'` ));
    test.is( _.strHas( got.output, `keywords :` ));
    test.is( _.strHas( got.output, `'wTools'` ));

    return null;
  })

  // /* - */
  //
  // start({ execPath : '.execution.list' })
  //
  // .then( ( got ) =>
  // {
  //   test.case = '.execution.list'
  //   test.identical( got.exitCode, 0 );
  //   test.is( got.output.length );
  //   return null;
  // })

  return ready;
} /* end of function listWithSubmodules */

listWithSubmodules.timeOut = 200000;

//

function listSteps( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'spawn',
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready

  /* - */

  start({ execPath : '.steps.list' })
  .finally( ( err, got ) =>
  {
    test.case = '.steps.list';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( _.strHas( got.output, 'step::delete.out.debug' ) );
    test.is( _.strHas( got.output, /step::reflect\.proto\.[^d]/ ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ) );
    test.is( _.strHas( got.output, 'step::reflect.submodules' ) );
    test.is( _.strHas( got.output, 'step::export.proto' ) );

    return null;
  })

  /* - */

  start({ execPath : '.steps.list *' })
  .finally( ( err, got ) =>
  {
    test.case = '.steps.list';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( _.strHas( got.output, 'step::delete.out.debug' ) );
    test.is( _.strHas( got.output, /step::reflect\.proto\.[^d]/ ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ) );
    test.is( _.strHas( got.output, 'step::reflect.submodules' ) );
    test.is( _.strHas( got.output, 'step::export.proto' ) );

    return null;
  })

  /* - */

  start({ execPath : '.steps.list *proto*' })
  .finally( ( err, got ) =>
  {
    test.case = '.steps.list';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( !_.strHas( got.output, 'step::delete.out.debug' ) );
    test.is( _.strHas( got.output, /step::reflect\.proto\.[^d]/ ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ) );
    test.is( !_.strHas( got.output, 'step::reflect.submodules' ) );
    test.is( _.strHas( got.output, 'step::export.proto' ) );

    return null;
  })

  /* - */

  start({ execPath : '.steps.list *proto* debug:1' })
  .finally( ( err, got ) =>
  {
    test.case = '.steps.list';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.is( !_.strHas( got.output, 'step::delete.out.debug' ) );
    test.is( !_.strHas( got.output, /step::reflect\.proto\.[^d]/ ) );
    test.is( _.strHas( got.output, 'step::reflect.proto.debug' ) );
    test.is( !_.strHas( got.output, 'step::reflect.submodules' ) );
    test.is( _.strHas( got.output, 'step::export.proto' ) );

    return null;
  })

  /* - */

  return ready;
}

//

function clean( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath + '',
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start
  ({
    args : [ '.with NoTemp .build' ]
  })

  var files;
  ready
  .then( () =>
  {
    files = self.findAll( submodulesPath );
    test.gt( files.length, 300 );
    return files;
  })

  start({ execPath : '.with NoTemp .clean' })
  .then( ( got ) =>
  {
    test.case = '.clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted ' + files.length + ' file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* phantom problem ? */
    return null;
  })

  start({ execPath : '.with NoTemp .clean' })
  .then( ( got ) =>
  {
    test.case = '.with NoTemp .clean -- second';
    test.identical( got.exitCode, 0 );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    return null;
  })

  /* - */

  var files = [];
  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( outPath );
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.with NoBuild .clean' })
  .then( ( got ) =>
  {
    test.case = '.with NoBuild .clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted ' + 0 + ' file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    return null;
  })

  /* - */

  var files = [];
  ready
  .then( () =>
  {
    _.fileProvider.filesDelete( outPath );
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.with Build .build' })
  start({ execPath : '.with Vector .clean' })
  .then( ( got ) =>
  {
    test.case = '.with NoBuild .clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '- Clean deleted 2 file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );
    return null;
  })

  /* - */

  return ready;
}

clean.timeOut = 300000;

//

function cleanSingleModule( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null )

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  /* - */

  start({ execPath : [ '.build', '.clean' ] })

  .then( ( got ) =>
  {
    debugger;
    test.case = '.clean '
    test.identical( got[ 0 ].exitCode, 0 );
    test.identical( got[ 1 ].exitCode, 0 );
    test.is( _.strHas( got[ 1 ].output, 'Clean deleted 0 file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )
    return null;
  })

  /* - */

  start({ execPath : [ '.build', '.clean dry:1' ] })

  .then( ( got ) =>
  {
    test.case = '.clean dry:1'
    test.identical( got[ 0 ].exitCode, 0 );
    test.identical( got[ 1 ].exitCode, 0 );
    test.is( _.strHas( got[ 1 ].output, 'Clean will delete 0 file(s)' ) );
    return null;
  })

  /* - */

  return ready;
}

cleanSingleModule.timeOut = 200000;

//

function cleanBroken1( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-broken-1' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );
  let outDebugPath = _.path.join( routinePath, 'out/debug' );


  test.description = 'should handle currputed willfile properly';

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  ready

  /* - */

  .then( ( got ) =>
  {
    test.case = '.clean ';

    var files = self.find( submodulesPath );
    test.identical( files.length, 4 );

    return null;
  })

  /* - */

  start({ execPath : '.clean dry:1' })

  .then( ( got ) =>
  {
    test.case = '.clean dry:1';

    var files = self.find( submodulesPath );

    test.identical( files.length, 4 );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, String( files.length ) + ' at ' ) );
    test.is( _.strHas( got.output, 'Clean will delete ' + String( files.length ) + ' file(s)' ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })

  .then( ( got ) =>
  {
    test.case = '.clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* filesDelete issue? */
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );
    return null;
  })

  /* */

  start({ execPath : '.export' })
  .then( ( got ) =>
  {
    test.case = '.export';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );

    var files = self.find( outDebugPath ); debugger;
    test.gt( files.length, 9 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  });

  /* */

  start({ execPath : '.export' })
  .then( ( got ) =>
  {
    test.case = '.export';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );

    var files = self.find( outDebugPath );
    test.gt( files.length, 9 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    return null;
  })

  /* - */

  return ready;
}

cleanBroken1.timeOut = 200000;

//

function cleanBroken2( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-broken-2' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );
  let outDebugPath = _.path.join( routinePath, 'out/debug' );


  test.description = 'should handle currputed willfile properly';

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  ready

  /* - */

  .then( ( got ) =>
  {
    test.case = '.clean ';

    var files = self.find( submodulesPath );

    test.identical( files.length, 4 );

    return null;
  })

  /* - */

  start({ execPath : '.clean dry:1' })

  .then( ( got ) =>
  {
    test.case = '.clean dry:1';

    var files = self.find( submodulesPath );

    test.identical( files.length, 4 );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, String( files.length ) ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })

  .then( ( got ) =>
  {
    test.case = '.clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* filesDelete issue? */
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );
    return null;
  })

  /* */

  start({ execPath : '.export' })
  .then( ( got ) =>
  {
    test.case = '.export';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );

    var files = self.find( outDebugPath );
    test.gt( files.length, 9 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  });

  /* */

  start({ execPath : '.export', throwingExitCode : 0 })
  .then( ( got ) =>
  {
    test.case = '.export';

    test.will = 'update should throw error if submodule is not downloaded but download path exists';

    test.notIdentical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );
    test.is( _.strHas( got.output, `Module module::submodules / opener::PathBasic is downloaded, but it's not a git repository` ) );

    // var files = self.find( outDebugPath );
    // test.gt( files.length, 9 );

    // var files = _.fileProvider.dirRead( outPath );
    // test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    var files = self.find( outDebugPath );
    test.identical( files.length, 0 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, null );

    return null;
  })

  /* */

  ready
  .then( ( got ) =>
  {

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  });

  start({ execPath : '.submodules.versions.agree' })
  start({ execPath : '.export', throwingExitCode : 0 })
  .then( ( got ) =>
  {
    test.case = '.export agree1';
    test.will = 'update should not throw error because submodule was updated by agree';

    test.identical( got.exitCode, 0 );

    test.is( !_.strHas( got.output, /Module module::submodules \/ opener::PathBasic is not downloaded, but file at .*/ ) );
    test.is( _.strHas( got.output, '+ 0/1 submodule(s) of module::submodules were updated' ) );
    test.is( _.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );

    var files = self.find( outDebugPath );
    test.gt( files.length, 9 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    return null;
  })

  /* - */

  return ready;
}

cleanBroken2.timeOut = 200000;

//

function cleanBrokenSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean-broken-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready

  /* - */

  .then( ( got ) =>
  {
    test.case = 'setup';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    var files = self.find( submodulesPath );
    test.identical( files.length, 4 );
    var files = self.find( outPath );
    test.identical( files.length, 2 );

    return null;
  })

  /* - */

  start({ execPath : '.clean dry:1' })
  .then( ( got ) =>
  {
    test.case = '.clean dry:1';

    var files = self.find( submodulesPath );
    test.identical( files.length, 4 );
    var files = self.find( outPath );
    test.identical( files.length, 2 );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '/.module' ) );
    test.is( _.strHas( got.output, '/out' ) );

    return null;
  })

  /* - */

  start({ execPath : '.clean' })
  .then( ( got ) =>
  {
    test.case = '.clean';

    var files = self.find( submodulesPath );
    test.identical( files.length, 0 );
    var files = self.find( outPath );
    test.identical( files.length, 0 );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '6 file(s)' ) );

    return null;
  })

  /* - */

  return ready;
}

cleanBrokenSubmodules.timeOut = 200000;

//

function cleanHdBug( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-hd-bug' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .clean recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ '.', './z.will.yml', './group1', './group1/a.will.yml', './group1/group10', './group1/group10/a0.will.yml' ];
    var files = self.find( a.abs( '.' ) );
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, 'Clean deleted' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanHdBug */

//

function cleanNoBuild( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath + ' .with NoBuild',
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.clean' })
  .then( ( got ) =>
  {
    test.case = '.clean -- second';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted ' + 0 + ' file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* phantom problem ? */
    return null;
  })

  start({ execPath : '.clean' })
  .then( ( got ) =>
  {
    test.case = '.clean';
    test.identical( got.exitCode, 0 );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );
    return null;
  })

  /* - */

  start({ execPath : '.clean -- badarg' })
  .then( ( got ) =>
  {
    test.case = '.clean -- badarg';
    test.notIdentical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Clean deleted' ) );
    return null;
  })

  /* - */

  return ready;
}

cleanNoBuild.timeOut = 200000;

//

function cleanDry( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath + ' .with NoTemp',
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start
  ({
    args : [ '.submodules.update' ],
  })

  .then( ( got ) =>
  {
    test.is( _.strHas( got.output, '+ 2/2 submodule(s) of module::submodules were updated' ) );
    var files = self.find( submodulesPath );
    test.gt( files.length, 100 );
    return null;
  })

  start
  ({
    args : [ '.build' ],
  })
  .then( ( got ) =>
  {
    test.is( _.strHas( got.output, '+ 0/2 submodule(s) of module::submodules were downloaded in' ) );
    return got;
  })

  var wasFiles;

  start({ execPath : '.clean dry:1' })

  .then( ( got ) =>
  {
    test.case = '.clean dry:1';

    var files = self.findAll( outPath );
    test.gt( files.length, 20 );
    var files = wasFiles = self.findAll( submodulesPath );
    test.gt( files.length, 100 );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, String( files.length ) + ' at ' ) );
    test.is( _.strHas( got.output, 'Clean will delete ' + String( files.length ) + ' file(s)' ) );
    test.is( _.fileProvider.isDir( _.path.join( routinePath, '.module' ) ) ); /* phantom problem ? */
    test.is( _.fileProvider.isDir( _.path.join( routinePath, 'out' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );

    return null;
  })

  /* - */

  return ready;
}

cleanDry.timeOut = 300000;

//

function cleanSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath + ' .with NoTemp',
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* */

  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {
    test.case = '.submodules.update'
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'Tools' ) ) )
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'PathBasic' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )

    var files = self.find( _.path.join( submodulesPath, 'Tools' ) );
    test.is( files.length );

    var files = self.find( _.path.join( submodulesPath, 'PathBasic' ) );
    test.is( files.length );

    return null;
  })

  /* */

  var files;
  ready
  .then( () =>
  {
    files = self.findAll( submodulesPath );
    return null;
  })

  /* */

  start({ execPath : '.submodules.clean' })
  .then( ( got ) =>
  {
    test.case = '.submodules.clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `${files.length}` ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* phantom problem ? */
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) );
    return null;
  })

  /* - */

  return ready;
}

cleanSubmodules.timeOut = 300000;

//

function cleanMixed( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-mixed' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.clean';
    return null;
  })

  start({ execPath : '.build' })
  start({ execPath : '.clean' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '- Clean deleted' ) ); debugger;

    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'out' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) );

    var expected = [ '.', './Proto.informal.will.yml', './UriBasic.informal.will.yml' ];
    var files = self.find( _.path.join( routinePath, 'module' ) );
    test.identical( files, expected );

    return null;
  })

  /* - */

  return ready;
}

cleanMixed.timeOut = 200000;

//

function cleanWithInPath( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'clean-with-inpath' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  var hadFiles;
  ready
  .then( ( got ) =>
  {
    test.case = '.with module/Proto .clean';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    hadFiles = self.find( routinePath + '/out' ).length + self.find( routinePath + '/.module' ).length;

    return null;
  })


  start({ execPath : '.with module/Proto .clean' })

  .then( ( got ) =>
  {

    var expectedFiles =
    [
      '.',
      './module',
      './module/Proto.will.yml',
      './module/.module',
      './module/.module/ForGit.txt',
      './module/out',
      './module/out/ForGit.txt',
      './proto',
      './proto/WithSubmodules.s'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '+**' : 0 } });
    test.identical( files, expectedFiles );

    test.identical( got.exitCode, 0 ); debugger;
    test.identical( _.strCount( got.output, '- Clean deleted ' + hadFiles + ' file(s)' ), 1 );

    return null;
  })

  /* - */

  return ready;
}

cleanWithInPath.timeOut = 200000;

//

/*
  check there is no annoying information about lack of remote submodules of submodules
*/

function cleanRecursive( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export first'
    return null;
  })

  start( '.with ** .clean' )
  start( '.with group1/group10/a0 .export' )
  start( '.with group1/a .export' )
  start( '.with group1/b .export' )
  start( '.with group2/c .export' )
  start( '.with z .export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 31 );
    test.identical( _.strCount( got.output, '+ 1/4 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  start( '.with z .clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 31 );

    var exp =
    [
      '.',
      './z.will.yml',
      './group1',
      './group1/a.will.yml',
      './group1/b.will.yml',
      './group1/group10',
      './group1/group10/a0.will.yml',
      './group2',
      './group2/c.will.yml'
    ]
    var files = self.find( routinePath );
    test.identical( files, exp );

    return null;
  })

  /* - */

  return ready;
} /* end of function cleanRecursive */

cleanRecursive.timeOut = 500000;

//

function cleanDisabledModule( test )
{
  let self = this;
  let a = self.assetFor( test, 'export-disabled-module' );
  let willfPath = a.abs( './' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.clean';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  a.start( '.clean' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with . .clean';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  a.start( '.with . .clean' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  a.startNonThrowing( '.with * .clean' )

  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, '- Clean deleted' ), 0 );
    test.identical( _.strCount( op.output, 'No module sattisfy criteria' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.imply withDisabled:1 ; .with * .clean';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  a.start( '.imply withDisabled:1 ; .with * .clean' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );
    test.identical( _.strCount( op.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanDisabledModule */

cleanDisabledModule.timeOut = 300000;
cleanDisabledModule.description =
`
- disabled module should be cleaned if picked explicitly
- disabled module should not be cleaned if picked with glob
`

//

function cleanHierarchyRemote( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .clean';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with z .clean' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean recursive:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean recursive:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 7 );
    test.identical( _.strCount( got.output, ' at ' ), 9 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .clean recursive:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .clean recursive:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .clean recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanHierarchyRemote */

cleanHierarchyRemote.timeOut = 1000000;

//

function cleanHierarchyRemoteDry( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .clean dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with z .clean dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean recursive:1 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean recursive:1 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 7 );
    test.identical( _.strCount( got.output, ' at ' ), 9 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .clean recursive:2 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .clean recursive:2 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .clean recursive:1 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .clean recursive:1 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .clean recursive:2 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .clean recursive:2 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 24 );
    test.identical( _.strCount( got.output, ' at ' ), 26 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanHierarchyRemoteDry */

cleanHierarchyRemoteDry.timeOut = 1000000;

//

function cleanSubmodulesHierarchyRemote( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.clean';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with z .submodules.clean' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean recursive:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean recursive:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 4 );
    test.identical( _.strCount( got.output, ' at ' ), 6 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.clean recursive:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .submodules.clean recursive:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.clean recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .submodules.clean recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '- Clean deleted' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanSubmodulesHierarchyRemote */

cleanSubmodulesHierarchyRemote.timeOut = 1000000;

//

function cleanSubmodulesHierarchyRemoteDry( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.clean dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with z .submodules.clean dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 1 );
    test.identical( _.strCount( got.output, ' at ' ), 3 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean recursive:1 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean recursive:1 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 4 );
    test.identical( _.strCount( got.output, ' at ' ), 6 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .submodules.clean recursive:2 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with * .submodules.clean recursive:2 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.clean recursive:1 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .submodules.clean recursive:1 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.clean recursive:2 dry:1';
    a.reflect();
    return null;
  })

  a.start( '.with ** .submodules.download recursive:2' )
  a.start( '.with ** .submodules.clean recursive:2 dry:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '. Read 26 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, ' at .' ), 9 );
    test.identical( _.strCount( got.output, ' at ' ), 11 );
    test.identical( _.strCount( got.output, '. Clean will delete' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function cleanSubmodulesHierarchyRemoteDry */

cleanSubmodulesHierarchyRemoteDry.timeOut = 1000000;

//

function buildSingleModule( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outDebugPath = _.path.join( routinePath, 'out/debug' );
  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready.then( () =>
  {
    test.case = '.build'
    _.fileProvider.filesDelete( outDebugPath );
    return null;
  })

  start({ execPath : '.build' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .*module::single \/ build::debug\.raw.*/ ) );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, /Built .*module::single \/ build::debug\.raw.* in/ ) );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );

    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = '.build debug.raw'
    let outDebugPath = _.path.join( routinePath, 'out/debug' );
    _.fileProvider.filesDelete( outDebugPath );
    return null;
  })

  start({ execPath : '.build debug.raw' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .*module::single \/ build::debug\.raw.*/ ) );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, /Built .*module::single \/ build::debug\.raw.* in/ ) );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );

    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = '.build release.raw'
    let outDebugPath = _.path.join( routinePath, 'out/release' );
    _.fileProvider.filesDelete( outDebugPath );
    return null;
  })

  start({ execPath : '.build release.raw' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Building .*module::single \/ build::release\.raw.*/ ) );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, /Built .*module::single \/ build::release\.raw.* in/ ) );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build wrong'
    let buildOutDebugPath = _.path.join( routinePath, 'out/debug' );
    let buildOutReleasePath = _.path.join( routinePath, 'out/release' );
    _.fileProvider.filesDelete( buildOutDebugPath );
    _.fileProvider.filesDelete( buildOutReleasePath );
    var o =
    {
      args : [ '.build wrong' ],
      ready : null,
    }
    return test.shouldThrowErrorOfAnyKind( () => start( o ) )
    .then( ( got ) =>
    {
      test.is( o.exitCode !== 0 );
      test.is( o.output.length );
      test.is( !_.fileProvider.fileExists( buildOutDebugPath ) )
      test.is( !_.fileProvider.fileExists( buildOutReleasePath ) )

      return null;
    })
  })

  /* - */

  return ready;
}

buildSingleModule.timeOut = 200000;

//

function buildSingleStep( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-shell' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.build debug1'
    let outDebugPath = _.path.join( routinePath, 'out/debug' );
    let outPath = _.path.join( routinePath, 'out' );
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.build debug2'
    let outDebugPath = _.path.join( routinePath, 'out/debug' );
    let outPath = _.path.join( routinePath, 'out' );
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build debug2' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    return null;
  })

  /* - */

  return ready;
}

//

function buildSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready

  /* - */

  .then( () =>
  {
    test.case = 'build withoud submodules'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build' })
  .finally( ( err, got ) =>
  {
    test.is( !err );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    var files = self.find( outPath );
    test.gt( files.length, 60 );
    return null;
  })

  /* - */

  start({ execPath : '.submodules.update' })
  .then( () =>
  {
    test.case = '.build'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, /Building .*module::submodules \/ build::debug\.raw.*/ ) );
    test.is( _.strHas( got.output, /Built .*module::submodules \/ build::debug\.raw.*/ ) );

    var files = self.find( outPath );
    test.gt( files.length, 15 );

    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = '.build wrong'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  .then( () =>
  {

    var o =
    {
      execPath : 'node ' + self.willPath,
      currentPath : routinePath,
      outputCollecting : 1,
    outputGraying : 1,
      args : [ '.build wrong' ]
    }

    let buildOutDebugPath = _.path.join( routinePath, 'out/debug' );
    let buildOutReleasePath = _.path.join( routinePath, 'out/release' );

    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    .then( ( got ) =>
    {
      test.is( o.exitCode !== 0 );
      test.is( o.output.length );
      test.is( !_.fileProvider.fileExists( outPath ) );
      test.is( !_.fileProvider.fileExists( buildOutDebugPath ) );
      test.is( !_.fileProvider.fileExists( buildOutReleasePath ) );

      return null;
    })

  });

  return ready;
}

buildSubmodules.timeOut = 300000;

//

function buildDetached( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );
  let modulePath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, /\+ .*module::wTools.* was downloaded version .*master.* in/ ) );
    test.is( _.strHas( got.output, /\+ .*module::wPathBasic.* was downloaded version .*622fb3c259013f3f6e2aeec73642645b3ce81dbc.* in/ ) );
    // test.is( _.strHas( got.output, /\+ .*module::wColor.* was downloaded version .*0.3.115.* in/ ) );
    test.is( _.strHas( got.output, /\.module\/Procedure\.informal <- npm:\/\/wprocedure/ ) );
    test.is( _.strHas( got.output, /\.module\/Proto\.informal <- git\+https:\/\/github\.com\/Wandalen\/wProto\.git#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7/ ) );
    test.is( _.strHas( got.output, /\.module\/UriBasic\.informal <- git\+https:\/\/github\.com\/Wandalen\/wUriBasic\.git/ ) );

    var files = _.fileProvider.dirRead( modulePath );
    test.identical( files, [ /* 'Color', */ 'PathBasic', 'Procedure.informal', 'Proto.informal', 'Tools', 'UriBasic.informal' ] );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'Procedure.informal.out.will.yml', 'Proto.informal.out.will.yml', 'UriBasic.informal.out.will.yml' ] );

    return null;
  })

  /* - */

  return ready;
}

buildDetached.timeOut = 300000;

//

function exportSingle( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outDebugPath = _.path.join( routinePath, 'out/debug' );
  let outPath = _.path.join( routinePath, 'out' );
  let outWillPath = _.path.join( routinePath, 'out/single.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outDebugPath );

  /* - */

  ready.then( () =>
  {
    test.case = '.export'
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, 'Exported module::single / build::proto.export with 2 file(s) in') );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );
    var files = self.find( outPath );
    test.identical( files, [ '.', './single.out.will.yml', './debug', './debug/Single.s' ] );

    test.is( _.fileProvider.fileExists( outWillPath ) )
    var outfile = _.fileProvider.fileConfigRead( outWillPath );
    outfile = outfile.module[ outfile.root[ 0 ] ];

    let reflector = outfile.reflector[ 'exported.files.proto.export' ];
    test.identical( reflector.src.basePath, '.' );
    test.identical( reflector.src.prefixPath, 'path::exported.dir.proto.export' );
    test.identical( reflector.src.filePath, { 'path::exported.files.proto.export' : '' } );

    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = '.export.proto'
    let outDebugPath = _.path.join( routinePath, 'out/debug' );
    let outPath = _.path.join( routinePath, 'out' );
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.export proto.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exported .*module::single \/ build::proto.export.* in/ ) );
    test.is( _.strHas( got.output, 'reflected 2 file(s)' ) );
    test.is( _.strHas( got.output, 'Exported module::single / build::proto.export with 2 file(s) in' ) );

    var files = self.find( outDebugPath );
    test.identical( files, [ '.', './Single.s' ] );
    var files = self.find( outPath );
    test.identical( files, [ '.', './single.out.will.yml', './debug', './debug/Single.s'  ] );

    test.is( _.fileProvider.fileExists( outWillPath ) )
    var outfile = _.fileProvider.fileConfigRead( outWillPath );
    outfile = outfile.module[ outfile.root[ 0 ] ];

    let reflector = outfile.reflector[ 'exported.files.proto.export' ];
    let expectedFilePath =
    {
      '.' : '',
      'Single.s' : '',
    }
    test.identical( reflector.src.basePath, '.' );
    test.identical( reflector.src.prefixPath, 'path::exported.dir.proto.export' );
    test.identical( reflector.src.filePath, { 'path::exported.files.proto.export' : '' } );

    return null;
  })

  return ready;
}

exportSingle.timeOut = 200000;

//

function exportItself( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-itself' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready.then( () =>
  {
    test.case = '.export'
    return null;
  })

  start( '.with v1 .clean' )
  start( '.with v1 .submodules.download' )
  start( '.with v1 .export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( routinePath );
    test.gt( files.length, 250 );

    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, /Exported module::experiment \/ build::export with .* file\(s\) in/ ) );

    return null;
  })

  /* */

  return ready;
}

//

/*
  Submodule Submodule is deleted, so exporting should fail.
*/

function exportNonExportable( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete( _.path.join( routinePath, 'out' ) );
  _.fileProvider.filesDelete( _.path.join( routinePath, 'super.out' ) );

  /* - */

  start({ execPath : '.with super .clean' })
  start({ args : [ '.with super .export debug:1' ], throwingExitCode : 0 })

  .then( ( got ) =>
  {
    test.is( got.exitCode !== 0 );

    test.identical( _.strCount( got.output, 'uncaught error' ), 0 );
    test.identical( _.strCount( got.output, '====' ), 0 );

    test.identical( _.strCount( got.output, 'module::supermodule / relation::Submodule is not opened' ), 1 );
    test.identical( _.strCount( got.output, 'Failed module::supermodule / step::reflect.submodules.debug' ), 1 );

    // test.identical( _.strCount( got.output, /Exporting is impossible because .*module::supermodule \/ submodule::Submodule.* is broken!/ ), 1 );
    // test.identical( _.strCount( got.output, /Failed .*module::supermodule \/ step::export.*/ ), 1 );

    return null;
  })

  return ready;
}

//

function exportInformal( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-mixed' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with module/Proto.informal .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with module/Proto.informal .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, /Exported .*module::Proto.informal \/ build::export.* in/ ), 1 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './Proto.informal.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( outPath, './Proto.informal.out.will.yml' ) );
    outfile = outfile.module[ 'Proto.informal.out' ];
    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out.will.yml`
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out`
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`
      },
      "in" :
      {
        "path" : `.`
      },
      "out" :
      {
        "path" : `.`
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "download" : { "path" : `../.module/Proto`, "criterion" : { "predefined" : 1 } },
      "export" : { "path" : `{path::download}/proto/**` },
      "exported.dir.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" : `../.module/Proto/proto`
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      },
    }
    delete outfile.path[ 'exported.files.export' ];
    test.identical( outfile.path, expected );
    test.identical( outfile.path.download.path, '../.module/Proto' );
    test.identical( outfile.path.remote.path, undefined );
    // test.identical( outfile.path.remote.path, 'git+https:///github.com/Wandalen/wProto.git' );
    // logger.log( _.toJson( outfile.path ) );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with module/Proto.informal .export -- second'
    return null;
  })

  start({ execPath : '.with module/Proto.informal .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, /Exported .*module::Proto.informal \/ build::export.* in/ ), 1 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './Proto.informal.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( outPath, './Proto.informal.out.will.yml' ) );
    outfile = outfile.module[ 'Proto.informal.out' ];
    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out.will.yml`
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out`
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`
      },
      "in" :
      {
        "path" : `.`
      },
      "out" :
      {
        "path" : `.`
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "download" : { "path" : `../.module/Proto`, "criterion" : { "predefined" : 1 } },
      "export" : { "path" : `{path::download}/proto/**` },
      "exported.dir.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" : `../.module/Proto/proto`
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      },
    }
    delete outfile.path[ 'exported.files.export' ];
    test.identical( outfile.path, expected );
    test.identical( outfile.path.download.path, '../.module/Proto' );
    test.identical( outfile.path.remote.path, undefined );
    // test.identical( outfile.path.remote.path, 'git+https:///github.com/Wandalen/wProto.git' );
    // logger.log( _.toJson( outfile.path ) );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.with module/UriBasic.informal .export'
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.with module/UriBasic.informal .export' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, /Exported .*module::UriBasic.informal \/ build::export.* in/ ), 1 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './UriBasic.informal.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( outPath, './UriBasic.informal.out.will.yml' ) );
    outfile = outfile.module[ 'UriBasic.informal.out' ];
    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `UriBasic.informal.out.will.yml`
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `UriBasic.informal.out`
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/UriBasic.informal.will.yml`
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/UriBasic.informal.will.yml`
      },
      "in" :
      {
        "path" : `.`
      },
      "out" :
      {
        "path" : `.`
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "download" : { "path" : `../.module/UriBasic`, "criterion" : { "predefined" : 1 } },
      "export" : { "path" : `{path::download}/proto/**` },
      "exported.dir.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" : `../.module/UriBasic/proto`
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      }
    }
    delete outfile.path[ 'exported.files.export' ];
    test.identical( outfile.path, expected );
    test.identical( outfile.path.download.path, '../.module/UriBasic' );
    test.identical( outfile.path.remote.path, undefined );
    // test.identical( outfile.path.remote.path, 'npm:///wuribasic' );
    // logger.log( _.toJson( outfile.path ) );

    return null;
  })

  /* - */

  return ready;
}

exportInformal.timeOut = 300000;
exportInformal.description =
`
- local path and remote path of exported informal module should be preserved and in proper form
- second export should work properly
`

//

function exportWithReflector( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-reflector' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outDebugPath = _.path.join( routinePath, 'out/debug' );
  let outPath = _.path.join( routinePath, 'out' );
  let outWillPath = _.path.join( routinePath, 'out/export-with-reflector.out.will.yml' );
  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete( outDebugPath );

  /* - */

  ready.then( () =>
  {
    test.case = '.export'
    _.fileProvider.filesDelete( outDebugPath );
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './export-with-reflector.out.will.yml' ] );

    // var reflectors =

    var outfile = _.fileProvider.fileConfigRead( outWillPath );

    debugger;

    return null;
  })

  return ready;
}

exportWithReflector.timeOut = 200000;

//

function exportToRoot( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-to-root' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.case = '.export'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exporting .*module::export-to-root \/ build::proto\.export.*/ ) );
    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, /Exported .*module::export-to-root \/ build::proto\.export.* in/ ) );
    test.is( _.fileProvider.fileExists( _.path.join( routinePath, 'export-to-root.out.will.yml' ) ) )
    return null;
  })

  return ready;
}

exportToRoot.timeOut = 200000;

//

function exportMixed( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-mixed' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.each module .export';
    return null;
  })

  start({ execPath : '.each module .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exporting .*module::UriBasic\.informal \/ build::export.*/ ) );
    test.is( _.strHas( got.output, ' + reflector::download reflected' ) );
    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, /Exported .*module::UriBasic\.informal \/ build::export.* in/ ) );
    test.is( _.strHas( got.output, 'out/Proto.informal.out.will.yml' ) );
    test.is( _.strHas( got.output, 'out/UriBasic.informal.out.will.yml' ) );

    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/Proto.informal.out.will.yml' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/UriBasic.informal.out.will.yml' ) ) );

    var files = self.find( _.path.join( routinePath, 'module' ) );
    test.identical( files, [ '.', './Proto.informal.will.yml', './UriBasic.informal.will.yml' ] );
    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './Proto.informal.out.will.yml', './UriBasic.informal.out.will.yml' ] );

    var expected = [ 'Proto.informal.will.yml', 'UriBasic.informal.will.yml' ];
    var files = _.fileProvider.dirRead( modulePath );
    test.identical( files, expected );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( routinePath, 'out/Proto.informal.out.will.yml' ) );
    outfile = outfile.module[ 'Proto.informal.out' ];
    var expected =
    {
      'download' :
      {
        'src' : { 'prefixPath' : 'path::remote', 'filePath' : { '.' : '.' } },
        'dst' : { 'prefixPath' : 'path::download' },
        'mandatory' : 1,
      },
      'exported.export' :
      {
        'src' :
        {
          'filePath' : { '**' : '' },
          'prefixPath' : '../.module/Proto/proto'
        },
        'criterion' : { 'export' : 1, 'default' : 1, 'generated' : 1 },
        'mandatory' : 1,
      },
      'exported.files.export' :
      {
        'recursive' : 0,
        'mandatory' : 1,
        'src' : { 'filePath' : { 'path::exported.files.export' : '' }, 'basePath' : '.', 'prefixPath' : 'path::exported.dir.export', 'recursive' : 0 },
        'criterion' : { 'default' : 1, 'export' : 1, 'generated' : 1 }
      }
    }
    test.identical( outfile.reflector, expected );
    test.identical( outfile.reflector[ 'exported.files.export' ], expected[ 'exported.files.export' ] );

    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out.will.yml`
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.informal.out`
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.informal.will.yml`,
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..',
      },
      "in" :
      {
        "path" : `.`
      },
      "out" :
      {
        "path" : `.`
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "download" : { "path" : `../.module/Proto`/*, "criterion" : { "predefined" : 1 }*/ },
      "export" : { "path" : `{path::download}/proto/**` },
      "exported.dir.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" : `../.module/Proto/proto`
      },
      "exported.files.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" :
        [
          `../.module/Proto/proto`,
          `../.module/Proto/proto/dwtools`,
          `../.module/Proto/proto/dwtools/Tools.s`,
          `../.module/Proto/proto/dwtools/abase`,
          `../.module/Proto/proto/dwtools/abase/l3_proto`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/Include.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l1`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l1/Define.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l1/Proto.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l1/Workpiece.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l3`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l3/Accessor.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l3/Class.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l3/Complex.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto/l3/Like.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto.test`,
          `../.module/Proto/proto/dwtools/abase/l3_proto.test/Class.test.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto.test/Complex.test.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto.test/Like.test.s`,
          `../.module/Proto/proto/dwtools/abase/l3_proto.test/Proto.test.s`
        ]
      }
    }
    test.identical( outfile.path, expected );
    // logger.log( _.toJson( outfile.path ) );

    var expected =
    {
      'export' :
      {
        'version' : '0.1.0',
        'recursive' : 0,
        'withIntegrated' : 2,
        'tar' : 0,
        'criterion' : { 'default' : 1, 'export' : 1 },
        'exportedReflector' : 'reflector::exported.export',
        'exportedFilesReflector' : 'reflector::exported.files.export',
        'exportedDirPath' : 'path::exported.dir.export',
        'exportedFilesPath' : 'path::exported.files.export',
      }
    }
    test.identical( outfile.exported, expected );

    var expected =
    {
      'export.common' :
      {
        'opts' : { 'export' : 'path::export', 'tar' : 0 },
        'inherit' : [ 'module.export' ]
      },
      'download' :
      {
        'opts' : { 'reflector' : 'reflector::download*', 'verbosity' : null },
        'inherit' : [ 'files.reflect' ]
      }
    }
    test.identical( outfile.step, expected );

    var expected =
    {
      'export' :
      {
        'criterion' : { 'default' : 1, 'export' : 1 },
        'steps' : [ 'step::download', 'step::export.common' ]
      }
    }
    test.identical( outfile.build, expected );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.build';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.build' })

  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Exporting .*module::UriBasic.informal.* \/ build::export/ ) );
    test.is( _.strHas( got.output, /\+ reflector::download reflected .* file\(s\)/ ) );
    test.is( _.strHas( got.output, '+ Write out willfile' ) );
    test.is( _.strHas( got.output, /Exported .*module::UriBasic.informal.* \/ build::export/ ) );
    test.is( _.strHas( got.output, 'out/Proto.informal.out.will.yml' ) );
    test.is( _.strHas( got.output, 'out/UriBasic.informal.out.will.yml' ) );
    test.is( _.strHas( got.output, 'Reloading submodules' ) );

    test.is( _.strHas( got.output, /- .*step::delete.out.debug.* deleted 0 file\(s\), at/ ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.proto.debug reflected' ) );
    test.is( _.strHas( got.output, ' + reflector::reflect.submodules reflected' ) );

    test.identical( _.strCount( got.output, ' ! Failed to open' ), 4 );

    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/Proto.informal.out.will.yml' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/UriBasic.informal.out.will.yml' ) ) );

    var files = self.find( _.path.join( routinePath, 'module' ) );
    test.identical( files, [ '.', './Proto.informal.will.yml', './UriBasic.informal.will.yml' ] );
    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.gt( files.length, 70 );

    var expected = [ 'Proto.informal.will.yml', 'UriBasic.informal.will.yml' ];
    var files = _.fileProvider.dirRead( modulePath );
    test.identical( files, expected );

    var expected = [ 'dwtools', 'WithSubmodules.s' ];
    var files = _.fileProvider.dirRead( _.path.join( routinePath, 'out/debug' ) );
    test.identical( files, expected );

    return null;
  })

  /* - */

  return ready;
}

exportMixed.timeOut = 300000;

//

function exportSecond( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-second' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.export';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+ Write out willfile' ), 2 );
    test.identical( _.strCount( got.output, 'Exported module::ExportSecond / build::export with 6 file(s) in' ), 1 );

    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/ExportSecond.out.will.yml' ) ) );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './ExportSecond.out.will.yml', './debug', './debug/.NotExecluded.js', './debug/File.js' ] );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( routinePath, 'out/ExportSecond.out.will.yml' ) );

    outfile = outfile.module[ 'ExportSecond.out' ]

    var expected =
    {
      "reflect.proto." :
      {
        "src" :
        {
          "filePath" : { "path::proto" : "path::out.*=1" },
          "prefixPath" : ""
        },
        "dst" : { "prefixPath" : "" },
        "mandatory" : 1,
        "criterion" : { "debug" : 0 },
        "inherit" : [ "predefined.*" ]
      },
      "reflect.proto.debug" :
      {
        "src" :
        {
          "filePath" : { "path::proto" : "path::out.*=1" }
        },
        "mandatory" : 1,
        "criterion" : { "debug" : 1 },
        "inherit" : [ "predefined.*" ]
      },
      "exported.doc.export" :
      {
        "src" :
        {
          "filePath" : { "**" : "" },
          "prefixPath" : "../doc"
        },
        "mandatory" : 1,
        "criterion" : { "doc" : 1, "export" : 1, 'generated' : 1 }
      },
      "exported.files.doc.export" :
      {
        "src" :
        {
          "filePath" : { "path::exported.files.doc.export" : "" },
          "basePath" : ".",
          "prefixPath" : "path::exported.dir.doc.export",
          "recursive" : 0
        },
        "recursive" : 0,
        "mandatory" : 1,
        "criterion" : { "doc" : 1, "export" : 1, 'generated' : 1 }
      },
      "exported.proto.export" :
      {
        "src" :
        {
          "filePath" : { "**" : "" },
          "prefixPath" : "../proto"
        },
        "mandatory" : 1,
        "criterion" : { "proto" : 1, "export" : 1, 'generated' : 1 }
      },
      "exported.files.proto.export" :
      {
        "src" :
        {
          "filePath" : { "path::exported.files.proto.export" : "" },
          "basePath" : ".",
          "prefixPath" : "path::exported.dir.proto.export",
          "recursive" : 0
        },
        "recursive" : 0,
        "mandatory" : 1,
        "criterion" : { "proto" : 1, "export" : 1, 'generated' : 1 }
      }
    }
    test.identical( outfile.reflector, expected );
    // logger.log( _.toJson( outfile.reflector ) ); debugger;

    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : "ExportSecond.out.will.yml"
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : "ExportSecond.out"
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ]
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ]
      },
      "download" :
      {
        "criterion" : { "predefined" : 1 }
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "in" :
      {
        "path" : "."
      },
      "temp" : { "path" : "." },
      "out" :
      {
        "path" : "."
      },
      "out.debug" :
      {
        "criterion" : { "debug" : 1 },
        "path" : "debug/*"
      },
      "out.release" :
      {
        "criterion" : { "debug" : 0 },
        "path" : "release/*"
      },
      "proto" : { "path" : "../proto/**" },
      "doc" : { "path" : "../doc/**" },
      "exported.dir.doc.export" :
      {
        "criterion" : { "doc" : 1, "export" : 1, "generated" : 1 },
        "path" : "../doc"
      },
      "exported.files.doc.export" :
      {
        "criterion" : { "doc" : 1, "export" : 1, 'generated' : 1 },
        "path" : [ "../doc", "../doc/File.md" ]
      },
      "exported.dir.proto.export" :
      {
        "criterion" : { "proto" : 1, "export" : 1, 'generated' : 1 },
        "path" : "../proto"
      },
      "exported.files.proto.export" :
      {
        "criterion" : { "proto" : 1, "export" : 1, 'generated' : 1 },
        "path" : [ "../proto", "../proto/-NotExecluded.js", "../proto/.NotExecluded.js", "../proto/File.js" ]
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      }
    }
    test.identical( outfile.path, expected );
    // logger.log( _.toJson( outfile.path ) ); debugger;

    var expected =
    {
      'doc.export' :
      {
        version : '0.0.0',
        recursive : 0,
        withIntegrated : 2,
        tar : 0,
        criterion : { doc : 1, export : 1 },
        exportedReflector : 'reflector::exported.doc.export',
        exportedFilesReflector : 'reflector::exported.files.doc.export',
        exportedDirPath : 'path::exported.dir.doc.export',
        exportedFilesPath : 'path::exported.files.doc.export',
      },
      'proto.export' :
      {
        version : '0.0.0',
        recursive : 0,
        withIntegrated : 2,
        tar : 0,
        criterion : { proto : 1, export : 1 },
        exportedReflector : 'reflector::exported.proto.export',
        exportedFilesReflector : 'reflector::exported.files.proto.export',
        exportedDirPath : 'path::exported.dir.proto.export',
        exportedFilesPath : 'path::exported.files.proto.export',
      }
    }
    test.identical( outfile.exported, expected );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.export';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '+ Write out willfile' ), 2 );
    test.identical( _.strCount( got.output, 'Exported module::ExportSecond / build::export with 6 file(s) in' ), 1 );

    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/ExportSecond.out.will.yml' ) ) );

    var files = self.find( _.path.join( routinePath, 'out' ) );
    test.identical( files, [ '.', './ExportSecond.out.will.yml', './debug', './debug/.NotExecluded.js', './debug/File.js' ] );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( routinePath, 'out/ExportSecond.out.will.yml' ) );

    outfile = outfile.module[ 'ExportSecond.out' ]

    var expected =
    {
      "reflect.proto." :
      {
        "src" :
        {
          "filePath" : { "path::proto" : "path::out.*=1" },
          "prefixPath" : ""
        },
        "dst" : { "prefixPath" : "" },
        "mandatory" : 1,
        "criterion" : { "debug" : 0 },
        "inherit" : [ "predefined.*" ]
      },
      "reflect.proto.debug" :
      {
        "src" :
        {
          "filePath" : { "path::proto" : "path::out.*=1" }
        },
        "mandatory" : 1,
        "criterion" : { "debug" : 1 },
        "inherit" : [ "predefined.*" ]
      },
      "exported.doc.export" :
      {
        "src" :
        {
          "filePath" : { "**" : "" },
          "prefixPath" : "../doc"
        },
        "mandatory" : 1,
        "criterion" : { "doc" : 1, "export" : 1, "generated" : 1 }
      },
      "exported.files.doc.export" :
      {
        "src" :
        {
          "filePath" : { "path::exported.files.doc.export" : "" },
          "basePath" : ".",
          "prefixPath" : "path::exported.dir.doc.export",
          "recursive" : 0
        },
        "recursive" : 0,
        "mandatory" : 1,
        "criterion" : { "doc" : 1, "export" : 1, "generated" : 1 }
      },
      "exported.proto.export" :
      {
        "src" :
        {
          "filePath" : { "**" : "" },
          "prefixPath" : "../proto"
        },
        "mandatory" : 1,
        "criterion" : { "proto" : 1, "export" : 1, "generated" : 1 }
      },
      "exported.files.proto.export" :
      {
        "src" :
        {
          "filePath" : { "path::exported.files.proto.export" : "" },
          "basePath" : ".",
          "prefixPath" : "path::exported.dir.proto.export",
          "recursive" : 0
        },
        "recursive" : 0,
        "mandatory" : 1,
        "criterion" : { "proto" : 1, "export" : 1, "generated" : 1 }
      }
    }
    test.identical( outfile.reflector, expected );
    // logger.log( _.toJson( outfile.reflector ) ); debugger;

    var expected =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : "ExportSecond.out.will.yml"
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : "ExportSecond.out"
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ]
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ]
      },
      "download" :
      {
        "criterion" : { "predefined" : 1 }
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "in" :
      {
        "path" : "."
      },
      "temp" : { "path" : "." },
      "out" :
      {
        "path" : "."
      },
      "out.debug" :
      {
        "criterion" : { "debug" : 1 },
        "path" : "debug/*"
      },
      "out.release" :
      {
        "criterion" : { "debug" : 0 },
        "path" : "release/*"
      },
      "proto" : { "path" : "../proto/**" },
      "doc" : { "path" : "../doc/**" },
      "exported.dir.doc.export" :
      {
        "criterion" : { "doc" : 1, "export" : 1, "generated" : 1 },
        "path" : "../doc"
      },
      "exported.files.doc.export" :
      {
        "criterion" : { "doc" : 1, "export" : 1, "generated" : 1 },
        "path" : [ "../doc", "../doc/File.md" ]
      },
      "exported.dir.proto.export" :
      {
        "criterion" : { "proto" : 1, "export" : 1, "generated" : 1 },
        "path" : "../proto"
      },
      "exported.files.proto.export" :
      {
        "criterion" : { "proto" : 1, "export" : 1, "generated" : 1 },
        "path" : [ "../proto", "../proto/-NotExecluded.js", "../proto/.NotExecluded.js", "../proto/File.js" ]
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      }
    }
    test.identical( outfile.path, expected );
    // logger.log( _.toJson( outfile.path ) ); debugger;

    var expected =
    {
      'doc.export' :
      {
        version : '0.0.0',
        recursive : 0,
        withIntegrated : 2,
        tar : 0,
        criterion : { doc : 1, export : 1 },
        exportedReflector : 'reflector::exported.doc.export',
        exportedFilesReflector : 'reflector::exported.files.doc.export',
        exportedDirPath : 'path::exported.dir.doc.export',
        exportedFilesPath : 'path::exported.files.doc.export',
      },
      'proto.export' :
      {
        version : '0.0.0',
        recursive : 0,
        withIntegrated : 2,
        tar : 0,
        criterion : { proto : 1, export : 1 },
        exportedReflector : 'reflector::exported.proto.export',
        exportedFilesReflector : 'reflector::exported.files.proto.export',
        exportedDirPath : 'path::exported.dir.proto.export',
        exportedFilesPath : 'path::exported.files.proto.export',
      }
    }
    test.identical( outfile.exported, expected );

    return null;
  })

  /* - */

  return ready;
}

exportSecond.timeOut = 300000;

//

function exportSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outDebugPath = _.path.join( routinePath, 'out/debug' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  return start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/debug/dwtools/abase/l0/l1/Predefined.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/debug/dwtools/abase/l2/PathBasic.s' ) ) );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/submodules.out.will.yml' ) ) );
    test.is( _.strHas( got.output, /Exported .*module::submodules \/ build::proto\.export.* in/ ) );

    var files = self.find( outPath );
    test.is( files.length > 60 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'submodules.out.will.yml' ] );

    return null;
  })

  return ready;
}

exportSubmodules.timeOut = 200000;

//

function exportMultiple( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-multiple' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );
  let outWillPath = _.path.join( outPath, 'submodule.out.will.yml' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.export debug:1';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );

    return null;
  })

  start({ execPath : '.export debug:1' })

  .then( ( got ) =>
  {

    var files = self.find( outPath );
    test.identical( files, [ '.', './submodule.debug.out.tgs', './submodule.out.will.yml', './debug', './debug/File.debug.js' ] );
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'Read 2 willfile(s) in' ) );
    test.is( _.strHas( got.output, /Exported module::submodule \/ build::export.debug with 2 file\(s\) in .*/ ) );
    test.is( _.strHas( got.output, 'Write out archive' ) );
    test.is( _.strHas( got.output, 'Write out willfile' ) );
    test.is( _.strHas( got.output, 'submodule.debug.out.tgs' ) );
    test.is( _.strHas( got.output, 'out/submodule.out.will.yml' ) );

    var outfile = _.fileProvider.fileConfigRead( outWillPath );

    outfile = outfile.module[ 'submodule.out' ];

    var exported =
    {
      'export.debug' :
      {
        version : '0.0.1',
        recursive : 0,
        withIntegrated : 2,
        tar : 1,
        criterion :
        {
          default : 1,
          debug : 1,
          raw : 1,
          export : 1
        },
        exportedReflector : 'reflector::exported.export.debug',
        exportedFilesReflector : 'reflector::exported.files.export.debug',
        exportedDirPath : 'path::exported.dir.export.debug',
        exportedFilesPath : 'path::exported.files.export.debug',
        archiveFilePath : 'path::archiveFile.export.debug',
      }
    }

    test.identical( outfile.exported, exported );

    var exportedReflector =
    {
      // src : { filePath : { '.' : '' }, prefixPath : 'debug' },
      src : { filePath : { '**' : '' }, prefixPath : 'debug' },
      mandatory : 1,
      criterion :
      {
        default : 1,
        debug : 1,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }
    test.identical( outfile.reflector[ 'exported.export.debug' ], exportedReflector );
    // logger.log( _.toJson( outfile.reflector ) );

    var exportedReflectorFiles =
    {
      recursive : 0,
      mandatory : 1,
      src :
      {
        filePath : { 'path::exported.files.export.debug' : '' },
        basePath : '.',
        prefixPath : 'path::exported.dir.export.debug',
        recursive : 0,
      },
      criterion :
      {
        default : 1,
        debug : 1,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }

    test.identical( outfile.reflector[ 'exported.files.export.debug' ], exportedReflectorFiles );

    let outfilePath =
    {
      "module.willfiles" :
      {
        "path" : "submodule.out.will.yml",
        "criterion" : { "predefined" : 1 }
      },
      "module.original.willfiles" :
      {
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ],
        "criterion" : { "predefined" : 1 }
      },
      "module.peer.willfiles" :
      {
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ],
        "criterion" : { "predefined" : 1 }
      },
      "download" :
      {
        "criterion" : { "predefined" : 1 }
      },
      "module.common" :
      {
        "path" : "submodule.out",
        "criterion" : { "predefined" : 1 }
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "proto" : { "path" : "../proto" },
      "temp" : { "path" : "." },
      "in" :
      {
        "path" : ".",
      },
      "out" :
      {
        "path" : ".",
      },
      "out.debug" :
      {
        "path" : "debug",
        "criterion" : { "debug" : 1 }
      },
      "out.release" :
      {
        "path" : "release",
        "criterion" : { "debug" : 0 }
      },
      "exported.dir.export.debug" :
      {
        "path" : "debug",
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "exported.files.export.debug" :
      {
        "path" : [ "debug", "debug/File.debug.js" ],
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          'generated' : 1,
        }
      },
      "archiveFile.export.debug" :
      {
        "path" : "submodule.debug.out.tgs",
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      }
    }
    test.identical( outfile.path, outfilePath );
    // logger.log( _.toJson( outfile.path ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.export debug:1';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );

    return null;
  })

  start({ execPath : '.export debug:1' })
  start({ execPath : '.export debug:0' })
  start({ execPath : '.export debug:0' })

  .then( ( got ) =>
  {

    var files = self.find( outPath );
    test.identical( files, [ '.', './submodule.debug.out.tgs', './submodule.out.tgs', './submodule.out.will.yml', './debug', './debug/File.debug.js', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'Read 3 willfile(s) in' ) );
    test.is( _.strHas( got.output, /Exported module::submodule \/ build::export. with 2 file\(s\) in .*/ ) );
    test.is( _.strHas( got.output, 'Write out archive' ) );
    test.is( _.strHas( got.output, 'Write out willfile' ) );
    test.is( _.strHas( got.output, 'submodule.out.tgs' ) );
    test.is( _.strHas( got.output, 'out/submodule.out.will.yml' ) );

    var outfileData = _.fileProvider.fileRead( outWillPath );
    test.is( outfileData.length > 1000 );
    test.is( !_.strHas( outfileData, _.path.join( routinePath, '../..' ) ) );
    test.is( !_.strHas( outfileData, _.path.nativize( _.path.join( routinePath, '../..' ) ) ) );

    var outfile = _.fileProvider.fileConfigRead( outWillPath );
    outfile = outfile.module[ 'submodule.out' ]
    var exported =
    {
      'export.debug' :
      {
        version : '0.0.1',
        recursive : 0,
        withIntegrated : 2,
        tar : 1,
        criterion :
        {
          default : 1,
          debug : 1,
          raw : 1,
          export : 1
        },
        exportedReflector : 'reflector::exported.export.debug',
        exportedFilesReflector : 'reflector::exported.files.export.debug',
        exportedDirPath : 'path::exported.dir.export.debug',
        exportedFilesPath : 'path::exported.files.export.debug',
        archiveFilePath : 'path::archiveFile.export.debug',
      },
      'export.' :
      {
        version : '0.0.1',
        recursive : 0,
        withIntegrated : 2,
        tar : 1,
        criterion :
        {
          default : 1,
          debug : 0,
          raw : 1,
          export : 1
        },
        exportedReflector : 'reflector::exported.export.',
        exportedFilesReflector : 'reflector::exported.files.export.',
        exportedDirPath : 'path::exported.dir.export.',
        exportedFilesPath : 'path::exported.files.export.',
        archiveFilePath : 'path::archiveFile.export.',
      },
    }
    test.identical( outfile.exported, exported );

    var exportedReflector =
    {
      'mandatory' : 1,
      'src' :
      {
        'filePath' : { '**' : '' },
        'prefixPath' : 'debug',
      },
      criterion :
      {
        default : 1,
        debug : 1,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }
    test.identical( outfile.reflector[ 'exported.export.debug' ], exportedReflector );
    // logger.log( _.toJson( outfile.reflector[ 'exported.export.debug' ] ) );

    var exportedReflector =
    {
      'mandatory' : 1,
      src :
      {
        // 'filePath' : { '.' : '' },
        'filePath' : { '**' : '' },
        'prefixPath' : 'release'
      },
      criterion :
      {
        default : 1,
        debug : 0,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }
    // logger.log( _.toJson( outfile.reflector[ 'exported.export.' ] ) );
    test.identical( outfile.reflector[ 'exported.export.' ], exportedReflector );

    var exportedReflectorFiles =
    {
      recursive : 0,
      mandatory : 1,
      src :
      {
        filePath : { 'path::exported.files.export.debug' : '' },
        basePath : '.',
        prefixPath : 'path::exported.dir.export.debug',
        recursive : 0,
      },
      criterion :
      {
        default : 1,
        debug : 1,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }

    test.identical( outfile.reflector[ 'exported.files.export.debug' ], exportedReflectorFiles );

    var exportedReflectorFiles =
    {
      recursive : 0,
      mandatory : 1,
      src :
      {
        filePath : { 'path::exported.files.export.' : '' },
        basePath : '.',
        prefixPath : 'path::exported.dir.export.',
        recursive : 0,
      },
      criterion :
      {
        default : 1,
        debug : 0,
        raw : 1,
        export : 1,
        generated : 1,
      }
    }

    test.identical( outfile.reflector[ 'exported.files.export.' ], exportedReflectorFiles );

    let outfilePath =
    {
      "module.willfiles" :
      {
        "path" : "submodule.out.will.yml",
        "criterion" : { "predefined" : 1 }
      },
      "module.original.willfiles" :
      {
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ],
        "criterion" : { "predefined" : 1 }
      },
      "module.peer.willfiles" :
      {
        "path" : [ "../.ex.will.yml", "../.im.will.yml" ],
        "criterion" : { "predefined" : 1 }
      },
      "download" :
      {
        "criterion" : { "predefined" : 1 }
      },
      "module.common" :
      {
        "path" : "submodule.out",
        "criterion" : { "predefined" : 1 }
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "proto" : { "path" : "../proto" },
      "temp" : { "path" : "." },
      "in" :
      {
        "path" : ".",
      },
      "out" :
      {
        "path" : ".",
      },
      "out.debug" :
      {
        "path" : "debug",
        "criterion" : { "debug" : 1 }
      },
      "out.release" :
      {
        "path" : "release",
        "criterion" : { "debug" : 0 }
      },
      "exported.dir.export.debug" :
      {
        "path" : "debug",
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "exported.files.export.debug" :
      {
        "path" : [ "debug", "debug/File.debug.js" ],
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "archiveFile.export.debug" :
      {
        "path" : "submodule.debug.out.tgs",
        "criterion" :
        {
          "default" : 1,
          "debug" : 1,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "exported.dir.export." :
      {
        "path" : "release",
        "criterion" :
        {
          "default" : 1,
          "debug" : 0,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "exported.files.export." :
      {
        "path" : [ "release", "release/File.release.js" ],
        "criterion" :
        {
          "default" : 1,
          "debug" : 0,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      "archiveFile.export." :
      {
        "path" : "submodule.out.tgs",
        "criterion" :
        {
          "default" : 1,
          "debug" : 0,
          "raw" : 1,
          "export" : 1,
          "generated" : 1,
        }
      },
      'module.peer.in' :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      },
    }
    test.identical( outfile.path, outfilePath );
    // logger.log( _.toJson( outfile.path ) );

    return null;
  })

  /* - */

  return ready;
}

exportMultiple.timeOut = 200000;

//

function exportImportMultiple( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-multiple' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );
  let out2Path = _.path.join( routinePath, 'super.out' );
  let outWillPath = _.path.join( outPath, 'submodule.out.will.yml' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = 'export submodule';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );

    return null;
  })

  start({ execPath : '.with . .export debug:0' })
  start({ execPath : '.with . .export debug:1' })

  .then( ( got ) =>
  {

    var files = self.find( outPath );
    test.identical( files, [ '.', './submodule.debug.out.tgs', './submodule.out.tgs', './submodule.out.will.yml', './debug', './debug/File.debug.js', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Exported module::submodule / build::export.debug with 2 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .export debug:0';

    _.fileProvider.filesDelete( out2Path );

    return null;
  })

  start({ execPath : '.with super .export debug:0' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [ '.', './supermodule.out.tgs', './supermodule.out.will.yml', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Exported module::supermodule / build::export. with 2 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .clean dry:1';
    return null;
  })

  start({ execPath : '.with super .clean dry:1' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [ '.', './supermodule.out.tgs', './supermodule.out.will.yml', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '5 at ' ) );
    test.is( _.strHas( got.output, 'Clean will delete 5 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .clean';
    return null;
  })

  start({ execPath : '.with super .clean' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted 5 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .export debug:0 ; .with super .export debug:1';

    _.fileProvider.filesDelete( out2Path );

    return null;
  })

  start({ execPath : '.with super .export debug:0' })
  start({ execPath : '.with super .export debug:1' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [ '.', './supermodule.debug.out.tgs', './supermodule.out.tgs', './supermodule.out.will.yml', './debug', './debug/File.debug.js', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Exported module::supermodule / build::export.debug with 2 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .clean dry:1';
    return null;
  })

  start({ execPath : '.with super .clean dry:1' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [ '.', './supermodule.debug.out.tgs', './supermodule.out.tgs', './supermodule.out.will.yml', './debug', './debug/File.debug.js', './release', './release/File.release.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '8 at ' ) );
    test.is( _.strHas( got.output, 'Clean will delete 8 file(s)' ) );

    return null;
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with super .clean';
    return null;
  })

  start({ execPath : '.with super .clean' })

  .then( ( got ) =>
  {

    var files = self.find( out2Path );
    test.identical( files, [] );
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted 8 file(s)' ) );

    return null;
  })

  /* - */

  return ready;
}

exportImportMultiple.timeOut = 200000;

//

function exportBroken( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-multiple-broken' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );
  let outWillPath = _.path.join( outPath, 'submodule.out.will.yml' );

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.export debug:1';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  })

  debugger;
  start({ execPath : '.export debug:1' })

  .then( ( got ) =>
  {

    var files = self.find( outPath );
    test.identical( files, [ '.', './submodule.debug.out.tgs', './submodule.out.will.yml', './debug', './debug/File.debug.js' ] );
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( _.path.join( outPath, 'debug' ) ) );
    test.is( !_.fileProvider.fileExists( _.path.join( outPath, 'release' ) ) );

    test.is( _.strHas( got.output, 'submodule.debug.out.tgs' ) );
    test.is( _.strHas( got.output, 'out/submodule.out.will.yml' ) );

    var outfile = _.fileProvider.fileConfigRead( outWillPath );
    outfile = outfile.module[ 'submodule.out' ];

    var exported =
    {
      'export.debug' :
      {
        version : '0.0.1',
        recursive : 0,
        withIntegrated : 2,
        tar : 1,
        criterion :
        {
          default : 1,
          debug : 1,
          raw : 1,
          export : 1
        },
        exportedReflector : 'reflector::exported.export.debug',
        exportedFilesReflector : 'reflector::exported.files.export.debug',
        exportedDirPath : 'path::exported.dir.export.debug',
        exportedFilesPath : 'path::exported.files.export.debug',
        archiveFilePath : 'path::archiveFile.export.debug',
      }
    }

    test.identical( outfile.exported, exported );

    var exportedReflector =
    {
      'mandatory' : 1,
      src :
      {
        // filePath : { '.' : '' },
        filePath : { '**' : '' },
        prefixPath : 'debug'
      },
      criterion :
      {
        generated : 1,
        default : 1,
        debug : 1,
        raw : 1,
        export : 1
      }
    }
    test.identical( outfile.reflector[ 'exported.export.debug' ], exportedReflector );

    var exportedReflectorFiles =
    {
      recursive : 0,
      mandatory : 1,
      src :
      {
        filePath : { 'path::exported.files.export.debug' : '' },
        basePath : '.',
        prefixPath : 'path::exported.dir.export.debug',
        recursive : 0,
      },
      criterion :
      {
        generated : 1,
        default : 1,
        debug : 1,
        raw : 1,
        export : 1
      }
    }

    test.identical( outfile.reflector[ 'exported.files.export.debug' ], exportedReflectorFiles );

    return null;
  })

  return ready;
}

//

function exportDoc( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-multiple-doc' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let subOutPath = _.path.join( routinePath, 'out' );
  let supOutPath = _.path.join( routinePath, 'doc.out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = 'export submodule';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( subOutPath );
    _.fileProvider.filesDelete( supOutPath );

    return null;
  })

  start({ execPath : '.with . .export export.doc' })
  start({ execPath : '.with . .export export.debug' })
  start({ execPath : '.with . .export export.' })
  start({ execPath : '.with doc .build doc:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( subOutPath );
    test.identical( files, [ '.', './submodule.default-debug-raw.out.tgs', './submodule.default-raw.out.tgs', './submodule.out.will.yml', './debug', './debug/File.debug.js', './release', './release/File.release.js' ] );

    var files = self.find( supOutPath );
    test.identical( files, [ '.', './file.md' ] );

    return null;
  })

  /* - */

  return ready;
}

exportDoc.timeOut = 200000;

//

function exportImport( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'super.out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export'
    _.fileProvider.filesDelete( outPath );
    return null;
  })

  start({ execPath : '.with super .export debug:0' })
  start({ execPath : '.with super .export debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = _.fileProvider.dirRead( outPath );
    test.identical( files, [ 'debug', 'release', 'supermodule.out.will.yml' ] );

    return null;
  })

  return ready;
}

exportImport.timeOut = 200000;

//

function exportBrokenNoreflector( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-broken-noreflector' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with submodule .reflectors.list predefined:0'
    return null;
  })

  start({ execPath : '.with submodule .reflectors.list predefined:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::' ), 2 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::reflect.proto' ), 1 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::exported.files.export' ), 1 );
    return null;
  })

  start({ execPath : '.with module/submodule .export' })
  start({ execPath : '.with submodule .reflectors.list predefined:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::' ), 3 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::reflect.proto' ), 1 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::exported.export' ), 1 );
    test.identical( _.strCount( got.output, 'module::submodule / reflector::exported.files.export' ), 1 );
    return null;
  })

  return ready;
} /* end of function exportBrokenNoreflector */

exportBrokenNoreflector.description =
`
removed reflector::exported.export is not obstacle to list out file
`

exportBrokenNoreflector.timeOut = 500000;

//

function exportCourrputedOutfileUnknownSection( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'corrupted-outfile-unknown-section' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'sub.out' );
  let outFilePath = _.path.join( routinePath, 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with sub .export debug:1';
    return null;
  })

  start( '.with sub .export debug:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './sub.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    outfile = outfile.module[ 'sub.out' ];
    var exported = _.mapKeys( _.select( outfile, 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    test.identical( _.strCount( got.output, '. Read 2 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, '! Failed to open .' ), 2 );
    test.identical( _.strCount( got.output, 'Failed to open willfile' ), 1 );
    test.identical( _.strCount( got.output, 'Out-willfile should not have section(s) : "unknown_section"' ), 1 );
    test.identical( _.strCount( got.output, /Exported module::sub \/ build::export.debug with .* file\(s\) in .*/ ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportCourrputedOutfileUnknownSection */

//

function exportCourruptedOutfileSyntax( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'corrupted-outfile-syntax' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'sub.out' );
  let outFilePath = _.path.join( routinePath, 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with sub .export debug:1';
    return null;
  })

  start( '.with sub .export debug:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './sub.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    outfile = outfile.module[ 'sub.out' ]
    var exported = _.mapKeys( _.select( outfile, 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    test.identical( _.strCount( got.output, '. Read 2 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, '! Failed to open .' ), 2 );
    test.identical( _.strCount( got.output, 'Failed to open willfile' ), 1 );
    test.identical( _.strCount( got.output, 'Failed to convert from "string" to "structure" by encoder yaml-string->structure' ), 1 );
    test.identical( _.strCount( got.output, /Exported .*module::sub \/ build::export.debug.*/ ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportCourruptedOutfileSyntax */

//

function exportCourruptedSubmodulesDisabled( test )
{
  let self = this;
  let a = self.assetFor( test, 'corrupted-submodules-disabled' );
  let outPath = a.abs( 'super.out' );
  let outFilePath = a.abs( 'super.out/supermodule.out.will.yml' );

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with super .export debug:1';
    return null;
  })

  a.start( '.with super .export debug:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './supermodule.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    var exported = _.mapKeys( _.select( outfile.module[ outfile.root[ 0 ] ], 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    test.identical( _.strCount( got.output, '. Read 2 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 3 file(s) in' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportCourruptedSubmodulesDisabled */

//

function exportDisabledModule( test )
{
  let self = this;
  let a = self.assetFor( test, 'export-disabled-module' );
  let willfPath = a.abs( './' );
  let outFilePath = a.abs( 'out/disabled.out.will.yml' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.export';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    var exp = [ 'disabled.out', '../', '../.module/Tools/', '../.module/Tools/out/wTools.out', '../.module/PathBasic/', '../.module/PathBasic/out/wPathBasic.out' ];
    var got = _.mapKeys( outfile.module );
    test.setsAreIdentical( got, exp );

    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with . .export';
    a.reflect();
    return null;
  })

  a.start( '.with . .export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    var exp = [ 'disabled.out', '../', '../.module/Tools/', '../.module/Tools/out/wTools.out', '../.module/PathBasic/', '../.module/PathBasic/out/wPathBasic.out' ];
    var got = _.mapKeys( outfile.module );
    test.setsAreIdentical( got, exp );

    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with * .export';
    a.reflect();
    return null;
  })

  a.startNonThrowing( '.with * .export' )

  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );

    var exp = [ 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );

    test.identical( _.strCount( op.output, 'No module sattisfy' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.imply withDisabled:1; .with * .export';
    a.reflect();
    return null;
  })

  a.startNonThrowing( '.imply withDisabled:1; .with * .export' )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp = [ '.module', 'out', 'will.yml' ];
    var files = _.fileProvider.dirRead( a.routinePath );
    test.identical( files, exp );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    var exp = [ 'disabled.out', '../', '../.module/Tools/', '../.module/Tools/out/wTools.out', '../.module/PathBasic/', '../.module/PathBasic/out/wPathBasic.out' ];
    var got = _.mapKeys( outfile.module );
    test.setsAreIdentical( got, exp );

    test.identical( _.strCount( op.output, 'Exported module::disabled / build::proto.export' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportDisabledModule */

exportDisabledModule.timeOut = 300000;
exportDisabledModule.description =
`
- disabled module should be exported if picked explicitly
- disabled module should not be exported if picked with glob
`

//

function exportOutdated( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'inconsistent-outfile' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'sub.out' );
  let outFilePath = _.path.join( routinePath, 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with sub .export debug:1';
    return null;
  })

  start( '.with sub .export debug:1' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './sub.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    outfile = outfile.module[ 'sub.out' ];
    var exported = _.mapKeys( _.select( outfile, 'exported/*' ) );
    var exp = [ 'export.debug' ];
    test.setsAreIdentical( exported, exp );

    test.identical( _.strCount( got.output, '. Read 2 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, /Exported .*module::sub \/ build::export.debug.*/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = 'export release, but input willfile is changed';
    _.fileProvider.fileAppend( _.path.join( routinePath, 'sub.ex.will.yml' ), '\n' );
    return null;
  })

  start( '.with sub .export debug:0' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var files = self.find( outPath );
    test.identical( files, [ '.', './sub.out.will.yml' ] );

    var outfile = _.fileProvider.fileConfigRead( outFilePath );
    outfile = outfile.module[ 'sub.out' ];
    var exported = _.mapKeys( _.select( outfile, 'exported/*' ) );
    var exp = [ 'export.' ];
    test.setsAreIdentical( exported, exp );

    test.identical( _.strCount( got.output, '. Read 2 willfile(s)' ), 1 );
    test.identical( _.strCount( got.output, '! Outdated .' ), 2 );
    test.identical( _.strCount( got.output, 'Failed to open willfile' ), 0 );
    test.identical( _.strCount( got.output, 'Out-willfile is inconsistent with its in-willfiles' ), 0 );
    test.identical( _.strCount( got.output, /Exported .*module::sub \/ build::export.*/ ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportOutdated */

//

function exportWholeModule( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-whole' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export whole module using in path'
    return null;
  })

  start({ execPath : '.with module/ .export' })
  start({ execPath : '.build' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    var files = self.find( outPath );
    test.identical( files, [ '.', './.will.yml', './proto', './proto/File1.s', './proto/dir', './proto/dir/File2.s' ] );
    return null;
  })

  /* - */

  return ready;
} /* end of function exportWholeModule */

//

function exportRecursive( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'resolve-path-of-submodules-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( 'ab/' );
  let outTerminalPath = abs( 'out/ab/module-ab.out.will.yml' );
  let outDirPath = abs( 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with ab/ .export.recursive -- first'
    return null;
  })

  start({ execPath : '.with ab/ .export.recursive' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp = [ '.', './module-a.out.will.yml', './module-b.out.will.yml', './ab', './ab/module-ab.out.will.yml' ];
    var files = self.find( outDirPath );
    test.identical( files, exp )

    test.identical( _.strCount( got.output, 'Exported module::module-ab / module::module-a / build::proto.export with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::module-ab / module::module-b / build::proto.export with 8 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::module-ab / build::proto.export with 13 file(s) in' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with ab/ .export.recursive -- second'
    return null;
  })

  start({ execPath : '.with ab/ .export.recursive' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp = [ '.', './module-a.out.will.yml', './module-b.out.will.yml', './ab', './ab/module-ab.out.will.yml' ];
    var files = self.find( outDirPath );
    test.identical( files, exp )

    test.identical( _.strCount( got.output, 'Exported module::module-ab / module::module-a / build::proto.export with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::module-ab / module::module-b / build::proto.export with 8 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::module-ab / build::proto.export with 13 file(s) in' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportRecursive */

//

function exportRecursiveUsingSubmodule( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-multiple-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( 'super' );
  let outSuperDirPath = abs( 'super.out' );
  let outSubDirPath = abs( 'sub.out' );
  let outSuperTerminalPath = abs( 'super.out/supermodule.out.will.yml' );
  let outSubTerminalPath = abs( 'sub.out/submodule.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outSuperDirPath );
  _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with super .export.recursive debug:1 -- first'
    return null;
  })

  start({ execPath : '.with super .export.recursive debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/submodule.debug.out.tgs',
      './sub.out/submodule.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './super.out',
      './super.out/supermodule.debug.out.tgs',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::submodule / build::export.debug with 2 file(s)' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 2 file(s) in' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with super .export.recursive debug:1 -- second'
    return null;
  })

  start({ execPath : '.with super .export.recursive debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/submodule.debug.out.tgs',
      './sub.out/submodule.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './super.out',
      './super.out/supermodule.debug.out.tgs',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::submodule / build::export.debug with 2 file(s)' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 2 file(s) in' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with super .export.recursive debug:0 -- first'
    return null;
  })

  start({ execPath : '.with super .export.recursive debug:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/submodule.debug.out.tgs',
      './sub.out/submodule.out.tgs',
      './sub.out/submodule.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './sub.out/release',
      './sub.out/release/File.release.js',
      './super.out',
      './super.out/supermodule.debug.out.tgs',
      './super.out/supermodule.out.tgs',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/release',
      './super.out/release/File.release.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::submodule / build::export. with 2 file(s)' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export. with 2 file(s) in' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with super .export.recursive debug:0 -- second'
    return null;
  })

  start({ execPath : '.with super .export.recursive debug:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './super.ex.will.yml',
      './super.im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub.out',
      './sub.out/submodule.debug.out.tgs',
      './sub.out/submodule.out.tgs',
      './sub.out/submodule.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './sub.out/release',
      './sub.out/release/File.release.js',
      './super.out',
      './super.out/supermodule.debug.out.tgs',
      './super.out/supermodule.out.tgs',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/release',
      './super.out/release/File.release.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::submodule / build::export. with 2 file(s)' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export. with 2 file(s) in' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportRecursiveUsingSubmodule */

exportRecursiveUsingSubmodule.timeOut = 300000;

//

function exportRecursiveLocal( test )
{
  let self = this;
  let a = self.assetFor( test, 'export-with-submodules' );

  // let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules' );
  // let routinePath = _.path.join( self.suiteTempPath, test.name );
  // let abs = self.abs_functor( routinePath );
  // let rel = self.rel_functor( routinePath );
  // let submodulesPath = _.path.join( routinePath, '.module' );
  // let outPath = _.path.join( routinePath, 'out' );
  //
  // let ready = new _.Consequence().take( null );
  // let start = _.process.starter
  // ({
  //   execPath : 'node ' + self.willPath,
  //   currentPath : routinePath,
  //   outputCollecting : 1,
  //   outputGraying : 1,
  //   mode : 'spawn',
  //   ready : ready,
  // })
  //
  // _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  a.reflect();

  /* - */

  a.start({ execPath : '.with */* .clean' })
  a.start({ execPath : '.with */* .export' })

  .finally( ( err, got ) =>
  {
    test.case = 'first';

    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 9 );
    return null;
  })

  a.start({ execPath : '.with ab/ .resources.list' })
  .finally( ( err, got ) =>
  {
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.identical( _.strCount( got.output, 'About' ), 1 );
    test.identical( _.strCount( got.output, 'module::module-ab / path::export' ), 1 );
    test.identical( _.strCount( got.output, 'module::module-ab /' ), 52 );

    return null;
  })

  /* - */

  a.start({ execPath : '.with */* .export' })
  .finally( ( err, got ) =>
  {
    test.case = 'second';
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 15 );
    return null;
  })

  a.start({ execPath : '.with ab/ .resources.list' })
  .finally( ( err, got ) =>
  {
    test.is( !err );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );

    test.identical( _.strCount( got.output, 'About' ), 1 );
    test.identical( _.strCount( got.output, 'module::module-ab / path::export' ), 1 );
    test.identical( _.strCount( got.output, 'module::module-ab /' ), 52 );

    return null;
  })

  /* - */

  return a.ready;
} /* end of function exportRecursiveLocal */

exportRecursiveLocal.timeOut = 300000;

//

function exportDotless( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( './' );
  let outSuperDirPath = abs( 'super.out' );
  let outSubDirPath = abs( 'sub.out' );
  let outSuperTerminalPath = abs( 'super.out/supermodule.out.will.yml' );
  let outSubTerminalPath = abs( 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outSuperDirPath );
  _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export.recursive debug:1'
    return null;
  })

  start({ execPath : '.export.recursive debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './super.out',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/debug/File.release.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::sub / build::export.debug with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 3 file(s) in' ), 1 );

    return null;
  })

  .then( () =>
  {
    test.case = '.with . .export.recursive debug:0'
    return null;
  })

  start({ execPath : '.with . .export.recursive debug:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './ex.will.yml',
      './im.will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/ex.will.yml',
      './sub/im.will.yml',
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
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::sub / build::export. with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export. with 3 file(s) in' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportDotless */

exportDotless.timeOut = 300000;

//

function exportDotlessSingle( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-single-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( './' );
  let outSuperDirPath = abs( 'super.out' );
  let outSubDirPath = abs( 'sub.out' );
  let outSuperTerminalPath = abs( 'super.out/supermodule.out.will.yml' );
  let outSubTerminalPath = abs( 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outSuperDirPath );
  _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export.recursive debug:1'
    return null;
  })

  start({ execPath : '.export.recursive debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/will.yml',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './super.out',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/debug/File.release.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::sub / build::export.debug with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 3 file(s) in' ), 1 );

    return null;
  })

  .then( () =>
  {
    test.case = '.with . .export.recursive debug:0'
    return null;
  })

  start({ execPath : '.with . .export.recursive debug:0' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/will.yml',
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
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::sub / build::export. with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export. with 3 file(s) in' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportDotlessSingle */

exportDotlessSingle.timeOut = 300000;

//

function exportTracing( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'two-dotless-single-exported' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let inPath = abs( './' );
  let outSuperDirPath = abs( 'super.out' );
  let outSubDirPath = abs( 'sub.out' );
  let outSuperTerminalPath = abs( 'super.out/supermodule.out.will.yml' );
  let outSubTerminalPath = abs( 'sub.out/sub.out.will.yml' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath + '/proto',
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
  _.fileProvider.filesDelete( outSuperDirPath );
  _.fileProvider.filesDelete( outSubDirPath );

  /* - */

  ready

  .then( () =>
  {
    test.case = '.export.recursive debug:1'
    return null;
  })

  start({ execPath : '.export.recursive debug:1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.description = 'files';
    var exp =
    [
      '.',
      './will.yml',
      './proto',
      './proto/File.debug.js',
      './proto/File.release.js',
      './sub',
      './sub/will.yml',
      './sub.out',
      './sub.out/sub.out.will.yml',
      './sub.out/debug',
      './sub.out/debug/File.debug.js',
      './super.out',
      './super.out/supermodule.out.will.yml',
      './super.out/debug',
      './super.out/debug/File.debug.js',
      './super.out/debug/File.release.js'
    ]
    var files = self.find({ filePath : { [ routinePath ] : '', '**/+**' : 0 } });
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported module::supermodule / module::sub / build::export.debug with 2 file(s) in' ), 1 );
    test.identical( _.strCount( got.output, 'Exported module::supermodule / build::export.debug with 3 file(s) in' ), 1 );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = '.with . .export.recursive debug:1'
    return null;
  })

  start({ execPath : '.with . .export.recursive debug:1' })

  .finally( ( err, op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'No module sattisfy criteria' ), 1 );
    _.errAttend( err );
    return null;
  })

  /* - */

  return ready;
} /* end of function exportTracing */

exportTracing.timeOut = 300000;

//

function exportRewritesOutFile( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-rewrites-out-file' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );

  let ready = new _.Consequence().take( null );
  let outFilePath = _.path.join( routinePath, 'out/export-rewrites-out-file.out.will.yml' );
  let willFilePath = _.path.join( routinePath, '.will.yml' );
  let willSingleExportFilePath = _.path.join( routinePath, '.will.single-export.yml' );
  let willCopyFilePath = _.path.join( routinePath, 'copy.will.yml' );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.fileCopy( willCopyFilePath, willFilePath );

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export module with two exports'
    return null;
  })

  start({ execPath : '.export export1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( outFilePath ) );
    let outFile = _.fileProvider.fileRead({ filePath : outFilePath, encoding : 'yaml' });
    let build = outFile.module[ outFile.root[ 0 ] ].build;
    test.identical( _.mapKeys( build ), [ 'export1', 'export2' ] );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'remove second export build then export again';
    _.fileProvider.fileCopy( willFilePath, willSingleExportFilePath )
    return null;
  })

  start({ execPath : '.export export1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( outFilePath ) );
    let outFile = _.fileProvider.fileRead({ filePath : outFilePath, encoding : 'yaml' });
    let build = outFile.module[ outFile.root[ 0 ] ].build;
    test.identical( _.mapKeys( build ), [ 'export1' ] );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'restore second export, then export again';
    _.fileProvider.fileCopy( willFilePath, willCopyFilePath )
    return null;
  })

  start({ execPath : '.export export1' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( outFilePath ) );
    let outFile = _.fileProvider.fileRead({ filePath : outFilePath, encoding : 'yaml' });
    let build = outFile.module[ outFile.root[ 0 ] ].build;
    test.identical( _.mapKeys( build ), [ 'export1', 'export2' ] );
    return null;
  })

  /* - */

  return ready;
}

exportRewritesOutFile.timeOut = 30000;

//

function exportWithRemoteSubmodules( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export'
    return null;
  })

  start( '.with group1/group10/a0 .clean' )
  start( '.with group1/a .clean' )
  start( '.with group1/b .clean' )
  start( '.with group2/c .clean' )
  start( '.with group1/group10/a0 .export' )
  start( '.with group1/a .export' )
  start( '.with group1/b .export' )
  start( '.with group2/c .export' )
  start( '.with z .export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 31 );
    test.identical( _.strCount( got.output, '+ 1/4 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportWithRemoteSubmodules */

exportWithRemoteSubmodules.timeOut = 300000;
exportWithRemoteSubmodules.description =
`
check there is no annoying information about lack of remote submodules of submodules
`

//

function exportDiffDownloadPathsRegular( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-diff-download-paths-regular' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .export.recursive';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    var exp = [ 'a.out.will.yml', 'c.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'out' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
    test.identical( _.strCount( got.output, '. Opened .' ), 36 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 6 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 10 );
    test.identical( _.strCount( got.output, '+ 6/7 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  a.start( '.with c .export.recursive' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    var exp = [ 'a.out.will.yml', 'c.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'out' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 38 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 10 );
    test.identical( _.strCount( got.output, 'submodule(s) of' ), 0 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportDiffDownloadPathsRegular */

exportDiffDownloadPathsRegular.timeOut = 300000;

//

function exportHierarchyRemote( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .export.recursive';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with z .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );
    var exp = [ 'debug', 'z.out.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( 'out' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );
    var exp = [ 'a.out.will.yml', 'b.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/out' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );
    var exp = [ 'a0.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/out' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );
    var exp = [ 'c.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/out' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 38 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 5 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 12 );
    test.identical( _.strCount( got.output, '+ 5/9 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'module::z were downloaded' ), 2 );
    test.identical( _.strCount( got.output, 'were downloaded' ), 6 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .export.recursive';
    a.reflect();
    return null;
  })

  a.start( '.with ** .clean recursive:2' )
  a.start( '.with ** .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );
    var exp = [ 'debug', 'z.out.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( 'out' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );
    var exp = [ 'a.out.will.yml', 'b.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/out' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );
    var exp = [ 'a0.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/out' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );
    var exp = [ 'c.out.will.yml', 'debug' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/out' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 38 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 5 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 12 );
    test.identical( _.strCount( got.output, 'module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'were downloaded' ), 9 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportHierarchyRemote */

exportHierarchyRemote.timeOut = 300000;
exportHierarchyRemote.description =
`
- "with module .export.recursive" should export the same number of modules as "with ** .export.recursive"
- each format of recursive export command should export each instance of each module exactly one time
- each instance of a module is exported once even if module has several instances in different location
`

//

function exportWithDisabled( test )
{
  let self = this;
  let a = self.assetFor( test, 'broken-out' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.imply withDisabled:1 ; .with */* .export.recursive';
    a.reflect();
    return null;
  })

  a.start( '.imply withDisabled:1 ; .with */* .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './module1',
      './module1/.ex.will.yml',
      './module1/.im.will.yml',
      './module1/out',
      './module1/out/module1.out.will.yml',
      './module1/proto',
      './module1/proto/File1.txt',
      './module2',
      './module2/will.yml',
      './module2/out',
      './module2/out/module2.out.will.yml'
    ];
    var files = self.find( a.abs( '.' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported' ), 2 );
    test.identical( _.strCount( got.output, 'ncaught' ), 0 );
    test.identical( _.strHas( got.output, '! Outdated' ), true );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.imply withDisabled:0 ; .with */* .export.recursive';
    a.reflect();
    _.fileProvider.filesDelete( a.abs( 'module1/out' ) );
    return null;
  })

  a.start( '.imply withDisabled:0 ; .with */* .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './module1',
      './module1/.ex.will.yml',
      './module1/.im.will.yml',
      './module1/proto',
      './module1/proto/File1.txt',
      './module2',
      './module2/will.yml',
      './module2/out',
      './module2/out/module2.out.will.yml'
    ];
    var files = self.find( a.abs( '.' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported' ), 1 );
    test.identical( _.strCount( got.output, 'ncaught' ), 0 );
    test.identical( _.strHas( got.output, '! Outdated' ), false );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.imply withDisabled:0 ; .with */* .export';
    a.reflect();
    _.fileProvider.filesDelete( a.abs( 'module1/out' ) );
    return null;
  })

  a.start( '.imply withDisabled:0 ; .with */* .export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './module1',
      './module1/.ex.will.yml',
      './module1/.im.will.yml',
      './module1/proto',
      './module1/proto/File1.txt',
      './module2',
      './module2/will.yml',
      './module2/out',
      './module2/out/module2.out.will.yml'
    ];
    var files = self.find( a.abs( '.' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported' ), 1 );
    test.identical( _.strCount( got.output, 'ncaught' ), 0 );
    test.identical( _.strHas( got.output, '! Outdated' ), false );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with */* .export.recursive';
    a.reflect();
    _.fileProvider.filesDelete( a.abs( 'module1/out' ) );
    return null;
  })

  a.start( '.with */* .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './module1',
      './module1/.ex.will.yml',
      './module1/.im.will.yml',
      './module1/proto',
      './module1/proto/File1.txt',
      './module2',
      './module2/will.yml',
      './module2/out',
      './module2/out/module2.out.will.yml'
    ];
    var files = self.find( a.abs( '.' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, 'Exported' ), 1 );
    test.identical( _.strCount( got.output, 'ncaught' ), 0 );
    test.identical( _.strHas( got.output, '! Outdated' ), false );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportWithDisabled */

exportWithDisabled.timeOut = 300000;

//

function exportOutResourceWithoutGeneratedCriterion( test )
{
  let self = this;
  let a = self.assetFor( test, 'export-out-resource-without-generated-criterion' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .submodules.download';
    a.reflect();
    return null;
  })

  a.start( '.export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'nhandled' ), 0 );
    test.identical( _.strCount( got.output, 'Exported module::' ), 1 );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'debug', 'wChangeTransactor.out.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( 'out' ) )
    test.identical( files, exp );

    var outfile = _.fileProvider.fileConfigRead( a.abs( 'out/wChangeTransactor.out.will.yml' ) );
    var exp =
    [
      'module.willfiles',
      'module.common',
      'module.original.willfiles',
      'module.peer.willfiles',
      'module.peer.in',
      'download',
      'repository',
      'origins',
      'bugs',
      'in',
      'temp',
      'out',
      'out.debug',
      'out.release',
      'proto',
      'export',
      'exported.dir.proto.export',
      'exported.files.proto.export',
      'exported.dir.proto.export.1',
      'exported.files.proto.export.1'
    ]
    var got = _.mapKeys( outfile.module[ 'wChangeTransactor.out' ].path );
    test.identical( _.setFrom( got ), _.setFrom( exp ) );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportOutResourceWithoutGeneratedCriterion */

exportOutResourceWithoutGeneratedCriterion.timeOut = 100000;

//

function exportWillAndOut( test )
{
  let self = this;
  let a = self.assetFor( test, 'export-will-and-out' ); xxx

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .export.recursive';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '+ 6/7 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function exportWillAndOut */

exportWillAndOut.timeOut = 300000;

//

function exportAuto( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-auto' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export'
    return null;
  })

  start( '.clean' )
  start( '.with submodule/* .export' )
  start( '.with manual .export' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './auto.will.yml',
      './manual.will.yml',
      './will.yml',
      './.module',
      './.module/LocalModule.manual.out.will.yml',
      './.module/RemoteModule.manual.out.will.yml',
      './.module/RemoteModule.manual',
      './.module/RemoteModule.manual/README.md',
      './.module/RemoteModule.manual/dir',
      './.module/RemoteModule.manual/dir/SecondFile.md',
      './local',
      './local/LocalFile.txt',
      './out',
      './out/manual.out.will.yml',
      './out/files',
      './out/files/LocalFile.txt',
      './out/files/README.md',
      './out/files/dir',
      './out/files/dir/SecondFile.md',
      './submodule',
      './submodule/local.will.yml',
      './submodule/remote.will.yml'
    ]
    var files = self.find( routinePath );
    test.contains( files, exp );

    return null;
  })

  /* - */

  ready

  .then( () =>
  {
    test.case = 'export'
    return null;
  })

  start( '.clean' )
  start( '.with auto .export.recursive' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp =
    [
      '.',
      './auto.will.yml',
      './manual.will.yml',
      './will.yml',
      './.module',
      './.module/LocalModule.manual.out.will.yml',
      './.module/RemoteModule.manual.out.will.yml',
      './.module/RemoteModule.manual',
      './.module/RemoteModule.manual/README.md',
      './.module/RemoteModule.manual/dir',
      './.module/RemoteModule.manual/dir/SecondFile.md',
      './local',
      './local/LocalFile.txt',
      './out',
      './out/manual.out.will.yml',
      './out/files',
      './out/files/LocalFile.txt',
      './out/files/README.md',
      './out/files/dir',
      './out/files/dir/SecondFile.md',
      './submodule',
      './submodule/local.will.yml',
      './submodule/remote.will.yml'
    ]
    var files = self.find( routinePath );
    test.contains( files, exp );

    return null;
  })

  /* - */

  return ready;
} /* end of function exportAuto */

exportAuto.timeOut = 300000;
exportAuto.description =
`
- auto export works similar to manual export
`

//

/*
Import out file with non-importable path local.
Test importing of non-valid out files.
Test redownloading of currupted remote submodules.
*/

function importPathLocal( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'import-path-local' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = 'export submodule';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesDelete( outPath );

    return null;
  })

  start({ execPath : '.build' })

  .then( ( got ) =>
  {

    var files = self.find( outPath );
    test.contains( files, [ '.', './debug', './debug/WithSubmodules.s', './debug/dwtools', './debug/dwtools/Tools.s' ] );
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, /Built .*module::submodules \/ build::debug\.raw.* in/ ), 1 );

    return null;
  })

  /* - */

  return ready;
}

importPathLocal.timeOut = 200000;

//

function importLocalRepo( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'import-auto' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let repoPath = _.path.join( self.suiteTempPath, '_repo' );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = '.with module/Proto .export';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
    _.fileProvider.filesReflect({ reflectMap : { [ self.repoDirPath ] : repoPath } });

    return null;
  })

  start({ execPath : '.with module/Proto .clean' })
  start({ execPath : '.with module/Proto .export' })

  .then( ( got ) =>
  {

    var files = _.fileProvider.dirRead( modulePath );
    test.identical( files, [ 'Proto', 'Proto.out.will.yml' ] );

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, /\+ reflector::download reflected .* file\(s\)/ ), 1 );
    test.identical( _.strCount( got.output, /Write out willfile .*\/.module\/Proto.out.will.yml/ ), 1 );

    var outfile = _.fileProvider.fileConfigRead( _.path.join( modulePath, 'Proto.out.will.yml' ) );
    outfile = outfile.module[ 'Proto.out' ]

    var expectedReflector =
    {
      "download" :
      {
        "src" :
        {
          "filePath" : { "." : `.` },
          "prefixPath" : `path::remote`
        },
        "dst" : { "prefixPath" : `path::download` },
        "mandatory" : 1
      },
      "exported.export" :
      {
        "src" :
        {
          "filePath" : { "**" : `` },
          "prefixPath" : `Proto/proto`
        },
        "mandatory" : 1,
        "criterion" : { "default" : 1, "export" : 1, 'generated' : 1 }
      },
      "exported.files.export" :
      {
        "src" :
        {
          "filePath" : { "path::exported.files.export" : `` },
          "basePath" : `.`,
          "prefixPath" : `path::exported.dir.export`,
          "recursive" : 0
        },
        "recursive" : 0,
        "mandatory" : 1,
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 }
      }
    }
    test.identical( outfile.reflector, expectedReflector );

    var expectedPath =
    {
      "module.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.out.will.yml`
      },
      "module.common" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `Proto.out`
      },
      "module.original.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.will.yml`
      },
      "module.peer.willfiles" :
      {
        "criterion" : { "predefined" : 1 },
        "path" : `../module/Proto.will.yml`
      },
      "in" :
      {
        "path" : `.`
      },
      "out" :
      {
        "path" : `.`
      },
      // "remote" :
      // {
      //   "criterion" : { "predefined" : 1 }
      // },
      "download" : { "path" : `Proto` },
      "export" : { "path" : `{path::download}/proto/**` },
      "temp" : { "path" : `../out` },
      "exported.dir.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" : `Proto/proto`
      },
      "module.peer.in" :
      {
        'criterion' : { 'predefined' : 1 },
        'path' : '..'
      },
      "exported.files.export" :
      {
        "criterion" : { "default" : 1, "export" : 1, "generated" : 1 },
        "path" :
        [
          `Proto/proto`,
          `Proto/proto/dwtools`,
          `Proto/proto/dwtools/Tools.s`,
          `Proto/proto/dwtools/abase`,
          `Proto/proto/dwtools/abase/l3_proto`,
          `Proto/proto/dwtools/abase/l3_proto/Include.s`,
          `Proto/proto/dwtools/abase/l3_proto/l1`,
          `Proto/proto/dwtools/abase/l3_proto/l1/Define.s`,
          `Proto/proto/dwtools/abase/l3_proto/l1/Proto.s`,
          `Proto/proto/dwtools/abase/l3_proto/l1/Workpiece.s`,
          `Proto/proto/dwtools/abase/l3_proto/l3`,
          `Proto/proto/dwtools/abase/l3_proto/l3/Accessor.s`,
          `Proto/proto/dwtools/abase/l3_proto/l3/Class.s`,
          `Proto/proto/dwtools/abase/l3_proto/l3/Complex.s`,
          `Proto/proto/dwtools/abase/l3_proto/l3/Like.s`,
          `Proto/proto/dwtools/abase/l3_proto.test`,
          `Proto/proto/dwtools/abase/l3_proto.test/Class.test.s`,
          `Proto/proto/dwtools/abase/l3_proto.test/Complex.test.s`,
          `Proto/proto/dwtools/abase/l3_proto.test/Like.test.s`,
          `Proto/proto/dwtools/abase/l3_proto.test/Proto.test.s`
        ]
      }
    }
    test.identical( outfile.path, expectedPath );
    // logger.log( _.toJs( outfile.path ) );

    return null;
  })

  /* - */

  return ready;
}

importLocalRepo.timeOut = 200000;

//

/*
 - check caching of modules in out-willfiles
*/

function importOutWithDeletedSource( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'export-with-submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );
  let modulePath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  ready
  .then( ( got ) =>
  {
    test.case = 'export first';

    _.fileProvider.filesDelete( routinePath );
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

    return null;
  })

  start({ args : '.clean' })
  start({ args : '.with a .export' })
  start({ args : '.with b .export' })
  start({ args : '.with ab-named .export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ '.', './module-a.out.will.yml', './module-ab-named.out.will.yml', './module-b.out.will.yml' ];
    var files = self.find( outPath );
    test.identical( files, exp );

    _.fileProvider.filesDelete( _.path.join( routinePath, 'a.will.yml' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'b.will.yml' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'ab' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'ab-named.will.yml' ) );

    return null;
  })

  start({ args : '.with out/module-ab-named .modules.list' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, '. Opened .' ), 6 );
    test.identical( _.strCount( got.output, ' from ' ), 5 );
    test.identical( _.strCount( got.output, 'module::module-ab-named' ), 5 );
    test.identical( _.strCount( got.output, 'module::module-ab-named / module::module-a' ), 2 );
    test.identical( _.strCount( got.output, 'module::module-ab-named / module::module-b' ), 2 );
    test.identical( _.strCount( got.output, 'module::' ), 9 );

    return null;
  })

  /* - */

  return ready;
}

importOutWithDeletedSource.timeOut = 200000;

//

function shellWithCriterion( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-shell-with-criterion' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );


  /* Checks if start step supports plural criterion and which path is selected using current value of criterion */

  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.build A' })

  .then( ( got ) =>
  {
    test.description = 'should execute file A.js';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Executed-A.js' ) );

    return null;
  })

  /* - */

  start({ execPath : '.build B' })

  .then( ( got ) =>
  {
    test.description = 'should execute file B.js';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Executed-B.js' ) );

    return null;
  })

  /* - */

  return ready;
}

shellWithCriterion.timeOut = 200000;

//

/*
  Checks amount of output from start step depending on value of verbosity option
*/

function shellVerbosity( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-shell-verbosity' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.build verbosity.0' })

  .then( ( got ) =>
  {
    test.case = '.build verbosity.0';

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'node -e "console.log( \'message from shell\' )"' ), 0 );
    test.identical( _.strCount( got.output, routinePath ), 1 );
    test.identical( _.strCount( got.output, 'message from shell' ), 0 );
    test.identical( _.strCount( got.output, 'Process returned error code 0' ), 0 );

    return null;
  })

  /* - */

  start({ execPath : '.build verbosity.1' })

  .then( ( got ) =>
  {
    test.case = '.build verbosity.1';

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'node -e "console.log( \'message from shell\' )"' ), 1 );
    test.identical( _.strCount( got.output, routinePath ), 1 );
    test.identical( _.strCount( got.output, 'message from shell' ), 1 );
    test.identical( _.strCount( got.output, 'Process returned error code 0' ), 0 );

    return null;
  })

  /* - */

  start({ execPath : '.build verbosity.2' })

  .then( ( got ) =>
  {
    test.case = '.build verbosity.2';

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'node -e "console.log( \'message from shell\' )"' ), 1 );
    test.identical( _.strCount( got.output, routinePath ), 1 );
    test.identical( _.strCount( got.output, 'message from shell' ), 2 );
    test.identical( _.strCount( got.output, 'Process returned error code 0' ), 0 );

    return null;
  })

  /* - */

  start({ execPath : '.build verbosity.3' })

  .then( ( got ) =>
  {
    test.case = '.build verbosity.3';

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'node -e "console.log( \'message from shell\' )"' ), 1 );
    test.identical( _.strCount( got.output, routinePath ), 2 );
    test.identical( _.strCount( got.output, 'message from shell' ), 2 );
    test.identical( _.strCount( got.output, 'Process returned error code 0' ), 0 );

    return null;
  })

  /* - */

  start({ execPath : '.build verbosity.5' })

  .then( ( got ) =>
  {
    test.case = 'verbosity:5';

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, 'node -e "console.log( \'message from shell\' )"' ), 1 );
    test.identical( _.strCount( got.output, routinePath ), 2 );
    test.identical( _.strCount( got.output, 'message from shell' ), 2 );
    test.identical( _.strCount( got.output, 'Process returned error code 0' ), 1 );

    return null;
  })

  /* - */

  return ready;
}

//

function functionStringsJoin( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'function-strings-join' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build strings.join'
    return null;
  })
  start({ execPath : '.clean' })
  start({ execPath : '.build strings.join' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'node' ), 1 );
    test.identical( _.strCount( got.output, 'File2.js' ), 1 );
    test.identical( _.strCount( got.output, 'File3.js' ), 1 );
    test.identical( _.strCount( got.output, 'File1.js' ), 1 );
    test.identical( _.strCount( got.output, 'out1.js' ), 1 );

    var expected =
`console.log( 'File2.js' );
console.log( 'File3.js' );
console.log( 'File1.js' );
`
    var read = _.fileProvider.fileRead( _.path.join( routinePath, 'out1.js' ) );
    test.identical( read, expected );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build multiply'
    return null;
  })
  start({ execPath : '.clean' })
  start({ execPath : '.build multiply' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'node' ), 2 );
    test.identical( _.strCount( got.output, 'File2.js' ), 1 );
    test.identical( _.strCount( got.output, 'File3.js' ), 1 );
    test.identical( _.strCount( got.output, 'File1.js' ), 2 );
    test.identical( _.strCount( got.output, 'out2.js' ), 2 );

    var expected =
`console.log( 'File3.js' );
console.log( 'File1.js' );
`
    var read = _.fileProvider.fileRead( _.path.join( routinePath, 'out2.js' ) );
    test.identical( read, expected );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build echo1'
    return null;
  })
  start({ execPath : '.clean' })
  start({ execPath : '.build echo1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'node' ), 6 );
    test.identical( _.strCount( got.output, 'File2.js' ), 4 );
    test.identical( _.strCount( got.output, 'File3.js' ), 4 );
    test.identical( _.strCount( got.output, 'File3.js op2' ), 2 );
    test.identical( _.strCount( got.output, 'File3.js op3' ), 2 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build echo2'
    return null;
  })
  start({ execPath : '.clean' })
  start({ execPath : '.build echo2' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'node' ), 6 );
    test.identical( _.strCount( got.output, 'Echo.js op2 op3 op1' ), 2 );
    test.identical( _.strCount( got.output, 'Echo.js op2 op3 op2' ), 2 );

    return null;
  })

  /* - */

  return ready;
}

//

function functionPlatform( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'function-platform' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let outPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.build'
    return null;
  })
  start({ execPath : '.clean' })
  start({ execPath : '.build' })
  .then( ( got ) =>
  {
    var Os = require( 'os' );
    let platform = 'posix';

    if( Os.platform() === 'win32' )
    platform = 'windows'
    if( Os.platform() === 'darwin' )
    platform = 'osx'

    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '+ reflector::copy reflected 2 file(s)' ), 1 );
    test.identical( _.strCount( got.output, `./out/dir.${platform} <- ./proto in` ), 1 );

    var files = self.find( outPath );

    test.identical( files, [ '.', `./dir.${platform}`, `./dir.${platform}/File.js` ] );

    return null;
  })

  /* - */

  return ready;
}

//

/*
  Checks resolving selector with criterion.
*/

function functionThisCriterion( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-shell-using-criterion-value' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let outPath = _.path.join( routinePath, 'out' );


  let ready = new _.Consequence().take( null );
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* - */

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  start({ execPath : '.build debug' })

  .then( ( got ) =>
  {
    test.description = 'should print debug:1';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'debug:1' ) );

    return null;
  })

  /* - */

  start({ execPath : '.build release' })

  .then( ( got ) =>
  {
    test.description = 'should print debug:0';

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'debug:0' ) );

    return null;
  })

  /* - */

  return ready;
}

functionThisCriterion.timeOut = 200000;

//

function submodulesDownloadSingle( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  start({ execPath : '.submodules.download' })

  .then( ( got ) =>
  {
    test.case = '.submodules.download';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/0 submodule(s) of module::single were downloaded in' ) );
    return null;
  })

  /* - */

  start({ execPath : '.submodules.download' })

  .then( ( got ) =>
  {
    test.case = '.submodules.download'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/0 submodule(s) of module::single were downloaded in' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )
    return null;
  })

  /* - */

  start({ execPath : '.submodules.update' })

  .then( ( got ) =>
  {
    test.case = '.submodules.update'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/0 submodule(s) of module::single were updated in' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )
    return null;
  })

  /* - */

  start({ execPath : '.submodules.clean' })

  .then( ( got ) =>
  {
    test.case = '.submodules.clean';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Clean deleted 0 file(s)' ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )
    return null;
  })

  return ready;

}

submodulesDownloadSingle.timeOut = 200000;

//

function submodulesDownloadUpdate( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );


  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* */

  ready

  /* */

  .then( () =>
  {
    test.case = '.submodules.download - first time';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.submodules.download' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 2/2 submodule(s) of module::submodules were downloaded' ) );

    var files = self.find( submodulesPath );

    test.is( files.length > 30 );

    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'Tools' ) ) )
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'PathBasic' ) ) )
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.submodules.download - again';
    return null;
  })
  start({ execPath : '.submodules.download' })
  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/2 submodule(s) of module::submodules were downloaded' ) );
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'Tools' ) ) )
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'PathBasic' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )

    var files = self.find( _.path.join( submodulesPath, 'Tools' ) );
    test.is( files.length > 3 );

    var files = self.find( _.path.join( submodulesPath, 'PathBasic' ) );
    test.is( files.length > 3 );

    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.submodules.update - first time';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 2/2 submodule(s) of module::submodules were updated' ) );
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'Tools' ) ) )
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'PathBasic' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )

    var files = self.find( _.path.join( submodulesPath, 'Tools' ) );
    test.is( files.length );

    var files = self.find( _.path.join( submodulesPath, 'PathBasic' ) );
    test.is( files.length );

    return null;
  })

  /* */

  .then( () =>
  {
    test.case = '.submodules.update - again';
    return null;
  })
  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/2 submodule(s) of module::submodules were updated in' ) );
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'Tools' ) ) )
    test.is( _.fileProvider.fileExists( _.path.join( submodulesPath, 'PathBasic' ) ) )
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'modules' ) ) )

    var files = self.find( _.path.join( submodulesPath, 'Tools' ) );
    test.is( files.length );

    var files = self.find( _.path.join( submodulesPath, 'PathBasic' ) );
    test.is( files.length );

    return null;
  })

  /* */

  var files;

  ready
  .then( () =>
  {
    test.case = '.submodules.clean';
    files = self.findAll( submodulesPath );
    return files;
  })

  start({ execPath : '.submodules.clean' })
  .then( ( got ) =>
  {

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `${files.length}` ) );
    test.is( !_.fileProvider.fileExists( _.path.join( routinePath, '.module' ) ) ); /* phantom problem ? */

    return null;
  })

  /* */

  return ready;
}

submodulesDownloadUpdate.timeOut = 300000;

//

function submodulesDownloadUpdateDry( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );


  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.download dry:1';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.submodules.download dry:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.is( _.strHas( got.output, / \+ .*module::Tools.* will be downloaded version .*/ ) );
    // test.is( _.strHas( got.output, / \+ .*module::PathBasic.* will be downloaded version .*622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ) );
    // test.is( _.strHas( got.output, / \+ .*module::Color.* will be downloaded version .*0.3.115.*/ ) );
    test.is( _.strHas( got.output, '+ 2/5 submodule(s) of module::submodules-detached will be downloaded' ) );
    var files = self.find( submodulesPath );
    test.is( files.length === 0 );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.download dry:1 -- after download';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.submodules.download' })
  start({ execPath : '.submodules.download dry:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '0/5 submodule(s) of module::submodules-detached will be downloaded' ) );
    var files = self.find( submodulesPath );
    test.gt( files.length, 150 );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update dry:1';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.submodules.update dry:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.is( _.strHas( got.output, / \+ .*module::Tools.* will be updated to version .*/ ) );
    // test.is( _.strHas( got.output, / \+ .*module::PathBasic.* will be updated to version .*622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ) );
    // test.is( _.strHas( got.output, / \+ .*module::Color.* will be updated to version .*0.3.115.*/ ) );
    test.is( _.strHas( got.output, '+ 2/5 submodule(s) of module::submodules-detached will be updated' ) );
    var files = self.find( submodulesPath );
    test.is( files.length === 0 );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update dry:1 -- after update';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })

  start({ execPath : '.submodules.update' })
  start({ execPath : '.submodules.update dry:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/5 submodule(s) of module::submodules-detached will be updated' ) );
    var files = self.find( submodulesPath );
    test.gt( files.length, 150 );
    return null;
  })

  /* */

  return ready;
}

submodulesDownloadUpdateDry.timeOut = 300000;

//

function submodulesDownloadSwitchBranch( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-update-switch-branch' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let experimentModulePath = _.path.join( submodulesPath, 'experiment' );
  let willfilePath = _.path.join( routinePath, '.will.yml' );

  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  ready

  .then( () =>
  {
    test.case = 'setup repo';

    let con = new _.Consequence().take( null );
    let repoPath = _.path.join( routinePath, 'experiment' );
    let repoSrcFiles = _.path.join( routinePath, 'src' );
    let clonePath = _.path.join( routinePath, 'cloned' );
    _.fileProvider.dirMake( repoPath );

    let start = _.process.starter
    ({
      currentPath : routinePath,
      outputCollecting : 1,
      ready : con,
    })

    start( 'git -C experiment init --bare' )
    start( 'git clone experiment cloned' )

    .then( () =>
    {
      return _.fileProvider.filesReflect({ reflectMap : { [ repoSrcFiles ] : clonePath } })
    })

    start( 'git -C cloned add -fA .' )
    start( 'git -C cloned commit -m init' )
    start( 'git -C cloned push' )
    start( 'git -C cloned checkout -b dev' )
    start( 'git -C cloned commit --allow-empty -m test' )
    start( 'git -C cloned push origin dev' )

    return con;
  })

  .then( () =>
  {
    test.case = 'download master branch';
    return null;
  })

  start({ execPath : '.submodules.download' })

  .then( () =>
  {
    debugger
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch master to dev';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#master', '#dev' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.download' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch dev to detached state';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#dev', '#9ce409887df0754760a1cbdce249b0fa5f08152e' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.download' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch detached state to master';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#9ce409887df0754760a1cbdce249b0fa5f08152e', '#master' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.download' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  return ready;
}

submodulesDownloadSwitchBranch.timeOut = 300000;

// //
//
// function submodulesDownloadRecursive( test )
// {
//   let self = this;
//   let a = self.assetFor( test, 'hierarchy-remote' );
//
//   // let a = self.assetFor( test, 'hierarchy-diff-download-paths-regular' );
//   // let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'hierarchy-remote' );
//   // let routinePath = _.path.join( self.suiteTempPath, test.name );
//   // let abs = self.abs_functor( routinePath );
//   // let rel = self.rel_functor( routinePath );
//   // let submodulesPath = _.path.join( routinePath, '.module' );
//   //
//   // let ready = new _.Consequence().take( null );
//   //
//   // let start = _.process.starter
//   // ({
//   //   execPath : 'node ' + self.willPath,
//   //   currentPath : routinePath,
//   //   outputCollecting : 1,
//   //   outputGraying : 1,
//   //   outputGraying : 1,
//   //   mode : 'spawn',
//   //   ready : ready,
//   // })
//   //
//   // _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with * .submodules.download recursive:2';
//     a.reflect();
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     return null;
//   })
//
//   a.start({ execPath : '.with * .submodules.download recursive:2' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'PathTools' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = null;
//     var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
//     test.identical( _.strCount( got.output, '. Read 2 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 6/7 submodule(s) of module::c were downloaded in' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   a.start({ execPath : '.with * .submodules.download recursive:2' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
//     test.identical( _.strCount( got.output, '. Read 26 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 0/7 submodule(s) of module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with ** .submodules.download recursive:2';
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     a.reflect();
//     return null;
//   })
//
//   a.start({ execPath : '.with ** .submodules.download recursive:2' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
//     test.identical( _.strCount( got.output, '. Read 2 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 6/7 submodule(s) of module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   a.start({ execPath : '.with ** .submodules.download recursive:2' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
//     test.identical( _.strCount( got.output, '. Read 26 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wPathBasic were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wUriBasic were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wProto were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::a0 were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wTools were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z / module::c were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wPathTools were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::b were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z / module::a were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/9 submodule(s) of module::z were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/7 submodule(s) of module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with * .submodules.download recursive:1';
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     a.reflect();
//     return null;
//   })
//
//   a.start({ execPath : '.with * .submodules.download recursive:1' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
//     test.identical( _.strCount( got.output, '. Read 2 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 4/5 submodule(s) of module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   a.start({ execPath : '.with * .submodules.download recursive:1' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
//     test.identical( _.strCount( got.output, '. Read 20 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 0/5 submodule(s) of module::c were downloaded in' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with ** .submodules.download recursive:1';
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     a.reflect();
//     return null;
//   })
//
//   a.start({ execPath : '.with ** .submodules.download recursive:1' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
//     test.identical( _.strCount( got.output, '. Read 5 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 2/2 submodule(s) of module::z / module::a0 were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 1/2 submodule(s) of module::z / module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 1/2 submodule(s) of module::z / module::b were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 1/3 submodule(s) of module::z / module::a were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 5 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   a.start({ execPath : '.with ** .submodules.download recursive:1' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = [ 'PathTools' ];
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'PathTools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
//     test.identical( _.strCount( got.output, '. Read 20 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wPathBasic were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wUriBasic were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wProto were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::a0 were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wTools were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::c were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z / module::wPathTools were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::b were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::z / module::a were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 10 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wPathBasic / module::wPathBasic were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wUriBasic / module::wUriBasic were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wProto / module::wProto were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::a0 were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wTools / module::wTools were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::c were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::wPathTools / module::wPathTools were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z / module::b were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::z / module::a were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );
//     // test.identical( _.strCount( got.output, 'submodule(s)' ), 10 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with * .submodules.download recursive:0';
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     a.reflect();
//     return null;
//   })
//
//   a.start({ execPath : '.with * .submodules.download recursive:0' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = null;
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'PathTools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
//     test.identical( _.strCount( got.output, '. Read 5 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of module::z were downloaded' ), 1 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//
//   .then( () =>
//   {
//     test.case = '.with ** .submodules.download recursive:0';
//     // _.fileProvider.filesDelete( a.abs( '.module' ) );
//     a.reflect();
//     return null;
//   })
//
//   a.start({ execPath : '.with ** .submodules.download recursive:0' })
//
//   .then( ( got ) =>
//   {
//     test.identical( got.exitCode, 0 );
//
//     var exp = null;
//     var files = _.fileProvider.dirRead( a.abs( '.module' ) );
//     test.identical( files, exp )
//
//     var exp = [ 'PathTools' ];
//     var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) );
//     test.identical( files, exp )
//
//     test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
//     test.identical( _.strCount( got.output, '. Read 5 willfile(s) in' ), 1 );
//     test.identical( _.strCount( got.output, 'willfile(s) in' ), 1 );
//
//     test.identical( _.strCount( got.output, '+ 0/0 submodule(s) of' ), 5 );
//     test.identical( _.strCount( got.output, 'submodule(s)' ), 5 );
//     test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
//
//     return null;
//   })
//
//   /* - */
//
//   return a.ready;
// } /* end of function submodulesDownloadRecursive */
//
// submodulesDownloadRecursive.timeOut = 500000;
// xxx

//

function submodulesDownloadThrowing( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-download-errors' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );
  let downloadPath = _.path.join( routinePath, '.module/PathBasic' );
  let filePath = _.path.join( downloadPath, 'file' );
  let filesBefore;

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready

  .then( () =>
  {
    test.case = 'error on download, new directory should not be made';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.download' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `fatal: unable to access 'https://githu.com/Wandalen/wPathBasic.git/` ) );
    test.is( _.strHas( got.output, 'Failed to download module' ) );
    test.is( !_.fileProvider.fileExists( downloadPath ) )
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error on download, existing empty directory should be preserved';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.download' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `fatal: unable to access 'https://githu.com/Wandalen/wPathBasic.git/` ) );
    test.is( _.strHas( got.output, 'Failed to download module' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    test.identical( _.fileProvider.dirRead( downloadPath ), [] );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'no error if download path exists and its an empty dir';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Failed to download module' ) );
    test.is( _.strHas( got.output, 'module::wPathBasic was downloaded version master in' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were downloaded' ) );

    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error if download path exists and it is not a empty dir';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    _.fileProvider.fileWrite( filePath,filePath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `Module module::submodules-download-errors-good / opener::PathBasic is downloaded, but it's not a git repository` ) );
    test.is( _.strHas( got.output, 'Failed to download module' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    test.identical( _.fileProvider.dirRead( downloadPath ), [ 'file' ] );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error if download path exists and its terminal';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.fileWrite( downloadPath,downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `Module module::submodules-download-errors-good / opener::PathBasic is not downloaded, but file at` ) );
    test.is( _.strHas( got.output, 'Failed to download module' ) );
    test.is( _.fileProvider.isTerminal( downloadPath ) )
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'no error if download path exists and it has other git repo';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start2({ execPath : 'git clone https://github.com/Wandalen/wTools.git .module/PathBasic' })
  .then( () =>
  {
    filesBefore = self.find( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules-download-errors-good were downloaded' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    let filesAfter = self.find( downloadPath );
    test.identical( filesAfter, filesBefore );

    return null;
  })

  //

  ready
  .then( () =>
  {
    test.case = 'downloaded, change in file to make module not valid, error expected';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( () =>
  {
    let inWillFilePath = _.path.join( downloadPath, '.im.will.yml' );
    let inWillFile = _.fileProvider.fileConfigRead( inWillFilePath );
    inWillFile.section = { field : 'value' };
    _.fileProvider.fileWrite({ filePath : inWillFilePath, data : inWillFile,encoding : 'yml' });
    return null;
  })
  .then( () =>
  {
    filesBefore = self.find( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.download' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Willfile should not have section(s) : "section"' ) );
    let filesAfter = self.find( downloadPath );
    test.identical( filesAfter, filesBefore )
    return null;
  })

  /* - */

  return ready;
}

submodulesDownloadThrowing.timeOut = 300000;

//

function submodulesDownloadStepAndCommand( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-download' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );
  let localRepoPath = _.path.join( routinePath, 'module' );
  let ready = new _.Consequence().take( null );
  let downloadPath = _.path.join( routinePath, '.module/PathBasic' );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : localRepoPath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  /* submodules.download step downloads submodules recursively, but should not */

  ready

  .then( () =>
  {
    test.case = 'download using step::submodules.download'
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start2( 'git init' )
  start2( 'git add .' )
  start2( 'git commit -m init' )
  start({ execPath : '.build' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    let files = self.find( submodulesPath );
    test.is( !_.longHas( files, './Tools' ) )
    test.is( !_.longHas( files, './Proto' ) )
    test.is( _.longHas( files, './submodule' ) )
    return null;
  })

  /* submodules.download command downloads only own submodule, as expected */

  .then( () =>
  {
    test.case = 'download using command submodules.download'
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start2( 'git init' )
  start2( 'git add .' )
  start2( 'git commit -m init' )
  start({ execPath : '.submodules.download' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    let files = self.find( submodulesPath );
    test.is( !_.longHas( files, './Tools' ) )
    test.is( !_.longHas( files, './Proto' ) )
    test.is( _.longHas( files, './submodule' ) )
    return null;
  })

  /*  */

  return ready;
}

//

function submodulesDownloadDiffDownloadPathsRegular( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-diff-download-paths-regular' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .submodules.download';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .submodules.download' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
    test.identical( _.strCount( got.output, '. Opened .' ), 20 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 4 );
    test.identical( _.strCount( got.output, '+ 4/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  a.start( '.with c .submodules.download' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 20 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 6 );
    test.identical( _.strCount( got.output, '+ 6/7 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  a.start( '.with c .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'PathTools', 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/7 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function submodulesDownloadDiffDownloadPathsRegular */

submodulesDownloadDiffDownloadPathsRegular.timeOut = 300000;

//

function submodulesDownloadDiffDownloadPathsIrregular( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-diff-download-paths-irregular' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .submodules.download';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .submodules.download' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 4 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 4 );
    test.identical( _.strCount( got.output, '+ 4/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  a.start( '.with c .submodules.download' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with c .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with c .clean recursive:2' )
  a.start( '.with c .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 4 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 4 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 4 );
    test.identical( _.strCount( got.output, '+ 4/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  a.start( '.with c .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Color', 'PathBasic', 'Procedure', 'Proto' ];
    var files = _.fileProvider.dirRead( a.abs( 'a/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/5 submodule(s) of module::c were downloaded' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function submodulesDownloadDiffDownloadPathsIrregular */

submodulesDownloadDiffDownloadPathsIrregular.timeOut = 300000;

//

function submodulesDownloadHierarchyRemote( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-remote' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.download';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with z .submodules.download' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 14 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 1/4 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = null;
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 14 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/4 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 5 );
    test.identical( _.strCount( got.output, '+ 5/9 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/9 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with ** .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 2 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 5 );
    test.identical( _.strCount( got.output, '+ 5/9 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathTools', 'Proto', 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    var exp = [ 'PathBasic', 'PathTools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/group10/.module' ) )
    test.identical( files, exp );

    var exp = [ 'UriBasic' ];
    var files = _.fileProvider.dirRead( a.abs( 'group2/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 26 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/9 submodule(s) of module::z were downloaded' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function submodulesDownloadHierarchyRemote */

submodulesDownloadHierarchyRemote.timeOut = 300000;

//

function submodulesDownloadHierarchyDuplicate( test )
{
  let self = this;
  let a = self.assetFor( test, 'hierarchy-duplicate' );

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.download';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with z .submodules.download' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 1 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 1/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with z .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 1 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 1/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  /* - */

  a.ready

  .then( () =>
  {
    test.case = '.with ** .submodules.download recursive:2';
    a.reflect();
    return null;
  })

  a.start( '.with z .clean recursive:2' )
  a.start( '.with ** .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );


    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 1 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 1 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 1 );
    test.identical( _.strCount( got.output, '+ 1/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  a.start( '.with z .submodules.download recursive:2' )

  .then( ( got ) =>
  {
    test.case = 'second';
    test.identical( got.exitCode, 0 );


    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    var exp = [ 'Tools' ];
    var files = _.fileProvider.dirRead( a.abs( 'group1/.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 8 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/2 submodule(s) of module::z were downloaded' ), 1 );
    test.identical( _.strCount( got.output, 'submodule(s)' ), 1 );

    return null;
  })

  /* - */

  return a.ready;

} /* end of function submodulesDownloadHierarchyDuplicate */

submodulesDownloadHierarchyDuplicate.timeOut = 300000;

//

function submodulesDownloadNpm( test )
{
  let self = this;
  let a = self.assetFor( test, 'submodules-download-npm' );
  let versions = {}
  let willFilePath = a.abs( '.will.yml' )
  let filesBefore = null;

  /* - */

  a.ready
  
  .then( () =>
  {
    versions[ 'Tools' ] = _.npm.versionRemoteRetrive( 'npm:///wTools' );
    versions[ 'Path' ] = _.npm.versionRemoteRetrive( 'npm:///wpathbasic@alpha' );
    versions[ 'Uri' ] = _.npm.versionRemoteCurrentRetrive( 'npm:///wuribasic#0.6.131' );
    
    a.reflect();
    
    return null;
  })

  /* */
  
  a.start( '.submodules.download' )

  .then( ( got ) =>
  {
    test.case = 'download npm modules';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = a.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 3 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 3 );
    test.identical( _.strCount( got.output, '+ 3/3 submodule(s) of module::supermodule were downloaded' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was downloaded version ${versions['Tools']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Path was downloaded version ${versions['Path']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Uri was downloaded version ${versions['Uri']}` ), 1 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 1 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  a.start( '.submodules.download' )

  .then( ( got ) =>
  { 
    test.case = 'second run of .submodules.download';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = a.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'was downloaded' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::supermodule were downloaded' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was downloaded version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was downloaded version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was downloaded version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  .then( () => 
  { 
    test.case = 'change origin of first submodule and run .submodules.download';
    
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wTools', 'npm:///wprocedure' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    filesBefore = self.find( a.abs( '.module/Tools' ) );
    
    return null;
  })
  
  a.start( '.submodules.download' )
  
  .then( ( got ) =>
  { 
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = a.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::supermodule were downloaded' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was downloaded version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was downloaded version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was downloaded version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    var files = self.find( a.abs( '.module/Tools' ) );
    test.identical( files,filesBefore );
    
    return null;
  })
  .then( () => 
  { 
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wprocedure', 'npm:///wTools' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    return null;
  })
  
  /*  */

  return a.ready;
}

submodulesDownloadNpm.timeOut = 300000;

//

function submodulesDownloadUpdateNpm( test )
{
  let self = this;
  let a = self.assetFor( test, 'submodules-download-npm' );
  let versions = {}
  let willFilePath = a.abs( '.will.yml' );
  let filesBefore = null;
  
  /* - */

  a.ready
  
  .then( () =>
  {
    versions[ 'Tools' ] = _.npm.versionRemoteRetrive( 'npm:///wTools' );
    versions[ 'Path' ] = _.npm.versionRemoteRetrive( 'npm:///wpathbasic@alpha' );
    versions[ 'Uri' ] = _.npm.versionRemoteCurrentRetrive( 'npm:///wuribasic#0.6.131' );
    
    a.reflect();
    
    return null;
  })

  /* */
  
  a.start( '.submodules.update' )

  .then( ( got ) =>
  {
    test.case = 'download npm modules';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 3 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'were updated' ), 1 );
    test.identical( _.strCount( got.output, '+ 3/3 submodule(s) of module::supermodule were updated' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was updated to version ${versions['Tools']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Path was updated to version ${versions['Path']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Uri was updated to version ${versions['Uri']}` ), 1 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 1 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  .then( ( got ) =>
  { 
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, '@alpha', '@beta' );
    willFile = _.strReplace( willFile, '#0.6.131', '#0.6.122' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    versions[ 'Path' ] = _.npm.versionRemoteRetrive( 'npm:///wpathbasic@beta' );
    versions[ 'Uri' ] = '0.6.122'
    
    return null;
  })
  
  a.start( '.submodules.update' )

  .then( ( got ) =>
  { 
    test.case = 'second run of .submodules.update';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 11 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'were updated' ), 1 );
    test.identical( _.strCount( got.output, '+ 2/3 submodule(s) of module::supermodule were updated' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was updated to version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was updated to version ${versions['Path']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Uri was updated to version ${versions['Uri']}` ), 1 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 1 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  a.start( '.submodules.update' )

  .then( ( got ) =>
  { 
    test.case = 'third run of .submodules.update';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'were updated' ), 1 );
    test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::supermodule were updated' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was updated to version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was updated to version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was updated to version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  .then( () => 
  {
    test.case = 'change origin of first submodule and run .submodules.update';
    
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wTools', 'npm:///wprocedure' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    filesBefore = self.find( a.abs( '.module' ) );
    
    return null;
  })
  
  a.startNonThrowing( '.submodules.update' )
  
  .then( ( got ) =>
  { 
    test.notIdentical( got.exitCode, 1 );
    
    var files = self.find( a.abs( '.module' ) );
    test.identical( files,filesBefore );
    
    test.identical( _.strCount( got.output, 'opener::Tools is already downloaded, but has different origin url: wTools , expected url: wprocedure' ), 1 );
    
    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::supermodule were updated' ), 0 );
    
    test.identical( _.strCount( got.output, `module::Tools was updated to version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was updated to version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was updated to version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    return null;
  })
  
  .then( () => 
  {
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wprocedure', 'npm:///wTools' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    return null;
  })

  return a.ready;
}

submodulesDownloadUpdateNpm.timeOut = 300000;

//

function submodulesUpdateThrowing( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-download-errors' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );
  let downloadPath = _.path.join( routinePath, '.module/PathBasic' );
  let filePath = _.path.join( downloadPath, 'file' );
  let filesBefore;

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    mode : 'spawn',
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready

  .then( () =>
  {
    test.case = 'error on update, new directory should not be made';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `fatal: unable to access 'https://githu.com/Wandalen/wPathBasic.git/` ) );
    test.is( _.strHas( got.output, 'Failed to update module' ) );

    test.is( !_.fileProvider.fileExists( downloadPath ) )
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error on update, existing empty directory should be preserved';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `fatal: unable to access 'https://githu.com/Wandalen/wPathBasic.git/` ) );
    test.is( _.strHas( got.output, 'Failed to update module' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    test.identical( _.fileProvider.dirRead( downloadPath ), [] );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'no error if download path exists and its an empty dir';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Failed to download update' ) );
    test.is( _.strHas( got.output, 'module::wPathBasic was updated to version master in' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were updated in' ) );

    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error if download path exists and it is not a empty dir';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    _.fileProvider.fileWrite( filePath,filePath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `Module module::submodules-download-errors-good / opener::PathBasic is downloaded, but it's not a git repository` ) );
    test.is( _.strHas( got.output, 'Failed to update module' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    test.identical( _.fileProvider.dirRead( downloadPath ), [ 'file' ] );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error if download path exists and its terminal';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.fileWrite( downloadPath,downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Module module::submodules-download-errors-good / opener::PathBasic is not downloaded, but file at' ) );
    test.is( _.strHas( got.output, 'Failed to update submodules' ) );
    test.is( _.fileProvider.isTerminal( downloadPath ) )
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error if download path exists and it has other git repo, repo should be preserved';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start2({ execPath : 'git clone https://github.com/Wandalen/wTools.git .module/PathBasic' })
  .then( () =>
  {
    filesBefore = self.find( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'opener::PathBasic is already downloaded, but has different origin url') );
    test.is( _.strHas( got.output, 'Failed to update submodules' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    let filesAfter = self.find( downloadPath );
    test.identical( filesBefore.length, filesAfter.length );

    return null;
  })

  //

  ready
  .then( () =>
  {
    test.case = 'downloaded, change in file to make module not valid, error expected';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( () =>
  {
    let inWillFilePath = _.path.join( downloadPath, '.im.will.yml' );
    let inWillFile = _.fileProvider.fileConfigRead( inWillFilePath );
    inWillFile.section = { field : 'value' };
    _.fileProvider.fileWrite({ filePath : inWillFilePath, data : inWillFile,encoding : 'yml' });
    return null;
  })
  .then( () =>
  {
    filesBefore = self.find( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.update' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Willfile should not have section(s) : "section"' ) );
    let filesAfter = self.find( downloadPath );
    test.identical( filesAfter, filesBefore )
    return null;
  })

  /* - */

  return ready;
}

submodulesUpdateThrowing.timeOut = 300000;

//

function submodulesAgreeThrowing( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-download-errors' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );
  let downloadPath = _.path.join( routinePath, '.module/PathBasic' );
  let filePath = _.path.join( downloadPath, 'file' );
  let filesBefore;

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready

  .then( () =>
  {
    test.case = 'error on agree, new directory should not be made';
    _.fileProvider.filesDelete( submodulesPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Failed to agree module' ) );
    test.is( !_.fileProvider.fileExists( downloadPath ) )
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error on download, existing empty directory will be deleted ';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Failed to agree module' ) );
    test.is( !_.fileProvider.fileExists( downloadPath ) );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'existing empty directory will be deleted ';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Failed to agree module' ) );
    test.is( _.strHas( got.output, 'module::wPathBasic was agreed with version master' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were agreed' ) );
    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error on download, dir with terminal at download path, download path will be deleted';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    _.fileProvider.fileWrite( filePath,filePath );
    return null;
  })
  start({ execPath : '.with bad .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Failed to agree module' ) );
    test.is( !_.fileProvider.fileExists( downloadPath ) );

    return null;
  })

  //

  .then( () =>
  {
    test.case = 'dir with terminal at download path, download path will be deleted';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    _.fileProvider.fileWrite( filePath,filePath );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Failed to agree module' ) );
    test.is( _.strHas( got.output, 'module::wPathBasic was agreed with version master' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were agreed' ) );
    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })

  //

  .then( () =>
  {
    test.case = 'error on download, download path exists and its terminal, file will be removed';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.fileWrite( downloadPath,downloadPath );
    return null;
  })
  start({ execPath : '.with bad .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Failed to agree module' ) );
    test.is( !_.fileProvider.fileExists( downloadPath ) );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'download path exists and its terminal, file will be removed';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.fileWrite( downloadPath,downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, 'Failed to agree module' ) );
    test.is( _.strHas( got.output, 'module::wPathBasic was agreed with version master' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were agreed in' ) );
    let files = self.find( downloadPath );
    test.gt( files.length, 10 );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'donwloaded repo has different origin, should be deleted and downloaded again';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start2({ execPath : 'git clone https://github.com/Wandalen/wTools.git .module/PathBasic' })
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules-download-errors-good were agreed' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })



  .then( () =>
  {
    test.case = 'donwloaded repo has uncommitted change, error expected';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  start2( 'git -C .module/PathBasic reset --hard HEAD~1' )
  .then( () =>
  {
    _.fileProvider.fileWrite( _.path.join( downloadPath, 'was.package.json' ), 'was.package.json' );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Module at module::submodules-download-errors-good / opener::PathBasic needs to be updated, but has local changes' ) );
    test.is( _.strHas( got.output, 'Failed to agree module::submodules-download-errors-good / opener::PathBasic' ) );
    return null;
  })

  //

  .then( () =>
  {
    test.case = 'donwloaded repo has unpushed change and wrong origin, error expected';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })
  start({ execPath : '.with good .submodules.versions.agree' })
  start2( 'git -C .module/PathBasic reset --hard HEAD~1' )
  start2( 'git -C .module/PathBasic commit -m unpushed --allow-empty' )
  start2( 'git -C .module/PathBasic remote remove origin' )
  start2( 'git -C .module/PathBasic remote add origin https://github.com/Wandalen/wTools.git' )
  start({ execPath : '.with good .submodules.versions.agree' })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'needs to be deleted, but has local changes' ) );
    test.is( _.strHas( got.output, 'Failed to agree module::submodules-download-errors-good / opener::PathBasic' ) );
    return null;
  })

  /* - */

  return ready;
}

submodulesAgreeThrowing.timeOut = 300000;

//

function submodulesVersionsAgreeWrongOrigin( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-download-errors' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let ready = new _.Consequence().take( null );
  let downloadPath = _.path.join( routinePath, '.module/PathBasic' );
  let filePath = _.path.join( downloadPath, 'file' );
  let filesBefore;

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* - */

  ready
  .then( () =>
  {
    test.case = 'donwloaded repo has different origin, should be deleted and downloaded again';
    _.fileProvider.filesDelete( submodulesPath );
    _.fileProvider.dirMake( downloadPath );
    return null;
  })

  start2({ execPath : 'git clone https://github.com/Wandalen/wTools.git .module/PathBasic' })
  start({ execPath : '.with good .submodules.versions.agree' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 1/1 submodule(s) of module::submodules-download-errors-good were agreed' ) );
    test.is( _.fileProvider.fileExists( downloadPath ) )
    let files = self.find( downloadPath );
    test.gt( files.length, 10 );

    return null;
  })

  /* - */

  return ready;
}

submodulesVersionsAgreeWrongOrigin.timeOut = 300000;

//

/*
  Informal module has submodule willbe-experiment#master
  Supermodule has informal module and willbe-experiment#dev in submodules list
  First download of submodules works fine.
  After updating submodules of supermodule, branch dev of willbe-experiment is changed to master.
  This is wrong, because willbe-experiment should stay on branch dev as its defined in willfile of supermodule.
*/

function submodulesDownloadedUpdate( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-downloaded-update' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );


  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* */

  ready
  .then( () =>
  {
    test.case = 'setup';
    return null;
  })

  start({ execPath : '.each module .export' })
  start({ execPath : '.submodules.download' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, / \+ 1\/2 submodule\(s\) of .*module::submodules.* were downloaded in/ ) );
    return got;
  })

  /* */

  .then( () =>
  {
    test.case = 'check module branch after download';
    return null;
  })

  _.process.start
  ({
    execPath : 'git -C .module/willbe-experiment rev-parse --abbrev-ref HEAD',
    currentPath : routinePath,
    ready : ready,
    outputCollecting : 1,
    outputGraying : 1,
  })

  .then( ( got ) =>
  {
    test.will = 'submodule of supermodule should stay on dev';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'dev' ) );
    return got;
  })

  _.process.start
  ({
    execPath : 'git -C module/.module/willbe-experiment rev-parse --abbrev-ref HEAD',
    currentPath : routinePath,
    ready : ready,
    outputCollecting : 1,
    outputGraying : 1,
  })

  .then( ( got ) =>
  {
    test.will = 'submodule of informal submodule should stay on master';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'master' ) );
    return got;
  })

  /* */

  .then( ( got ) =>
  {
    test.case = 'update downloaded module and check branch';
    return got;
  })

  start({ execPath : '.submodules.update' })

  _.process.start
  ({
    execPath : 'git -C .module/willbe-experiment rev-parse --abbrev-ref HEAD',
    currentPath : routinePath,
    ready : ready,
    outputCollecting : 1,
    outputGraying : 1,
  })

  .then( ( got ) =>
  {
    test.will = 'submodule of supermodule should stay on dev';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'dev' ) );
    return got;
  })

  _.process.start
  ({
    execPath : 'git -C module/.module/willbe-experiment rev-parse --abbrev-ref HEAD',
    currentPath : routinePath,
    ready : ready,
    outputCollecting : 1,
    outputGraying : 1,
  })

  .then( ( got ) =>
  {
    test.will = 'submodule of informal submodule should stay on master';
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'master' ) );
    return got;
  })

  return ready;
}

//

function subModulesUpdate( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-update' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );


  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ module::wTools was updated to version 8fa27d72fe02d5e496b26e16669970a69d71fdb1 in' ) );
    test.is( _.strHas( got.output, '+ module::wPathBasic was updated to version master in' ) );
    test.is( _.strHas( got.output, '+ module::wUriBasic was updated to version d7022e6dcd5ab7f2d71aeb740d41a65dfaabdecf in' ) );
    test.is( _.strHas( got.output, '+ 3/3 submodule(s) of module::submodules were updated in' ) );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update -- second';
    return null;
  })

  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, /module::Tools/ ) );
    test.is( !_.strHas( got.output, /module::PathBasic/ ) );
    test.is( !_.strHas( got.output, /module::UriBasic/ ) );
    test.is( _.strHas( got.output, '+ 0/3 submodule(s) of module::submodules were updated in' ) );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update -- after patch';
    var read = _.fileProvider.fileRead( _.path.join( routinePath, '.im.will.yml' ) );
    read = _.strReplace( read, '8fa27d72fe02d5e496b26e16669970a69d71fdb1', 'master' )
    _.fileProvider.fileWrite( _.path.join( routinePath, '.im.will.yml' ), read );
    return null;
  })

  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.is( _.strHas( got.output, / \+ .*module::Tools.* was updated to version .*master.* in/ ) );
    test.is( !_.strHas( got.output, /module::PathBasic/ ) );
    test.is( !_.strHas( got.output, /module::UriBasic/ ) );
    test.is( _.strHas( got.output, '+ 1/3 submodule(s) of module::submodules were updated in' ) );
    return null;
  })

  /* */

  ready
  .then( () =>
  {
    test.case = '.submodules.update -- second';
    return null;
  })

  start({ execPath : '.submodules.update' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( !_.strHas( got.output, /module::Tools/ ) );
    test.is( !_.strHas( got.output, /module::PathBasic/ ) );
    test.is( !_.strHas( got.output, /module::UriBasic/ ) );
    test.is( _.strHas( got.output, '+ 0/3 submodule(s) of module::submodules were updated in' ) );
    return null;
  })

  /* */

  return ready;
}

subModulesUpdate.timeOut = 300000;

//

function subModulesUpdateSwitchBranch( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-update-switch-branch' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let submodulesPath = _.path.join( routinePath, '.module' );

  let experimentModulePath = _.path.join( submodulesPath, 'willbe-experiment' );
  let willfilePath = _.path.join( routinePath, '.will.yml' );
  let detachedVersion;

  let ready = new _.Consequence().take( null )
  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  /* */

  begin()

  .then( () =>
  {
    test.case = 'download master branch';
    return null;
  })

  start({ execPath : '.submodules.update' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch master to dev';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ]= _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#master', '#dev' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.update' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/dev' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch dev to detached state';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#dev', '#' + detachedVersion );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.update' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, detachedVersion ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'switch detached state to master';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#' + detachedVersion, '#master' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.update' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  .then( () =>
  {
    test.case = 'master has local change, cause conflict when switch to dev';
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#master', '#dev' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    let filePath = _.path.join( submodulesPath, 'willbe-experiment/File.js' );
    _.fileProvider.fileWrite({ filePath, data : 'master' });
    return null;
  })

  .then( () =>
  {
    let con = start({ execPath : '.submodules.update', ready : null });
    return test.shouldThrowErrorAsync( con );
  })

  _.process.start
  ({
    execPath : 'git status',
    currentPath : experimentModulePath,
    ready : ready,
    outputCollecting : 1
  })

  .then( ( got ) =>
  {
    test.is( _.strHas( got.output, 'modified:   File.js' ) )

    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  /**/

  ready.then( () =>
  {
    test.case = 'master has new commit, changing branch to dev';
    return null;
  })

  begin()

  start({ execPath : '.submodules.update' })

  _.process.start
  ({
    execPath : 'git commit --allow-empty -m commitofmaster',
    currentPath : experimentModulePath,
    ready : ready
  })
  .then( () =>
  {
    let willFile = _.fileProvider.fileRead({ filePath : willfilePath, encoding : 'yml' });
    willFile.submodule[ 'willbe-experiment' ] = _.strReplaceAll( willFile.submodule[ 'willbe-experiment' ], '#master', '#dev' );
    _.fileProvider.fileWrite({ filePath : willfilePath, data : willFile, encoding : 'yml' });
    return null;
  })

  start({ execPath : '.submodules.update' })

  .then( () =>
  {
    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/dev' ) );
    return null;
  })

  /**/

  ready.then( () =>
  {
    test.case = 'master and remote master have new commits';
    return null;
  })

  begin()

  start({ execPath : '.submodules.update' })

  _.process.start
  ({
    execPath : 'git commit --allow-empty -m emptycommit',
    currentPath : experimentModulePath,
    ready : ready
  })

  start2( 'git -C cloned checkout master' )
  start2( 'git -C cloned commit --allow-empty -m test' )
  start2( 'git -C cloned push' )

  start({ execPath : '.submodules.update' })

  _.process.start
  ({
    execPath : 'git status',
    currentPath : experimentModulePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  .then( ( got ) =>
  {
    test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 2 commits` ) );

    let currentVersion = _.fileProvider.fileRead( _.path.join( submodulesPath, 'willbe-experiment/.git/HEAD' ) );
    test.is( _.strHas( currentVersion, 'ref: refs/heads/master' ) );
    return null;
  })

  return ready;

  /* */

  function begin()
  {
    ready
    .then( () =>
    {
      test.case = 'setup repo';

      let con = new _.Consequence().take( null );
      let repoPath = _.path.join( routinePath, 'experiment' );
      let repoSrcFiles = _.path.join( routinePath, 'src' );
      let clonePath = _.path.join( routinePath, 'cloned' );

      _.fileProvider.filesDelete( routinePath );
      _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

      _.fileProvider.dirMake( repoPath );

      let start = _.process.starter
      ({
        currentPath : routinePath,
        outputCollecting : 1,
        ready : con,
      })

      start( 'git -C experiment init --bare' )
      start( 'git clone experiment cloned' )

      .then( () =>
      {
        return _.fileProvider.filesReflect({ reflectMap : { [ repoSrcFiles ] : clonePath } })
      })

      start( 'git -C cloned add -fA .' )
      start( 'git -C cloned commit -m init' )
      start( 'git -C cloned push' )
      start( 'git -C cloned checkout -b dev' )
      start( 'git -C cloned commit --allow-empty -m test' )
      start( 'git -C cloned commit --allow-empty -m test2' )
      start( 'git -C cloned push origin dev' )
      start( 'git -C cloned rev-parse HEAD~1' )

      .then( ( got ) =>
      {
        detachedVersion = _.strStrip( got.output );
        test.is( _.strDefined( detachedVersion ) );
        return null;
      })

      return con;
    })

    return ready;
  }

}

subModulesUpdateSwitchBranch.timeOut = 300000;

//

/* qqq : improve test coverage of submodulesVerify */
function submodulesVerify( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'command-versions-verify' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let localModulePathSrc = _.path.join( routinePath, 'module' );
  let localModulePathDst = _.path.join( routinePath, '.module/local' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : localModulePathSrc,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  let start3 = _.process.starter
  ({
    currentPath : localModulePathDst,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready.then( () =>
  {
    test.case = 'setup';
    return null;
  })

  start( '.with ./module/ .export' )
  start2( 'git init' )
  start2( 'git add -fA .' )
  start2( 'git commit -m init' )

  /* */

  .then( () =>
  {
    test.case = 'verify not downloaded';
    return null;
  })

  start( '.submodules.versions.verify' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '! Submodule opener::local does not have files' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'first verify after download';
    return null;
  })

  start( '.submodules.download' )
  start( '.submodules.versions.verify' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1 / 1 submodule(s) of module::submodules / module::local were verified' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'second verify';
    return null;
  })

  start( '.submodules.versions.verify' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1 / 1 submodule(s) of module::submodules / module::local were verified' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'new commit on local copy, try to verify';
    return null;
  })

  start3( 'git commit --allow-empty -m test' )

  start( '.submodules.versions.verify' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1 / 1 submodule(s) of module::submodules / module::local were verified' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'change branch';
    return null;
  })

  start3( 'git checkout -b testbranch' )

  start( '.submodules.versions.verify' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Submodule module::local has version different from that is specified in will-file' ) );
    return null;
  })

  return ready;
}

//

function versionsAgree( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'command-versions-agree' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let localModulePathSrc = _.path.join( routinePath, 'module' );
  let localModulePathDst = _.path.join( routinePath, '.module/local' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    throwingExitCode : 0,
    outputGraying : 1,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : localModulePathSrc,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  let start3 = _.process.starter
  ({
    currentPath : localModulePathDst,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready.then( () =>
  {
    test.case = 'setup';
    return null;
  })

  start( '.with ./module/ .export' )
  start2( 'git init' )
  start2( 'git add -fA .' )
  start2( 'git commit -m init' )

  /* */

  .then( () =>
  {
    test.case = 'agree not downloaded';
    return null;
  })

  start( '.submodules.versions.agree' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 1/1 submodule(s) of module::submodules were agreed in' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'agree after download';
    return null;
  })

  start( '.submodules.versions.agree' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/1 submodule(s) of module::submodules were agreed in' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'local is up to date with remote but has local commit';
    return null;
  })

  start3( 'git commit --allow-empty -m test' )
  start( '.submodules.versions.agree' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '+ 0/1 submodule(s) of module::submodules were agreed in' ) );
    return null;
  })
  start3( 'git status' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Your branch is ahead of \'origin\/master\' by 1 commit/ ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'local is not up to date with remote but has local commit';
    return null;
  })

  start2( 'git commit --allow-empty -m test' )
  start( '.submodules.versions.agree' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, 'module::local was agreed with version master in' ) );
    test.is( _.strHas( got.output, '+ 1/1 submodule(s) of module::submodules were agreed in' ) );
    return null;
  })
  start3( 'git status' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 2 commits` ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'local is not up to date with remote, no local changes';
    return null;
  })

  start3( 'git reset --hard origin' )
  start2( 'git commit --allow-empty -m test2' )
  start( '.submodules.versions.agree' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.is( _.strHas( got.output, '+ 1/1 submodule(s) of module::submodules were agreed in' ) );
    return null;
  })
  start3( 'git status' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Your branch is up to date/ ) );
    return null;
  })

  return ready;
}

//

function versionsAgreeNpm( test )
{
  let self = this;
  let a = self.assetFor( test, 'submodules-download-npm' );
  let versions = {}
  let willFilePath = a.abs( '.will.yml' );
  let filesBefore = null;
  
  /* - */

  a.ready
  
  .then( () =>
  {
    versions[ 'Tools' ] = _.npm.versionRemoteRetrive( 'npm:///wTools' );
    versions[ 'Path' ] = _.npm.versionRemoteRetrive( 'npm:///wpathbasic@alpha' );
    versions[ 'Uri' ] = _.npm.versionRemoteCurrentRetrive( 'npm:///wuribasic#0.6.131' );
    
    a.reflect();
    
    return null;
  })

  /* */
  
  a.start( '.submodules.versions.agree' )

  .then( ( got ) =>
  {
    test.case = 'agree npm modules';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 3 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, 'were agreed' ), 1 );
    test.identical( _.strCount( got.output, '+ 3/3 submodule(s) of module::supermodule were agreed' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was agreed with version ${versions['Tools']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Path was agreed with version ${versions['Path']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Uri was agreed with version ${versions['Uri']}` ), 1 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 1 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  .then( ( got ) =>
  { 
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, '@alpha', '@beta' );
    willFile = _.strReplace( willFile, '#0.6.131', '#0.6.122' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    versions[ 'Path' ] = _.npm.versionRemoteRetrive( 'npm:///wpathbasic@beta' );
    versions[ 'Uri' ] = '0.6.122'
    
    return null;
  })
  
  a.start( '.submodules.versions.agree' )

  .then( ( got ) =>
  { 
    test.case = 'second run of .submodules.versions.agree';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 11 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, '+ 2/3 submodule(s) of module::supermodule were agreed' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was agreed with version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was agreed with version ${versions['Path']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Uri was agreed with version ${versions['Uri']}` ), 1 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 1 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  a.start( '.submodules.versions.agree' )

  .then( ( got ) =>
  { 
    test.case = 'third run of .submodules.versions.agree';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 7 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, '+ 0/3 submodule(s) of module::supermodule were agreed' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was agreed with version ${versions['Tools']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Path was agreed with version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was agreed with version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Tools' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    return null;
  })
  
  /*  */
  
  .then( () => 
  {
    test.case = 'change origin of first submodule and run .submodules.versions.agree';
    
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wTools', 'npm:///wprocedure' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    versions[ 'Procedure' ] = _.npm.versionRemoteRetrive( 'npm:///wprocedure' );
    
    return null;
  })
  
  a.start( '.submodules.versions.agree' )
  
  .then( ( got ) =>
  { 
    test.case = 'third run of .submodules.versions.agree';
    
    test.identical( got.exitCode, 0 );

    var exp = [ 'Path', 'Path.will.yml', 'Tools', 'Tools.will.yml', 'Uri', 'Uri.will.yml' ];
    var files = _.fileProvider.dirRead( a.abs( '.module' ) )
    test.identical( files, exp );

    test.identical( _.strCount( got.output, '! Failed to open' ), 0 );
    test.identical( _.strCount( got.output, '. Opened .' ), 9 );
    test.identical( _.strCount( got.output, '+ Reflected' ), 0 );
    test.identical( _.strCount( got.output, '+ 1/3 submodule(s) of module::supermodule were agreed' ), 1 );
    
    test.identical( _.strCount( got.output, `module::Tools was agreed with version ${versions['Procedure']}` ), 1 );
    test.identical( _.strCount( got.output, `module::Path was agreed with version ${versions['Path']}` ), 0 );
    test.identical( _.strCount( got.output, `module::Uri was agreed with version ${versions['Uri']}` ), 0 );
    
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Tools` ), 1 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Path` ), 0 );
    test.identical( _.strCount( got.output, `Exported module::supermodule / module::Uri` ), 0 );
    
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Tools' ) );
    test.identical( version, versions[ 'Procedure' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Uri' ) );
    test.identical( version, versions[ 'Uri' ] )
    var version = _.npm.versionLocalRetrive( a.abs( '.module/Path' ) );
    test.identical( version, versions[ 'Path' ] )
    
    test.is( a.fileProvider.fileExists( a.abs( '.module/Tools/Tools.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Uri/Uri.out.will.yml' ) ) )
    test.is( a.fileProvider.fileExists( a.abs( '.module/Path/Path.out.will.yml' ) ) )
    
    var exp = 
    [
      '.',
      './dwtools',
      './dwtools/Tools.s',
      './dwtools/abase',
      './dwtools/abase/l8',
      './dwtools/abase/l8/Procedure.s'
    ];
    var files = self.find( a.abs( '.module/Tools/proto' ) ); 
    test.identical( files,exp );
    
    return null;
  })
  
  .then( () => 
  {
    let willFile = a.fileProvider.fileRead( willFilePath );
    willFile = _.strReplace( willFile, 'npm:///wprocedure', 'npm:///wTools' );
    a.fileProvider.fileWrite( willFilePath, willFile );
    
    a.reflect();
    
    return null;
  })
  
  /*  */

  return a.ready;
}

versionsAgreeNpm.timeOut = 300000;

//

function stepSubmodulesDownload( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-submodules-download' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
  _.fileProvider.filesDelete( _.path.join( routinePath, '.module' ) );
  _.fileProvider.filesDelete( _.path.join( routinePath, 'out/debug' ) );


  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    verbosity : 3,
    ready : ready
  })

  // /* - */
  //
  // start()
  //
  // .then( ( got ) =>
  // {
  //   test.case = 'simple run without args'
  //   test.identical( got.exitCode, 0 );
  //   test.is( got.output.length );
  //   return null;
  // })

  /* - */

  start({ execPath : '.resources.list' })

  .then( ( got ) =>
  {
    test.case = 'list'
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, `git+https:///github.com/Wandalen/wTools.git/out/wTools.out.will#master` ) );
    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = 'build'
    _.fileProvider.filesDelete( _.path.join( routinePath, '.module' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'out/debug' ) );
    return null;
  })

  start({ execPath : '.build' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.gt( self.find( _.path.join( routinePath, '.module/Tools' ) ).length, 70 );
    test.gt( self.find( _.path.join( routinePath, 'out/debug' ) ).length, 50 );
    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = 'export'
    _.fileProvider.filesDelete( _.path.join( routinePath, '.module' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'out/debug' ) );
    _.fileProvider.filesDelete( _.path.join( routinePath, 'out/Download.out.will.yml' ) );
    return null;
  })

  start({ execPath : '.export' })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.gt( self.find( _.path.join( routinePath, '.module/Tools' ) ).length, 85 );
    test.gt( self.find( _.path.join( routinePath, 'out/debug' ) ).length, 50 );
    test.is( _.fileProvider.isTerminal( _.path.join( routinePath, 'out/Download.out.will.yml' ) ) );
    return null;
  })

  /* - */

  return ready;
}

stepSubmodulesDownload.timeOut = 300000;

//

function stepWillbeVersionCheck( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-willbe-version-check' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let willbeRootPath = _.path.join( __dirname, '../../../..' );

  let assetDstPath = _.path.join( routinePath, 'asset' );
  let willbeDstPath = _.path.join( routinePath, 'willbe' );

  let nodeModulesSrcPath = _.path.join( willbeRootPath, 'node_modules' );
  let nodeModulesDstPath = _.path.join( willbeDstPath, 'node_modules' );

  if( !_.fileProvider.fileExists( _.path.join( willbeRootPath, 'package.json' ) ) )
  {
    test.is( true );
    return;
  }

  _.fileProvider.filesReflect
  ({
    reflectMap :
    {
      'proto/dwtools/Tools.s' : 'proto/dwtools/Tools.s',
      'proto/dwtools/atop/will' : 'proto/dwtools/atop/will',
      'package.json' : 'package.json',
    },
    src : { prefixPath : willbeRootPath },
    dst : { prefixPath : willbeDstPath },
  })
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : assetDstPath } })
  _.fileProvider.softLink( nodeModulesDstPath, nodeModulesSrcPath );

  let execPath = _.path.nativize( _.path.join( willbeDstPath, 'proto/dwtools/atop/will/Exec' ) );
  let ready = new _.Consequence().take( null )

  let start = _.process.starter
  ({
    execPath : 'node ' + execPath,
    currentPath : assetDstPath,
    outputCollecting : 1,
    throwingExitCode : 0,
    verbosity : 3,
    ready : ready
  })

  /* */

  start( '.build' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, /Built .+ \/ build::debug/ ) );
    return null;
  })

  .then( ( ) =>
  {
    let packageJsonPath = _.path.join( willbeDstPath, 'package.json' );
    let packageJson = _.fileProvider.fileRead({ filePath : packageJsonPath, encoding : 'json' });
    packageJson.version = '0.0.0';
    _.fileProvider.fileWrite({ filePath : packageJsonPath, encoding : 'json', data : packageJson });
    return null;
  })

  start( '.build' )
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'npm r -g willbe && npm i -g willbe' ) );
    test.is( _.strHas( got.output, /Failed .+ \/ step::willbe.version.check/ ) );
    return null;
  })

  return ready;
}

stepWillbeVersionCheck.timeOut = 15000;

//

function stepSubmodulesAreUpdated( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'step-submodules-are-updated' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let localModulePath = _.path.join( routinePath, 'module' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    throwingExitCode : 0,
    outputGraying : 1,
    ready : ready,
  })

  let start2 = _.process.starter
  ({
    currentPath : localModulePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  })

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  ready.then( () =>
  {
    test.case = 'setup';
    return null;
  })

  start( '.with ./module/ .export' )
  start2( 'git init' )
  start2( 'git add -fA .' )
  start2( 'git commit -m init' )
  start2( 'git commit --allow-empty -m test' )

  /* */

  .then( () =>
  {
    test.case = 'first build';
    return null;
  })

  start( '.build' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules were downloaded in' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'second build';
    return null;
  })

  start( '.build' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules were downloaded in' ) );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'new commit on remote, try to build';
    return null;
  })

  start2( 'git commit --allow-empty -m test' )

  start( '.build' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules were downloaded in' ) );
    test.is( _.strHas( got.output, '! Submodule relation::local is not up to date' ) );
    // test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'module is not downloaded';
    return null;
  })

  start( '.build debug2' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '! Submodule relation::local does not have files' ) );
    // test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'download path does not contain git repo';
    return null;
  })

  start( '.build debug3' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '! Submodule relation::local does not have files' ) );
    // test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /*  */

  .then( () =>
  {
    test.case = 'module is downloaded from different origin';
    return null;
  })

  start( '.build debug4' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '! Submodule relation::local has different origin url' ) );
    // test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /*  */

  .then( () =>
  {
    test.case = 'module is in detached state';
    return null;
  })

  start( '.build debug5' )

  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '! Submodule relation::local is not up to date' ) );
    // test.is( _.strHas( got.output, '0/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  /*  */

  .then( () =>
  {
    test.case = 'module is ahead remote';
    return null;
  })

  start( '.build debug6' )

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, '1/1 submodule(s) of module::submodules are up to date' ) );
    return null;
  })

  return ready;
}

stepSubmodulesAreUpdated.timeOut = 300000;

//

function upgradeDryDetached( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );
  let modulePath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:1 negative:1 -- after full update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.upgrade dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    // test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* will be upgraded to version/ ), 1 );
    // test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Proto\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Procedure\.informal\.will\.yml.* will be upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:1 negative:0 -- after full update';
    return null;
  })

  start({ execPath : '.submodules.upgrade dry:1 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    // test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* will be upgraded to version/ ), 1 );
    // test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Proto\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Procedure\.informal\.will\.yml.* will be upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:1 negative:1 -- after informal update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each module .export' })
  start({ execPath : '.submodules.upgrade dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    // test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* will be upgraded to version/ ), 1 );
    // test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 0 );
    // test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Proto\.informal\.will\.yml.* will be upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Procedure\.informal\.will\.yml.* will be upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:1 negative:1 -- after formal update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.update' })
  start({ execPath : '.submodules.upgrade dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* will be upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 2 );

    // test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* will be upgraded to version/ ), 1 );
    // test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /! .*upgradeDryDetached\/\.module\/Color\/\.im\.will\.yml.* won't be upgraded/ ), 1 );
    // test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/\.im\.will\.yml.* will be upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be upgraded/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* will be upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Proto\.informal\.will\.yml.* will be upgraded/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDryDetached\/module\/Procedure\.informal\.will\.yml.* will be upgraded/ ), 0 );

    return null;
  })

  /* - */

  return ready;
}

upgradeDryDetached.timeOut = 500000;

//

function upgradeDetached( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );
  let modulePath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:1 -- after full update';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.upgrade dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:0 -- after full update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.upgrade dry:0 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:1 -- after full update, second';
    return null;
  })

  start({ execPath : '.submodules.upgrade dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was skipped/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:0 -- after full update, second';
    return null;
  })

  start({ execPath : '.submodules.upgrade dry:0 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths/ ), 0 );
    test.identical( _.strCount( got.output, /was upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /will be upgraded/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was skipped/ ), 0 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:1 -- after informal update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each module .export' })
  start({ execPath : '.submodules.upgrade dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was upgraded/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was upgraded/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:1 -- after formal update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.update' })
  start({ execPath : '.submodules.upgrade dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.* : .* <- .*\.#622fb3c259013f3f6e2aeec73642645b3ce81dbc.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.* : .* <- .*\.#0.3.115.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Color\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/UriBasic\.informal\.will\.yml.* was upgraded/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.* : .* <- .*\.#70fcc0c31996758b86f85aea1ae58e0e8c2cb8a7.*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Proto\.informal\.out\.will\.yml.* was upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Proto\.informal\.will\.yml.* was upgraded/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was upgraded to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/out\/Procedure\.informal\.out\.will\.yml.* was upgraded/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/module\/Procedure\.informal\.will\.yml.* was upgraded/ ), 0 );

    return null;
  })

  /* - */

  return ready;
}

upgradeDetached.timeOut = 500000;

//

function upgradeDetachedExperiment( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached-single' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.upgrade dry:0 negative:1 -- after download';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })

  start({ execPath : '.submodules.download' })
  start({ execPath : '.submodules.upgrade dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was upgraded to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /! .*upgradeDetached\/\.module\/Tools\/\.im\.will\.yml.* was not upgraded/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*upgradeDetached\/\.im\.will\.yml.* was upgraded/ ), 1 );

    return null;
  })

  return ready;
}

upgradeDetachedExperiment.experimental = 1;

//

function fixateDryDetached( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );
  let modulePath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:1 negative:1 -- after full update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.fixate dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/\.im\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/module\/Proto\.informal\.will\.yml.* will be skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/Procedure\.informal\.will\.yml.* will be fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:1 negative:0 -- after full update';
    return null;
  })

  start({ execPath : '.submodules.fixate dry:1 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/\.im\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/module\/Proto\.informal\.will\.yml.* will be skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/Procedure\.informal\.will\.yml.* will be fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:1 negative:1 -- after informal update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each module .export' })
  start({ execPath : '.submodules.fixate dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/\.im\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/module\/Proto\.informal\.will\.yml.* will be skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/Procedure\.informal\.will\.yml.* will be fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:1 negative:1 -- after formal update';
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.update' })
  start({ execPath : '.submodules.fixate dry:1 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* will be fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Tools\/\.im\.will\.yml.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/\.im\.will\.yml.* will be fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/PathBasic\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* won't be fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.module\/Color\/\.im\.will\.yml.* will be skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/\.im\.will\.yml.* will be skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* will be fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/UriBasic\.informal\.out\.will\.yml.* will be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/UriBasic\.informal\.will\.yml.* will be fixated/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* won't be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/out\/Proto\.informal\.out\.will\.yml.* will be skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDryDetached\/module\/Proto\.informal\.will\.yml.* will be skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* will be fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/out\/Procedure\.informal\.out\.will\.yml.* will be fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDryDetached\/module\/Procedure\.informal\.will\.yml.* will be fixated/ ), 0 );

    return null;
  })

  /* - */

  return ready;
}

fixateDryDetached.timeOut = 500000;

//

function fixateDetached( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'submodules-detached' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );
  let filePath = _.path.join( routinePath, 'file' );
  let modulePath = _.path.join( routinePath, '.module' );
  let outPath = _.path.join( routinePath, 'out' );

  let ready = new _.Consequence().take( null );

  let start = _.process.starter
  ({
    execPath : 'node ' + self.willPath,
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
  });

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:1 -- after full update';
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.fixate dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/\.im\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:0 -- after full update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.export' })
  start({ execPath : '.submodules.fixate dry:0 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/\.im\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:1 -- after full update, second';
    return null;
  })

  start({ execPath : '.submodules.fixate dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 3 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was skipped/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:0 -- after full update, second';
    return null;
  })

  start({ execPath : '.submodules.fixate dry:0 negative:0' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths/ ), 0 );
    test.identical( _.strCount( got.output, /was fixated/ ), 0 );
    test.identical( _.strCount( got.output, /will be fixated/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/\.im\.will\.yml.* was fixated/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was fixated/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was fixated/ ), 0 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:1 -- after informal update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.each module .export' })
  start({ execPath : '.submodules.fixate dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/\.im\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was fixated/ ), 1 );

    return null;
  })

  /* - */

  ready
  .then( () =>
  {
    test.case = '.submodules.fixate dry:0 negative:1 -- after formal update';

    _.fileProvider.filesDelete({ filePath : routinePath })
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })

    return null;
  })

  start({ execPath : '.clean' })
  start({ execPath : '.submodules.update' })
  start({ execPath : '.submodules.fixate dry:0 negative:1' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Tools.* was fixated to version/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wTools\.git\/out\/wTools\.out\.will.* : .* <- .*\.#master.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/out\/wTools\.out\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Tools\/\.im\.will\.yml.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/\.im\.will\.yml.* was fixated/ ), 1 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::PathBasic.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wPathBasic\.git\/out\/wPathBasic\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/out\/wPathBasic\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/PathBasic\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Color.* was not fixated/ ), 1 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wColor\/out\/wColor\.out\.will.*/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/out\/wColor\.out\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.module\/Color\/\.im\.will\.yml.* was skipped/ ), 1 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/\.im\.will\.yml.* was skipped/ ), 2 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::UriBasic.* was fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wUriBasic\.git.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/UriBasic\.informal\.out\.will\.yml.* was fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/UriBasic\.informal\.will\.yml.* was fixated/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Proto.* was not fixated/ ), 0 );
    test.identical( _.strCount( got.output, /.*git\+https:\/\/\/github\.com\/Wandalen\/wProto\.git.*/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/out\/Proto\.informal\.out\.will\.yml.* was skipped/ ), 0 );
    test.identical( _.strCount( got.output, /! .*fixateDetached\/module\/Proto\.informal\.will\.yml.* was skipped/ ), 0 );

    test.identical( _.strCount( got.output, /Remote paths of .*module::submodules-detached \/ relation::Procedure.* was fixated to version/ ), 0 );
    test.identical( _.strCount( got.output, /.*npm:\/\/\/wprocedure.* : .* <- .*\..*/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/out\/Procedure\.informal\.out\.will\.yml.* was fixated/ ), 0 );
    test.identical( _.strCount( got.output, /\+ .*fixateDetached\/module\/Procedure\.informal\.will\.yml.* was fixated/ ), 0 );

    return null;
  })

  /* - */

  return ready;
}

fixateDetached.timeOut = 500000;

//

/*
  runWillbe checks if willbe can be terminated on early start from terminal when executed as child process using ExecUnrestricted script
*/

function runWillbe( test )
{

  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'run-willbe' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let execUnrestrictedPath = _.path.nativize( _.path.join( __dirname, '../will/ExecUnrestricted' ) );
  let ready = new _.Consequence().take( null );

  let fork = _.process.starter
  ({
    // execPath : 'node',
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : ready,
    mode : 'fork',
  });

  let start = _.process.starter
  ({
    currentPath : routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    mode : 'fork',
    ready : ready,
    mode : 'shell',
  });

  ready
  .then( () =>
  {
    _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } })
    return null;
  })

  /* */

  .then( () =>
  {
    test.case = 'execUnrestricted: terminate utility during heavy load of will files, should be terminated';
    let o = { args : [ execUnrestrictedPath, '.submodules.list' ], ready : null };

    let con = fork( o );

    o.process.stdout.on( 'data', ( data ) =>
    {
      if( _.bufferAnyIs( data ) )
      data = _.bufferToStr( data );
      if( _.strHas( data, 'wTools.out.will.yml' ) )
      {
        console.log( 'Terminating willbe...' );
        o.process.kill( 'SIGINT' )
        // o.process.stdin.write( '\x03\n' ); /* CTRL+C */
        // o.process.stdin.write( '~^C\n' ); /* CTRL+C */
      }
    });

    return test.shouldThrowErrorAsync( con )
    .then( () =>
    {
      if( process.platform === 'win32' )
      test.identical( o.exitCode, null );
      else
      test.identical( o.exitCode, 255 );
      test.identical( o.exitSignal, 'SIGINT' );
      test.is( _.strHas( o.output, 'wTools.out.will.yml' ) );
      test.is( !_.strHas( o.output, 'wLogger.out.will.yml' ) );
      test.is( !_.strHas( o.output, 'wLoggerToJs.out.will.yml' ) );
      test.is( !_.strHas( o.output, 'wConsequence.out.will.yml' ) );
      test.is( !_.strHas( o.output, 'wInstancing.out.will.yml' ) );

      return null;
    })
  })

  /* */

  .then( () =>
  {
    test.case = 'Exec: terminate utility during heavy load of will files, should fail'
    let o = { execPath : 'node', args : [ execPath, '.submodules.list' ], ready : null };
    let con = start( o );

    o.process.stdout.on( 'data', ( data ) =>
    {
      if( _.bufferAnyIs( data ) )
      data = _.bufferToStr( data );
      if( _.strHas( data, 'wTools.out.will.yml' ) )
      {
        console.log( 'Terminating willbe...' );
        // debugger;
        // o.process.kill( 'SIGTERM' );
        // o.process.kill( 'SIGINT' );
        o.process.kill( 'SIGINT' );
        // o.process.kill( 'SIGKILL' );
      }
    });

    return test.shouldThrowErrorAsync( con )
    .then( () =>
    {
      if( process.platform === 'win32' )
      test.identical( o.exitCode, null );
      else
      test.identical( o.exitCode, 255 );
      test.identical( o.exitSignal, 'SIGINT' );
      test.is( _.strHas( o.output, 'module::runWillbe / submodule::Tools' ) );
      test.is( _.strHas( o.output, 'module::runWillbe / submodule::Logger' ) );
      test.is( _.strHas( o.output, 'module::runWillbe / submodule::LoggerToJs' ) );
      return null;
    })

  })

  /* */

  return ready;
}

//

/*

Performance issue. Related with
- path map handling
- file filter forming
Disappeared as mystically as appeared.

*/

function resourcesFormReflectorsExperiment( test )
{
  let self = this;
  let originalAssetPath = _.path.join( self.suiteAssetsOriginalPath, 'performance2' );
  let routinePath = _.path.join( self.suiteTempPath, test.name );
  let abs = self.abs_functor( routinePath );
  let rel = self.rel_functor( routinePath );

  let moduleOldPath = _.path.join( routinePath, './old-out-file/' );
  let moduleNewPath = _.path.join( routinePath, './new-out-file/' );

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalAssetPath ] : routinePath } });

  let ready = new _.Consequence().take( null )

  /* */

  ready.then( () =>
  {
    /* This case uses out file of Starter that cause slow forming of reflector reflect.submodules from supermode */

    test.case = 'old version of out file from Starter module, works really slow';
    let o2 =
    {
      execPath : execPath,
      currentPath : moduleOldPath,
      args : [ '.submodules.list' ],
      mode : 'fork',
      outputCollecting : 1
    };

    let con = _.process.start( o2 );
    let t = _.time.out( 10000, () =>
    {
      o2.process.kill( 'SIGKILL' );
      throw _.err( 'TimeOut:10000, resources forming takes too long' );
    });

    return con.orKeepingSplit( t );
  })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'module::old-out-file / submodule::Starter' ) );
    test.is( _.strHas( got.output, 'path : git+https:///github.com/Wandalen/wStarter.git/out/wStarter#master' ) );
    test.is( _.strHas( got.output, 'autoExporting : 0' ) );
    test.is( _.strHas( got.output, 'enabled : 1' ) );
    test.is( _.strHas( got.output, "Exported builds : [ 'proto.export' ]" ) );
    test.is( _.strHas( got.output, "isDownloaded : false" ) );
    test.is( _.strHas( got.output, "isAvailable : false" ) );

    return null;
  })

  /* */

  ready.then( () =>
  {
    /* This case uses new out file of Starter forming of reflector reflect.submodules from supermode is fast */

    test.case = 'new version of out file from Starter module, works fast';

    let o2 =
    {
      execPath : execPath,
      currentPath : moduleNewPath,
      args : [ '.submodules.list' ],
      mode : 'fork',
      outputCollecting : 1
    };

    let con = _.process.start( o2 );
    let t = _.time.out( 10000, () =>
    {
      o2.process.kill( 'SIGKILL' );
      throw _.err( 'TimeOut : 10000, resources forming takes too long' );
    });

    return con.orKeepingSplit( t );
  })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'module::new-out-file / submodule::Starter' ) );
    test.is( _.strHas( got.output, 'path : git+https:///github.com/Wandalen/wStarter.git/out/wStarter#master' ) );
    test.is( _.strHas( got.output, 'autoExporting : 0' ) );
    test.is( _.strHas( got.output, 'enabled : 1' ) );
    test.is( _.strHas( got.output, "Exported builds : [ 'proto.export' ]" ) );
    test.is( _.strHas( got.output, "isDownloaded : false" ) );
    test.is( _.strHas( got.output, "isAvailable : false" ) );

    return null;
  })

  /* */

  return ready;
}

// --
// declare
// --

var Self =
{

  name : 'Tools.atop.WillExternals',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,
  routineTimeOut : 60000,

  context :
  {
    suiteTempPath : null,
    suiteAssetsOriginalPath : null,
    repoDirPath : null,
    willPath : null,
    find : null,
    findAll : null,
    assetFor,
    abs_functor,
    rel_functor,
  },

  tests :
  {

    preCloneRepos,
    singleModuleWithSpaceTrivial,
    make,
    transpile,
    moduleNewDotless,
    moduleNewDotlessSingle,
    moduleNewNamed,

    openWith,
    openEach,
    // withMixed, /* xxx : later */
    // eachMixed, // xxx : later
    withList,
    // eachList, // xxx : later
    eachBrokenIll,
    eachBrokenNon,
    eachBrokenCommand,
    openExportClean,

    // reflect

    reflectNothingFromSubmodules,
    reflectGetPath,
    reflectSubdir,
    reflectSubmodulesWithBase,
    reflectComposite,
    reflectRemoteGit,
    reflectRemoteHttp,
    reflectWithOptions,
    reflectWithSelectorInDstFilter,
    reflectSubmodulesWithCriterion,
    reflectSubmodulesWithPluralCriterionManualExport,
    reflectSubmodulesWithPluralCriterionEmbeddedExport,
    // relfectSubmodulesWithNotExistingFile, // zzz : uncomment after final transition to willbe
    reflectInherit,
    reflectInheritSubmodules,
    reflectComplexInherit,
    reflectorMasks,

    // with do

    withDoInfo,
    withDoStatus,
    withDoCommentOut,

    hookCallInfo,
    hookGitMake,
    hookPrepare,
    hookLink,
    hookGitPullConflict,
    hookGitSyncColflict,
    hookGitSyncArguments,

    verbositySet,
    verbosityStepDelete,
    verbosityStepPrintName,
    modulesTreeDotless,
    modulesTreeLocal,
    modulesTreeHierarchyRemote,
    // modulesTreeHierarchyRemoteDownloaded, /* xxx : later */
    // modulesTreeHierarchyRemotePartiallyDownloaded, /* xxx : later */
    modulesTreeDisabledAndCorrupted,

    help,
    listSingleModule,
    listWithSubmodulesSimple,
    listWithSubmodules,
    listSteps,

    clean,
    cleanSingleModule,
    cleanBroken1,
    cleanBroken2,
    cleanBrokenSubmodules,
    cleanHdBug,
    cleanNoBuild,
    cleanDry,
    cleanSubmodules,
    cleanMixed,
    cleanWithInPath,
    cleanRecursive,
    cleanDisabledModule,
    cleanHierarchyRemote,
    cleanHierarchyRemoteDry,
    cleanSubmodulesHierarchyRemote,
    cleanSubmodulesHierarchyRemoteDry,

    buildSingleModule,
    buildSingleStep,
    buildSubmodules,
    // buildDetached, /* xxx : later */

    exportSingle,
    exportItself,
    exportNonExportable,
    // exportInformal, /* xxx : later */
    exportWithReflector,
    exportToRoot,
    // exportMixed, /* xxx : later */
    exportSecond,
    exportSubmodules,
    exportMultiple,
    exportImportMultiple,
    exportBroken,
    exportDoc,
    exportImport,
    exportBrokenNoreflector,
    exportCourrputedOutfileUnknownSection,
    exportCourruptedOutfileSyntax,
    exportCourruptedSubmodulesDisabled,
    exportDisabledModule,
    exportOutdated,
    exportWholeModule,
    exportRecursive,
    exportRecursiveUsingSubmodule,
    exportRecursiveLocal,
    exportDotless,
    exportDotlessSingle,
    exportTracing,
    exportRewritesOutFile,
    exportWithRemoteSubmodules,
    exportDiffDownloadPathsRegular,
    exportHierarchyRemote,
    exportWithDisabled,
    exportOutResourceWithoutGeneratedCriterion,
    exportWillAndOut,
    /* xxx : implement same test for hierarchy-remote and irregular */
    /* xxx : implement clean tests */
    /* xxx : refactor ** clean */
    // exportAuto, // xxx : later
    reflectNpmModules,

    importPathLocal,
    // importLocalRepo, /* xxx : later */
    importOutWithDeletedSource,

    shellWithCriterion,
    shellVerbosity,

    functionStringsJoin,
    functionPlatform,
    functionThisCriterion,

    submodulesDownloadSingle,
    submodulesDownloadUpdate,
    submodulesDownloadUpdateDry,
    submodulesDownloadSwitchBranch,
    // submodulesDownloadRecursive,
    submodulesDownloadThrowing,
    submodulesDownloadStepAndCommand,
    submodulesDownloadDiffDownloadPathsRegular,
    submodulesDownloadDiffDownloadPathsIrregular,
    submodulesDownloadHierarchyRemote,
    submodulesDownloadHierarchyDuplicate,
    submodulesDownloadNpm,
    submodulesDownloadUpdateNpm,

    submodulesUpdateThrowing,
    submodulesAgreeThrowing,
    submodulesVersionsAgreeWrongOrigin,
    submodulesDownloadedUpdate,
    subModulesUpdate,
    subModulesUpdateSwitchBranch,
    submodulesVerify,
    versionsAgree,
    versionsAgreeNpm,

    stepSubmodulesDownload,
    stepWillbeVersionCheck,
    stepSubmodulesAreUpdated,

    /* xxx : cover "will .module.new.with prepare" */

    // upgradeDryDetached, // xxx : look later
    // upgradeDetached, // xxx : look later
    // upgradeDetachedExperiment, // xxx : look later
    // fixateDryDetached, // xxx : look later
    // fixateDetached, // xxx : look later

    // runWillbe, // zzz : help to fix, please

    // resourcesFormReflectorsExperiment, // xxx : look

  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();