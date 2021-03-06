## Quick start

For quick start [install](<./tutorial/Installation.md>) utility `willbe`, [get acquainted with](<./tutorial/CLI.md>) command line interface and create the first [module "Hello World"](<./tutorial/HelloWorld.md>). [Read](<./tutorial/Abstract.md>) abstract if you are wondering what is it for and what philosophy is behind utility `willbe`.

For gentle introduction use tutorials. For getting exhaustive information on one or another aspect use list of concepts to find a concept of interest and get familiar with it.

## Concepts

<details>
  <summary><a href="./concept/WillFile.md">
    Configuration <code>willfile</code>
  </a></summary>
    Configuration for describing and building a module. Each formal module has such a file.
</details>

<details>
  <summary><a href="./concept/WillFileNamedAndSplit.md#Named-willfile">
    Named <code>willfile</code>
  </a></summary>
    Kind of <code>willfile</code> which has a non-standard name. It makes possible to have multiple modules with different names in a directory.
</details>

<details>
  <summary><a href="./concept/WillFileNamedAndSplit.md#Split-willfile">
    Split <code>willfile</code>
  </a></summary>
    Splitting <code>willfile</code> into two files. One of them is for the import of the module and the other is for export of it. It makes possible to split data related building and to develop a module and data which can be used by other modules.
</details>

<details>
  <summary><a href="./concept/WillFileExported.md#Exported-willfile-out-willfile">
    Exported <code>willfile</code> (<code>out-willfile</code>)
  </a></summary>
    <code>Out-willfile</code> is a kind of <code>willfile</code> which is generated by the utility during the export of a module. Other modules can use the module by importing its <code>out-willfile</code>.
</details>

<details>
  <summary><a href="./concept/Structure.md#Resources">
    Resources
  </a></summary>
    Structural and functional unit of <code>willfile</code>. Resources of the same type are collected in a section.
</details>

<details>
  <summary><a href="./concept/Structure.md#Type-of-resource">
    Type of resource
  </a></summary>
    Functionality which is associated with a group of resources. It is limited by its purpose. An example of resource types is a path, submodule, step, build. Each type of resource has its own purpose and is processed by a utility in different ways.

</details>

<details>
  <summary><a href="./concept/Inheritance.md">
    Inheritance
  </a></summary>
It is the approach of the module description according to which the <code>willfile</code> can reuse (inherit) field values of another resource(s) of the same type.</details>

<details>
  <summary><a href="./concept/ResourcePath.md#Path">
    Resource path
  </a></summary>
    Resource for determination of the module's file structure. It includes paths to the module files. The paths are placed in the section <code>path</code>.
</details>

<details>
  <summary><a href="./concept/ResourceReflector.md#Resource-reflector">
    Resource reflector
  </a></summary>
    It is a resource of the <code>reflector</code> section. It is the method to describe a set of files in order to perform some operation on it.
</details>

<details>
  <summary><a href="./concept/ReflectorFileFilter.md">
    File filters
  </a></summary>

  Technique of the file selection in order to perform the operation on it. Reflector has two file filters: <code>src</code> and <code>dst</code>.
</details>

<details>
  <summary><a href="./concept/ResourceReflector.md#map-of-paths">
    Map of paths
  </a></summary>
It is reflector field and the way to describe a set of files that allows to include a lot of files in it. Moreover it allows to exclude from it the files that are not required by the terms of exclusion and globes.
</details>

<details>
  <summary><a href="./concept/ResourceStep.md#Resource-step">
    Resource step
  </a></summary>
    Instruction for building the module. Describe an operation and desired outcome. Build consists of <code>steps</code>.
</details>

<details>
  <summary><a href="./concept/ResourceBuild.md#Resource-build">
    Resource build
  </a></summary>
Sequence and conditions of the procedure's execution to build a module. By implementation of the command <code>will .build</code>, the developer has to select a particular build which is wanted unambiguously calling command by name or by conditions of the build.
</details>

<details>
  <summary><a href="./concept/ResourceBuild.md#Resource-export">
    Resource export
  </a></summary>
