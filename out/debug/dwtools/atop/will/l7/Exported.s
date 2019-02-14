( function _Exported_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

let Tar;

//

let _ = wTools;
let Parent = _.Will.Resource;
let Self = function wWillExported( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Exported';

// --
// inter
// --

function verify()
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let build = module.buildMap[ exported.name ];
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( !!module );
  _.assert( !!will );
  _.assert( !!hd );
  _.assert( !!logger );
  _.assert( !!build );
  _.assert( module.preformed === 3 );
  _.assert( will.formed === 1 );
  _.assert( build.formed === 3 );
  _.assert( exported.criterion === null );
  _.assert( build instanceof will.Build );

  _.sure( _.strDefined( module.dirPath ), 'Expects directory path of the module' );
  _.sure( _.objectIs( build.criterion ), 'Expects criterion of export' );
  _.sure( _.strDefined( build.name ), 'Expects name of export' );
  _.sure( _.objectIs( module.willFileWithRoleMap.import ) || _.objectIs( module.willFileWithRoleMap.single ), 'Expects import in fine' );
  _.sure( _.objectIs( module.willFileWithRoleMap.export ) || _.objectIs( module.willFileWithRoleMap.single ), 'Expects export in fine' );
  _.sure( _.strDefined( module.about.name ), 'Expects defined name of the module' );
  _.sure( _.strDefined( module.about.version ), 'Expects defined version of the module' );

}

//

function readExported()
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let build = module.buildMap[ exported.name ];
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;

  let outFilePath = build.outFilePathFor();
  let module2 = will.Module({ will : will, dirPath : path.dir( outFilePath ) }).preform();
  let willFiles = module2.willFilesSelect( outFilePath );
  let willFile = willFiles[ 0 ];

  if( !willFiles.length )
  {
    module2.finit();
    return;
  }

  _.assert( willFiles.length === 1 );
  _.assert( willFile.exists() );

  try
  {

    module2.willFilesOpen();
    module2.submodulesFormSkip();
    let con = module2.resourcesFormSkip();

    con
    .thenKeep( ( arg ) =>
    {
      if( willFile.data && willFile.data.exported )
      for( let exportedName in willFile.data.exported )
      {
        if( exportedName === exported.name )
        continue;
        let exported2 = module2.exportedMap[ exportedName ];
        _.assert( exported2 instanceof Self );
        module.resourceImport( exported2 );
      }
      return arg;
    })
    .finallyKeep( ( err, arg ) =>
    {
      try
      {
        module2.finit();
      }
      catch( err2 )
      {
        _.errLogOnce( err2 );
      }
      if( err )
      throw _.errLogOnce( _.errBriefly( err ) );
      return arg;
    })
    ;

    let result = con.toResource();
    return result;
  }
  catch( err )
  {
    _.errLogOnce( _.errBriefly( err ) );
  }

}

//

