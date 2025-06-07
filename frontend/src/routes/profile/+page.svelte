<script lang="ts">
  // Mock user data
  const userData = {
    name: 'Иван Петров',
    email: 'ivan.petrov@example.com',
    balance: '1,234,567',
    portfolio: [
      { ticker: 'LKOH', amount: 100, value: '7,890,000' },
      { ticker: 'SBER', amount: 500, value: '12,345,000' },
      { ticker: 'GAZP', amount: 1000, value: '15,678,000' }
    ],
    settings: {
      token: 'your-api-token-here',
      language: 'ru',
      interestTags: ['нефть', 'газ', 'банки', 'технологии']
    }
  };

  let newPassword = '';
  let confirmPassword = '';
  let newTag = '';

  function addTag() {
    if (newTag && !userData.settings.interestTags.includes(newTag)) {
      userData.settings.interestTags = [...userData.settings.interestTags, newTag];
      newTag = '';
    }
  }

  function removeTag(tag: string) {
    userData.settings.interestTags = userData.settings.interestTags.filter(t => t !== tag);
  }

  function resetHistory() {
    // Здесь будет логика сброса истории
    alert('История действий сброшена');
  }
</script>

<main class="profile-container">
  <div class="profile-header">
    <h1>Профиль</h1>
    <a href="/" class="back-button">← Назад</a>
  </div>

  <div class="profile-content">
    <div class="profile-card">
      <div class="profile-info">
        <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix" alt="Profile" class="profile-avatar" />
        <div class="user-details">
          <h2>{userData.name}</h2>
          <p class="email">{userData.email}</p>
        </div>
      </div>

      <div class="balance-section">
        <h3>Баланс</h3>
        <div class="balance-amount">₽ {userData.balance}</div>
      </div>

      <div class="portfolio-section">
        <h3>Портфель</h3>
        <div class="portfolio-list">
          {#each userData.portfolio as item}
            <div class="portfolio-item">
              <span class="ticker">{item.ticker}</span>
              <span class="amount">{item.amount} шт.</span>
              <span class="value">₽ {item.value}</span>
            </div>
          {/each}
        </div>
      </div>

      <div class="settings-section">
        <h3>Настройки</h3>
        <div class="settings-list">
          <div class="setting-item">
            <span>API Токен</span>
            <input type="text" value={userData.settings.token} class="token-input" />
          </div>

          <div class="password-section">
            <h4>Смена пароля</h4>
            <div class="password-inputs">
              <input type="password" bind:value={newPassword} placeholder="Новый пароль" />
              <input type="password" bind:value={confirmPassword} placeholder="Подтвердите пароль" />
            </div>
          </div>

          <div class="tags-section">
            <h4>Интересующие теги</h4>
            <div class="tags-input">
              <input type="text" bind:value={newTag} placeholder="Добавить тег" />
              <button on:click={addTag} class="add-tag-button">+</button>
            </div>
            <div class="tags-list">
              {#each userData.settings.interestTags as tag}
                <div class="tag-item">
                  <span>{tag}</span>
                  <button on:click={() => removeTag(tag)} class="remove-tag-button">×</button>
                </div>
              {/each}
            </div>
          </div>

          <div class="setting-item">
            <span>Язык</span>
            <select value={userData.settings.language}>
              <option value="ru">Русский</option>
              <option value="en">English</option>
            </select>
          </div>

          <button on:click={resetHistory} class="reset-button">
            Сбросить историю действий
          </button>
        </div>
      </div>
    </div>
  </div>
</main>

<style>
  .profile-container {
    max-width: 800px;
    margin: 2rem auto;
    padding: 0 1rem;
  }

  .profile-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(255, 221, 45, 0.1);
  }

  h1 {
    color: #ffdd2d;
    font-size: 2.2rem;
    margin: 0;
    font-weight: 700;
    text-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
  }

  .back-button {
    color: #a0a0a0;
    text-decoration: none;
    font-size: 1rem;
    transition: all 0.2s;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.05);
  }

  .back-button:hover {
    color: #ffdd2d;
    background: rgba(255, 221, 45, 0.1);
  }

  .profile-card {
    background: linear-gradient(145deg, #242424, #2a2a2a);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 2rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  }

  .profile-info {
    display: flex;
    align-items: center;
    gap: 2rem;
    margin-bottom: 2.5rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .profile-avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: 3px solid #ffdd2d;
    box-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
    transition: transform 0.3s;
  }

  .profile-avatar:hover {
    transform: scale(1.05);
  }

  .user-details h2 {
    color: #ffffff;
    margin: 0 0 0.5rem 0;
    font-size: 1.8rem;
    font-weight: 600;
  }

  .email {
    color: #a0a0a0;
    margin: 0;
    font-size: 1rem;
  }

  .balance-section {
    margin-bottom: 2.5rem;
    padding: 1.5rem;
    background: rgba(255, 221, 45, 0.05);
    border-radius: 12px;
    border: 1px solid rgba(255, 221, 45, 0.1);
  }

  h3 {
    color: #ffdd2d;
    font-size: 1.3rem;
    margin-bottom: 1rem;
    font-weight: 600;
  }

  .balance-amount {
    font-size: 2.5rem;
    font-weight: 700;
    color: #ffdd2d;
    text-shadow: 0 0 20px rgba(255, 221, 45, 0.2);
  }

  .portfolio-section {
    margin-bottom: 2.5rem;
  }

  .portfolio-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .portfolio-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.2rem;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    transition: all 0.2s;
  }

  .portfolio-item:hover {
    background: rgba(255, 255, 255, 0.05);
    transform: translateX(5px);
  }

  .ticker {
    font-weight: 600;
    color: #ffdd2d;
    font-size: 1.1rem;
  }

  .amount {
    color: #ffffff;
    font-size: 1rem;
  }

  .value {
    color: #4caf50;
    font-weight: 600;
    font-size: 1.1rem;
  }

  .settings-list {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.2rem;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.05);
  }

  .setting-item span {
    color: #ffffff;
    font-size: 1.1rem;
  }

  .token-input {
    background: rgba(0, 0, 0, 0.2);
    color: #ffffff;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 0.8rem;
    border-radius: 8px;
    width: 300px;
    font-size: 1rem;
    transition: all 0.2s;
  }

  .token-input:focus {
    border-color: #ffdd2d;
    outline: none;
    box-shadow: 0 0 0 2px rgba(255, 221, 45, 0.2);
  }

  .password-section {
    margin: 1.5rem 0;
    padding: 1.5rem;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.05);
  }

  .password-section h4 {
    color: #ffffff;
    margin-bottom: 1rem;
    font-size: 1.1rem;
    font-weight: 600;
  }

  .password-inputs {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .password-inputs input {
    background: rgba(0, 0, 0, 0.2);
    color: #ffffff;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 0.8rem;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s;
  }

  .password-inputs input:focus {
    border-color: #ffdd2d;
    outline: none;
    box-shadow: 0 0 0 2px rgba(255, 221, 45, 0.2);
  }

  .tags-section {
    margin: 1.5rem 0;
    padding: 1.5rem;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.05);
  }

  .tags-section h4 {
    color: #ffffff;
    margin-bottom: 1rem;
    font-size: 1.1rem;
    font-weight: 600;
  }

  .tags-input {
    display: flex;
    gap: 0.8rem;
    margin-bottom: 1rem;
  }

  .tags-input input {
    flex: 1;
    background: rgba(0, 0, 0, 0.2);
    color: #ffffff;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 0.8rem;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s;
  }

  .tags-input input:focus {
    border-color: #ffdd2d;
    outline: none;
    box-shadow: 0 0 0 2px rgba(255, 221, 45, 0.2);
  }

  .add-tag-button {
    background: #ffdd2d;
    color: #1a1a1a;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 8px;
    font-size: 1.5rem;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
  }

  .add-tag-button:hover {
    transform: scale(1.05);
    box-shadow: 0 0 20px rgba(255, 221, 45, 0.3);
  }

  .tags-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.8rem;
  }

  .tag-item {
    background: rgba(255, 221, 45, 0.1);
    padding: 0.5rem 1rem;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 0.8rem;
    border: 1px solid rgba(255, 221, 45, 0.2);
    transition: all 0.2s;
  }

  .tag-item:hover {
    background: rgba(255, 221, 45, 0.15);
    transform: translateY(-2px);
  }

  .remove-tag-button {
    background: none;
    border: none;
    color: #a0a0a0;
    cursor: pointer;
    font-size: 1.2rem;
    padding: 0;
    line-height: 1;
    transition: color 0.2s;
  }

  .remove-tag-button:hover {
    color: #ff3e00;
  }

  .reset-button {
    background: linear-gradient(145deg, #ff3e00, #ff5c2e);
    color: #ffffff;
    border: none;
    padding: 1rem 2rem;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 1.1rem;
    margin-top: 2rem;
    width: 100%;
    transition: all 0.2s;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .reset-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(255, 62, 0, 0.3);
  }

  .setting-item select {
    background: rgba(0, 0, 0, 0.2);
    color: #ffffff;
    border: 1px solid rgba(255, 255, 255, 0.1);
    padding: 0.8rem;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s;
    cursor: pointer;
  }

  .setting-item select:focus {
    border-color: #ffdd2d;
    outline: none;
    box-shadow: 0 0 0 2px rgba(255, 221, 45, 0.2);
  }

  .setting-item select option {
    background: #1a1a1a;
    color: #ffffff;
  }
</style> 