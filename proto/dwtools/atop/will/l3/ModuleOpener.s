( function _ModuleOpener_s_( ) {

'use strict';

if( typeof opener !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

//

let _ = wTools;
let Parent = _.Will.AbstractModule;
let Self = function wWillModuleOpener( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ModuleOpener';

// --
// inter
// --

function finit()
{
  let opener = this;
  let will = opener.will;

  // if( opener.id === 210 )
  // debugger;

  _.assert( !opener.finitedIs() );

  opener.unform();

  if( will && will.mainOpener === opener )
  will.mainOpener = null;

  // will.openersErrorsRemoveOf( opener );

  return Parent.prototype.finit.apply( opener, arguments );
}

//

function init( o )
{
  let opener = this;

  _.assert( opener.dirPath === undefined );
  _.assert( opener._.dirPath === undefined );
  opener._.dirPath = null;
  opener._.localPath = null;
  opener._.downloadPath = null;
  opener._.remotePath = null;
  _.assert( opener.dirPath === null );
  _.assert( opener._.dirPath === null );

  if( o )
  opener.precopy( o );

  Parent.prototype.init.apply( opener, arguments );

  if( o )
  opener.copy( o );

  _.assert( !!o );
  _.assert( opener.unwrappedModuleOpener !== undefined );
  _.assert( opener.openedModule !== undefined );
  _.assert( opener.original !== undefined );

  return opener;
}

//

function unform()
{
  let opener = this;
  let will = opener.will;

  if( !opener.formed )
  return opener;

  _.assert( opener.superRelation === null );

  if( opener.openedModule )
  {
    let openedModule = opener.openedModule;
    opener.openedModule = null;
    if( !openedModule.isUsedManually() )
    openedModule.finit();
  }

  let variant = will.variantOf( opener );
  variant.remove( opener );

  opener.formed = 0;

  opener._willfilesRelease();
  will.openerUnregister( opener );

  return opener;
}

//

function preform()
{
  let opener = this;
  let will = opener.will;

  // if( opener.id === 308 )
  // debugger;

  if( opener.formed )
  {
    // _.assert( opener.formed >= 2 );
    return opener;
  }

  /* */

  _.assert( arguments.length === 0 );
  _.assert( !!opener.will );
  _.assert( _.strsAreAll( opener.willfilesPath ) || _.strIs( opener.dirPath ), 'Expects willfilesPath or dirPath' );
  _.assert( opener.formed === 0 );

  /* */

  opener._filePathChanged1();
  will.openerRegister( opener );
  will._willfilesReadBegin();

  /* */

  _.assert( arguments.length === 0 );
  _.assert( !!opener.will );
  _.assert( will.openerModuleWithIdMap[ opener.id ] === opener );
  _.assert( opener.dirPath === null || _.strDefined( opener.dirPath ) );
  _.assert( !!opener.willfilesPath || !!opener.dirPath );

  /* */

  opener.formed = 1;
  return end();

  /* */

  function end()
  {
    opener._remoteForm();
    _.assert( opener.formed >= 2 );
    return opener;
  }
}

//

function optionsForModuleExport()
{
  let opener = this;

  let Import =
  {

    will : null,
    rootModule : null,
    peerModule : null,
    willfilesArray : null,

    willfilesPath : null,
    localPath : null,
    downloadPath : null,
    remotePath : null,

    isRemote : null,
    isUpToDate : null,
    isOut : null,

  }

  let result = _.mapOnly( opener, Import );

  // if( opener.superRelation )
  // result.superRelations = [ opener.superRelation ]; // xxx

  result.willfilesArray = _.entityMake( result.willfilesArray );

  _.assert( _.boolLike( opener.isOut ), 'Expects defined {- opener.isOut -}' );

  return result;
}

//

function precopy( o )
{
  let opener = this;
  if( o.will )
  opener.will = o.will;
  if( o.superRelation )
  opener.superRelation = o.superRelation;
  if( o.original )
  opener.original = o.original;
  if( o.rootModule )
  opener.rootModule = o.rootModule;
  return o;
}

//

function copy( o )
{
  let opener = this;
  opener.precopy( o );

  _.assert( arguments.length === 1 );

  let read =
  {
    dirPath : null,
    localPath : null,
    downloadPath : null,
    remotePath : null,
  }
  let o2 = _.mapOnly( o, read );
  _.mapExtend( opener._, o2 );

  o = _.mapBut( o, read );
  let result = _.Copyable.prototype.copy.apply( opener, [ o ] );
  return result;
}

//

function clone()
{
  let opener = this;

  _.assert( arguments.length === 0 );

  let result = opener.cloneExtending({});

  return result;
}

//

function cloneExtending( o )
{
  let opener = this;

  _.assert( arguments.length === 1 );

  if( o.original === undefined )
  o.original = opener.original;
  if( opener.isMain && o.isMain === undefined )
  o.isMain = false;
  if( o.willfilesArray === undefined )
  o.willfilesArray = [];
  // if( o.moduleWithCommonPathMap === undefined )
  // o.moduleWithCommonPathMap = opener.moduleWithCommonPathMap;

  let result = _.Copyable.prototype.cloneExtending.call( opener, o );

  return result;
}

// --
// module
// --

function moduleAdopt( module )
{
  let opener = this;
  let will = opener.will;

  _.assert( !module.finitedIs() );
  _.assert( opener.openedModule === null );
  _.assert( arguments.length === 1 );
  _.assert( module instanceof _.Will.OpenedModule );

  let o2 = module.optionsForOpenerExport();
  opener.copy( o2 );
  // _.mapExtend( opener, o2 );

  opener.preform();
  // opener.remoteForm();

  opener.openedModule = module;

  if( opener.superRelation )
  opener.superRelation._moduleAdoptEnd();

  _.assert( opener.openedModule === module );
  _.assert( _.arrayHas( module.userArray, opener ) );

  return module;
}

//

function openedModuleSet( module )
{
  let opener = this;

  _.assert( arguments.length === 1 );
  _.assert( module === null || module instanceof _.Will.OpenedModule )

  // if( opener.id === 397 )
  // debugger;

  if( opener.openedModule === module )
  return module ;

  // if( opener.id === 128 )
  // debugger;

  // if( opener.superRelation && opener.openedModule )
  // opener.openedModule.superRelationsRemove( opener.superRelation );

  if( opener.openedModule )
  opener.openedModule.releasedBy( opener );

  // if( opener.superRelation && module )
  // module.superRelationsAppend( opener.superRelation );

  if( module )
  {
    module.usedBy( opener );
    opener.moduleUsePaths( module );
    opener.moduleUseError( module );
  }

  opener[ openedModuleSymbol ] = module;

  return module;
}

//

function moduleUsePaths( module )
{
  let opener = this;

  _.assert( arguments.length === 1 );
  _.assert( module instanceof _.Will.OpenedModule );

  opener._.dirPath = module.dirPath;
  opener._.commonPath = module.commonPath;
  // opener[ dirPathSymbol ] = module.dirPath;
  // opener[ commonPathSymbol ] = module.commonPath;

  opener.willfilesPath = module.willfilesPath;
  // opener.downloadPath = module.downloadPath;
  // opener.localPath = module.localPath;
  // opener.remotePath = module.remotePath;

opener._.downloadPath = module.downloadPath;
opener._.localPath = module.localPath;
opener._.remotePath = module.remotePath;

}

//

function moduleUseError( module )
{
  let opener = this;

  _.assert( arguments.length === 1 );
  _.assert( module instanceof _.Will.OpenedModule );

  if( module.ready.errorsCount() )
  opener.error = opener.error || module.ready.errorsGet()[ 0 ];

}

// --
// opener
// --

function close()
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let module = opener.openedModule;

  _.assert( !opener.finitedIs() );
  _.assert( arguments.length === 0 );
  _.assert( opener.formed >= 0 );

  if( module )
  {
    module.close();
    _.assert( module.isUsedBy( opener ) );
    opener.openedModule = null;
    _.assert( opener.openedModule === null );
    _.assert( !module.isUsedBy( opener ) );
  }

  if( opener.error )
  opener.error = null

  opener._willfilesRelease();

  if( opener.superRelation )
  opener.superRelation._closeEnd();

  if( opener.formed > 1 )
  {
    opener.formed = 1;
    opener._remoteForm();
  }

  if( module )
  {
    module.finit();
  }
}

//

function find( o )
{
  let opener = this;
  let will = opener.will;

  o = _.routineOptions( find, arguments );
  _.assert( _.arrayHas( [ 'smart', 'strict', 'exact' ], opener.searching ) );
  _.assert( opener.formed <= 2 );

  if( opener.openedModule )
  return opener.openedModule;

  try
  {

    opener.preform();
    // opener.remoteForm();

    _.assert( opener.formed >= 2 );

    let openedModule = opener.openedModule;
    if( !openedModule )
    openedModule = will.moduleAt( opener.willfilesPath );

    /* */

    if( !openedModule || !openedModule.willfilesArray.length )
    {

      opener._willfilesFind();

      if( !opener.error )
      if( !opener.willfilesArray.length )
      {
        debugger;
        opener.error = _.err( 'Found no will file at ' + _.strQuote( opener.dirPath ) );
      }

      /* get module from opened willfile, maybe */

      if( opener.willfilesArray.length )
      if( opener.willfilesArray[ 0 ].openedModule )
      openedModule = opener.willfilesArray[ 0 ].openedModule;

    }

    /* */

    if( opener.error )
    {
      throw opener.error;
    }

    /* */

    if( openedModule )
    {

      if( openedModule.rootModule !== opener.rootModule && !!opener.rootModule )
      if( openedModule.rootModule === openedModule )
      {
        openedModule.rootModule = opener.rootModule;
      }

      _.assert( !opener.willfilesArray.length || !openedModule.willfilesArray.length || _.arraysAreIdentical( opener.willfilesArray, openedModule.willfilesArray ) );
      if( opener.willfilesArray.length )
      openedModule.willfilesArray = _.entityMake( opener.willfilesArray );
      else
      opener.willfilesArray = _.entityMake( openedModule.willfilesArray );

      let o2 = opener.optionsForModuleExport();
      for( let f in o2 )
      {
        if( o2[ f ] !== null && openedModule[ f ] === null )
        {
          if( f !== 'peerModule' )
          debugger;
          openedModule[ f ] = o2[ f ];
        }
      }

      // _.assert( openedModule.rootModule === opener.rootModule || opener.rootModule === null );
      _.assert( opener.openedModule === openedModule || opener.openedModule === null );
      opener.openedModule = openedModule;

    }
    else
    {

      _.assert( opener.openedModule === null );
      let o2 = opener.optionsForModuleExport();
      openedModule = opener.openedModule = new will.OpenedModule( o2 );
      if( openedModule.rootModule === null )
      openedModule.rootModule = openedModule;
      openedModule.preform();

    }

    _.assert( _.arraysAreIdentical( opener.willfilesArray, opener.openedModule.willfilesArray ) );
    _.assert( _.arraysAreIdentical( _.mapVals( opener.willfileWithRoleMap ), _.mapVals( opener.openedModule.willfileWithRoleMap ) ) );

    if( !opener.openedModule.isUsedBy( opener ) )
    opener.openedModule.usedBy( opener );

    opener.formed = 3;

    return opener.openedModule;
  }
  catch( err )
  {
    err = _.err( err, `\nError looking for willfiles for module at ${opener.commonPath}` );
    opener.error = opener.error || err;
    if( o.throwing )
    throw err;
    return null;
  }

}

find.defaults =
{
  throwing : 1,
}

//

function open( o )
{
  let opener = this;
  let will = opener.will;
  let ready = new _.Consequence();

  o = _.routineOptions( open, arguments );

  try
  {

    // _.assert( opener.formed <= 3, () => `${opener.absoluteName} was already opened` );

    if( opener.error )
    throw opener.error;

    if( !opener.openedModule )
    opener.find();

    defaultsApply( o );

    _.assert( opener.formed >= 3 );

    if( opener.error )
    throw opener.error;

    let stager = opener.openedModule.stager;
    let rerun = false;

    let skipping = Object.create( null );
    skipping.attachedWillfilesFormed = !o.attachedWillfilesFormed;
    skipping.peerModulesFormed = !o.peerModulesFormed;
    skipping.subModulesFormed = !o.subModulesFormed;
    skipping.resourcesFormed = !o.resourcesFormed;

    // let processing = stager.stageStateBegun( 'opened' ) || ( stager.stageStateEnded( 'opened' ) && !stager.stageStateEnded( 'formed' ) );
    let processing = stager.stageStateBegun( 'opened' ) && !stager.stageStateEnded( 'formed' );
    _.assert( !processing, 'not tested' );

    for( let s in skipping )
    if( stager.stageStatePerformed( s ) )
    skipping[ s ] = false;
    else
    rerun = rerun || !skipping[ s ];

    if( !stager.stageStateEnded( 'opened' ) || rerun )
    {

      stager.stageStatePausing( 'opened', 0 );

      for( let s in skipping )
      {
        stager.stageStateSkipping( s, skipping[ s ] );
        if( !processing )
        if( !skipping[ s ] )
        if( stager.stageStateEnded( s ) && !stager.stageStatePerformed( s ) )
        stager.stageReset( s );
      }

      stager.tick();

    }

    // if( processing )
    // {
    //   // if( opener.formed === 3 )
    //   // opener.formed = 4;
    //   ready.take( opener.openedModule );
    // }
    // else
    opener.openedModule.ready.finally( ( err, arg ) =>
    {
      if( err )
      {
        handleError( err );
        throw err;
      }
      if( opener.formed === 3 )
      opener.formed = 4;
      ready.take( opener.openedModule );
      return arg;
    });

  }
  catch( err )
  {
    handleError( err );
    return ready;
  }

  return ready;

  /* */

  function handleError( err )
  {

    if( !err || !_.strIs( err.originalMessage ) || !_.strHas( err.originalMessage, 'Failed to open module at' ) )
    {
      err = _.err( err, `\nFailed to open module at ${opener.commonPath}` );
    }
    opener.error = opener.error || err;

    if( !o.throwing )
    _.errAttend( err );

    if( o.throwing )
    ready.error( err );
    else
    ready.take( null );

  }

  /* */

  function defaultsApply( o )
  {

    will.instanceDefaultsApply( o );

    let isMain = opener.isMain;

    if( !isMain && opener.openedModule && will.mainOpener && will.mainOpener.openedModule === opener.openedModule )
    isMain = true;

    opener.optionsFormingForward( o );

    if( o.attachedWillfilesFormed === null )
    o.attachedWillfilesFormed = isMain ? will.attachedWillfilesFormedOfMain : will.attachedWillfilesFormedOfSub;
    if( o.peerModulesFormed === null )
    o.peerModulesFormed = isMain ? will.peerModulesFormedOfMain : will.peerModulesFormedOfSub;
    if( o.subModulesFormed === null )
    o.subModulesFormed = isMain ? will.subModulesFormedOfMain : will.subModulesFormedOfSub;
    if( o.resourcesFormed === null )
    o.resourcesFormed = isMain ? will.resourcesFormedOfMain : will.resourcesFormedOfSub;

    o.attachedWillfilesFormed = !!o.attachedWillfilesFormed;
    o.peerModulesFormed = !!o.peerModulesFormed;
    o.subModulesFormed = !!o.subModulesFormed;
    o.resourcesFormed = !!o.resourcesFormed;

    return o;
  }

}

open.defaults =
{

  throwing : 1,
  attachedWillfilesFormed : null,
  peerModulesFormed : null,
  subModulesFormed : null,
  resourcesFormed : null,
  all : null,

}

//

function isOpened()
{
  let opener = this;
  return !!opener.openedModule && opener.openedModule.stager.stageStatePerformed( 'formed' );
}

//

function isValid()
{
  let opener = this;
  if( opener.error )
  return false;
  if( opener.openedModule )
  return opener.openedModule.stager.isValid();
  return true;
}

//

function isUsed()
{
  let opener = this;

  if( opener.openedModule )
  return true;
  if( opener.superRelation )
  return true;

  return false;
}

//

function usersGet()
{
  let opener = this;
  let result = [];
  if( opener.openedModule )
  result.push( opener.openedModule );
  if( opener.superRelation )
  result.push( opener.superRelation );
  return result;
}

// --
// willfiles
// --

function willfileUnregister( willf )
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  // _.arrayRemoveElementOnceStrictly( opener.willfilesArray, willf );
  _.arrayRemoveElementOnceStrictly( willf.openers, opener );

  // if( willf.role )
  // {
  //   _.assert( opener.willfileWithRoleMap[ willf.role ] === willf )
  //   delete opener.willfileWithRoleMap[ willf.role ];
  // }

  Parent.prototype.willfileUnregister.apply( opener, arguments );
}

//

function willfileRegister( willf )
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 1 );

  if( _.arrayIs( willf ) )
  {
    debugger;
    willf.forEach( ( willf ) => opener.willfileRegister( willf ) );
    return;
  }

  _.arrayAppendOnce( willf.openers, opener );

  Parent.prototype.willfileRegister.apply( opener, arguments );
}

