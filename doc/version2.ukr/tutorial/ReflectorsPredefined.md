# Вбудовані рефлектори  

Використання вбудованих рефлекторів для розбиття на версію для відлагодження і для релізу. Побудова мультизбірок.

### Призначення вбудованих рефлекторів

Вбудовані рефлектори - це рефлектори з налаштованими файловими фільтрами для операцій побудови модуля відладки і реліз-модуля. Всього є три вбудованих рефлектора: `predefined.common`, `predefined.debug` i `predefined.release`.    

<details>
  <summary><u>Приклад використання вбудованого рефлектора</u></summary>

```yaml
reflector :

  use.files.reflector :
    inherit : predefined.common

```

</details>

Для використання вбудованих рефлекторів в ресурсі потрібно вказати поле `inherit` з обраним рефлектором. В прикладі, рефлектор `use.files.reflector` наслідує вбудований рефлектор `predefined.common`. Запис неповний, він доповнюється інформацією щодо директорій, файли яких будуть фільтруватись, критеріонами за необхідністю, додатковими фільтрами, тощо.  

### Властивості вбудованих рефлекторів

##### Вбудований рефлектор `predefined.common` 

Рефлектор для фільтрування допоміжних файлів проекта.   

<details>
  <summary><u>Налаштування рефлектора <code>predefined.common</code></u></summary>

```yaml
    src :
      maskAll :
        excludeAny :
          - !!js/regex '/(\W|^)node_modules(\W|$)/'
          - !!js/regex '/\.unique$/'
          - !!js/regex '/\.git$/'
          - !!js/regex '/\.svn$/'
          - !!js/regex '/\.hg$/'
          - !!js/regex '/\.DS_Store$/'
          - !!js/regex '/(^|\/)-/'

```

</details>


Вбудований рефлектор `predefined.common` виключає зі збірки файли, які мають розширення `.unique`, `,git`, `.svn`, `.hg`, `.DS_Store`, а також файли які починаються зі знаків `/` або `-`.  
Регулярний вираз `/(\W|^)node_modules(\W|$)/` фільтрує наступні комбінації у назвах файлів:   
- `спеціальний символ (несловесний) + node_modules`;  
- `спеціальний символ (несловесний) + node_modules + спеціальний символ (несловесний)`;  
- `node_modules + спеціальний символ (несловесний)`;  
- `node_modules`.    

##### Вбудований рефлектор `predefined.debug`

Рефлектор для фільтрації файлів, призначених для релізу проекта. 

Рефлектор має дві версії: 
-`predefined.debug.v1`, який використовує критеріон `debug : 1`;
- `predefined.debug.v2`. який використовує критеріон `debug : debug`.  

<details>
  <summary><u>Налаштування рефлектора <code>predefined.debug</code></u></summary>

```yaml
     src :
       maskAll :
         excludeAny :
           - !!js/regex '/\.release($|\.|\/)/i'
     criterion :
       debug : 1

```

</details>

Вбудований рефлектор `predefined.debug` виключає зі збірки файли, які мають розширення `.release`, в назві яких є слово `.release.` і директорії з закінченням `.release`. 

Для використання рефлектора потрібно встановити в збірці побудови критеріон `debug` зі значенням `1` або `debug`.  

##### Вбудований рефлектор `predefined.release`  

Рефлектор, який фільтрує файли підготовки до релізу - відладки, тестові, експериментальні. 

Рефлектор має дві версії: 
-`predefined.release.v1`, який використовує критеріон `debug : 0`;
- `predefined.release.v2`. який використовує критеріон `debug : release`.  

<details>
  <summary><u>Налаштування рефлектора <code>predefined.release</code></u></summary>

```yaml
     src :
       maskAll :
         excludeAny :
           - !!js/regex '/\.debug($|\.|\/)/i'
           - !!js/regex '/\.test($|\.|\/)/i'
           - !!js/regex '/\.experiment($|\.|\/)/i'
     criterion :
       debug : 0

```

</details>


Вбудований рефлектор `predefined.release` виключає зі збірки файли:
- які мають розширення `.debug`, `.test`, `.experiment`;  
- в назві яких є слово `.debug.`, `.test.`, `.experiment.`;  
- директорії з закінченням `.debug`, `.test`, `.experiment`.   

Для використання рефлектора потрібно встановити в збірці побудови критеріон `debug` зі значенням `0` або `release`.  

### Дослідження вбудованих рефлекторів. Мультизбірка

##### Конфігурація

Для дослідження вбудованих критеріонів потрібно створити таку структуру, при якій кожен вбудований рефлектор буде фільтрувати визначені файли.   

<details>
  <summary><u>Структура модуля</u></summary>

```
predefinedReflectors
        ├── proto
        │     ├── files.debug
        │     │     ├── debug.DS_Store
        │     │     └── debug.js
        │     ├── files.release
        │     │     └── release.test
        │     ├── node_modules              #  directory    
        │     ├── other
        │     │     └── other.experiment
        │     ├── -files.yml
        │     └── one.release.file.yml
        │
        └── .will.yml       

```

