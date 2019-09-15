( function _Resource_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

//

let _ = wTools;
let Parent = null;
let Self = function wWillResource( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Resource';

// --
// inter
// --

function MakeFor_pre( routine, args )
{
  let o = args[ 0 ];

  _.routineOptions( routine, o );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 2 );

  return o;
}

function MakeFor_body( o )
{
  let Cls = this;

  _.assertRoutineOptions( MakeFor_body, arguments );

  if( !o.resource )
  return;

  _.assert( _.constructorIs( Cls ) );
  _.assert( arguments.length === 1 );
  _.assert( !!o.resource );
  _.assert( !!o.willf );
  _.assert( !!o.module );

  let o2 = Object.create( null );

  o2.Optional = o.Optional;
  o2.Rewriting = o.Rewriting;
  o2.Importing = o.Importing;
  o2.IsOutFile = o.IsOutFile;

  if( Cls.ResouceDataFrom )
  o2.resource = Cls.ResouceDataFrom( o.resource );
  else
  o2.resource = _.mapExtend( null, o.resource );

  _.assert( o.resource !== o2.resource );

  o2.resource.willf = o.willf;
  o2.resource.module = o.module;
  o2.resource.name = o.name;

  if( o2.Importing === null )
  o2.Importing = 1;
  if( o2.IsOutFile === null )
  o2.IsOutFile = o.willf.isOutFile;

  Cls.MakeForEachCriterion( o2 );

}

MakeFor_body.defaults =
{

  module : null,
  willf : null,
  resource : null,
  name : null,

  Optional : null,
  Rewriting : null,
  Importing : null,
  IsOutFile : null,

}

let MakeFor = _.routineFromPreAndBody( MakeFor_pre, MakeFor_body );

//

function MakeForEachCriterion( o )
{
  let Cls = this;
  let args = arguments;
  let result = [];
  let module = o.resource.module;
  let will = module.will;

  try
  {
    return safe();
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Cant form', Cls.KindName + '::' + o.name, '\n', err );
  }

  /* */

  function safe()
  {
    let counter = 0;
    let isSingle = true;

    _.assert( args.length === 1 );
    _.assert( _.mapIs( o ) );
    _.assert( _.mapIs( o.resource ) );
    _.assert( _.objectIs( o.resource.module ) );
    _.assert( _.strDefined( o.resource.name ) );

    if( o.resource.criterion )
    o.resource.criterion = Cls.CriterionMapResolve( module, o.resource.criterion );

    if( o.resource.criterion )
    o.resource.criterion = Cls.CriterionNormalize( o.resource.criterion );

    if( o.resource.criterion && _.mapKeys( o.resource.criterion ).length > 0 )
    {
      let samples = _.eachSample({ sets : o.resource.criterion });
      if( samples.length > 1 )
      for( let index = 0 ; index < samples.length ; index++ )
      {
        let criterion = samples[ index ];
        let o2 = _.mapExtend( null, o );
        o2.resource = _.mapExtend( null, o.resource );
        let postfix = Cls.CriterionPostfixFor( samples, criterion );

        o2.resource.criterion = criterion;
        o2.resource.name = o.resource.name + '.' + postfix;

        isSingle = false;

        if( o2.Optional )
        if( module[ Cls.MapName ][ o2.resource.name ] )
        continue;

        single( o2 );
        counter += 1;
      }
    }

    if( isSingle )
    {
      single( o );
      counter += 1;
    }

    return result;
  }

  /* */

  function single( o )
  {

    try
    {

      _.assert( o.resource.module instanceof will.OpenedModule );
      _.assert( !!o.resource.module[ Cls.MapName ] );
      let instance = o.resource.module[ Cls.MapName ][ o.resource.name ];
      if( instance )
      {
        _.sure( !!Cls.OnInstanceExists, 'Instance ' + Cls.KindName + '::' + o.resource.name + ' already exists' );
        o.instance = instance;
        Cls.OnInstanceExists( o );
      }

      let optional = !!o.Optional;
      let rewriting = !!o.Rewriting;
      let importing = !!o.Importing;
      let isOutFile = !!o.IsOutFile;

      if( o.resource.importable !== undefined && !o.resource.importable )
      if( importing )
      {
        return;
      }

      if( instance && rewriting )
      instance.finit();

      let r = Cls( o.resource ).form1();
      result.push( r );
      return r;
    }
    catch( err )
    {
      throw _.err( 'Criterions\n', _.toStr( o.resource.criterion ), '\n', err );
    }

  }

}

MakeForEachCriterion.defaults =
{
  Optional : null,
  Rewriting : null,
  Importing : null,
  IsOutFile : null,
  resource : null,
}

//

function ResouceDataFrom( o )
{
  _.assert( arguments.length === 1 );
  return _.mapExtend( null, o );
}

//

function finit()
{
  let resource = this;
  _.assert( !_.workpiece.isFinited( resource ) );
  if( resource.formed )
  resource.unform();
  resource.module = null;
  return _.Copyable.prototype.finit.apply( resource, arguments );
}

//

function init( o )
{
  let resource = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.Will.ResourceCounter += 1;
  resource.id = _.Will.ResourceCounter;
  resource.criterion = Object.create( null );

  _.workpiece.initFields( resource );
  Object.preventExtensions( resource );

  if( o )
  resource.copy( o );

  return resource;
}

//

function copy( o )
{
  let resource = this;
  _.assert( _.objectIs( o ) );
  _.assert( arguments.length === 1 );

  if( o.name !== undefined )
  resource.name = o.name;

  if( _.mapIs( o ) )
  if( o.module !== undefined )
  resource.module = o.module;

  let result = _.Copyable.prototype.copy.call( resource, o );

  let module = o.module !== undefined ? o.module : resource.module;
  if( o.unformedResource )
  resource.unformedResource = o.unformedResource.cloneExtending({ original : resource, module : module });

  return result;
}

//

function cloneDerivative()
{
  let resource = this;

  if( resource.original )
  return resource;

  let resource2 = resource.clone();

  _.assert( arguments.length === 0 );

  resource2.module = resource.module;
  resource2.willf = resource.willf;
  resource2.original = resource.original || resource;
  resource2.formed = resource.formed;
  resource2.unformedResource = resource.unformedResource;

  return resource2;
}

//

function unform()
{
  let resource = this;
  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( resource.formed );

  if( resource.original )
  _.assert( module[ resource.MapName ][ resource.name ] === resource.original );
  else
  _.assert( module[ resource.MapName ][ resource.name ] === resource );

  /* begin */

  if( !resource.original )
  {
    delete module[ resource.MapName ][ resource.name ];
  }

  /* end */

  resource.formed = 0;
  return resource;
}

//

function form()
{
  _.assert( !!this.module );

  let resource = this;
  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  if( resource.formed === 0 )
  resource.form1();
  if( resource.formed === 1 )
  resource.form2();
  if( resource.formed === 2 )
  resource.form3();

  _.assert( resource.formed === 3 );

  return resource;
}

//

function form1()
{
  let resource = this;

  _.assert( !!resource.module );
  _.assert( !!resource.module.will );

  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( !resource.formed );
  _.assert( !!will );
  _.assert( !!module );
  _.assert( !!fileProvider );
  _.assert( !!logger );
  _.assert( !!will.formed );
  _.assert( !willf || !!willf.formed );
  _.assert( _.strDefined( resource.name ) );

  if( !resource.original )
  {
    _.sure( !module[ resource.MapName ][ resource.name ], () => 'Module ' + module.dirPath + ' already has ' + resource.nickName );
  }

  /* begin */

  resource.criterion = resource.criterion || Object.create( null );

  for( let c in resource.criterion )
  {
    if( _.arrayIs( resource.criterion[ c ] ) && resource.criterion[ c ].length === 1 )
    resource.criterion[ c ] = resource.criterion[ c ][ 0 ];
  }

  if( !resource.original )
  {
    module[ resource.MapName ][ resource.name ] = resource;
  }

  /* end */

  resource.formed = 1;
  return resource;
}

//

function form2( o )
{
  let resource = this;
  let module = resource.module;
  o = o || Object.create( null );

  if( resource.formed >= 2 )
  return resource;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( resource.formed === 1 );

  /* begin */

  o.visited = o.visited || [];
  resource._inheritForm( o )
  // resource._inheritForm({ visited : [] })

  /* end */

  _.assert( _.mapIs( resource.criterion ) );
  resource.criterionValidate();

  resource.formed = 2;
  return resource;
}

//

function _inheritForm( o )
{
  let resource = this;
  let module = resource.module;
  let original = resource.original;

  if( resource.inherited === 1 )
  return resource;

  _.assert( arguments.length === 1 );
  _.assert( resource.formed === 1 );
  _.assert( resource.inherited === 0 );
  _.assert( _.arrayIs( resource.inherit ) );
  _.assert( o.ancestors === undefined );
  _.arrayAppendOnceStrictly( o.visited, resource );

  resource.inherited = 1;

  /* begin */

  o.ancestors = resource.inherit;
  resource._inheritMultiple( o );

  /* end */

  _.arrayRemoveElementOnceStrictly( o.visited, resource );
  _.assert( original === resource.original );
  _.assert( resource.inherited === 1 );

  return resource;
}

//

function _inheritMultiple( o )
{
  let resource = this;
  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  /* begin */

  for( let a = o.ancestors.length-1 ; a >= 0 ; a-- )
  {
    let ancestor = o.ancestors[ a ];

    _.assert( _.strIs( resource.KindName ) );
    _.assert( _.strIs( ancestor ) );

    let ancestors = module.resolve
    ({
      selector : ancestor,
      defaultResourceKind : resource.KindName,
      prefixlessAction : 'default',
      visited : o.visited,
      currentContext : resource,
      mapFlattening : 1,
    });

    if( _.mapIs( ancestors ) )
    ancestors = _.mapVals( ancestors );

    if( ancestors.length === 1 )
    ancestors = ancestors[ 0 ];

    _.assert( _.arrayIs( ancestors ) || ancestors instanceof resource.constructor );

    if( ancestors instanceof resource.constructor )
    {
      let o2 = _.mapExtend( null, o );
      delete o2.ancestors;
      o2.ancestor = ancestors;
      resource._inheritSingle( o2 );
    }
    else if( ancestors.length === 1 )
    {
      let o2 = _.mapExtend( null, o );
      delete o2.ancestors;
      o2.ancestor = ancestors[ 0 ];
      resource._inheritSingle( o2 );
    }
    else
    {
      for( let a = 0 ; a < ancestors.length ; a++ )
      {
        let o2 = _.mapExtend( null, o );
        delete o2.ancestors;
        o2.ancestor = ancestors[ a ];
        resource._inheritSingle( o2 );
      }
    }

  }

  /* end */

  return resource;
}

_inheritMultiple.defaults =
{
  ancestors : null,
  visited : null,
}

//

function _inheritSingle( o )
{
  let resource = this;
  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  if( _.strIs( o.ancestor ) )
  o.ancestor = module[ module.MapName ][ o.ancestor ];

  let resource2 = o.ancestor;

  _.assert( !!resource2.formed );
  _.assert( o.ancestor instanceof resource.constructor, () => 'Expects ' + resource.constructor.shortName + ' but got ' + _.strType( o.ancestor ) );
  _.assert( arguments.length === 1 );
  _.assert( resource.formed === 1 );
  _.assert( !!resource2.formed );
  _.assertRoutineOptions( _inheritSingle, arguments );

  if( resource2.formed < 2 )
  {
    _.sure( !_.arrayHas( o.visited, resource2.name ), () => 'Cyclic dependency ' + resource.nickName + ' of ' + resource2.nickName );
    resource2._inheritForm({ visited : o.visited });
  }

  let extend = _.mapOnly( resource2, _.mapNulls( resource.structureExport({ compact : 0, copyingAggregates : 1 }) ) );
  delete extend.criterion;
  resource.copy( extend );
  resource.criterionInherit( resource2.criterion );

}

_inheritSingle.defaults=
{
  ancestor : null,
  visited : null,
}

//

function form3()
{
  let resource = this;
  let module = resource.module;
  let willf = resource.willf;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  _.assert( arguments.length === 0 );
  _.assert( resource.formed === 2 );

  /* begin */

  /* end */

  resource.formed = 3;
  return resource;
}

// --
// criterion
// --

function criterionValidate()
{
  let resource = this;

  if( resource.criterion )
  for( let c in resource.criterion )
  {
    let crit = resource.criterion[ c ];
    _.sure( _.strIs( crit ) || _.numberIs( crit ), () => 'Criterion ' + c + ' of ' + resource.nickName + ' should be number or string, but is ' + _.strType( crit ) );
  }

}

//

function criterionSattisfy( criterion2 )
{
  let resource = this;
  let criterion1 = resource.criterion;

  _.assert( criterion1 === null || _.mapIs( criterion1 ) );
  _.assert( criterion2 === null || _.mapIs( criterion2 ) );
  _.assert( arguments.length === 1 );

  if( criterion1 === null )
  return true;
  if( criterion2 === null )
  return true;

  for( let c in criterion2 )
  {
    if( criterion1[ c ] === undefined )
    continue;
    if( criterion1[ c ] !== criterion2[ c ] )
    return false;
  }

  return true;
}

//

function criterionSattisfyStrict( criterion2 )
{
  let resource = this;
  let criterion1 = resource.criterion;

  _.assert( criterion1 === null || _.mapIs( criterion1 ) );
  _.assert( criterion2 === null || _.mapIs( criterion2 ) );
  _.assert( arguments.length === 1 );

  if( criterion1 === null )
  return true;
  if( criterion2 === null )
  return true;

  for( let c in criterion2 )
  {

    if( criterion1[ c ] === undefined && !criterion2[ c ] )
    continue;

    if( criterion1[ c ] !== criterion2[ c ] )
    return false;
  }

  return true;
}

//

function criterionInherit( criterion2 )
{
  let resource = this;
  let criterion1 = resource.criterion;

  _.assert( criterion2 === null || _.mapIs( criterion2 ) );
  _.assert( arguments.length === 1 );

  if( criterion2 === null )
  return criterion1

  criterion1 = resource.criterion = resource.criterion || Object.create( null );

  _.mapSupplement( criterion1, _.mapBut( criterion2, { default : null, predefined : null } ) )

  return criterion1;
}

//

function criterionVariable( criterionMaps, criterion )
{
  let resource = this;

  if( !criterion )
  criterion = resource.criterion;

  return resource.CriterionVariable( criterionMaps, criterion );
}

//

function CriterionVariable( criterionMaps, criterion )
{

  criterionMaps = _.arrayAs( criterionMaps );
  criterionMaps = criterionMaps.map( ( e ) => _.mapIs( e ) ? e : e.criterion );

  if( Config.debug )
  _.assert( _.all( criterionMaps, ( criterion ) => _.mapIs( criterion ) ) );
  _.assert( arguments.length === 2 );

  _.arrayAppendOnce( criterionMaps, criterion );

  let all = _.mapExtend( null, criterionMaps[ 0 ] );
  all = this.CriterionNormalize( all );

  for( let i = 1 ; i < criterionMaps.length ; i++ )
  {
    let criterion2 = criterionMaps[ i ];

    for( let c in all )
    if( criterion2[ c ] === undefined || this.CriterionValueNormalize( criterion2[ c ] ) !== all[ c ] )
    delete all[ c ];

  }

  let result = _.mapBut( criterion, all );

  return result;
}

//

function CriterionPostfixFor( criterionMaps, criterionMap )
{

  _.assert( arguments.length === 2 );

  let variableCriterionMap = this.CriterionVariable( criterionMaps, criterionMap );
  let postfix = [];
  for( let c in variableCriterionMap )
  {
    let value = variableCriterionMap[ c ];
    _.assert( value === this.CriterionValueNormalize( value ) );
    if( value === 0 )
    {}
    else if( value === 1 )
    postfix.push( c );
    else if( value > 1 )
    postfix.push( c + value );
    else if( _.strIs( value ) )
    postfix.push( value );
    else _.assert( 0 );
  }

  let result = ( postfix.length ? postfix.join( '.' ) : '' );

  return result;
}

//

function CriterionMapResolve( module, criterionMap )
{

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( criterionMap ) );

  let criterionMap2 = Object.create( null );

  for( let c in criterionMap )
  {
    let value = criterionMap[ c ];

    let c2 = module.resolve
    ({
      selector : c,
      prefixlessAction : 'resolved',
    });

    let value2 = value;
    if( _.strIs( value ) || _.arrayIs( value ) )
    {
      value2 = module.resolve
      ({
        selector : value,
        prefixlessAction : 'resolved',
      });
    }

    delete criterionMap[ c ];
    criterionMap2[ c2 ] = value2;

  }

  _.mapExtend( criterionMap, criterionMap2 );

  return criterionMap;
}

