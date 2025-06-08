<script lang="ts">
	import { browser } from "$app/environment";
	import { api } from "$lib/api";

	// Состояние приложения
	let selectedTickers: string[] = [];
	let newsItems: any[] = [];
	let isLoading = true;
	let error: string | null = null;
	let showBalance = true;
	let feedMode: "recommendations" | "all" = "recommendations";
	
	// Состояние баланса
	let userBalance: any = null;
	let isLoadingBalance = false;

	// Важные новости за день
	const importantNews = [
		{
			id: 101,
			title: "ЦБ РФ повысил ключевую ставку до 16%",
			impact: "high",
			ticker: "SBER",
			tags: ["монетарная политика", "процентные ставки"]
		},
		{
			id: 102,
			title: "Минфин объявил о выпуске ОФЗ с доходностью 15%",
			impact: "high",
			ticker: "OFZ",
			tags: ["облигации", "госдолг"]
		},
		{
			id: 103,
			title: "Роснефть подписала контракт на поставку нефти в Индию",
			impact: "medium",
			ticker: "ROSN",
			tags: ["нефть", "экспорт"]
		},
		{
			id: 104,
			title: "Сбербанк запускает новую программу лояльности",
			impact: "medium",
			ticker: "SBER",
			tags: ["банки", "розничный бизнес"]
		},
		{
			id: 105,
			title: "Яндекс представил новый сервис для бизнеса",
			impact: "medium",
			ticker: "YNDX",
			tags: ["технологии", "B2B"]
		},
		{
			id: 106,
			title: "Газпром увеличивает поставки в Китай",
			impact: "high",
			ticker: "GAZP",
			tags: ["газ", "экспорт"]
		},
		{
			id: 107,
			title: "Тинькофф запускает платформу для инвестиций в стартапы",
			impact: "medium",
			ticker: "TCSG",
			tags: ["финтех", "стартапы", "инвестиции"]
		}
	];

	// Показывать всегда 7 карточек (седьмая всегда заполнена)
	$: visibleStories = [
		...importantNews.slice(0, 6),
		importantNews[6] ? importantNews[6] : { title: "Нет важных новостей", tags: [], ticker: "" }
	];

	async function fetchNews(mode: "recommendations" | "all") {
		if (!browser) return;

		console.log(`[News Page] Fetching news with mode: ${mode}`);
		isLoading = true;
		error = null;

		try {
			const params = new URLSearchParams({
				top: "20"
			});
			if (mode === "recommendations") {
				params.append("filter", "true");
			}

			const url = `/api/news/?${params.toString()}`;
			console.log(`[News Page] Fetching from URL: ${url}`);

			const response = await fetch(url, {
				credentials: "include"
			});

			console.log(`[News Page] Response status: ${response.status}`);

			if (response.status === 401) {
				error = "Для доступа к новостям необходимо авторизоваться.";
				isLoading = false;
				newsItems = [];
				console.error("[News Page] Received 401 Unauthorized. User needs to log in.");
				return;
			}

			if (!response.ok) {
				const errorData = await response
					.json()
					.catch(() => ({ detail: "Ошибка загрузки новостей" }));
				console.error("[News Page] News fetch error data:", errorData);
				throw new Error(errorData.detail || "Ошибка загрузки новостей");
			}

			const data = await response.json();
			console.log(`[News Page] Successfully fetched ${data.length} news items.`);

			newsItems = data.map((item: any) => ({
				id: item.id,
				title: item.title,
				summary: item.summary,
				keyPoints: item.summary
					? item.summary.split(". ").filter((s: string) => s && s.length > 0)
					: [],
				ticker: item.tickers?.split(",")[0].trim() || "N/A",
				sentiment: item.is_positive ? "positive" : "negative",
				source: "TBank News API",
				timestamp: item.created_at,
				recommendation: {
					action: item.is_positive ? "buy" : "sell",
					confidence: Math.floor(Math.random() * 21) + 70,
					reasoning: item.is_positive
						? "На основе анализа новостей ИИ рекомендует покупку."
						: "На основе анализа новостей ИИ рекомендует продажу."
				},
				tags: item.tags ? item.tags.split(",").map((t: string) => t.trim()) : [],
				percentageChange: parseFloat((Math.random() * 2.5 * (item.is_positive ? 1 : -1)).toFixed(1))
			}));
		} catch (e: any) {
			error = e.message || "Произошла ошибка при запросе новостей.";
			newsItems = [];
			console.error("[News Page] Error in fetchNews catch block:", e);
		} finally {
			isLoading = false;
		}
	}

	$: fetchNews(feedMode);

	// Загрузка баланса пользователя
	async function loadUserBalance() {
		if (!browser) return;
		
		isLoadingBalance = true;
		try {
			const response = await fetch('/api/invest/sandbox/balance', {
				credentials: 'include'
			});

			if (response.ok) {
				userBalance = await response.json();
				console.log('Загружен баланс:', userBalance);
			} else {
				console.log('Баланс недоступен (пользователь не авторизован или токен не настроен)');
			}
		} catch (e: any) {
			console.error('Ошибка загрузки баланса:', e);
		} finally {
			isLoadingBalance = false;
		}
	}

	// Форматирование баланса
	function formatBalance(balance: number): string {
		return new Intl.NumberFormat('ru-RU').format(Math.round(balance));
	}

	// Загрузка баланса при инициализации
	import { onMount } from 'svelte';
	onMount(() => {
		loadUserBalance();
	});

	function handleTickerSelect(ticker: string) {
		if (selectedTickers.includes(ticker)) {
			selectedTickers = selectedTickers.filter(t => t !== ticker);
		} else {
			selectedTickers = [...selectedTickers, ticker];
		}
	}
