import Phaser from 'phaser';
import { Constants } from '../utils/Constants';
import { Settings } from '../utils/Settings';
import { CoordUtils } from '../utils/CoordUtils';

/**
 * Базовый класс для всех движущихся объектов
 */
export interface WayPointData {
  point: Phaser.Math.Vector2;
  type: number;
  // Можно добавить графический объект для визуализации, если решим ее делать
  // graphics?: Phaser.GameObjects.Graphics | Phaser.GameObjects.Shape;
}

export class Vehicle extends Phaser.GameObjects.Sprite {
  // Константы для уровней мощности
  static readonly POWER_0: number = 0;
  static readonly POWER_1: number = 1;
  static readonly POWER_2: number = 2;
  static readonly POWER_3: number = 3;
  static readonly POWER_4: number = 4;
  static readonly POWER_5: number = 5;
  static readonly POWER_6: number = 6;
  
  // Константы для состояний движения
  static readonly ST_MOVE_UNKNOWN: number = 0;
  static readonly ST_WP_MOVING: number = 1;
  static readonly ST_COMMAND_MOVING: number = 2;
  static readonly ST_WP_SEARCH_TARGET: number = 3;
  static readonly ST_WP_TORP_DEFENCE_MOVING: number = 4;
  static readonly ST_WP_FINISHED: number = 5;
  static readonly ST_WP_CONVOY_MOVING: number = 6; // Добавлено состояние для движения в конвое
  
  // Константы для положения руля
  static readonly RUDER_RIGHT_15: number = -3;
  static readonly RUDER_RIGHT_10: number = -2;
  static readonly RUDER_RIGHT_5: number = -1;
  static readonly RUDER_0: number = 0;
  static readonly RUDER_LEFT_5: number = 1;
  static readonly RUDER_LEFT_10: number = 2;
  static readonly RUDER_LEFT_15: number = 3;
  
  // Статический счетчик для уникальных ID
  private static nextId: number = 0;

  // Свойства объекта
  public readonly id: number; // Уникальный идентификатор объекта
  protected position: Phaser.Math.Vector2;
  protected velocity: Phaser.Math.Vector2;
  protected direction: number = 0;
  protected directionTarget: number = 0;
  protected power: number = Vehicle.POWER_0;
  protected rudder: number = Vehicle.RUDER_0; // Положение руля
  protected maxVelocity: number = 30;
  protected color: number = 0xFFFFFF;
  protected forces: number = Constants.FORCES_WHITE;
  protected timeLive: number = 0;
  protected underControl: boolean = false;
  protected displaySelected: boolean = false;
  protected moveState: number = Vehicle.ST_MOVE_UNKNOWN;
  protected wayPoints: WayPointData[] = [];
  protected currentWayPointIndex: number = -1;
  public isMovingOnWayPoint: boolean = false;
  protected arrivalThreshold: number = 30; // Дистанция для регистрации прибытия к точке (WAY_POINT_SIZE в AS был 30)
  
  // Маневренность в процентах (100 - торпеды и катера, 50-80 - корабли)
  protected manevr_prc: number = 100;
  
  // Базовая шумность объекта, может переопределяться в дочерних классах
  public intrinsicNoisiness: number = 1.0;

  // Графика для отображения кругов шума
  private noiseCirclesGraphics: Phaser.GameObjects.Graphics | null = null;

  // Пороговые значения и стили для отображения кругов шума (на основе AS-версии)
  private static readonly NOISE_DISPLAY_THRESHOLDS_AS = [
    // { threshold: 0.8, color: Constants.COLOR_LIGHT_RED_AS_EQUIVALENT, alpha: 1.0, lineThickness: 2 }, // Самый тихий, самый большой круг
    // { threshold: 0.5, color: Constants.COLOR_MEDIUM_RED_AS_EQUIVALENT, alpha: 1.0, lineThickness: 2 },
    // { threshold: 0.2, color: Constants.COLOR_DARK_RED_AS_EQUIVALENT, alpha: 1.0, lineThickness: 2 }  // Самый громкий, самый маленький круг
    // ПОРЯДОК ВАЖЕН ДЛЯ ОТРИСОВКИ, ЧТОБЫ БОЛЬШИЕ КРУГИ НЕ ПЕРЕКРЫВАЛИ МЕНЬШИЕ, ЕСЛИ БУДЕТ ЗАЛИВКА
    // НО ТАК КАК У НАС ТОЛЬКО ЛИНИИ, ПОРЯДОК НЕ СТОЛЬ КРИТИЧЕН.
    // ДЛЯ СООТВЕТСТВИЯ С AS, ГДЕ СНАЧАЛА РИСУЕТСЯ ДЛЯ 0.2, ПОТОМ 0.5, ПОТОМ 0.8:
    { threshold: 0.2, color: 0xFF0000, alphaLine: 1.0, lineThickness: 2 }, // Темно-красный (пример)
    { threshold: 0.5, color: 0xFF6347, alphaLine: 1.0, lineThickness: 2 }, // Средне-красный (томатный - пример)
    { threshold: 0.8, color: 0xFFA07A, alphaLine: 1.0, lineThickness: 2 }  // Светло-красный (светло-лососевый - пример)
  ];