A special kind of build which is required in order to use this module by other developers and modules. The result of the module export is generated files, which is <code>out-willfile</code> and archive.
</details>

<details>
  <summary><a href="./concept/Structure.md#Section-willfile">
    Section of <code>willfile</code>
  </a></summary>
    The highest structural unit of the <code>willfile</code>, which consists of one-type resources or fields that describe this module.
</details>

<details>
  <summary><a href="./concept/SectionAbout.md">
    Section <code>about</code>
  </a></summary>
    The section contains the descriptive information about the module.
</details>

<details>
  <summary><a href="./concept/ResourcePath.md#Section-path">
    Section <code>path</code>
  </a></summary>
    Section has the list of the module paths for quick orientation in its file structure.
</details>

<details>
  <summary><a href="./concept/SectionSubmodule.md">
    Section <code>submodule</code>
  </a></summary>
    The section contains the information about the submodules.
</details>

<details>
  <summary><a href="./concept/ResourceReflector.md#Section-reflector">
    Section <code>reflector</code>
  </a></summary>
The section has reflectors. It is a special type of resources for operation on the groups of files.
</details>

<details>
  <summary><a href="./concept/ResourceStep.md#Section-step">
    Section <code>step</code>
  </a></summary>
    The section contains steps that can be used by the build to build the module.
</details>

<details>
  <summary><a href="./concept/ResourceBuild.md#Section-build">
    Section <code>build</code>
  </a></summary>
    Resources of the section (build) describe sequence and conditions of procedures of module building.
</details>

<details>
  <summary><a href="./concept/SectionExported.md">
    Section <code>exported</code>
  </a></summary>
    The <code>out-willfile</code> section is programmatically generated when the module is exported. It contains the list of all exported files and is used by the importation of this module by another one.
</details>

<details>
  <summary><a href="./concept/Module.md#Module">
    Module
  </a></summary>
    A module is a set of files that are described in <code>willfile</code>.
</details>

<details>
  <summary><a href="./concept/Module.md#Submodule">
    Submodule
  </a></summary>
    An individual module with its own configuration <code> willfile </code> which is used by another module (supermodule).
</details>

<details>
  <summary><a href="./concept/Module.md#Supermodule">
    Supermodule
  </a></summary>
    A module which includes other modules (submodules).
</details>

<details>
  <summary><a href="./concept/SubmodulesLocalAndRemote.md#Local-submodule">
    Local submodule
  </a></summary>
    A submodule which is located on the local machine.
</details>

<details>
  <summary><a href="./concept/SubmodulesLocalAndRemote.md#Remote-submodule">
    Remote submodule
  </a></summary>
    A module located on the remote server is downloaded to the local machine for use.
</details>

<details>
  <summary><a href="./concept/SubmoduleInformal.md">
    Informal submodule
  </a></summary>
    A set of files that are not distributed with <code>willfile</code>. For such submodule it is possible to create <code>willfile</code> independently.
</details>

<details>
  <summary><a href="./concept/ModuleCurrent.md">
    Current module
  </a></summary>
    A module with respect to which the operations are performed. By default, this module loads from the file <code>.will.yml</code> of the current directory or from a pair of files <code>.im.will.yml</code> and <code>.ex.will.yml</code>.
</details>

<details>
  <summary><a href="./concept/Command.md#Command">
    Command
  </a></summary>
A string which has phrase which describes intention of a developer and actions which will be done by utility after user enters it. It is entered in the interface of the command prompt by developer.
</details>

<details>
  <summary><a href="./concept/Command.md#Phrase">
    Phrase
  </a></summary>
    Word or several words, separated by dot, it denotes command which utility should perform.
</details>

<details>
  <summary><a href="./concept/Selector.md#Selector">
    Selector
  </a></summary>
    String-reference on resource or group of resources of the module.
</details>

<details>
  <summary><a href="./concept/Selector.md#Selector-with-globs">
    Selector with globs
  </a></summary>
    Selector which uses searching patterns (globs) for selecting of resources.
</details>

