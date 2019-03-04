# Робота з підмодулями

В туторіалі продовжено опис імпортованих підмодулів, більш детально розглянуто їх адміністрування

В попередньому туторіалі йдеться про умовне [_"наслідування"_ ресурсами властивостей секції](ImportingSubmodules.md#resource-inheritation), тобто, ресурс має наслідувати структуру секції за замовчуванням, а для `submodule` вона включає чотири поля: `description`, `path`, `criterion`, `inherit`. Два останніх - предмет окремих туторіалів, з ними ознайомитесь пізніше, а поки що перепишемо попередній приклад:
<a name="short-form">
    
```yaml
submodule :

    WTools : git+https:///github.com/Wandalen/wTools.git/out/wTools#master  
    PathFundamentals : git+https:///github.com/Wandalen/wPathFundamentals.git/out/wPathFundamentals#master

```

додавши до першого з підмодулів поля `path` та `description`:

<a name="full-form">
    
```yaml
submodule :

    WTools :
       path : git+https:///github.com/Wandalen/wTools.git/out/wTools#master
       description : 'Import willbe tools'  
    PathFundamentals : git+https:///github.com/Wandalen/wPathFundamentals.git/out/wPathFundamentals#master

```

Введіть в консолі `will .submodules.list`:

```
...
submodule::WTools
  path : git+https:///github.com/Wandalen/wTools.git/out/wTools#master
  description : Import willbe tools
  isDownloaded : true
  Exported builds : [ 'proto.export' ]
submodule::PathFundamentals
  path : git+https:///github.com/Wandalen/wPathFundamentals.git/out/wPathFundamentals#master
  isDownloaded : false
  Exported builds : []

```  

<a name="submodules-cleaning">
    
Маємо один завантажений підмодуль з описом. Для завантаження другого введіть фразу `will .submodules.download`. Проте, краще виконаємо чисте встановлення попередньо видаливши підмодулі фразою `will .submodules.clean`

```
will .submodules.clean
Request ".submodules.clean"
   . Read : /path_to_file/.will.yml
 . Read 1 will-files in 0.082s
 . Read : /path_to_file/.module/WTools/out/wTools.out.will.yml
 ! Failed to read submodule::PathFundamentals, try to download it with .submodules.download or even clean it before downloading
 - Clean deleted 252 file(s) in 0.907s

```

Після `.submodules.download` структура модуля матиме вигляд:
```
.
├── .module
|   ├──WTools
|   └──PathFundamentals
└── .will.yml

```  

### Підсумок
- Ресурс секції може мати [скорочену](#short-form) і [повну](#full-form) форму запису.
- Для чистого встановлення підмодулів бажано попередньо [очистити директорію `.module`](#submodules-cleaning).

[Наступний туторіал](CriterionsInWillFile.ukr.md)  
[Повернутись до меню](Topics.ukr.md)