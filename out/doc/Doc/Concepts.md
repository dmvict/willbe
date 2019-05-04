
## Quick start

For quick start [install](<./tutorial/Instalation.md>) utility `willbe`, [get acquainted with](<./tutorial/CLI.md>) command line interface and create the first [module "Hello World"](<./tutorial/HelloWorld.md>). [Read](<./tutorial/Abstract.md>) abstract if you are wondering what is it for and what philosophy is behind utility `willbe`.

For gentle introduction use tutorials. For getting exhaustive information on one or another aspect use list of concepts to find a concept of interest and get familiar with it.

## Concepts

<details><summary><a href="./concept/WillFile.md">
      Configuration <code>will-file</code>
  </a></summary>
  Configuration for describing and building a module. Each formal module has such a file.
</details>
<details><summary><a href="./concept/WillFileNamedAndSplit.md#Named-will-file">
      Named <code>will-file</code>
  </a></summary>
  Kind of <code>will-file</code> which has a nonstandard name. It makes possible to have multiple modules with different names in a directory.
</details>
<details><summary><a href="./concept/WillFileNamedAndSplit.md#Split-will-file">
      Split <code>will-file</code>
  </a></summary>
  Splitting <code>will-file</code> into two files. One of them is for importing data and other is for exporting. It makes possible to split data related building and to develop a module and data which can be used by another modules.
</details>
<details><summary><a href="./concept/WillFileExported.md#Exported-will-file-out-will-file">
      Exported <code>will-file</code> (<code>out-will-file</code>)
  </a></summary>
  <code>Out-will-file</code> - kind of <code>will-file</code> which is generated by the utility during exporting of a module. Other modules can use the module importing its <code>out-will-file</code>.
</details>
<details><summary><a href="./concept/Structure.md#Resources">
      Resources
  </a></summary>
  Structural and functional element of <code>will-file</code>. Resources of the same type collected in a section.
</details>
<details><summary><a href="./concept/Structure.md#Type-of-resource">
      Type of resource
  </a></summary>
  Functionality associated with the group of resources restricted by its purpose. Examples of types of resources: path, submodule, step, build. Each type of resources has its own purpose and is treated by the utility differently.
</details>
<details><summary><a href="./concept/Inheritance.md">
      Inheritance
  </a></summary>
    It is the approach to describing a module when <code>will-file</code> can reuse (inherit) value of fields of another resource(s) of the same type.
</details>
<details><summary><a href="./concept/ResourcePath.md#Path">
      Resource path
  </a></summary>
  Resource for determination of the module's file structure. It includes paths to the module files. The paths are placed in the section <code>path</code>.
</details>
<details><summary><a href="./concept/ResourceReflector.md#Resource-reflector">
      Resource reflector
  </a></summary>
    It is a resource of section <code>reflector</code>, a method to describe a set of files in order to perform some operation on it.
</details>
<details><summary><a href="./concept/ReflectorFileFilter.md">
      File filters
  </a></summary>
  Technique of describing the conditions for selecting the required files for some operation on a group of files. Reflector has two file filters: <code>src</code> and <code>dst</code>.
</details>
<details><summary><a href="./concept/ResourceReflector.md#map-of-paths">
      Map of paths
  </a></summary>
  A field of a reflector and a technique of description of the set of files which allows to include plenty of files and to exclude unwanted files by means of excluding conditions and globs out of it.
</details>
<details><summary><a href="./concept/ResourceStep.md#Resource-step">
      Resource step
  </a></summary>
  Instruction for building the module. Describe an operation and desired outcome. Build consists of <code>steps</code>.
</details>
<details><summary><a href="./concept/ResourceBuild.md#Resource-build">
      Resource build
  </a></summary>
    Sequence and conditions of procedures execution to build a module. By implementation of the command <code>will .build</code>, developer has to select a particular build which is wanted unambiguously calling command by name or by conditions of the build.
