## Як користуватись командою `.shell`

Команда для виклику зовнішніх програм утилітою <code>willbe</code> для вибраних модулів.

### Kos : please, ask for clarification

Для роботи з модулем часто доводиться використовувати сторонні інструменти - командну оболонку операційної системи чи зовнішні програми. Наприклад, вивести список файлів після побудови, запустити створений файл... Це можна здійснити помістивши в збірку `will-файла` крок `predefined.shell` з потрібною командою, а для повторного використання команд потрібно будувати окремі збірки. Якщо ви працюєте з готовим модулем, вносити зміни в `will-файл` незручно тому, є команда `.shell`, яка дозволяє виконувати команди сторонніх програм в терміналі операційної системи.  

### Використання команди
Команда `.shell` може використовуватись окремо в вигляді `will .shell [command]`, де `[command]` - команда операційної системи чи сторонньої програми, яку утиліта `willbe` виконає з допомогою `.shell`. При такому способі різниці між запуском команди самостійно і разом з `will .shell` не буде, оскільки, команда `.shell` безпосередньо не взаємодіє з компонентами модуля. Для ефективного використання команди `.shell` застосовуйте її разом з командою `.each`, котра виконує команди як над групою `will-файлів`, так і над окремими ресурсами модуля.  
Побудуйте модуль згідно представленої структури:  

<details>
  <summary><u>Відкрийте, щоб проглянути</u></summary>

```
shellCommand
    ├── module.test
    │        ├── one.will.yml
    │        └── two.will.yml
    │
    └── .will.yml       

```

</details>

В файл `.will.yml`, `one.will.yml` та `two.will.yml` внесіть код:

<details>
  <summary><u>Код <code>will-файлів</code></u></summary>
    <p>Код <code>.will.yml</code></p>

```yaml
about :

  name : shellCommand
  description : "To use .shell command"
  version : 0.0.1

submodule :

  Tools : git+https:///github.com/Wandalen/wTools.git/out/wTools#master
  PathFundamentals : git+https:///github.com/Wandalen/wPathFundamentals.git/out/wPathFundamentals#master
  One : module.test/one

build :

  download :
    criterion :
      default : 1
    steps :
      - submodules.download

```

<p>Код <code>one.will.yml</code> і <code>two.will.yml</code></p>

```yaml
about :

  name : noWorkedFile
  description : "Only example of will-file"

```

</details>

Запустіть побудову:

<details>
  <summary><u>Вивід команди <code>will .build</code></u></summary>

```
[user@user ~]$ will .build
...
  Building module::shellCommand / build::download
     . Read : /path_to_file/.module/Tools/out/wTools.out.will.yml
     + module::Tools version master was downloaded in 12.011s
     . Read : /path_to_file/.module/PathFundamentals/out/wPathFundamentals.out.will.yml
     + module::PathFundamentals version master was downloaded in 4.239s
   + 2/4 submodule(s) of module::shellCommand were downloaded in 16.262s
  Built module::shellCommand / build::download in 16.313s

```

<p>Модуль після побудови</p>

```
shellCommand
    ├── .module
    │      ├── Tools
    │      └── PathFundamentals
    ├── module.test
    │        ├── one.will.yml
    │        └── two.will.yml
    │
    └── .will.yml       

```

</details>

З командою `.shell` можна виконати будь-які зовнішні операції над модулем. Для прикладу, виведіть повну інформацію про `will-файли` підмодулів. Для цього використовуйте команду `.each`:  

<details>
  <summary><u>Вивід команди <code>will .each submodule::* .shell ls -al *.yml</code></u></summary>

```
[user@user ~]$ will .each submodule::* .shell ls -al *.yml
...
Module at /path_to_file/.module/Tools/out/wTools.out.will.yml
 > ls -al *.yml
-rw-r--r-- 1 user user 7526 Апр  3 10:00 wTools.out.will.yml

Module at /path_to_file/.module/PathFundamentals/out/wPathFundamentals.out.will.yml
 > ls -al *.yml
-rw-r--r-- 1 user user 5970 Апр  3 10:00 wPathFundamentals.out.will.yml

Module at /path_to_file/module.test/one.will.yml
 > ls -al *.yml
-rw-r--r-- 1 user user 88 Апр  3 09:29 one.will.yml
-rw-r--r-- 1 user user 88 Апр  3 09:29 two.will.yml

```

<p>Модуль</p>

```
shellCommand
    ├── .module
    │      ├── Tools
    │      └── PathFundamentals
    ├── module.test
    │        ├── one.will.yml
    │        └── two.will.yml
    │
    └── .will.yml       

```

</details>

Підмодулі `Tools` i `PathFundamentals` завантажені з Git-репозиторію. Для них можна виконувати git-команди. Наприклад, дізнайтесь статус підмодулів командою `git status`:

<details>
  <summary><u>Вивід команди <code>will .each submodule::*s .shell git status</code></u></summary>

```
[user@user ~]$ will .each submodule::*s .shell git status
...
Module at /path_to_file/.module/Tools/out/wTools.out.will.yml
 > git status
На ветке master
Ваша ветка обновлена в соответствии с «origin/master».
нечего коммитить, нет изменений в рабочем каталоге

Module at /path_to_file/.module/PathFundamentals/out/wPathFundamentals.out.will.yml
 > git status
На ветке master
Ваша ветка обновлена в соответствии с «origin/master».
нечего коммитить, нет изменений в рабочем каталоге

```

<p>Модуль</p>

```
shellCommand
    ├── .module
    │      ├── Tools
    │      └── PathFundamentals
    ├── module.test
    │        ├── one.will.yml
    │        └── two.will.yml
    │
    └── .will.yml       

```

</details>

При роботі з окремими `will-файлами` утиліта додатково виводить інформацію, про те, які файли зчитано. Перевірте список файлів в директорії `module.test`:  

<details>
  <summary><u>Вивід команди <code>will .each module.test .shell ls</code></u></summary>

```
[user@user ~]$ will .each module.test .shell ls
...
Module at /path_to_file/module.test/one.will.yml
 . Read : /path_to_file/module.test/one.will.yml
 . Read 1 will-files in 0.344s

 > ls
one.will.yml
two.will.yml

Module at /path_to_file/module.test/two.will.yml
 . Read : /path_to_file/module.test/two.will.yml
 . Read 1 will-files in 0.265s

 > ls
one.will.yml
two.will.yml


```

<p>Модуль</p>

```
shellCommand
    ├── .module
    │      ├── Tools
    │      └── PathFundamentals
    ├── module.test
    │        ├── one.will.yml
    │        └── two.will.yml
    │
    └── .will.yml       

```

</details>

### Підсумок  
- Команда `.shell` має переваги над побудовою збірок з кроками `predefined.shell` в комбінації з командою `.each` - полегшує роботу з іменованими `will-файлами` та підмодулями.

[Повернутись до змісту](../README.md#tutorials)