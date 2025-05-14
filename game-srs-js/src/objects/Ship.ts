import Phaser from 'phaser';
import { Vehicle } from './Vehicle';
import { Constants } from '../utils/Constants';
import { Settings } from '../utils/Settings';
import { TorpedoParams } from './TorpedoParams';
import { Torpedo } from './Torpedo';

/**
 * Класс корабля - базовый класс для всех кораблей и подводных лодок
 */
export class Ship extends Vehicle {
  // Свойства
  protected sizeForHit: number = Settings.SHIP_HIT_SIZE;
  protected health: number = 1000;
  protected isConvoyShip: boolean = false;
  protected torpedoOnBoardI: number = 5;
  protected torpedoOnBoardII: number = 5;
  protected torpedoOnBoardIII: number = 5;
  protected torpedoReloadTimeMs: number = 15000;
  protected timeLastTorpedoFire: number = 0;
  
  // Параметры торпед
  protected torpedoParamsI: TorpedoParams | null = null;
  protected torpedoParamsII: TorpedoParams | null = null;
  protected torpedoParamsIII: TorpedoParams | null = null;
  
  // Время перезарядки оружия
  protected reloadTimeTorp1: number = 0;
  protected reloadTimeTorp2: number = 0;
  protected reloadTimeTorp3: number = 0;
  
  /**
   * Конструктор
   * @param scene Сцена
   * @param x Начальная позиция X
   * @param y Начальная позиция Y
   * @param forces Принадлежность (0 - red, 1 - white)
   */
  constructor(scene: Phaser.Scene, x: number, y: number, forces: number = Constants.FORCES_WHITE) {
    super(scene, x, y);
    
    // Устанавливаем принадлежность
    this.setForces(forces);
    
    // Устанавливаем пониженную маневренность для кораблей (70%)
    this.manevr_prc = 70;
    
    // Инициализируем оружие
    this.initTorpedoParams();
    
    // Создаем интерактивность (возможность клика)
    this.setInteractive({ useHandCursor: true });
    this.on('pointerdown', this.onClick, this);
    
    // Рисуем корабль
    this.drawShip();
    
    // Показываем начальное положение руля, если корабль под управлением
    if (this.underControl) {
      this.showRudder();
    }
  }
  
  /**
   * Инициализирует параметры торпед
   */
  protected initTorpedoParams(): void {
    // В будущем здесь будет загрузка из хранилища
    this.torpedoParamsI = {
      maxVelocity: Settings.TRP_I_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_I_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_I_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_I_TIME_RELOAD_SEC,
      damage: Settings.TRP_I_DAMEGE,
      executionDist: Settings.TRP_I_DIST_EXECUTION
    };
    
    this.torpedoParamsII = {
      maxVelocity: Settings.TRP_II_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_II_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_II_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_II_TIME_RELOAD_SEC,
      damage: Settings.TRP_II_DAMEGE,
      executionDist: Settings.TRP_II_DIST_EXECUTION
    };
    
    this.torpedoParamsIII = {
      maxVelocity: Settings.TRP_III_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_III_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_III_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_III_TIME_RELOAD_SEC,
      damage: Settings.TRP_III_DAMEGE,
      executionDist: Settings.TRP_III_DIST_EXECUTION,
      targetAcceptDist: Settings.TRP_III_TRG_ACCEPT_DIST
    };
  }
  
  /**
   * Обрабатывает клик по кораблю
   */
  protected onClick(): void {
    this.setSelected(true);
  }
  