<details>
  <summary><a href="./concept/Selector.md#Glob-with-assertion">
    Glob with assertion
  </a></summary>
    Special syntax construction appended after glob to restrict a number of resources which should be found by the selector.
</details>

<details>
  <summary><a href="./concept/Criterions.md">
    Criterion
  </a></summary>
    Element of comparison for selection of resources.
</details>

<details>
  <summary><a href="./concept/SectionAbout.md">
    Section <code>about</code>
  </a></summary>
    The section has the descriptive information about the module.
</details>

<details>
  <summary><a href="./concept/ResourcePath.md#Section-path">
    Section <code>path</code>
  </a></summary>
    The section has the list of the paths for quick orientation in its file structure.
</details>

<details>
  <summary><a href="./concept/SectionSubmodule.md">
    Section <code>submodule</code>
  </a></summary>
    The section has an information about submodules.
</details>

<details>
  <summary><a href="./concept/ResourceReflector.md#Section-reflector">
    Section <code>reflector</code>
  </a></summary>
    The section has reflectors. It is  a special type of resources for operation at the groups of files.
</details>

<details>
  <summary><a href="./concept/ResourceStep.md#Section-step">
    Section <code>step</code>
  </a></summary>
    The section has steps which could be used by build for building of the module.
</details>

<details>
  <summary><a href="./concept/ResourceBuild.md#Section-build">
    Section <code>build</code>
  </a></summary>
    Resources of the section (build) describe sequence and conditions of procedures of module's building.
</details>

<details>
  <summary><a href="./concept/SectionExported.md">
    Section <code>exported</code>
  </a></summary>
    It is programmatically generated section of <code>out-willfile</code> by exporting a module. It has a list of exported files and it is used by other modules for importing the module.
</details>

<details>
  <summary><a href="./concept/Module.md#Module">
    Module
  </a></summary>
    Module is the set of files, which is described in <code>willfile</code>.
</details>

<details>
  <summary><a href="./concept/Module.md#Submodule">
    Submodule
  </a></summary>
    A module with its own <code>willfile</code> which is used by other module (supermodule).
</details>

<details>
  <summary><a href="./concept/Module.md#Supermodule">
    Supermodule
  </a></summary>
    A module which includes other modules (submodules).
</details>

<details>
  <summary><a href="./concept/SubmodulesLocalAndRemote.md#Local-submodule">
    Local submodule
  </a></summary>
    A submodule which is located locally.
</details>

<details>
  <summary><a href="./concept/SubmodulesLocalAndRemote.md#Remote-submodule">
    Remote submodule
  </a></summary>
    A module which is located at the remote server. It should be downloaded in order to be used.
</details>

<details>
  <summary><a href="./concept/SubmoduleInformal.md">
    Informal submodule
  </a></summary>
    Set of files distribution of which does not include <code>willfile</code>. For such a submodule it is possible to create <code>willfile</code> independently.
</details>

<details>
  <summary><a href="./concept/ModuleCurrent.md">
    Current module
  </a></summary>
    A module with respect to which operations are performed. By default the module is loaded from file <code>.will.yml</code> of the current directory or pair of files <code>.im.will.yml</code> and <code>.ex.will.yml</code>.
</details>

<details>
  <summary><a href="./concept/Command.md#Command">
    Command
  </a></summary>
    A string which has phrase which describes intention of a developer and actions which will be done by utility after user enters it. It is entered in the interface of the command prompt by developer.
</details>

<details>
  <summary><a href="./concept/Command.md#Phrase">
    Phrase
  </a></summary>
    Word or couple of words which are separated by a point. It specifies the command to be executed by the utility.
</details>

<details>
  <summary><a href="./concept/Selector.md#Selector">
    Selector
  </a></summary>
    String-reference on the resource or the group of the module resources.
</details>

<details>
  <summary><a href="./concept/Selector.md#Selector-with-globs">
    Selector with globs
  </a></summary>
    Selector which uses searching patterns (globs) for selection of the resources.
</details>

