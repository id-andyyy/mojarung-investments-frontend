<script lang="ts">
  import { onMount } from 'svelte';

  // Моковые данные для демонстрации (скопировано из +page.svelte для согласованности)
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
        reasoning: 'Сильный рост прибыли и перспективные проекты указывают на потенциал роста акций. Компания демонстрирует устойчивый рост финансовых показателей, что подтверждается увеличением прибыли на 25%. Новые проекты в Арктическом регионе открывают дополнительные возможности для развития бизнеса. Аналитики ожидают дальнейшего укрепления позиций компании на рынке.'
      },
      tags: ['нефть', 'энергетика', 'дивиденды'],
      fullText: 'ЛУКОЙЛ, одна из крупнейших нефтяных компаний России, объявила о рекордной прибыли по итогам последнего финансового квартала. Согласно официальным данным, прибыль компании выросла на 25% по сравнению с предыдущим кварталом, что значительно превзошло ожидания аналитиков. Этот рост обусловлен благоприятной конъюнктурой мирового рынка нефти, а также эффективной оптимизацией внутренних бизнес-процессов. Компания также намекнула на возможное увеличение дивидендов для акционеров, что вызвало позитивную реакцию на рынке. В дополнение к этому, ЛУКОЙЛ активно развивает новые проекты в Арктическом регионе, что обещает долгосрочные перспективы роста и укрепление позиций на глобальном энергетическом рынке.'
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
      tags: ['банки', 'финансы', 'технологии', 'инвестиции'],
      fullText: 'Сбербанк, крупнейший банк России, представил новую инновационную программу, разработанную специально для розничных инвесторов. В рамках этой программы банк запускает передового ИИ-ассистента, который будет помогать трейдерам принимать обоснованные решения, анализируя огромные объемы данных в реальном времени. Одним из ключевых преимуществ новой программы является снижение комиссий на 30%, что делает инвестиции более доступными для широкого круга клиентов. Кроме того, инвесторы получат эксклюзивный доступ к премиум-аналитике и исследованиям рынка от ведущих экспертов Сбербанка, что позволит им быть в курсе последних тенденций и принимать более информированные решения.'
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
      tags: ['газ', 'энергетика', 'санкции'],
      fullText: 'Газпром, ведущая российская газовая компания, объявила о пересмотре своих планов по добыче газа на текущий год. В связи с изменением рыночной ситуации и геополитических факторов, компания снизила прогноз по добыче на 15%. Это решение является частью более широкой стратегии по адаптации к новым реалиям на мировом энергетическом рынке. Газпром также подтвердил свои намерения по переориентации поставок газа на азиатские рынки, активно развивая инфраструктуру и налаживая новые партнерские отношения в этом регионе. Тем не менее, некоторые новые проекты по добыче газа были отложены на неопределенный срок, что может повлиять на долгосрочные перспективы компании.'
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
      tags: ['технологии', 'интернет', 'B2B'],
      fullText: 'Яндекс, российский технологический гигант, анонсировал запуск целого ряда новых сервисов, ориентированных на бизнес-сектор. В рамках расширения линейки B2B-продуктов компания представила новую облачную платформу, которая предоставит предприятиям доступ к масштабируемым вычислительным ресурсам и передовым инструментам для анализа данных. Также было объявлено об интеграции с Тинькофф, что позволит клиентам пользоваться бесшовными финансовыми услугами прямо внутри платформы Яндекса. В дополнение к этому, Яндекс вводит новые, более гибкие тарифные планы для малого и среднего бизнеса, что сделает их продукты и сервисы более доступными и привлекательными для широкого круга компаний.'
    }
  ];

  let newsItem: any = mockNews[0]; // Выбираем первую новость для демонстрации
  let isLoading = false; // Не загружаем, так как данные уже есть
  let error: string | null = null;

  // Функция для обработки нажатия кнопки покупки/продажи (заглушка)
  function handleAction(action: string, ticker: string) {
    alert(`${action} ${ticker}`);
  }
</script>

