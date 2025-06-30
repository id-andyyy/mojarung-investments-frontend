![Art](https://i.postimg.cc/90JCTgqr/art.png)

![GitHub Created At](https://img.shields.io/github/created-at/id-andyyy/mojarung-investments-frontend?style=flat&color=FFDD2F)
![](https://tokei.rs/b1/github/id-andyyy/mojarung-investments-frontend?style=flat&category=code&color=black)
![Top Language](https://img.shields.io/github/languages/top/id-andyyy/mojarung-investments-frontend?style=flat&color=white)
![Vnedraid](https://img.shields.io/badge/hackathon-vnedraid-blue?color=FFDD2F)

# Mojarung Investments Frontend&nbsp;&#128184;

A frontend project for the "Mojarung Investments" investment platform. Created as part of the [Vnedreid](https://vnedreid.orionsoft.ru/) hackathon (1st place&nbsp;&#129351;). The backend part is located in the [mojarung-investments-backend](https://github.com/id-andyyy/mojarung-investments-backend) repository.

## Functionality

The project has the following page structure, defined in the `src/routes/` directory:

- &#127968;&nbsp;`/` - **Home Page**: The main page of the application. Contains a list of recent news with the ability to buy a stock in one click.
- &#128274;&nbsp;`/login` - **Login Page**: A form for authenticating existing users.
- &#128075;&nbsp;`/register` - **Registration Page**: A form for creating a new account.
- &#128240;&nbsp;`/news` - **News Page**: A section for displaying news related to investments or the market.
- &#128100;&nbsp;`/profile` - **Profile Page**: The user's personal account where they can view and manage their data.

## &#128218;&nbsp;Technologies and Tools

![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?style=for-the-badge&logo=css3&logoColor=white)
![SASS](https://img.shields.io/badge/SASS-hotpink.svg?style=for-the-badge&logo=SASS&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=white&color=yellow)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/vite-%23646CFF.svg?style=for-the-badge&logo=vite&logoColor=white)
![Svelte](https://img.shields.io/badge/svelte-%23f1413d.svg?style=for-the-badge&logo=svelte&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

- **Framework**: SvelteKit
- **Programming Language**: TypeScript
- **Project Bundler**: Vite
- **Styling**: Sass/SCSS
- **Code Formatting**: Prettier
- **Main Libraries**:
    - `sveltekit-superforms`: For convenient work with forms in SvelteKit.
    - `chart.js`: For creating and displaying charts and diagrams.
- **Build Adapter**: `@sveltejs/adapter-node` is used to build the application as a standalone Node.js server.
- **Containerization**: `Dockerfile` for packaging the application into a Docker container.

## &#128161;&nbsp;Technical Decisions

- **Strict Typing**: Using TypeScript increases code reliability and improves the development experience through static type checking.
- **Contract-First API Approach**: The API structure is defined in the specification.
- **Server-Side Rendering (SSR)**: Thanks to `@sveltejs/adapter-node`, the application generates pages on the server, which has a positive effect on SEO and initial load speed.
- **Containerized Deployment**: `Dockerfile` and `deploy.sh`/`upload.sh` scripts for deployment.


## &#128640;&nbsp;How to run the service

1.  Clone the repository and go to the project folder:
    ```bash
    git clone https://github.com/id-andyyy/mojarung-investments-frontend.git
    cd mojarung-investments-frontend
    ```

2.  Install dependencies:
    ```bash
    npm install
    ```

3.  Start the development server:
    ```bash
    npm run dev
    ```

4.  Go to http://localhost:5173

## &#128221;&nbsp;Project Structure

```
.
├── src/
│   ├── lib/              # Svelte libraries, components, and utilities
│   ├── routes/
│   │   ├── login/        # Login page
│   │   ├── news/         # News page
│   │   ├── profile/      # User profile page
│   │   └── register/     # Registration page
│   ├── app.html          # HTML page template
│   ├── openapi.json      # API specification
│   └── styles.css        # Global styles
├── static/               # Static files (images, fonts)
├── .dockerignore         # Files excluded from the Docker container
├── .gitignore            # Files ignored by Git
├── .prettierignore       # Files excluded from Prettier formatting
├── .prettierrc           # Prettier configuration for code formatting
├── Dockerfile            # Instructions for building the Docker image
├── deploy.sh             # Script for deploying the project
├── package.json          # Project dependencies and scripts
├── svelte.config.js      # SvelteKit configuration
├── tsconfig.json         # TypeScript configuration
├── upload.sh             # Script for uploading the build to the server
└── vite.config.ts        # Vite configuration
```

## Feedback

I would appreciate it if you give it a star&nbsp;&#11088;. If you find a bug or have suggestions for improvement, please use the [Issues](https://github.com/id-andyyy/mojarung-investments-frontend/issues) section.

## Team

The [Mojarung](https://t.me/mojarung) development team:

- [Andrey Obrezkov](https://github.com/id-andyyy) (Fullstack developer)
- [Kirill Veriyalov](https://github.com/verikirill) (Backend developer)
- [Yaroslav Roldugin](https://github.com/Felicuss) (Backend developer)
- [Vladislav Politsyn](https://github.com/wasbyy) (Frontend developer)
- [Roman Solovyov](https://github.com/Fors1ksx) (Frontend developer)

Читать на [русском&nbsp;&#127479;&#127482;](README.md)
