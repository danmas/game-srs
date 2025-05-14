import Phaser from 'phaser';
import { MainScene } from './scenes/MainScene';
import { Settings } from './utils/Settings';

// Конфигурация игры
const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: Settings.SCREEN_WIDTH,
  height: Settings.SCREEN_HEIGHT,
  backgroundColor: '#2c2cFF',
  parent: 'game-container',
  physics: {
    default: 'arcade',
    arcade: {
      debug: Settings.DEBUG
    }
  },
  scene: [MainScene]
};

// Создаем игру
const game = new Phaser.Game(config);

// Экспортируем для доступа из других модулей
export default game; 