  /**
   * Конструктор
   * @param scene Сцена, к которой принадлежит объект
   * @param x Начальная позиция X
   * @param y Начальная позиция Y
   * @param texture Текстура спрайта
   */
  constructor(scene: Phaser.Scene, x: number, y: number, texture?: string) {
    super(scene, x, y, texture || 'vehicle');
    this.position = new Phaser.Math.Vector2(x, y);
    this.velocity = new Phaser.Math.Vector2(0, 0);
    this.id = Vehicle.nextId++; // Присваиваем уникальный ID и инкрементируем счетчик
    
    // Добавление в сцену
    (scene.add as Phaser.GameObjects.GameObjectFactory).existing(this);
    
    // Если нет текстуры, рисуем стандартную фигуру
    if (!texture) {
      this.drawVehicle();
    }

    // Инициализация графики для кругов шума
    this.noiseCirclesGraphics = this.scene.add.graphics({ x: this.x, y: this.y });
    this.noiseCirclesGraphics.setDepth(this.depth - 1); // Рисуем под основным спрайтом Vehicle
  }
  
  /**
   * Рисует стандартную фигуру для объекта
   */
  protected drawVehicle(): void {
    // Создаем графику для отрисовки
    const graphics = (this.scene.add as Phaser.GameObjects.GameObjectFactory).graphics();
    
    // Очищаем графику
    graphics.clear();
    
    // Рисуем более заметный объект (треугольник)
    graphics.fillStyle(this.color, 1);
    graphics.lineStyle(2, 0x000000, 1);
    
    // Треугольник для обозначения направления движения
    graphics.beginPath();
    graphics.moveTo(0, -20);    // Вершина (нос)
    graphics.lineTo(-15, 15);   // Левый нижний угол (корма)
    graphics.lineTo(15, 15);    // Правый нижний угол (корма)
    graphics.closePath();
    graphics.fillPath();
    graphics.strokePath();
    
    // Создаем текстуру из графики
    const textureName = 'vehicle' + this.forces; // Разные текстуры для разных сторон
    graphics.generateTexture(textureName, 40, 40);
    graphics.destroy();
    
    // Устанавливаем текстуру
    this.setTexture(textureName);
    this.setDisplaySize(40, 40);
  }
  
  /**
   * Обновляет позицию и состояние объекта
   * @param time Текущее время
   * @param delta Прошедшее с последнего обновления время в мс
   */
  update(time: number, delta: number): void {
    this.timeLive += delta;
    
    // Обновляем движение по путевым точкам, если активно
    if (this.isMovingOnWayPoint) {
      this.updateMoveOnWayPoint(delta);
    }
    
    // Обновляем физику (учитывает текущий руль и мощность)
    this.updatePhysics(delta);
    
    // Обновляем позицию спрайта и поворот
    this.setPosition(this.position.x, this.position.y); // position обновляется в updatePhysics
    this.setSpriteRotation(Phaser.Math.DegToRad(this.direction)); // direction обновляется в updatePhysics или updateMoveOnWayPoint (через setRudder)

    // Обновляем круги шума, если они есть и объект выбран
    if (this.noiseCirclesGraphics && (this.displaySelected /*|| Settings.DEBUG_SHOW_ALL_NOISE_CIRCLES*/)) {
      this.updateNoiseCircles();
      this.noiseCirclesGraphics.x = this.x;
      this.noiseCirclesGraphics.y = this.y;
      this.noiseCirclesGraphics.visible = true;
    } else if (this.noiseCirclesGraphics) {
      this.noiseCirclesGraphics.visible = false;
    }
  }
  
