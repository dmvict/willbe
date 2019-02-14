( function _Reflector_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

//

let _ = wTools;
let Parent = _.Will.Resource;
let Self = function wWillReflector( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Reflector';

// --
// inter
// --

function init( o )
{
  let reflector = this;

  _.assert( o && o.module );

  let module = o.module;
  let will = module.will;
  let fileProvider = will.fileProvider;

  reflector.srcFilter = fileProvider.recordFilter();
  reflector.dstFilter = fileProvider.recordFilter();

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  let result = Parent.prototype.init.apply( reflector, arguments );

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  return result;
}

//

function form1()
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( !reflector.formed );

  _.assert( !!will );
  _.assert( !!module );
  _.assert( !!fileProvider );
  _.assert( !!logger );
  _.assert( !!will.formed );
  _.assert( module.preformed >= 2 );
  _.assert( !willf || !!willf.formed );
  _.assert( _.strDefined( reflector.name ) );

  // if( _.strHas( reflector.name, 'exported.export.' ) )
  // debugger;

  /* begin */

  module[ reflector.MapName ][ reflector.name ] = reflector;
  if( willf )
  willf[ reflector.MapName ][ reflector.name ] = reflector;

  reflector.srcFilter = reflector.srcFilter || {};

  if( reflector.srcFilter )
  {
    reflector.srcFilter.hubFileProvider = fileProvider;
    if( reflector.srcFilter.basePath )
    reflector.srcFilter.basePath = path.s.normalize( reflector.srcFilter.basePath );
    // reflector.srcFilter.basePath = path.s.normalize( path.s.join( module.dirPath, reflector.srcFilter.basePath ) );
    if( !reflector.srcFilter.formed )
    reflector.srcFilter._formAssociations();
  }

  reflector.dstFilter = reflector.dstFilter || {};

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  if( reflector.dstFilter )
  {
    reflector.dstFilter.hubFileProvider = fileProvider;

    if( reflector.dstFilter.basePath )
    reflector.dstFilter.basePath = path.s.normalize( reflector.dstFilter.basePath );
    // reflector.dstFilter.basePath = path.s.normalize( path.s.join( module.dirPath, reflector.dstFilter.basePath ) );
    if( !reflector.dstFilter.formed )
    reflector.dstFilter._formAssociations();
  }

  // if( reflector.filePath )
  // reflector.filePath = path.fileMapExtend( null, reflector.filePath, true );

  /* end */

  reflector.formed = 1;
  return reflector;
}

//

function form2()
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  // if( _.strHas( reflector.name, 'exported.export.' ) )
  // debugger;

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  /* filters */

  if( reflector.filePath )
  reflector.filePath = path.fileMapExtend( null, reflector.filePath, true );

  reflector.pathsResolve();

  let result = Parent.prototype.form2.apply( reflector, arguments );

  return result;
}

//

function _inheritMultiple( o )
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 1 );
  _.assert( reflector.formed === 1 );
  _.assert( _.arrayIs( reflector.inherit ) );
  _.routineOptions( _inheritMultiple, arguments );

  /* begin */

  Parent.prototype._inheritMultiple.call( reflector, o );

  if( reflector.filePath )
  {
    reflector._reflectMapForm({ visited : o.visited });
  }

  /* end */

  return reflector;
}

_inheritMultiple.defaults=
{
  ancestors : null,
  visited : null,
  defaultDst : true,
}

//

function _inheritSingle( o )
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let reflector2 = o.ancestor;

  _.assertRoutineOptions( _inheritSingle, arguments );
  _.assert( arguments.length === 1 );
  _.assert( reflector.formed === 1 );
  _.assert( reflector2 instanceof reflector.constructor, () => 'Expects reflector, but got', _.strType( reflector2 ) );
  _.assert( !!reflector2.formed );

  _.assert( reflector.srcFilter instanceof _.FileRecordFilter );
  _.assert( reflector.dstFilter instanceof _.FileRecordFilter );
  _.assert( reflector2.srcFilter instanceof _.FileRecordFilter );
  _.assert( reflector2.dstFilter instanceof _.FileRecordFilter );
  _.assert( _.entityIdentical( reflector.srcFilter.filePath, reflector.filePath ) );
  _.assert( _.entityIdentical( reflector2.srcFilter.filePath, reflector2.filePath ) );

  // if( _.strHas( reflector.name, 'exported.export.' ) )
  // debugger;

  if( reflector2.formed < 2 )
  {
    _.sure( !_.arrayHas( o.visited, reflector2.name ), () => 'Cyclic dependency ' + reflector.nickName + ' of ' + reflector2.nickName );
    reflector2._inheritForm({ visited : o.visited });
  }

  let extend = _.mapOnly( reflector2, _.mapNulls( reflector ) );

  delete extend.srcFilter;
  delete extend.dstFilter;
  delete extend.criterion;
  delete extend.filePath;

  reflector.copy( extend );
  reflector.criterionInherit( reflector2.criterion );

  reflector.srcFilter.and( reflector2.srcFilter ).pathsInherit( reflector2.srcFilter );

  if( _.mapIs( reflector.filePath ) )
  {
    // reflector.dstFilter.filePath = _.longRemoveDuplicates( _.mapVals( reflector.filePath ) );
    // reflector.dstFilter.filePath = reflector.dstFilter.filePath.filter( ( e ) => e === false ? false : true )
  }

  // logger.log( '_inheritSingle', reflector.nickName, '<-', reflector2.nickName );
  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  reflector.dstFilter.and( reflector2.dstFilter ).pathsInherit( reflector2.dstFilter );

}