//

function _willfilesFindAct( o )
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let filePaths;
  let records;

  o = _.routineOptions( _willfilesFindAct, arguments );
  o.willfilesPath = o.willfilesPath || opener.willfilesPath;

  _.assert( opener.willfilesArray.length === 0, 'not tested' );

  if( opener.searching === 'smart' )
  o.willfilesPath = opener.CommonPathFor( o.willfilesPath );

  if( opener.searching === 'exact' )
  {
    // debugger;
    o.willfilesPath = _.arrayAs( o.willfilesPath );
    records = o.willfilesPath.map( ( willfilePath ) => fileProvider.record( willfilePath ) );
    // records = fileProvider.record({ filePath : o.willfilesPath });
    // records = _.arrayAs( records );
    // debugger;
  }
  else
  {
    records = will.willfilesList
    ({
      dirPath : o.willfilesPath,
      includingInFiles : o.includingInFiles,
      includingOutFiles : o.includingOutFiles,
    });
  }

  for( let r = 0 ; r < records.length ; r++ )
  {
    let record = records[ r ];

    let willfOptions =
    {
      filePath : record.absolute,
      // dirPath : opener.dirPath,
    }
    let got = will.willfileFor({ willf : willfOptions, combining : 'supplement' });
    opener.willfileRegister( got.willf );

  }

}

