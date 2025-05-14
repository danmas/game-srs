import Phaser from 'phaser';
import { Ship } from './Ship';
import { Constants } from '../utils/Constants';
import { Settings } from '../utils/Settings';

/**
 * Класс подводной лодки
 */
export class Submarine extends Ship {
  // Дополнительные свойства для подлодки
  public depth: number = 0;  // Глубина погружения
  public maxDepth: number = 300;  // Максимальная глубина
  public periscope: boolean = false;  // Поднят ли перископ
  
  /**
   * Конструктор
   * @param scene Сцена
   * @param x Начальная позиция X
   * @param y Начальная позиция Y
   * @param forces Принадлежность к силам (красные/белые)
   */
  constructor(scene: Phaser.Scene, x: number, y: number, forces: number = Constants.FORCES_WHITE) {
    super(scene, x, y, forces);
    
    // Увеличиваем максимальную скорость для подлодки
    this.maxVelocity = 40;
    
    // Уменьшаем размер для попадания
    this.sizeForHit = Settings.SHIP_HIT_SIZE * 0.8;
    
    // Увеличиваем запас торпед
    this.torpedoOnBoardI = 8;
    this.torpedoOnBoardII = 8;
    this.torpedoOnBoardIII = 8;
  }
  
  /**
   * Возвращает цвет рубки в зависимости от принадлежности
   */
  protected getConningTowerColor(): number {
    return this.forces === Constants.FORCES_RED ? 0xcc0000 : 0xdddddd;
  }
  
  /**
   * Переопределяем метод отрисовки подлодки
   * Использует методы Phaser 3 для графики и подход как при отрисовке порта
   */
  protected drawVehicle(): void {
    // Определяем имя текстуры в зависимости от принадлежности
    const textureName = this.forces === Constants.FORCES_RED ? 'submarine_red' : 'submarine_white';

    // Цвет зависит от принадлежности
    const mainColor = this.forces === Constants.FORCES_RED ? 
                     (this.underControl ? Constants.COLOR_LIGHT_RED : Constants.COLOR_DARK_RED) : 
                     (this.underControl ? Constants.COLOR_LIGHT_WHITE : Constants.COLOR_DARK_WHITE);

    // Создаем графику прямо через сцену
    const graphics = this.scene.add.graphics();
    
    // Очищаем графику
    graphics.clear();
    
    // В зависимости от того, под управлением или нет, рисуем по-разному
    if (this.underControl) {
      // Подробное представление для подлодки под управлением игрока
      // Масштабируем с оригинальной версии
      const scale = 15; //2.5;
      
      // Базовые размеры из оригинала
      const bh = 14 * scale;      // высота корпуса
      const bw = 3 * scale;       // ширина корпуса
      const sh = bw / 2;          // сдвиг
      
      const halfWidth = bw / 2;
      const halfHeight = bh / 2;
      
      // Рисуем корпус подлодки
      graphics.fillStyle(mainColor, 1);
      graphics.lineStyle(1, mainColor, 1);
      
      // Прямоугольник
      graphics.fillRect(-halfWidth, -halfHeight, bw, bh);
      
      // Скругленные углы для верхней части
      graphics.fillCircle(-halfWidth, -halfHeight, halfWidth);
      graphics.fillCircle(halfWidth, -halfHeight, halfWidth);
      
      // Треугольный хвост
      graphics.beginPath();
      graphics.moveTo(-halfWidth, halfHeight);
      graphics.lineTo(0, halfHeight + bw);
      graphics.lineTo(halfWidth, halfHeight);
      graphics.closePath();
      graphics.fillPath();
      
      // Рисуем перископ, если он поднят
      if (this.periscope) {
        graphics.fillStyle(0x0f0f0f, 1);
        graphics.lineStyle(1, 0x0f0f0f, 1);
        const rh = 3 * scale;
        const rw = 1 * scale;
        graphics.fillEllipse(0, -halfHeight / 2, rw, rh);
      }
    } else {
      // Упрощенное представление для ИИ-подлодок - прямоугольник с синим заполнением
      graphics.lineStyle(2, mainColor, 1);
      
      // Прямоугольник с синим заполнением
      graphics.fillStyle(0x0000FF, 0.5);
      graphics.fillRect(-10, -10, 20, 20);
      graphics.strokeRect(-10, -10, 20, 20);
    }
    
    // Создаем текстуру из графики
    graphics.generateTexture(textureName, 50, 50);
    
    // Удаляем временную графику, чтобы не засорять память
    graphics.destroy();
    
    // Устанавливаем текстуру и размер
    this.setTexture(textureName);
    this.setDisplaySize(50, 50);
  }
  
  /**
   * Устанавливает глубину погружения
   * @param newDepth Новая глубина
   */
  public setSubmDepth(newDepth: number): void {
    // Ограничиваем глубину допустимыми пределами
    this.depth = Phaser.Math.Clamp(newDepth, 0, this.maxDepth);
    
    // Если глубина 0, то устанавливаем перископ
    this.periscope = (this.depth === 0);
    
    // Перерисовываем подлодку
    this.drawVehicle();
  }
  
  /**
   * Получает текущую глубину
   */
  public getDepth(): number {
    return this.depth;
  }
  
  /**
   * Поднимает перископ
   */
  public raisePeriscope(): void {
    if (this.depth <= 50) { // Перископ можно поднять только на малой глубине
      this.periscope = true;
      this.drawVehicle();
    }
  }
  
  /**
   * Опускает перископ
   */
  public lowerPeriscope(): void {
    this.periscope = false;
    this.drawVehicle();
  }
  
  /**
   * Переопределяем метод получения шума
   */
  public getNoiseStrength(): number {
    // Базовый шум от корабля
    let noise = super.getNoiseStrength();
    
    // Уменьшаем шум в зависимости от глубины
    // Чем глубже, тем тише
    const depthFactor = 1 - (this.depth / this.maxDepth) * 0.7;
    
    return noise * depthFactor;
  }
  
  /**
   * Запускает ИИ - шаг 1 (анализ ситуации)
   */
  public AI_step_I(): void {
    super.AI_step_I();
    
    // Дополнительная логика ИИ для подводной лодки
    // Например, регулировка глубины в зависимости от ситуации
    if (!this.underControl) {
      // Автоматическое управление глубиной для ИИ
      // - Погружение при обнаружении опасности
      // - Всплытие для атаки
      // Будет реализовано позже
    }
  }
  
  /**
   * Запускает ИИ - шаг 2 (принятие решений)
   */
  public AI_step_II(): void {
    super.AI_step_II();
    
    // Дополнительная логика ИИ для принятия решений
    // Будет реализовано позже
  }
} 