  /**
   * Обновляет физику объекта
   * @param delta Прошедшее время в мс
   */
  protected updatePhysics(delta: number): void {
    const deltaSeconds = delta / 1000;
    
    // Обновление направления на основе положения руля, если руль не в нейтральном положении
    if (this.rudder !== Vehicle.RUDER_0) {
      // Скорость поворота зависит от положения руля, скорости и маневренности
      // Реализуем поворот как в оригинальной ActionScript-версии
      // direction_deg -= dt_ms * command_params.rudder * VehicleMoving.getAlphaR(cur_vel_gm, manevr_prc) * cur_vel_gm;
      const turnFactor = this.rudder * this.getAlphaR() * this.velocity.length();
      
      // Применяем формулу поворота как в оригинале
      this.direction -= delta * turnFactor;
      
      // Нормализуем угол
      this.direction = (this.direction + 360) % 360;
      this.directionTarget = this.direction; // Целевое направление следует за текущим при управлении рулем
    }
    // Иначе, если есть целевое направление, двигаемся к нему
    else if (this.direction !== this.directionTarget) {
      // Находим кратчайший путь поворота
      let diff = this.directionTarget - this.direction;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      
      // Скорость поворота зависит от мощности и коэффициентов
      let turnRate = this.power * (Settings.alfa_r_0 + Settings.alfa_r_30);
      
      // Применяем поворот с ограничением по времени
      if (Math.abs(diff) <= turnRate * deltaSeconds) {
        this.direction = this.directionTarget;
      } else {
        this.direction += Math.sign(diff) * turnRate * deltaSeconds;
      }
      
      // Нормализуем угол
      this.direction = (this.direction + 360) % 360;
    }
    
    // Обновление скорости в зависимости от мощности
    const targetSpeed = this.power * this.maxVelocity / Vehicle.POWER_6;
    const currentSpeed = this.velocity.length();
    
    // Используем больший коэффициент для заметного изменения скорости
    // и умножаем на 1000 для компенсации deltaSeconds, как в оригинальном коде
    const inertiaFactor = Settings.alfa_v * 1000;
    
    if (Math.abs(currentSpeed - targetSpeed) > 0.01) {
      // Плавное изменение скорости с учетом инерции
      const speedChange = (targetSpeed - currentSpeed) * inertiaFactor * deltaSeconds;
      
      if (currentSpeed < 0.1) {
        // Если стоим на месте или почти остановились, начинаем движение в направлении
        this.velocity.x = Math.sin(Phaser.Math.DegToRad(this.direction)) * targetSpeed * 0.1;
        this.velocity.y = -Math.cos(Phaser.Math.DegToRad(this.direction)) * targetSpeed * 0.1;
      } else {
        // Иначе изменяем текущую скорость пропорционально
        // Ограничиваем изменение скорости
        let newSpeed = currentSpeed + speedChange;
        if ((speedChange > 0 && newSpeed > targetSpeed) || 
            (speedChange < 0 && newSpeed < targetSpeed)) {
          newSpeed = targetSpeed;
        }
        
        // Устанавливаем новое значение скорости, сохраняя направление
        if (newSpeed > 0.1) {
          const scale = newSpeed / currentSpeed;
          this.velocity.scale(scale);
        } else {
          // Если скорость стала слишком маленькой, полностью останавливаемся
          this.velocity.x = 0;
          this.velocity.y = 0;
        }
      }
    }
    
    // Пересчитываем направление вектора скорости по текущему углу direction
    if (this.velocity.length() > 0.1) {
      const speed = this.velocity.length();
      this.velocity.x = Math.sin(Phaser.Math.DegToRad(this.direction)) * speed;
      this.velocity.y = -Math.cos(Phaser.Math.DegToRad(this.direction)) * speed;
    }
    
    // Обновляем позицию
    this.position.x += this.velocity.x * deltaSeconds;
    this.position.y += this.velocity.y * deltaSeconds;
  }
  
  /**
   * Получает коэффициент поворота в зависимости от скорости
   * Аналог getAlphaR из ActionScript версии
   */
  protected getAlphaR(): number {
    const vel = this.velocity.length();
    // Базовая формула из ActionScript:
    // ar = (Settings.alfa_r_30 - Settings.alfa_r_0) / (100.*Settings.koef_v) * vel + Settings.alfa_r_0;
    const ar = (Settings.alfa_r_30 - Settings.alfa_r_0) / (100 * Settings.koef_v) * vel + Settings.alfa_r_0;
    
    // Учитываем маневренность как в оригинальной AS-версии
    return ar * this.manevr_prc / 100;
  }
  
  /**
   * Добавляет точку маршрута
   * @param x Координата X
   * @param y Координата Y
   * @param type Тип точки маршрута
   */
  public addWayPoint(x: number, y: number, type: number = 0): void {
    // Используем логические координаты для путевых точек
    const logicalPoint = new Phaser.Math.Vector2(x, y);
    this.wayPoints.push({ point: logicalPoint, type: type });
    // TODO: Add visualization if needed, similar to CustomCircle in AS
  }
  
