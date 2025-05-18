import Phaser from 'phaser';
import { Settings } from '../utils/Settings';
import { Statistic } from '../utils/Statistic';
import { Constants } from '../utils/Constants';
import { Vehicle } from '../objects/Vehicle';
import { Ship } from '../objects/Ship';
import { Submarine } from '../objects/Submarine';
import { TorpedoTypeI } from '../objects/TorpedoTypeI';
import { TorpedoTypeII } from '../objects/TorpedoTypeII';
import { TorpedoTypeIII } from '../objects/TorpedoTypeIII';
import { Torpedo } from '../objects/Torpedo';
import { Informer } from '../utils/Informer';
import { ScenarioManager } from '../scenario/ScenarioManager';
import { Obstruction } from '../objects/Obstruction';
import { Scenario } from '../scenario/Scenario';
import { CoordUtils } from '../utils/CoordUtils';

// Enum for player control states - ADDED
enum PlayerControlState {
  NORMAL,
  SELECTING_TORPEDO_TARGET,
}

/**
 * Основная игровая сцена
 */
export class MainScene extends Phaser.Scene {
  // Состояния игры
  static readonly STOPED: number = 0;
  static readonly STARTED: number = 1;
  
  // Состояния ввода
  static readonly ST_UNKNOWN: number = 0;
  static readonly ST_SELECT_TORP_WAY_POINT: number = 1;
  static readonly ST_SELECT_SHIP_WAY_POINT: number = 2;
  
  // Свойства
  private myShip: Ship | null = null;
  private redTorpedos: Torpedo[] = [];
  private whiteTorpedos: Torpedo[] = [];
  private redShips: Ship[] = [];
  private whiteShips: Ship[] = [];
  
  private weaponSelect: number = Constants.WEAPON_SELECT_UNKNOWN;
  private gameState: number = MainScene.STOPED;
  private zoom: number = 1.0;
  private deltaX: number = 0;
  private deltaY: number = 0;
  private timeLife: number = 0;
  private timeLastMove: number = 0;
  private timeLastSlowLoop: number = 0;
  private inputTextState: number = MainScene.ST_UNKNOWN;
  
  // Камеры
  private gameCamera: Phaser.Cameras.Scene2D.Camera | null = null;
  private uiCamera: Phaser.Cameras.Scene2D.Camera | null = null;
  
  // Защита от слишком частых нажатий клавиш
  private lastKeyPressTime: number = 0;
  private keyPressDelay: number = 300; // ms
  
  // Информационная панель
  public informer: Informer | null = null;
  
  // Менеджер сценариев
  private scenarioManager: ScenarioManager | null = null;
  
  // Карта препятствий
  private obstructions: Obstruction[] = [];
  
  // Свойства для перетаскивания камеры
  private isDragging: boolean = false;
  private dragStartX: number = 0;
  private dragStartY: number = 0;
  
  private gridGraphics: Phaser.GameObjects.Graphics | null = null;
  
  public selectedVehicleForInformer: Vehicle | null = null;
  
  // Added for torpedo targeting
  private playerControlState: PlayerControlState = PlayerControlState.NORMAL;
  private torpedoTargetCursor!: Phaser.GameObjects.Graphics | null;
  private torpedoAimingLine!: Phaser.GameObjects.Graphics | null;
  
  private debugPanelEnabled: boolean = true; // По умолчанию панель отладки включена
  
  /**
   * Конструктор
   */
  constructor() {
    super({ key: 'MainScene' });
  }
  
  /**
   * Предзагрузка ресурсов
   */
  preload(): void {
    // Загрузка изображений и звуков будет здесь
  }
  
  /**
   * Создание объектов сцены
   */
  create(): void {
    // Создаем камеры для игры и UI
    this.setupCameras();
    
    // Создаем графические элементы игровой зоны
    this.createGameArea();
    
    // Добавляем обработчики ввода
    const input = this.input as Phaser.Input.InputPlugin;
    input.on('pointerdown', this.handlePointerDown, this);
    input.on('pointermove', this.handlePointerMove, this);
    input.on('pointerup', this.handlePointerUp, this);
    
    // Используем только один способ обработки клавиш, удаляем дублирование
    if (input.keyboard) {
      input.keyboard.on('keydown', this.handleKeyDown, this);
    } else {
      // Запасной вариант, используем только если Phaser keyboard недоступен
      window.addEventListener('keydown', this.handleKeyDown.bind(this));
    }
    
    // Создаем информационную панель
    this.informer = new Informer(this);
    // Устанавливаем камеру для отображения UI
    if (this.informer && this.uiCamera) {
      this.informer.setCamera(this.uiCamera);
    }
    this.informer?.setPlayerName("Player 1");
    
    // Создаем менеджер сценариев
    this.scenarioManager = new ScenarioManager(this);
    
    // Создаем графический интерфейс
    this.createUI();
    
    // Инициализируем игру, но не запускаем автоматически
    this.initGame();
    
    // Обновляем настройки камер после создания всех объектов
    this.updateCamerasConfig();
  }
  
  /**
   * Настраивает камеры для игры и UI
   */
  private setupCameras(): void {
    // Основная камера - для игрового мира
    this.gameCamera = this.cameras.main;
    this.gameCamera.setZoom(1 / this.zoom);
    this.gameCamera.setName('gameCamera');
    this.gameCamera.setBackgroundColor(0x0000FF); // Устанавливаем синий фон для игровой камеры
    // Устанавливаем границы для игровой камеры, чтобы она не выходила за пределы мира
    this.gameCamera.setBounds(0, 0, Settings.GAME_WORLD_WIDTH, Settings.GAME_WORLD_HEIGHT);
    
    // UI камера - для интерфейса
    // Ее размер остается привязанным к SCREEN_WIDTH/HEIGHT
    this.uiCamera = this.cameras.add(0, 0, Settings.SCREEN_WIDTH, Settings.SCREEN_HEIGHT);
    this.uiCamera.setName('uiCamera');
    this.uiCamera.setScroll(0, 0); // UI всегда отображается от (0,0)
    this.uiCamera.transparent = true; // Прозрачный фон для UI камеры
    this.uiCamera.setZoom(1); // Не масштабировать UI
  }
  
  /**
   * Создает игровую зону и фон
   */
  private createGameArea(): void {
    // Создаем внешний темно-серый фон (видимый только при отдалении)
    // Его размер уже был Settings.SCREEN_WIDTH * 10, что теперь соответствует GAME_WORLD_WIDTH/HEIGHT
    const worldBg = this.add.rectangle(
      Settings.GAME_WORLD_WIDTH / 2, 
      Settings.GAME_WORLD_HEIGHT / 2,
      Settings.GAME_WORLD_WIDTH, 
      Settings.GAME_WORLD_HEIGHT,
      0x333333 // Темно-серый цвет
    );
    worldBg.setDepth(-100); // Ставим ниже всех объектов
    
    // Создаем сетку
    this.gridGraphics = this.add.graphics();
    this.gridGraphics.setDepth(-99); // Чуть выше фона, но ниже границы

    const gridSize = 100; // Размер ячейки сетки
    const gridColor = 0xCCCCCC; // Цвет сетки (светло-серый)
    const gridAlpha = 0.25;    // Прозрачность сетки
    const gridLineThickness = 1; // Толщина линий сетки

    this.gridGraphics.lineStyle(gridLineThickness, gridColor, gridAlpha);

    // Рисуем вертикальные линии на весь игровой мир
    for (let x = 0; x <= Settings.GAME_WORLD_WIDTH; x += gridSize) {
      this.gridGraphics.moveTo(x, 0);
      this.gridGraphics.lineTo(x, Settings.GAME_WORLD_HEIGHT);
    }
    // Рисуем горизонтальные линии на весь игровой мир
    for (let y = 0; y <= Settings.GAME_WORLD_HEIGHT; y += gridSize) {
      this.gridGraphics.moveTo(0, y);
      this.gridGraphics.lineTo(Settings.GAME_WORLD_WIDTH, y);
    }
    this.gridGraphics.strokePath(); // Завершаем отрисовку линий основной сетки

    // Рисуем центральные оси (логические 0,0) пунктиром
    const axisColor = 0xFFD700; // Золотистый цвет для осей
    const axisAlpha = 0.7;
    const axisThickness = 2;
    const dashLength = 15; // Длина штриха
    const gapLength = 10;  // Длина промежутка

    this.gridGraphics.lineStyle(axisThickness, axisColor, axisAlpha);

    // Логическая нулевая X-ось (вертикальная линия)
    const phaserZeroX = CoordUtils.logicalToPhaserX(0);
    for (let y = 0; y < Settings.GAME_WORLD_HEIGHT; y += (dashLength + gapLength)) {
      this.gridGraphics.moveTo(phaserZeroX, y);
      this.gridGraphics.lineTo(phaserZeroX, y + dashLength);
    }

    // Логическая нулевая Y-ось (горизонтальная линия)
    const phaserZeroY = CoordUtils.logicalToPhaserY(0);
    for (let x = 0; x < Settings.GAME_WORLD_WIDTH; x += (dashLength + gapLength)) {
      this.gridGraphics.moveTo(x, phaserZeroY);
      this.gridGraphics.lineTo(x + dashLength, phaserZeroY);
    }
    this.gridGraphics.strokePath(); // Завершаем отрисовку пунктирных осей

    // Создаем внутреннюю игровую зону (синий цвет не нужен, так как фон камеры уже синий)
    // Вместо этого создаем только белую границу по размерам всего игрового мира
    const border = this.add.graphics();
    border.lineStyle(4, 0xFFFFFF, 0.8); // Белая граница
    border.strokeRect(0, 0, Settings.GAME_WORLD_WIDTH, Settings.GAME_WORLD_HEIGHT);
    border.setDepth(-98); // Выше игровой зоны и сетки
    
    // Фоновые элементы должны видеться только в gameCamera, не в uiCamera
    if (this.uiCamera) {
      this.uiCamera.ignore([worldBg, this.gridGraphics, border]); // Добавляем gridGraphics в ignore
    }
  }
  
