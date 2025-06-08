<script lang="ts">
	import { onMount } from "svelte";
	import { browser } from "$app/environment";
	import { goto } from "$app/navigation";

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
	let newPassword = "";
	let confirmPassword = "";
	let newInvestToken = "";
	let newTelegramId = "";
	let selectedCompanyId: number | null = null;

<<<<<<< HEAD
  // Состояние для красивого выбора тикеров
  let searchTerm = '';
  let showCompanyDropdown = false;
  let isSearchFocused = false;

  // Состояние для уведомлений
  let notifications: Array<{id: number, type: 'success' | 'error', message: string}> = [];
  let notificationId = 0;

  // Состояние для обновлений
  let isUpdatingProfile = false;
  let isUpdatingToken = false;
  let isUpdatingTelegram = false;
  let isLoadingBalance = false;
=======
	// Состояние для обновлений
	let isUpdatingProfile = false;
	let isUpdatingToken = false;
	let isUpdatingTelegram = false;
	let isLoadingBalance = false;
>>>>>>> 35ee2eae97cb3ce5893600363e5245973411ff15

	// --- НОВАЯ ЛОГИКА АУТЕНТИФИКАЦИИ ---

	function getAuthHeaders(): Record<string, string> {
		if (!browser) return {};
		const token = localStorage.getItem("access_token");
		if (!token) {
			goto("/login");
			return {};
		}
		return {
			Authorization: `Bearer ${token}`,
			"Content-Type": "application/json"
		};
	}

	async function fetchWithAuth(url: string, options: RequestInit = {}) {
		const headers = getAuthHeaders();
		// If headers are empty, it means goto was called, so we shouldn't proceed.
		if (Object.keys(headers).length === 0 && browser) {
			// Return a promise that never resolves, as we are navigating away.
			return new Promise<Response>(() => {});
		}

		const response = await fetch("http://176.124.212.149:8000" + url, {
			...options,
			headers: {
				...headers,
				...options.headers
			}
		});

		if (response.status === 401) {
			if (browser) {
				localStorage.removeItem("access_token");
			}
			goto("/login");
			// Return a promise that never resolves, as we are navigating away.
			return new Promise<Response>(() => {});
		}
		return response;
	}

	// --- ОБНОВЛЕННЫЕ ФУНКЦИИ ---

	// Загрузка данных пользователя
	async function loadUserData() {
		try {
			const response = await fetchWithAuth("/api/auth/me");
			if (!response.ok) {
				throw new Error("Ошибка загрузки профиля");
			}
			userData = await response.json();
			console.log("Загружены данные пользователя:", userData);
		} catch (e: any) {
			error = e.message || "Ошибка загрузки профиля";
			console.error("Ошибка загрузки пользователя:", e);
		}
	}

	// Загрузка баланса
	async function loadBalance() {
		if (!userData?.invest_token) return;

		isLoadingBalance = true;
		try {
			const response = await fetchWithAuth("/api/invest/sandbox/balance");

			if (response.ok) {
				userBalance = await response.json();
				console.log("Загружен баланс:", userBalance);
			} else {
				console.log("Баланс недоступен (токен не настроен или ошибка API)");
			}
		} catch (e: any) {
			console.error("Ошибка загрузки баланса:", e);
		} finally {
			isLoadingBalance = false;
		}
	}

	// Загрузка доступных компаний
	async function loadAvailableCompanies() {
		try {
			const response = await fetchWithAuth("/api/tradingview/companies?limit=200");

			if (response.ok) {
				availableCompanies = await response.json();
				console.log("Загружены компании:", availableCompanies.length);
			}
		} catch (e: any) {
			console.error("Ошибка загрузки компаний:", e);
		}
	}

	// Загрузка тикеров пользователя
	async function loadUserTickers() {
		try {
			const response = await fetchWithAuth("/api/users/me/tickers");

			if (response.ok) {
				const data = await response.json();
				userTickers = data.tickers
					? data.tickers
							.split(",")
							.map((t: string) => t.trim())
							.filter((t: string) => t)
					: [];
				console.log("Загружены тикеры пользователя:", userTickers);
			}
		} catch (e: any) {
			console.error("Ошибка загрузки тикеров:", e);
		}
	}

