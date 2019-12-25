( function _ModuleJunction_s_( ) {

'use strict';

if( typeof junction !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wWillModuleJunction( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ModuleJunction';

// --
// inter
// --

function finit()
{
  let junction = this;
  let will = junction.will;
  _.assert( !junction.finitedIs() );

  _.each( junction.modules, ( module ) => junction._moduleRemove( module ) );
  _.each( junction.openers, ( opener ) => junction._moduleRemove( opener ) );
  _.each( junction.relations, ( relation ) => junction._moduleRemove( relation ) );

  _.assert( junction.module === null );
  _.assert( junction.opener === null );
  _.assert( junction.relation === null );
  _.assert( junction.object === null );

  if( junction.peer )
  {
    let peer = junction.peer;
    _.assert( junction.peer.peer === junction )
    peer.peer = null;
    junction.peer = null;
    if( !peer.isUsed() )
    peer.finit();
  }

  for( let v in will.junctionMap )
  {
    if( will.junctionMap[ v ] === junction )
    delete will.junctionMap[ v ];
  }

  return _.Copyable.prototype.finit.apply( junction, arguments );
}

//

function init( o )
{
  let junction = this;
  _.workpiece.initFields( junction );
  Object.preventExtensions( junction );
  _.Will.ResourceCounter += 1;
  junction.id = _.Will.ResourceCounter;

  if( o )
  junction.copy( o );

  if( o.module )
  junction._moduleAdd( o.module );
  if( o.opener )
  junction._openerAdd( o.opener );
  if( o.relation )
  junction._relationAdd( o.relation );
  if( o.object )
  junction._add( o.object );

  return junction;
}

//

function reform()
{
  let junction = this;
  let will = junction.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;

  if( junction.formed === -1 )
  return;

  // if( junction.id === 452 )
  // debugger;

  // logger.log( `Reforming junction::${junction.name}#${junction.id} at ${junction.localPath}` ); debugger;

  junction.formed = -1;

  _.assert( !junction.finitedIs() );

  if( junction.finitedIs() )
  return;

  associationsAdd();
  objectFind();
  pathsForm();

  // if( junction.id === 610 )
  // debugger;

  junction.mergeMaybe( 1 );
  if( junction.finitedIs() )
  {
    return false;
  }
  if( !junction.isUsed() )
  {
    junction.finit();
    return false;
  }

  verify();
  register();
  peerForm();
  nameForm();
  isOutForm();

  // logger.log( `Reformed junction::${junction.name}#${junction.id} at ${junction.localPath}` ); debugger;

  junction.assertIntegrityVerify();

  // if( junction.id === 452 )
  // debugger;

  junction.formed = 1;
  return junction;

  /* */

  function pathAdd( object )
  {
    let localPath, remotePath;
    [ localPath, remotePath ] = junction.PathsOf( object );

    if( localPath )
    {
      _.arrayAppendOnce( junction.localPaths, localPath );
      if( junction.localPath === null )
      junction.localPath = localPath;
    }

    if( remotePath )
    {
      _.arrayAppendOnce( junction.remotePaths, remotePath );
      junction.remotePath = remotePath;
      // _.assert( junction.remotePaths.length <= 1, `Remote paths collision: ${junction.remotePaths.join( ' ' )}` );
    }

  }

  /* */

  function pathFromPeerAdd( object )
  {

    let localPath = object.peerLocalPathGet();
    if( localPath )
    _.arrayAppendOnce( junction.localPaths, localPath );
    if( junction.localPath === null )
    junction.localPath = localPath;
    _.assert( localPath === null || _.strIs( localPath ) );

    let remotePath = object.peerRemotePathGet();
    if( remotePath )
    _.arrayAppendOnce( junction.remotePaths, remotePath );
    if( junction.remotePath === null )
    junction.remotePath = remotePath;
    _.assert( remotePath === null || _.strIs( remotePath ) );

  }

  /* */

  function pathsForm()
  {

    junction.localPaths.splice( 0, junction.localPaths.length );
    junction.remotePaths.splice( 0, junction.remotePaths.length );

    junction.modules.forEach( ( object ) => pathAdd( object ) );
    junction.openers.forEach( ( object ) => pathAdd( object ) );
    junction.relations.forEach( ( object ) => pathAdd( object ) );

    if( junction.peer )
    junction.peer.modules.forEach( ( object ) => pathFromPeerAdd( object ) );

    if( junction.localPaths.length && !_.longHas( junction.localPaths, junction.localPath ) )
    junction.localPath = junction.localPaths[ 0 ];
    if( junction.remotePaths.length && !_.longHas( junction.remotePaths, junction.remotePath ) )
    junction.remotePath = junction.remotePaths[ 0 ];

    _.assert( !junction.localPaths.length || _.longHas( junction.localPaths, junction.localPath ) );
    _.assert( !junction.remotePaths.length || _.longHas( junction.remotePaths, junction.remotePath ) );

  }

  /* */

  function objectFind()
  {
    if( junction.module )
    {
      junction.object = junction.module;
    }
    else if( junction.opener )
    {
      _.assert( junction.opener.formed >= 2 );
      junction.object = junction.opener;
    }
    else if( junction.relation )
    {
      junction.object = junction.relation;
    }
  }

  /* */

  function associationsAdd()
  {

    junction._add( junction.AssociationsOf( junction.relations ) );
    junction._add( junction.AssociationsOf( junction.openers ) );
    junction._add( junction.AssociationsOf( junction.modules ) );

  }

  /* */

  function finitedRemove()
  {

    if( junction.module && junction.module.finitedIs() )
    debugger;
    if( junction.module && junction.module.finitedIs() )
    junction._remove( junction.module );
    if( junction.opener && junction.opener.finitedIs() )
    debugger;
    if( junction.opener && junction.opener.finitedIs() )
    junction._remove( junction.opener );
    if( junction.relation && junction.relation.finitedIs() )
    junction._remove( junction.relation );

  }

  /* */

  function verify()
  {

    if( junction.module )
    _.assert( !junction.module.finitedIs() );
    if( junction.opener )
    _.assert( !junction.opener.finitedIs() );
    if( junction.relation )
    _.assert( !junction.relation.finitedIs() );

    _.assert
    (
      _.strDefined( junction.localPath ) || _.strDefined( junction.remotePath ),
      () => `${junction.name} does not have defined local path, neither remote path`
    );
    _.assert
    (
      !junction.opener || junction.opener.formed >= 2,
      () => `Opener should be formed to level 2 or higher, but ${junction.opener.absoluteName} is not`
    );

  }

  /* */

  function register()
  {
    if( will.junctionMap )
    {
      if( junction.localPath )
      {
        junction.localPaths.forEach( ( localPath ) =>
        {
          _.assert( will.junctionMap[ localPath ] === undefined || will.junctionMap[ localPath ] === junction );
          _.assert( _.strDefined( localPath ) );
          will.junctionMap[ localPath ] = junction;
        });
      }
      if( junction.remotePath )
      {
        _.assert( will.junctionMap[ junction.remotePath ] === undefined || will.junctionMap[ junction.remotePath ] === junction );
        _.assert( _.strDefined( junction.remotePath ) );
        will.junctionMap[ junction.remotePath ] = junction;
      }
    }
  }

  /* */

  function peerFromModule( module )
  {
    _.assert( module instanceof _.Will.Module );
    _.assert( !module.peerModule );

    let localPath = module.peerLocalPathGet();
    if( !localPath )
    return;

    if( will.junctionMap[ localPath ] )
    {
      let junction2 = will.junctionMap[ localPath ];
      peerAssign( junction, junction2 );
      return junction2;
    }

    _.assert( !will.junctionMap[ localPath ] );

    let junction2 = new _.Will.ModuleJunction({ will : will });
    junction2.localPaths.push( localPath );
    junction2.localPath = localPath;
    peerAssign( junction, junction2 );
    junction2.reform();

    return junction2;
  }

  /* */

  function peerFrom( object )
  {
    let peerModule = object.peerModule;

    if( !peerModule )
    return;

    if( !peerModule.isPreformed() )
    return;

    if( junction.peer )
    {
      _.assert( junction.peer.peer === junction );
      if( !object.peerModule )
      return junction.peer;

      let junction2 = junction.JunctionWithObject( will, object.peerModule );
      if( junction2 && junction2.peer === junction )
      return junction.peer;
    }

    let junction2 = _.Will.ModuleJunction.JunctionWithObject( will, peerModule );
    peerAssign( junction, junction2 );

    return junction2;
  }

  /* */

  function peerAssign( junction, junction2 )
  {
    _.assert( !junction.finitedIs() );

    if( junction2.peer && junction2.peer !== junction )
    {
      if( !junction2.peer.ownSomething() )
      {
        debugger;
        junction2.peer.finit();
      }
      else
      {
        debugger;
        junction2.peer.mergeIn( junction );
      }
    }

    if( junction.peer && junction.peer !== junction2 )
    {
      if( !junction.peer.ownSomething() )
      {
        debugger;
        junction.peer.finit();
      }
      else
      {
        junction2.mergeIn( junction.peer );
        return;
      }
    }

    assign();

    function assign()
    {
      _.assert( junction.peer === junction2 || junction.peer === null );
      _.assert( junction2.peer === junction || junction2.peer === null );
      _.assert( !junction.finitedIs() );
      _.assert( !junction2.finitedIs() );
      junction.peer = junction2;
      junction2.peer = junction;
      return;
    }
  }

  /* */

  function peerForm()
  {

    junction.openers.forEach( ( object ) => peerFrom( object ) );
    junction.modules.forEach( ( object ) => peerFrom( object ) );

    if( !junction.peer )
    junction.modules.forEach( ( object ) => peerFromModule( object ) );

  }

  /* */

  function nameForm()
  {
    if( junction.object )
    junction.name = junction.object.absoluteName;
    else if( junction.peer )
    junction.name = junction.peer.name + ' / f::peer';
  }

  /* */

  function isOutForm()
  {
    if( junction.object && _.boolLike( junction.object.isOut ) )
    junction.isOut = !!junction.object.isOut;
    else if( junction.peer && junction.peer.object && _.boolLike( junction.peer.object.isOut ) )
    junction.isOut = !junction.peer.object.isOut;
    else
    junction.isOut = _.Will.PathIsOut( junction.localPath || junction.remotePath );
  }

  /* */

}

//

function mergeIn( junction2 )
{
  let junction = this;
  let will = junction.will;
  let objects = [];

  _.assert( !junction.finitedIs() );
  _.assert( !junction2.finitedIs() );
  _.assert( arguments.length === 1 );

  /* xxx : use junction.objects */
  junction.relations.slice().forEach( ( object ) => objects.push( object ) );
  junction.openers.slice().forEach( ( object ) => objects.push( object ) );
  junction.modules.slice().forEach( ( object ) => objects.push( object ) );

  objects.forEach( ( object ) => junction._remove( object ) );
  objects.forEach( ( object ) => junction2._add( object ) );

  if( junction.peer )
  {
    let peer = junction.peer;
    _.assert( !peer.finitedIs() );
    junction.peer = null;
    peer.peer = null;

    if( junction2.peer === null )
    {
      junction2.peer = peer;
      peer.peer = junction2;
    }
    else
    {
      peer.mergeIn( junction2.peer );
      _.assert( peer.finitedIs() );
      _.assert( peer.peer === null );
    }

  }

  _.assert( !junction.finitedIs() );
  _.assert( !junction2.finitedIs() );

  junction.reform();

  if( junction.ownSomething() )
  {
    _.assert( 'not tested' );
  }
  else
  {
    if( !junction.finitedIs() )
    junction.finit();
  }

  _.assert( junction.finitedIs() );
  _.assert( !junction2.finitedIs() );

  junction2.reform(); /* yyy */

  if( junction.finitedIs() )
  return true;
  return false;
}

//

function mergeMaybe( usingPath )
{
  let junction = this;
  let will = junction.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let junction2;
  let reset;

  _.assert( arguments.length === 1 );

  let merged = merge();

  if( reset )
  merge();

  if( !merged && usingPath )
  {

    junction.localPaths.every( ( localPath ) =>
    {
      let junction3 = will.junctionMap[ localPath ];
      if( junction3 && junction3 !== junction )
      {
        junction.mergeIn( junction3 );
        return false;
      }
      return true;
    });

    junction.remotePaths.every( ( remotePath ) =>
    {
      let junction3 = will.junctionMap[ remotePath ];
      if( junction3 && junction3 !== junction )
      {
        junction.mergeIn( junction3 );
        return false;
      }
      return true;
    });

  }

  _.assert( !reset );
  _.assert( !junction2 || !junction2.finitedIs() );

  if( !junction.finitedIs() )
  junction.assertIntegrityVerify();
  if( junction2 && !junction2.finitedIs() )
  junction2.assertIntegrityVerify();

  return junction2 || false;

  /* */

  function merge()
  {
    reset = false;

    if( objectsMergeMaybe( junction.modules ) )
    return junction2;

    if( objectsMergeMaybe( junction.openers ) )
    return junction2;

    if( objectsMergeMaybe( junction.relations ) )
    return junction2;

    if( objectsMergeMaybe( junction.AssociationsOf( junction.modules ) ) )
    return junction2;

    if( objectsMergeMaybe( junction.AssociationsOf( junction.openers ) ) )
    return junction2;

    if( objectsMergeMaybe( junction.AssociationsOf( junction.relations ) ) )
    return junction2;

    return false;
  }


  /* */

  function objectsMergeMaybe( objects )
  {
    _.any( objects, ( object ) =>
    {
      junction2 = objectMergeMaybe( object );
      if( junction2 )
      return junction2;
    });
    return junction2;
  }

  /* */

  function objectMergeMaybe( object )
  {
    let localPath, remotePath;

    [ localPath, remotePath ] = junction.PathsOf( object );

    if( localPath )
    {

      let junction2 = will.junctionMap[ localPath ];
      if( junction2 && junction2 !== junction )
      {
        if( junction.mergeIn( junction2 ) )
        return junction2;
        return junction2;
      }

    }

    if( remotePath )
    {

      let junction2 = will.junctionMap[ remotePath ];
      if( junction2 && junction2 !== junction )
      {
        if( junction.mergeIn( junction2 ) )
        return junction2;
        return junction2;
      }

    }

    {
      let junction3 = will.objectToJunctionHash.get( object );
      if( junction3 && junction3 !== junction )
      {
        _.assert( 0, 'not tested' );
        reset = 1;
        junction3.mergeIn( junction );
        return junction3;
      }
    }

  }

}

//

function From( o )
{
  let cls = this;
  let junction;
  let will = o.will;
  let junctionMap = will.junctionMap;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  let logger = will.logger;
  let made = false;
  let changed = false;

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );
  _.assert( _.mapIs( junctionMap ) );

  if( !o.object )
  o.object = o.module || o.opener || o.relation;

  if( o.object && o.object instanceof Self )
  {
    junction = o.object;
    return junction;
  }
  else if( _.mapIs( o.object ) )
  {
    debugger;
    junction = Self( o.object );
  }
  else
  {
    junction = will.objectToJunctionHash.get( o.object );
    if( junction )
    {
    //   junction.assertIntegrityVerify();
      // if( junction.id === 452 )
      // debugger;
      return junction;
    }
  }

  // if( o.object && o.object.id === 5 )
  // debugger;

  // if( junction && junction.object ) /* xxx : remove ? */
  // {
  //   let localPath, remotePath;
  //   [ localPath, remotePath ] = junction.PathsOf( junction.object );
  //
  //   if( localPath !== junction.localPath )
  //   changed = true;
  //   if( remotePath !== junction.remotePath )
  //   changed = true;
  // }

  if( !junction )
  junctionWithPath();

  _.assert
  (
    !o.relation || ( !!o.relation.opener && o.relation.opener.formed >= 2 ),
    () => `Opener should be formed to level 2 or higher, but opener of ${o.relation.absoluteName} is not`
  )

  if( junction )
  junctionUpdate();

  if( !junction )
  {
    made = true;
    changed = true;
    junction = Self( o );
  }

  // if( changed ) /* xxx : switch on the optimization */
  if( junction.formed !== -1 )
  junction = junction.reform();

  _.assert( !junction || !junction.finitedIs() );

  return junction;

  /* */

  function junctionUpdate()
  {

    if( o.object && o.object !== junction )
    if( !junction.own( o.object ) )
    changed = junction._add( o.object ) || changed;
    if( o.module )
    if( !junction.own( o.module ) )
    changed = junction._add( o.module ) || changed;
    if( o.opener )
    if( !junction.own( o.opener ) )
    changed = junction._add( o.opener ) || changed;
    if( o.relation )
    if( !junction.own( o.relation ) )
    changed = junction._add( o.relation ) || changed;

    delete o.object;
    delete o.module;
    delete o.opener;
    delete o.relation;

    for( let f in o )
    {
      if( junction[ f ] !== o[ f ] )
      {
        debugger;
        _.assert( 0, 'not tested' );
        junction[ f ] = o[ f ];
        changed = true;
      }
    }

  }

  /* */

  function junctionWithPath()
  {
    let localPath, remotePath;

    [ localPath, remotePath ] = cls.PathsOf( o.object );

    if( junctionMap && junctionMap[ localPath ] )
    junction = junctionMap[ localPath ];
    else if( junctionMap && remotePath && junctionMap[ remotePath ] )
    junction = junctionMap[ remotePath ];

  }

  /* */

}

//

function PathsOf( object )
{
  let result = [];

  _.assert( !!object );

  if( object instanceof Self )
  {
    let localPath = object.localPath;
    let remotePath = object.remotePath;
    result.push( localPath );
    result.push( remotePath );
  }
  else if( object instanceof _.Will.Module )
  {
    let localPath = object.localPath || object.commonPath;
    let remotePath = object.remotePath;
    result.push( localPath );
    result.push( remotePath );
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    let localPath = object.localPath || object.commonPath;
    let remotePath = object.remotePath;
    result.push( localPath );
    result.push( remotePath );
  }
  else if( object instanceof _.Will.ModulesRelation )
  {
    let path = object.module.will.fileProvider.path;
    let localPath = object.localPath;
    let remotePath = object.remotePath;
    result.push( localPath );
    result.push( remotePath );
  }
  else _.assert( 0 );

  /* xxx */
  if( result[ 1 ] && _.strHas( result[ 1 ], 'hd://.' ) )
  result[ 1 ] = null;

  return result;
}

//

function PathsOfAsMap( object )
{
  let result = Object.create( null );

  _.assert( !!object );

  if( object instanceof Self )
  {
    result.localPath = object.localPath;
    result.remotePath = object.remotePath;
  }
  else if( object instanceof _.Will.Module )
  {
    result.localPath = object.localPath || object.commonPath;
    result.remotePath = object.remotePath;
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    result.localPath = object.localPath || object.commonPath;
    result.remotePath = object.remotePath;
  }
  else if( object instanceof _.Will.ModulesRelation )
  {
    let path = object.module.will.fileProvider.path;
    result.localPath = object.localPath;
    result.remotePath = object.remotePath;
  }
  else _.assert( 0 );

  return result;
}

//

function JunctionReform( will, o )
{
  let cls = this;
  let result;

  _.assert( arguments.length === 2 );
  _.assert( !!o );

  if( !_.mapIs( o ) )
  o = { object : o }
  if( !o.will )
  o.will = will;

  let junction = will.objectToJunctionHash.get( o.object );
  if( junction )
  {
    junction.reform();
    return junction;
  }

  result = cls.From( o );

  return result;
}

//

function JunctionsReform( will, junctions )
{
  let cls = this;
  _.assert( arguments.length === 2 );
  if( _.arrayLike( junctions ) )
  return _.filter( junctions, ( junction ) => cls.JunctionReform( will, junction ) );
  else
  return cls.JunctionReform( will, junctions );
}

//

function JunctionFrom( will, object )
{
  let cls = this;
  let result;

  _.assert( arguments.length === 2 );
  _.assert( !!object );

  if( !_.mapIs( object ) )
  object = { object : object }
  if( !object.will )
  object.will = will;

  result = will.objectToJunctionHash.get( object );

  if( result )
  {
    result.assertIntegrityVerify();
    return result;
  }

  result = cls.From( object );

  return result;
}

//

function JunctionsFrom( will, junctions )
{
  let cls = this;
  _.assert( arguments.length === 2 );
  if( _.arrayLike( junctions ) )
  return _.filter( junctions, ( junction ) => cls.JunctionFrom( will, junction ) );
  else
  return cls.JunctionFrom( will, junctions );
}

//

function JunctionWithObject( will, object )
{
  let cls = this;

  _.assert( arguments.length === 2 );
  _.assert( !!object );

  if( object instanceof _.Will.ModuleJunction )
  return object;

  let junction = will.objectToJunctionHash.get( object );

  if( Config.debug )
  if( junction )
  {
    let paths = cls.PathsOf( object );
    let junction2 = _.any( paths, ( path ) => will.junctionMap[ path ] );
    if( junction2 )
    _.assert( junction2.formed !== 1 || _.all( paths, ( path ) => will.junctionMap[ path ] === undefined || will.junctionMap[ path ] === junction2 ) );
    _.assert( junction === junction2 || !junction2 || !junction2.ownSomething() );
  }

  return junction;
}

//

function JunctionsWithObjects( will, junctions )
{
  let cls = this;
  _.assert( arguments.length === 2 );
  if( _.arrayLike( junctions ) )
  return _.filter( junctions, ( junction ) => cls.JunctionWithObject( will, junction ) );
  else
  return cls.JunctionWithObject( will, junction );
}

//

function AssociationsOf( object )
{
  let cls = this;

  if( _.arrayIs( object ) )
  return _.longOnce( _.arrayFlatten( object.map( ( object ) => cls.AssociationsOf( object ) ) ) );

  let result = [];
  if( object instanceof _.Will.Module )
  {
    return _.each( object.userArray, ( opener ) =>
    {
      if( opener instanceof _.Will.ModuleOpener )
      result.push( opener );
    });
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    if( object.openedModule )
    result.push( object.openedModule );
    if( object.superRelation )
    result.push( object.superRelation );
  }
  else if( object instanceof _.Will.ModulesRelation )
  {
    if( object.opener )
    result.push( object.opener );
    if( object.opener && object.opener.openedModule )
    result.push( object.opener.openedModule );
  }
  else _.assert( 0 );

  return result;
}

//

function ObjectToOptionsMap( o )
{
  if( _.mapIs( o ) )
  return o;
  if( o instanceof _.Will.Module )
  {
    return { module : o }
  }
  else if( o instanceof _.Will.ModuleOpener )
  {
    return { opener : o }
  }
  else if( o instanceof _.Will.ModulesRelation )
  {
    return { relation : o }
  }
  else _.assert( 0 );
}

//

function _relationAdd( relation )
{
  let junction = this;
  let will = junction.will;
  let changed = false;

  _.assert( relation instanceof _.Will.ModulesRelation );

  // if( !relation.enabled ) /* ttt */
  // {
  //   return false;
  // }

  if( !junction.relation )
  {
    junction.relation = relation;
    changed = true;
  }

  changed = _.arrayAppendedOnce( junction.relations, relation ) > -1 || changed;

  let junction2 = will.objectToJunctionHash.get( relation );
  _.assert( junction.formed === -1 || junction2 === junction || junction2 === undefined );
  will.objectToJunctionHash.set( relation, junction );

  _.assert( junction.formed === -1 || changed || _.all( junction.PathsOf( relation ), ( path ) => will.junctionMap[ path ] === undefined || will.junctionMap[ path ] === junction ) );

  return changed;
}

//

function _relationRemoveSingle( relation )
{
  let junction = this;
  let will = junction.will;

  _.assert( relation instanceof _.Will.ModulesRelation );
  _.arrayRemoveOnce( junction.relations, relation );

  if( junction.relation === relation )
  junction.relation = null;
  if( junction.object === relation )
  junction.object = null;

  if( !junction.relation && junction.relations.length )
  junction.relation = junction.relations[ 0 ];

  let junction2 = will.objectToJunctionHash.get( relation );
  _.assert( junction2 === junction );
  will.objectToJunctionHash.delete( relation );

  return true;
}

//

function _relationRemove( relation )
{
  let junction = this;
  let will = junction.will;

  if( !_.longHas( junction.relations, relation ) )
  return false;

  junction._relationRemoveSingle( relation );

  junction._remove( junction.AssociationsOf( relation ) );
  return true;
}

//

function _openerAdd( opener )
{
  let junction = this;
  let will = junction.will;
  let changed = false;

  // if( opener.superRelation ) /* ttt */
  // {
  //   if( !opener.superRelation.enabled )
  //   return false;
  //   _.assert( !!opener.superRelation.enabled );
  // }

  _.assert( opener instanceof _.Will.ModuleOpener );

  if( !junction.opener )
  {
    junction.opener = opener;
    changed = true;
  }

  changed = _.arrayAppendedOnce( junction.openers, opener ) > -1 || changed;

  let junction2 = will.objectToJunctionHash.get( opener );
  _.assert( junction.formed === -1 || junction2 === junction || junction2 === undefined );
  will.objectToJunctionHash.set( opener, junction );

  _.assert( junction.formed === -1 || changed || _.all( junction.PathsOf( opener ), ( path ) => will.junctionMap[ path ] === undefined || will.junctionMap[ path ] === junction ) );

  return changed;
}

//

function _openerRemoveSingle( opener )
{
  let junction = this;
  let will = junction.will;

  _.assert( opener instanceof _.Will.ModuleOpener );
  _.arrayRemoveOnceStrictly( junction.openers, opener );

  if( junction.opener === opener )
  junction.opener = null;
  if( junction.object === opener )
  junction.object = null;

  if( !junction.opener && junction.openers.length )
  junction.opener = junction.openers[ 0 ];

  let junction2 = will.objectToJunctionHash.get( opener );
  _.assert( junction2 === junction );
  will.objectToJunctionHash.delete( opener );

}

//

function _openerRemove( opener )
{
  let junction = this;
  let will = junction.will;

  if( !_.longHas( junction.openers, opener ) )
  return false;

  junction._openerRemoveSingle( opener );

  junction._remove( junction.AssociationsOf( opener ) );
  return true;
}

//

function _moduleAdd( module )
{
  let junction = this;
  let will = junction.will;
  let changed = false;

  _.assert( module instanceof _.Will.Module );

  if( !junction.module )
  {
    junction.module = module;
    changed = true;
  }

  changed = _.arrayAppendedOnce( junction.modules, module ) > -1 || changed;

  let junction2 = will.objectToJunctionHash.get( module );
  _.assert( junction2 === junction || junction2 === undefined, 'Module can belong only to one junction' );
  will.objectToJunctionHash.set( module, junction );

  _.assert( junction.formed === -1 || changed || _.all( junction.PathsOf( module ), ( path ) => will.junctionMap[ path ] === undefined || will.junctionMap[ path ] === junction ) );

  return changed;
}

//

function _moduleRemoveSingle( module )
{
  let junction = this;
  let will = junction.will;

  _.assert( module instanceof _.Will.Module );
  // _.assert( junction.module === module );
  _.arrayRemoveOnceStrictly( junction.modules, module );

  if( junction.module === module )
  junction.module = null;
  if( junction.object === module )
  junction.object = null;

  if( !junction.module && junction.modules.length )
  junction.module = junction.modules[ 0 ];

  let junction2 = will.objectToJunctionHash.get( module );
  _.assert( junction2 === junction );
  will.objectToJunctionHash.delete( module );

}

//

function _moduleRemove( module )
{
  let junction = this;
  let will = junction.will;

  if( !_.longHas( junction.modules, module ) )
  return false;

  junction._moduleRemoveSingle( module );

  junction._remove( junction.AssociationsOf( module ) );
  return true;
}

//

function _add( object )
{
  let junction = this;
  let result;

  if( _.arrayIs( object ) )
  return _.any( _.map( object, ( object ) => junction._add( object ) ) );

  if( object instanceof _.Will.ModulesRelation )
  {
    result = junction._relationAdd( object );
  }
  else if( object instanceof _.Will.Module )
  {
    result = junction._moduleAdd( object );
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    result = junction._openerAdd( object );
  }
  else _.assert( 0, `Unknown type of object ${_.strType( object )}` );

  return result;
}

//

function add( object )
{
  let junction = this;
  let result = junction._add( object );
  junction.reform();
  return result;
}

//

function _remove( object )
{
  let junction = this;

  if( _.arrayIs( object ) )
  return _.any( _.map( object, ( object ) => junction._remove( object ) ) );

  if( object instanceof _.Will.ModulesRelation )
  {
    return junction._relationRemove( object );
  }
  else if( object instanceof _.Will.Module )
  {
    return junction._moduleRemove( object );
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    return junction._openerRemove( object );
  }
  else _.assert( 0 );

}

//

function remove( object )
{
  let junction = this;
  junction._remove( object );
  return junction.reform();
}

//

function own( object )
{
  let junction = this;

  _.assert( arguments.length === 1 );

  if( object instanceof _.Will.Module )
  {
    return _.longHas( junction.modules, object );
  }
  else if( object instanceof _.Will.ModuleOpener )
  {
    return _.longHas( junction.openers, object );
  }
  else if( object instanceof _.Will.ModulesRelation )
  {
    return _.longHas( junction.relations, object );
  }
  else _.assert( 0 );

}

//

function ownSomething()
{
  let junction = this;

  _.assert( arguments.length === 0 );

  if( junction.modules.length )
  return true;
  if( junction.openers.length )
  return true;
  if( junction.relations.length )
  return true;

  return false;
}

//

function isUsed()
{
  let junction = this;

  _.assert( arguments.length === 0 );

  if( junction.ownSomething() )
  return true;

  if( junction.peer )
  if( junction.peer.ownSomething() )
  return true;

  return false;
}

//

// function submodulesRelationsFilter( o )
// {
//   let junction = this;
//   let will = junction.will;
//   let result = [];
//
//   o = _.routineOptions( submodulesRelationsFilter, arguments );
//
//   let filter = _.mapOnly( o, will.relationFit.defaults );
//
//   junctionLook( junction );
//
//   if( !junction.peer )
//   if( junction.module && junction.module.peerModule )
//   {
//     debugger;
//     junction.From({ module : junction.module.peerModule, will : will });
//     _.assert( _.longHas( junction.peer.modules, junction.module.peerModule ) );
//   }
//
//   if( o.withPeers )
//   if( junction.peer )
//   junctionLook( junction.peer );
//
//   if( o.withoutDuplicates )
//   result = result.filter( ( junction ) =>
//   {
//     return !junction.isOut || !_.longHas( result, junction.peer );
//   });
//
//   return result;
//
//   /* */
//
//   function junctionLook( junction )
//   {
//
//     if( junction.module )
//     for( let s in junction.module.submoduleMap )
//     {
//       let relation = junction.module.submoduleMap[ s ];
//
//       let junction2 = junction.JunctionWithObject( will, relation );
//       if( !junction2 )
//       junction2 = junction.From({ relation : relation, will : will });
//       _.assert( !!junction2 );
//
//       if( !junction2.peer )
//       if( junction2.module && junction2.module.peerModule )
//       {
//         debugger;
//         _.assert( 0, 'not tested' );
//         junction2.From({ module : junction2.module.peerModule, will : will });
//       }
//
//       /*
//       getting shadow sould go after setting up junction
//       */
//
//       // junction2 = junction2.shadow({ relation })
//       junctionAppendMaybe( junction2 );
//
//       if( o.withPeers )
//       if( junction2.peer )
//       junctionAppendMaybe( junction2.peer );
//
//     }
//
//   }
//
//   /* */
//
//   function junctionAppendMaybe( junction )
//   {
//
//     if( !will.relationFit( junction, filter ) )
//     return;
//
//     _.assert( junction instanceof _.Will.ModuleJunction );
//     _.arrayAppendOnce( result, junction );
//
//   }
//
//   /* */
//
// }
//
// submodulesRelationsFilter.defaults =
// {
//
//   ... _.Will.RelationFilterDefaults,
//   withPeers : 1,
//   withoutDuplicates : 0,
//
// }

//

function submodulesJunctionsFilter( o )
{
  let junction = this;
  let will = junction.will;
  let result = [];

  o = _.routineOptions( submodulesJunctionsFilter, arguments );

  let filter = _.mapOnly( o, will.relationFit.defaults );

  // if( _global_.debugger === 1 )
  // debugger;

  junctionLook( junction );

  if( !junction.peer )
  if( junction.module && junction.module.peerModule )
  {
    debugger;
    junction.From({ module : junction.module.peerModule, will : will });
    _.assert( _.longHas( junction.peer.modules, junction.module.peerModule ) );
  }

  if( o.withPeers )
  if( junction.peer )
  junctionLook( junction.peer );

  // if( _global_.debugger === 1 )
  // debugger;

  if( o.withoutDuplicates )
  result = result.filter( ( junction ) =>
  {
    return !junction.isOut || !_.longHas( result, junction.peer );
  });

  // if( _global_.debugger === 1 )
  // debugger;

  return result;

  /* */

  function junctionLook( junction )
  {

    // if( _global_.debugger )
    // if( junction.id === 176 )
    // debugger;

    // if( junction.module )
    junction.modules.forEach( ( module ) =>
    {
      for( let s in module.submoduleMap )
      {
        let relation = module.submoduleMap[ s ];

        // let junction2 = junction.JunctionWithObject( will, relation );
        // if( !junction2 )
        let junction2 = junction.From({ relation : relation, will : will });
        _.assert( !!junction2 );

        if( !junction2.peer )
        if( junction2.module && junction2.module.peerModule )
        {
          debugger;
          _.assert( 0, 'not tested' );
          junction2.From({ module : junction2.module.peerModule, will : will });
        }

        /*
        getting shadow sould go after setting up junction
        */

        // junction2 = junction2.shadow({ relation })
        junctionAppendMaybe( junction2 );

        if( o.withPeers )
        if( junction2.peer )
        junctionAppendMaybe( junction2.peer );

      }
    });

  }

  /* */

  function junctionAppendMaybe( junction )
  {

    if( !will.relationFit( junction, filter ) )
    return;

    _.assert( junction instanceof _.Will.ModuleJunction );
    _.arrayAppendOnce( result, junction );

  }

  /* */

}

submodulesJunctionsFilter.defaults =
{

  ... _.Will.RelationFilterDefaults,
  withPeers : 1,
  withoutDuplicates : 0,

}

//

function shadow( o )
{
  let junction = this;
  let will = junction.will;

  if( !_.mapIs( o ) )
  o = junction.ObjectToOptionsMap( o );

  o = _.routineOptions( shadow, o );
  _.assert( arguments.length === 1 );

  let shadowMap = _.mapExtend( null, o );
  shadowMap.localPath = _.unknown;
  shadowMap.remotePath = _.unknown;

  let shadowProxy = _.proxyShadow
  ({
    back : junction,
    front : shadowMap,
  });

  pathsDeduce();
  peerDeduce();
  associationsFill();
  peerDeduce();
  pathsDeduce();

  for( let s in shadowMap )
  if( shadowMap[ s ] === _.unknown )
  delete shadowMap[ s ];

  return shadowProxy;

  function associationsFill()
  {
    if( defined( shadowMap.module ) )
    objectAssociationsAppend( shadowMap.module );
    if( defined( shadowMap.opener ) )
    objectAssociationsAppend( shadowMap.opener );
    if( defined( shadowMap.relation ) )
    objectAssociationsAppend( shadowMap.relation );
  }

  function objectAssociationsAppend( object )
  {
    junction.AssociationsOf( object ).forEach( ( object ) =>
    {
      if( object instanceof _.Will.Module )
      {
        if( shadowMap.module === _.unknown )
        shadowMap.module = object;
      }
      else if( object instanceof _.Will.ModuleOpener )
      {
        if( shadowMap.opener === _.unknown )
        shadowMap.opener = object;
      }
      else if( object instanceof _.Will.ModulesRelation )
      {
        if( shadowMap.relation === _.unknown )
        shadowMap.relation = object;
      }
      else _.assert( 0 );
    });
  }

  function pathsFrom( object )
  {
    let paths = junction.PathsOfAsMap( object );
    if( paths.localPath && shadowMap.localPath === _.unknown )
    shadowMap.localPath = paths.localPath;
    if( paths.remotePath && shadowMap.remotePath === _.unknown )
    shadowMap.remotePath = paths.remotePath;
  }

  function pathsDeduce()
  {
    if( shadowMap.localPath !== _.unknown && shadowMap.remotePath !== _.unknown )
    return true;
    if( defined( shadowMap.module ) )
    pathsFrom( shadowMap.module );
    if( shadowMap.localPath !== _.unknown && shadowMap.remotePath !== _.unknown )
    return true;
    if( defined( shadowMap.opener ) )
    pathsFrom( shadowMap.opener );
    if( shadowMap.localPath !== _.unknown && shadowMap.remotePath !== _.unknown )
    return true;
    if( defined( shadowMap.relation ) )
    pathsFrom( shadowMap.relation );
    if( shadowMap.localPath !== _.unknown && shadowMap.remotePath !== _.unknown )
    return true;
    return false;
  }

  function peerDeduce()
  {
    if( shadowMap.peer !== _.unknown )
    return true;

    if( shadowMap.module && shadowMap.module.peerModule )
    peerFrom( shadowMap.module.peerModule );
    else if( shadowMap.opener && shadowMap.opener.peerModule )
    peerFrom( shadowMap.opener.peerModule );

    if( shadowMap.peer !== _.unknown )
    return true;
    return false;
  }

  function peerFrom( peerModule )
  {
    _.assert( peerModule instanceof _.Will.Module );
    _.assert( shadowMap.peer === _.unknown );
    shadowMap.peer = junction.JunctionWithObject( will, peerModule );
    if( !shadowMap.peer )
    shadowMap.peer = junction.JunctionFrom( will, peerModule );
    shadowMap.peer = shadowMap.peer.shadow({ module : peerModule, peer : shadowProxy });
  }

  function defined( val )
  {
    return !!val && ( val !== _.unknown );
  }

}

shadow.defaults =
{
  module : _.unknown,
  relation : _.unknown,
  opener : _.unknown,
  peer : _.unknown,
}

//

function assertIntegrityVerify()
{
  let junction = this;
  let will = junction.will;
  let objects = junction.objects;

  objects.forEach( ( object ) =>
  {
    _.assert( will.objectToJunctionHash.get( object ) === junction, `Integrity of ${junction.nameWithLocationGet()} is broken. Another junction has this object.` );
    _.assert( _.longHasAll( objects, junction.AssociationsOf( object ) ), `Integrity of ${junction.nameWithLocationGet()} is broken. One or several associations are no in the list.` );
    let p = junction.PathsOfAsMap( object );
    _.assert( !p.localPath || _.longHas( junction.localPaths, p.localPath ), `Integrity of ${junction.nameWithLocationGet()} is broken. Local path ${p.localPath} is not in the list` );
    _.assert( !p.remotePath || _.longHas( junction.remotePaths, p.remotePath ), `Integrity of ${junction.nameWithLocationGet()} is broken. Remote path ${p.remotePath} is not in the list` );
  });

  return true;
}

//

function toModule()
{
  let junction = this;
  return junction.module;
}

//

function toOpener()
{
  let junction = this;
  return junction.opener;
}

//

function toRelation()
{
  let junction = this;
  return junction.relation;
}

//

function toJunction()
{
  let junction = this;
  return junction;
}

// --
// export
// --

function exportInfo()
{
  let result = '';
  let junction = this;

  result += `junction:: : #${junction.id}\n`;

  let lpl = ' ';
  if( junction.localPaths.length > 1 )
  lpl = ` ( ${junction.localPaths.length} ) `;
  if( junction.localPath )
  result += `  path::local${lpl}: ${junction.localPath}\n`;

  let rpl = ' ';
  if( junction.remotePaths.length > 1 )
  rpl = ` ( ${junction.remotePaths.length} ) `;
  if( junction.remotePath )
  result += `  path::remote${rpl}: ${junction.remotePath}\n`;

  if( junction.modules.length )
  {
    result += '  ' + junction.module.absoluteName + ' #' + junction.modules.map( ( m ) => m.id ).join( ' #' ) + '\n';
  }
  if( junction.opener )
  {
    result += '  ' + junction.opener.absoluteName + ' #' + junction.openers.map( ( m ) => m.id ).join( ' #' ) + '\n';
  }
  if( junction.relation )
  {
    result += '  ' + junction.relation.absoluteName + ' #' + junction.relations.map( ( m ) => m.id ).join( ' #' ) + '\n';
  }
  if( junction.peer )
  {
    result += `  peer::junction : #${junction.peer.id}\n`;
  }

  return result;
}

//

function nameWithLocationGet()
{
  let junction = this;
  let name = _.color.strFormat( junction.object.qualifiedName || junction.name, 'entity' );
  let localPath = _.color.strFormat( junction.localPath, 'path' );
  let result = `${name} at ${localPath}`;
  return result;
}

// --
// etc
// --

function moduleSet( module )
{
  let junction = this;
  junction[ moduleSymbol ] = module;
  return module;
}

//

function dirPathGet()
{
  let junction = this;
  if( !junction.localPath )
  return null;
  let will = junction.will;
  let fileProvider = will.fileProvider;
  let path = fileProvider.path;
  return path.detrail( path.dirFirst( junction.localPath ) );
}

//

function enabledGet()
{
  let junction = this;
  let result = null;

  if( junction.module )
  result = junction.module.about.enabled;
  else if( junction.peer && junction.peer.module )
  result = junction.peer.module.enabled;

  _.assert( result === null || _.boolIs( result ) );
  return result;
}

//

function isRemoteGet()
{
  let junction = this;
  let result = null;

  if( junction.module && junction.module.repo )
  result = junction.module.repo.isRemote;
  else if( junction.opener && junction.opener.repo )
  result = junction.opener.repo.isRemote;
  else if( junction.peer && junction.peer.module && junction.peer.module.repo )
  result = junction.peer.module.repo.isRemote;
  else if( junction.peer && junction.peer.opener && junction.peer.opener.repo )
  result = junction.peer.opener.repo.isRemote;

  _.assert( result === null || _.boolIs( result ) );
  return result;
}

//

function objectsGet()
{
  let junction = this;
  let result = [];

  _.each( junction.modules, ( module ) => result.push( module ) );
  _.each( junction.openers, ( opener ) => result.push( opener ) );
  _.each( junction.relations, ( relation ) => result.push( relation ) );

  return result;
}

// --
// relations
// --

let moduleSymbol = Symbol.for( 'module' );

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{

  will : null,

}

let Medials =
{

  module : null,
  opener : null,
  relation : null,
  object : null,

}

let Restricts =
{

  name : null,
  id : null,
  isOut : null,
  formed : 0,

  localPath : null,
  localPaths : _.define.own([]),
  remotePath : null,
  remotePaths : _.define.own([]),

  module : null,
  modules : _.define.own([]),
  opener : null,
  openers : _.define.own([]),
  relation : null,
  relations : _.define.own([]),
  object : null,
  peer : null,

}

let Statics =
{
  From,
  PathsOf,
  PathsOfAsMap,
  JunctionReform,
  JunctionsReform,
  JunctionFrom,
  JunctionsFrom,
  JunctionWithObject,
  JunctionsWithObjects,
  AssociationsOf,
  ObjectToOptionsMap,
}

let Forbids =
{
  recordsMap : 'recordsMap',
  commonPath : 'commonPath',
  nodesGroup : 'nodesGroup',
  junctionMap : 'junctionMap',
}

let Accessors =
{
  dirPath : { getter : dirPathGet, readOnly : 1 },
  enabled : { getter : enabledGet, readOnly : 1 },
  isRemote : { getter : isRemoteGet, readOnly : 1 },
  objects : { getter : objectsGet, readOnly : 1 },
}

// --
// declare
// --

let Extend =
{

  // inter

  finit,
  init,
  reform,
  mergeIn,
  mergeMaybe,

  From,
  PathsOf,
  PathsOfAsMap,
  JunctionReform,
  JunctionsReform,
  JunctionFrom,
  JunctionsFrom,
  JunctionWithObject,
  JunctionsWithObjects,
  AssociationsOf,
  ObjectToOptionsMap,

  _relationAdd,
  _relationRemoveSingle,
  _relationRemove,
  _openerAdd,
  _openerRemoveSingle,
  _openerRemove,
  _moduleAdd,
  _moduleRemoveSingle,
  _moduleRemove,

  _add,
  add,
  _remove,
  remove,
  own,
  ownSomething,
  isUsed,
  submodulesJunctionsFilter,
  shadow,
  assertIntegrityVerify,
  toModule,
  toOpener,
  toRelation,
  toJunction,

  // export

  exportInfo,
  nameWithLocationGet,

  // etc

  moduleSet,
  dirPathGet,
  enabledGet,
  isRemoteGet,
  objectsGet,

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

_.Copyable.mixin( Self );

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

_.staticDeclare
({
  prototype : _.Will.prototype,
  name : Self.shortName,
  value : Self,
});

})();