  /**
   * Начинает движение по текущему маршруту из путевых точек.
   * Устанавливает мощность по умолчанию, если не было иной логики.
   */
  public startMoveOnWP(): void {
    if (this.wayPoints.length > 0) {
      this.currentWayPointIndex = 0;
      this.isMovingOnWayPoint = true;
      this.moveState = Vehicle.ST_WP_MOVING; // Устанавливаем состояние движения по WP
      // Устанавливаем первую путевую точку как цель, но не меняем this.directionTarget напрямую,
      // это будет управляться логикой в updateMoveOnWayPoint через установку руля.
      // this.setDirectionToWayPoint(this.wayPoints[this.currentWayPointIndex].point);
      console.log(`${this.constructor.name} ${this.id} starting WP sequence. First target:`, this.wayPoints[this.currentWayPointIndex].point);
    } else {
      this.isMovingOnWayPoint = false;
      this.moveState = Vehicle.ST_MOVE_UNKNOWN; // или ST_WP_FINISHED, если это более подходяще
    }
  }
  
  /**
   * Немедленно останавливает движение по маршруту и очищает все путевые точки.
   */
  public stopMoveOnWayPoint(): void {
    this.isMovingOnWayPoint = false;
    this.currentWayPointIndex = -1;
    this.moveState = Vehicle.ST_WP_FINISHED; // Состояние: завершено движение по WP
    this.setRudder(Vehicle.RUDER_0); // Сбрасываем руль в нейтральное положение
    // this.clearWayPoints(); // Не очищаем здесь, чтобы можно было возобновить или проанализировать маршрут
    // Очистка должна быть явной через clearWayPoints() или при добавлении нового маршрута
    this.onWayPointSequenceFinished(); // Уведомляем, что вся последовательность завершена (или прервана)
    console.log(`${this.constructor.name} ${this.id} stopped WP sequence.`);
  }
  
  /**
   * Очищает все путевые точки из маршрута.
   * Также удаляет их визуальное представление, если оно было.
   */
  public clearWayPoints(): void {
    this.wayPoints = [];
    this.currentWayPointIndex = -1;
    this.isMovingOnWayPoint = false;
    if (this.moveState === Vehicle.ST_WP_MOVING || this.moveState === Vehicle.ST_WP_FINISHED) {
      this.moveState = Vehicle.ST_MOVE_UNKNOWN; // Сброс состояния, если оно было связано с WP
    }
    // TODO: Remove waypoint graphics from scene if they were added
    console.log(`${this.constructor.name} ${this.id} cleared waypoints.`);
  }
  
  /**
   * Проверяет, есть ли у объекта заданные путевые точки.
   * @returns true, если есть хотя бы одна путевая точка.
   */
  public hasWayPoints(): boolean {
    return this.wayPoints.length > 0;
  }
  
  /**
   * Вызывается при достижении КАЖДОЙ путевой точки в маршруте.
   * @param pointType Тип достигнутой точки (из Constants.WP_*).
   * @param isLastPoint Является ли эта точка последней в маршруте.
   */
  protected onWayPointReached(pointType: number, isLastPoint: boolean): void {
    // Базовая реализация пуста. Может быть переопределена в дочерних классах
    // для специфической реакции на тип точки или на то, последняя ли она.
    // Например, в Ship.as здесь менялся move_state или параметры движения.
    console.log(`${this.constructor.name} ${this.id} reached waypoint of type ${pointType}. Is last: ${isLastPoint}`);
  }
  
  /**
   * Вызывается при достижении ПОСЛЕДНЕЙ точки всего маршрута.
   * Завершает движение по путевым точкам.
   */
  protected onWayPointSequenceFinished(): void {
    // Базовая реализация: остановка движения по точкам
    console.log(`${this.constructor.name} ${this.id} WP sequence finished.`);
    // this.stopMoveOnWayPoint(); // Не вызываем здесь, чтобы избежать рекурсии, если stop вызвал onWayPointSequenceFinished
    this.isMovingOnWayPoint = false;
    this.currentWayPointIndex = -1;
    // ST_WP_FINISHED будет установлен в stopMoveOnWayPoint, если он вызывается извне,
    // или здесь, если это естественное завершение
    if (this.moveState === Vehicle.ST_WP_MOVING) {
        this.moveState = Vehicle.ST_WP_FINISHED;
    }
    this.setRudder(Vehicle.RUDER_0);
    // Дочерние классы могут переопределить это для специфического поведения (например, начать новый поиск)
  }
  
