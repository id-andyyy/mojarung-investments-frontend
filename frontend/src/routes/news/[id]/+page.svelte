<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { get } from 'svelte/store';

  let newsId: string = '';
  let newsItem: any = null;
  let isLoading = true;
  let error: string | null = null;

  onMount(async () => {
    newsId = get(page).params.id;
    isLoading = true;
    error = null;
    try {
      const response = await fetch(`/api/news/${newsId}`);
      if (!response.ok) {
        throw new Error('Новость не найдена');
      }
      newsItem = await response.json();
    } catch (e: any) {
      error = e.message || 'Ошибка загрузки новости';
    } finally {
      isLoading = false;
    }
  });
</script>

<main class="news-detail-container">
  {#if isLoading}
    <div class="loading">Загрузка новости...</div>
  {:else if error}
    <div class="error">{error}</div>
  {:else if newsItem}
    <article class="news-detail-card">
      <div class="news-header">
        <span class="ticker">{newsItem.ticker}</span>
        <span class="source">{newsItem.source}</span>
        <span class="time">{new Date(newsItem.created_at).toLocaleString()}</span>
      </div>
      <h1 class="news-detail-title">{newsItem.title}</h1>
      <p class="news-summary">{newsItem.summary}</p>
      {#if newsItem.tags && newsItem.tags.length > 0}
        <div class="news-tags">
          {#each newsItem.tags as tag}
            <span class="news-tag">{tag}</span>
          {/each}
        </div>
      {/if}
      <div class="key-points">
        <h3>Ключевые моменты:</h3>
        <ul>
          {#each newsItem.summary?.split('. ') as point (point)}
            {#if point}
              <li>{point}</li>
            {/if}
          {/each}
        </ul>
      </div>
    </article>
  {/if}
</main>

<style>
.news-detail-container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 1rem;
}
.news-detail-card {
  background: #242424;
  padding: 2rem;
  border-radius: 12px;
  border: 1px solid #333;
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}
.news-header {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  font-size: 0.95rem;
  color: #ffdd2d;
}
.ticker {
  font-weight: 600;
}
.source, .time {
  color: #a0a0a0;
}
.news-detail-title {
  font-size: 2rem;
  color: #fff;
  margin-bottom: 1rem;
}
.news-summary {
  color: #a0a0a0;
  margin-bottom: 1rem;
}
.news-tags {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
.news-tag {
  background: rgba(255,221,45,0.1);
  color: #ffdd2d;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.9rem;
}
.key-points h3 {
  color: #ffdd2d;
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
}
.key-points ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.key-points li {
  margin-bottom: 0.4rem;
  color: #fff;
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}
.loading, .error {
  text-align: center;
  color: #a0a0a0;
  margin: 2rem 0;
}
.error {
  color: #ff3e00;
}
</style> 