//

function CriterionNormalize( criterionMap )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( criterionMap ) );

  for( let c in criterionMap )
  {
    let value = criterionMap[ c ];
    if( _.arrayIs( value ) )
    criterionMap[ c ] = value.map( ( e ) => CriterionValueNormalize( e ) )
    else
    criterionMap[ c ] = CriterionValueNormalize( value );
  }

  return criterionMap;
}

//

function CriterionValueNormalize( criterionValue )
{
  _.assert( arguments.length === 1 );
  _.assert( _.numberIsInt( criterionValue ) || _.boolIs( criterionValue ) || _.strIs( criterionValue ) );
  if( !_.boolIs( criterionValue ) )
  return criterionValue;
  return criterionValue === true ? 1 : 0;
}

// --
// export
// --

function _infoExport( o )
{
  let resource = this;
  let result = '';

  result += resource.decoratedAbsoluteName + '\n';
  result += _.toStr( o.fields, { wrap : 0, levels : 4, multiline : 1, stringWrapper : '', multiline : 1 } );

  return result;
}

//

function infoExport()
{
  let resource = this;
  let o = _.routineOptions( infoExport, arguments );

  let fields = resource.structureExport( o );
  let result = resource._infoExport({ fields });

  return result;
}

var defaults = infoExport.defaults = Object.create( _.Will.OpenedModule.prototype.structureExport.defaults );
defaults.copyingNonExportable = 1;
defaults.formed = 1;
defaults.strict = 0;