_inheritSingle.defaults=
{
  ancestor : null,
  visited : null,
  defaultDst : true,
}

//

function form3()
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( reflector.formed === 2 );

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  /* begin */

  reflector.pathsResolve({ addingSrcPrefix : 1 });
  reflector.relative();
  reflector.sureRelativeOrGlobal();

  _.assert( path.isAbsolute( reflector.srcFilter.prefixPath ) );
  // _.assert( path.isAbsolute( reflector.dstFilter.prefixPath ) );

  /* end */

  // if( reflector.nickName === 'reflector::reflect.submodules' )
  // debugger;

  reflector.formed = 3;
  return reflector;
}

//

function _reflectMapForm( o )
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assertRoutineOptions( _reflectMapForm, arguments );

  let map = reflector.filePath;
  for( let r in map )
  {
    let dst = map[ r ];

    if( !_.boolIs( dst ) )
    {
      _.assert( _.strIs( dst ), 'not tested' );
      if( !module.strIsResolved( dst ) )
      dst = reflector.resolve
      ({
        query : dst,
        visited : o.visited,
        current : reflector,
      });
    }

    if( !module.strIsResolved( r ) )
    {

      let resolved = reflector.resolve
      ({
        query : r,
        visited : o.visited,
        current : reflector,
        mapVals : 1,
        unwrappingSingle : 1,
        flattening : 1,
      });

      if( !_.errIs( resolved ) && !_.strIs( resolved ) && !_.arrayIs( resolved ) && !( resolved instanceof will.Reflector ) )
      resolved = _.err( 'Source of reflects map was resolved to unexpected type', _.strType( resolved ) );
      if( _.errIs( resolved ) )
      throw _.err( 'Failed to form ', reflector.nickName, '\n', resolved );

      if( _.arrayIs( resolved ) )
      {
        resolved = path.s.normalize( resolved );

        delete map[ r ];
        for( let p = 0 ; p < resolved.length ; p++ )
        {
          let rpath = resolved[ p ];
          _.assert( _.strIs( rpath ) );

          if( path.isAbsolute( rpath ) && !path.isGlobal( rpath ) )
          debugger;
          if( path.isAbsolute( rpath ) && !path.isGlobal( rpath ) )
          rpath = path.s.relative( module.dirPath, rpath );

          map[ rpath ] = dst;
        }
      }
      else if( _.strIs( resolved ) )
      {
        resolved = path.normalize( resolved );

        if( path.isAbsolute( resolved ) && !path.isGlobal( resolved ) )
        resolved = path.s.relative( module.dirPath, resolved );

        delete map[ r ];
        map[ resolved ] = dst;
      }
      else if( resolved instanceof will.Reflector )
      {
        delete map[ r ];
        debugger;
        reflector._inheritSingle({ visited : o.visited, ancestor : resolved, defaultDst : dst });
        _.sure( !!resolved.filePath );
        path.fileMapExtend( map, resolved.filePath, dst );
      }

    }
  }

}

_reflectMapForm.defaults =
{
  visited : null,
}

//

function sureRelativeOrGlobal( o )
{
  let reflector = this;

  o = _.routineOptions( sureRelativeOrGlobal, arguments );
  _.assert( reflector.srcFilter instanceof _.FileRecordFilter );
  _.assert( reflector.dstFilter instanceof _.FileRecordFilter );
  _.assert( reflector.srcFilter.filePath === reflector.filePath );

  try
  {
    reflector.srcFilter.sureRelativeOrGlobal( o );
  }
  catch( err )
  {
    throw _.err( 'Source filter is ill-formed\n', err );
  }

  try
  {
    reflector.dstFilter.sureRelativeOrGlobal( o );
  }
  catch( err )
  {
    throw _.err( 'Destination filter is ill-formed\n', err );
  }

  return true;
}