<details>
  <summary><a href="./concept/Selector.md#Glob-with-assertion">
    Glob with assertion
  </a></summary>
    A special syntactic construct that is added to the globe to limit the amount of resources which have to be found by the selector with this glob.
</details>

<details>
  <summary><a href="./concept/Criterions.md">
    Criterion
  </a></summary>
    Element of comparison for selection of the resources.
</details>

## Tutorials

<details>
  <summary><a href="./tutorial/Abstract.md">
     Abstract
  </a></summary>
    Abstract. What utility <code>willbe</code> is and what it is not.
</details>

<details>
  <summary><a href="./tutorial/Installation.md">
    Installation
  </a></summary>
    Procedure of installation of a utility. <code>willbe</code>
</details>

<details>
  <summary><a href="./tutorial/CLI.md">
    Command line interface
  </a></summary>
    How to use command line interface of utility <code>willbe</code>. How to use command <code>.help</code> and <code>.list</code>.
</details>

<details>
  <summary><a href="./tutorial/HelloWorld.md">
    Module "Hello, World!"
  </a></summary>
    Creating module "Hello, World!". Downloading of remoted submodule.
</details>

<details>
  <summary><a href="./tutorial/CommandSubmodulesFixate.md">
    Command <code>.submodules.fixate</code>
  </a></summary>
    The command to fixate the submodule version in <code>willfile</code> using its automated overwriting.
</details>

<details>
  <summary><a href="./tutorial/CommandSubmodulesUpgrade.md">
    Command <code>.submodules.upgrade</code>
  </a></summary>
    The command to upgrade the version of the submodules using the automated overwriting of the <code>willfile</code>.
</details>

<details>
  <summary><a href="./tutorial/CommandSubmodulesUpdate.md">
    Command <code>.submodules.update</code>
  </a></summary>
    Command to update remote submodules.
</details>

<details>
  <summary><a href="./tutorial/CommandSubmodulesClean">
    Command <code>.submodules.clean</code>
  </a></summary>
    The command to clear the module from the temporary and downloaded submodules.
</details>

<details>
  <summary><a href="./tutorial/Build.md">
    Module building by command <code>.build</code>
  </a></summary>
    Build of some builds of the module for construction of it.
</details>

<!--
<details>
  <summary><a href="./tutorial/StepSubmodules.md">
    Predefined steps
  </a></summary>
    How to use predefined steps for the work with remote submodules.
</details>

<details>
  <summary><a href="./tutorial/Criterions.md">
    Criterions
  </a></summary>
    How to use criterions for resource selection.
</details>
-->

<details>
  <summary><a href="./tutorial/CriterionDefault.md">
    Default build of the module
  </a></summary>
    How to construct the build without explicit specification of the argument for command <code>.build</code>.
</details>

<!--
<details>
  <summary><a href="./tutorial/WillFileMinimization.md">
    Minimization of <code>willfile</code>
  </a></summary>
    How to minimize <code>willfile</code> by means of instantiation of sets of criterions.
</details>

<details>
  <summary><a href="./tutorial/ModuleWillFileExported.md">
    Exporting of a module
  </a></summary>
    Exporting of the module to use it by another developer or module.
</details>

<details>
  <summary><a href="./tutorial/SubmodulesLocal.md">
    Importing of local submodule
  </a></summary>
    How to use local submodule from another module (supermodule).
</details>

<details>
  <summary><a href="./tutorial/SelectorsWithGlob.md">
    Selectors with globs
  </a></summary>
    How to use selectors with globs.
</details>

<details>
  <summary><a href="./tutorial/AssertionUsing.md">
    How to use assertions
  </a></summary>
    How assertions help to reduce errors during design.
</details>

<details>
  <summary><a href="./tutorial/WillFileSplit.md">
    Split <code>willfiles</code>
  </a></summary>
    How to create and use a module with split <code>willfile</code>.
</details>

<details>
  <summary><a href="./tutorial/WillFileNamed.md">
    Command <code>.with</code> and named <code>willfile</code>
  </a></summary>
    How to use command <code>.with</code>? What is named <code>willfile</code>?
</details>

