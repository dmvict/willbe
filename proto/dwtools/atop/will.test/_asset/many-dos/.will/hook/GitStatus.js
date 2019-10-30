
function onModule( it )
{
  let o = it.request.map;
  let _ = it.tools;
  let logger = it.logger;

  _.fileProvider.filesFind( it.variant.dirPath + '**' );

  if( o.v !== null && o.v !== undefined )
  o.verbosity = o.v;
  _.routineOptions( onModule, o );

  let o2 = _.mapOnly( o, _.git.statusFull.defaults );
  o2.insidePath = it.variant.dirPath;
  let got = _.git.statusFull( o2 );

  if( !got.status )
  return null;

  logger.log( it.variant.nameWithLocationGet() );
  logger.log( got.status );

}

var defaults = onModule.defaults = Object.create( null );

defaults.local = 1;
defaults.uncommitted = null;
defaults.uncommittedUntracked = null;
defaults.uncommittedAdded = null;
defaults.uncommittedChanged = null;
defaults.uncommittedDeleted = null;
defaults.uncommittedRenamed = null;
defaults.uncommittedCopied = null;
defaults.uncommittedIgnored = 0;
defaults.unpushed = null;
defaults.unpushedCommits = null;
defaults.unpushedTags = null;
defaults.unpushedBranches = null;
defaults.remote = 1;
defaults.remoteCommits = null;
defaults.remoteBranches = 0;
defaults.remoteTags = null;
defaults.prs = 1;
defaults.v = null;
defaults.verbosity = 1;

module.exports = onModule;