<script lang="ts">
  import { onMount } from 'svelte';
  import Chart from 'chart.js/auto'; // Импортируем Chart.js

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
      fullText: 'ЛУКОЙЛ, одна из крупнейших нефтяных компаний России, объявила о рекордной прибыли по итогам последнего финансового квартала. Согласно официальным данным, прибыль компании выросла на 25% по сравнению с предыдущим кварталом, что значительно превзошло ожидания аналитиков. Этот рост обусловлен благоприятной конъюнктурой мирового рынка нефти, а также эффективной оптимизацией внутренних бизнес-процессов. Компания также намекнула на возможное увеличение дивидендов для акционеров, что вызвало позитивную реакцию на рынке. В дополнение к этому, ЛУКОЙЛ активно развивает новые проекты в Арктическом регионе, что обещает долгосрочные перспективы роста и укрепление позиций на глобальном энергетическом рынке.',
      chartData: [
        { date: '2024-03-01', value: 100 },
        { date: '2024-03-05', value: 105 },
        { date: '2024-03-10', value: 110 },
        { date: '2024-03-15', value: 108 },
        { date: '2024-03-20', value: 115 }
      ]
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
      fullText: 'Сбербанк, крупнейший банк России, представил новую инновационную программу, разработанную специально для розничных инвесторов. В рамках этой программы банк запускает передового ИИ-ассистента, который будет помогать трейдерам принимать обоснованные решения, анализируя огромные объемы данных в реальном времени. Одним из ключевых преимуществ новой программы является снижение комиссий на 30%, что делает инвестиции более доступными для широкого круга клиентов. Кроме того, инвесторы получат эксклюзивный доступ к премиум-аналитике и исследованиям рынка от ведущих экспертов Сбербанка, что позволит им быть в курсе последних тенденций и принимать более информированные решения.',
      chartData: [
        { date: '2024-03-01', value: 200 },
        { date: '2024-03-05', value: 202 },
        { date: '2024-03-10', value: 205 },
        { date: '2024-03-15', value: 203 },
        { date: '2024-03-20', value: 207 }
      ]
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
      fullText: 'Газпром, ведущая российская газовая компания, объявила о пересмотре своих планов по добыче газа на текущий год. В связи с изменением рыночной ситуации и геополитических факторов, компания снизила прогноз по добыче на 15%. Это решение является частью более широкой стратегии по адаптации к новым реалиям на мировом энергетическом рынке. Газпром также подтвердил свои намерения по переориентации поставок газа на азиатские рынки, активно развивая инфраструктуру и налаживая новые партнерские отношения в этом регионе. Тем не менее, некоторые новые проекты по добыче газа были отложены на неопределенный срок, что может повлиять на долгосрочные перспективы компании.',
      chartData: [
        { date: '2024-03-01', value: 50 },
        { date: '2024-03-05', value: 48 },
        { date: '2024-03-10', value: 45 },
        { date: '2024-03-15', value: 47 },
        { date: '2024-03-20', value: 42 }
      ]
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
      fullText: 'Яндекс, российский технологический гигант, анонсировал запуск целого ряда новых сервисов, ориентированных на бизнес-сектор. В рамках расширения линейки B2B-продуктов компания представила новую облачную платформу, которая предоставит предприятиям доступ к масштабируемым вычислительным ресурсам и передовым инструментам для анализа данных. Также было объявлено об интеграции с Тинькофф, что позволит клиентам пользоваться бесшовными финансовыми услугами прямо внутри платформы Яндекса. В дополнение к этому, Яндекс вводит новые, более гибкие тарифные планы для малого и среднего бизнеса, что сделает их продукты и сервисы более доступными и привлекательными для широкого круга компаний.',
      chartData: [
        { date: '2024-03-01', value: 300 },
        { date: '2024-03-05', value: 305 },
        { date: '2024-03-10', value: 303 },
        { date: '2024-03-15', value: 308 },
        { date: '2024-03-20', value: 310 }
      ]
    }
  ];

  let newsItem: any = mockNews[0]; // Выбираем первую новость для демонстрации
  let isLoading = false; // Не загружаем, так как данные уже есть
  let error: string | null = null;

  // Функция для обработки нажатия кнопки покупки/продажи (заглушка)
  function handleAction(action: string, ticker: string) {
    alert(`${action} ${ticker}`);
  }

  let chartInstance: Chart | null = null;

  // Add chat message interface
  interface ChatMessage {
    text: string;
    sender: 'user' | 'bot';
  }

  // Add chat bot state
  let isChatOpen = false;
  let chatMessages: ChatMessage[] = [];
  let newMessage = '';

  function toggleChat() {
    isChatOpen = !isChatOpen;
  }

  function sendMessage() {
    if (newMessage.trim()) {
      chatMessages = [...chatMessages, { text: newMessage, sender: 'user' }];
      // Here you would typically send the message to your backend
      // For now, we'll just simulate a response
      setTimeout(() => {
        chatMessages = [...chatMessages, { 
          text: 'Это демо-ответ от чат-бота. В будущем здесь будет реальный ответ от ИИ.', 
          sender: 'bot' 
        }];
      }, 1000);
      newMessage = '';
    }
  }

  onMount(() => {
    // Проверяем, что newsItem.chartData существует и содержит данные
    if (newsItem && newsItem.chartData && newsItem.chartData.length > 0) {
      const ctx = document.getElementById('stockChartCanvas') as HTMLCanvasElement;
      if (ctx) {
        // Деструктурируем данные для Chart.js
        const labels = newsItem.chartData.map((d: { date: string; }) => new Date(d.date).toLocaleDateString('ru-RU', { month: 'short', day: 'numeric' }));
        const values = newsItem.chartData.map((d: { value: any; }) => d.value);

        if (chartInstance) {
          chartInstance.destroy(); // Уничтожаем предыдущий экземпляр графика, если он есть
        }

        chartInstance = new Chart(ctx, {
          type: 'line',
          data: {
            labels: labels,
            datasets: [{
              label: newsItem.ticker || 'Стоимость',
              data: values,
              borderColor: '#ffdd2d',
              backgroundColor: 'rgba(255, 221, 45, 0.2)',
              tension: 0.4,
              fill: true,
              pointRadius: 3,
              pointBackgroundColor: '#ffdd2d',
              pointBorderColor: '#fff',
              pointHoverRadius: 5,
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: '#ffdd2d'
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false // Скрываем легенду
              }
            },
            scales: {
              x: {
                grid: {
                  color: '#333' // Цвет сетки X-оси
                },
                ticks: {
                  color: '#a0a0a0' // Цвет меток X-оси
                }
              },
              y: {
                grid: {
                  color: '#333' // Цвет сетки Y-оси
                },
                ticks: {
                  color: '#a0a0a0' // Цвет меток Y-оси
                }
              }
            }
          }
        });
      }
    } else {
      console.warn("Отсутствуют данные chartData для отрисовки графика.");
    }
  });

  // Обновляем график при изменении newsItem (если это требуется для динамической загрузки)
  // $: if (newsItem) {
  //   // Код для обновления графика здесь
  // }
