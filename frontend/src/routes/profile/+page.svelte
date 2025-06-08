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
	let selectedCompanyId: number | undefined = undefined;

	// Состояние для красивого выбора тикеров
	let searchTerm = '';
	let showCompanyDropdown = false;
	let isSearchFocused = false;

	// Placeholder portfolio stocks
	let portfolioStocks = [
		{ ticker: 'GAZP', quantity: 0, value: 0 },
		{ ticker: 'ROSN', quantity: 0, value: 0 },
		{ ticker: 'TATN', quantity: 0, value: 0 },
		{ ticker: 'NLMK', quantity: 0, value: 0 },
	];

	// Состояние для уведомлений
	let notifications: Array<{id: number, type: 'success' | 'error', message: string}> = [];
	let notificationId = 0;

	// Состояние для обновлений
	let isUpdatingProfile = false;
	let isUpdatingToken = false;
	let isUpdatingTelegram = false;
	let isLoadingBalance = false;

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

	// Обновление токена инвестиций
	async function updateInvestToken() {
		if (!newInvestToken.trim()) return;

		isUpdatingToken = true;
		try {
			const response = await fetchWithAuth("/api/auth/me/invest-token", {
				method: "PUT",
				body: JSON.stringify({ invest_token: newInvestToken })
			});

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

	// Helper to get random quantity
	function getRandomQuantity(min: number, max: number): number {
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}

	// Добавление тикера
	async function addTicker(companyId?: number) {
		const targetCompanyId = companyId || selectedCompanyId;
		if (!targetCompanyId) return;

		try {
			const response = await fetchWithAuth('/api/users/me/tickers', {
				method: 'POST',
				body: JSON.stringify({ company_id: targetCompanyId })
			});

			if (response.ok) {
				await loadUserTickers();
				selectedCompanyId = undefined;
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
			const response = await fetchWithAuth(`/api/users/me/tickers/${ticker}`, {
				method: "DELETE"
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

	// Фильтрация компаний по поиску
	$: availableToAdd = availableCompanies.filter(company => 
		!userTickers.includes(company.ticker)
	);
	
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

	// Инициализация при загрузке компонента
	onMount(async () => {
		if (!browser) return;
		isLoading = true;
		await loadUserData();
		if (userData) {
			await Promise.all([loadBalance(), loadAvailableCompanies(), loadUserTickers()]);
		}
		
		// Populate random quantities and values for portfolioStocks
		portfolioStocks = portfolioStocks.map(stock => ({
			...stock,
			quantity: getRandomQuantity(5, 20),
			value: getRandomQuantity(500000, 15000000) // Random value for display
		}));

		isLoading = false;
	});
</script>

<main class="profile-container">
	<a href="/news" class="back-button">← Назад</a>
	{#if isLoading}
		<div class="loading">Загрузка профиля...</div>
	{:else if error}
		<div class="error-message">{error}</div>
	{:else if userData}
		<!-- Profile Section -->
		<div class="main-profile-block">
			<div class="profile-summary">
				<img src="/bik3.png" alt="User Avatar" class="profile-avatar-img" />
				<div class="user-details">
					<h1>{userData.username}</h1>
					<p>{userData.email}</p>
				</div>
			</div>

			<div class="balance-section">
				<div class="info-label">Баланс</div>
				{#if isLoadingBalance}
					<p class="loading-balance">Загрузка баланса...</p>
				{:else if userBalance}
					<div class="balance-amount">
						₽ {formatBalance(userBalance.balance)}
					</div>
				{:else}
					<p class="no-balance">Баланс недоступен. Проверьте ваш токен инвестиций.</p>
				{/if}
			</div>

			<div class="portfolio-section">
				<div class="info-label">Портфель</div>
				{#if portfolioStocks.length > 0}
					{#each portfolioStocks as stock}
						<div class="portfolio-item">
							<span class="ticker-name">{stock.ticker}</span>
							<span class="ticker-shares">{stock.quantity} шт.</span>
							<span class="ticker-value">₽ {formatBalance(stock.value)}</span>
						</div>
					{/each}
				{:else}
					<div class="empty-portfolio">
						<div class="empty-icon">📈</div>
						<h4>Пока нет компаний в портфеле</h4>
						<p>Добавьте интересующие вас компании в настройках ниже, чтобы увидеть их здесь.</p>
					</div>
				{/if}
			</div>
		</div>

		<!-- Settings Section -->
		<div class="settings-block">
			<h2>Настройки</h2>

			<div class="setting-item">
				<div class="setting-label">API Токен</div>
				<div class="setting-content api-token-display">
					<input type="text" value="{userData.invest_token ? '****' + userData.invest_token.slice(-4) : 'your-api-token-here'}" readonly class="settings-input" />
				</div>
				<div class="form-group update-token-group">
					<input
						type="text"
						bind:value={newInvestToken}
						placeholder="Введите новый API Токен"
						disabled={isUpdatingToken}
						class="settings-input"
					/>
					<button on:click={updateInvestToken} disabled={isUpdatingToken} class="settings-button">
						{isUpdatingToken ? "Обновление..." : "Обновить"}
					</button>
				</div>
			</div>

			<div class="setting-item">
				<div class="setting-label">Смена пароля</div>
				<div class="form-group password-change">
					<input
						type="password"
						bind:value={newPassword}
						placeholder="Новый пароль"
						class="settings-input"
					/>
					<input
						type="password"
						bind:value={confirmPassword}
						placeholder="Подтвердите пароль"
						class="settings-input"
					/>
					 <button on:click={/* Implement password change function */ null} class="settings-button" disabled={isUpdatingProfile}>
						{isUpdatingProfile ? "Обновление..." : "Сменить пароль"}
					</button>
				</div>
			</div>

			<div class="setting-item">
				<div class="setting-label">Интересующие теги</div>
				<div class="tags-input-wrapper">
					<input
						type="text"
						bind:value={searchTerm}
						on:focus={handleSearchFocus}
						on:blur={handleSearchBlur}
						placeholder="Добавить тег"
						class="settings-input tag-search-input"
					/>
					<button class="add-tag-button" on:click={() => addTicker(selectedCompanyId)}>
						+
					</button>
				</div>
				{#if showCompanyDropdown && searchTerm.length > 0}
					<div class="companies-dropdown settings-dropdown">
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
									</div>
								</div>
							{/each}
						{:else}
							<div class="no-results">
								<p>Компании не найдены</p>
							</div>
						{/if}
					</div>
				{/if}
				<div class="selected-tags-display">
					{#each userTickers as ticker}
						<div class="profile-tag">
							{ticker}
							<button on:click={() => removeTicker(ticker)} class="remove-tag-btn">×</button>
						</div>
					{/each}
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
		padding: 0;
		color: #e0e0e0;
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.loading,
	.error-message {
		padding: 4rem;
		margin: 2rem;
		border-radius: 12px;
	}

	.error-message {
		background-color: rgba(244, 67, 54, 0.1);
		border: 1px solid #f44336;
	}

	.profile-header {
		display: none; /* Hidden as per new design */
	}

	.back-button {
		color: #a0a0a0;
		text-decoration: none;
		font-size: 1rem;
		transition: all 0.2s;
		padding: 0.5rem 1rem;
		border-radius: 6px;
		background: rgba(255, 255, 255, 0.05);
		width: fit-content;
		margin: 0 0 0 auto; /* Align to right */
	}

	.back-button:hover {
		color: #ffdd2d;
		background: rgba(255, 221, 45, 0.1);
		transform: translateX(-2px);
	}

	.main-profile-block,
	.settings-block {
		background: #242424;
		padding: 2rem;
		border-radius: 12px;
		border: 1px solid #333;
		box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
	}

	.profile-summary {
		display: flex;
		align-items: center;
		gap: 1.5rem;
		margin-bottom: 2rem;
		padding-bottom: 1.5rem;
		border-bottom: 1px solid #333;
	}

	.profile-avatar-img {
		width: 80px;
		height: 80px;
		border-radius: 50%;
		border: 2px solid #ffdd2d;
		flex-shrink: 0;
    background-size: cover; 
    padding: 5px;
	}

	.user-details h1 {
		font-size: 1.8rem;
		color: #ffffff;
		margin-bottom: 0.2rem;
	}

	.user-details p {
		color: #a0a0a0;
		font-size: 1rem;
	}

	.balance-section {
		margin-bottom: 2rem;
		padding-bottom: 1.5rem;
		border-bottom: 1px solid #333;
	}

	.info-label {
		color: #a0a0a0;
		font-size: 0.9rem;
		margin-bottom: 0.5rem;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.balance-amount {
		font-size: 2.5rem;
		font-weight: 700;
		color: #ffdd2d;
	}

	.loading-balance,
	.no-balance {
		color: #a0a0a0;
		font-style: italic;
	}

	.portfolio-section {
		/* No bottom border for the last section */
	}

	.portfolio-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.8rem 0;
		border-bottom: 1px solid rgba(255, 255, 255, 0.05);
	}

	.portfolio-item:last-child {
		border-bottom: none;
	}

	.ticker-name {
		font-weight: 600;
		color: #ffffff;
		flex-basis: 30%;
	}

	.ticker-shares {
		color: #a0a0a0;
		flex-basis: 30%;
		text-align: center;
	}

	.ticker-value {
		color: #66bb6a; /* Green color for positive value */
		font-weight: 600;
		flex-basis: 40%;
		text-align: right;
	}

	.empty-portfolio {
		text-align: center;
		padding: 2rem;
		background-color: rgba(255, 255, 255, 0.03);
		border-radius: 8px;
		border: 1px dashed rgba(255, 255, 255, 0.1);
	}

	.empty-portfolio .empty-icon {
		font-size: 3rem;
		margin-bottom: 1rem;
		color: #ffdd2d;
	}

	.empty-portfolio h4 {
		color: #ffffff;
		margin-bottom: 0.5rem;
	}

	.empty-portfolio p {
		color: #a0a0a0;
		font-size: 0.9rem;
	}

	/* Settings Styles */
	.settings-block h2 {
		color: #ffffff;
		font-size: 1.8rem;
		margin-bottom: 2rem;
		padding-bottom: 1rem;
		border-bottom: 1px solid #333;
	}

	.setting-item {
		margin-bottom: 1.5rem;
		padding-bottom: 1.5rem;
		border-bottom: 1px solid #333;
	}

	.setting-item:last-child {
		border-bottom: none;
		margin-bottom: 0;
		padding-bottom: 0;
	}

	.setting-label {
		color: #a0a0a0;
		font-size: 0.9rem;
		margin-bottom: 0.8rem;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.settings-input {
		width: 100%;
		padding: 0.7rem 1rem;
		border: 1px solid #444;
		border-radius: 6px;
		background-color: #1a1a1a;
		color: #e0e0e0;
		font-size: 1rem;
		box-sizing: border-box; /* Ensures padding doesn't increase width */
	}

	.settings-input::placeholder {
		color: #777;
	}

	.api-token-display .settings-input {
		font-family: monospace;
	}

	.form-group {
		display: flex;
		gap: 0.75rem;
		margin-top: 1rem;
	}

	.form-group.password-change {
		flex-direction: column;
	}

	.update-token-group .settings-input {
		flex-grow: 1;
	}

	.settings-button {
		padding: 0.7rem 1.5rem;
		border: none;
		border-radius: 6px;
		background-color: #ffdd2d;
		color: #1a1a1a;
		font-weight: 600;
		cursor: pointer;
		transition: background-color 0.2s;
		white-space: nowrap; /* Prevent button text from wrapping */
	}

	.settings-button:disabled {
		background-color: #555;
		cursor: not-allowed;
		opacity: 0.7;
	}

	.settings-button:hover:not(:disabled) {
		background-color: #ffe766;
	}

	.tags-input-wrapper {
		display: flex;
		gap: 0.75rem;
	}

	.tags-input-wrapper .settings-input {
		flex-grow: 1;
	}

	.add-tag-button {
		width: 40px;
		height: 40px;
		min-width: 40px;
		min-height: 40px;
		border-radius: 50%;
		background-color: #ffdd2d;
		color: #1a1a1a;
		font-size: 1.5rem;
		font-weight: 600;
		border: none;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: background-color 0.2s;
	}

	.add-tag-button:hover {
		background-color: #ffe766;
	}

	.settings-dropdown {
		background-color: #333;
		border-radius: 8px;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
		max-height: 200px;
		overflow-y: auto;
		margin-top: 0.5rem;
		position: relative;
		z-index: 10;
	}

	.settings-dropdown .company-option {
		padding: 0.8rem 1rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		cursor: pointer;
		transition: background-color 0.2s;
		border-bottom: 1px solid #444;
	}

	.settings-dropdown .company-option:last-child {
		border-bottom: none;
	}

	.settings-dropdown .company-option:hover {
		background-color: #444;
	}

	.settings-dropdown .company-info {
		display: flex;
		gap: 0.5rem;
		align-items: baseline;
	}

	.settings-dropdown .company-ticker {
		font-weight: 600;
		color: #ffdd2d;
	}

	.settings-dropdown .company-name {
		color: #e0e0e0;
		font-size: 0.9rem;
	}

	.settings-dropdown .no-results {
		text-align: center;
		padding: 1rem;
		color: #a0a0a0;
	}

	.selected-tags-display {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin-top: 1rem;
	}

	.profile-tag {
		display: inline-flex;
		align-items: center;
		background-color: rgba(255, 221, 45, 0.2); /* Yellow with transparency */
		color: #ffdd2d; /* Yellow text */
		padding: 0.4rem 0.8rem;
		border-radius: 6px;
		font-size: 0.9rem;
		font-weight: 500;
		white-space: nowrap;
	}

	.profile-tag .remove-tag-btn {
		background: none;
		border: none;
		color: #ffdd2d;
		font-size: 1.1rem;
		font-weight: 600;
		margin-left: 0.5rem;
		cursor: pointer;
		padding: 0;
		line-height: 1;
		transition: color 0.2s;
	}

	.profile-tag .remove-tag-btn:hover {
		color: #ffffff;
	}

	/* Responsive adjustments */
	@media (max-width: 768px) {
		.profile-container {
			margin: 1rem;
			padding: 1rem;
		}

		.main-profile-block,
		.settings-block {
			padding: 1.5rem;
		}

		.profile-summary {
			flex-direction: column;
			text-align: center;
		}

		.back-button {
			margin: 0 auto;
		}

		.user-details h1 {
			font-size: 1.5rem;
		}

		.balance-amount {
			font-size: 2rem;
		}

		.settings-block h2 {
			font-size: 1.5rem;
		}

		.form-group {
			flex-direction: column;
		}

		.settings-button {
			width: 100%;
		}

		.tags-input-wrapper {
			flex-direction: column;
		}

		.add-tag-button {
			width: 100%;
			border-radius: 6px;
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