  /**
   * Обновляет движение объекта к текущей путевой точке.
   * Включает логику поворота и переключения на следующую точку.
   * @param delta Время, прошедшее с последнего обновления, в миллисекундах.
   */
  protected updateMoveOnWayPoint(delta: number): void {
    if (!this.isMovingOnWayPoint || this.currentWayPointIndex < 0 || this.currentWayPointIndex >= this.wayPoints.length) {
      this.isMovingOnWayPoint = false;
      if (this.moveState === Vehicle.ST_WP_MOVING) { // Если мы активно двигались по WP
          this.moveState = Vehicle.ST_WP_FINISHED; // Отмечаем как завершенное
          this.onWayPointSequenceFinished(); // Вызываем обработчик завершения всей последовательности
      }
      return;
    }

    const currentWpData = this.wayPoints[this.currentWayPointIndex];
    const targetLogicalPos = currentWpData.point;

    // Конвертируем логические координаты цели в Phaser координаты для расчета дистанции и угла
    const targetPhaserPos = new Phaser.Math.Vector2(
        CoordUtils.logicalToPhaserX(targetLogicalPos.x),
        CoordUtils.logicalToPhaserY(targetLogicalPos.y)
    );

    const distanceToTarget = Phaser.Math.Distance.Between(this.x, this.y, targetPhaserPos.x, targetPhaserPos.y);

    // Проверка достижения точки
    if (distanceToTarget <= this.arrivalThreshold) {
      const isLastPoint = this.currentWayPointIndex === this.wayPoints.length - 1;
      this.onWayPointReached(currentWpData.type, isLastPoint);

      if (isLastPoint) {
        this.onWayPointSequenceFinished(); // Вызываем обработчик завершения всей последовательности
        this.isMovingOnWayPoint = false; // Останавливаем движение по WP
        this.moveState = Vehicle.ST_WP_FINISHED;
        // Не сбрасываем currentWayPointIndex, чтобы можно было понять, на какой точке остановились
        return;
      } else {
        this.currentWayPointIndex++;
        // console.log(`${this.constructor.name} ${this.id} reached WP, next target:`, this.wayPoints[this.currentWayPointIndex].point);
        // Цель изменилась, пересчитываем для текущего кадра
        // (или можно оставить поворот на следующий кадр, как было бы в реальности)
        // Для более плавной реакции, пересчитаем targetPhaserPos для логики руления ниже
        const nextWpData = this.wayPoints[this.currentWayPointIndex];
        const nextTargetLogicalPos = nextWpData.point;
        targetPhaserPos.set(
            CoordUtils.logicalToPhaserX(nextTargetLogicalPos.x),
            CoordUtils.logicalToPhaserY(nextTargetLogicalPos.y)
        );
        // console.log(`${this.constructor.name} ${this.id} advancing to WP index ${this.currentWayPointIndex}`);

      }
    }

    // Логика руления для достижения текущей targetPhaserPos
    // Угол направления в градусах (0 - вверх, 90 - вправо, 180 - вниз, 270 - влево)
    // this.direction уже в градусах и соответствует этой конвенции.

    // Рассчитываем угол к текущей цели (targetPhaserPos)
    const angleToTargetRad = Phaser.Math.Angle.Between(this.x, this.y, targetPhaserPos.x, targetPhaserPos.y);
    // Phaser.Math.Angle.Between возвращает угол в радианах, где 0 вправо.
    // Нам нужен угол, где 0 - вверх, и в градусах.
    // Сначала конвертируем в градусы:
    let angleToTargetDeg = Phaser.Math.RadToDeg(angleToTargetRad);
    // Теперь приводим к нашей системе координат (0 = вверх):
    // Угол из Angle.Between: 0 вправо, 90 вниз, 180 влево, -90 вверх (или 270)
    // Наша система: 0 вверх, 90 вправо, 180 вниз, 270 влево
    // Преобразование: naš_ugol = (phaser_ugol + 90) % 360
    angleToTargetDeg = (angleToTargetDeg + 90 + 360) % 360;


    // Кратчайший угол поворота
    const diffAngle = Phaser.Math.Angle.ShortestBetween(this.direction, angleToTargetDeg); // оба угла в градусах

    if (Math.abs(diffAngle) > Settings.ANGLE_PRECISION_FOR_WP) {
      // Необходимо повернуть
      if (diffAngle > 0) { // Поворот влево (против часовой стрелки в нашей системе, this.direction увеличивается)
        if (Math.abs(diffAngle) > 45) this.setRudder(Vehicle.RUDER_LEFT_15);
        else if (Math.abs(diffAngle) > 20) this.setRudder(Vehicle.RUDER_LEFT_10);
        else this.setRudder(Vehicle.RUDER_LEFT_5);
      } else { // Поворот вправо (по часовой стрелке, this.direction уменьшается)
        if (Math.abs(diffAngle) > 45) this.setRudder(Vehicle.RUDER_RIGHT_15);
        else if (Math.abs(diffAngle) > 20) this.setRudder(Vehicle.RUDER_RIGHT_10);
        else this.setRudder(Vehicle.RUDER_RIGHT_5);
      }
    } else {
      // Курс в пределах допустимой точности, руль прямо
      this.setRudder(Vehicle.RUDER_0);
    }

    // Физика (включая поворот от руля и движение вперед) будет обновлена в self.updatePhysics(delta)
    // который вызывается в Vehicle.update() после updateMoveOnWayPoint.
  }
  