//

function structureExport()
{
  let resource = this;
  let o = _.routineOptions( structureExport, arguments );

  if( !o.formed )
  if( resource.unformedResource )
  return resource.unformedResource.structureExport.call( resource.unformedResource, o );

  if( !o.copyingNonExportable )
  if( !resource.exportable )
  return;

  if( !o.copyingPredefined )
  if( resource.criterion && resource.criterion.predefined )
  return;

  if( !o.copyingNonWritable && !resource.writable )
  return;

  let o2 = _.mapExtend( null, o );
  delete o2.copyingNonWritable;
  delete o2.copyingPredefined;
  delete o2.copyingNonExportable;
  delete o2.module;
  delete o2.rootModule;
  delete o2.formed;
  delete o2.strict;
  delete o2.exportModule;

  let fields = resource.cloneData( o2 );

  delete fields.name;
  return fields;
}

structureExport.defaults = Object.create( _.Will.OpenedModule.prototype.structureExport.defaults );

//

function compactField( it )
{
  let resource = this;
  let module = resource.module;

  if( it.src instanceof Self )
  {
    _.assert( resource instanceof _.Will.Exported, 'not tested' );
    it.dst = it.src.nickName;
    return it.dst;
  }

  if( it.dst === null )
  return;

  if( _.arrayIs( it.dst ) && !it.dst.length )
  return;

  if( _.mapIs( it.dst ) && !_.mapKeys( it.dst ).length )
  return;

  return it.dst;
}

