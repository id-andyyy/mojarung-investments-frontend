<script lang="ts">
  let login = '';
  let password = '';
  let error: string | null = null;
  let success: string | null = null;

  async function handleSubmit() {
    error = null;
    success = null;

    try {
      const response = await fetch('http://176.124.212.149:8000/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          username: login,
          password: password,
        }).toString(),
      });

      if (!response.ok) {
        const errorData = await response.json();
        error = errorData.detail?.[0]?.msg || 'Ошибка при входе';
        return;
      }

      const data = await response.json();
      // Сохраняем токен и тип токена в куках
      const expires = new Date(Date.now() + 86400 * 1000).toUTCString(); // Кука будет действительна 1 день
      document.cookie = `access_token=${data.access_token}; expires=${expires}; path=/; HttpOnly=false; Secure=false`; // HttpOnly и Secure могут быть изменены в зависимости от настроек бэкенда и https
      document.cookie = `token_type=${data.token_type}; expires=${expires}; path=/; HttpOnly=false; Secure=false`;
      
      success = 'Вход выполнен успешно!';
      // Очищаем форму
      login = '';
      password = '';
      // Можно перенаправить пользователя на другую страницу
      // window.location.href = '/dashboard';
    } catch (err) {
      error = 'Ошибка при подключении к серверу';
      console.error('Login error:', err);
    }
  }
</script>

<main class="login-container">
  <div class="login-card">
    <h1 class="login-title">Вход</h1>
    <form on:submit|preventDefault={handleSubmit}>
      <div class="form-group">
        <label for="login">Логин</label>
        <input type="text" id="login" bind:value={login} required />
      </div>

      <div class="form-group">
        <label for="password">Пароль</label>
        <input type="password" id="password" bind:value={password} required />
      </div>

      {#if error}
        <p class="error-message">{error}</p>
      {/if}

      {#if success}
        <p class="success-message">{success}</p>
      {/if}

      <button type="submit" class="submit-button">Войти</button>
    </form>
  </div>
</main>

<style>
  /* Import Google Fonts - Inter */
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');

  :global(body) {
    background-color: #1a1a1a; /* Consistent dark background */
    font-family: 'Inter', sans-serif; /* Consistent font */
  }

  .login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background-color: #1a1a1a; /* Ensure background is set even if not global */
    padding: 2rem;
  }

  .login-card {
    background: #242424; /* Darker card background */
    padding: 0.9rem;
    border-radius: 12px;
    border: 1px solid #333; /* Subtle border */
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    width: 100%;
    max-width: 450px;
  }

  .login-title {
    color: #ffdd2d; /* TBank yellow accent color */
    font-size: 2rem;
    margin-bottom: 0.5rem;
    text-align: center;
    font-weight: 700;
  }

  .form-group {
    margin-bottom: 1.5rem; /* Increased space between form groups */
  }

  .form-group label {
    display: block;
    color: #a0a0a0; /* Lighter grey for labels */
    font-size: 0.95rem;
    margin-bottom: 0.8rem; /* Increased space between label and input */
    font-weight: 500;
  }

  .form-group input[type="text"],
  .form-group input[type="email"],
  .form-group input[type="tel"],
  .form-group input[type="password"] {
    width: 100%;
    padding: 0.5rem 1rem;
    border: 1px solid #444; /* Darker border for inputs */
    border-radius: 8px;
    background-color: #1a1a1a; /* Even darker input background */
    color: #ffffff;
    font-size: 1rem;
    box-sizing: border-box;
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  .form-group input[type="text"]:focus,
  .form-group input[type="email"]:focus,
  .form-group input[type="tel"]:focus,
  .form-group input[type="password"]:focus {
    border-color: #ffdd2d; /* Yellow focus border */
    box-shadow: 0 0 0 3px rgba(255, 221, 45, 0.3); /* Yellow glow on focus */
    outline: none;
  }

  .error-message {
    color: #f44336;
    background-color: rgba(244, 67, 54, 0.1);
    border: 1px solid #f44336;
    padding: 0.75rem 1rem;
    border-radius: 8px;
    margin-bottom: 0.7rem;
    font-size: 0.9rem;
  }

  .success-message {
    color: #4caf50;
    background-color: rgba(76, 175, 80, 0.1);
    border: 1px solid #4caf50;
    padding: 0.75rem 1rem;
    border-radius: 8px;
    margin-bottom: 0.7rem;
    font-size: 0.9rem;
  }

  .submit-button {
    width: 50%; /* Сделать кнопку еще меньше */
    padding: 0.8rem;
    background-color: #ffdd2d;
    color: #1a1a1a;
    border: none;
    border-radius: 25px; /* Сделать кнопку более закругленной */
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.2s, transform 0.2s, border-radius 0.2s; /* Добавить transition для border-radius */
    margin-top: 1.5rem;
    display: block; /* Убедиться, что кнопка является блочным элементом */
    margin-left: auto; /* Центрирование */
    margin-right: auto; /* Центрирование */
    margin-bottom: 0.5rem;
  }

  .submit-button:hover {
    background-color: #ffe766; /* Lighter yellow on hover */
    transform: translateY(-2px);
  }

  .submit-button:active {
    transform: translateY(0);
  }

  /* Responsive adjustments */
  @media (max-width: 600px) {
    .login-card {
      padding: 0.6rem;
    }

    .login-title {
      font-size: 1.75rem;
    }
  }
</style> 