sureRelativeOrGlobal.defaults =
{
  fixes : 0,
  basePath : 1,
  // stemPath : 1,
  filePath : 1,
}

//

function isRelativeOrGlobal( o )
{
  let reflector = this;

  o = _.routineOptions( isRelativeOrGlobal, arguments );

  _.assert( reflector.srcFilter instanceof _.FileRecordFilter );
  _.assert( reflector.dstFilter instanceof _.FileRecordFilter );
  _.assert( reflector.srcFilter.filePath === reflector.filePath );

  if( !reflector.srcFilter.isRelativeOrGlobal( o ) )
  return false;

  if( !reflector.dstFilter.isRelativeOrGlobal( o ) )
  return false;

  return true;
}

isRelativeOrGlobal.defaults =
{
  fixes : 0,
  basePath : 1,
  filePath : 1,
}

//

function relative()
{
  let reflector = this;
  let module = reflector.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let prefixPath;

  _.assert( arguments.length === 0 );
  _.assert( reflector.srcFilter.postfixPath === null, 'not implemented' );
  _.assert( reflector.dstFilter.postfixPath === null, 'not implemented' );

  prefixPath = reflector.srcFilter.prefixPath;

  if( prefixPath )
  {
    _.assert( path.isAbsolute( reflector.srcFilter.prefixPath ) );
    if( reflector.srcFilter.basePath )
    reflector.srcFilter.basePath = path.filter( reflector.srcFilter.basePath, relative );
    if( reflector.srcFilter.filePath )
    reflector.srcFilter.filePath = path.filter( reflector.srcFilter.filePath, relative );
    if( reflector.srcFilter.filePath )
    reflector.srcFilter.filePath = path.filter( reflector.srcFilter.filePath, relative );
  }

  prefixPath = reflector.dstFilter.prefixPath;

  if( prefixPath )
  {
    _.assert( path.isAbsolute( reflector.dstFilter.prefixPath ) );
    if( reflector.dstFilter.basePath )
    reflector.dstFilter.basePath = path.filter( reflector.dstFilter.basePath, relative );
    if( reflector.dstFilter.filePath )
    reflector.dstFilter.filePath = path.filter( reflector.dstFilter.filePath, relative );
    if( reflector.dstFilter.filePath )
    reflector.dstFilter.filePath = path.filter( reflector.dstFilter.filePath, relative );
  }

  /* */

  function relative( filePath )
  {
    if( _.strIs( filePath ) && path.isAbsolute( filePath ) )
    return path.relative( prefixPath, filePath );
    else
    return filePath;
  }

}

//

function pathsResolve( o )
{
  let reflector = this;
  let module = reflector.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( pathsResolve, arguments );

  if( reflector.srcFilter.basePath )
  reflector.srcFilter.basePath = path.filter( reflector.srcFilter.basePath, resolve );
  if( reflector.srcFilter.prefixPath )
  reflector.srcFilter.prefixPath = resolve( reflector.srcFilter.prefixPath );
  if( reflector.srcFilter.prefixPath || o.addingSrcPrefix )
  reflector.srcFilter.prefixPath = path.resolve( module.inPath, reflector.srcFilter.prefixPath || '.' );

  if( reflector.dstFilter.basePath )
  reflector.dstFilter.basePath = path.filter( reflector.dstFilter.basePath, resolve );
  if( reflector.dstFilter.prefixPath )
  reflector.dstFilter.prefixPath = resolve( reflector.dstFilter.prefixPath );
  if( reflector.dstFilter.prefixPath || o.addingDstPrefix )
  reflector.dstFilter.prefixPath = path.resolve( module.inPath, reflector.dstFilter.prefixPath || '.' );
  else if( reflector.dstFilter.filePath )
  reflector.dstFilter.prefixPath = path.common( reflector.dstFilter.filePath );

  /* */

  function resolve( src )
  {
    return reflector.resolve({ prefixlessAction : 'resolved', query : src });
  }

}

pathsResolve.defaults =
{
  addingSrcPrefix : 0,
  addingDstPrefix : 0,
}

//

function optionsForFindExport( o )
{
  let reflector = this;
  let module = reflector.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let result = Object.create( null );

  o = _.routineOptions( optionsForFindExport, arguments );
  _.assert( reflector.dstFilter === null || !reflector.dstFilter.hasFiltering() );

  result.recursive = reflector.recursive === null ? 2 : reflector.recursive;

  if( reflector.srcFilter )
  result.filter = reflector.srcFilter.clone();
  result.filter = result.filter || Object.create( null );
  result.filter.prefixPath = path.resolve( module.dirPath, result.filter.prefixPath || '.' );
  if( o.resolving )
  if( result.filter.basePath )
  result.filter.basePath = path.resolve( module.dirPath, result.filter.basePath );

  return result;
}

