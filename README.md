![Art](https://i.postimg.cc/90JCTgqr/art.png)

![GitHub Created At](https://img.shields.io/github/created-at/id-andyyy/mojarung-investments-frontend?style=flat&color=FFDD2F)
![](https://tokei.rs/b1/github/id-andyyy/mojarung-investments-frontend?style=flat&category=code&color=black)
![Top Language](https://img.shields.io/github/languages/top/id-andyyy/mojarung-investments-frontend?style=flat&color=white)
![Vnedraid](https://img.shields.io/badge/hackathon-vnedraid-blue?color=FFDD2F)

# Mojarung Investments Frontend&nbsp;&#128184;

Фронтенд-проект для инвестиционной платформы "Mojarung Investments". Создан в рамках хакатона [Внедрейд](https://vnedreid.orionsoft.ru/) (1&nbsp;место&nbsp;&#129351;). Backend часть размещена в репозитории [mojarung-investments-backend](https://github.com/id-andyyy/mojarung-investments-backend).

## Функциональность

Проект имеет следующую структуру страниц, определенную в директории `src/routes/`:

- &#127968;&nbsp;`/` - **Главная страница**: Основная страница приложения. Содержит список свежих новостей с возможностью купить акцию в один клик
- &#128274;&nbsp;`/login` - **Страница входа**: Форма для аутентификации существующих пользователей
- &#128075;&nbsp;`/register` - **Страница регистрации**: Форма для создания новой учетной записи
- &#128240;&nbsp;`/news` - **Страница новостей**: Раздел для отображения новостей, связанных с инвестициями или рынком
- &#128100;&nbsp;`/profile` - **Страница профиля**: Личный кабинет пользователя, где он может просматривать и управлять своими данными


## &#128218;&nbsp;Технологии и инструменты

![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?style=for-the-badge&logo=css3&logoColor=white)
![SASS](https://img.shields.io/badge/SASS-hotpink.svg?style=for-the-badge&logo=SASS&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=white&color=yellow)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/vite-%23646CFF.svg?style=for-the-badge&logo=vite&logoColor=white)
![Svelte](https://img.shields.io/badge/svelte-%23f1413d.svg?style=for-the-badge&logo=svelte&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

- **Фреймворк**: SvelteKit
- **Язык программирования**: TypeScript
- **Сборщик проекта**: Vite
- **Стилизация**: Sass/SCSS
- **Форматирование кода**: Prettier
- **Основные библиотеки**:
    - `sveltekit-superforms`: Для удобной работы с формами в SvelteKit
    - `chart.js`: Для создания и отображения графиков и диаграмм
- **Адаптер сборки**: `@sveltejs/adapter-node` используется для сборки приложения в виде standalone Node.js сервера
- **Контейнеризация**: `Dockerfile` для упаковки приложения в Docker-контейнер

## &#128161;&nbsp;Принятые технические решения

- **Строгая типизация**: Использование TypeScript повышает надежность кода и улучшает опыт разработки за счет статической проверки типов
- **Contract-First подход к API**: Структура API определена в спецификации
- **Серверный рендеринг (SSR)**: Благодаря `@sveltejs/adapter-node` приложение генерирует страницы на сервере, что положительно сказывается на SEO и скорости первой загрузки
- **Развертывание в контейнере**: `Dockerfile` и скрипты `deploy.sh`/`upload.sh`


## &#128640;&nbsp;Как запустить сервис

1. Склонируйте репозиторий и перейдите в папку с проектом:
    ```bash
    git clone https://github.com/id-andyyy/mojarung-investments-frontend.git
    cd mojarung-investments-frontend 
    ```

2. Установите зависимости:
    ```bash
    npm install
    ```

3. Запустите сервер для разработки:
    ```bash
    npm run dev
    ```

4. Перейдите на http://localhost:5173

## &#128221;&nbsp;Структура проекта

```
.
├── src/
│   ├── lib/              # Библиотеки, компоненты и утилиты Svelte
│   ├── routes/
│   │   ├── login/        # Страница входа
│   │   ├── news/         # Страница новостей
│   │   ├── profile/      # Страница профиля пользователя
│   │   └── register/     # Страница регистрации
│   ├── app.html          # Шаблон HTML-страницы
│   ├── openapi.json      # Спецификация API
│   └── styles.css        # Глобальные стили
├── static/               # Статические файлы (изображения, шрифты)
├── .dockerignore         # Файлы, исключаемые из Docker-контейнера
├── .gitignore            # Файлы, игнорируемые Git
├── .prettierignore       # Файлы, исключаемые из форматирования Prettier
├── .prettierrc           # Конфигурация Prettier для форматирования кода
├── Dockerfile            # Инструкции для сборки Docker-образа
├── deploy.sh             # Скрипт для развертывания проекта
├── package.json          # Зависимости и скрипты проекта
├── svelte.config.js      # Конфигурация SvelteKit
├── tsconfig.json         # Конфигурация TypeScript
├── upload.sh             # Скрипт для загрузки сборки на сервер
└── vite.config.ts        # Конфигурация Vite
```

## Обратная связь

Буду признателен, если вы поставите звезду&nbsp;&#11088;. Если вы нашли баг или у вас есть предложения по улучшению, используйте раздел [Issues](https://github.com/id-andyyy/mojarung-investments-frontend/issues).

## Команда

Команда разработчиков [Mojarung](https://t.me/mojarung):

- [Андрей Обрезков](https://github.com/id-andyyy) (Fullstack developer)
- [Кирилл Вериялов](https://github.com/verikirill) (Backend developer)
- [Ярослав Ролдугин](https://github.com/Felicuss) (Backend developer)
- [Владислав Полицын](https://github.com/wasbyy) (Frontend developer)
- [Роман Соловьёв](https://github.com/Fors1ksx) (Frontend developer)

Read in [English&nbsp;&#127468;&#127463;](README-en.md)