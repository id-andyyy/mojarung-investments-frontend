<script lang="ts">
  import { onMount } from 'svelte';
  import { browser } from "$app/environment";

  // Интерфейсы для TypeScript
  interface User {
    id: number;
    username: string;
    email: string;
    invest_token?: string;
    telegram_id?: string;
    tickers?: string;
    is_active: boolean;
    created_at: string;
  }

  interface Balance {
    account_id: string;
    balance: number;
    currency: string;
  }

  interface Company {
    id: number;
    ticker: string;
    company_name: string;
    link: string;
    image_url?: string;
    description?: string;
    tags?: string;
  }

  // Состояние компонента
  let userData: User | null = null;
  let userBalance: Balance | null = null;
  let availableCompanies: Company[] = [];
  let userTickers: string[] = [];
  let isLoading = true;
  let error: string | null = null;

  // Формы
  let newPassword = '';
  let confirmPassword = '';
  let newInvestToken = '';
  let newTelegramId = '';
  let selectedCompanyId: number | null = null;

  // Состояние для обновлений
  let isUpdatingProfile = false;
  let isUpdatingToken = false;
  let isUpdatingTelegram = false;
  let isLoadingBalance = false;

  // Загрузка данных пользователя
  async function loadUserData() {
    if (!browser) return;
    
    try {
      const response = await fetch('/api/auth/me', {
        credentials: 'include'
      });

      if (response.status === 401) {
        error = "Необходима авторизация";
        window.location.href = '/login';
        return;
      }

      if (!response.ok) {
        throw new Error('Ошибка загрузки профиля');
      }

      userData = await response.json();
      console.log('Загружены данные пользователя:', userData);
    } catch (e: any) {
      error = e.message || 'Ошибка загрузки профиля';
      console.error('Ошибка загрузки пользователя:', e);
    }
  }

  // Загрузка баланса
  async function loadBalance() {
    if (!browser || !userData?.invest_token) return;
    
    isLoadingBalance = true;
    try {
      const response = await fetch('/api/invest/sandbox/balance', {
        credentials: 'include'
      });

      if (response.ok) {
        userBalance = await response.json();
        console.log('Загружен баланс:', userBalance);
      } else {
        console.log('Баланс недоступен (токен не настроен или ошибка API)');
      }
    } catch (e: any) {
      console.error('Ошибка загрузки баланса:', e);
    } finally {
      isLoadingBalance = false;
    }
  }

  // Загрузка доступных компаний
  async function loadAvailableCompanies() {
    if (!browser) return;

    try {
      const response = await fetch('/api/tradingview/companies?limit=200', {
        credentials: 'include'
      });

      if (response.ok) {
        availableCompanies = await response.json();
        console.log('Загружены компании:', availableCompanies.length);
      }
    } catch (e: any) {
      console.error('Ошибка загрузки компаний:', e);
    }
  }

  // Загрузка тикеров пользователя
  async function loadUserTickers() {
    if (!browser) return;

    try {
      const response = await fetch('/api/users/me/tickers', {
        credentials: 'include'
      });

      if (response.ok) {
        const data = await response.json();
        userTickers = data.tickers ? data.tickers.split(',').map((t: string) => t.trim()).filter((t: string) => t) : [];
        console.log('Загружены тикеры пользователя:', userTickers);
      }
    } catch (e: any) {
      console.error('Ошибка загрузки тикеров:', e);
    }
  }

  // Обновление токена инвестиций
  async function updateInvestToken() {
    if (!newInvestToken.trim()) return;

    isUpdatingToken = true;
    try {
      const response = await fetch('/api/auth/me/invest-token', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({ invest_token: newInvestToken })
      });

      if (response.ok) {
        userData = await response.json();
        newInvestToken = '';
        alert('Токен инвестиций обновлен успешно!');
        // Перезагружаем баланс с новым токеном
        await loadBalance();
      } else {
        const errorData = await response.json();
        alert(`Ошибка: ${errorData.detail || 'Не удалось обновить токен'}`);
      }
    } catch (e: any) {
      alert(`Ошибка: ${e.message}`);
    } finally {
      isUpdatingToken = false;
    }
  }

  // Обновление Telegram ID
  async function updateTelegramId() {
    if (!newTelegramId.trim()) return;

    isUpdatingTelegram = true;
    try {
      const response = await fetch('/api/auth/me/telegram-id', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({ telegram_id: newTelegramId })
      });

      if (response.ok) {
        userData = await response.json();
        newTelegramId = '';
        alert('Telegram ID обновлен успешно!');
      } else {
        const errorData = await response.json();
        alert(`Ошибка: ${errorData.detail || 'Не удалось обновить Telegram ID'}`);
      }
    } catch (e: any) {
      alert(`Ошибка: ${e.message}`);
    } finally {
      isUpdatingTelegram = false;
    }
  }

  // Добавление тикера
  async function addTicker() {
    if (!selectedCompanyId) return;

    try {
      const response = await fetch('/api/users/me/tickers', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({ company_id: selectedCompanyId })
      });

      if (response.ok) {
        await loadUserTickers();
        selectedCompanyId = null;
        alert('Тикер добавлен в избранное!');
      } else {
        const errorData = await response.json();
        alert(`Ошибка: ${errorData.detail || 'Не удалось добавить тикер'}`);
      }
    } catch (e: any) {
      alert(`Ошибка: ${e.message}`);
    }
  }

  // Удаление тикера
  async function removeTicker(ticker: string) {
    try {
      const response = await fetch(`/api/users/me/tickers/${ticker}`, {
        method: 'DELETE',
        credentials: 'include'
      });

      if (response.ok) {
        await loadUserTickers();
        alert('Тикер удален из избранного!');
      } else {
        const errorData = await response.json();
        alert(`Ошибка: ${errorData.detail || 'Не удалось удалить тикер'}`);
      }
    } catch (e: any) {
      alert(`Ошибка: ${e.message}`);
    }
  }

  // Инициализация при загрузке компонента
  onMount(async () => {
    await loadUserData();
    if (userData) {
      await Promise.all([
        loadBalance(),
        loadAvailableCompanies(),
        loadUserTickers()
      ]);
    }
    isLoading = false;
  });

  // Фильтрация компаний, которые еще не добавлены
  $: availableToAdd = availableCompanies.filter(company => 
    !userTickers.includes(company.ticker)
  );

  // Форматирование баланса
  function formatBalance(balance: number): string {
    return new Intl.NumberFormat('ru-RU').format(Math.round(balance));
  }

  // Получение информации о компании по тикеру
  function getCompanyInfo(ticker: string): Company | undefined {
    return availableCompanies.find(c => c.ticker === ticker);
  }