function proceedExportedReflectors( exportSelector )
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let build = exported.build;
  let step = exported.step;
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;

  _.assert( arguments.length === 1 );
  _.assert( !!module );
  _.assert( !!will );
  _.assert( !!hd );
  _.assert( !!logger );
  _.assert( !!build );
  _.assert( module.preformed === 3 );
  _.assert( will.formed === 1 );
  _.assert( build.formed === 3 );
  _.assert( _.objectIs( exported.criterion ) );
  _.assert( step instanceof will.Step );
  _.assert( build instanceof will.Build );
  _.assert( exported.exportedReflector === null );
  _.assert( exported.exportedDirPath === null );

  let exp = step.resolve( exportSelector );
  let exportedReflector;

  /* */

  if( exp instanceof will.Reflector )
  {

    _.assert( exp.formed === 3 );
    _.assert( exp.srcFilter.formed === 1 );
    _.sure( !!exp.filePath, () => exp.nickName + ' should have filePath' );

    exportedReflector = exp.cloneExtending({ name : module.resourceNameAllocate( 'reflector', 'exported.' + exported.name ) });

    _.assert( exportedReflector.srcFilter !== exp.srcFilter );
    _.assert( exportedReflector.srcFilter.prefixPath === null || exportedReflector.srcFilter.prefixPath === module.inPath );
    exportedReflector.srcFilter.prefixPath = null;

    let filter2 =
    {
      // maskTransientDirectory : { excludeAny : [ /\.git$/, /node_modules$/ ] },
    }

    exportedReflector.srcFilter.and( filter2 ).pathsInherit( filter2 );
    exportedReflector.srcFilter.filePath = exportedReflector.filePath;

  }
  else if( _.arrayIs( exp ) )
  {
    let commonPath = path.common.apply( path, exp );

    _.assert( path.isRelative( commonPath ) );

    exportedReflector = module.resourceAllocate( 'reflector', 'exported.' + exported.name );
    exportedReflector.srcFilter.filePath = Object.create( null );
    for( let p = 0 ; p < exp.length ; p++ )
    {
      _.assert( !_.strHas( exp[ p ], '::' ) );
      exportedReflector.srcFilter.filePath[ exp[ p ] ] = true;
    }
    exportedReflector.srcFilter.basePath = commonPath;

  }
  else if( _.strIs( exp ) )
  {

    _.assert( !_.strHas( exp, '::' ) );
    exportedReflector = module.resourceAllocate( 'reflector', 'exported.' + exported.name );
    exportedReflector.srcFilter.filePath = exp;

  }
  else _.assert( 0 );

  // debugger;
  exportedReflector.criterion = _.mapExtend( null, exported.criterion );
  exportedReflector.form();
  exported.exportedReflector = exportedReflector;
  // debugger;

  _.assert( _.mapIs( exportedReflector.criterion ) );
  _.assert( exportedReflector.dstFilter.prefixPath === null );
  _.assert( exportedReflector.dstFilter.basePath === null );
  _.assert( path.isAbsolute( exportedReflector.srcFilter.prefixPath ) );
  _.assert( exportedReflector instanceof will.Reflector );

  /* srcFilter */

  let srcFilter = exported.srcFilter = exportedReflector.srcFilter.clone();
  srcFilter._formBasePath();

  _.assert( srcFilter.formed === 3 );
  _.assert( _.mapIs( srcFilter.basePath ) );
  _.sure
  (
    srcFilter.basePaths.length === 1,
    () => 'Source filter for ' + exported.nickName + ' for ' + exportSelector + ' should have single-path reflect map or defined base path'
  );

  /* exportedDirPath */

  let exportedDirPath = srcFilter.basePaths[ 0 ];

  exported.exportedDirPath = module.resourceAllocate( 'path', 'exportedDir.' + exported.name );
  exported.exportedDirPath.path = path.dot( path.relative( module.dirPath, exportedDirPath ) ); // xxx
  exported.exportedDirPath.criterion = _.mapExtend( null, exported.criterion );
  exported.exportedDirPath.form();

}

//

function proceedExportedFilesReflector()
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;

  /* exportedFilesPath */

  exported.exportedFilesPath = module.resourceAllocate( 'path', 'exportedFiles.' + exported.name );
  exported.exportedFilesPath.criterion = _.mapExtend( null, exported.criterion );

  /* */

  let exportedFilesPath;
  try
  {

    exportedFilesPath = hd.filesFind
    ({
      recursive : 2,
      includingDirs : 1,
      includingTerminals : 1,
      mandatory : 0,
      verbosity : 0,
      outputFormat : 'record',
      filter : exported.srcFilter.clone(),
    });

  }
  catch( err )
  {
    throw _.err( 'Cant collect files for export\n', err );
  }

  exportedFilesPath = _.filter( exportedFilesPath, ( r ) => r.absolute );

  debugger;

  exported.exportedFilesPath.path = path.s.relative( module.dirPath, exportedFilesPath );

  // exported.exportedFilesPath.path = _.filter( exportedFilesPath, ( r ) => r.relative );

  _.sure
  (
    exported.exportedFilesPath.path.length > 0,
    () => 'No file found at ' + path.commonReport( exported.srcFilter.filePath )
    + ', cant export ' + exported.build.name,
  );

  exported.exportedFilesPath.form();

  /* exportedFilesReflector */

  let exportedFilesReflector = exported.exportedFilesReflector = exported.exportedReflector.cloneExtending({ name : module.resourceNameAllocate( 'reflector', 'exportedFiles.' + exported.name ) });

  _.assert( _.objectIs( exportedFilesReflector.criterion ) );
  _.assert( exportedFilesReflector.srcFilter.basePath === exported.exportedDirPath.path || exportedFilesReflector.srcFilter.basePath === null );
  exportedFilesReflector.srcFilter.filteringClear();
  _.assert( exportedFilesReflector.srcFilter.basePath === exported.exportedDirPath.path || exportedFilesReflector.srcFilter.basePath === null );
  _.assert( exportedFilesReflector.srcFilter.prefixPath === module.inPath || exportedFilesReflector.srcFilter.prefixPath === null );

  exportedFilesReflector.srcFilter.basePath = '.';
  exportedFilesReflector.srcFilter.prefixPath = exported.exportedDirPath.refName;

  _.assert( exportedFilesReflector.dstFilter.basePath === null );
  exportedFilesReflector.dstFilter.filteringClear();
  // exportedFilesReflector.filePath = { [ exported.exportedFilesPath.refName ] : true }
  exportedFilesReflector.filePath = path.fileMapExtend( null, exportedFilesPath );
  exportedFilesReflector.recursive = 0;
  exportedFilesReflector.form();

  _.assert( exportedFilesReflector.dstFilter.prefixPath === null );
  _.assert( exportedFilesReflector.dstFilter.basePath === null );

}