_willfilesFindAct.defaults =
{
  willfilesPath : null,
  includingInFiles : 1,
  includingOutFiles : 1,
}

//

function _willfilesFind()
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let result = [];

  _.assert( arguments.length === 0 );

  /* */

  try
  {

    result = opener._willfilesFindAct();
    _.assert( !_.consequenceIs( result ) );
    if( opener.willfilesArray.length )
    _.assert( !!opener.willfilesPath && !!opener.dirPath );

  }
  catch( err )
  {
    err = _.err( err, '\nError looking for will files for', opener.qualifiedName, 'at', _.strQuote( opener.commonPath ) );
    opener.error = opener.error || err;
  }

  if( !opener.error )
  if( opener.willfilesArray.length === 0 )
  {
    let err;
    if( opener.superRelation )
    err = _.errBrief( 'Found no out-willfile file for',  opener.superRelation.qualifiedName, 'at', _.strQuote( opener.commonPath ) );
    else
    err = _.errBrief( 'Found no willfile at', _.strQuote( opener.commonPath ) );
    opener.error = opener.error || err;
  }

}

// --
// submodule
// --

function sharedFieldGet_functor( fieldName )
{
  let symbol = Symbol.for( fieldName );

  return function sharedFieldGet()
  {
    let opener = this;
    let openedModule = opener.openedModule;
    let will = opener.will;

    if( openedModule )
    return openedModule[ fieldName ];

    let result = opener[ symbol ];

    return result;
  }

}