</script>

<main class="profile-container">
  <div class="profile-header">
    <h1>Профиль</h1>
    <a href="/" class="back-button">← Назад</a>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <div class="loading-spinner"></div>
      <p>Загрузка профиля...</p>
    </div>
  {:else if error}
    <div class="error-container">
      <p class="error">{error}</p>
      <a href="/login" class="login-link">Войти в систему</a>
    </div>
  {:else if userData}
    <div class="profile-content">
      <div class="profile-card">
        <!-- Информация о пользователе -->
        <div class="profile-info">
          <img src="/bik3.png" alt="Profile" class="profile-avatar" />
          <div class="user-details">
            <h2>{userData.username}</h2>
            <p class="email">{userData.email}</p>
            <p class="registration-date">
              Зарегистрирован: {new Date(userData.created_at).toLocaleDateString('ru-RU')}
            </p>
          </div>
        </div>

        <!-- Баланс -->
        <div class="balance-section">
          <h3>Баланс в песочнице</h3>
          {#if isLoadingBalance}
            <div class="balance-loading">Загрузка...</div>
          {:else if userBalance}
            <div class="balance-amount">
              {userBalance.currency} {formatBalance(userBalance.balance)}
            </div>
            <p class="balance-note">Счет: {userBalance.account_id}</p>
          {:else if userData.invest_token}
            <div class="balance-error">Не удалось загрузить баланс</div>
          {:else}
            <div class="balance-placeholder">
              Добавьте токен Tinkoff API для просмотра баланса
            </div>
          {/if}
        </div>

        <!-- Настройки API токена -->
        <div class="settings-section">
          <h3>API Токен Tinkoff</h3>
          <div class="token-section">
            <div class="current-token">
              <label>Текущий токен:</label>
              <div class="token-display">
                {#if userData.invest_token}
                  <span class="token-masked">
                    {userData.invest_token.substring(0, 8)}...{userData.invest_token.slice(-4)}
                  </span>
                  <span class="token-status active">Активен</span>
                {:else}
                  <span class="token-placeholder">Токен не установлен</span>
                  <span class="token-status inactive">Не активен</span>
                {/if}
              </div>
            </div>
            <div class="token-input-section">
              <input 
                type="text" 
                bind:value={newInvestToken} 
                placeholder="Введите новый токен Tinkoff API"
                class="token-input"
                disabled={isUpdatingToken}
              />
              <button 
                on:click={updateInvestToken} 
                class="update-button"
                disabled={!newInvestToken.trim() || isUpdatingToken}
              >
                {isUpdatingToken ? 'Обновление...' : 'Обновить токен'}
              </button>
            </div>
          </div>
        </div>

        <!-- Telegram ID -->
        <div class="settings-section">
          <h3>Telegram ID</h3>
          <div class="telegram-section">
            <div class="current-telegram">
              <label>Текущий ID:</label>
              <span class="telegram-display">
                {userData.telegram_id || 'Не указан'}
              </span>
            </div>
            <div class="telegram-input-section">
              <input 
                type="text" 
                bind:value={newTelegramId} 
                placeholder="Введите Telegram ID"
                class="telegram-input"
                disabled={isUpdatingTelegram}
              />
              <button 
                on:click={updateTelegramId} 
                class="update-button"
                disabled={!newTelegramId.trim() || isUpdatingTelegram}
              >
                {isUpdatingTelegram ? 'Обновление...' : 'Обновить ID'}
              </button>
            </div>
          </div>
        </div>

        <!-- Интересующие тикеры -->
        <div class="tickers-section">
          <h3>Интересующие тикеры</h3>
          
          <!-- Добавление нового тикера -->
          <div class="add-ticker-section">
            <select bind:value={selectedCompanyId} class="ticker-select">
              <option value={null}>Выберите компанию для добавления</option>
              {#each availableToAdd as company}
                <option value={company.id}>
                  {company.ticker} - {company.company_name}
                </option>
              {/each}
            </select>
            <button 
              on:click={addTicker} 
              class="add-ticker-button"
              disabled={!selectedCompanyId}
            >
              + Добавить
            </button>
          </div>

          <!-- Список выбранных тикеров -->
          <div class="tickers-list">
            {#if userTickers.length > 0}
              {#each userTickers as ticker}
                {@const companyInfo = getCompanyInfo(ticker)}
                <div class="ticker-item">
                  <div class="ticker-info">
                    <span class="ticker-symbol">{ticker}</span>
                    {#if companyInfo}
                      <span class="ticker-name">{companyInfo.company_name}</span>
                    {/if}
                  </div>
                  <button 
                    on:click={() => removeTicker(ticker)} 
                    class="remove-ticker-button"
                    title="Удалить тикер"
                  >
                    ×
                  </button>
                </div>
              {/each}
            {:else}
              <div class="empty-tickers">
                <p>Вы еще не добавили ни одного тикера</p>
                <p class="empty-hint">Добавьте интересующие вас компании для персонализированных новостей</p>
              </div>
            {/if}
          </div>
        </div>
      </div>
    </div>
  {/if}
</main>

<style>
  :global(body) {
    background-color: #1a1a1a;
    font-family: 'Inter', sans-serif;
  }

  .profile-container {
    max-width: 900px;
    margin: 2rem auto;
    padding: 0 1rem;
  }

  .profile-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(255, 221, 45, 0.2);
  }

  h1 {
    color: #ffdd2d;
    font-size: 2.2rem;
    margin: 0;
    font-weight: 700;
    text-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
  }

  .back-button {
    color: #a0a0a0;
    text-decoration: none;
    font-size: 1rem;
    transition: all 0.2s;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.05);
  }

  .back-button:hover {
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    transform: translateX(-2px);
  }

  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    text-align: center;
  }

  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(255, 221, 45, 0.3);
    border-top: 3px solid #ffdd2d;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 1rem;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .loading-container p {
    color: #a0a0a0;
    font-size: 1.1rem;
  }

  .error-container {
    text-align: center;
    padding: 4rem 2rem;
  }

  .error {
    color: #ff6b6b;
    font-size: 1.1rem;
    margin-bottom: 1rem;
  }

  .login-link {
    color: #ffdd2d;
    text-decoration: none;
    font-weight: 600;
    padding: 0.8rem 1.5rem;
    border: 1px solid #ffdd2d;
    border-radius: 6px;
    transition: all 0.2s;
    display: inline-block;
  }

  .login-link:hover {
    background: #ffdd2d;
    color: #1a1a1a;
  }

  .profile-card {
    background: linear-gradient(145deg, #242424, #2a2a2a);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 2rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  }

  .profile-info {
    display: flex;
    align-items: center;
    gap: 2rem;
    margin-bottom: 2.5rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .profile-avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: 3px solid #ffdd2d;
    box-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
    transition: transform 0.3s;
    object-fit: contain;
    background: #1a1a1a;
    padding: 10px;
  }

  .profile-avatar:hover {
    transform: scale(1.05);
  }

  .user-details h2 {
    color: #ffffff;
    margin: 0 0 0.5rem 0;
    font-size: 1.8rem;
    font-weight: 600;
  }

  .email {
    color: #a0a0a0;
    margin: 0 0 0.3rem 0;
    font-size: 1rem;
  }

  .registration-date {
    color: #666;
    margin: 0;
    font-size: 0.9rem;
  }

  .balance-section {
    margin-bottom: 2rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .balance-section h3 {
    color: #ffdd2d;
    margin-bottom: 1rem;
    font-size: 1.3rem;
  }

  .balance-amount {
    font-size: 2rem;
    font-weight: 700;
    color: #4caf50;
    margin-bottom: 0.5rem;
  }

  .balance-note {
    color: #a0a0a0;
    font-size: 0.9rem;
    margin: 0;
  }

  .balance-loading, .balance-error, .balance-placeholder {
    color: #a0a0a0;
    font-style: italic;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
  }

  .balance-error {
    color: #ff6b6b;
  }

  .settings-section {
    margin-bottom: 2rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .settings-section h3 {
    color: #ffdd2d;
    margin-bottom: 1.5rem;
    font-size: 1.3rem;
  }

  .token-section, .telegram-section {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .current-token, .current-telegram {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .current-token label, .current-telegram label {
    color: #a0a0a0;
    font-weight: 600;
    min-width: 120px;
  }

  .token-display {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .token-masked {
    font-family: monospace;
    color: #ffffff;
    background: rgba(255, 255, 255, 0.1);
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
  }

  .token-placeholder, .telegram-display {
    color: #666;
    font-style: italic;
  }

  .token-status {
    font-size: 0.8rem;
    padding: 0.2rem 0.6rem;
    border-radius: 12px;
    font-weight: 600;
  }

  .token-status.active {
    background: rgba(76, 175, 80, 0.2);
    color: #4caf50;
  }

  .token-status.inactive {
    background: rgba(255, 107, 107, 0.2);
    color: #ff6b6b;
  }

  .token-input-section, .telegram-input-section {
    display: flex;
    gap: 1rem;
    align-items: center;
  }

  .token-input, .telegram-input {
    flex: 1;
    padding: 0.8rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 8px;
    color: #ffffff;
    font-size: 0.9rem;
  }

  .token-input:focus, .telegram-input:focus {
    outline: none;
    border-color: #ffdd2d;
  }

  .update-button {
    padding: 0.8rem 1.5rem;
    background: #ffdd2d;
    color: #1a1a1a;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
  }

  .update-button:hover:not(:disabled) {
    background: #ffe766;
    transform: translateY(-1px);
  }

  .update-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .tickers-section {
    margin-bottom: 0;
  }

  .tickers-section h3 {
    color: #ffdd2d;
    margin-bottom: 1.5rem;
    font-size: 1.3rem;
  }

  .add-ticker-section {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    align-items: center;
  }

  .ticker-select {
    flex: 1;
    padding: 0.8rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 8px;
    color: #ffffff;
    font-size: 0.9rem;
  }

  .ticker-select:focus {
    outline: none;
    border-color: #ffdd2d;
  }

  .add-ticker-button {
    padding: 0.8rem 1.5rem;
    background: #4caf50;
    color: #ffffff;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
  }

  .add-ticker-button:hover:not(:disabled) {
    background: #45a049;
    transform: translateY(-1px);
  }

  .add-ticker-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .tickers-list {
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
  }

  .ticker-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    transition: all 0.2s;
  }

  .ticker-item:hover {
    background: rgba(255, 255, 255, 0.08);
    border-color: rgba(255, 221, 45, 0.3);
  }

  .ticker-info {
    display: flex;
    flex-direction: column;
    gap: 0.2rem;
  }

  .ticker-symbol {
    font-weight: 700;
    color: #ffdd2d;
    font-size: 1.1rem;
  }

  .ticker-name {
    color: #a0a0a0;
    font-size: 0.9rem;
  }

  .remove-ticker-button {
    width: 32px;
    height: 32px;
    background: rgba(255, 107, 107, 0.2);
    color: #ff6b6b;
    border: none;
    border-radius: 50%;
    font-size: 1.2rem;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .remove-ticker-button:hover {
    background: rgba(255, 107, 107, 0.4);
    transform: scale(1.1);
  }

  .empty-tickers {
    text-align: center;
    padding: 2rem;
    color: #a0a0a0;
  }

  .empty-tickers p {
    margin: 0 0 0.5rem 0;
  }

  .empty-hint {
    font-size: 0.9rem;
    color: #666;
  }

  /* Адаптивность */
  @media (max-width: 768px) {
    .profile-container {
      padding: 0 0.5rem;
    }

    .profile-info {
      flex-direction: column;
      text-align: center;
      gap: 1rem;
    }

    .profile-avatar {
      width: 100px;
      height: 100px;
    }

    .token-input-section, .telegram-input-section, .add-ticker-section {
      flex-direction: column;
    }

    .ticker-item {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.8rem;
    }

    .remove-ticker-button {
      align-self: flex-end;
    }
  }

  @media (max-width: 480px) {
    .profile-header {
      flex-direction: column;
      gap: 1rem;
      align-items: flex-start;
    }

    h1 {
      font-size: 1.8rem;
    }

    .current-token, .current-telegram {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }
  }
</style> 