  /**
   * Устанавливает мощность/скорость движения
   * @param newPower Новый уровень мощности
   */
  public setPower(newPower: number): void {
    if (newPower >= Vehicle.POWER_0 && newPower <= Vehicle.POWER_6) {
      this.power = newPower;
    }
  }
  
  /**
   * Устанавливает направление движения (курс)
   * @param newDirection Новое направление в градусах (0-359)
   */
  public setDirection(newDirection: number): void {
    this.directionTarget = ((newDirection % 360) + 360) % 360;
  }
  
  /**
   * Устанавливает максимальную скорость
   * @param newMaxVelocity Новая максимальная скорость
   */
  public setMaxVelocity(newMaxVelocity: number): void {
    this.maxVelocity = newMaxVelocity;
  }
  
  /**
   * Получает текущую позицию
   */
  public getPosition(): Phaser.Math.Vector2 {
    return this.position.clone();
  }
  
  /**
   * Получает текущую скорость в виде вектора
   */
  public getVelocity(): Phaser.Math.Vector2 {
    return this.velocity.clone();
  }
  
  /**
   * Получает скорость объекта
   */
  public getSpeed(): number {
    return this.velocity.length();
  }
  
  /**
   * Получает текущее направление (курс)
   */
  public getDirection(): number {
    return this.direction;
  }
  
  /**
   * Получает время жизни объекта в миллисекундах
   */
  public getTimeLiveMs(): number {
    return this.timeLive;
  }
  
  /**
   * Получает принадлежность к силам
   */
  public getForces(): number {
    return this.forces;
  }
  
  /**
   * Устанавливает принадлежность к силам
   * @param newForces Новая принадлежность к силам
   */
  public setForces(newForces: number): void {
    this.forces = newForces;
    
    // Устанавливаем цвет в зависимости от принадлежности
    if (this.forces === Constants.FORCES_RED) {
      this.color = Constants.COLOR_LIGHT_RED;
    } else {
      this.color = Constants.COLOR_LIGHT_WHITE;
    }
  }
  
  /**
   * Устанавливает отметку выбора объекта
   * @param selected Выбран ли объект
   */
  public setSelected(selected: boolean): void {
    this.displaySelected = selected;
    
    // Перерисовываем объект при изменении состояния выбора
    if (this.constructor.name === 'Ship') {
      // Для обычных кораблей
      (this as any).drawShip();
    } else if (this.constructor.name === 'Submarine') {
      // Для подводных лодок
      const submarine = this as any;
      if (typeof submarine.drawVehicle === 'function') {
        submarine.drawVehicle();
      }
    }
  }
  
  /**
   * Проверяет, выбран ли объект
   */
  public isSelected(): boolean {
    return this.displaySelected;
  }
  
  /**
   * Устанавливает ручное управление объектом
   * @param control Включено ли ручное управление
   */
  public setUnderControl(control: boolean): void {
    this.underControl = control;
  }
  
  /**
   * Проверяет, находится ли объект под ручным управлением
   */
  public isUnderControl(): boolean {
    return this.underControl;
  }
  
  /**
   * Проверяет столкновение с другим объектом
   * @param other Другой объект для проверки столкновения
   */
  public testCollision(other: Vehicle): boolean {
    const distance = Phaser.Math.Distance.Between(
      this.position.x, this.position.y,
      other.position.x, other.position.y
    );
    
    // Примитивная проверка столкновения по расстоянию
    return distance < 15;
  }
  
  /**
   * Переопределяем destroy, чтобы уничтожить и графику кругов
   */
  destroy(removeFromScene?: boolean): void { // Используем параметр как в GameObject.destroy
    if (this.noiseCirclesGraphics) {
      this.noiseCirclesGraphics.destroy(removeFromScene); // Передаем тот же параметр
      this.noiseCirclesGraphics = null;
    }
    super.destroy(removeFromScene); // Передаем тот же параметр
  }
  
  /**
   * Получает мощность/скорость движения
   * @returns Текущий уровень мощности
   */
  public getPower(): number {
    return this.power;
  }
  
  /**
   * Устанавливает положение руля
   * @param newRudder Новое положение руля
   */
  public setRudder(newRudder: number): void {
    if (newRudder >= Vehicle.RUDER_RIGHT_15 && newRudder <= Vehicle.RUDER_LEFT_15) {
      this.rudder = newRudder;
    }
    
    // Обновляем интерфейс, если корабль под контролем
    if (this.underControl) {
      this.showRudder();
    }
  }
  