</script>

<main class="news-detail-container">
  <!-- Chat Bot Button -->
  <div class="chat-bot-button" on:click={toggleChat}>
    <img src="/bik3.png" alt="Chat Bot" class="chat-bot-icon" />
  </div>

  <!-- Chat Window -->
  {#if isChatOpen}
    <div class="chat-window">
      <div class="chat-header">
        <h3>Чат с ИИ-ассистентом</h3>
        <button class="close-button" on:click={toggleChat}>×</button>
      </div>
      <div class="chat-messages">
        {#each chatMessages as message}
          <div class="message {message.sender}">
            {message.text}
          </div>
        {/each}
      </div>
      <div class="chat-input">
        <input 
          type="text" 
          bind:value={newMessage} 
          placeholder="Введите сообщение..."
          on:keydown={(e) => e.key === 'Enter' && sendMessage()}
        />
        <button on:click={sendMessage}>Отправить</button>
      </div>
    </div>
  {/if}

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
            <div class="sentiment-circle"></div>
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
          <h3>График</h3>
          <canvas id="stockChartCanvas"></canvas>
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

  /* Add mobile responsiveness for header */
  @media (max-width: 600px) {
    .header-content {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }
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
    white-space: nowrap;
  }

  .news-tags {
    display: flex;
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

  .sentiment-circle {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background-color: #a0a0a0; /* Neutral/default color */
  }

  .sentiment.positive .sentiment-circle {
    background-color: #4caf50; /* Green for positive sentiment */
  }

  .sentiment.negative .sentiment-circle {
    background-color: #f44336; /* Red for negative sentiment */
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
    display: grid;
    gap: 1rem;
    margin-top: 2rem;
    width: 100%;
    align-items: stretch;
    grid-template-columns: 1fr 1fr;
  }

  .recommendation-detail,
  .chart-placeholder {
    box-sizing: border-box;
    height: 100%;
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

  .chart-placeholder h3 {
    color: #ffdd2d;
    margin-bottom: 1rem; /* Adjust as needed */
  }

  .stock-chart {
    width: 100%;
    height: 100%;
    overflow: visible; /* Allow labels to extend outside viewBox */
  }

  .stock-chart line {
    stroke: #555; /* Lighter color for grid lines */
    stroke-width: 1;
  }

  .stock-chart text {
    fill: #a0a0a0;
    font-size: 0.7rem;
  }

  .full-text {
    margin-bottom: 1.5rem;
    line-height: 1.7;
    color: #e0e0e0;
  }

  .full-text p {
    margin-bottom: 1rem;
  }

  /* Стили для Chart.js canvas */
  canvas#stockChartCanvas {
    max-width: 100%;
    max-height: 250px; /* Ограничиваем максимальную высоту канваса */
    height: auto; /* Позволяет канвасу регулировать высоту */
  }

  .chat-bot-button {
    position: fixed;
    right: 1rem;
    bottom: 2rem;
    width: 80px;
    height: 80px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: transform 0.2s ease;
    z-index: 1000;
    padding: 0;
    border: none;
    background: none;
    filter: drop-shadow(0 0 8px rgba(255, 221, 45, 0.4));
  }

  .chat-bot-button:hover {
    transform: scale(1.1);
    filter: drop-shadow(0 0 12px rgba(255, 221, 45, 0.8));
  }

  .chat-bot-icon {
    width: 70px;
    height: 70px;
    object-fit: contain;
    background: none;
    mix-blend-mode: multiply;
  }

  .chat-window {
    position: fixed;
    right: 4rem;
    bottom: 4rem;
    width: 350px;
    height: 500px;
    background-color: #242424;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    display: flex;
    flex-direction: column;
    z-index: 1000;
    border: 1px solid #333;
  }

  .chat-header {
    padding: 1rem;
    background-color: #2a2a2a;
    border-radius: 12px 12px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #333;
  }

  .chat-header h3 {
    margin: 0;
    color: #ffdd2d;
    font-size: 1.1rem;
  }

  .close-button {
    background: none;
    border: none;
    color: #a0a0a0;
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0;
    line-height: 1;
  }

  .close-button:hover {
    color: #ffffff;
  }

  .chat-messages {
    flex-grow: 1;
    padding: 1rem;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 1rem;
    
  }

  .message {
    max-width: 80%;
    padding: 0.8rem 1rem;
    border-radius: 12px;
    font-size: 0.9rem;
    line-height: 1.4;
  }

  .message.user {
    background-color: #ffdd2d;
    color: #1a1a1a;
    align-self: flex-end;
    border-bottom-right-radius: 4px;
  }

  .message.bot {
    background-color: #2a2a2a;
    color: #ffffff;
    align-self: flex-start;
    border-bottom-left-radius: 4px;
  }

  .chat-input {
    padding: 1rem;
    border-top: 1px solid #333;
    display: flex;
    gap: 0.5rem;
  }

  .chat-input input {
    flex-grow: 1;
    padding: 0.8rem;
    border: 1px solid #333;
    border-radius: 8px;
    background-color: #2a2a2a;
    color: #ffffff;
    font-size: 0.9rem;
  }

  .chat-input input:focus {
    outline: none;
    border-color: #ffdd2d;
  }

  .chat-input button {
    padding: 0.8rem 1.2rem;
    background-color: #ffdd2d;
    color: #1a1a1a;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .chat-input button:hover {
    background-color: #ffe766;
  }

  /* Add responsive styles for chat */
  @media (max-width: 600px) {
    .chat-window {
      width: calc(100% - 2rem);
      height: 60vh;
      right: 1rem;
      bottom: 5rem;
    }

    .chat-bot-button {
      right: 1rem;
      bottom: 1rem;
    }
  }
</style> 