import Phaser from 'phaser';
import { Vehicle } from './Vehicle';
import { Constants } from '../utils/Constants';
import { Settings } from '../utils/Settings';
import { TorpedoParams } from './TorpedoParams';
import { Torpedo } from './Torpedo';
import { MainScene } from '../scenes/MainScene';

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
    
    // Устанавливаем базовую шумность для надводного корабля
    this.intrinsicNoisiness = 1.5; // Корабли немного шумнее базового Vehicle
    
    // Устанавливаем пониженную маневренность для кораблей (70%)
    this.manevr_prc = 70;
    
    // Инициализируем оружие
    this.initTorpedoParams();
    
    // Создаем интерактивность (возможность клика)
    this.setInteractive({ useHandCursor: true });
    this.on('pointerdown', this.onClick, this);
    
    // Рисуем корабль только если это обычный корабль, а не подводная лодка
    if (this.constructor === Ship) {
      this.drawShip();
    }
    
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
    // Визуально выделяем корабль
    this.setSelected(true); 

    // Сообщаем главной сцене, что этот корабль теперь выбран для информера
    const mainScene = this.scene as MainScene; // Используем явное приведение типа, если MainScene импортирована
    if (mainScene && typeof mainScene.setSelectedVehicleForInformer === 'function') {
      mainScene.setSelectedVehicleForInformer(this);
    }
  }
  
  /**
   * Создание визуального представления корабля
   * Использует методы Phaser 3 для графики: fillStyle, fillCircle, strokeLine, strokeCircle
   * Создает спрайт через add.graphics как для порта
   */
  protected drawShip(): void {
    // Определяем имя текстуры в зависимости от принадлежности
    const textureName = this.forces === Constants.FORCES_RED ? `ship_red_${this.id}` : `ship_white_${this.id}`;
    
    // Цвет зависит от принадлежности
    const mainColor = this.forces === Constants.FORCES_RED ? 
                     (this.underControl ? Constants.COLOR_LIGHT_RED : Constants.COLOR_DARK_RED) : 
                     (this.underControl ? Constants.COLOR_LIGHT_WHITE : Constants.COLOR_DARK_WHITE);
    const borderColor = 0x000000;
    
    // Создаем графику прямо через сцену
    const graphics = this.scene.add.graphics();
    
    // Очищаем графику
    graphics.clear();
    
    // Рисуем корабль: кружок с линией направления
    const radius = 10;
    const lineWidth = 2; // Толщина обводки и линии направления
    const lineLength = radius * 1.5; // Длина линии направления

    // Тело корабля (круг)
    graphics.fillStyle(mainColor, 1);
    const textureSize = (radius + lineWidth * 2) * 2 + lineLength * 2;
    const centerX = textureSize / 2;
    const centerY = textureSize / 2;
    graphics.fillCircle(centerX, centerY, radius);
    graphics.lineStyle(lineWidth, borderColor, 1);
    graphics.strokeCircle(centerX, centerY, radius);

    // Линия направления (используем this.rotation, так как Vehicle его устанавливает в радианах)
    // this.angle - в градусах, this.rotation - в радианах. Vehicle использует rotation.
    graphics.moveTo(centerX, centerY);
    graphics.lineTo(centerX + lineLength * Math.cos(this.rotation), 
                    centerY + lineLength * Math.sin(this.rotation));
    
    // Если корабль выбран, добавляем дополнительную отметку (желтый круг)
    if (this.displaySelected) {
      graphics.lineStyle(lineWidth, 0xFFFF00, 1); // Желтый цвет для выделения
      graphics.strokeCircle(centerX, centerY, radius + lineWidth * 2); // Чуть больший круг для выделения
    }
    
    // Создаем текстуру из графики
    // Увеличим размер генерируемой текстуры, чтобы вместить линию и выделение
    graphics.generateTexture(textureName, textureSize, textureSize);
    
    // Удаляем временную графику
    graphics.destroy();
    
    // Устанавливаем текстуру и размер
    this.setTexture(textureName);
    // Устанавливаем размер отображения спрайта. Можно сделать его чуть больше, чем сам корабль.
    this.setDisplaySize(40, 40); // Масштабируем для адекватного размера на экране
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
   * Уменьшает количество торпед на борту
   * @param weaponType Тип оружия
   */
  public decrementTorpCount(weaponType: number): void {
    switch (weaponType) {
      case Constants.WEAPON_SELECT_TORP_I:
        if (this.torpedoOnBoardI > 0) this.torpedoOnBoardI--;
        break;
      case Constants.WEAPON_SELECT_TORP_II:
        if (this.torpedoOnBoardII > 0) this.torpedoOnBoardII--;
        break;
      case Constants.WEAPON_SELECT_TORP_III:
        if (this.torpedoOnBoardIII > 0) this.torpedoOnBoardIII--;
        break;
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
    // Логика AI первого уровня (общая для всех кораблей)
    // Например, обнаружение противника, принятие решения об атаке или уклонении

    // Пример: если здоровье низкое, пытаемся уйти
    if (this.health < 200 && this.power < Vehicle.POWER_4) {
      this.setPower(Vehicle.POWER_4);
    }
  }
  
  /**
   * Запускает ИИ - шаг 2 (принятие решений)
   */
  public AI_step_II(): void {
    // Логика AI второго уровня (более специфичные действия)
    // Этот метод должен вызываться реже, чем AI_step_I

    if (this.moveState === Vehicle.ST_WP_SEARCH_TARGET) {
      // Логика движения по точкам для поиска цели
      if (!this.isMovingOnWayPoint || !this.hasWayPoints()) {
        // Если не движемся по точкам или точек нет, генерируем новые
        this.generateRandomWayPoint(); // Генерирует точку и запускает движение
        if (this.wayPoints.length > 0 && this.wayPoints[0]) { // Добавлена проверка this.wayPoints[0]
             console.log(`AI ${this.id}: New search WP generated. Target: ${this.wayPoints[0].point.x}, ${this.wayPoints[0].point.y} type: ${this.wayPoints[0].type}`);
        }
      } else {
        // Движемся по точкам, проверяем, не пора ли сменить тактику
        // Например, если текущая точка - точка поиска, и мы ее почти достигли,
        // или если прошло достаточно времени.
        // В AS здесь была проверка типа точки: if (way_point_tip[current_way_point] == WP_TARGET_SEARCH)
        // Теперь это будет this.wayPoints[this.currentWayPointIndex].type
        if (this.currentWayPointIndex !== -1 && this.wayPoints[this.currentWayPointIndex] && this.wayPoints[this.currentWayPointIndex].type === Constants.WP_TYPE_SEARCH) {
          // Дополнительная логика для точки поиска, если нужна
        }
      }
    } else if (this.moveState === Vehicle.ST_WP_CONVOY_MOVING) {
      // Логика движения в составе конвоя
      // (пока не реализована подробно)
      if (!this.isMovingOnWayPoint || !this.hasWayPoints()) {
        // Возможно, нужно запросить новые точки у ведущего или вернуться на маршрут
        // Для примера, просто генерируем случайную точку
        this.generateRandomWayPoint(Constants.WP_TYPE_CONVOY);
         if (this.wayPoints.length > 0 && this.wayPoints[0]) { // Добавлена проверка this.wayPoints[0]
            console.log(`AI ${this.id}: New convoy WP generated. Target: ${this.wayPoints[0].point.x}, ${this.wayPoints[0].point.y} type: ${this.wayPoints[0].type}`);
        }
      }
    } else if (this.moveState === Vehicle.ST_WP_TORP_DEFENCE_MOVING) {
        // Логика уклонения от торпед
        if (!this.isMovingOnWayPoint || !this.hasWayPoints()) {
            // Генерируем точку для маневра уклонения
            this.generateRandomWayPoint(Constants.WP_TYPE_MANEUVER); // Используем новый тип для маневра
             if (this.wayPoints.length > 0 && this.wayPoints[0]) { // Добавлена проверка this.wayPoints[0]
                console.log(`AI ${this.id}: New maneuver WP generated. Target: ${this.wayPoints[0].point.x}, ${this.wayPoints[0].point.y} type: ${this.wayPoints[0].type}`);
            }
        }
    }
    // ... Другие состояния AI ...

    // Пример вызова стрельбы торпедами, если есть цель и оружие готово
    // Эту логику нужно будет значительно расширить
    const mainScene = this.scene as MainScene;
    if (mainScene) {
      let enemyShips: Ship[] = [];
      if (this.forces === Constants.FORCES_RED) {
        if (mainScene.getWhiteShips) enemyShips = mainScene.getWhiteShips();
      } else {
        if (mainScene.getRedShips) enemyShips = mainScene.getRedShips();
      }

      const activeEnemies = enemyShips.filter((v: Ship) => v.active && v.getForces() !== this.forces);

      if (activeEnemies.length > 0) {
        const target = activeEnemies[0] as Ship; // Выбираем первую попавшуюся активную цель
        if (target && this.isWeaponReady(Constants.WEAPON_SELECT_TORP_I)) {
          // Проверяем дистанцию и угол
          const distanceToTarget = Phaser.Math.Distance.Between(this.x, this.y, target.x, target.y);
          const angleToTargetRad = Phaser.Math.Angle.Between(this.x, this.y, target.x, target.y);
          let angleToTargetDeg = (Phaser.Math.RadToDeg(angleToTargetRad) + 90 + 360) % 360;
          const diffAngle = Phaser.Math.Angle.ShortestBetween(this.direction, angleToTargetDeg);

          if (distanceToTarget < Settings.TRP_I_DIST_EXECUTION && Math.abs(diffAngle) < Settings.TRP_ATACK__ANGLE_WARNING) {
            // this.fireTorpedo(Constants.WEAPON_SELECT_TORP_I, target);
          }
        }
      }
    }
  }
  
  /**
   * Переопределяем обработчик достижения точки маршрута из Vehicle
   * @param pointType Тип достигнутой точки
   * @param isLastPoint Является ли точка последней
   */
  protected override onWayPointReached(pointType: number, isLastPoint: boolean): void {
    super.onWayPointReached(pointType, isLastPoint); // Вызываем базовую реализацию (для логирования)
    console.log(`Ship ${this.id} reached WP type: ${pointType}, isLast: ${isLastPoint}. Current AI state: ${this.moveState}`);

    if (this.moveState === Vehicle.ST_WP_SEARCH_TARGET) {
      if (pointType === Constants.WP_TYPE_SEARCH) {
        // Достигли точки поиска. Можно, например, постоять немного или изменить направление поиска.
        // В AS здесь был вызов this.stop(), this.target_locked = false и т.д.
        // Пока просто остановим движение по WP, если это была последняя точка поиска
        if (isLastPoint) {
          console.log(`AI ${this.id}: Search WP sequence finished.`);
          // this.stopMoveOnWayPoint(); // ST_WP_FINISHED будет установлен в onWayPointSequenceFinished
        } else {
          // Если это не последняя точка в серии поисковых точек, просто продолжаем
        }
      }
    } else if (this.moveState === Vehicle.ST_WP_CONVOY_MOVING) {
      if (pointType === Constants.WP_TYPE_CONVOY) {
        if (isLastPoint) {
          console.log(`AI ${this.id}: Convoy WP sequence finished. Holding position or awaiting new orders.`);
          // this.setPower(Vehicle.POWER_0); // Например, остановиться
          // this.stopMoveOnWayPoint();
        }
      }
    } else if (this.moveState === Vehicle.ST_WP_TORP_DEFENCE_MOVING) {
        if (pointType === Constants.WP_TYPE_MANEUVER) {
            if (isLastPoint) {
                console.log(`AI ${this.id}: Maneuver WP sequence finished. Assessing situation.`);
                // После маневра можно вернуться к предыдущей задаче или переоценить обстановку
                // this.moveState = Vehicle.ST_MOVE_UNKNOWN; // Сбросить состояние маневра
                // this.stopMoveOnWayPoint();
            }
        }
    }
    // Другие реакции на типы точек и состояния AI...
  }

  /**
   * Переопределяем обработчик завершения всей последовательности путевых точек
   */
  protected override onWayPointSequenceFinished(): void {
    super.onWayPointSequenceFinished(); // Вызываем базовую реализацию (установка флагов, руля)
    console.log(`Ship ${this.id} finished WP sequence. AI state was: ${this.moveState}`);

    // В зависимости от состояния AI, решаем, что делать дальше
    if (this.moveState === Vehicle.ST_WP_SEARCH_TARGET) {
      // Последовательность поиска завершена, генерируем новую точку поиска (или серию точек)
      // this.generateRandomWayPoint(Constants.WP_TYPE_SEARCH); // Начнет новую последовательность
      // Либо переходим в другое состояние, если цель найдена или время вышло
      this.moveState = Vehicle.ST_MOVE_UNKNOWN; // Пример: сброс в общее состояние
      console.log(`AI ${this.id}: Search sequence complete. Resetting AI state.`);
    } else if (this.moveState === Vehicle.ST_WP_CONVOY_MOVING) {
      // Завершили движение по точкам конвоя. Возможно, ждем новых указаний или занимаем позицию.
      this.setPower(Vehicle.POWER_0); // Например, остановиться
      this.moveState = Vehicle.ST_MOVE_UNKNOWN; // Сброс
      console.log(`AI ${this.id}: Convoy sequence complete. Holding or resetting AI state.`);
    } else if (this.moveState === Vehicle.ST_WP_TORP_DEFENCE_MOVING) {
        this.moveState = Vehicle.ST_MOVE_UNKNOWN; // Маневр завершен, сбрасываем состояние
        console.log(`AI ${this.id}: Maneuver sequence complete. Resetting AI state.`);
    }
    // Если мы просто двигались по команде (ST_WP_MOVING), то базовая реализация уже все сделала (остановила движение).
  }

  /**
   * Генерирует случайную путевую точку и начинает движение к ней.
   * Используется для простого AI поведения, например, для поиска.
   * @param wpType Тип создаваемой путевой точки.
   */
  private generateRandomWayPoint(wpType: number = Constants.WP_TYPE_SEARCH): void {
    const margin = 200; // Отступ от границ мира
    const randomX = Phaser.Math.Between(margin - Settings.GAME_WORLD_WIDTH / 2, Settings.GAME_WORLD_WIDTH / 2 - margin);
    const randomY = Phaser.Math.Between(margin - Settings.GAME_WORLD_HEIGHT / 2, Settings.GAME_WORLD_HEIGHT / 2 - margin);

    this.clearWayPoints(); // Очищаем предыдущие точки
    this.addWayPoint(randomX, randomY, wpType);
    
    // Устанавливаем мощность для движения, если корабль не движется уже достаточно быстро
    if (this.getPower() < Vehicle.POWER_3) {
        this.setPower(Vehicle.POWER_4); // Средняя мощность для движения к точке
    }
    this.startMoveOnWP();
  }
  
  /**
   * Получает уровень шума корабля.
   * Этот метод теперь соответствует новой системе, унаследованной от Vehicle.
   * Если у Ship есть специфические модификаторы к "конечной силе шума",
   * их можно добавить здесь, вызвав super.getNoiseStrength() или this.getSourceNoiseLevel().
   * В данном случае, предполагаем, что Ship не добавляет таких модификаторов,
   * поэтому он может либо наследовать getNoiseStrength от Vehicle,
   * либо для ясности явно вызывать this.getSourceNoiseLevel().
   */
  public override getNoiseStrength(): number {
    // Для корабля просто возвращаем его уровень шума у источника.
    // Специфические модификаторы (если есть) должны быть в getSourceNoiseLevel()
    // или, если они влияют на конечную силу, добавлены здесь.
    // Сейчас Ship не имеет таких, так что это эквивалентно наследованию от Vehicle,
    // если Vehicle.getNoiseStrength() возвращает this.getSourceNoiseLevel().
    return this.getSourceNoiseLevel(); 
  }
} 