  /**
   * Отображает текущее положение руля в интерфейсе
   */
  protected showRudder(): void {
    // Получаем доступ к информеру через сцену как MainScene
    const mainScene = this.scene as any;
    const informer = mainScene.informer;
    if (!informer) {
      console.warn("Informer not available in showRudder");
      return;
    }
    
    console.log(`Setting rudder display to: ${this.rudder}`);
    console.log(`Тип информера: ${typeof informer}`);
    console.log(`Информер имеет метод setRudder: ${informer && typeof informer.setRudder === 'function'}`);
    
    switch (this.rudder) {
      case Vehicle.RUDER_0:
        console.log('Устанавливаем руль в положение 0');
        informer.setCommand("Прямо по курсу!");
        informer.setRudder("0");
        break;
        
      case Vehicle.RUDER_LEFT_5:
        console.log('Устанавливаем руль в положение L 5');
        informer.setCommand("Руль 5 градусов влево.");
        informer.setRudder("L 5");
        break;
        
      case Vehicle.RUDER_LEFT_10:
        console.log('Устанавливаем руль в положение L 10');
        informer.setCommand("Руль 10 градусов влево.");
        informer.setRudder("L 10");
        break;
        
      case Vehicle.RUDER_LEFT_15:
        console.log('Устанавливаем руль в положение L 15');
        informer.setCommand("Руль 15 градусов влево.");
        informer.setRudder("L 15");
        break;
        
      case Vehicle.RUDER_RIGHT_5:
        console.log('Устанавливаем руль в положение R 5');
        informer.setCommand("Руль 5 градусов вправо.");
        informer.setRudder("R 5");
        break;
        
      case Vehicle.RUDER_RIGHT_10:
        console.log('Устанавливаем руль в положение R 10');
        informer.setCommand("Руль 10 градусов вправо.");
        informer.setRudder("R 10");
        break;
        
      case Vehicle.RUDER_RIGHT_15:
        console.log('Устанавливаем руль в положение R 15');
        informer.setCommand("Руль 15 градусов вправо.");
        informer.setRudder("R 15");
        break;
        
      default:
        console.warn(`Unknown rudder value: ${this.rudder}`);
        informer.setRudder("?");
        break;
    }
  }
  
  /**
   * Получает текущее положение руля
   */
  public getRudder(): number {
    return this.rudder;
  }

  /**
   * Возвращает коэффициент мощности для расчета шума.
   * @returns Коэффициент, зависящий от текущей мощности двигателя.
   */
  protected getPowerFactorForNoise(): number {
    const absPower = Math.abs(this.power);
    // Значения подобраны на основе анализа calcNoise из VehicleMoving.as
    // где для POWER_0 был 0.05, для POWER_1 0.2, для POWER_2 1.0,
    // а для остальных, похоже, использовалось само значение мощности (или его модуль).
    // Для отрицательных мощностей (реверс) шум должен быть аналогичен.
    if (absPower === Vehicle.POWER_0) return 0.05;
    if (absPower === Vehicle.POWER_1) return 0.2;
    if (absPower === Vehicle.POWER_2) return 1.0;
    if (absPower === Vehicle.POWER_3) return 3.0;
    if (absPower === Vehicle.POWER_4) return 4.0;
    if (absPower === Vehicle.POWER_5) return 5.0;
    if (absPower === Vehicle.POWER_6) return 6.0;
    return 0; // На всякий случай, если мощность будет вне диапазона
  }

