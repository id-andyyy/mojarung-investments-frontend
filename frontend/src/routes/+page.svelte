<script lang="ts">
  import { api } from '$lib/api';
  import { onMount } from 'svelte';

  let count = 0;
  let name = '';
  let apiData: any = null;
  let error: string | null = null;

  function increment() {
    count += 1;
  }

  async function fetchData() {
    try {
      // Пример использования API
      // apiData = await api.get('/docs');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Произошла ошибка';
    }
  }

  onMount(() => {
    fetchData();
  });
</script>

<main class="container">
  <h1>Добро пожаловать в Svelte приложение!</h1>
  
  <div class="card">
    <h2>Тестовая страница</h2>
    
    <div class="input-group">
      <label for="name">Введите ваше имя:</label>
      <input 
        type="text" 
        id="name" 
        bind:value={name} 
        placeholder="Ваше имя"
      />
    </div>

    {#if name}
      <p>Привет, {name}!</p>
    {/if}

    <div class="counter">
      <p>Счетчик: {count}</p>
      <button on:click={increment}>
        Увеличить
      </button>
    </div>

    {#if error}
      <div class="error">
        {error}
      </div>
    {/if}

    {#if apiData}
      <div class="api-data">
        <pre>{JSON.stringify(apiData, null, 2)}</pre>
      </div>
    {/if}
  </div>
</main>

<style>
  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    text-align: center;
  }

  h1 {
    color: #ff3e00;
    font-size: 2.5rem;
    margin-bottom: 2rem;
  }

  .card {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .input-group {
    margin: 1.5rem 0;
  }

  label {
    display: block;
    margin-bottom: 0.5rem;
    color: #333;
  }

  input {
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 4px;
    width: 100%;
    max-width: 300px;
  }

  .counter {
    margin-top: 2rem;
  }

  button {
    background: #ff3e00;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background 0.2s;
  }

  button:hover {
    background: #ff5e2a;
  }

  p {
    color: #333;
    line-height: 1.5;
  }

  .error {
    color: #ff0000;
    margin-top: 1rem;
    padding: 0.5rem;
    background: #fff0f0;
    border-radius: 4px;
  }

  .api-data {
    margin-top: 1rem;
    text-align: left;
    background: #f5f5f5;
    padding: 1rem;
    border-radius: 4px;
    overflow-x: auto;
  }

  pre {
    margin: 0;
    white-space: pre-wrap;
  }
</style> 