// --
// accessor
// --

function nickNameGet()
{
  let resource = this;
  return resource.refName;
}

//

function decoratedNickNameGet()
{
  let module = this;
  let result = module.nickName;
  return _.color.strFormat( result, 'entity' );
}

//

function _refNameGet()
{
  let resource = this;
  return resource.KindName + '::' + resource.name;
}

//

function absoluteNameGet()
{
  let resource = this;
  let module = resource.module;

  return ( module ? module.absoluteName : '...' ) + ' / ' + resource.nickName;
}

//

function decoratedAbsoluteNameGet()
{
  let resource = this;
  let result = resource.absoluteName;
  return _.color.strFormat( result, 'entity' );
}

//

function shortNameArrayGet()
{
  let resource = this;
  let module = resource.module;
  let result = module.shortNameArrayGet();
  result.push( resource.name );
  return result;
}

//

function willfSet( src )
{
  let resource = this;
  resource[ willfSymbol ] = src;
  return src;
}

//

function moduleSet( src )
{
  let resource = this;

  if( src && src instanceof _.Will.ModuleOpener )
  src = src.openedModule;

  resource[ moduleSymbol ] = src;

  _.assert( resource.module === null || resource.module instanceof _.Will.OpenedModule );

  return src;
}

// --
// resolver
// --