</details>
<details><summary><a href="./concept/ResourceBuild.md#Resource-export">
      Resource export
  </a></summary>
  Special kind of build which required for the module to been used by other developers and modules. Result of exporting is generated files among wich is <code>out-will-file</code> and archive.
</details>
<details><summary><a href="./concept/Structure.md#Section-will-file">
      Section of <code>will-file</code>
  </a></summary>
  The highest structural unit of the <code>will-file</code> which consists of one-type resources or fields that describe this module.  
</details>
<details><summary><a href="./concept/SectionAbout.md">
      Section <code>about</code>
  </a></summary>
  The section has the descriptive information about the module.
</details>
<details><summary><a href="./concept/ResourcePath.md#Section-path">
      Section <code>path</code>
  </a></summary>
  Section has the list of the module paths for quick orientation in its file structure.
</details>
<details><summary><a href="./concept/SectionSubmodule.md">
      Section <code>submodule</code>
  </a></summary>
  The section has an information about submodules.
</details>
<details><summary><a href="./concept/ResourceReflector.md#Section-reflector">
      Section <code>reflector</code>
  </a></summary>
  The section has reflectors. It is a special type of resources for operation on the groups of files.
</details>
<details><summary><a href="./concept/ResourceStep.md#Section-step">
      Section <code>step</code>
  </a></summary>
  The section has steps which could be used by build for building of the module.
</details>
<details><summary><a href="./concept/ResourceBuild.md#Section-build">
      Section <code>build</code>
  </a></summary>
  Resources of the section (build) describe sequence and conditions of procedures of module's building.
</details>
<details><summary><a href="./concept/SectionExported.md">
      Section <code>exported</code>
  </a></summary>
  It is programmatically generated section of <code>out-will-file</code> by exporting a module. It has a list of exported files and it is used by other modules for importing the module.
</details>
<details><summary><a href="./concept/Module.md#Module">
      Module
  </a></summary>
  A module is a set of files that are described in <code>will-file</code>.
</details>
<details><summary><a href="./concept/Module.md#Submodule">
      Submodule
  </a></summary>
  A module with its own <code>will-file</code> which is used by other module (supermodule).
</details>
<details><summary><a href="./concept/Module.md#Supermodule">
      Supermodule
  </a></summary>
  A module which includes other modules (submodules).
</details>
<details><summary><a href="./concept/SubmodulesLocalAndRemote.md#Local-submodule">
      Local submodule
  </a></summary>
  A submodule which is located locally.
</details>
<details><summary><a href="./concept/SubmodulesLocalAndRemote.md#Remote-submodule">
      Remote submodule
  </a></summary>
  A module located on the remote server is downloaded to the local machine for use.
</details>
<details><summary><a href="./concept/SubmoduleInformal.md">
      Informal submodule
  </a></summary>
  Set of files distribution of which does not include <code>will-file</code>. For such a submodule it is possible to create <code>will-file</code> independently.
</details>
<details><summary><a href="./concept/ModuleCurrent.md">
      Current module
  </a></summary>
  A module with respect to which operations are performed. By default the module is loaded from file <code>.will.yml</code> of the current directory or pair of files <code>.im.will.yml</code> and <code>.ex.will.yml</code>.
</details>
<details><summary><a href="./concept/Command.md#Command">
      Command
  </a></summary>
  A string which has phrase which describes intention of a developer and actions which will be done by utility after user enters it. It is entered in the interface of the command prompt by developer.
</details>
<details><summary><a href="./concept/Command.md#Phrase">
      Phrase
  </a></summary>
  Word or several words, separated by dot, it denotes command which utility should perform.
</details>
<details><summary><a href="./concept/Selector.md#Selector">
      Selector
  </a></summary>
  String-reference on resource or group of resources of the module.
</details>
<details><summary><a href="./concept/Selector.md#Selector-with-globs">
      Selector with globs
  </a></summary>
  Selector which uses searching patterns (globs) for selecting of resources.
</details>
<details><summary><a href="./concept/Selector.md#Glob-with-assertion">
      Glob with assertion
  </a></summary>
  Special syntax construction appended after glob to restrict by expected number of resources which should be found by the selector.