//

function sharedFieldSet_functor( fieldName )
{
  let symbol = Symbol.for( fieldName );

  return function sharedModuleSet( src )
  {
    let opener = this;
    let openedModule = opener.openedModule;

    _.assert( src === null || src instanceof _.Will.OpenedModule );

    opener[ symbol ] = src;

    if( openedModule && openedModule[ fieldName ] !== src )
    openedModule[ fieldName ] = src;

    return src;
  }

}

let peerModuleGet = sharedFieldGet_functor( 'peerModule' );
let peerModuleSet = sharedFieldSet_functor( 'peerModule' );

let rootModuleGet = sharedFieldGet_functor( 'rootModule' );

//

function rootModuleSet( src )
{
  let opener = this;
  let openedModule = opener.openedModule;

  _.assert( src === null || src instanceof _.Will.OpenedModule );
  _.assert( src === null || src.rootModule === src || src.rootModule === null );

  opener[ rootModuleSymbol ] = src;

  if( openedModule && openedModule[ fieldName ] !== src )
  openedModule[ fieldName ] = src;

  return src;
}

//

function superRelationGet()
{
  let opener = this;
  _.assert( opener[ superRelationSymbol ] === undefined || opener[ superRelationSymbol ] === null || opener[ superRelationSymbol ] instanceof _.Will.ModulesRelation );
  return opener[ superRelationSymbol ];
}

//

function superRelationSet( src )
{
  let opener = this;
  let will = opener.will;

  _.assert( src === null || src instanceof _.Will.ModulesRelation );
  _.assert( src === null || src.opener === null || src.opener === opener )

  if( opener.openedModule && opener.superRelation )
  {
    opener.openedModule.superRelationsRemove( opener.superRelation );
  }

  opener[ superRelationSymbol ] = src;
  // opener._.superRelation = src;

  if( opener.openedModule && opener.superRelation )
  {
    opener.openedModule.superRelationsAppend( opener.superRelation );
  }

  return src;
}

// --
// remote
// --

function _remoteForm()
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( opener.formed >= 1 );

  // logger.log( '_remoteForm', opener.absoluteName ); debugger;

  opener.remoteIsUpdate();

  if( opener.isRemote )
  {
    opener._remoteFormAct();
  }
  else
  {
    opener._.localPath = opener.commonPath;
    opener.isDownloaded = true;
  }

  _.assert( will.openerModuleWithIdMap[ opener.id ] === opener );

  if( opener.formed < 2 )
  opener.formed = 2;

  /*
    should goes after setting formed
  */

  will.variantFrom( opener );

  return opener;
}

//