  /**
   * Рассчитывает базовый уровень шума, производимого объектом у источника,
   * до учета затухания с расстоянием и специфических модификаторов (например, глубины для подлодок).
   * Теперь также учитывает текущую скорость относительно максимальной для данной мощности.
   * @returns Базовый уровень шума у источника.
   */
  public getSourceNoiseLevel(): number {
    const noisy = this.intrinsicNoisiness; 
    const powerSettingFactor = this.getPowerFactorForNoise(); 

    if (this.getSpeed() < 0.1 && this.power === Vehicle.POWER_0) {
      return (3 * noisy * 1000000 * 0.05) / 36; // Минимальный шум для POWER_0 и стоянки
    }

    // Максимальная скорость для текущей *установки* мощности (может быть 0, если мощность POWER_0)
    const maxSpeedForCurrentPowerSetting = (this.power === Vehicle.POWER_0) ? 0 : (this.power / Vehicle.POWER_6) * this.maxVelocity;

    let speedRatio = 0;
    if (maxSpeedForCurrentPowerSetting > 0.1) {
      // Рассчитываем долю текущей скорости от максимальной для данной мощности
      speedRatio = Phaser.Math.Clamp(this.getSpeed() / maxSpeedForCurrentPowerSetting, 0, 1);
    } else if (this.power > Vehicle.POWER_0 && this.getSpeed() > 0.1) {
      // Если мощность задана (не P0), но макс. скорость для нее почти 0 (напр. P1), а корабль еще движется.
      // В этом случае, пусть шум будет основан на powerSettingFactor, так как он уже мал для низких мощностей.
      speedRatio = 1.0; 
    } else if (this.power === Vehicle.POWER_0 && this.getSpeed() > 0.1) {
      // Если мощность P0, но корабль еще движется по инерции, шум должен быть минимальным
      speedRatio = 0; // Это приведет к использованию Math.max(0, 0.05) ниже, что даст шум POWER_0
    }
    
    // Итоговый фактор, учитывающий и настройку мощности, и фактическую скорость.
    const scaledPowerFactor = powerSettingFactor * speedRatio;
    
    // Гарантируем минимальный шум работающего двигателя (эквивалент POWER_0), если мощность не 0, 
    // но scaledPowerFactor оказался меньше из-за очень низкой скорости.
    // Если мощность POWER_0, то scaledPowerFactor будет 0, и Math.max возьмет 0.05.
    // Если мощность > POWER_0 и scaledPowerFactor > 0.05, возьмется scaledPowerFactor.
    // Если мощность > POWER_0 и scaledPowerFactor < 0.05 (очень медленно едет), возьмется 0.05.
    const finalNoiseFactor = (this.power > Vehicle.POWER_0) ? Math.max(scaledPowerFactor, 0.05) : (this.getSpeed() < 0.1 ? 0.05 : scaledPowerFactor) ;

    return (3 * noisy * 1000000 * finalNoiseFactor) / 36;
  }

  /**
   * Возвращает конечную "силу" шума объекта, которую будут "слышать" другие.
   * Этот метод может быть переопределен в дочерних классах (например, Submarine)
   * для добавления специфических модификаторов (глубина, состояние перископа и т.д.).
   * @returns Эффективная сила шума объекта.
   */
  public getNoiseStrength(): number {
    // По умолчанию просто возвращаем базовый уровень шума от источника.
    // Дочерние классы могут добавить сюда свои модификаторы.
    return this.getSourceNoiseLevel();
  }

  /**
   * Обновляет и перерисовывает круги визуализации шума.
   */
  protected updateNoiseCircles(): void {
    if (!this.noiseCirclesGraphics) return;
    this.noiseCirclesGraphics.clear();

    // Рисуем круги только если объект выбран
    if (!this.displaySelected) {
      return;
    }

    const sourceNoiseOutput = this.getNoiseStrength();

    // Объект не шумит или шум слишком мал для отображения минимального порога
    // Пороги в AS очень низкие, поэтому отсечка по sourceNoiseOutput < 0.1 может быть слишком грубой.
    // Будем доверять тому, что если радиус получается <=0, круг не нарисуется.
    if (sourceNoiseOutput <= 0) { // Достаточно проверить, что шум вообще есть
        return;
    }

    for (const T of Vehicle.NOISE_DISPLAY_THRESHOLDS_AS) {
      if (T.threshold <= 0) continue;

      const radiusSquared = sourceNoiseOutput / T.threshold;
      if (radiusSquared <= 0) continue;

      let radius = Math.sqrt(radiusSquared);

      // В AS радиус умножался на main.getZoom().
      // В Phaser, если камера масштабирует сцену, то размеры объектов (включая графику)
      // также масштабируются. Поэтому явное умножение на зум здесь не нужно,
      // если noiseCirclesGraphics является частью отмасштабированной сцены.
      // Оставим пока без явного умножения на зум, так как графика привязана к сцене.
      
      // Ограничим максимальный радиус отображения, чтобы избежать слишком больших кругов
      // Это значение нужно будет подобрать. Settings.MAX_DETECTION_RANGE может быть слишком большим.
      const maxDisplayRadius = Settings.SCREEN_WIDTH * 2; // Например, два экрана

      if (radius > 0 && radius <= maxDisplayRadius) {
        this.noiseCirclesGraphics.lineStyle(T.lineThickness, T.color, T.alphaLine);
        // Круги рисуются относительно центра графического объекта (0,0),
        // а сам графический объект позиционируется по кораблю в Vehicle.update().
        this.noiseCirclesGraphics.strokeCircle(0, 0, radius);
      }
    }
  }

  // Метод setRotation уже есть в Phaser.GameObjects.Sprite, используем другое имя для нашего метода setSpriteRotation
  public setSpriteRotation(radians: number): void {
    super.setRotation(radians);
  }
} 