</details>
<details><summary><a href="./concept/Criterions.md">
      Criterion
  </a></summary>
  Element of comparison for selection of resources.
</details><details><summary><a href="./concept/SectionAbout.md">
      Section <code>about</code>
  </a></summary>
  The section has the descriptive information about the module.
</details>
<details><summary><a href="./concept/ResourcePath.md#Section-path">
      Section <code>path</code>
  </a></summary>
  The section has the list of the paths for quick orientation in its file structure.
</details>
<details><summary><a href="./concept/SectionSubmodule.md">
      Section <code>submodule</code>
  </a></summary>
  The section has an information about submodules.
</details>
<details><summary><a href="./concept/ResourceReflector.md#Section-reflector">
      Section <code>reflector</code>
  </a></summary>
  The section has reflectors. It is  a special type of resources for operation at the groups of files.
</details>
<details><summary><a href="./concept/ResourceStep.md#Section-step">
      Section <code>step</code>
  </a></summary>
  The section has steps which could be used by build for building of the module.
</details>
<details><summary><a href="./concept/ResourceBuild.md#Section-build">
      Section <code>build</code>
  </a></summary>
  Resources of the section (build) describe sequence and conditions of procedures of module's building.
</details>
<details><summary><a href="./concept/SectionExported.md">
      Section <code>exported</code>
  </a></summary>
  It is programmatically generated section of <code>out-will-file</code> by exporting a module. It has a list of exported files and it is used by other modules for importing the module.
</details>
<details><summary><a href="./concept/Module.md#Module">
      Module
  </a></summary>
  Module is the set of files, which is described in <code>will-file</code>.
</details>
<details><summary><a href="./concept/Module.md#Submodule">
      Submodule
  </a></summary>
  A module with its own <code>will-file</code> which is used by other module (supermodule).
</details>
<details><summary><a href="./concept/Module.md#Supermodule">
      Supermodule
  </a></summary>
  A module which includes other modules (submodules).
</details>
<details><summary><a href="./concept/SubmodulesLocalAndRemote.md#Local-submodule">
      Local submodule
  </a></summary>
  A submodule which is located locally.
</details>
<details><summary><a href="./concept/SubmodulesLocalAndRemote.md#Remote-submodule">
      Remote submodule
  </a></summary>
  A module which is located at the remote server. It should be downloaded in order to be used.
</details>
<details><summary><a href="./concept/SubmoduleInformal.md">
      Informal submodule
  </a></summary>
  Set of files distribution of which does not include <code>will-file</code>. For such a submodule it is possible to create <code>will-file</code> independently.
</details>
<details><summary><a href="./concept/ModuleCurrent.md">
      Current module
  </a></summary>
  A module with respect to which operations are performed. By default the module is loaded from file <code>.will.yml</code> of the current directory or pair of files <code>.im.will.yml</code> and <code>.ex.will.yml</code>.
</details>
<details><summary><a href="./concept/Command.md#Command">
      Command
  </a></summary>
  A string which has phrase which describes intention of a developer and actions which will be done by utility after user enters it. It is entered in the interface of the command prompt by developer.
</details>
<details><summary><a href="./concept/Command.md#Phrase">
      Phrase
  </a></summary>
  Word or several words, separated by dot, it denotes command which utility should perform.
</details>
<details><summary><a href="./concept/Selector.md#Selector">
      Selector
  </a></summary>
  String-reference on resource or group of resources of the module.
</details>
<details><summary><a href="./concept/Selector.md#Selector-with-globs">
      Selector with globs
  </a></summary>
  Selector which uses searching patterns (globs) for selecting of resources.
</details>
<details><summary><a href="./concept/Selector.md#Glob-with-assertion">
      Glob with assertion
  </a></summary>
  Special syntax construction appended after glob to restrict by expected number of resources which should be found by the selector.
</details>
<details><summary><a href="./concept/Criterions.md">
      Criterion
  </a></summary>
  Element of comparison for selection of resources.
</details>