function _remoteFormAct()
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let willfilesPath = opener.remotePath || opener.willfilesPath;

  _.assert( _.strDefined( opener.aliasName ) );
  _.assert( !!opener.superRelation );
  _.assert( _.strIs( willfilesPath ) );

  let remoteProvider = fileProvider.providerForPath( opener.remotePath || opener.commonPath );

  _.assert( remoteProvider.isVcs && _.routineIs( remoteProvider.pathParse ), () => 'Seems file provider ' + remoteProvider.qualifiedName + ' does not have version control system features' );

  let submodulesDir = opener.superRelation.module.cloneDirPathGet();
  let parsed = remoteProvider.pathParse( willfilesPath );

  opener._.remotePath = willfilesPath;
  opener._.downloadPath = path.resolve( submodulesDir, opener.aliasName );
  let willfilesPath2 = path.resolve( submodulesDir, opener.aliasName, parsed.localVcsPath );
  opener._.localPath = opener.CommonPathFor( willfilesPath2 );
  opener._filePathChange( willfilesPath2 );
  opener.remoteIsDownloadedUpdate();

  _.assert( will.openerModuleWithIdMap[ opener.id ] === opener );

  return opener;
}

//

function _remoteDownload( o )
{
  let opener = this;
  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let time = _.timeNow();
  let downloading = null;
  let ready = _.Consequence().take( null );

  _.routineOptions( _remoteDownload, o );
  _.assert( arguments.length === 1 );
  _.assert( opener.formed >= 2 );
  _.assert( !!opener.willfilesPath );
  _.assert( _.strDefined( opener.aliasName ) );
  _.assert( _.strDefined( opener.remotePath ) );
  _.assert( _.strDefined( opener.downloadPath ) );
  _.assert( _.strDefined( opener.localPath ) );
  _.assert( !!opener.superRelation );
  _.assert( _.arrayHas( [ 'download', 'update', 'agree' ], o.mode ) );

  return ready
  .then( () => opener._remoteIsUpToDate({ mode : o.mode }) )
  .then( function( arg )
  {

    downloading = arg;
    _.assert( _.boolIs( downloading ) );

    if( !downloading )
    return downloading;

    if( o.mode === 'download' )
    {

      filesCheck();

    }
    else if( o.mode === 'update' )
    {
      //Vova: qqq Should throw error if not downloaded but opener.downloadPath exists
      filesCheck();
      originCheck();
      localChangesCheck();

    }
    else if( o.mode === 'agree' )
    {

      originCheck();
      localChangesCheck();
      filesDelete();

    }
    else _.assert( 0 );

    /*
    should goes after ifs
    */
    opener.error = null;

    return arg;
  })
  .then( () =>
  {
    return filesDownload();
  })
  .then( function( arg )
  {

    if( downloading && !o.dry )
    {
      opener.isDownloaded = true;
      opener.isUpToDate = true;
    }

    if( o.opening && !o.dry && downloading )
    moduleOpen();
    return null;
  })
  .finally( function( err, arg )
  {
    if( err )
    throw _.err( err, '\nFailed to', o.mode, opener.decoratedAbsoluteName );
    log();
    return downloading;
  });

  /* */

  function localChangesCheck()
  {

    /*
    if local repo has any changes then throw error with invitation to commit changes first
    */

    if( opener.isDownloaded )
    if( opener.remoteHasLocalChanges() )
    {
      throw _.errBrief
      (
        'Module at', opener.decoratedAbsoluteName, 'needs to be updated, but has local changes.',
        '\nPlease push your local changes to remote or stash them and merge manually after update.'
      );
    }
  }

  /* */

  function originCheck()
  {
    if( !opener.isDownloaded )
    return;

    let gitProvider = will.fileProvider.providerForPath( opener.remotePath );
    debugger;
    let result = gitProvider.isDownloadedFromRemote
    ({
      localPath : opener.downloadPath,
      remotePath : opener.remotePath
    });
    debugger;
    if( !result.downloadedFromRemote )
    throw _.err
    (
      'Module', opener.decoratedAbsoluteName, 'is already downloaded, but has different origin url:',
      _.color.strFormat( result.originVcsPath, 'path' ), ', expected url:', _.color.strFormat( result.remoteVcsPath, 'path' )
    );
  }

  /* */

  function filesCheck()
  {
    if( fileProvider.fileExists( opener.downloadPath ) )
    {
      throw _.err
      (
        'Module', opener.decoratedAbsoluteName, 'is not downloaded, but file at', _.color.strFormat( opener.downloadPath, 'path' ), 'exits.',
        'Rename/remove path:', _.color.strFormat( opener.downloadPath, 'path' ), 'and try again.'
      )
    }

  }

  /* */

  function filesDelete()
  {
    if( o.dry )
    return null;

    /*
    delete old remote opener if it has a critical error or downloaded files are corrupted
    */

    if( downloading )
    if( !opener.isValid() || !opener.isDownloaded )
    {
      if( fileProvider.fileExists( opener.downloadPath ) )
      debugger;
      fileProvider.filesDelete({ filePath : opener.downloadPath, throwing : 0, sync : 1 });
    }

  }

  /* */

  function filesDownload()
  {

    let o2 =
    {
      reflectMap : { [ opener.remotePath ] : opener.downloadPath },
      verbosity : will.verbosity - 5,
      extra : { fetching : 0 },
    }

    if( downloading && !o.dry )
    return will.Predefined.filesReflect.call( fileProvider, o2 );

    return null;
  }

  /* */

  function moduleOpen()
  {

    if( opener.openedModule )
    debugger;

    let willf = opener.willfilesArray[ 0 ]; // xxx : check
    opener.close();
    _.assert( opener.error === null );
    _.assert( !_.arrayHas( will.willfilesArray, willf ) );
    opener.find();

    return opener.open();
  }

  /* */

  function log()
  {
    let module = opener.openedModule ? opener.openedModule : opener;
    if( will.verbosity >= 3 && downloading )
    {
      if( o.dry )
      {
        let remoteProvider = fileProvider.providerForPath( opener.remotePath );
        let version = remoteProvider.versionRemoteCurrentRetrive( opener.remotePath );
        let phrase = '';
        if( o.mode === 'update' )
        phrase = ' to';
        else if( o.mode === 'agree' )
        phrase = ' with';
        logger.log( ' + ' + module.decoratedQualifiedName + ' will be ' + ( o.mode + phrase ) + ' version ' + _.color.strFormat( version, 'path' ) );
      }
      else
      {
        let remoteProvider = fileProvider.providerForPath( opener.remotePath );
        let version = remoteProvider.versionLocalRetrive( opener.downloadPath );
        let phrase = '';
        if( o.mode === 'update' )
        phrase = ' was updated to version ';
        else if( o.mode === 'agree' )
        phrase = ' was agreed with version ';
        else if( o.mode === 'download' )
        phrase = ' was downloaded version ';
        logger.log( ' + ' + module.decoratedQualifiedName + phrase + _.color.strFormat( version, 'path' ) + ' in ' + _.timeSpent( time ) );
      }
    }
  }

  /* */
}