  /**
   * Создание визуального представления корабля
   * Использует методы Phaser 3 для графики: fillStyle, fillRect, strokeRect
   * Создает спрайт через add.graphics как для порта
   */
  protected drawShip(): void {
    // Определяем имя текстуры в зависимости от принадлежности
    const textureName = this.forces === Constants.FORCES_RED ? 'ship_red' : 'ship_white';
    
    // Цвет зависит от принадлежности
    const mainColor = this.forces === Constants.FORCES_RED ? 
                     (this.underControl ? Constants.COLOR_LIGHT_RED : Constants.COLOR_DARK_RED) : 
                     (this.underControl ? Constants.COLOR_LIGHT_WHITE : Constants.COLOR_DARK_WHITE);
    const borderColor = 0x000000;
    
    // Создаем графику прямо через сцену
    const graphics = this.scene.add.graphics();
    
    // Очищаем графику
    graphics.clear();
    
    // Рисуем корабль в соответствии с оригинальной версией - простой прямоугольник
    graphics.fillStyle(mainColor, 1);
    graphics.lineStyle(2, borderColor, 1);
    
    // Простой прямоугольник для обычного режима
    graphics.fillRect(-10, -10, 20, 20);
    graphics.strokeRect(-10, -10, 20, 20);
    
    // Если корабль выбран, добавляем дополнительную отметку
    if (this.displaySelected) {
      graphics.lineStyle(1, 0xFFFF00, 1);
      graphics.strokeRect(-12, -12, 24, 24);
    }
    
    // Создаем текстуру из графики
    graphics.generateTexture(textureName, 30, 30);
    
    // Удаляем временную графику
    graphics.destroy();
    
    // Устанавливаем текстуру и размер
    this.setTexture(textureName);
    this.setDisplaySize(40, 40);
  }
  
  /**
   * Обновление состояния корабля
   * @param time Текущее время
   * @param delta Прошедшее время с последнего обновления
   */
  override update(time: number, delta: number): void {
    super.update(time, delta);
    
    // Обновляем время перезарядки оружия
    this.updateWeaponReload(delta);
  }
  
  /**
   * Обновление времени перезарядки оружия
   * @param delta Прошедшее время в мс
   */
  protected updateWeaponReload(delta: number): void {
    // Перезарядка торпед
    if (this.reloadTimeTorp1 > 0) {
      this.reloadTimeTorp1 -= delta;
      if (this.reloadTimeTorp1 < 0) this.reloadTimeTorp1 = 0;
    }
    
    if (this.reloadTimeTorp2 > 0) {
      this.reloadTimeTorp2 -= delta;
      if (this.reloadTimeTorp2 < 0) this.reloadTimeTorp2 = 0;
    }
    
    if (this.reloadTimeTorp3 > 0) {
      this.reloadTimeTorp3 -= delta;
      if (this.reloadTimeTorp3 < 0) this.reloadTimeTorp3 = 0;
    }
  }
  
  /**
   * Проверяет готовность оружия
   * @param weaponType Тип оружия
   */
  public isWeaponReady(weaponType: number): boolean {
    // Проверяем тип оружия
    switch (weaponType) {
      case Constants.WEAPON_SELECT_TORP_I:
        // Проверяем наличие и время перезарядки
        return this.torpedoOnBoardI > 0 && this.reloadTimeTorp1 <= 0;
      
      case Constants.WEAPON_SELECT_TORP_II:
        return this.torpedoOnBoardII > 0 && this.reloadTimeTorp2 <= 0;
      
      case Constants.WEAPON_SELECT_TORP_III:
        return this.torpedoOnBoardIII > 0 && this.reloadTimeTorp3 <= 0;
      
      default:
        return false;
    }
  }
  
  /**
   * Получает количество торпед на борту
   * @param weaponType Тип оружия
   */
  public getTorpOnBoard(weaponType: number): number {
    switch (weaponType) {
      case Constants.WEAPON_SELECT_TORP_I:
        return this.torpedoOnBoardI;
      
      case Constants.WEAPON_SELECT_TORP_II:
        return this.torpedoOnBoardII;
      
      case Constants.WEAPON_SELECT_TORP_III:
        return this.torpedoOnBoardIII;
      
      default:
        return 0;
    }
  }
  
  /**
   * Обрабатывает попадание в корабль
   * @param damage Нанесенный урон
   */
  public hasHit(damage: number): void {
    // Уменьшаем здоровье
    this.health -= damage;
    
    // Увеличиваем время перезарядки торпед
    this.torpedoReloadTimeMs *= Settings.HIT_TIME_RELOAD_INCREASE;
    
    // Уменьшаем скорость
    this.maxVelocity /= Settings.HIT_SHIP_SPEED_DECREASE;
    
    // Проверяем, не уничтожен ли корабль
    if (this.health <= 0) {
      this.destroy();
    }
  }
  