  /**
   * Инициализация игры без запуска
   */
  initGame(): void {
    // Сбрасываем статистику
    Statistic.reset();
    
    // Очищаем массивы объектов
    this.redTorpedos = [];
    this.whiteTorpedos = [];
    this.redShips = [];
    this.whiteShips = [];
    this.obstructions = [];
    
    // Сбрасываем время
    this.timeLife = 0;
    this.timeLastMove = 0;
    this.timeLastSlowLoop = 0;
    
    // Устанавливаем состояние игры как остановленное
    this.gameState = MainScene.STOPED;
    
    // Загружаем сценарий, но не запускаем игру
    if (this.scenarioManager) {
      this.scenarioManager.loadScenario('scenario1');
      this.scenarioManager.showMissionGoal();
      
      // Центрируем камеру на позиции игрока и устанавливаем myShip как выбранный для информера
      if (this.myShip) {
        const pos = this.myShip.getPosition();
        this.cameras.main.centerOn(pos.x, pos.y);
        this.setSelectedVehicleForInformer(this.myShip);
      }
    } else {
      // Если менеджер сценариев недоступен, используем стандартное создание объектов
      this.createDefaultObjects();
      
      // Центрируем камеру на позиции игрока и устанавливаем myShip как выбранный для информера
      if (this.myShip) {
        const pos = this.myShip.getPosition();
        this.cameras.main.centerOn(pos.x, pos.y);
        this.setSelectedVehicleForInformer(this.myShip);
      }
    }
    
    // Устанавливаем командный текст на информере
    if (this.informer) {
      this.informer.setCommand("Нажмите 'S' для начала игры.");
    }
  }
  
  /**
   * Создание пользовательского интерфейса
   */
  private createUI(): void {
    // Временная информация о версии
    (this.add as Phaser.GameObjects.GameObjectFactory).text(10, 10, Settings.CURRENT_SRS, { 
      color: '#ffffff',
      fontSize: '16px'
    });
  }
  
  /**
   * Запуск игры
   */
  startGame(): void {
    // Устанавливаем состояние игры
    this.gameState = MainScene.STARTED;
    
    // Скрываем цель миссии, если она показывается
    if (this.scenarioManager) {
      this.scenarioManager.getCurrentScenario()?.hideMissionGoal();
    }
    
    // Устанавливаем командный текст на информере
    if (this.informer) {
      this.informer.setCommand("Игра началась. Используйте клавиши 0-6 для управления скоростью.");
    }
  }
  
  /**
   * Остановка игры
   */
  stopGame(): void {
    // Устанавливаем состояние игры
    this.gameState = MainScene.STOPED;
    
    // Устанавливаем командный текст на информере
    if (this.informer) {
      this.informer.setCommand("Игра приостановлена. Нажмите 'S' для продолжения.");
    }
    
    // Показываем цель миссии
    if (this.scenarioManager) {
      this.scenarioManager.showMissionGoal();
    }
  }
  
  /**
   * Обработчик запуска/остановки игры
   */
  startStopHandler(): void {
    console.log(`Текущее состояние игры: ${this.gameState === MainScene.STARTED ? 'STARTED' : 'STOPPED'}`);
    
    if (this.gameState === MainScene.STARTED) {
      console.log('Останавливаю игру');
      this.stopGame();
    } else {
      console.log('Запускаю игру');
      this.startGame();
    }
    
    console.log(`Новое состояние игры: ${this.gameState === MainScene.STARTED ? 'STARTED' : 'STOPPED'}`);
  }
  
  /**
   * Создает стандартные объекты для демонстрации
   * Используется если менеджер сценариев недоступен
   */
  private createDefaultObjects(): void {
    // Задаем логические координаты (0,0 - центр мира)
    const playerLogicalX = 0;
    const playerLogicalY = 0;

    // Конвертируем в Phaser координаты для создания объекта
    const playerPhaserX = CoordUtils.logicalToPhaserX(playerLogicalX);
    const playerPhaserY = CoordUtils.logicalToPhaserY(playerLogicalY);
    this.createPlayerShip(playerPhaserX, playerPhaserY, Constants.FORCES_WHITE);
    
    // Размещаем вражеские корабли со смещением от центра в логических координатах
    const enemyOffsetLogical = Settings.SCREEN_WIDTH; // Используем SCREEN_WIDTH как меру смещения

    const enemy1LogicalX = enemyOffsetLogical;
    const enemy1LogicalY = -enemyOffsetLogical / 2;
    this.createEnemyShip(
      CoordUtils.logicalToPhaserX(enemy1LogicalX),
      CoordUtils.logicalToPhaserY(enemy1LogicalY),
      Constants.FORCES_RED, 
      false
    );

    const enemy2LogicalX = -enemyOffsetLogical;
    const enemy2LogicalY = enemyOffsetLogical / 2;
    this.createEnemyShip(
      CoordUtils.logicalToPhaserX(enemy2LogicalX),
      CoordUtils.logicalToPhaserY(enemy2LogicalY),
      Constants.FORCES_RED, 
      true
    );
  }
  
  /**
   * Обновление сцены
   * @param time Текущее время
   * @param delta Прошедшее время с последнего обновления
   */
  update(time: number, delta: number): void {
    // Обновляем время игры
    this.timeLife += delta;
    Statistic.time_game_sec = this.timeLife / 1000;
    
    // Обновляем информер если он существует
    if (this.informer) {
      this.informer.setTime(this.timeLife);
      
      // Обновляем данные с корабля игрока, если он существует
      if (this.myShip) {
        this.informer.setSpeed(this.myShip.getSpeed());
        this.informer.setDirection(this.myShip.getDirection().toString());
        this.informer.setPower(this.myShip.getPower().toString());
      }
      
      // Отображаем масштаб
      this.informer.setZoom(this.zoom);
    }
    
    // Проверяем, запущена ли игра
    if (this.gameState !== MainScene.STARTED) {
      return;
    }
    
    // Медленный цикл (обновление интерфейса, ИИ)
    if (time - this.timeLastSlowLoop > Settings.SLOW_LOOP_INTERVAL_MS) {
      this.updateSlowLoop(time);
      this.timeLastSlowLoop = time;
    }
    
    // Быстрый цикл (физика, движение)
    if (time - this.timeLastMove > Settings.MOVE_INTERVAL_MS) {
      this.updateFastLoop(delta);
      this.timeLastMove = time;
    }
  }
  