_remoteDownload.defaults =
{
  mode : 'download',
  dry : 0,
  opening : 1,
  recursive : 0,
}

//

function remoteDownload()
{
  let opener = this;
  let will = opener.will;
  return opener._remoteDownload({ updating : 0 });
}

//

function remoteUpgrade()
{
  let opener = this;
  let will = opener.will;
  return opener._remoteDownload({ updating : 1 });
}

//

function remoteIsDownloadedUpdate()
{
  let module = this;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  _.assert( _.strDefined( module.downloadPath ) );
  _.assert( !!module.willfilesPath );
  _.assert( module.isRemote === true );

  let remoteProvider = fileProvider.providerForPath( module.remotePath );
  _.assert( !!remoteProvider.isVcs );

  let result = remoteProvider.isDownloaded
  ({
    localPath : module.downloadPath,
  });

  _.assert( !_.consequenceIs( result ) );

  if( !result )
  return end( result );

  return _.Consequence.From( result )
  .finally( ( err, arg ) =>
  {
    end( arg );
    if( err )
    throw err;
    return arg;
  });

  /* */

  function end( result )
  {
    module.isDownloaded = !!result;
    return result;
  }

}

//

function _remoteIsUpToDate( o )
{
  let opener = this;
  let ready = _.Consequence().take( null );

  ready
  .then( () =>
  {
    if( o.mode === 'download' )
    return opener.remoteIsDownloadedUpdate();
    else if( o.mode === 'update' )
    return opener.remoteIsUpToDateUpdate();
    else if( o.mode === 'agree' )
    return opener.remoteIsUpToDateUpdate();
  })
  .then( function()
  {
    let downloading = false;

    if( o.mode === 'download' )
    downloading = opener.isDownloaded;
    else if( o.mode === 'update' )
    downloading = opener.isUpToDate;
    else if( o.mode === 'agree' )
    downloading = opener.isUpToDate;
    _.assert( _.boolLike( downloading ) );
    downloading = !downloading;

    return !!downloading;
  });

  return ready;
}

_remoteIsUpToDate.defaults =
{
  mode : 'download',
}

// --
// path
// --

function _filePathChanged1( o )
{
  let opener = this;

  if( !this.will )
  return o;

  opener._filePathChanged2.call( opener, o );

  if( opener.openedModule && !o.isIdentical )
  debugger;
  if( opener.openedModule && !o.isIdentical )
  opener.openedModule._filePathChanged2({ willfilesPath : o.willfilesPath });

  return o;
}

_filePathChanged1.defaults = _.mapExtend( null, _.Will.AbstractModule.prototype._filePathChanged1.defaults );

//

function _filePathChanged2( o )
{
  let opener = this;

  if( !this.will )
  return o;

  let will = opener.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  o = Parent.prototype._filePathChanged2.call( opener, o );

  _.assert( _.boolIs( o.isIdentical ) );

  // opener[ dirPathSymbol ] = o.dirPath;
  opener._.dirPath = o.dirPath;

  if( o.commonPath )
  {
    // opener[ commonPathSymbol ] = o.commonPath;
    opener._.commonPath = o.commonPath;
    if( opener.isRemote === false )
    // opener[ localPathSymbol ] = o.commonPath;
    opener._.localPath = o.commonPath;
  }

  if( !o.isIdentical )
  if( opener.willfilesPath && opener.commonPath && opener.formed >= 2 )
  {
    will.variantFrom( opener );
  }

  return o;
}

_filePathChanged2.defaults = _.mapExtend( null, _.Will.AbstractModule.prototype._filePathChanged2.defaults );

//

// function remotePathSet( filePath )
// {
//   let opener = this;
//   let openedModule = opener.openedModule;
//   let was = opener[ remotePathSymbol ];
//   let isIdentical = was === filePath || _.entityIdentical( _.path.simplify( was ), _.path.simplify( filePath ) );
//
//   filePath = _.entityMake( filePath );
//   opener[ remotePathSymbol ] = filePath;
//
//   if( openedModule )
//   openedModule[ fieldName ] = filePath;
//
//   if( !isIdentical )
//   {
//     // opener._filePathChanged1();
//     if( opener.formed )
//     opener._remoteForm();
//   }
//
// }

// //
//
// function remotePathPut( filePath )
// {
//   let opener = this;
//   opener._.remotePath = filePath;
//   // opener[ remotePathSymbol ] = filePath;
// }

//