function resolve_pre( routine, args )
{
  let resource = this;
  let module = resource.module;
  let o = module.resolve.pre.apply( module, arguments );
  return o;
}

function resolve_body( o )
{
  let resource = this;
  let module = resource.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );
  _.assert( o.currentContext === null || o.currentContext === resource )

  o.currentContext = resource;

  let resolved = module.resolve.body.call( module, o );

  return resolved;
}

var defaults = resolve_body.defaults = Object.create( _.Will.OpenedModule.prototype.resolve.defaults );
defaults.prefixlessAction = 'default';

let resolve = _.routineFromPreAndBody( resolve_pre, resolve_body );

//

function inPathResolve_body( o )
{
  let resource = this;
  let module = resource.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.selector ) || _.strsAreAll( o.selector ) );
  _.assertRoutineOptions( inPathResolve_body, arguments );

  if( o.prefixlessAction !== 'default' )
  o.defaultResourceKind = null;

  let result = resource.resolve( o );

  return result;
}

var defaults = inPathResolve_body.defaults = Object.create( resolve.defaults );
defaults.defaultResourceKind = 'path';
defaults.prefixlessAction = 'default';
defaults.pathResolving = 'in';

let inPathResolve = _.routineFromPreAndBody( resolve.pre, inPathResolve_body );