  /**
   * Медленный цикл обновления
   * @param time Текущее время
   */
  private updateSlowLoop(time: number): void {
    // Обновление информера
    if (this.informer) {
      this.informer.onSlowLoop(time);
      
      // Обновляем общую информацию в информере (не зависит от selectedVehicleForInformer)
      // Например, отладочная информация о камере и масштабе
      if (this.debugPanelEnabled && Settings.DEBUG && this.informer) { 
        this.informer.writeDebugText(`Камера: X=${Math.floor(this.cameras.main.scrollX)}, Y=${Math.floor(this.cameras.main.scrollY)}`);
        this.informer.writeDebugText(`Масштаб: ${this.zoom.toFixed(2)}`);
      }

      // Обновляем информацию о шуме и другие данные для selectedVehicleForInformer
      if (this.selectedVehicleForInformer) {
        const vehicle = this.selectedVehicleForInformer;
        const phaserPos = vehicle.getPosition(); 
        const logicalPosX = CoordUtils.phaserToLogicalX(phaserPos.x);
        const logicalPosY = CoordUtils.phaserToLogicalY(phaserPos.y);

        if (this.debugPanelEnabled && Settings.DEBUG && this.informer) {
            this.informer.writeDebugText(`Выбран: ID ${vehicle.id}, ${vehicle.constructor.name}`);
            this.informer.writeDebugText(`Позиция (лог): X=${Math.floor(logicalPosX)}, Y=${Math.floor(logicalPosY)}`);
            
            if (vehicle instanceof Submarine) {
              this.informer.writeDebugText(`Глубина: ${(vehicle as Submarine).getDepth()} м`);
              this.informer.writeDebugText(`Перископ: ${(vehicle as Submarine).periscope ? 'поднят' : 'опущен'}`);
            }
        }
        
        const noiseVal = vehicle.getNoiseStrength();
        this.informer.writeRightField("NOISE", noiseVal.toFixed(2));

        // Если selectedVehicleForInformer это myShip, обновляем специфичные для него данные
        if (vehicle === this.myShip) {
            this.informer.setSpeed(this.myShip.getSpeed());
            this.informer.setDirection(this.myShip.getDirection().toString());
            this.informer.setPower(this.myShip.getPower().toString());
             // Обновляем индикаторы торпед
            this.informer.panelLampReadyNotReady(
                Constants.LAMP_TRPRD_I, 
                this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_I)
            );
            this.informer.panelLampReadyNotReady(
                Constants.LAMP_TRPRD_II, 
                this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_II)
            );
            this.informer.panelLampReadyNotReady(
                Constants.LAMP_TRPRD_III, 
                this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_III)
            );
             // Обновляем индикатор наличия точек маршрута
            if (this.myShip.hasWayPoints()) {
                this.informer.panelLampActive(Constants.LAMP_WP);
            } else {
                this.informer.panelLampOff(Constants.LAMP_WP);
            }
            // Проверяем наличие торпед в радиусе атаки
            const hasEnemyTorpedosNearby = this.checkEnemyTorpedosNearby();
            if (hasEnemyTorpedosNearby) {
                this.informer.panelLampBlinkAlarmWarning(Constants.LAMP_TRP_ATACK);
            } else {
                this.informer.panelLampOff(Constants.LAMP_TRP_ATACK);
            }
        }

      } else {
        // Если ничего не выбрано, очищаем поле шума или ставим прочерк
        this.informer.writeRightField("NOISE", "--");
      }
    }
    
    // Обновление ИИ кораблей
    // Шаг 1 - анализ ситуации
    for (const ship of this.redShips) {
      if (!ship.isUnderControl()) {
        ship.AI_step_I();
      }
    }
    
    for (const ship of this.whiteShips) {
      if (!ship.isUnderControl()) {
        ship.AI_step_I();
      }
    }
    
    // Шаг 2 - реакция на угрозы
    for (const ship of this.redShips) {
      if (!ship.isUnderControl()) {
        ship.AI_step_II();
      }
    }
    
    for (const ship of this.whiteShips) {
      if (!ship.isUnderControl()) {
        ship.AI_step_II();
      }
    }
    
    // Обновление ИИ самонаводящихся торпед
    for (const torpedo of this.redTorpedos) {
      torpedo.AI_step_I();
      torpedo.AI_step_II();
    }
    
    for (const torpedo of this.whiteTorpedos) {
      torpedo.AI_step_I();
      torpedo.AI_step_II();
    }
    
    // Обновление индикаторов в информационной панели
    if (this.informer && this.myShip) {
      // Обновляем индикаторы торпед
      this.informer.panelLampReadyNotReady(
        Constants.LAMP_TRPRD_I, 
        this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_I)
      );
      
      this.informer.panelLampReadyNotReady(
        Constants.LAMP_TRPRD_II, 
        this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_II)
      );
      
      this.informer.panelLampReadyNotReady(
        Constants.LAMP_TRPRD_III, 
        this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_III)
      );
      
      // Обновляем индикатор наличия точек маршрута
      if (this.myShip.hasWayPoints()) {
        this.informer.panelLampActive(Constants.LAMP_WP);
      } else {
        this.informer.panelLampOff(Constants.LAMP_WP);
      }
      
      // Проверяем наличие торпед в радиусе атаки
      const hasEnemyTorpedosNearby = this.checkEnemyTorpedosNearby();
      if (hasEnemyTorpedosNearby) {
        this.informer.panelLampBlinkAlarmWarning(Constants.LAMP_TRP_ATACK);
      } else {
        this.informer.panelLampOff(Constants.LAMP_TRP_ATACK);
      }
    }
  }
  
  /**
   * Проверяет, есть ли торпеды противника рядом с кораблем игрока
   */
  private checkEnemyTorpedosNearby(): boolean {
    if (!this.myShip) return false;
    
    const enemyTorpedos = this.myShip.getForces() === Constants.FORCES_WHITE ? 
      this.redTorpedos : this.whiteTorpedos;
    
    for (const torpedo of enemyTorpedos) {
      const distance = Phaser.Math.Distance.Between(
        this.myShip.getPosition().x, this.myShip.getPosition().y,
        torpedo.getPosition().x, torpedo.getPosition().y
      );
      
      if (distance < Settings.TRP_ATACK_ALARM_DIST) {
        return true;
      }
    }
    
    return false;
  }
  
  /**
   * Быстрый цикл обновления (физика)
   * @param delta Прошедшее время
   */
  private updateFastLoop(delta: number): void {
    // Обновляем позиции объектов
    if (this.myShip) {
      this.myShip.update(this.timeLife, delta);
    }
    
    // Обновляем торпеды и корабли
    for (const torpedo of this.redTorpedos) {
      torpedo.update(this.timeLife, delta);
    }
    
    for (const torpedo of this.whiteTorpedos) {
      torpedo.update(this.timeLife, delta);
    }
    
    for (const ship of this.redShips) {
      if (!ship.isUnderControl()) {
        ship.update(this.timeLife, delta);
      }
    }
    
    for (const ship of this.whiteShips) {
      if (!ship.isUnderControl()) {
        ship.update(this.timeLife, delta);
      }
    }

    // Удаляем неактивные (уничтоженные) торпеды из массивов
    this.redTorpedos = this.redTorpedos.filter(t => t.active);
    this.whiteTorpedos = this.whiteTorpedos.filter(t => t.active);
    
    // Удаляем неактивные (уничтоженные) корабли из массивов
    this.redShips = this.redShips.filter(s => s.active);
    this.whiteShips = this.whiteShips.filter(s => s.active);
    
    // Проверяем условия завершения игры
    if (this.scenarioManager) {
      const gameState = this.scenarioManager.checkGameOver();
      if (gameState !== Scenario.GAME_CONTINUE) {
        this.scenarioManager.gameOver(gameState);
        this.gameState = MainScene.STOPED;
      }
    }
    
    // Проверка столкновений будет реализована позже
  }
  
  /**
   * Обработчик нажатия кнопки мыши
   * @param pointer Указатель мыши
   */
  private handlePointerDown(pointer: Phaser.Input.Pointer): void {
    // Координаты щелчка в мире игры
    const worldPoint = this.cameras.main.getWorldPoint(pointer.x, pointer.y);
    const logicalX = CoordUtils.phaserToLogicalX(worldPoint.x);
    const logicalY = CoordUtils.phaserToLogicalY(worldPoint.y);

    // --- START: Torpedo Targeting Logic ---
    if (this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
      if (pointer.leftButtonDown()) {
        if (this.myShip instanceof Submarine) {
          // fireTorpedoTypeIPlayer expects logical coordinates
          this.myShip.fireTorpedoTypeIPlayer(new Phaser.Math.Vector2(logicalX, logicalY)); 
          this.cancelTorpedoTargeting();
        }
      } else if (pointer.rightButtonDown()) {
        this.cancelTorpedoTargeting();
      }
      return; // Prevent other actions while targeting
    }
    // --- END: Torpedo Targeting Logic ---

    // Попробуем найти объект под курсором
    let clickedObject: Vehicle | null = null;
    const allVehicles: Vehicle[] = [...this.whiteShips, ...this.redShips, ...this.whiteTorpedos, ...this.redTorpedos];
    
    for (const vehicle of allVehicles) {
      if (!vehicle.active) { // Пропускаем неактивные (уничтоженные) объекты
        continue;
      }
      // Используем bounding box для проверки попадания
      if (vehicle.getBounds().contains(worldPoint.x, worldPoint.y)) {
        clickedObject = vehicle;
        break; 
      }
    }

    if (clickedObject) {
        this.setSelectedVehicleForInformer(clickedObject);
        // Если у объекта есть метод onClick, вызываем его
        if (typeof (clickedObject as any).onClick === 'function') {
            (clickedObject as any).onClick();
        }
    }

    // Начинаем перетаскивание камеры, только если это левая кнопка мыши
    // и если не был кликнут объект (чтобы не мешать выбору)
    if (pointer.leftButtonDown() && !clickedObject) {
      this.isDragging = true;
      this.dragStartX = pointer.x;
      this.dragStartY = pointer.y;
      return; // Завершаем обработку, чтобы не ставить WP при перетаскивании
    }
    
    // Обработка правого клика мыши для добавления путевой точки
    if (pointer.rightButtonDown()) {
      if (this.myShip && this.selectedVehicleForInformer === this.myShip) {
        // Сначала проверяем, не кликнули ли рядом с существующей WP для удаления
        const wayPoints = this.myShip.getWayPoints(); // Нужен метод для получения waypoints
        for (let i = 0; i < wayPoints.length; i++) {
          const wpData = wayPoints[i];
          // Графика WP уже находится в Phaser-координатах
          if (wpData.graphics) {
            const distanceToWpCenter = Phaser.Math.Distance.Between(
              worldPoint.x, worldPoint.y, 
              wpData.graphics.x, wpData.graphics.y
            );
            if (distanceToWpCenter < Settings.WAYPOINT_CLICK_DELETE_THRESHOLD) {
              this.myShip.removeSpecificWayPoint(i);
              if (this.informer) {
                this.informer.setCommand(`WP ${i} удалена.`);
              }
              console.log(`WP ${i} removed for myShip.`);
              return; // Завершаем обработку, точка удалена
            }
          }
        }

        // Если не удалили существующую, то добавляем новую
        const wasAlreadyMoving = this.myShip.isMovingOnWayPoint;
        this.myShip.addWayPoint(logicalX, logicalY, Constants.WP_TYPE_MOVE);
        
        if (!wasAlreadyMoving) { // Если он НЕ двигался до этого, то запускаем движение
          this.myShip.startMoveOnWP();
          if (this.informer) {
            this.informer.setCommand(`WP добавлена, идем к (лог.): X=${Math.floor(logicalX)}, Y=${Math.floor(logicalY)}`);
          }
          console.log(`WP added and starting move for myShip: LX=${logicalX.toFixed(0)}, LY=${logicalY.toFixed(0)}`);
        } else { // Если он УЖЕ двигался, то addWayPoint просто добавил точку в очередь
          if (this.informer) {
            this.informer.setCommand(`WP добавлена в маршрут (лог.): X=${Math.floor(logicalX)}, Y=${Math.floor(logicalY)}`);
          }
          console.log(`WP added to existing route for myShip: LX=${logicalX.toFixed(0)}, LY=${logicalY.toFixed(0)}`);
        }
      } else if (this.informer) {
        this.informer.setCommandAlarm("Выберите свой корабль для добавления WP");
      }
      return; // Правый клик только для WP, не продолжаем другую логику клика
    }

    if (this.gameState !== MainScene.STARTED || !this.myShip) {
      return;
    }
    
    // Обработка щелчка в зависимости от состояния
    switch (this.inputTextState) {
      case MainScene.ST_SELECT_SHIP_WAY_POINT:
        this.myShip.addWayPoint(logicalX, logicalY, Constants.WP_TYPE_MOVE);
        this.myShip.startMoveOnWP();
        if (this.informer) {
          this.informer.setCommand(`Установлена точка маршрута: ${Math.floor(logicalX)}, ${Math.floor(logicalY)}`);
        }
        break;
        
      case MainScene.ST_SELECT_TORP_WAY_POINT:
        // Проверяем, что выбрано оружие
        if (this.weaponSelect !== Constants.WEAPON_SELECT_UNKNOWN) {
          // Запускаем торпеду в выбранном направлении
          const torpedo = this.fireTorpedo(this.myShip, this.weaponSelect, logicalX, logicalY);
          
          if (torpedo && this.informer) {
            this.informer.setCommand(`Торпеда запущена в направлении: ${Math.floor(logicalX)}, ${Math.floor(logicalY)}`);
          } else if (this.informer) {
            this.informer.setCommandAlarm("Не удалось запустить торпеду! Оружие не готово.");
          }
          
          // Сбрасываем состояние выбора
          this.inputTextState = MainScene.ST_UNKNOWN;
          this.weaponSelect = Constants.WEAPON_SELECT_UNKNOWN;
        }
        break;
        
      default:
        // В обычном режиме левый щелчок просто выбирает точку движения
        // Если кликнули не по объекту и это левая кнопка
        if (!clickedObject && pointer.leftButtonDown() && this.myShip === this.selectedVehicleForInformer) {
          this.myShip.clearWayPoints(); // Очищаем предыдущий маршрут перед добавлением новой единственной точки
          this.myShip.addWayPoint(logicalX, logicalY, Constants.WP_TYPE_MOVE);
          this.myShip.startMoveOnWP();
          if (this.informer) {
            this.informer.setCommand(`Движение к (лог.): X=${Math.floor(logicalX)}, Y=${Math.floor(logicalY)}`);
          }
        }
        break;
    }
  }
  
  /**
   * Обработчик перемещения указателя мыши
   * @param pointer Указатель мыши
   */
  private handlePointerMove(pointer: Phaser.Input.Pointer): void {
    // --- START: Torpedo Targeting Logic ---
    if (this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
      this.updateTorpedoTargetCursor(pointer.worldX, pointer.worldY);
    }
    // --- END: Torpedo Targeting Logic ---

    if (!this.isDragging) return;
    
    // Вычисляем смещение в пикселях
    const deltaX = this.dragStartX - pointer.x;
    const deltaY = this.dragStartY - pointer.y;
    
    // Учитываем масштаб при перемещении камеры
    this.cameras.main.scrollX += deltaX * this.zoom;
    this.cameras.main.scrollY += deltaY * this.zoom;
    
    // Обновляем начальную позицию для следующего перемещения
    this.dragStartX = pointer.x;
    this.dragStartY = pointer.y;
  }
  
  /**
   * Обработчик отпускания кнопки мыши
   * @param pointer Указатель мыши
   */
  private handlePointerUp(pointer: Phaser.Input.Pointer): void {
    this.isDragging = false;
  }
  
  /**
   * Обработчик нажатия клавиш клавиатуры
   * @param event Событие нажатия клавиши
   */
  private handleKeyDown(event: KeyboardEvent): void {
    // Отладочная информация о нажатой клавише
    console.log(`Клавиша нажата: ${event.key}, код: ${event.keyCode || event.which}`);
    
    // Защита от двойного срабатывания в слишком короткий промежуток времени
    const currentTime = Date.now();
    if (currentTime - this.lastKeyPressTime < this.keyPressDelay) {
      console.log('Игнорирую слишком частое нажатие клавиши');
      return;
    }
    this.lastKeyPressTime = currentTime;
    
    // --- START: Debug Panel Toggle (Ctrl+B) ---
    if (event.ctrlKey && (event.key === 'b' || event.key === 'B' || (event.keyCode || event.which) === 66)) {
      this.debugPanelEnabled = !this.debugPanelEnabled;
      if (this.informer) {
        if (!this.debugPanelEnabled) {
          this.informer.clearDebugOutput(); 
        }
        this.informer.setCommand(this.debugPanelEnabled ? "Панель отладки: ВКЛ (Ctrl+B)" : "Панель отладки: ВЫКЛ (Ctrl+B)");
      }
      event.preventDefault(); // Предотвращаем стандартное действие браузера
      return; 
    }
    // --- END: Debug Panel Toggle ---
    
    // Обработка клавиши S для старта/стопа игры независимо от текущего состояния
    if (event.key === 's' || event.key === 'S' || event.keyCode === 83) {
      this.startStopHandler();
      return;
    }
    
    // Обработка масштабирования (Z/X) доступна всегда
    if (event.key === 'z' || event.key === 'Z' || event.keyCode === 90) {
      this.decreaseZoom(); // БЫЛО: this.increaseZoom();
      return;
    }
    
    if (event.key === 'x' || event.key === 'X' || event.keyCode === 88) {
      this.increaseZoom(); // БЫЛО: this.decreaseZoom();
      return;
    }
    
    // Обработка центрирования на корабле (C) доступна всегда, если есть корабль
    if ((event.key === 'c' || event.key === 'C' || event.keyCode === 67) && this.myShip) {
      this.centerOnShip();
      return;
    }
    
    // Если игра не запущена или нет корабля игрока, остальные клавиши не обрабатываем
    if (this.gameState !== MainScene.STARTED || !this.myShip) {
      console.log('Игра не запущена или нет корабля игрока');
      // Allow Esc to cancel targeting even if game is not "started" (e.g. in mission goal screen)
      if ((event.key === 'Escape' || event.keyCode === 27) && this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
        this.cancelTorpedoTargeting();
      }
      return;
    }
    
    // --- START: Torpedo Targeting Key Handling (ESC, ENTER before main switch) ---
    if (this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
      if (event.key === 'Escape' || event.keyCode === 27) { // Escape
        this.cancelTorpedoTargeting();
        return; // Consume event
      }
      if (event.key === 'Enter' || event.keyCode === 13) { // Enter
        if (this.myShip instanceof Submarine) {
          const worldX = this.input.activePointer.worldX;
          const worldY = this.input.activePointer.worldY;
          // Corrected: Use phaserToLogicalX and phaserToLogicalY
          const logicalPoint = new Phaser.Math.Vector2(
            CoordUtils.phaserToLogicalX(worldX),
            CoordUtils.phaserToLogicalY(worldY)
          );
          this.myShip.fireTorpedoTypeIPlayer(logicalPoint);
          this.cancelTorpedoTargeting();
        }
        return; // Consume event
      }
      // If in targeting mode, other keys (like Q, W, E for weapon switch) might be ignored or handled differently
      // For now, let's allow Q to re-trigger or select another torpedo if needed, or other keys to pass through
    }
    // --- END: Torpedo Targeting Key Handling ---

    // Обработка по ключу event.key или event.keyCode
    const key = event.key.toLowerCase();
    const keyCode = event.keyCode || event.which;

    switch(key) { // Сначала пробуем по event.key (предпочтительнее для читаемости)
      // Управление мощностью
      case '0':
        this.myShip.setPower(Vehicle.POWER_0);
        if (this.informer) this.informer.setCommand("Мощность: Стоп");
        break;
      case '1':
        this.myShip.setPower(Vehicle.POWER_1);
        if (this.informer) this.informer.setCommand("Мощность: 1");
        break;
      case '2':
        this.myShip.setPower(Vehicle.POWER_2);
        if (this.informer) this.informer.setCommand("Мощность: 2");
        break;
      case '3':
        this.myShip.setPower(Vehicle.POWER_3);
        if (this.informer) this.informer.setCommand("Мощность: 3");
        break;
      case '4':
        this.myShip.setPower(Vehicle.POWER_4);
        if (this.informer) this.informer.setCommand("Мощность: 4");
        break;
      case '5':
        this.myShip.setPower(Vehicle.POWER_5);
        if (this.informer) this.informer.setCommand("Мощность: 5");
        break;
      case '6':
        this.myShip.setPower(Vehicle.POWER_6);
        if (this.informer) this.informer.setCommand("Мощность: Полный ход");
        break;
        
      // Управление рулем (стрелки влево/вправо)
      case 'arrowleft':
      // case 'left':    // Для поддержки IE/Edge - event.key === 'ArrowLeft' стандартно
        console.log('Обработка стрелки влево по event.key');
        this.handleArrowLeft();
        break;
        
      case 'arrowright':
      // case 'right':   // Для поддержки IE/Edge - event.key === 'ArrowRight' стандартно
        console.log('Обработка стрелки вправо по event.key');
        this.handleArrowRight();
        break;
        
      // Изменение глубины для подводной лодки
      case 'u':
      case 'U':
        if (this.myShip instanceof Submarine) {
          // Всплытие
          const currentDepth = this.myShip.getDepth();
          this.myShip.setSubmDepth(currentDepth - 20);
          if (this.informer) this.informer.setCommand(`Глубина: ${this.myShip.getDepth()} м`);
        }
        break;
        
      case 'd':
      case 'D':
        if (this.myShip instanceof Submarine) {
          // Погружение
          const currentDepth = this.myShip.getDepth();
          this.myShip.setSubmDepth(currentDepth + 20);
          if (this.informer) this.informer.setCommand(`Глубина: ${this.myShip.getDepth()} м`);
        }
        break;
        
      // Управление перископом
      case 'p':
      case 'P':
        if (this.myShip instanceof Submarine) {
          if (this.myShip.periscope) {
            this.myShip.lowerPeriscope();
            if (this.informer) this.informer.setCommand("Перископ опущен");
          } else {
            this.myShip.raisePeriscope();
            if (this.informer) this.informer.setCommand("Перископ поднят");
          }
        }
        break;
        
      // Выбор оружия (оставляем q для удобства, но можно и только по keyCode)
      case 'q': // Intentional fall-through to keyCode check if needed, or handle directly
        // Логика для 'q' уже ниже по keyCode, либо можно ее сюда перенести полностью
        // Для чистоты, если хотим ТОЛЬКО по keyCode, этот case 'q' можно убрать,
        // а всю логику для Q поместить в switch(keyCode) или в if/else if ниже.
        // Пока оставим так, подразумевая, что основная логика Q будет по keyCode.
        break; // Пустой case, если основная обработка Q будет по keyCode
        
      case 'w':
        // Торпеда II
        this.weaponSelect = Constants.WEAPON_SELECT_TORP_II;
        this.inputTextState = MainScene.ST_SELECT_TORP_WAY_POINT;
        if (this.informer) {
          if (this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_II)) {
            this.informer.setCommand("Выбрана торпеда типа II. Кликните для выбора цели.");
          } else {
            this.informer.setCommandAlarm("Торпеда типа II не готова к запуску!");
          }
        }
        break;
        
      case 'e':
        // Торпеда III (самонаводящаяся)
        // If we are in torpedo targeting mode, pressing E should cancel it first
        if (this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
            this.cancelTorpedoTargeting();
        }
        this.weaponSelect = Constants.WEAPON_SELECT_TORP_III;
        this.inputTextState = MainScene.ST_SELECT_TORP_WAY_POINT;
        if (this.informer) {
          if (this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_III)) {
            this.informer.setCommand("Выбрана самонаводящаяся торпеда типа III. Кликните для выбора цели.");
          } else {
            this.informer.setCommandAlarm("Торпеда типа III не готова к запуску!");
          }
        }
        break;
        
      case 'escape':
        // --- MODIFIED: General Escape Logic ---
        // This is now handled above if in SELECTING_TORPEDO_TARGET state by event.key or keyCode.
        // If not in targeting mode, then do the original inputTextState reset.
        if (this.playerControlState !== PlayerControlState.SELECTING_TORPEDO_TARGET) {
            this.inputTextState = MainScene.ST_UNKNOWN;
            this.weaponSelect = Constants.WEAPON_SELECT_UNKNOWN;
            if (this.informer) this.informer.setCommand("Выбор отменен");
        }
        // --- END MODIFIED ---
        break;
      
      default:
        // Если по event.key не нашли, или для клавиш без стандартного event.key (как стрелки в старых браузерах)
        // или если мы хотим специфичную логику по keyCode для Q.
        break; // Просто выходим из switch(key)
    }

    // Дополнительная обработка по keyCode, особенно для Q и стрелок, если нужно
    // Это позволяет иметь и буквенные значения в switch(key) и числовые здесь.
    if (keyCode === 81) { // Key Q
        // --- MODIFIED: Torpedo Targeting Logic for Q (now by keyCode) ---
        if (this.myShip instanceof Submarine && this.myShip.getTorpOnBoard(Constants.WEAPON_SELECT_TORP_I) > 0) { 
          this.playerControlState = PlayerControlState.SELECTING_TORPEDO_TARGET;
          if (this.informer) this.informer.setCommand("TORPEDO AIM: SELECT TARGET (Enter/LMB)"); 
          
          if (!this.torpedoTargetCursor) {
            this.torpedoTargetCursor = this.add.graphics();
            this.torpedoTargetCursor.setDepth(Constants.DEPTH_UI_ELEMENTS + 1); 
          }
          this.torpedoTargetCursor.setVisible(true);

          if (!this.torpedoAimingLine) {
            this.torpedoAimingLine = this.add.graphics();
            this.torpedoAimingLine.setDepth(Constants.DEPTH_UI_ELEMENTS); 
          }
          this.torpedoAimingLine.setVisible(true);
          
          this.updateTorpedoTargetCursor(this.input.activePointer.worldX, this.input.activePointer.worldY);
          
          this.weaponSelect = Constants.WEAPON_SELECT_TORP_I;

        } else if (this.informer) {
            if (!(this.myShip instanceof Submarine)) {
                this.informer.setCommandAlarm("Только подлодки могут использовать этот режим прицеливания.");
            } else {
                this.informer.setCommandAlarm("Торпеды типа I отсутствуют или не готовы!");
            }
        }
        // --- END MODIFIED ---
    } 
    // УДАЛЕНО ДУБЛИРОВАНИЕ ОБРАБОТКИ СТРЕЛОК ПО keyCode
    // else if (keyCode === 37 && (key === 'arrowleft' || key === 'left')) { 
    //     console.log('Обработка стрелки влево по keyCode');
    //     this.handleArrowLeft();
    // } else if (keyCode === 39 && (key === 'arrowright' || key === 'right')) { 
    //     console.log('Обработка стрелки вправо по keyCode');
    //     this.handleArrowRight();
    // }
    // Другие обработки по keyCode, если необходимы
  }
  
  /**
   * Обработка нажатия клавиши влево
   */
  private handleArrowLeft(): void {
    if (this.myShip && this.myShip.isUnderControl()) {
      let currentRudder = this.myShip.getRudder();
      // Увеличиваем руль влево (уменьшаем значение, так как левый руль - отрицательные или меньшие положительные значения в AS, а у нас положительные)
      // RUDER_LEFT_5 = 1, RUDER_LEFT_10 = 2, RUDER_LEFT_15 = 3
      if (currentRudder < Vehicle.RUDER_LEFT_15) {
        currentRudder++;
      } else {
        currentRudder = Vehicle.RUDER_LEFT_15; // Уже на максимуме влево
      }
      this.myShip.setRudder(currentRudder);
      console.log("Arrow Left: Rudder set to", currentRudder);
    }
  }
  
  /**
   * Обработка нажатия клавиши вправо
   */
  private handleArrowRight(): void {
    if (this.myShip && this.myShip.isUnderControl()) {
      let currentRudder = this.myShip.getRudder();
      // Увеличиваем руль вправо (увеличиваем значение, так как правый руль - положительные или большие отрицательные значения в AS, а у нас отрицательные)
      // RUDER_RIGHT_5 = -1, RUDER_RIGHT_10 = -2, RUDER_RIGHT_15 = -3
      if (currentRudder > Vehicle.RUDER_RIGHT_15) {
        currentRudder--;
      } else {
        currentRudder = Vehicle.RUDER_RIGHT_15; // Уже на максимуме вправо
      }
      this.myShip.setRudder(currentRudder);
      console.log("Arrow Right: Rudder set to", currentRudder);
    }
  }
  
  /**
   * Получает корабль игрока
   */
  public getMyShip(): Ship | null {
    return this.myShip;
  }
  
  /**
   * Получает массив красных кораблей
   */
  public getRedShips(): Ship[] {
    return this.redShips;
  }
  
  /**
   * Получает массив белых кораблей
   */
  public getWhiteShips(): Ship[] {
    return this.whiteShips;
  }
  
  /**
   * Получает массив красных торпед
   */
  public getRedTorpedos(): Torpedo[] {
    return this.redTorpedos;
  }
  
  /**
   * Получает массив белых торпед
   */
  public getWhiteTorpedos(): Torpedo[] {
    return this.whiteTorpedos;
  }
  
  /**
   * Проверяет, запущена ли игра
   */
  public isStarted(): boolean {
    return this.gameState === MainScene.STARTED;
  }
  
  /**
   * Создает корабль игрока
   * @param x Позиция X
   * @param y Позиция Y
   * @param forces Принадлежность к силам
   */
  public createPlayerShip(x: number, y: number, forces: number = Constants.FORCES_WHITE): Ship {
    // Создаем подлодку игрока
    const ship = new Submarine(this, x, y, forces);
    ship.setUnderControl(true);
    // ship.setSelected(true); // setSelected будет управляться через setSelectedVehicleForInformer

    // Принудительная перерисовка для правильного отображения
    if (ship instanceof Submarine) {
      (ship as Submarine).drawVehicle();
    }
    
    console.log("Корабль игрока создан:", ship);
    console.log("underControl =", ship.isUnderControl());
    console.log("Тип корабля:", ship.constructor.name);
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redShips.push(ship);
    } else {
      this.whiteShips.push(ship);
    }
    
    // Устанавливаем как управляемый корабль и выбранный для информера
    this.myShip = ship;
    this.setSelectedVehicleForInformer(ship);
    
    return ship;
  }
  
  /**
   * Создает вражеский корабль
   * @param x Позиция X
   * @param y Позиция Y
   * @param forces Принадлежность к силам
   * @param isSubmarine Является ли подводной лодкой
   */
  public createEnemyShip(
    x: number, 
    y: number, 
    forces: number = Constants.FORCES_RED, 
    isSubmarine: boolean = false
  ): Ship {
    // Создаем корабль противника
    let ship: Ship;
    
    if (isSubmarine) {
      ship = new Submarine(this, x, y, forces);
    } else {
      ship = new Ship(this, x, y, forces);
    }
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redShips.push(ship);
    } else {
      this.whiteShips.push(ship);
    }
    
    return ship;
  }
  
  /**
   * Добавляет препятствие в сцену
   * @param obstruction Объект препятствия
   */
  public addObstruction(obstruction: Obstruction): void {
    this.obstructions.push(obstruction);
  }
  
  /**
   * Удаляет все препятствия
   */
  public clearObstructions(): void {
    this.obstructions.forEach(obs => obs.destroy());
    this.obstructions = [];
    // Также очистим графику, если она была частью объектов Obstruction и не удалилась с ними
  }
  
  /**
   * Проверяет столкновение с препятствиями
   * @param x Координата X
   * @param y Координата Y
   * @returns true если есть столкновение
   */
  public checkObstructionCollision(x: number, y: number): boolean {
    for (const obstruction of this.obstructions) {
      if (obstruction.containsPoint(x, y)) {
        return true;
      }
    }
    return false;
  }
  
  /**
   * Получает текущий масштаб сцены
   */
  public getZoom(): number {
    return this.zoom;
  }
  
  /**
   * Увеличивает масштаб (приближение)
   */
  private increaseZoom(): void {
    // Уменьшаем значение зума (что делает объекты крупнее)
    this.zoom *= 0.5;
    
    // Ограничиваем минимальный зум
    if (this.zoom < 0.25) {
      this.zoom = 0.25;
      if (this.informer) {
        this.informer.setCommand("Максимальное приближение!");
      }
    }
    
    // Обновляем зум камеры
    this.updateCameraZoom();
    
    // Обновляем индикатор зума
    if (this.informer) {
      this.informer.setZoom(this.zoom);
      this.informer.setCommand(`Масштаб: ${this.zoom.toFixed(2)}`);
    }
    
    console.log(`Zoom увеличен: ${this.zoom}`);
  }
  
  /**
   * Уменьшает масштаб (отдаление)
   */
  private decreaseZoom(): void {
    // Увеличиваем значение зума (что делает объекты мельче)
    this.zoom /= 0.5;
    
    // Ограничиваем максимальный зум
    if (this.zoom > 4) {
      this.zoom = 4;
      if (this.informer) {
        this.informer.setCommand("Максимальное отдаление!");
      }
    }
    
    // Обновляем зум камеры
    this.updateCameraZoom();
    
    // Обновляем индикатор зума
    if (this.informer) {
      this.informer.setZoom(this.zoom);
      this.informer.setCommand(`Масштаб: ${this.zoom.toFixed(2)}`);
    }
    
    console.log(`Zoom уменьшен: ${this.zoom}`);
  }
  
  /**
   * Центрирует камеру на корабле игрока
   */
  private centerOnShip(): void {
    if (!this.myShip) return;
    
    // Получаем позицию корабля игрока
    const shipPos = this.myShip.getPosition();
    
    // Центрируем камеру на позиции корабля
    this.cameras.main.centerOn(shipPos.x, shipPos.y);
    
    if (this.informer) {
      this.informer.setCommand("Центрирование на корабле");
    }
    
    console.log(`Центрирование на позиции: ${shipPos.x}, ${shipPos.y}`);
  }
  
  /**
   * Обновляет масштаб камеры и настройки отображения
   */
  private updateCameraZoom(): void {
    // Устанавливаем масштаб ТОЛЬКО для основной камеры
    if (this.gameCamera) {
      this.gameCamera.setZoom(1 / this.zoom);
      console.log(`Масштаб игровой камеры установлен: ${1 / this.zoom}`);
    }
    
    // UI камера всегда с фиксированным масштабом 1
    if (this.uiCamera) {
      this.uiCamera.setZoom(1);
    }
    
    // Обновляем настройки камер после изменения масштаба
    this.updateCamerasConfig();
  }
  
  /**
   * Обновляет настройки камер и прикрепление объектов к ним
   */
  private updateCamerasConfig(): void {
    if (!this.gameCamera || !this.uiCamera) return;
    
    // Получаем все объекты сцены
    const allObjects = this.children.list;
    
    // Получаем UI элементы из Informer
    const uiElements: Phaser.GameObjects.GameObject[] = [];
    
    // Если у нас есть Informer, получаем все его UI элементы
    if (this.informer) {
      const informerElements = this.informer.getAllUIElements();
      uiElements.push(...informerElements);
    }
    
    // Добавляем версию игры (текст в верхнем углу)
    const versionText = allObjects.find(obj => 
      obj instanceof Phaser.GameObjects.Text && 
      (obj as Phaser.GameObjects.Text).text === Settings.CURRENT_SRS
    );
    
    if (versionText) {
      uiElements.push(versionText);
    }
    
    // Игнорируем все UI элементы в основной камере
    this.gameCamera.ignore(uiElements);
    
    // Игнорируем все не-UI элементы в UI камере
    const gameObjects = allObjects.filter(obj => !uiElements.includes(obj));
    this.uiCamera.ignore(gameObjects);
    
    console.log(`Настроены камеры: UI элементов - ${uiElements.length}, игровых объектов - ${gameObjects.length}`);
  }
  
  /**
   * Устанавливает выбранный для отображения в информере объект.
   * @param vehicle Объект Vehicle или null, если ничего не выбрано.
   */
  public setSelectedVehicleForInformer(vehicle: Vehicle | null): void {
    // Сбрасываем флаг setSelected у предыдущего выбранного объекта, если он был
    if (this.selectedVehicleForInformer && this.selectedVehicleForInformer !== vehicle) {
      this.selectedVehicleForInformer.setSelected(false);
    }

    this.selectedVehicleForInformer = vehicle;

    // Устанавливаем флаг setSelected у нового объекта
    if (this.selectedVehicleForInformer) {
      this.selectedVehicleForInformer.setSelected(true);
    }

    // Можно добавить дополнительную логику, например, центрирование камеры на выбранном объекте,
    // или обновление специфичных частей UI.
    console.log(`Выбран для информера: ${vehicle ? vehicle.constructor.name + ' ID ' + vehicle.id : 'null'}`);
  }

  // --- START: Added Torpedo Targeting Methods ---
  private cancelTorpedoTargeting() {
    this.playerControlState = PlayerControlState.NORMAL;
    if (this.torpedoTargetCursor) {
      this.torpedoTargetCursor.clear(); // Clear graphics before hiding
      this.torpedoTargetCursor.setVisible(false);
    }
    if (this.torpedoAimingLine) {
      this.torpedoAimingLine.clear(); // Clear graphics before hiding
      this.torpedoAimingLine.setVisible(false);
    }
    if (this.informer) this.informer.setCommand("Targeting cancelled. Ready."); // Changed to setCommand and cleared message
    console.log("[MainScene] Torpedo targeting cancelled.");
  }

  private updateTorpedoTargetCursor(phaserX: number, phaserY: number) {
    if (!this.myShip) return;

    if (this.torpedoTargetCursor && this.torpedoTargetCursor.visible) {
      const size = 15; // Size of the crosshair
      this.torpedoTargetCursor.clear();
      this.torpedoTargetCursor.lineStyle(2, 0x0000FF, 1); // Blue color for the crosshair
      this.torpedoTargetCursor.beginPath();
      this.torpedoTargetCursor.moveTo(phaserX - size, phaserY);
      this.torpedoTargetCursor.lineTo(phaserX + size, phaserY);
      this.torpedoTargetCursor.moveTo(phaserX, phaserY - size);
      this.torpedoTargetCursor.lineTo(phaserX, phaserY + size);
      this.torpedoTargetCursor.strokePath();
    }
    if (this.torpedoAimingLine && this.torpedoAimingLine.visible && this.playerControlState === PlayerControlState.SELECTING_TORPEDO_TARGET) {
        this.torpedoAimingLine.clear();
        this.torpedoAimingLine.lineStyle(1, 0x00FFFF, 0.5); // Thin, semi-transparent cyan line
        this.torpedoAimingLine.beginPath();
        // Ensure myShip coordinates are up-to-date Phaser world coordinates
        const shipPhaserPos = this.myShip.getPosition(); 
        this.torpedoAimingLine.moveTo(shipPhaserPos.x, shipPhaserPos.y);
        this.torpedoAimingLine.lineTo(phaserX, phaserY);
        this.torpedoAimingLine.strokePath();
    }
  }
  // --- END: Added Torpedo Targeting Methods ---

  // Уничтожаем и графику сетки при уничтожении сцены
  destroy() {
    if (this.gridGraphics) {
        this.gridGraphics.destroy();
        this.gridGraphics = null;
    }
    // Destroy torpedo targeting graphics if they exist
    if (this.torpedoTargetCursor) {
        this.torpedoTargetCursor.destroy();
        this.torpedoTargetCursor = null;
    }
    if (this.torpedoAimingLine) {
        this.torpedoAimingLine.destroy();
        this.torpedoAimingLine = null;
    }
    // Здесь нужно вызвать super.destroy() или убедиться, что Phaser это делает.
    // В GameObject.destroy() есть параметр removeFromScene, но для Scene его нет.
    // Обычно Phaser сам управляет уничтожением объектов сцены.
  }

  /**
   * Method to be called by Submarine (or other ships) when it creates a torpedo directly.
   * This ensures the torpedo is added to the scene and relevant tracking arrays.
   * @param torpedo The torpedo instance to register.
   */
  public registerCreatedTorpedo(torpedo: Torpedo): void {
    this.add.existing(torpedo); // Add to scene for rendering and updates

    // Add to specific tracking arrays based on forces
    if (torpedo.getForces() === Constants.FORCES_RED) {
      this.redTorpedos.push(torpedo);
    } else {
      this.whiteTorpedos.push(torpedo);
    }
    console.log(`[MainScene] Torpedo ${torpedo.id} registered. Forces: ${torpedo.getForces() === Constants.FORCES_RED ? 'RED' : 'WHITE'}`);
  }

  // --- START: Refactored Torpedo Creation Logic ---

  /**
   * Создает и регистрирует торпеду в сцене.
   * @param launchX Phaser координата X для старта торпеды
   * @param launchY Phaser координата Y для старта торпеды
   * @param launchAngleDeg Начальный угол торпеды в градусах
   * @param forces Принадлежность торпеды
   * @param weaponType Тип торпеды (WEAPON_SELECT_TORP_I/II/III)
   * @param targetXForWP Опционально, Phaser X-координата цели для WP (для TorpedoTypeII)
   * @param targetYForWP Опционально, Phaser Y-координата цели для WP (для TorpedoTypeII)
   * @returns Созданный объект Torpedo или null, если не удалось создать.
   */
  private _spawnAndRegisterTorpedo(
    launchX: number, 
    launchY: number, 
    launchAngleDeg: number, 
    forces: number, 
    weaponType: number,
    targetXForWP?: number,
    targetYForWP?: number
  ): Torpedo | null {
    let torpedo: Torpedo | null = null;

    switch (weaponType) {
      case Constants.WEAPON_SELECT_TORP_I:
        torpedo = this._createTorpedoTypeI(launchX, launchY, launchAngleDeg, forces);
        break;
      case Constants.WEAPON_SELECT_TORP_II:
        torpedo = this._createTorpedoTypeII(launchX, launchY, launchAngleDeg, forces);
        if (torpedo && targetXForWP !== undefined && targetYForWP !== undefined) {
          // Для торпеды типа II добавляем цель как точку маршрута
          // Координаты для WP должны быть логическими
          (torpedo as TorpedoTypeII).addWayPoint(
            CoordUtils.phaserToLogicalX(targetXForWP), 
            CoordUtils.phaserToLogicalY(targetYForWP), 
            Constants.WP_TYPE_TARGET
          );
          (torpedo as TorpedoTypeII).startMoveOnWP();
        }
        break;
      case Constants.WEAPON_SELECT_TORP_III:
        torpedo = this._createTorpedoTypeIII(launchX, launchY, launchAngleDeg, forces);
        break;
      default:
        if (this.informer) {
          this.informer.setCommandAlarm("Неизвестный тип оружия для _spawnAndRegisterTorpedo!");
        }
        return null;
    }

    if (torpedo) {
      this.registerCreatedTorpedo(torpedo); // Добавляет в сцену и массивы
    }
    
    return torpedo;
  }

  /**
   * Создает экземпляр торпеды типа I.
   * (Ранее createTorpedoTypeI, переименован для ясности, что это только создание экземпляра)
   */
  private _createTorpedoTypeI(x: number, y: number, angle: number, forces: number): TorpedoTypeI {
    const params = { /* ... параметры из Settings ... */ }; // Будет заполнено
    // Логика получения параметров из Settings и создания new TorpedoTypeI
    // Это должно быть скопировано из старого createTorpedoTypeI
    // ...
    // return new TorpedoTypeI(this, x, y, angle, params, forces);
    // ЗАГЛУШКА, будет заполнено ниже
    const trpParams = {
      maxVelocity: Settings.TRP_I_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_I_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_I_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_I_TIME_RELOAD_SEC,
      damage: Settings.TRP_I_DAMEGE,
      executionDist: Settings.TRP_I_DIST_EXECUTION,
      type: Constants.WEAPON_SELECT_TORP_I // Добавим тип для информации
    };
    return new TorpedoTypeI(this, x, y, angle, trpParams, forces);
  }

  /**
   * Создает экземпляр торпеды типа II.
   */
  private _createTorpedoTypeII(x: number, y: number, angle: number, forces: number): TorpedoTypeII {
    // ЗАГЛУШКА, будет заполнено ниже
    const trpParams = {
      maxVelocity: Settings.TRP_II_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_II_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_II_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_II_TIME_RELOAD_SEC,
      damage: Settings.TRP_II_DAMEGE,
      executionDist: Settings.TRP_II_DIST_EXECUTION,
      type: Constants.WEAPON_SELECT_TORP_II
    };
    return new TorpedoTypeII(this, x, y, angle, trpParams, forces);
  }

  /**
   * Создает экземпляр торпеды типа III.
   */
  private _createTorpedoTypeIII(x: number, y: number, angle: number, forces: number): TorpedoTypeIII {
    // ЗАГЛУШКА, будет заполнено ниже
    const trpParams = {
      maxVelocity: Settings.TRP_III_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_III_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_III_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_III_TIME_RELOAD_SEC,
      damage: Settings.TRP_III_DAMEGE,
      executionDist: Settings.TRP_III_DIST_EXECUTION,
      targetAcceptDist: Settings.TRP_III_TRG_ACCEPT_DIST, // Специфично для TypeIII
      type: Constants.WEAPON_SELECT_TORP_III
    };
    return new TorpedoTypeIII(this, x, y, angle, trpParams, forces);
  }
  
  // --- END: Refactored Torpedo Creation Logic ---

  /**
   * Запускает торпеду с корабля (обновленный)
   * @param ship Корабль, с которого запускается торпеда
   * @param weaponType Тип оружия
   * @param targetX Целевая координата X (Phaser world coordinates)
   * @param targetY Целевая координата Y (Phaser world coordinates)
   */
  public fireTorpedo(ship: Ship, weaponType: number, targetX: number, targetY: number): Torpedo | null {
    // 1. Проверяем готовность оружия у корабля (остается здесь)
    if (!ship.isWeaponReady(weaponType)) {
      if (this.informer) {
        this.informer.setCommandAlarm("Оружие не готово! (Вызов из fireTorpedo)");
      }
      return null;
    }
    
    // 2. Рассчитываем параметры запуска (позиция, угол)
    const shipPos = ship.getPosition(); // Phaser world coordinates
    const shipDir = ship.getDirection(); // Градусы
    
    const launchDist = 15; // Расстояние от центра корабля для точки старта торпеды
    const launchX = shipPos.x + Math.sin(Phaser.Math.DegToRad(shipDir)) * launchDist;
    const launchY = shipPos.y - Math.cos(Phaser.Math.DegToRad(shipDir)) * launchDist;
    
    // Угол направления на цель от точки запуска торпеды
    let launchAngleDeg = shipDir; // По умолчанию - текущий курс корабля

    // --- ИЗМЕНЕНИЕ ДЛЯ КУРСА ТОРПЕД ПОДЛОДКИ ---
    if (ship instanceof Submarine) {
      // Для подводных лодок торпеда всегда выходит по курсу лодки
      launchAngleDeg = shipDir;
      // targetX, targetY будут использованы для установки первой WP торпеды
    } else {
      // Для надводных кораблей (или если логика изменится), оставляем возможность наведения на цель
      if (targetX !== undefined && targetY !== undefined) { 
        launchAngleDeg = Phaser.Math.RadToDeg(
          Phaser.Math.Angle.Between(launchX, launchY, targetX, targetY)
        );
        launchAngleDeg = (launchAngleDeg + 90 + 360) % 360;
      }
    }
    // --- КОНЕЦ ИЗМЕНЕНИЯ ---
    
    const forces = ship.getForces();
    
    // 3. Вызываем новый метод для фактического создания и регистрации торпеды
    const torpedo = this._spawnAndRegisterTorpedo(
      launchX, 
      launchY, 
      launchAngleDeg, 
      forces, 
      weaponType,
      targetX, // Передаем исходные targetX, targetY для WP торпеды TypeII
      targetY
    );

    // 4. Обновляем информер (если торпеда успешно создана)
    // Эту логику можно оставить здесь или перенести в AIWeaponControl/PlayerControls
    if (torpedo && this.informer && ship === this.myShip) { // Только для корабля игрока
        const logicalTargetX = CoordUtils.phaserToLogicalX(targetX);
        const logicalTargetY = CoordUtils.phaserToLogicalY(targetY);
        this.informer.setCommand(`Торпеда ${weaponType} запущена в направлении (лог.): ${Math.floor(logicalTargetX)}, ${Math.floor(logicalTargetY)}`);
    } else if (!torpedo && this.informer && ship === this.myShip) {
        this.informer.setCommandAlarm("Не удалось запустить торпеду! (после _spawnAndRegisterTorpedo)");
    }
    
    // Важно! После выстрела корабль должен запустить перезарядку
    // Это делается в ship.decrementTorpCount(), который вызывается из fireTorpedoTypeIPlayer (Submarine)
    // или должен вызываться после успешного выстрела ИИ.
    // AIWeaponControl должен вызывать ship.decrementTorpCount() ПОСЛЕ успешного вызова mainScene.fireTorpedo.
    if (torpedo) {
        ship.decrementTorpCount(weaponType); // Запускаем перезарядку и уменьшаем счетчик
    }

    return torpedo;
  }
} 