<<<<<<< HEAD
      if (response.ok) {
        userData = await response.json();
        newInvestToken = '';
        showNotification('success', 'Токен инвестиций обновлен успешно!');
        // Перезагружаем баланс с новым токеном
        await loadBalance();
      } else {
        const errorData = await response.json();
        showNotification('error', `Ошибка: ${errorData.detail || 'Не удалось обновить токен'}`);
      }
    } catch (e: any) {
      showNotification('error', `Ошибка: ${e.message}`);
    } finally {
      isUpdatingToken = false;
    }
  }
=======
	// Обновление токена инвестиций
	async function updateInvestToken() {
		if (!newInvestToken.trim()) return;
>>>>>>> 35ee2eae97cb3ce5893600363e5245973411ff15

		isUpdatingToken = true;
		try {
			const response = await fetchWithAuth("/api/auth/me/invest-token", {
				method: "PUT",
				body: JSON.stringify({ invest_token: newInvestToken })
			});

			if (response.ok) {
				userData = await response.json();
				newInvestToken = "";
				alert("Токен инвестиций обновлен успешно!");
				await loadBalance();
			} else {
				const errorData = await response.json();
				alert(`Ошибка: ${errorData.detail || "Не удалось обновить токен"}`);
			}
		} catch (e: any) {
			alert(`Ошибка: ${e.message}`);
		} finally {
			isUpdatingToken = false;
		}
	}

<<<<<<< HEAD
      if (response.ok) {
        userData = await response.json();
        newTelegramId = '';
        showNotification('success', 'Telegram ID обновлен успешно!');
      } else {
        const errorData = await response.json();
        showNotification('error', `Ошибка: ${errorData.detail || 'Не удалось обновить Telegram ID'}`);
      }
    } catch (e: any) {
      showNotification('error', `Ошибка: ${e.message}`);
    } finally {
      isUpdatingTelegram = false;
    }
  }

  // Добавление тикера
  async function addTicker(companyId?: number) {
    const targetCompanyId = companyId || selectedCompanyId;
    if (!targetCompanyId) return;

    try {
      const response = await fetch('/api/users/me/tickers', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({ company_id: targetCompanyId })
      });

      if (response.ok) {
        await loadUserTickers();
        selectedCompanyId = null;
        searchTerm = '';
        showCompanyDropdown = false;
        const company = availableCompanies.find(c => c.id === targetCompanyId);
        showNotification('success', `${company?.ticker || 'Тикер'} добавлен в избранное!`);
      } else {
        const errorData = await response.json();
        showNotification('error', `Ошибка: ${errorData.detail || 'Не удалось добавить тикер'}`);
      }
    } catch (e: any) {
      showNotification('error', `Ошибка: ${e.message}`);
    }
  }

  // Функции для управления поиском
  function handleSearchFocus() {
    isSearchFocused = true;
    showCompanyDropdown = true;
  }

  function handleSearchBlur() {
    // Задержка, чтобы клик по компании успел сработать
    setTimeout(() => {
      isSearchFocused = false;
      showCompanyDropdown = false;
    }, 200);
  }

  function selectCompany(company: Company) {
    addTicker(company.id);
  }

  function clearSearch() {
    searchTerm = '';
    showCompanyDropdown = false;
  }

  // Функции для уведомлений
  function showNotification(type: 'success' | 'error', message: string) {
    const id = ++notificationId;
    notifications = [...notifications, { id, type, message }];
    
    // Автоматически удаляем уведомление через 3 секунды
    setTimeout(() => {
      removeNotification(id);
    }, 3000);
  }

  function removeNotification(id: number) {
    notifications = notifications.filter(n => n.id !== id);
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
        showNotification('success', `${ticker} удален из избранного!`);
      } else {
        const errorData = await response.json();
        showNotification('error', `Ошибка: ${errorData.detail || 'Не удалось удалить тикер'}`);
      }
    } catch (e: any) {
      showNotification('error', `Ошибка: ${e.message}`);
    }
  }