//

function proceedArchive( enabled )
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;
  let build = module.buildMap[ exported.name ];

  _.assert( exported.archiveFilePath === null );
  _.assert( arguments.length === 1 );

  /* archiveFilePath */

  if( !enabled )
  {
    exported.archiveFilePath = null;
    return;
  }

  let archiveFilePath = build.archiveFilePathFor();
  exported.archiveFilePath = module.resourceAllocate( 'path', 'archiveFile.' + exported.name );
  exported.archiveFilePath.path = path.dot( path.relative( module.dirPath, archiveFilePath ) );
  exported.archiveFilePath.criterion = _.mapExtend( null, exported.criterion );
  exported.archiveFilePath.form();

  /* */

  if( !Tar )
  Tar = require( 'tar' );

  let exportedDirPath = path.s.resolve( module.dirPath, exported.exportedDirPath.path );

  hd.dirMake( path.dir( archiveFilePath ) );

  _.sure( hd.fileExists( exportedDirPath ) );

  let o2 =
  {
    gzip : true,
    sync : 1,
    file : hd.path.nativize( archiveFilePath ),
    cwd : hd.path.nativize( exportedDirPath ),
  }

  let zip = Tar.create( o2, [ '.' ] );
  if( will.verbosity >= 3 )
  logger.log( ' + ' + 'Write out archive ' + hd.path.moveReport( archiveFilePath, exportedDirPath ) );

  /* */

  // if( exported.archiveFilePath )
  // exported.archiveFilePath = exported.archiveFilePath.refName;

}

//

function proceedOutFile()
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;
  let build = module.buildMap[ exported.name ];

  let outFilePath = build.outFilePathFor();
  let data = module.dataExport();

  hd.fileWrite
  ({
    filePath : outFilePath,
    data : data,
    encoding : 'yaml',
  });

  if( will.verbosity >= 3 )
  logger.log( ' + ' + 'Write out will-file ' + outFilePath );

}

//

function proceed( frame )
{
  let exported = this;
  let module = exported.module;
  let will = module.will;
  let build = module.buildMap[ exported.name ];
  let opts = frame.opts
  let hub = will.fileProvider;
  let hd = hub.providersWithProtocolMap.file;
  let path = hub.path;
  let logger = will.logger;
  let step = frame.resource;
  let time = _.timeNow();

  _.assert( arguments.length === 1 );
  _.assert( step instanceof will.Step );
  _.assert( exported.step === null || exported.step === step );
  _.assert( _.strDefined( opts.export ), () => step.nickName + ' should have options option export, path to directory to export or reflector' )

  exported.verify();

  exported.step = step;
  exported.build = build;
  exported.criterion = _.mapExtend( null, build.criterion );
  exported.version = module.about.version;

  /* */

  exported.readExported();
  exported.proceedExportedReflectors( opts.export );
  exported.proceedExportedFilesReflector();
  exported.proceedArchive( opts.tar === undefined || opts.tar );

  exported.proceedOutFile();

  /* log */

  if( will.verbosity >= 3 )
  logger.log( ' + Exported', exported.name, 'with', exported.exportedFilesPath.path.length, 'files', 'in', _.timeSpent( time ) );

  /* ref names */

  // exported.exportedFilesReflector = exported.exportedFilesReflector.refName;
  // exported.exportedReflector = exported.exportedReflector.refName;
  // exported.exportedDirPath = exported.exportedDirPath.refName;
  // exported.exportedFilesPath = exported.exportedFilesPath.refName;
  // if( _.objectIs( exported.archiveFilePath ) )
  // exported.archiveFilePath = exported.archiveFilePath.refName;

  return exported;
}

// --
// relations
// --

let Composes =
{

  version : null,
  description : null,
  criterion : null,
  inherit : _.define.own([]),

  exportedReflector : null,
  exportedFilesReflector : null,

  exportedDirPath : null,
  exportedFilesPath : null,
  archiveFilePath : null,

}

let Aggregates =
{
  name : null,
}

let Associates =
{
  step : null,
  build : null,
  module : null,
}

let Restricts =
{
  srcFilter : null,
}

let Statics =
{
  MapName : 'exportedMap',
  KindName : 'exported',
}

let Forbids =
{
  files : 'files',
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  // inter

  verify,
  readExported,
  proceedExportedReflectors,
  proceedExportedFilesReflector,
  proceedArchive,
  proceedOutFile,
  proceed,

  // relation

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

_.staticDecalre
({
  prototype : _.Will.prototype,
  name : Self.shortName,
  value : Self,
});

})();