//

function reflectorResolve_body( o )
{
  let resource = this;
  let module = resource.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );
  _.assert( o.currentContext === null || o.currentContext === resource )

  o.currentContext = resource;

  let resolved = module.reflectorResolve.body.call( module, o );

  return resolved;
}

reflectorResolve_body.defaults = Object.create( _.Will.OpenedModule.prototype.reflectorResolve.defaults );

let reflectorResolve = _.routineFromPreAndBody( resolve.pre, reflectorResolve_body );

// --
// etc
// --

function pathRebase( o )
{
  let resource = this;
  let module = resource.module;
  let will = module.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let Resolver = will.Resolver;

  o = _.routineOptions( pathRebase, arguments );

  if( o.filePath )
  if( path.isRelative( o.filePath ) )
  {
    if( Resolver.selectorIs( o.filePath ) )
    {
      let filePath2 = Resolver.selectorNormalize( o.filePath );
      if( _.strBegins( filePath2, '{' ) )
      return o.filePath;
      o.filePath = filePath2;
    }
    return path.relative( o.inPath, path.join( o.exInPath, o.filePath ) );
  }

  return o.filePath;
}

pathRebase.defaults =
{
  filePath : null,
  exInPath : null,
  inPath : null,
}

// --
// relations
// --

let willfSymbol = Symbol.for( 'willf' );
let moduleSymbol = Symbol.for( 'module' );

let Composes =
{

  description : null,
  criterion : null,
  inherit : _.define.own([]),

}

let Aggregates =
{
  writable : 1,
  exportable : 1,
  importable : 1,
  generated : 0,
}

let Associates =
{
  willf : null,
  module : null,
  original : null,
}

let Medials =
{
}

let Restricts =
{
  id : null,
  formed : 0,
  inherited : 0,
  unformedResource : null,
}

let Statics =
{

  MakeFor,
  MakeForEachCriterion,
  ResouceDataFrom,

  CriterionVariable,
  CriterionPostfixFor,
  CriterionMapResolve,
  CriterionNormalize,
  CriterionValueNormalize,

  MapName : null,
  KindName : null,

}

let Forbids =
{
  default : 'default',
  predefined : 'predefined',
}

let Accessors =
{
  willf : { setter : willfSet },
  nickName : { getter : nickNameGet, readOnly : 1 },
  decoratedNickName : { getter : decoratedNickNameGet, readOnly : 1 },
  refName : { getter : _refNameGet, readOnly : 1 },
  absoluteName : { getter : absoluteNameGet, readOnly : 1 },
  decoratedAbsoluteName : { getter : decoratedAbsoluteNameGet, readOnly : 1 },
  inherit : { setter : _.accessor.setter.arrayCollection({ name : 'inherit' }) },
  module : {},
}

// --
// declare
// --

let Extend =
{

  // inter

  MakeFor,
  MakeForEachCriterion,
  ResouceDataFrom,

  finit,
  init,
  copy,
  cloneDerivative,

  unform,
  form,
  form1,
  form2,

  _inheritForm,
  _inheritMultiple,
  _inheritSingle,

  form3,

  // criterion

  criterionValidate,
  criterionSattisfy,
  criterionSattisfyStrict,
  criterionInherit,
  criterionVariable,

  CriterionVariable,
  CriterionPostfixFor,
  CriterionNormalize,
  CriterionValueNormalize,

  // export

  _infoExport,
  infoExport,
  structureExport,
  compactField,

  // accessor

  nickNameGet,
  decoratedNickNameGet,
  _refNameGet,
  absoluteNameGet,
  decoratedAbsoluteNameGet,
  shortNameArrayGet,
  willfSet,
  moduleSet,

  // resolver

  resolve,
  inPathResolve,
  reflectorResolve,

  // etc

  pathRebase,

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

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
  withMixin : 1,
  withClass : 1,
});

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

_.staticDeclare
({
  prototype : _.Will.prototype,
  name : Self.shortName,
  value : Self,
});

})();
