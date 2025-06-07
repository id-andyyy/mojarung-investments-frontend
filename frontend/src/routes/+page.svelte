<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '$lib/api';

  // Состояние приложения
  let selectedTickers: string[] = [];
  let newsItems: any[] = [];
  let isLoading = true;
  let error: string | null = null;
  let activeTab: 'morning' | 'live' = 'morning';

  // Моковые данные для демонстрации
  const mockNews = [
    {
      id: 1,
      title: 'ЛУКОЙЛ объявил о рекордной прибыли',
      summary: 'Компания показала рост прибыли на 25% по сравнению с прошлым кварталом',
      keyPoints: [
        'Прибыль выросла на 25% к прошлому кварталу',
        'Дивиденды могут быть увеличены',
        'Новые проекты в Арктике'
      ],
      ticker: 'LKOH',
      sentiment: 'positive',
      source: 'РБК',
      timestamp: '2024-03-20T09:00:00Z',
      recommendation: {
        action: 'buy',
        confidence: 85,
        reasoning: 'Сильный рост прибыли и перспективные проекты указывают на потенциал роста акций'
      },
      tags: ['нефть', 'энергетика', 'дивиденды']
    },
    {
      id: 2,
      title: 'Сбербанк запускает новую программу для инвесторов',
      summary: 'Банк представил инновационный продукт для розничных инвесторов',
      keyPoints: [
        'Новый ИИ-ассистент для трейдеров',
        'Комиссии снижены на 30%',
        'Доступ к премиум-аналитике'
      ],
      ticker: 'SBER',
      sentiment: 'positive',
      source: 'Интерфакс',
      timestamp: '2024-03-20T08:45:00Z',
      recommendation: {
        action: 'buy',
        confidence: 75,
        reasoning: 'Инновационные продукты могут привлечь новых клиентов и увеличить доходы'
      },
      tags: ['банки', 'финансы', 'технологии', 'инвестиции']
    },
    {
      id: 3,
      title: 'Газпром снижает прогноз по добыче газа',
      summary: 'Компания пересмотрела планы по добыче в связи с рыночной ситуацией',
      keyPoints: [
        'Снижение добычи на 15%',
        'Переориентация на азиатский рынок',
        'Отложены новые проекты'
      ],
      ticker: 'GAZP',
      sentiment: 'negative',
      source: 'Ведомости',
      timestamp: '2024-03-20T08:30:00Z',
      recommendation: {
        action: 'sell',
        confidence: 80,
        reasoning: 'Снижение добычи и отложенные проекты могут негативно повлиять на финансовые показатели'
      },
      tags: ['газ', 'энергетика', 'санкции']
    },
    {
      id: 4,
      title: 'Яндекс анонсирует новые сервисы для бизнеса',
      summary: 'Компания расширяет линейку B2B-продуктов',
      keyPoints: [
        'Запуск облачной платформы',
        'Интеграция с Тинькофф',
        'Новые тарифы для малого бизнеса'
      ],
      ticker: 'YNDX',
      sentiment: 'neutral',
      source: 'Коммерсант',
      timestamp: '2024-03-20T08:15:00Z',
      recommendation: {
        action: 'hold',
        confidence: 65,
        reasoning: 'Новые сервисы могут принести результаты в долгосрочной перспективе'
      },
      tags: ['технологии', 'интернет', 'B2B']
    }
  ];

  onMount(() => {
    // Здесь будет реальный API запрос
    setTimeout(() => {
      newsItems = mockNews;
      isLoading = false;
    }, 1000);
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
    <h1>TBank News Aggregator</h1>
    <p class="subtitle">Агрегатор новостей для трейдеров</p>
  </header>

  <div class="tabs">
    <button 
      class="tab-button" 
      class:active={activeTab === 'morning'}
      on:click={() => activeTab = 'morning'}
    >
      Утренний дайджест
    </button>
    <button 
      class="tab-button" 
      class:active={activeTab === 'live'}
      on:click={() => activeTab = 'live'}
    >
      Живая лента
    </button>
  </div>

  <div class="content">
    <aside class="sidebar">
      <div class="ticker-selector">
        <h3>Выберите тикеры</h3>
        <div class="ticker-list">
          {#each ['LKOH', 'SBER', 'GAZP', 'YNDX', 'TCSG'] as ticker}
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
            <input type="checkbox" checked> РБК
          </label>
          <label class="source-item">
            <input type="checkbox" checked> Интерфакс
          </label>
          <label class="source-item">
            <input type="checkbox" checked> Ведомости
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
          <article class="news-card">
            <div class="news-header">
              <div class="news-meta">
                <span class="ticker">{news.ticker}</span>
                {#if news.tags && news.tags.length > 0}
                  <div class="news-tags">
                    {#each news.tags as tag}
                      <span class="news-tag">{tag}</span>
                    {/each}
                  </div>
                {/if}
                <span class="sentiment" class:positive={news.sentiment === 'positive'} class:negative={news.sentiment === 'negative'}>
                  {news.sentiment === 'positive' ? '📈' : news.sentiment === 'negative' ? '📉' : '➡️'}
                </span>
                <span class="time">{new Date(news.timestamp).toLocaleTimeString()}</span>
              </div>
              <span class="source">{news.source}</span>
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
                  {#if news.recommendation.action === 'buy'}
                    <div class="confidence-bar right" style="width: {news.recommendation.confidence / 2}%"></div>
                  {:else if news.recommendation.action === 'sell'}
                    <div class="confidence-bar left" style="width: {news.recommendation.confidence / 2}%"></div>
                  {:else}
                    <div class="confidence-bar hold" style="width: 0%"></div>
                  {/if}
                </div>
              </div>
              <span class="confidence-text">Уверенность: {news.recommendation.confidence}%</span>
              <p class="reasoning">{news.recommendation.reasoning}</p>
              <div class="action-buttons">
                <button class="action-button">{news.recommendation.action === 'buy' ? `Купить ${news.ticker}` : news.recommendation.action === 'sell' ? `Продать ${news.ticker}` : `Держать ${news.ticker}`}</button>
              </div>
            </div>
          </article>
        {/each}
      {/if}
    </section>
  </div>
</main>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');

  :global(body) {
    background-color: #1a1a1a;
    color: #ffffff;
    font-family: 'Inter', sans-serif;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  .header {
    text-align: center;
    margin-bottom: 2rem;
  }

  h1 {
    color: #ffdd2d;
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
    font-weight: 700;
  }

  .subtitle {
    color: #a0a0a0;
    font-size: 1.2rem;
  }

  .tabs {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    border-bottom: 1px solid #333;
    padding-bottom: 1rem;
  }

  .tab-button {
    padding: 0.75rem 1.5rem;
    border: none;
    background: none;
    font-size: 1rem;
    cursor: pointer;
    color: #a0a0a0;
    border-radius: 4px;
    transition: all 0.2s;
  }

  .tab-button.active {
    background: #ffdd2d;
    color: #1a1a1a;
    font-weight: 600;
  }

  .content {
    display: grid;
    grid-template-columns: 300px 1fr;
    gap: 2rem;
  }

  .sidebar {
    background: #242424;
    padding: 1.5rem;
    border-radius: 12px;
    border: 1px solid #333;
  }

  .ticker-selector, .sources {
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
    border-radius: 6px;
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
    margin-top: 0.05rem;
  }

  .reasoning {
    font-size: 0.85rem;
    color: #ffffff;
    margin: 0.2rem 0 0.3rem 0;
    line-height: 1.25;
  }

  .action-buttons {
    margin-top: 0.2rem;
    display: flex;
    justify-content: flex-start;
  }

  .action-button {
    padding: 0.5rem 1.5rem;
    border: none;
    border-radius: 6px;
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
    align-items: center;
    margin-bottom: 0.5rem;
    font-size: 0.85rem;
  }

  .news-meta {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .ticker {
    font-weight: 600;
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
  }

  .source {
    color: #a0a0a0;
    font-size: 0.8rem;
  }

  .time {
    color: #666;
    font-size: 0.8rem;
  }

  .news-tags {
    display: flex;
    flex-wrap: nowrap;
    gap: 0.4rem;
    margin-left: 0.5rem;
    overflow-x: auto;
    padding-bottom: 0.2rem;
  }

  .news-tag {
    font-weight: 600;
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    white-space: nowrap;
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

  .sentiment.positive {
    color: #4caf50;
  }

  .sentiment.negative {
    color: #f44336;
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

  @media (max-width: 768px) {
    .content {
      grid-template-columns: 1fr;
    }

    .sidebar {
      order: 2;
    }

    .news-content {
      flex-direction: column;
      gap: 0.5rem;
    }

    .news-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.25rem;
    }

    .news-meta {
      width: 100%;
      justify-content: space-between;
    }
  }
</style> 