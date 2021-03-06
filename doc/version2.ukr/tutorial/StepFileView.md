# Вбудований крок <code>file.view</code>

Використання вбудованого кроку <code>file.view</code> для перегляду файлів.

В процесі побудови деяких модулів виникає необхідність відкрити окремі файли для перегляду або редагування. Для автоматизації цієї процедури в утиліті є вбудований крок `file.view`, котрий здійснює запуск файлів засобами операційної системи і сторонніх програм.  

### Конфігурація

<details>
  <summary><u>Структура модуля</u></summary>

```
viewStep
    ├── file
    │     ├── hello.html
    │     └── htllo.txt
    └── .will.yml

```

</details>

Для дослідження вбудованого кроку `file.view` створіть структуру файлів як приведено вище.  

<details>
  <summary><u>Код файла <code>.will.yml</code></u></summary>

```yaml
about :

  name : viewStep
  description : "To use file.view step"
  version : 0.0.1

path :
  in : '.'
  html : './file/hello.html'
  txt : './file/hello.txt'
  uri : 'https://www.google.com/'

step :

  view.uri :
    inherit : file.view
    filePath : path::uri
    delay : 12000

  view.html :
    inherit : file.view
    filePath : path::html
    delay : 8000

  view.txt :
    inherit : file.view
    filePath : path::txt
    delay : 1000  

build :

  open.view :
    criterion :
      default : 1
    steps :
      - step::view.uri
      - step::view.html
      - step::view.txt

```

</details>

Помістіть приведений вище код в файл `.will.yml`.

`Вілфайл` містить одну збірку `open.view`. В сценарії збірки по черзі виконується запуск перегляду URI-посилання та файлів модуля.

Для виклику кроку перегляду файлів в полі `inherit` вказується `file.view`, в полі `filePath` - шлях до файла чи посилання, в полі `delay` - затримка до запуску (в мс). 

<details>
  <summary><u>Код <code>hello.html</code> i <code>hello.txt</code></u></summary>

```html
<html>
<header>
  <title>Test page</title>
</header>
<body>
  <h1>Hello, world!</h1>
</body>
</html>

```

</details>

Внесіть в файли `hello.html` i `hello.txt` приведений код.

Файли `hello.html` i `hello.txt` мають різні розширення для того, щоб утиліта викликала програми для перегляду веб-сторінок і текстовий редактор (якщо в налаштуваннях операційної системи ці файли відкривають різні програми). Крок `view.urі` показує, що крім файлів утиліта може відкрити URI-посилання.   

### Побудова модуля  

<details>
  <summary><u>Вивід команди <code>will .build</code></u></summary>

```
[user@user ~]$ will .build
...
  Building module::viewStep / build::open.view
  Built module::viewStep / build::open.view in 0.280s

View path::txt
View path::html
View path::urі

```

</details>

Запустіть побудову модуля (`will .build`).

Згідно виводу було відкрито два файли і посилання в послідовності затримок в кроках. Вивід в програмах приведено нижче:  

<details>
  <summary><u>Вивід текстового редактора</u></summary>

![txt.view.png](../../images/txt.view.png)

</details>

Файл з розширенням `.txt` було відкрито в текстовому редакторі, що встановлений за замовчуванням в операційній системі.  

<details>
  <summary><u>Вивід браузера. HTML-файл</u></summary>

![html.view.png](../../images/html.view.png)

</details>

Для відкриття файлів з розширенням `.html` в системі використовується браузер. Тому в вікні браузера відображено заголовок "Hello, world!".

<details>
  <summary><u>Вивід браузера. URI-посилання</u></summary>

![html.view.png](../../images/url.view.png)

</details>

Після затримки в 4 секунди браузер також відкрив URI-посилання.

### Підсумок    

- Вбудований крок `file.view` для перегляду файлів використовує програми, що встановлені за замовчуванням.
- Вбудований крок `file.view` дозволяє відкривати файли і посилання.
- Затримкою, визначеною в кроці, формується послідовність запуску файлів.

[Повернутись до змісту](../README.md#tutorials)