=======
	// Обновление Telegram ID
	async function updateTelegramId() {
		if (!newTelegramId.trim()) return;

		isUpdatingTelegram = true;
		try {
			const response = await fetchWithAuth("/api/auth/me/telegram-id", {
				method: "PUT",
				body: JSON.stringify({ telegram_id: newTelegramId })
			});

			if (response.ok) {
				userData = await response.json();
				newTelegramId = "";
				alert("Telegram ID обновлен успешно!");
			} else {
				const errorData = await response.json();
				alert(`Ошибка: ${errorData.detail || "Не удалось обновить Telegram ID"}`);
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
			const response = await fetchWithAuth("/api/users/me/tickers", {
				method: "POST",
				body: JSON.stringify({ company_id: selectedCompanyId })
			});

			if (response.ok) {
				await loadUserTickers();
				selectedCompanyId = null;
				alert("Тикер добавлен в избранное!");
			} else {
				const errorData = await response.json();
				alert(`Ошибка: ${errorData.detail || "Не удалось добавить тикер"}`);
			}
		} catch (e: any) {
			alert(`Ошибка: ${e.message}`);
		}
	}
>>>>>>> 35ee2eae97cb3ce5893600363e5245973411ff15

	// Удаление тикера
	async function removeTicker(ticker: string) {
		try {
			const response = await fetchWithAuth(`/api/users/me/tickers/${ticker}`, {
				method: "DELETE"
			});

			if (response.ok) {
				await loadUserTickers();
				alert("Тикер удален из избранного!");
			} else {
				const errorData = await response.json();
				alert(`Ошибка: ${errorData.detail || "Не удалось удалить тикер"}`);
			}
		} catch (e: any) {
			alert(`Ошибка: ${e.message}`);
		}
	}

<<<<<<< HEAD
  // Фильтрация компаний по поиску
  $: filteredCompanies = availableToAdd.filter(company =>
    company.ticker.toLowerCase().includes(searchTerm.toLowerCase()) ||
    company.company_name.toLowerCase().includes(searchTerm.toLowerCase())
  ).slice(0, 8); // Показываем максимум 8 результатов

  // Форматирование баланса
  function formatBalance(balance: number): string {
    return new Intl.NumberFormat('ru-RU').format(Math.round(balance));
  }

  // Получение информации о компании по тикеру
  function getCompanyInfo(ticker: string): Company | undefined {
    return availableCompanies.find(c => c.ticker === ticker);
  }
=======
	// Инициализация при загрузке компонента
	onMount(async () => {
		if (!browser) return;
		isLoading = true;
		await loadUserData();
		if (userData) {
			await Promise.all([loadBalance(), loadAvailableCompanies(), loadUserTickers()]);
		}
		isLoading = false;
	});
>>>>>>> 35ee2eae97cb3ce5893600363e5245973411ff15
</script>

<main class="profile-container">
	{#if isLoading}
		<div class="loading">Загрузка профиля...</div>
	{:else if error}
		<div class="error-message">{error}</div>
	{:else if userData}
		<div class="profile-header">
			<h1>Профиль пользователя</h1>
			<p>Привет, <span class="username">{userData.username}</span>!</p>
		</div>

		<div class="profile-grid">
			<!-- Personal Data Section -->
			<div class="profile-card">
				<h2>Личные данные</h2>
				<p><strong>ID:</strong> {userData.id}</p>
				<p><strong>Email:</strong> {userData.email}</p>
				<p><strong>Активен:</strong> {userData.is_active ? "Да" : "Нет"}</p>
				<p>
					<strong>Дата регистрации:</strong>
					{new Date(userData.created_at).toLocaleDateString()}
				</p>
			</div>

			<!-- Balance Section -->
			<div class="profile-card">
				<h2>Баланс</h2>
				{#if isLoadingBalance}
					<p>Загрузка баланса...</p>
				{:else if userBalance}
					<p class="balance-amount">{userBalance.balance.toFixed(2)} {userBalance.currency}</p>
					<p class="account-id">Счет: {userBalance.account_id}</p>
				{:else}
					<p>Баланс недоступен. Проверьте ваш токен инвестиций.</p>
				{/if}
			</div>

			<!-- Invest Token Section -->
			<div class="profile-card">
				<h2>Токен инвестиций</h2>
				<p class="token-display">
					{userData.invest_token ? `****${userData.invest_token.slice(-4)}` : "Не указан"}
				</p>
				<div class="form-group">
					<input
						type="text"
						bind:value={newInvestToken}
						placeholder="Новый токен"
						disabled={isUpdatingToken}
					/>
					<button on:click={updateInvestToken} disabled={isUpdatingToken}>
						{isUpdatingToken ? "Обновление..." : "Обновить"}
					</button>
				</div>
			</div>

			<!-- Telegram ID Section -->
			<div class="profile-card">
				<h2>Telegram ID</h2>
				<p class="token-display">{userData.telegram_id || "Не указан"}</p>
				<div class="form-group">
					<input
						type="text"
						bind:value={newTelegramId}
						placeholder="Новый Telegram ID"
						disabled={isUpdatingTelegram}
					/>
					<button on:click={updateTelegramId} disabled={isUpdatingTelegram}>
						{isUpdatingTelegram ? "Обновление..." : "Обновить"}
					</button>
				</div>
			</div>

<<<<<<< HEAD
        <!-- Интересующие тикеры -->
        <div class="tickers-section">
          <h3>Интересующие тикеры</h3>
          
          <!-- Красивый поиск и добавление тикеров -->
          <div class="ticker-search-section">
            <div class="search-container">
              <div class="search-input-wrapper">
                <input 
                  type="text" 
                  bind:value={searchTerm}
                  on:focus={handleSearchFocus}
                  on:blur={handleSearchBlur}
                  placeholder="Поиск компаний по названию или тикеру..."
                  class="ticker-search-input"
                  class:focused={isSearchFocused}
                />
                <div class="search-icon">
                  {#if searchTerm}
                    <button on:click={clearSearch} class="clear-search">×</button>
                  {:else}
                    <span class="search-symbol">🔍</span>
                  {/if}
                </div>
              </div>
              
              <!-- Dropdown с результатами поиска -->
              {#if showCompanyDropdown && searchTerm.length > 0}
                <div class="companies-dropdown">
                  {#if filteredCompanies.length > 0}
                    {#each filteredCompanies as company}
                      <div 
                        class="company-option"
                        on:click={() => selectCompany(company)}
                        on:keydown={(e) => e.key === 'Enter' && selectCompany(company)}
                        tabindex="0"
                        role="button"
                      >
                        <div class="company-info">
                          <div class="company-ticker">{company.ticker}</div>
                          <div class="company-name">{company.company_name}</div>
                          {#if company.tags}
                            <div class="company-tags">
                              {#each company.tags.split(',').slice(0, 2) as tag}
                                <span class="company-tag">{tag.trim()}</span>
                              {/each}
                            </div>
                          {/if}
                        </div>
                        <div class="add-icon">+</div>
                      </div>
                    {/each}
                  {:else}
                    <div class="no-results">
                      <span class="no-results-icon">🔍</span>
                      <p>Компании не найдены</p>
                      <small>Попробуйте изменить поисковый запрос</small>
                    </div>
                  {/if}
                </div>
              {/if}
            </div>
          </div>

          <!-- Список выбранных тикеров -->
          <div class="selected-tickers">
            <h4 class="selected-tickers-title">
              Выбранные компании 
              <span class="tickers-count">({userTickers.length})</span>
            </h4>
            
            {#if userTickers.length > 0}
              <div class="tickers-grid">
                {#each userTickers as ticker}
                  {@const companyInfo = getCompanyInfo(ticker)}
                  <div class="ticker-card">
                    <div class="ticker-card-header">
                      <div class="ticker-badge">{ticker}</div>
                      <button 
                        on:click={() => removeTicker(ticker)} 
                        class="remove-ticker-btn"
                        title="Удалить {ticker}"
                      >
                        ×
                      </button>
                    </div>
                    
                    {#if companyInfo}
                      <div class="ticker-card-body">
                        <h5 class="company-title">{companyInfo.company_name}</h5>
                        {#if companyInfo.tags}
                          <div class="ticker-tags">
                            {#each companyInfo.tags.split(',').slice(0, 3) as tag}
                              <span class="ticker-tag">{tag.trim()}</span>
                            {/each}
                          </div>
                        {/if}
                      </div>
                    {:else}
                      <div class="ticker-card-body">
                        <h5 class="company-title">Информация недоступна</h5>
                      </div>
                    {/if}
                  </div>
                {/each}
              </div>
            {:else}
              <div class="empty-tickers">
                <div class="empty-icon">📈</div>
                <h4>Пока нет выбранных компаний</h4>
                <p>Начните поиск выше, чтобы добавить интересующие вас компании</p>
                <div class="empty-benefits">
                  <div class="benefit-item">
                    <span class="benefit-icon">🎯</span>
                    <span>Персонализированные новости</span>
                  </div>
                  <div class="benefit-item">
                    <span class="benefit-icon">📊</span>
                    <span>Отслеживание котировок</span>
                  </div>
                  <div class="benefit-item">
                    <span class="benefit-icon">🔔</span>
                    <span>Уведомления о важных событиях</span>
                  </div>
                </div>
              </div>
            {/if}
          </div>
        </div>
      </div>
    </div>
  {/if}

  <!-- Уведомления -->
  <div class="notifications-container">
    {#each notifications as notification (notification.id)}
      <div 
        class="notification notification-{notification.type}"
        on:click={() => removeNotification(notification.id)}
      >
        <div class="notification-icon">
          {#if notification.type === 'success'}
            ✓
          {:else}
            ✕
          {/if}
        </div>
        <div class="notification-message">
          {notification.message}
        </div>
        <button 
          class="notification-close"
          on:click={() => removeNotification(notification.id)}
        >
          ×
        </button>
      </div>
    {/each}
  </div>
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

  /* Новый красивый поиск тикеров */
  .ticker-search-section {
    margin-bottom: 2rem;
  }

  .search-container {
    position: relative;
    width: 100%;
  }

  .search-input-wrapper {
    position: relative;
    display: flex;
    align-items: center;
  }

  .ticker-search-input {
    width: 100%;
    padding: 1rem 3rem 1rem 1rem;
    background: linear-gradient(145deg, rgba(255, 255, 255, 0.03), rgba(255, 255, 255, 0.08));
    border: 2px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    color: #ffffff;
    font-size: 1rem;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
  }

  .ticker-search-input:focus,
  .ticker-search-input.focused {
    outline: none;
    border-color: #ffdd2d;
    background: linear-gradient(145deg, rgba(255, 221, 45, 0.05), rgba(255, 221, 45, 0.1));
    box-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
    transform: translateY(-1px);
  }

  .ticker-search-input::placeholder {
    color: rgba(255, 255, 255, 0.5);
  }

  .search-icon {
    position: absolute;
    right: 1rem;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .search-symbol {
    font-size: 1.2rem;
    color: rgba(255, 255, 255, 0.4);
  }

  .clear-search {
    background: rgba(255, 255, 255, 0.1);
    border: none;
    border-radius: 50%;
    width: 24px;
    height: 24px;
    color: #ffffff;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    transition: all 0.2s;
  }

  .clear-search:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.1);
  }

  /* Dropdown с результатами поиска */
  .companies-dropdown {
    position: absolute;
    top: calc(100% + 8px);
    left: 0;
    right: 0;
    background: linear-gradient(145deg, #2a2a2a, #363636);
    border: 1px solid rgba(255, 221, 45, 0.2);
    border-radius: 12px;
    overflow: hidden;
    z-index: 1000;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(20px);
    max-height: 400px;
    overflow-y: auto;
  }

  .company-option {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1rem;
    cursor: pointer;
    transition: all 0.2s;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  }

  .company-option:hover {
    background: rgba(255, 221, 45, 0.1);
    transform: translateX(4px);
  }

  .company-option:last-child {
    border-bottom: none;
  }

  .company-info {
    flex: 1;
  }

  .company-ticker {
    font-weight: 700;
    color: #ffdd2d;
    font-size: 1.1rem;
    margin-bottom: 0.2rem;
  }

  .company-name {
    color: #ffffff;
    font-size: 0.95rem;
    margin-bottom: 0.5rem;
    line-height: 1.3;
  }

  .company-tags {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }

  .company-tag {
    background: rgba(255, 221, 45, 0.15);
    color: #ffdd2d;
    padding: 0.2rem 0.6rem;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .add-icon {
    width: 32px;
    height: 32px;
    background: linear-gradient(145deg, #4caf50, #45a049);
    color: #ffffff;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.2rem;
    font-weight: bold;
    transition: all 0.2s;
  }

  .company-option:hover .add-icon {
    transform: scale(1.1) rotate(90deg);
    box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4);
  }

  .no-results {
    text-align: center;
    padding: 2rem;
    color: rgba(255, 255, 255, 0.6);
  }

  .no-results-icon {
    font-size: 2rem;
    margin-bottom: 0.5rem;
    display: block;
  }

  .no-results p {
    margin: 0 0 0.5rem 0;
    font-size: 1rem;
  }

  .no-results small {
    color: rgba(255, 255, 255, 0.4);
    font-size: 0.85rem;
  }

  /* Выбранные тикеры */
  .selected-tickers {
    margin-top: 2rem;
  }

  .selected-tickers-title {
    color: #ffffff;
    font-size: 1.2rem;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .tickers-count {
    background: rgba(255, 221, 45, 0.2);
    color: #ffdd2d;
    padding: 0.2rem 0.6rem;
    border-radius: 12px;
    font-size: 0.9rem;
    font-weight: 600;
  }

  .tickers-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1rem;
  }

  .ticker-card {
    background: linear-gradient(145deg, rgba(255, 255, 255, 0.03), rgba(255, 255, 255, 0.08));
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    overflow: hidden;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
  }

  .ticker-card:hover {
    transform: translateY(-2px);
    border-color: rgba(255, 221, 45, 0.3);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
  }

  .ticker-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1rem 0.5rem;
  }

  .ticker-badge {
    background: linear-gradient(135deg, #ffdd2d, #ffe766);
    color: #1a1a1a;
    padding: 0.4rem 0.8rem;
    border-radius: 20px;
    font-weight: 700;
    font-size: 0.9rem;
    letter-spacing: 0.5px;
  }

  .remove-ticker-btn {
    width: 28px;
    height: 28px;
    background: rgba(255, 107, 107, 0.15);
    color: #ff6b6b;
    border: none;
    border-radius: 50%;
    font-size: 1rem;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .remove-ticker-btn:hover {
    background: rgba(255, 107, 107, 0.3);
    transform: scale(1.1);
  }

  .ticker-card-body {
    padding: 0.5rem 1rem 1rem;
  }

  .company-title {
    color: #ffffff;
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 0.8rem 0;
    line-height: 1.3;
  }



  .ticker-tags {
    display: flex;
    gap: 0.4rem;
    flex-wrap: wrap;
  }

  .ticker-tag {
    background: rgba(255, 221, 45, 0.12);
    color: #ffdd2d;
    padding: 0.2rem 0.5rem;
    border-radius: 16px;
    font-size: 0.7rem;
    font-weight: 500;
    border: 1px solid rgba(255, 221, 45, 0.2);
  }

  .empty-tickers {
    text-align: center;
    padding: 3rem 2rem;
    background: linear-gradient(145deg, rgba(255, 255, 255, 0.02), rgba(255, 255, 255, 0.05));
    border: 2px dashed rgba(255, 221, 45, 0.2);
    border-radius: 12px;
    margin-top: 1rem;
  }

  .empty-icon {
    font-size: 3rem;
    margin-bottom: 1rem;
    display: block;
  }

  .empty-tickers h4 {
    color: #ffffff;
    margin: 0 0 0.5rem 0;
    font-size: 1.1rem;
  }

  .empty-tickers p {
    color: rgba(255, 255, 255, 0.6);
    margin: 0 0 1.5rem 0;
    font-size: 0.95rem;
  }

  .empty-benefits {
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
    margin-top: 1.5rem;
  }

  .benefit-item {
    display: flex;
    align-items: center;
    gap: 0.8rem;
    color: rgba(255, 255, 255, 0.7);
    font-size: 0.9rem;
  }

  .benefit-icon {
    font-size: 1.2rem;
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

    .token-input-section, .telegram-input-section {
      flex-direction: column;
    }

    .tickers-grid {
      grid-template-columns: 1fr;
    }

    .ticker-card-header {
      padding: 0.8rem 0.8rem 0.4rem;
    }

    .ticker-card-body {
      padding: 0.4rem 0.8rem 0.8rem;
    }

    .companies-dropdown {
      max-height: 300px;
    }

    .company-option {
      padding: 0.8rem;
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }

    .add-icon {
      align-self: flex-end;
    }

    .empty-benefits {
      gap: 0.6rem;
    }

    .benefit-item {
      font-size: 0.85rem;
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

  /* Стили уведомлений */
  .notifications-container {
    position: fixed;
    top: 2rem;
    right: 2rem;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
    pointer-events: none;
  }

  .notification {
    display: flex;
    align-items: center;
    gap: 0.8rem;
    padding: 1rem 1.2rem;
    border-radius: 12px;
    backdrop-filter: blur(20px);
    border: 1px solid;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    cursor: pointer;
    transition: all 0.3s ease;
    pointer-events: auto;
    min-width: 300px;
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  .notification-success {
    background: linear-gradient(145deg, rgba(76, 175, 80, 0.15), rgba(76, 175, 80, 0.25));
    border-color: rgba(76, 175, 80, 0.4);
    color: #4caf50;
  }

  .notification-error {
    background: linear-gradient(145deg, rgba(244, 67, 54, 0.15), rgba(244, 67, 54, 0.25));
    border-color: rgba(244, 67, 54, 0.4);
    color: #f44336;
  }

  .notification:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.4);
  }

  .notification-icon {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 0.9rem;
    flex-shrink: 0;
  }

  .notification-success .notification-icon {
    background: rgba(76, 175, 80, 0.3);
    color: #4caf50;
  }

  .notification-error .notification-icon {
    background: rgba(244, 67, 54, 0.3);
    color: #f44336;
  }

  .notification-message {
    flex: 1;
    color: #ffffff;
    font-size: 0.95rem;
    font-weight: 500;
  }

  .notification-close {
    background: none;
    border: none;
    color: rgba(255, 255, 255, 0.6);
    font-size: 1.2rem;
    font-weight: bold;
    cursor: pointer;
    padding: 0;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: all 0.2s;
    flex-shrink: 0;
  }

  .notification-close:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #ffffff;
  }

  /* Адаптивность для уведомлений */
  @media (max-width: 768px) {
    .notifications-container {
      top: 1rem;
      right: 1rem;
      left: 1rem;
    }

    .notification {
      min-width: unset;
    }
  }
</style> 
=======
			<!-- Tickers Section -->
			<div class="profile-card tickers-card">
				<h2>Избранные тикеры</h2>
				<div class="ticker-list">
					{#if userTickers.length > 0}
						{#each userTickers as ticker}
							<div class="ticker-item">
								<span>{ticker}</span>
								<button class="remove-ticker-btn" on:click={() => removeTicker(ticker)}>×</button>
							</div>
						{/each}
					{:else}
						<p>У вас пока нет избранных тикеров.</p>
					{/if}
				</div>
				<hr />
				<h3>Добавить тикер</h3>
				<div class="form-group">
					<select bind:value={selectedCompanyId}>
						<option value={null} disabled>Выберите компанию</option>
						{#each availableCompanies as company}
							<option value={company.id}>{company.ticker} - {company.company_name}</option>
						{/each}
					</select>
					<button on:click={addTicker} disabled={!selectedCompanyId}>Добавить</button>
				</div>
			</div>
		</div>
	{/if}
</main>

<style>
	.profile-container {
		max-width: 1200px;
		margin: 2rem auto;
		padding: 2rem;
		color: #e0e0e0;
	}

	.loading {
		text-align: center;
		font-size: 1.5rem;
		padding: 4rem;
	}

	.error-message {
		color: #f44336;
		background-color: rgba(244, 67, 54, 0.1);
		border: 1px solid #f44336;
		padding: 1rem;
		border-radius: 8px;
		text-align: center;
	}

	.profile-header {
		text-align: center;
		margin-bottom: 2rem;
	}

	.profile-header h1 {
		color: #ffdd2d;
		font-size: 2.5rem;
		margin-bottom: 0.5rem;
	}

	.profile-header .username {
		font-weight: 700;
		color: #ffdd2d;
	}

	.profile-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
		gap: 1.5rem;
	}

	.profile-card {
		background: #242424;
		padding: 1.5rem;
		border-radius: 12px;
		border: 1px solid #333;
		display: flex;
		flex-direction: column;
	}

	.profile-card h2 {
		color: #ffdd2d;
		font-size: 1.25rem;
		margin-bottom: 1rem;
		border-bottom: 1px solid #444;
		padding-bottom: 0.5rem;
	}

	.profile-card p {
		margin-bottom: 0.5rem;
		line-height: 1.6;
	}

	.token-display {
		font-family: monospace;
		background-color: #1a1a1a;
		padding: 0.5rem;
		border-radius: 4px;
		word-break: break-all;
		margin-bottom: 1rem;
	}

	.form-group {
		display: flex;
		gap: 0.5rem;
		margin-top: auto; /* Pushes form to the bottom */
	}

	.form-group input,
	.form-group select {
		flex-grow: 1;
		padding: 0.5rem;
		border: 1px solid #444;
		border-radius: 4px;
		background-color: #1a1a1a;
		color: #e0e0e0;
		font-size: 1rem;
	}

	.form-group button {
		padding: 0.5rem 1rem;
		border: none;
		border-radius: 4px;
		background-color: #ffdd2d;
		color: #1a1a1a;
		font-weight: 600;
		cursor: pointer;
		transition: background-color 0.2s;
	}

	.form-group button:disabled {
		background-color: #555;
		cursor: not-allowed;
	}

	.form-group button:hover:not(:disabled) {
		background-color: #ffe766;
	}

	.balance-amount {
		font-size: 2rem;
		font-weight: 700;
		color: #ffdd2d;
	}

	.account-id {
		font-size: 0.9rem;
		color: #a0a0a0;
	}

	.tickers-card {
		grid-column: span 1 / -1; /* Make this card span full width */
	}

	.ticker-list {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}

	.ticker-item {
		background-color: #333;
		padding: 0.5rem 1rem;
		border-radius: 20px;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.remove-ticker-btn {
		background: none;
		border: none;
		color: #a0a0a0;
		cursor: pointer;
		font-size: 1.2rem;
		padding: 0;
		line-height: 1;
	}
	.remove-ticker-btn:hover {
		color: #ffdd2d;
	}

	hr {
		border: none;
		border-top: 1px solid #444;
		margin: 1.5rem 0;
	}
</style>
>>>>>>> 35ee2eae97cb3ce5893600363e5245973411ff15