  /**
   * Проверяет, является ли корабль конвоем
   */
  public isConvoy(): boolean {
    return this.isConvoyShip;
  }
  
  /**
   * Получает размер корабля для определения попадания
   */
  public getSizeForHit(): number {
    return this.sizeForHit;
  }
  
  /**
   * Запускает ИИ - шаг 1 (анализ ситуации)
   */
  public AI_step_I(): void {
    // Пропускаем, если корабль под управлением игрока
    if (this.underControl) {
      return;
    }
    
    // Получаем сцену
    const scene = this.scene as any;
    
    // Получаем корабли противника
    let enemyShips: Ship[] = [];
    if (this.forces === Constants.FORCES_RED) {
      // Красный корабль ищет белые корабли
      if (scene.getWhiteShips) {
        enemyShips = scene.getWhiteShips();
      }
    } else {
      // Белый корабль ищет красные корабли
      if (scene.getRedShips) {
        enemyShips = scene.getRedShips();
      }
    }
    
    // Если нет вражеских кораблей, то двигаемся случайно
    if (enemyShips.length === 0) {
      if (this.wayPoints.length === 0) {
        this.generateRandomWayPoint();
      }
      return;
    }
    
    // Находим ближайший вражеский корабль
    let nearestShip: Ship | null = null;
    let minDistance = Number.MAX_VALUE;
    
    for (const ship of enemyShips) {
      const distance = Phaser.Math.Distance.Between(
        this.position.x, this.position.y,
        ship.getPosition().x, ship.getPosition().y
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestShip = ship;
      }
    }
    
    // Если нашли вражеский корабль
    if (nearestShip) {
      // Если расстояние до вражеского корабля больше дистанции обнаружения,
      // то продолжаем двигаться по своему маршруту или генерируем новую точку
      if (minDistance > Settings.MOVE_ON_TARGET_FROM_DIST) {
        if (this.wayPoints.length === 0) {
          this.generateRandomWayPoint();
        }
        return;
      }
      
      // Если расстояние до вражеского корабля меньше дистанции обнаружения,
      // то начинаем преследование
      if (this.moveState !== Vehicle.ST_WP_SEARCH_TARGET) {
        // Очищаем точки маршрута
        this.wayPoints = [];
        this.wayPointTypes = [];
        
        // Устанавливаем состояние преследования
        this.moveState = Vehicle.ST_WP_SEARCH_TARGET;
        
        // Устанавливаем полную скорость
        this.power = Vehicle.POWER_6;
      }
      
      // Добавляем точку маршрута на позицию вражеского корабля
      const enemyPos = nearestShip.getPosition();
      this.addWayPoint(enemyPos.x, enemyPos.y, Constants.WP_TARGET);
      this.startMoveOnWP();
      
      // Если корабль находится достаточно близко для атаки
      if (minDistance < Settings.TRP_ATACK_DISTANCE_WARNING) {
        // Запускаем торпеду, если она готова
        if (this.isWeaponReady(Constants.WEAPON_SELECT_TORP_I)) {
          const enemyPosPredict = nearestShip.getPosition();
          
          // Предсказываем будущую позицию противника
          const enemyVel = nearestShip.getVelocity();
          enemyPosPredict.x += enemyVel.x * 2; // 2 секунды упреждения
          enemyPosPredict.y += enemyVel.y * 2;
          
          // Запускаем торпеду
          (scene as any).fireTorpedo(this, Constants.WEAPON_SELECT_TORP_I, enemyPosPredict.x, enemyPosPredict.y);
        }
      }
    }
  }
  