<main class="news-detail-container">
  <header class="header">
    <div class="header-content">
      <div class="header-left">
        <a href="/" class="header-title-link">
          <h1>TBank News Aggregator</h1>
        </a>
        <p class="subtitle">Агрегатор новостей для трейдеров</p>
      </div>
      <!-- Profile section can be added here if needed, similar to main page -->
    </div>
  </header>
  {#if isLoading}
    <div class="loading">Загрузка новости...</div>
  {:else if error}
    <div class="error">{error}</div>
  {:else if newsItem}
    <article class="news-detail-card">
      <div class="news-header">
        <div class="news-meta">
          <span class="ticker">{newsItem.ticker}</span>
          {#if newsItem.tags && newsItem.tags.length > 0}
            <div class="news-tags">
              {#each newsItem.tags as tag}
                <span class="news-tag">{tag}</span>
              {/each}
            </div>
          {/if}
          <span class="sentiment" class:positive={newsItem.sentiment === 'positive'} class:negative={newsItem.sentiment === 'negative'}>
            {newsItem.sentiment === 'positive' ? '📈' : newsItem.sentiment === 'negative' ? '📉' : '➡️'}
          </span>
          <span class="time">{new Date(newsItem.timestamp).toLocaleString()}</span>
        </div>
        <span class="source">{newsItem.source}</span>
      </div>

      <h1 class="news-detail-title">{newsItem.title}</h1>
      <p class="news-summary">{newsItem.summary}</p>

      <div class="key-points">
        <h3>Ключевые моменты:</h3>
        <ul>
          {#each newsItem.keyPoints as point}
            <li>{point}</li>
          {/each}
        </ul>
      </div>

      {#if newsItem.fullText}
        <div class="full-text">
          <p>{newsItem.fullText}</p>
        </div>
      {/if}

      <div class="recommendation-and-chart-container">
        <div class="recommendation-detail">
          <h4>Рекомендация ИИ</h4>
          <div class="confidence-meter">
            <div class="confidence-bar-center">
              {#if newsItem.recommendation.action === 'buy'}
                <div class="confidence-bar right" style="width: {newsItem.recommendation.confidence / 2}%"></div>
              {:else if newsItem.recommendation.action === 'sell'}
                <div class="confidence-bar left" style="width: {newsItem.recommendation.confidence / 2}%"></div>
              {:else}
                <div class="confidence-bar hold" style="width: 0%"></div>
              {/if}
            </div>
          </div>
          <span class="confidence-text">Уверенность: {newsItem.recommendation.confidence}%</span>
          <p class="reasoning">{newsItem.recommendation.reasoning}</p>
          <div class="action-buttons">
            <button 
              class="action-button" 
              on:click={() => handleAction(newsItem.recommendation.action, newsItem.ticker)}
            >
              {newsItem.recommendation.action === 'buy' ? `Купить ${newsItem.ticker}` : newsItem.recommendation.action === 'sell' ? `Продать ${newsItem.ticker}` : `Держать ${newsItem.ticker}`}
            </button>
          </div>
        </div>

        <div class="chart-placeholder">
          <h3>График (заглушка)</h3>
          <img src="https://smart-lab.ru/uploads/2025/images/18/43/35/2025/03/01/fbf6cb1f98.png" alt="Stock Chart" class="chart-image" />
        </div>
      </div>
    </article>
  {/if}
</main>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');

  :global(body) {
    background-color: #1a1a1a;
    font-family: 'Inter', sans-serif;
  }

  .news-detail-container {
    max-width: 98%;
    margin: 2rem auto;
    padding: 0 1rem;
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

  .header-title-link {
    text-decoration: none;
    color: inherit;
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

  /* Add mobile responsiveness for header */
  @media (max-width: 600px) {
    .header-content {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }
    .header-left h1 {
      font-size: 1.5rem;
    }
    .subtitle {
      font-size: 0.9rem;
    }
  }

  @media (max-width: 400px) {
    .header-left h1 {
      font-size: 1.3rem;
    }
    .subtitle {
      font-size: 0.8rem;
    }
  }

  .news-detail-card {
    background: #242424;
    padding: 2rem;
    border-radius: 12px;
    border: 1px solid #333;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  }

  .news-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    font-size: 0.85rem;
    flex-wrap: wrap;
  }

  .news-meta {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
  }

  .ticker {
    font-weight: 600;
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    white-space: nowrap;
  }

  .news-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.4rem;
  }

  .news-tag {
    font-weight: 600;
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    white-space: nowrap;
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

  .time {
    color: #a0a0a0;
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .source {
    color: #a0a0a0;
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .news-detail-title {
    font-size: 2.2rem;
    color: #ffffff;
    margin-bottom: 1rem;
    line-height: 1.3;
  }

  .news-summary {
    font-size: 1rem;
    color: #a0a0a0;
    margin-bottom: 1.5rem;
    line-height: 1.6;
  }

  .key-points {
    margin-bottom: 2rem;
  }

  .key-points h3 {
    color: #ffdd2d;
    font-size: 1.2rem;
    margin-bottom: 0.8rem;
  }

  .key-points ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .key-points li {
    margin-bottom: 0.5rem;
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    color: #ffffff;
  }

  .key-points li:before {
    content: "•";
    color: #ffdd2d;
    font-size: 1.2em;
    line-height: 1;
  }

  .recommendation-and-chart-container {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    margin-top: 2rem;
    justify-content: space-between;
    width: 100%;
  }

  .recommendation-detail,
  .chart-placeholder {
    flex: none;
    width: calc(50% - 0.5rem);
    box-sizing: border-box;
  }

  .recommendation-detail {
    background: #2a2a2a;
    padding: 1.5rem;
    border-radius: 10px;
    border: 1px solid #333;
    margin-bottom: 0;
  }

  .recommendation-detail h4 {
    color: #ffdd2d;
    margin-bottom: 1.5rem;
    font-size: 1.1rem;
    text-align: center;
  }

  .confidence-meter {
    background: #333;
    height: 12px;
    border-radius: 6px;
    margin: 0.5rem 0 0.25rem 0;
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
    font-size: 0.85rem;
    color: #a0a0a0;
    margin-top: 1rem;
    text-align: center;
    display: block;
  }

  .reasoning {
    font-size: 0.95rem;
    color: #ffffff;
    margin: 1rem 0;
    line-height: 1.5;
    text-align: center;
  }

  .action-buttons {
    margin-top: 1.5rem;
    text-align: center;
  }

  .action-button {
    padding: 0.8rem 2rem;
    background-color: #ffdd2d;
    color: #1a1a1a;
    border: none;
    border-radius: 25px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.2s, transform 0.2s;
  }

  .action-button:hover {
    background-color: #ffe766;
    transform: translateY(-2px);
  }

  .chart-placeholder {
    background: #2a2a2a;
    padding: 2rem;
    border-radius: 10px;
    border: 1px solid #333;
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: #a0a0a0;
  }

  .chart-image {
    max-width: 100%;
    height: auto;
    margin-top: 0.5rem;
    border-radius: 8px;
  }

  .chart-placeholder h3 {
    color: #ffdd2d;
    margin-bottom: 1rem;
  }

  .full-text {
    margin-bottom: 1.5rem;
    line-height: 1.7;
    color: #e0e0e0;
  }

  .full-text p {
    margin-bottom: 1rem;
  }
</style> 