</script>

<main class="container">
	<header class="header">
		<div class="header-content">
			<div class="header-left">
				<a href="/" class="header-title-link">
					<div class="title-container">
						<img src="/bik1.png" alt="TBank Logo" class="header-logo" />
						<div class="title-text">
							<h1>TBank News Aggregator</h1>
							<p class="subtitle">Агрегатор новостей для трейдеров</p>
						</div>
					</div>
				</a>
			</div>
			<div class="profile-section">
				<div class="balance">
					<span class="balance-label">Баланс:</span>
					<span class="balance-amount">
						{#if isLoadingBalance}
							<span class="balance-loading">Загрузка...</span>
						{:else if showBalance && userBalance}
							{userBalance.currency} {formatBalance(userBalance.balance)}
						{:else if showBalance && !userBalance}
							<span class="balance-placeholder">Не доступен</span>
						{:else}
							<span class="balance-stars">***</span>
						{/if}
					</span>
					<button
						class="balance-eye"
						on:click={() => (showBalance = !showBalance)}
						aria-label="Показать/скрыть баланс"
					>
						{#if showBalance}
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="22"
								height="22"
								fill="none"
								viewBox="0 0 24 24"
								stroke="currentColor"
								><path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M1.5 12s3.5-7 10.5-7 10.5 7 10.5 7-3.5 7-10.5 7S1.5 12 1.5 12z"
								/><circle cx="12" cy="12" r="3.5" /></svg
							>
						{:else}
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="22"
								height="22"
								fill="none"
								viewBox="0 0 24 24"
								stroke="currentColor"
								><path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M17.94 17.94A10.06 10.06 0 0112 19.5c-7 0-10.5-7.5-10.5-7.5a20.3 20.3 0 014.21-5.3M6.06 6.06A10.06 10.06 0 0112 4.5c7 0 10.5 7.5 10.5 7.5a20.3 20.3 0 01-4.21 5.3M1 1l22 22"
								/></svg
							>
						{/if}
					</button>
				</div>
				<a href="/profile" class="profile-button">
					<img
						src="https://avatars.mds.yandex.net/i?id=dfb57f6793d9a8a2575c240be885d79e_l-4538910-images-thumbs&n=13"
						alt="Profile"
						class="profile-icon"
					/>
				</a>
			</div>
		</div>
	</header>

	<div class="important-news-section">
		<h2>Важные новости за день</h2>
		<div class="important-news-stories">
			{#each visibleStories as news}
				<div class="important-news-story">
					<div class="story-preview">
						<div class="story-preview-content">
							<h3 class="story-title">{news.title}</h3>
							<div class="story-tags">
								{#if news.ticker}<span class="story-tag">{news.ticker}</span>{/if}
								{#each news.tags as tag}
									<span class="story-tag">{tag}</span>
								{/each}
							</div>
						</div>
					</div>
				</div>
			{/each}
		</div>
	</div>

	<div class="content">
		<aside class="sidebar">
			<div class="feed-mode-toggle">
				<button
					class:active={feedMode === "recommendations"}
					on:click={() => (feedMode = "recommendations")}>Рекомендации</button
				>
				<button class:active={feedMode === "all"} on:click={() => (feedMode = "all")}
					>Вся лента</button
				>
			</div>
			<div class="ticker-selector">
				<h3>Выберите тикеры</h3>
				<div class="ticker-list">
					{#each ["LKOH", "SBER", "GAZP", "YNDX", "TCSG"] as ticker}
						<button
							class="ticker-button"
							class:selected={selectedTickers.includes(ticker)}
							on:click={() => handleTickerSelect(ticker)}
						>
							{ticker}
						</button>
					{/each}
				</div>
			</div>

			<div class="sources">
				<h3>Источники</h3>
				<div class="source-list">
					<label class="source-item">
						<input type="checkbox" checked /> РБК
					</label>
					<label class="source-item">
						<input type="checkbox" checked /> Интерфакс
					</label>
					<label class="source-item">
						<input type="checkbox" checked /> Ведомости
					</label>
				</div>
			</div>
		</aside>

		<section class="news-feed">
			{#if isLoading}
				<div class="loading">Загрузка новостей...</div>
			{:else if error}
				<div class="error">{error}</div>
			{:else}
				{#each newsItems as news}
					<a href="#" class="news-card-link">
						<article class="news-card">
							<div class="news-header">
								<div class="news-meta">
									<div class="news-tags">
										<span class="news-tag">{news.ticker}</span>
										{#if news.tags && news.tags.length > 0}
											{#each news.tags as tag}
												<span class="news-tag">{tag}</span>
											{/each}
										{/if}
									</div>
								</div>
								<div class="news-right">
									<div class="source-time-sentiment">
										<span class="source">{news.source}</span>
										<span class="time">{new Date(news.timestamp).toLocaleTimeString()}</span>
										<span
											class="sentiment"
											class:positive={news.sentiment === "positive"}
											class:negative={news.sentiment === "negative"}
										>
											<div class="sentiment-circle"></div>
										</span>
										{#if news.percentageChange !== undefined}
											<span
												class="percentage-change"
												class:positive={news.percentageChange > 0}
												class:negative={news.percentageChange < 0}
											>
												{news.percentageChange > 0 ? "+" : ""}{news.percentageChange.toFixed(1)}%
											</span>
										{/if}
									</div>
								</div>
							</div>

							<div class="news-content">
								<h3 class="news-title">{news.title}</h3>
								<div class="key-points">
									<ul>
										{#each news.keyPoints as point}
											<li>{point}</li>
										{/each}
									</ul>
								</div>
							</div>

							<div class="recommendation">
								<h4>Рекомендация ИИ</h4>
								<div class="confidence-meter">
									<div class="confidence-bar-center">
										{#if news.recommendation.action === "buy"}
											<div
												class="confidence-bar right"
												style="width: {news.recommendation.confidence / 2}%"
											></div>
										{:else if news.recommendation.action === "sell"}
											<div
												class="confidence-bar left"
												style="width: {news.recommendation.confidence / 2}%"
											></div>
										{:else}
											<div class="confidence-bar hold" style="width: 0%"></div>
										{/if}
									</div>
								</div>
								<span class="confidence-text">Уверенность: {news.recommendation.confidence}%</span>
								<p class="reasoning">{news.recommendation.reasoning}</p>
								<div class="action-buttons">
									<button class="action-button"
										>{news.recommendation.action === "buy"
											? `Купить ${news.ticker}`
											: news.recommendation.action === "sell"
												? `Продать ${news.ticker}`
												: `Держать ${news.ticker}`}</button
									>
									<div class="news-actions">
										<button class="action-icon like">
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="20"
												height="20"
												viewBox="0 0 24 24"
												fill="none"
												stroke="currentColor"
												stroke-width="2"
												stroke-linecap="round"
												stroke-linejoin="round"
											>
												<path
													d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"
												></path>
											</svg>
										</button>
										<button class="action-icon dislike">
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="20"
												height="20"
												viewBox="0 0 24 24"
												fill="none"
												stroke="currentColor"
												stroke-width="2"
												stroke-linecap="round"
												stroke-linejoin="round"
											>
												<path
													d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17"
												></path>
											</svg>
										</button>
									</div>
								</div>
							</div>
						</article>
					</a>
				{/each}
			{/if}
		</section>
	</div>
</main>

<style>
	@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap");

	/* Global styles for news tags - highest priority */
	:global(.news-tags) {
		display: flex;
		flex-wrap: wrap;
		gap: 0.4rem;
	}

	:global(.news-tag) {
		font-weight: 600;
		color: #ffdd2d !important;
		background: rgba(255, 221, 45, 0.1) !important;
		padding: 0.2rem 0.5rem;
		border-radius: 4px;
	}

	:global(body) {
		background-color: #1a1a1a;
		font-family: "Inter", sans-serif;
	}

	.container {
		max-width: 1200px;
		margin: 0 auto;
		padding: rem;
	}

	.header {
		margin-bottom: 1.5rem;
		padding: 1rem 0;
		border-bottom: 1px solid #333;
	}

	.header-content {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.header-left {
		text-align: left;
	}

	.header-left h1 {
		font-size: 2rem;
		margin: 0;
		color: #ffdd2d;
		font-weight: 700;
	}

	.subtitle {
		margin: 0.5rem 0 0 0;
		color: #a0a0a0;
		font-size: 1rem;
	}

	.profile-section {
		display: flex;
		align-items: center;
		gap: 1.5rem;
	}

	.balance {
		display: flex;
		flex-direction: column;
		align-items: flex-end;
		position: relative;
	}

	.balance-label {
		font-size: 0.9rem;
		color: #a0a0a0;
	}

	.balance-amount {
		font-size: 1.3rem;
		font-weight: 600;
		color: #ffdd2d;
		letter-spacing: 0.5px;
		display: flex;
		align-items: center;
	}

	.balance-stars {
		color: #ffdd2d;
		font-size: 1.3rem;
		letter-spacing: 0.2em;
		font-weight: 600;
	}

	.balance-loading {
		color: #a0a0a0;
		font-size: 1.1rem;
		font-style: italic;
	}

	.balance-placeholder {
		color: #666;
		font-size: 1.1rem;
		font-style: italic;
	}

	.balance-eye {
		background: none;
		border: none;
		cursor: pointer;
		font-size: 1.2rem;
		margin-left: 0.3rem;
		color: #a0a0a0;
		transition: color 0.2s;
		vertical-align: middle;
		padding: 0;
	}

	.balance-eye:hover {
		color: #ffdd2d;
	}

	.profile-button {
		background: none;
		border: none;
		padding: 0;
		cursor: pointer;
		transition: transform 0.2s;
	}

	.profile-button:hover {
		transform: scale(1.05);
	}

	.profile-icon {
		width: 45px;
		height: 45px;
		border-radius: 50%;
		border: 2px solid #ffdd2d;
	}

	.tabs {
		display: none;
	}

	.tab-button {
		display: none;
	}

	.content {
		display: grid;
		grid-template-columns: 300px 1fr;
		gap: 2rem;
		align-items: start;
	}

	.sidebar {
		background: #242424;
		padding: 1.5rem;
		border-radius: 12px;
		border: 1px solid #333;
	}

	.ticker-selector,
	.sources {
		margin-bottom: 2rem;
	}

	h3 {
		margin-bottom: 1rem;
		color: #ffdd2d;
		font-size: 1.1rem;
	}

	.ticker-list {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
	}

	.ticker-button {
		padding: 0.5rem 1rem;
		border: 1px solid #333;
		border-radius: 10px;
		background: #1a1a1a;
		color: #ffffff;
		cursor: pointer;
		transition: all 0.2s;
	}

	.ticker-button.selected {
		background: #ffdd2d;
		color: #1a1a1a;
		border-color: #ffdd2d;
		font-weight: 600;
	}

	.source-list {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.source-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		cursor: pointer;
		color: #ffffff;
	}

	.source-item input[type="checkbox"] {
		accent-color: #ffdd2d;
	}

	.news-feed {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.news-card-link {
		text-decoration: none;
		color: inherit;
		display: block;
	}

	.news-card {
		background: #242424;
		padding: 1rem;
		border-radius: 8px;
		border: 1px solid #333;
		transition: all 0.2s;
		margin-bottom: 0.5rem;
	}

	.news-card:hover {
		background: #2a2a2a;
		border-color: #ffdd2d;
	}

	.recommendation {
		margin-top: 0rem;
		padding-top: 0rem;
		border-top: 1px solid #333;
	}

	.recommendation h4 {
		color: #ffdd2d;
		margin-bottom: 0.2rem;
		font-size: 1rem;
	}

	.confidence-meter {
		background: #333;
		height: 12px;
		border-radius: 6px;
		margin: 0.2rem 0 0.05rem 0;
		position: relative;
		overflow: hidden;
		display: flex;
		align-items: center;
	}

	.confidence-bar-center {
		position: relative;
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.confidence-bar {
		position: absolute;
		height: 100%;
		top: 0;
		transition: width 0.3s ease;
		border-radius: 6px;
	}

	.confidence-bar.right {
		left: 50%;
		background: #4caf50;
		border-top-left-radius: 0;
		border-bottom-left-radius: 0;
		z-index: 2;
	}

	.confidence-bar.left {
		right: 50%;
		background: #f44336;
		border-top-right-radius: 0;
		border-bottom-right-radius: 0;
		z-index: 2;
	}

	.confidence-bar.hold {
		left: 50%;
		background: #a0a0a0;
		width: 0;
		z-index: 2;
	}

	.confidence-text {
		font-size: 0.8rem;
		color: #a0a0a0;
		margin-top: 0.5rem;
		text-align: right;
		display: block;
	}

	.reasoning {
		font-size: 0.85rem;
		color: #ffffff;
		margin: 0.2rem 0 0.3rem 0;
		line-height: 1.25;
	}

	.action-buttons {
		margin-top: 0.5rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.action-button {
		padding: 0.5rem 1rem;
		border: none;
		border-radius: 10px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s;
		width: auto;
		min-width: 120px;
		margin: 0;
		background: #ffdd2d;
		color: #1a1a1a;
	}

	.action-button:hover {
		opacity: 0.9;
		transform: translateY(-2px);
	}

	.news-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		margin-bottom: 0.5rem;
		font-size: 0.85rem;
	}

	.news-meta {
		display: flex;
		align-items: flex-start;
	}

	.news-right {
		display: flex;
		align-items: center;
	}

	.source-time-sentiment {
		display: flex;
		align-items: center;
		gap: 0.8rem;
	}

	.time {
		font-size: 0.85rem;
		color: #a0a0a0;
	}

	.source {
		color: #ffffff;
		font-weight: 500;
	}

	.percentage-change {
		font-size: 0.85rem;
		font-weight: 600;
	}

	.percentage-change.positive {
		color: #4caf50; /* Green for positive change */
	}

	.percentage-change.negative {
		color: #f44336; /* Red for negative change */
	}

	.news-content {
		display: flex;
		gap: 1rem;
	}

	.news-title {
		font-size: 1.2rem;
		margin: 0;
		color: #ffffff;
		flex: 1;
		line-height: 1.4;
	}

	.key-points {
		flex: 1;
		font-size: 0.9rem;
		color: #a0a0a0;
	}

	.key-points ul {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	.key-points li {
		margin-bottom: 0.25rem;
		display: flex;
		align-items: flex-start;
		gap: 0.5rem;
	}

	.key-points li:before {
		content: "•";
		color: #ffdd2d;
	}

	.sentiment {
		font-size: 1rem;
	}

	.sentiment-circle {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		background-color: #a0a0a0;
	}

	.sentiment.positive .sentiment-circle {
		background-color: #4caf50;
	}

	.sentiment.negative .sentiment-circle {
		background-color: #f44336;
	}

	.loading {
		text-align: center;
		padding: 2rem;
		color: #a0a0a0;
	}

	.error {
		text-align: center;
		padding: 2rem;
		color: #ff3e00;
		background: rgba(255, 62, 0, 0.1);
		border-radius: 8px;
		border: 1px solid #ff3e00;
	}

	.important-news-section {
		margin-bottom: 2rem;
	}

	.important-news-section h2 {
		color: #ffdd2d;
		margin-bottom: 1rem;
		font-size: 1.5rem;
	}

	.important-news-stories {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		gap: 1rem;
		width: 100%;
		padding: 0.5rem 0;
	}
	.source {
		color: #ffffff;
	}
	.important-news-story {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		width: 100%;
		height: 100%;
	}

	.story-preview {
		width: 100%;
		aspect-ratio: 1 / 1;
		background: #242424;
		border: 2px solid #333;
		border-radius: 12px;
		overflow: hidden;
		position: relative;
		cursor: pointer;
		transition: all 0.2s;
	}

	.story-preview:hover {
		border-color: #ffdd2d;
		transform: scale(1.02);
	}

	.story-preview-content {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		padding: 0.75rem;
		display: flex;
		flex-direction: column;
		justify-content: flex-start;
		align-items: flex-start;
	}

	.story-title {
		font-size: 0.85rem;
		margin: 0 0 0.5rem 0;
		color: #ffffff;
		line-height: 1.2;
		display: -webkit-box;
		-webkit-line-clamp: 4;
		-webkit-box-orient: vertical;
		overflow: hidden;
		text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
	}

	.story-tags {
		display: flex;
		flex-wrap: wrap;
		gap: 0.25rem;
		margin-top: auto;
	}

	.story-tag {
		font-size: 0.65rem;
		color: #ffdd2d;
		background: rgba(255, 221, 45, 0.1);
		padding: 0.1rem 0.3rem;
		border-radius: 3px;
	}

	.feed-mode-toggle {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}
	.feed-mode-toggle button {
		padding: 0.4rem 1.2rem;
		border: 1px solid #333;
		border-radius: 10px;
		background: #1a1a1a;
		color: #fff;
		cursor: pointer;
		font-weight: 600;
		transition:
			background 0.2s,
			color 0.2s,
			border 0.2s;
	}
	.feed-mode-toggle button.active {
		background: #ffdd2d;
		color: #1a1a1a;
		border-color: #ffdd2d;
	}

	@media (max-width: 480px) {
		.container {
			padding: 0.1rem;
			max-width: 100vw;
		}
		.content {
			display: flex;
			flex-direction: column;
			gap: 0.3rem;
			width: 97%;
		}
		.source {
			opacity: 1;
		}
		.sidebar {
			order: 1;
			width: 98%;
			margin-bottom: 0.3rem;
			padding: 0.2rem;
			border-radius: 6px;
			box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
		}
		.news-feed {
			order: 2;
			width: 100%;
			gap: 0.5rem;
			margin-top: 0;
		}
		.important-news-section {
			margin-bottom: 0.3rem;
		}
		.important-news-stories {
			grid-template-columns: 1fr 1fr;
			column-gap: 0.3rem;
			row-gap: 0.5rem;
		}
		.important-news-story {
			margin: 0;
			width: 90%;
		}
		.story-preview {
			min-height: 20px;
			padding: 0.1rem 0.2rem;
			border-radius: 5px;
			font-size: 0.7rem;
		}
		.news-card {
			margin-bottom: 0.5rem;
		}
		.news-header {
			flex-direction: column;
			flex-wrap: nowrap;
		}
		.news-tags {
			display: flex;
			flex-wrap: nowrap;
			overflow-x: auto;
			gap: 0.12rem;
			padding-bottom: 0;
			scrollbar-width: none;
		}
		.news-tags::-webkit-scrollbar {
			display: none;
		}
		.news-tag {
			font-size: 0.7em;
			padding: 0.08em 0.4em;
			border-radius: 3px;
			font-weight: 600;
			white-space: nowrap;
		}
		.time {
			font-size: 0.75em;
			color: #a0a0a0;
			margin-top: 0.1rem;
			margin-left: 0.5rem;
			flex-shrink: 0;
			min-width: 48px;
			text-align: right;
		}
		.ticker-list,
		.source-list {
			display: flex;
			flex-wrap: nowrap;
			overflow-x: auto;
			gap: 0.1rem;
			padding-bottom: 0.1rem;
			scrollbar-width: none;
		}
		.ticker-list::-webkit-scrollbar,
		.source-list::-webkit-scrollbar {
			display: none;
		}
		.ticker-button,
		.source-item {
			font-size: 0.7rem;
			padding: 0.12rem 0.4rem;
			border-radius: 4px;
			min-width: 32px;
		}
		.news-title {
			font-size: 0.9rem;
			margin: 0 0 0.08rem 0;
			line-height: 1.1;
		}
		.action-button {
			font-size: 0.7rem;
			padding: 0.12rem 0.4rem;
			border-radius: 4px;
			min-width: 32px;
		}
		.profile-section {
			gap: 0.2rem;
		}
		.profile-icon {
			width: 22px;
			height: 22px;
		}
		.balance-amount {
			font-size: 0.7rem;
		}
	}
	@media (max-width: 600px) {
		.feed-mode-toggle {
			gap: 0.2rem;
			margin-bottom: 0.7rem;
		}
		.feed-mode-toggle button {
			padding: 0.3rem 0.7rem;
			font-size: 0.9rem;
		}
	}

	.news-actions {
		display: flex;
		gap: 0.5rem;
	}

	.action-icon {
		width: 32px;
		height: 32px;
		border-radius: 50%;
		border: 1px solid #333;
		background: #242424;
		color: #666;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.2s;
		padding: 0;
	}

	.action-icon:hover {
		background: #2a2a2a;
		color: #ffdd2d;
		border-color: #ffdd2d;
	}

	.action-icon svg {
		width: 16px;
		height: 16px;
	}

	.title-container {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.title-text {
		display: flex;
		flex-direction: column;
	}

	.header-logo {
		width: 60px;
		height: 60px;
		object-fit: contain;
	}

	.header-left h1 {
		font-size: 2rem;
		margin: 0;
		color: #ffdd2d;
		font-weight: 700;
	}

	.subtitle {
		margin: 0.5rem 0 0 0;
		color: #a0a0a0;
		font-size: 1rem;
	}

	/* Update mobile styles */
	@media (max-width: 600px) {
		.header-logo {
			width: 48px;
			height: 48px;
		}
		.header-left h1 {
			font-size: 1.5rem;
		}
		.subtitle {
			font-size: 0.9rem;
		}
	}

	@media (max-width: 400px) {
		.header-logo {
			width: 40px;
			height: 40px;
		}
		.header-left h1 {
			font-size: 1.3rem;
		}
		.subtitle {
			font-size: 0.8rem;
		}
	}

	.header-title-link {
		text-decoration: none;
		color: inherit;
	}
</style>