function sharedPathSet_functor( fieldName, signalingWillfilesChange, signalingRemotePathChange )
{
  let symbol = Symbol.for( fieldName );

  return function sharedPathSet( filePath )
  {
    let opener = this;
    let openedModule = opener.openedModule;
    let was = opener[ symbol ];
    let isIdentical = was === filePath || _.entityIdentical( _.path.simplify( was ), _.path.simplify( filePath ) );

    filePath = _.entityMake( filePath );
    opener[ symbol ] = filePath;

    if( openedModule )
    openedModule[ fieldName ] = filePath;

    if( signalingWillfilesChange )
    if( !isIdentical )
    opener._filePathChanged1();

    if( signalingRemotePathChange )
    if( !isIdentical )
    if( opener.formed )
    opener._remoteForm();

  }

}

//

function sharedFieldPut_functor( fieldName )
{
  let symbol = Symbol.for( fieldName );

  return function put( val )
  {
    let opener = this;

    // if( fieldName === 'commonPath' )
    // if( _.strEnds( val, '/pathsResolveOutFileOfExports' ) )
    // if( val && !_.path.isTrailed( val ) )
    // debugger;

    opener[ symbol ] = val;
    return val;
  }

}

//

let willfilesPathGet = sharedFieldGet_functor( 'willfilesPath' );
let dirPathGet = sharedFieldGet_functor( 'dirPath' );
let commonPathGet = sharedFieldGet_functor( 'commonPath' );
let downloadPathGet = sharedFieldGet_functor( 'downloadPath' );
let localPathGet = sharedFieldGet_functor( 'localPath' );
let remotePathGet = sharedFieldGet_functor( 'remotePath' );

let willfilesPathSet = sharedPathSet_functor( 'willfilesPath', 1, 1 );
// let downloadPathSet = sharedPathSet_functor( 'downloadPath', 0, 0 );
// let localPathSet = sharedPathSet_functor( 'localPath', 0, 0 );

let willfilesPathPut = sharedFieldPut_functor( 'willfilesPath' );
let dirPathPut = sharedFieldPut_functor( 'dirPath' );
let commonPathPut = sharedFieldPut_functor( 'commonPath' );
let downloadPathPut = sharedFieldPut_functor( 'downloadPath' );
let localPathPut = sharedFieldPut_functor( 'localPath' );
let remotePathPut = sharedFieldPut_functor( 'remotePath' );

// --
// name
// --

function nameGet()
{
  let opener = this;
  let name = null;

  if( !name && opener.aliasName )
  return opener.aliasName;

  if( !name && opener.openedModule && opener.openedModule.about && opener.openedModule.about.name )
  return opener.openedModule.about.name;

  if( !name && opener.fileName )
  return opener.fileName;

  if( !name && opener.openedModule )
  return opener.openedModule.name;

  if( !name && opener.commonPath )
  return _.uri.fullName( opener.commonPath );

  return null;
}

//

function _nameChanged()
{
  let opener = this;
  let will = opener.will;
  let openedModule = opener.openedModule;

  if( openedModule )
  openedModule._nameChanged();

}

//

function aliasNameSet( src )
{
  let opener = this;
  opener[ aliasNameSymbol ] = src;
  // opener._.aliasName = src;
  opener._nameChanged();
}

//

function qualifiedNameGet()
{
  let opener = this;
  let name = opener.name;
  return 'opener' + '::' + name;
}

//

function absoluteNameGet()
{
  let opener = this;
  let superRelation = opener.superRelation;
  if( superRelation )
  return superRelation.module.absoluteName + ' / ' + opener.qualifiedName;
  else
  return opener.qualifiedName;
}

//

function shortNameArrayGet()
{
  let opener = this;
  let superRelation = opener.openedModule.superRelation;
  if( !superRelation )
  return [ opener.name ];
  let result = superRelation.shortNameArrayGet();
  result.push( opener.name );
  return result;
}

// --
// other accessor
// --

function errorSet( err )
{
  let opener = this;
  let will = opener.will;

  if( opener.error === err )
  return;

  // if( err && opener.id === 301 )
  // debugger;

  opener[ errorSymbol ] = err;

  // if( will && err )
  // debugger;
  if( will && err )
  will.openersErrorsArray.push({ err : err, opener : opener });

  return err;
}

//

function isPreformed()
{
  let opener = this;
  return opener.formed >= 1;
}

//

function isMainGet()
{
  let opener = this;
  let will = opener.will;
  return will.mainOpener === opener;
}

//

function isMainSet( src )
{
  let opener = this;
  let will = opener.will;

  if( !will )
  return src;

  _.assert( src === null || _.boolLike( src ) );
  _.assert( will.mainOpener === null || will.mainOpener === opener || !src );

  // if( src )
  // debugger;

  if( src )
  will.mainOpener = opener;
  else if( will.mainOpener === opener )
  will.mainOpener = null;

  return src;
  // return opener.mainOpener === opener;
}

//

function accessorGet_functor( fieldName )
{
  let symbol = Symbol.for( fieldName );

  return function accessorGet()
  {
    let opener = this;
    let openedModule = opener.openedModule;

    if( openedModule )
    return openedModule[ fieldName ];

    let result = opener[ symbol ];

    return result;
  }

}

//

function accessorSet_functor( fieldName )
{
  let symbol = Symbol.for( fieldName );

  return function accessorSet( filePath )
  {
    let opener = this;
    let openedModule = opener.openedModule;

    opener[ symbol ] = filePath;
    if( openedModule )
    openedModule[ fieldName ] = filePath;

    return filePath;
  }

}

let isRemoteGet = accessorGet_functor( 'isRemote' );
let isUpToDateGet = accessorGet_functor( 'isUpToDate' );
let isOutGet = accessorGet_functor( 'isOut' );

let isRemoteSet = accessorSet_functor( 'isRemote' );
let isUpToDateSet = accessorSet_functor( 'isUpToDate' );
let isOutSet = accessorSet_functor( 'isOut' );

// --
// relations
// --

