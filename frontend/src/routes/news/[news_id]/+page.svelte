<script lang="ts">
  import { onMount } from 'svelte';
  import Chart from 'chart.js/auto'; // Импортируем Chart.js
  import { page } from '$app/stores'; // Import page store to get URL parameters

  let newsItem: any = null; // Initialize as null, will be populated from API
  let isLoading = true; // Set to true initially for loading state
  let error: string | null = null;

  // Function to process backend news data for Chart.js and other UI elements
  function processNewsData(data: any) {
    console.log('Начало обработки данных новости:', data);
    
    // Assuming tags and tickers come as comma-separated strings if not an array
    if (typeof data.tags === 'string' && data.tags.trim() !== '') {
      console.log('Обработка тегов из строки:', data.tags);
      data.tags = data.tags.split(',').map((tag: string) => tag.trim());
      console.log('Теги после обработки:', data.tags);
    } else {
      console.log('Теги отсутствуют или не являются строкой, устанавливаем пустой массив');
      data.tags = []; // Ensure it's an array, even if empty
    }
    
    // For ticker, if it comes as part of tickers string, take the first one or default
    if (typeof data.tickers === 'string' && data.tickers.trim() !== '') {
      console.log('Обработка тикеров из строки:', data.tickers);
      const tickersArray = data.tickers.split(',').map((t: string) => t.trim());
      data.ticker = tickersArray.length > 0 ? tickersArray[0] : '';
      console.log('Выбранный тикер:', data.ticker);
    } else {
      console.log('Тикеры отсутствуют или не являются строкой, устанавливаем пустой тикер');
      data.ticker = ''; // Default empty ticker
    }

    // Map 'is_positive' to 'sentiment' for existing UI logic
    console.log('Преобразование is_positive в sentiment:', data.is_positive);
    data.sentiment = data.is_positive ? 'positive' : 'negative';
    console.log('Результат sentiment:', data.sentiment);

    // Placeholder for chartData if not provided by the backend.
    if (!data.chartData || data.chartData.length === 0) {
      console.log('Данные для графика отсутствуют, используем тестовые данные');
      data.chartData = [
        { date: '2024-03-01', value: 100 },
        { date: '2024-03-05', value: 105 },
        { date: '2024-03-10', value: 110 },
        { date: '2024-03-15', value: 108 },
        { date: '2024-03-20', value: 115 }
      ];
    } else {
      console.log('Используем предоставленные данные для графика:', data.chartData);
    }

    console.log('Итоговые обработанные данные:', data);
    return data;
  }

  async function fetchNews(newsId: string) {
    console.log('Начало загрузки новости с ID:', newsId);
    isLoading = true;
    error = null;
    
    try {
      const token = localStorage.getItem('access_token');
      if (!token) {
        console.error('Токен доступа не найден в localStorage');
        throw new Error('No access token found. Please log in.');
      }
      console.log('Токен доступа получен');

      console.log('Отправка запроса к API:', `http://localhost:8000/api/news/${newsId}`);
      const response = await fetch(`http://localhost:8000/api/news/${newsId}`, {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        console.error('Ошибка при получении ответа:', response.status, response.statusText);
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Failed to fetch news item.');
      }

      console.log('Успешный ответ от API');
      let data = await response.json();
      console.log('Полученные данные:', data);
      
      newsItem = processNewsData(data); // Process data before assigning
      console.log('Данные обработаны и сохранены в newsItem');
    } catch (e: any) {
      console.error('Ошибка при загрузке новости:', e);
      error = e.message;
    } finally {
      isLoading = false;
      console.log('Загрузка завершена, isLoading =', isLoading);
    }
  }

  // Функция для обработки нажатия кнопки покупки/продажи (заглушка)
  function handleAction(action: string, ticker: string) {
    console.log('Обработка действия:', action, 'для тикера:', ticker);
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
    console.log('Переключение состояния чата:', !isChatOpen);
    isChatOpen = !isChatOpen;
  }

  function sendMessage() {
    if (newMessage.trim()) {
      console.log('Отправка сообщения:', newMessage);
      chatMessages = [...chatMessages, { text: newMessage, sender: 'user' }];
      // Here you would typically send the message to your backend
      // For now, we'll just simulate a response
      setTimeout(() => {
        console.log('Получен ответ от бота');
        chatMessages = [...chatMessages, { 
          text: 'Это демо-ответ от чат-бота. В будущем здесь будет реальный ответ от ИИ.', 
          sender: 'bot' 
        }];
      }, 1000);
      newMessage = '';
    }
  }

  // Function to initialize or update the chart
  function initializeChart() {
    console.log('Начало инициализации графика');
    if (newsItem && newsItem.chartData && newsItem.chartData.length > 0) {
      console.log('Данные для графика доступны:', newsItem.chartData);
      const ctx = document.getElementById('stockChartCanvas') as HTMLCanvasElement;
      if (ctx) {
        console.log('Canvas элемент найден');
        // Destroy existing chart if it exists
        if (chartInstance) {
          console.log('Удаление существующего графика');
          chartInstance.destroy();
        }

        // Деструктурируем данные для Chart.js
        const labels = newsItem.chartData.map((d: { date: string; }) => new Date(d.date).toLocaleDateString('ru-RU', { month: 'short', day: 'numeric' }));
        const values = newsItem.chartData.map((d: { value: any; }) => d.value);
        console.log('Подготовленные данные для графика:', { labels, values });

        console.log('Создание нового графика');
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
        console.log('График успешно создан');
      } else {
        console.error('Canvas элемент не найден');
      }
    } else {
      console.warn("Отсутствуют данные chartData для отрисовки графика");
    }
  }

  // Subscribe to page store changes
  $: if ($page.params.news_id) {
    console.log('Обнаружено изменение news_id в URL:', $page.params.news_id);
    fetchNews($page.params.news_id).then(() => {
      console.log('Данные загружены, инициализация графика');
      initializeChart();
    });
  }

  onMount(() => {
    console.log('Компонент смонтирован');
    // Initial fetch if news_id is present
    if ($page.params.news_id) {
      console.log('Начальная загрузка данных для news_id:', $page.params.news_id);
      fetchNews($page.params.news_id).then(() => {
        console.log('Начальные данные загружены, инициализация графика');
        initializeChart();
      });
    } else {
      console.warn('News ID не найден в URL');
      error = 'News ID not found in URL.';
      isLoading = false;
    }
  });
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
    color: #e0e0e0; /* Устанавливаем глобальный светлый цвет текста */
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
    color: #e0e0e0; /* Устанавливаем светлый цвет текста по умолчанию для всего блока */
  }

  .news-detail-card * {
    color: #e0e0e0 !important; /* Применяем светлый цвет ко всем элементам-потомкам с !important */
  }

  .news-detail-card p,
  .news-detail-card li {
    color: #e0e0e0 !important; /* Дополнительно устанавливаем светлый цвет для p и li с !important */
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
    color: #ffdd2d !important;
    background: #3d3d3d !important; /* Сплошной темный фон, как на изображении */
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
    color: #ffdd2d !important; /* Желтый текст, как у тикера */
    background: #3d3d3d !important; /* Сплошной темный фон, как у тикера */
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
  }

  .source {
    color: #a0a0a0;
    font-size: 0.8rem;
  }

  .news-detail-title {
    font-size: 2.2rem;
    color: #ffffff;
    margin-bottom: 1rem;
    line-height: 1.3;
  }

  .news-summary {
    font-size: 1rem;
    color: #e0e0e0;
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
    color: #e0e0e0 !important; /* Устанавливаем светлый цвет для элементов списка с !important */
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
    color: #1a1a1a !important; /* Устанавливаем черный цвет текста */
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

  .full-text {
    margin-bottom: 1.5rem;
    line-height: 1.7;
    color: #e0e0e0;
  }

  .full-text p {
    margin-bottom: 1rem;
    color: #e0e0e0 !important; /* Устанавливаем светлый цвет для параграфов внутри full-text с !important */
  }
</style> 