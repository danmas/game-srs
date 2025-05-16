import Phaser from 'phaser';
import { MainScene } from './scenes/MainScene';
import { Settings } from './utils/Settings';

// Создаем стили для контейнера игры
document.body.style.backgroundColor = '#333333'; // Темно-серый для всей страницы
const styleElement = document.createElement('style');
styleElement.textContent = `
  #game-container {
    margin: 0 auto;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
  }
  canvas {
    display: block;
    background-color: #0000FF !important; /* Принудительно устанавливаем синий цвет */
  }
`;
document.head.appendChild(styleElement);

// Конфигурация игры
const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: Settings.SCREEN_WIDTH,
  height: Settings.SCREEN_HEIGHT,
  backgroundColor: '#0000FF', // Яркий синий фон
  parent: 'game-container',
  physics: {
    default: 'arcade',
    arcade: {
      debug: Settings.DEBUG
    }
  },
  scene: [MainScene],
  render: {
    pixelArt: false,
    antialias: true,
    transparent: false, // Отключаем прозрачность, чтобы фон был видимым
  }
};

// Создаем игру
const game = new Phaser.Game(config);

// Экспортируем для доступа из других модулей
export default game; 