// let dirPathSymbol = Symbol.for( 'dirPath' );
// let commonPathSymbol = Symbol.for( 'commonPath' );
// let remotePathSymbol = Symbol.for( 'remotePath' );
// let localPathSymbol = Symbol.for( 'localPath' );
// let downloadPathSymbol = Symbol.for( 'downloadPath' );
let aliasNameSymbol = Symbol.for( 'aliasName' );
let superRelationSymbol = Symbol.for( 'superRelation' );
let rootModuleSymbol = Symbol.for( 'rootModule' );
let openedModuleSymbol = Symbol.for( 'openedModule' );
let errorSymbol = Symbol.for( 'error' );

let Composes =
{

  aliasName : null,

  willfilesPath : null,
  // downloadPath : null,
  // localPath : null,
  // remotePath : null,

  isRemote : null,
  isDownloaded : null,
  isUpToDate : null,
  isOut : null,
  isMain : null,
  isAuto : null,

  searching : 'strict', // 'smart', 'strict', 'exact'

}

// _.assert( Composes.downloadPath === undefined );

let Aggregates =
{
}

let Associates =
{

  original : null,
  will : null,
  rootModule : null,
  superRelation : null,
  willfilesArray : _.define.own([]),

}

let Medials =
{
  moduleWithCommonPathMap : null,
}

let Restricts =
{

  id : null,
  formed : 0,
  found : 0,
  error : null,
  openedModule : null,
  unwrappedModuleOpener : null,

}

let Statics =
{
}

let Forbids =
{
  moduleWithCommonPathMap : 'moduleWithCommonPathMap',
  allSubmodulesMap : 'allSubmodulesMap',
  moduleWithNameMap : 'moduleWithNameMap',
  willfilesReadTimeReported : 'willfilesReadTimeReported',
  submoduleAssociation : 'submoduleAssociation',
  currentRemotePath : 'currentRemotePath',
  opened : 'opened',
  pickedWillfileData : 'pickedWillfileData',
  pickedWillfilesPath : 'pickedWillfilesPath',
  willfilesReadBeginTime : 'willfilesReadBeginTime',
  willfilesReadTimeReported : 'willfilesReadTimeReported',
  finding : 'finding',
  inPath : 'inPath',
  outPath : 'outPath',
  willPath : 'willPath',
  preformed : 'preformed',
  supermoduleSubmodule : 'supermoduleSubmodule',
  supermodule : 'supermodule',
}

_.assert( _.routineIs( _.accessor.getter.toStructure ) );
_.assert( _.arrayHas( _.accessor.getter.toStructure.rubrics, 'functor' ) );

let Accessors =
{

  _ : { getter : _.accessor.getter.toStructure },

  willfilesPath : { getter : willfilesPathGet, setter : willfilesPathSet },
  dirPath : { getter : dirPathGet, readOnly : 1 },
  commonPath : { getter : commonPathGet, readOnly : 1 },
  localPath : { getter : localPathGet, readOnly : 1, },
  downloadPath : { getter : downloadPathGet, readOnly : 1 },
  remotePath : { getter : remotePathGet, readOnly : 1 },

  name : { getter : nameGet, readOnly : 1 },
  aliasName : { setter : aliasNameSet },
  absoluteName : { getter : absoluteNameGet, readOnly : 1 },
  qualifiedName : { getter : qualifiedNameGet, combining : 'rewrite', readOnly : 1 },

  isRemote : { getter : isRemoteGet, setter : isRemoteSet },
  isUpToDate : { getter : isUpToDateGet, setter : isUpToDateSet },
  isOut : { getter : isOutGet, setter : isOutSet },
  isMain : { getter : isMainGet, setter : isMainSet },

  superRelation : {},
  rootModule : {},
  openedModule : {},
  peerModule : {},

  error : { setter : errorSet },

}

// --
// declare
// --

let Extend =
{

  // inter

  finit,
  init,
  unform,
  preform,

  optionsForModuleExport,
  precopy,
  copy,
  clone,
  cloneExtending,

  // module

  moduleAdopt,
  openedModuleSet,
  moduleUsePaths,
  moduleUseError,

  // opener

  close,
  find,
  open,

  isOpened,
  isValid,
  isUsed,
  usersGet,

  // willfile

  willfileUnregister,
  willfileRegister,
  _willfilesFindAct,
  _willfilesFind,

  // submodule

  peerModuleGet,
  peerModuleSet,
  rootModuleGet,
  rootModuleSet,
  superRelationGet,
  superRelationSet,

  // remote

  _remoteForm,
  _remoteFormAct,
  _remoteDownload,
  remoteDownload,
  remoteUpgrade,
  remoteIsDownloadedUpdate,
  _remoteIsUpToDate,

  // path

  _filePathChanged1,
  _filePathChanged2,

  willfilesPathGet,
  dirPathGet,
  commonPathGet,

  downloadPathGet,
  localPathGet,
  remotePathGet,

  willfilesPathSet,

  willfilesPathPut,
  dirPathPut,
  commonPathPut,
  downloadPathPut,
  localPathPut,
  remotePathPut,

  // name

  nameGet,
  _nameChanged,
  aliasNameSet,
  absoluteNameGet,
  shortNameArrayGet,

  // other accessor

  errorSet,

  isPreformed,
  isMainGet,
  isMainSet,
  isRemoteGet,
  isUpToDateGet,
  isOutGet,

  isRemoteSet,
  isUpToDateSet,
  isOutSet,

  // relation

  Composes,
  Aggregates,
  Associates,
  Medials,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

// debugger;
// _.assert( Self.prototype.Composes.downloadPath === undefined );
// debugger;

Self.prototype[ Symbol.toStringTag ] = Object.prototype.toString;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

_.staticDeclare
({
  prototype : _.Will.prototype,
  name : Self.shortName,
  value : Self,
});

})();