<details>
  <summary><a href="./tutorial/CommandEach.md">
    Command <code>.each</code>
  </a></summary>
    Command <code>.each</code> for executing the same operation for plenty modules or submodules.
</details>

<details>
  <summary><a href="./tutorial/CommandShell.md">
    Command <code>.shell</code>
  </a></summary>
    A command to call external application by utility <code>willbe</code> for chosen modules or submodules.
</details>

<details>
  <summary><a href="./tutorial/StepJS.md">
    Using <code>JavaScript</code> files by utility <code>willbe</code>
  </a></summary>
    How to use JavaScript files by utility <code>willbe</code> for implementation of complicated scenarios of builds.
</details>

<details>
  <summary><a href="./tutorial/CommandSet.md">
    Command <code>.set</code>
  </a></summary>
    How to use command <code>.set</code> to change the state of the utility, for example to change the level of verbosity.
</details>

<details>
  <summary><a href="./tutorial/SelectorComposite.md">
    Composite selectors
  </a></summary>
    How to use composite selectors for selection of resources out of submodules.
</details>

<details>
  <summary><a href="./tutorial/CommandsListSearch.md">
    List of resources using filters and globs
  </a></summary>
    How to construct a request to utility and obtain the list of resources using filters and globs.
</details>

<details>
  <summary><a href="./tutorial/ReflectorUsing.md">
    Copying of files by reflector
  </a></summary>
    Copying files by reflectors, field <code>recursive</code> of reflector.
</details>

<details>
  <summary><a href="./tutorial/ReflectorMapPaths.md">
    Map of the paths. Using globs to filter files
  </a></summary>
    How the paths of the reflectors are created and how to manage the access to files and directory in reflector.
</details>

<details>
  <summary><a href="./tutorial/ReflectorFilters.md">
    Filters of reflector
  </a></summary>
    Using filters of reflectors for selection of files for copying.
</details>

<details>
  <summary><a href="./tutorial/ReflectorMasks.md">
    Masks of reflector
  </a></summary>
    Using masks of reflectors for selection of files for copying.
</details>

<details>
  <summary><a href="./tutorial/ReflectorTimeFilters.md">
    Time filters of reflector
  </a></summary>
    How to use filters to select files by time.
</details>

<details>
  <summary><a href="./tutorial/ReflectorsPredefined.md">
    Predefined reflectors
  </a></summary>
    Using of predefined reflectors to split on version of debugging  and release.Building of multibuilds.
</details>

<details>
  <summary><a href="./tutorial/ResourceInheritance.md">
    Resources inheritance
  </a></summary>
    How to use resource inheritance to reuse data.
</details>

<details>
  <summary><a href="./tutorial/StepFileView.md">
    Predefined step <code>file.view</code>
  </a></summary>
    How to use predefined step <code>file.view</code> to view files.
</details>

<details>
  <summary><a href="./tutorial/StepFileTranspile.md">
    Transpilation
  </a></summary>
    Using of predefined step <code>files.transpile</code> to transpile <code>JavaScript</code> files or its concatenation.
</details>

<details>
  <summary><a href="./tutorial/WillbeAsMake.md">
    Compiling of С++ application
  </a></summary>
    How to use utility <code>willbe</code> for compiling С++ application.
</details>

<details>
  <summary><a href="./tutorial/SubmoduleInformal.md">
    Informal submodules
  </a></summary>
    Importing of informal submodules.
</details>

<details>
  <summary><a href="./tutorial/CommandClean.md">
    Command  <code>.clean</code>
  </a></summary>
    Using of the command <code>.clean</code> for cleaning generated and temporary files.
</details>

<details>
  <summary><a href="./tutorial/FunctionPlatform.md">
    Building platform dependent modules
  </a></summary>
    Using the operating system determination to build platform dependent modules.
</details>

<details>
  <summary><a href="./tutorial/FunctionStringJoin.md">
    Processing an array of string values in the resources of <code>wilfile</code>
  </a></summary>
    How to use the function of combining string arrays in willfile <code>willfile</code>.
</details>
-->