  /**
   * Запускает ИИ - шаг 2 (принятие решений)
   */
  public AI_step_II(): void {
    // Пропускаем, если корабль под управлением игрока
    if (this.underControl) {
      return;
    }
    
    // Проверка угрозы от торпед
    const scene = this.scene as any;
    
    // Получаем торпеды противника
    let enemyTorpedos: Torpedo[] = [];
    if (this.forces === Constants.FORCES_RED) {
      // Красный корабль проверяет белые торпеды
      if (scene.getWhiteTorpedos) {
        enemyTorpedos = scene.getWhiteTorpedos();
      }
    } else {
      // Белый корабль проверяет красные торпеды
      if (scene.getRedTorpedos) {
        enemyTorpedos = scene.getRedTorpedos();
      }
    }
    
    // Если нет вражеских торпед, то продолжаем выполнять текущий план
    if (enemyTorpedos.length === 0) {
      return;
    }
    
    // Находим ближайшую торпеду и проверяем, угрожает ли она нам
    let nearestTorpedo: Torpedo | null = null;
    let minDistance = Number.MAX_VALUE;
    
    for (const torpedo of enemyTorpedos) {
      const distance = Phaser.Math.Distance.Between(
        this.position.x, this.position.y,
        torpedo.getPosition().x, torpedo.getPosition().y
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestTorpedo = torpedo;
      }
    }
    
    // Если есть ближайшая торпеда
    if (nearestTorpedo && minDistance < Settings.TRP_ATACK_ALARM_DIST) {
      // Направление к торпеде
      const torpedoDirection = Phaser.Math.RadToDeg(
        Phaser.Math.Angle.Between(
          this.position.x, this.position.y,
          nearestTorpedo.getPosition().x, nearestTorpedo.getPosition().y
        )
      );
      
      // Разница между нашим направлением и направлением к торпеде
      let angleDiff = Math.abs(this.direction - ((torpedoDirection + 90) % 360));
      if (angleDiff > 180) angleDiff = 360 - angleDiff;
      
      // Если торпеда приближается спереди или сбоку (опасное направление)
      if (angleDiff < Settings.TRP_ATACK_DEFENSE_ANGLE) {
        // Уклоняемся от торпеды - поворачиваем перпендикулярно направлению на торпеду
        const evadeDirection = (torpedoDirection + 180) % 360;
        
        // Очищаем маршрут и устанавливаем маневр уклонения
        this.wayPoints = [];
        this.wayPointTypes = [];
        this.moveState = Vehicle.ST_WP_TORP_DEFENCE_MOVING;
        
        // Устанавливаем максимальную скорость для уклонения
        this.power = Vehicle.POWER_6;
        
        // Вычисляем точку для уклонения - перпендикулярно к направлению на торпеду
        const evadeX = this.position.x + Math.cos(Phaser.Math.DegToRad(evadeDirection)) * 200;
        const evadeY = this.position.y + Math.sin(Phaser.Math.DegToRad(evadeDirection)) * 200;
        
        // Добавляем точку уклонения
        this.addWayPoint(evadeX, evadeY, Constants.WP_TORP_DEFENCE);
        this.startMoveOnWP();
      }
    }
  }
  
  /**
   * Генерирует случайную точку маршрута
   */
  private generateRandomWayPoint(): void {
    // Очищаем текущие точки
    this.wayPoints = [];
    this.wayPointTypes = [];
    
    // Генерируем случайные координаты в пределах экрана
    const x = Phaser.Math.Between(50, Settings.SCREEN_WIDTH - 50);
    const y = Phaser.Math.Between(50, Settings.SCREEN_HEIGHT - 50);
    
    // Добавляем точку и запускаем движение
    this.addWayPoint(x, y, Constants.WP_SHIP);
    this.startMoveOnWP();
    
    // Устанавливаем случайную скорость
    this.power = Phaser.Math.Between(Vehicle.POWER_2, Vehicle.POWER_5);
  }
  
  /**
   * Получает уровень шума корабля
   * Используется для определения обнаружения корабля
   */
  public getNoiseStrength(): number {
    // Базовый шум зависит от скорости корабля
    const baseNoise = this.getSpeed() / this.maxVelocity * 100;
    
    // Коэффициент шумности корабля (зависит от типа)
    const noiseCoefficient = 1.0;  // Базовый коэффициент для корабля
    
    return baseNoise * noiseCoefficient;
  }
  
  /**
   * Рассчитывает шум на заданном расстоянии
   * @param distance Расстояние до корабля
   */
  public calcNoiseAtDist(distance: number): number {
    const noise = this.getNoiseStrength();
    
    // Затухание шума с расстоянием (обратно пропорционально квадрату расстояния)
    if (distance <= 10) {
      return noise;  // На малых расстояниях шум не затухает
    }
    
    return noise / (Math.pow(distance / 100, 2));
  }
} 