</details>

Створіть приведену вище конфігурацію в директорії `predefinedReflectors`.

##### Мультизбірка  

Мультизбірка - особлива збірка побудови, в сценарій якої вносяться інші збірки секції `build` та кроки користувача. Використання мультизбірок полегшує створення комплексних сценаріїв побудови.      

<details>
  <summary><u>Код файла <code>.will.yml</code></u></summary>

```yaml
about :

  name : predefinedReflectors
  description : "To use predefined reflectors"
  version : 0.0.1

path :

  out.debug :
    path : out.debug
    criterion :
      debug : 1

  out.release :
    path : out.release
    criterion :
      debug : 0

reflector :

  reflect.project:
    inherit: predefined.*
    src:
      filePath:
        proto : 1
    dst:
      filePath: path::out.*=1
    criterion :
      debug : [ 0,1 ]

  reflect.copy.common:
    inherit: predefined.common
    src:
      filePath:
        proto : 1
    dst:
      filePath: out.common

step :

  reflect.project :
    inherit : files.reflect
    reflector : reflect.project*=1
    criterion :
      debug : [ 0,1 ]

  reflect.copy.common :
    inherit : files.reflect
    reflector : reflect.copy.common

build :

  copy :
    criterion :
      debug : [ 0,1 ]
    steps :
      - reflect.project*=1

  copy.common :
    steps :
      - reflect.copy.common

  all.reflectors :
    criterion :
      default : 1
    steps :
      - build::copy.
      - build::copy.debug
      - build::copy.common

```

</details>

Запишіть в файл `.will.yml` приведений код. 

Для використання рефлекторів `predefined.debug` i `predefined.release` використана збірка з [розгортанням критеріонів](WillFileMinimization.md) під назвою `copy`, а для рефлектора `predefined.common` - збірка `copy.common` з простими селекторами.    

Також, побудована мультизбірка `all.reflectors`, яка виконується за замовчуванням. Для побудови мультизбірки використовуються селектори, які посилаються на ресурси секції `build`, наприклад, `build::copy`.  

##### Побудова модуля

<details>
  <summary><u>Вивід команди <code>will .build</code></u></summary>

```
[user@user ~]$ will .build
...
  Building module::predefinedReflectors / build::all.reflectors
   + reflect.project. reflected 4 files /path_to_file/ : out.release <- proto in 1.548s
   + reflect.project.debug reflected 5 files /path_to_file/ : out.debug <- proto in 1.219s
   + reflect.copy.common reflected 8 files /path_to_file/ : out.common <- proto in 0.918s
  Built module::predefinedReflectors / build::all.reflectors in 3.967s

```

</details>

Виконайте побудову (фраза `will .build`).

<details>
  <summary><u>Структура модуля після побудови</u></summary>

```
predefinedReflectors
        ├── out.common
        │     ├── ... (look at the table)
        ├── out.debug
        │     ├── ... (look at the table)
        ├── out.release
        │     ├── ... (look at the table)
        ├── proto
        │     ├── ... (start configuration)
        │
        └── .will.yml       

```

</details>

Прогляньте створені пакетом директорії `out.common`, `out.debug` i `out.release`. Порівняйте вміст з даними в таблиці.

| Директорія    | Вбудований рефлектор | Файли в директорії після побудови |
|---------------|----------------------|-----------------------------------|
| `out.common`  | `predefined.common`  | Директорія `files.debug` з файлом `debug.js`; директорія `files.release` з файлом `release.test`; директорія `other` з файлом `other.experiment.js`; файл `one.release.file.yml` |
| `out.debug`   | `predefined.debug`   | Директорія `files.debug` з файлом `debug.js`; директорія `other` з файлом `other.experiment.js`        |
| `out.release` | `predefined.release` | Директорія `files.release`; директорія `other`; файл `one.release.file.yml` |

По результатам копіювання очевидно, що вбудовані рефлектори `predefined.debug` i `predefined.release` використовують попередню фільтрацію файлів з допомогою рефлектора `predefined.common`. Адже, після побудови в директоріях  `out.debug` і `out.release` відсутні файли, які фільтруються рефлектором `predefined.common`.

### Підсумок  

- Вбудовані рефлектори мають налаштовані фільтри для побудови модуля.
- Вбудований рефлектор `predefined.common` використовується для фільтрації допоміжних файлів проекту (розширення `.git`, `.svn` та інші).  
- Рефлектор `predefined.debug` - виключає файли призначені для релізу, а `predefined.release` - файли відладки, тестові, експериментальні.
- Для використання рефлектора `predefined.debug` в збірці необхідно встановити критеріон `debug : 1` або `debug : 'debug'`, а для `predefined.release` - `debug : 0` або `debug : 'release'`.
- Вбудовані рефлектори `predefined.debug` i `predefined.release` здійснюють попередню фільтрацію файлів з допомогою рефлектора `predefined.common`.

[Повернутись до змісту](../README.md#tutorials)
