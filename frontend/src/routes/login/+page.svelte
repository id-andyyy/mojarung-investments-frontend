<script lang="ts">
	import { goto } from "$app/navigation";
	import { browser } from "$app/environment";
	let login = "";
	let password = "";
	let error: string | null = null;
	let isLoading = false;

	async function handleSubmit() {
		error = null;
		isLoading = true;
		console.log(`[Login Page] Attempting login for user: ${login}`);

		try {
			const response = await fetch("http://176.124.212.149:8000/api/auth/login", {
				method: "POST",
				headers: {
					"Content-Type": "application/x-www-form-urlencoded"
				},
				body: new URLSearchParams({
					username: login,
					password: password
				}).toString()
			});

			console.log("[Login Page] Login response status:", response.status);

			if (!response.ok) {
				let errorMessage = "Неверный логин или пароль";
				try {
					const errorData = await response.json();
					console.error("[Login Page] Login error data:", errorData);
					if (errorData.detail) {
						if (
							Array.isArray(errorData.detail) &&
							errorData.detail.length > 0 &&
							errorData.detail[0].msg
						) {
							errorMessage = errorData.detail[0].msg;
						} else if (typeof errorData.detail === "string") {
							errorMessage = errorData.detail;
						}
					}
				} catch (e) {
					console.error("[Login Page] Could not parse error response JSON:", e);
				}
				error = errorMessage;
				return;
			}

			const data = await response.json();
			console.log("[Login Page] Login successful. Received token:", data.access_token);

			// Сохраняем токен в localStorage
			if (browser) {
				localStorage.setItem("access_token", data.access_token);
				console.log("[Login Page] Token saved to localStorage.");
			}

			// Redirect to the main page on successful login
			await goto("/");
		} catch (err) {
			error = "Ошибка при подключении к серверу";
			console.error("[Login Page] Network or unexpected error during login:", err);
		} finally {
			isLoading = false;
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

			<button type="submit" class="submit-button" disabled={isLoading}>
				{#if isLoading}
					Вход...
				{:else}
					Войти
				{/if}
			</button>
		</form>
		<div class="register-link-container">
			<a href="/register" class="register-link">Нет аккаунта? Зарегистрироваться</a>
		</div>
	</div>
</main>

<style>
	/* Import Google Fonts - Inter */
	@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap");

	:global(body) {
		background-color: #1a1a1a; /* Consistent dark background */
		font-family: "Inter", sans-serif; /* Consistent font */
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
		transition:
			border-color 0.2s,
			box-shadow 0.2s;
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
		transition:
			background-color 0.2s,
			transform 0.2s,
			border-radius 0.2s; /* Добавить transition для border-radius */
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

	.register-link-container {
		text-align: center;
		margin-top: 1.5rem;
	}

	.register-link {
		color: #a0a0a0;
		text-decoration: none;
		font-size: 0.9rem;
		transition: color 0.2s;
	}

	.register-link:hover {
		color: #ffdd2d;
		text-decoration: underline;
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
