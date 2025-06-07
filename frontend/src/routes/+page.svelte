<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '$lib/api';

  // Состояние приложения
  let selectedTickers: string[] = [];
  let newsItems: any[] = [];
  let isLoading = true;
  let error: string | null = null;
  let showBalance = true;

  // Важные новости за день
  const importantNews = [
    {
      id: 101,
      title: 'ЦБ РФ повысил ключевую ставку до 16%',
      impact: 'high',
      ticker: 'SBER',
      tags: ['монетарная политика', 'процентные ставки']
    },
    {
      id: 102,
      title: 'Минфин объявил о выпуске ОФЗ с доходностью 15%',
      impact: 'high',
      ticker: 'OFZ',
      tags: ['облигации', 'госдолг']
    },
    {
      id: 103,
      title: 'Роснефть подписала контракт на поставку нефти в Индию',
      impact: 'medium',
      ticker: 'ROSN',
      tags: ['нефть', 'экспорт']
    },
    {
      id: 104,
      title: 'Сбербанк запускает новую программу лояльности',
      impact: 'medium',
      ticker: 'SBER',
      tags: ['банки', 'розничный бизнес']
    },
    {
      id: 105,
      title: 'Яндекс представил новый сервис для бизнеса',
      impact: 'medium',
      ticker: 'YNDX',
      tags: ['технологии', 'B2B']
    },
    {
      id: 106,
      title: 'Газпром увеличивает поставки в Китай',
      impact: 'high',
      ticker: 'GAZP',
      tags: ['газ', 'экспорт']
    },
    {
      id: 107,
      title: 'Тинькофф запускает платформу для инвестиций в стартапы',
      impact: 'medium',
      ticker: 'TCSG',
      tags: ['финтех', 'стартапы', 'инвестиции']
    }
  ];

  // Показывать всегда 7 карточек (седьмая всегда заполнена)
  $: visibleStories = [
    ...importantNews.slice(0, 6),
    importantNews[6]
      ? importantNews[6]
      : { title: 'Нет важных новостей', tags: [], ticker: '' }
  ];

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
    <div class="header-content">
      <div class="header-left">
        <h1>TBank News Aggregator</h1>
        <p class="subtitle">Агрегатор новостей для трейдеров</p>
      </div>
      <div class="profile-section">
        <div class="balance">
          <span class="balance-label">Баланс:</span>
          <span class="balance-amount">
            {#if showBalance}
              ₽ 1,234,567
            {:else}
              <span class="balance-stars">***</span>
            {/if}
          </span>
          <button class="balance-eye" on:click={() => showBalance = !showBalance} aria-label="Показать/скрыть баланс">
            {#if showBalance}
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1.5 12s3.5-7 10.5-7 10.5 7 10.5 7-3.5 7-10.5 7S1.5 12 1.5 12z"/><circle cx="12" cy="12" r="3.5"/></svg>
            {:else}
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.94 17.94A10.06 10.06 0 0112 19.5c-7 0-10.5-7.5-10.5-7.5a20.3 20.3 0 014.21-5.3M6.06 6.06A10.06 10.06 0 0112 4.5c7 0 10.5 7.5 10.5 7.5a20.3 20.3 0 01-4.21 5.3M1 1l22 22"/></svg>
            {/if}
          </button>
        </div>
        <a href="/profile" class="profile-button">
          <img src="https://avatars.mds.yandex.net/i?id=dfb57f6793d9a8a2575c240be885d79e_l-4538910-images-thumbs&n=13" alt="Profile" class="profile-icon" />
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
          <a href="/news/{news.id}" class="news-card-link">
            <article class="news-card">
              <div class="news-header">
                <div class="news-meta">
                  <div class="news-tags-time">
                    <div class="news-tags">
                      <span class="news-tag">{news.ticker}</span>
                      {#if news.tags && news.tags.length > 0}
                        {#each news.tags as tag}
                          <span class="news-tag">{tag}</span>
                        {/each}
                      {/if}
                    </div>
                    <span class="time">{new Date(news.timestamp).toLocaleTimeString()}</span>
                  </div>
                  <span class="sentiment" class:positive={news.sentiment === 'positive'} class:negative={news.sentiment === 'negative'}>
                    {news.sentiment === 'positive' ? '📈' : news.sentiment === 'negative' ? '📉' : '➡️'}
                  </span>
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
          </a>
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

  .news-tags-time {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    margin-top: 0.1rem;
    width: 100%;
    gap: 0.2rem;
  }

  .news-tags {
    flex: 1 1 auto;
    min-width: 0;
    flex-wrap: wrap;
  }

  .news-tag {
    font-weight: 600;
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    margin-right: 0.4rem;
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
    text-shadow: 0 1px 3px rgba(0,0,0,0.5);
  }

  .story-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
    margin-top: auto;
  }

  .story-tag {
    font-size: 0.65rem;
    color: #e0e0e0;
    background: rgba(160, 160, 160, 0.2);
    padding: 0.1rem 0.3rem;
    border-radius: 3px;
    white-space: nowrap;
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
    .source{
      opacity: 0;
    }
    .sidebar {
      order: 1;
      width: 98%;
      margin-bottom: 0.3rem;
      padding: 0.2rem;
      border-radius: 6px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.06);
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
    .news-tags-time {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 0.2rem;
      margin-bottom: 0.2rem;
      padding-bottom: 0.2rem;
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
      background: #222;
      color: #ffd600;
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
    .ticker-list, .source-list {
      display: flex;
      flex-wrap: nowrap;
      overflow-x: auto;
      gap: 0.1rem;
      padding-bottom: 0.1rem;
      scrollbar-width: none;
    }
    .ticker-list::-webkit-scrollbar, .source-list::-webkit-scrollbar {
      display: none;
    }
    .ticker-button, .source-item {
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
</style> 