optionsForFindExport.defaults =
{
  resolving : 0,
}

//

function optionsForReflectExport( o )
{
  let reflector = this;
  let module = reflector.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let result = Object.create( null );

  o = _.routineOptions( optionsForReflectExport, arguments );
  _.assert( !o.resolving );

  result.recursive = reflector.recursive === null ? 2 : reflector.recursive;

  /* */

  if( reflector.srcFilter )
  result.srcFilter = reflector.srcFilter.clone();
  result.srcFilter = result.srcFilter || Object.create( null );
  result.srcFilter.prefixPath = path.resolve( module.dirPath, result.srcFilter.prefixPath || '.' );
  if( o.resolving )
  if( result.srcFilter.basePath )
  result.srcFilter.basePath = path.resolve( module.dirPath, result.srcFilter.basePath );

  if( reflector.dstFilter )
  result.dstFilter = reflector.dstFilter.clone();
  result.dstFilter = result.dstFilter || Object.create( null );
  result.dstFilter.prefixPath = path.resolve( module.dirPath, result.dstFilter.prefixPath || '.' );
  if( o.resolving )
  if( result.dstFilter.basePath )
  result.dstFilter.basePath = path.resolve( module.dirPath, result.dstFilter.basePath );

  /* */

  return result;
}

optionsForReflectExport.defaults =
{
  resolving : 0,
}

//

function infoExport()
{
  let reflector = this;
  let result = '';
  let fields = reflector.dataExport();

  _.assert( reflector.formed > 0 );

  result += reflector.nickName;
  result += '\n' + _.toStr( fields, { wrap : 0, levels : 4, multiline : 1 } );
  result += '\n';

  return result;
}

//

function dataExport()
{
  let reflector = this;
  let module = reflector.module;
  let willf = reflector.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  _.assert( reflector.srcFilter instanceof _.FileRecordFilter );

  let result = Parent.prototype.dataExport.apply( this, arguments );
  delete result.filePath;

  if( result.srcFilter && result.srcFilter.prefixPath && path.isAbsolute( result.srcFilter.prefixPath ) )
  result.srcFilter.prefixPath = path.relative( module.inPath, result.srcFilter.prefixPath );

  if( result.dstFilter && result.dstFilter.prefixPath && path.isAbsolute( result.dstFilter.prefixPath ) )
  result.dstFilter.prefixPath = path.relative( module.inPath, result.dstFilter.prefixPath );

  return result;
}

dataExport.defaults =
{
  compact : 1,
  copyingAggregates : 0,
}

//

function filePathGet()
{
  let reflector = this;
  if( !reflector.srcFilter )
  return null;
  return reflector.srcFilter.filePath;
}

//

function filePathSet( src )
{
  let reflector = this;
  if( !reflector.srcFilter && src === null )
  return src;
  _.assert( _.objectIs( reflector.srcFilter ), 'Reflector should have srcFilter to set filePath' );
  reflector.srcFilter.filePath = _.entityShallowClone( src );
  return reflector.srcFilter.filePath;
}

// --
// relations
// --

let Composes =
{

  description : null,
  recursive : null,
  filePath : null,
  srcFilter : null,
  dstFilter : null,
  criterion : null,

  inherit : _.define.own([]),

}

let Aggregates =
{
  name : null,
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
  KindName : 'reflector',
  MapName : 'reflectorMap',
}

let Forbids =
{
  inherited : 'inherited',
  filter : 'filter',
  parameter : 'parameter',
  reflectMap : 'reflectMap',
}

let Accessors =
{
  filePath : { setter : filePathSet, getter : filePathGet },
  srcFilter : { setter : _.accessor.setter.copyable({ name : 'srcFilter', maker : _.routineJoin( _.FileRecordFilter, _.FileRecordFilter.Clone ) }) },
  dstFilter : { setter : _.accessor.setter.copyable({ name : 'dstFilter', maker : _.routineJoin( _.FileRecordFilter, _.FileRecordFilter.Clone ) }) },
}

_.assert( _.routineIs( _.FileRecordFilter ) );

// --
// declare
// --

let Extend =
{

  // inter

  init,
  form1,
  form2,

  _inheritMultiple,
  _inheritSingle,

  form3,

  _reflectMapForm,

  sureRelativeOrGlobal,
  isRelativeOrGlobal,
  relative,
  pathsResolve,

  // exporter

  optionsForFindExport,
  optionsForReflectExport,
  infoExport,
  dataExport,

  // accessor

  filePathGet,
  filePathSet,

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
  extend : Extend,
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