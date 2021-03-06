# Селектори із ґлобами

Як користуватись селекторами з ґлобами.

### Поняття селекторів в `вілфайлах`

Селектор - рядок-посилання на ресурс або декілька ресурсів в `вілфайлі`. Селектори мають просту і більш складну форму запису в залежності від поля секції. В попередніх туторіалах вже неявно використовувались селектори.  

Для множинного пошуку ресурсів в утиліті `willbe` використовуються селектори з ґлобами. [Ґлоб ](https://linuxhint.com/bash_globbing_tutorial/) - метод опису пошукового запиту з використанням метасимволiв (символів-джокерів), зокрема `*`, `?` та інших.  

### Приклад селекторів 

<details>
  <summary><u>Cекція <code>step</code></u></summary>

```yaml
step :

  export.out.debug :
    inherit : module.export  --> простий селектор
    export : path::out.debug*    --> селектор з ґлобом 
    tar : 0
    ...

```

</details>

Селектор `module.export` - простий селектор, що вказує на вбудований крок.  
Селектор `path::out.debug*` - селектор з ґлобом `*`.

### Селектори з ґлобами. Конфігурація модуля  

<details>
  <summary><u>Структура модуля</u></summary>

```
selectorWithGlob
        ├── fileDebug
        ├── fileRelease         
        └── .will.yml       

```

</details>

Для дослідження селекторів з ґлобами створіть приведену структуру модуля.  

<details>
  <summary><u>Код файла <code>.will.yml</code></u></summary>

```yaml
about :

  name : selectorWithGlob
  description : "Using selector with glob to choise path"
  version : 0.0.1

path :

  in : '.'
  out : 'out'
  fileToExport.debug :
    criterion :
      debug : 1
    path : 'fileDebug'

  fileToExport.release :
    criterion :
      debug : 0
    path : 'fileRelease'

step  :
  export.debug :
    inherit : module.export
    export : path::fileToExport.*
    tar : 0
    criterion :
      debug : 1

  export.release :
    inherit : module.export
    export : path::fileToExport.*
    tar : 0
    criterion :
      debug : 0

build :

  export.debug :
    criterion :
      export : 1
      debug : 1
    steps :
      - export.*

  export.release :
    criterion :
      export : 1
      debug : 0
    steps :
      - export.*

```

</details>

В файл `.will.yml` внесіть код.

Кожна із збірок `export.debug` i `export.release` обирає крок в секції `step` згідно критеріона `debug`. При побудові збірки `export.debug` в експорт-модуль буде поміщено файл `fileDebug`, а при виконанні збірки `export.release` - `fileRelease`.   

### Експортування модуля з окремими файлами  

В `вілфайлі` використовується ґлоб `*`, який означає - додати до назви будь-яку кількість довільних символів. Тому, в секції `step` вибір між кроками `export.debug` i `export.release` здійснюється порівнянням мапи критеріонів. Кроки `export.debug` i `export.release`, в свою чергу, обирають потрібний шлях в секції `path` за селектором `path::fileToExport.*`.   

<details>
  <summary><u>Вивід команди <code>will .export export.debug</code></u></summary>

```
[user@user ~]$ will .export export.debug
...
   Exporting export.debug
   + Write out will-file /path_to_file/out/selectorWithGlob.out.will.yml
   + Exported export.debug with 1 files in 1.370s
  Exported module::selectorWithGlob / build::export.debug in 1.370s

```

</details>

Побудуйте збірку `export.debug` виконавши команду `will .export export.debug`. 

<details>
  <summary><u>Структура модуля після експорту</u></summary>

```
selectorWithGlob
        ├── out
        │    └── selectorWithGlob.out.will.yml
        ├── fileDebug
        ├── fileRelease         
        └── .will.yml       

```

</details>

Утиліта експортувала файл з назвою `selectorWithGlob` в директорію `out`. Експортовано лише один файл, що свідчить про правильну побудову модуля.

<details>
  <summary><u>Ресурс <code>export.release</code> зі зміненим ґлобом</u></summary>

```yaml
  export.release :
    inherit : module.export
    export : path::fileToExport.[p-t]??????
    tar : 0
    criterion :
      debug : 0

```

</details>

Ґлоб `*` може бути замінений на `?` - один будь-який знак (при умові відомого числа знаків). А для того, щоб задати вибір з діапазону знаків використовуються квадратні дужки `[]`. Наприклад, змініть ресурс `export.release` в секції `step` до вказаної вище форми.

Згідно запису `[p-t]??????` утиліта спочатку має вибрати літеру `r` з діапазону літер `p-t`, а шість знаків `?` замінити на `elease`, відповідно. 

<details>
  <summary><u>Вивід команди <code>will .export export.release</code></u></summary>

```
[user@user ~]$ will .export export.release
...
  Exporting export.release
   + Write out will-file /path_to_file/out/selectorWithGlob.out.will.yml
   + Exported export.release with 1 files in 1.379s
  Exported module::selectorWithGlob / build::export.release in 1.379s

```

</details>

Видаліть директорію `out` (команда `rm -Rf out`) та введіть `will .export export.release`.

Експорт реліз-модуля пройшов успішно за 1.379s. При побудові утиліта співставила назви шляхів, та обрала ресурс `fileToExport.release`.

<details>
  <summary><u>Структура модуля після експорту</u></summary>

```
selectorWithGlob
        ├── out
        │    └── selectorWithGlob.out.will.yml
        ├── fileDebug
        ├── fileRelease         
        └── .will.yml       

```

</details>

В директорію `out` утиліта помістила згенерований `out-вілфайл` з назвою `selectorWithGlob.out.will.yml`.

### Підсумок  

- Селектор - рядок посилання на ресурс `вілфайла`. 
- Селектори використовують пошукові шаблони - ґлоби.
- Поєднання селекторів з ґлобами та критеріонів - потужний інструмент в налаштуванні побудови модуля. 
- Використання ґлобів, робить побудову модуля гнучкою.  

Побудовані збірки не виключають помилок, тож, [в наступному туторіалі](AssertionUsing.md) показано як зменшити ймовірність їх появи в `вілфайлі`.

[Повернутись до змісту](../README.md#tutorials)
