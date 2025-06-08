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
