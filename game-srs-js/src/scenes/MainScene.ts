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
    // Инициализируем основную камеру
    this.cameras.main.setZoom(1 / this.zoom);
    
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
    this.informer.setPlayerName("Player 1");
    
    // Создаем менеджер сценариев
    this.scenarioManager = new ScenarioManager(this);
    
    // Создаем графический интерфейс
    this.createUI();
    
    // Инициализируем игру, но не запускаем автоматически
    this.initGame();
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
      
      // Центрируем камеру на позиции игрока
      if (this.myShip) {
        const pos = this.myShip.getPosition();
        this.cameras.main.centerOn(pos.x, pos.y);
      }
    } else {
      // Если менеджер сценариев недоступен, используем стандартное создание объектов
      this.createDefaultObjects();
      
      // Центрируем камеру на позиции игрока
      if (this.myShip) {
        const pos = this.myShip.getPosition();
        this.cameras.main.centerOn(pos.x, pos.y);
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
    // Создаем корабль игрока (подводная лодка)
    this.createPlayerShip(100, 350, Constants.FORCES_WHITE);
    
    // Создаем вражеские корабли (для демонстрации)
    this.createEnemyShip(800, 100, Constants.FORCES_RED, false);
    this.createEnemyShip(600, 500, Constants.FORCES_RED, true);
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
      
      // Добавляем отладочную информацию о позиции подводной лодки
      if (this.myShip) {
        const pos = this.myShip.getPosition();
        this.informer.writeDebugText(`Позиция: X=${Math.floor(pos.x)}, Y=${Math.floor(pos.y)}`);
        
        if (this.myShip instanceof Submarine) {
          this.informer.writeDebugText(`Глубина: ${(this.myShip as Submarine).getDepth()} м`);
          this.informer.writeDebugText(`Перископ: ${(this.myShip as Submarine).periscope ? 'поднят' : 'опущен'}`);
        }
        
        // Добавляем отладочную информацию о позиции камеры
        this.informer.writeDebugText(`Камера: X=${Math.floor(this.cameras.main.scrollX)}, Y=${Math.floor(this.cameras.main.scrollY)}`);
        this.informer.writeDebugText(`Масштаб: ${this.zoom.toFixed(2)}`);
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
    // Начинаем перетаскивание камеры, только если это левая кнопка мыши
    if (pointer.leftButtonDown()) {
      this.isDragging = true;
      this.dragStartX = pointer.x;
      this.dragStartY = pointer.y;
    }
    
    if (this.gameState !== MainScene.STARTED || !this.myShip) {
      return;
    }
    
    // Координаты щелчка
    const x = pointer.x;
    const y = pointer.y;
    
    // Обработка щелчка в зависимости от состояния
    switch (this.inputTextState) {
      case MainScene.ST_SELECT_SHIP_WAY_POINT:
        this.myShip.addWayPoint(x, y);
        this.myShip.startMoveOnWP();
        if (this.informer) {
          this.informer.setCommand(`Установлена точка маршрута: ${Math.floor(x)}, ${Math.floor(y)}`);
        }
        break;
        
      case MainScene.ST_SELECT_TORP_WAY_POINT:
        // Проверяем, что выбрано оружие
        if (this.weaponSelect !== Constants.WEAPON_SELECT_UNKNOWN) {
          // Запускаем торпеду в выбранном направлении
          const torpedo = this.fireTorpedo(this.myShip, this.weaponSelect, x, y);
          
          if (torpedo && this.informer) {
            this.informer.setCommand(`Торпеда запущена в направлении: ${Math.floor(x)}, ${Math.floor(y)}`);
          } else if (this.informer) {
            this.informer.setCommandAlarm("Не удалось запустить торпеду! Оружие не готово.");
          }
          
          // Сбрасываем состояние выбора
          this.inputTextState = MainScene.ST_UNKNOWN;
          this.weaponSelect = Constants.WEAPON_SELECT_UNKNOWN;
        }
        break;
        
      default:
        // В обычном режиме щелчок просто выбирает точку движения
        this.myShip.stopMoveOnWayPoint();
        this.myShip.addWayPoint(x, y);
        this.myShip.startMoveOnWP();
        if (this.informer) {
          this.informer.setCommand(`Установлена точка маршрута: ${Math.floor(x)}, ${Math.floor(y)}`);
        }
        break;
    }
  }
  
  /**
   * Обработчик перемещения указателя мыши
   * @param pointer Указатель мыши
   */
  private handlePointerMove(pointer: Phaser.Input.Pointer): void {
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
    
    // Обработка клавиши S для старта/стопа игры независимо от текущего состояния
    if (event.key === 's' || event.key === 'S' || event.keyCode === 83) {
      this.startStopHandler();
      return;
    }
    
    // Обработка масштабирования (Z/X) доступна всегда
    if (event.key === 'z' || event.key === 'Z' || event.keyCode === 90) {
      this.increaseZoom();
      return;
    }
    
    if (event.key === 'x' || event.key === 'X' || event.keyCode === 88) {
      this.decreaseZoom();
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
      return;
    }
    
    // Обработка по ключу event.key
    switch(event.key) {
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
      case 'ArrowLeft':
      case 'Left':    // Для поддержки IE/Edge
        console.log('Обработка стрелки влево');
        this.handleArrowLeft();
        break;
        
      case 'ArrowRight':
      case 'Right':    // Для поддержки IE/Edge
        console.log('Обработка стрелки вправо');
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
        
      // Выбор оружия
      case 'q':
      case 'Q':
        // Торпеда I
        this.weaponSelect = Constants.WEAPON_SELECT_TORP_I;
        this.inputTextState = MainScene.ST_SELECT_TORP_WAY_POINT;
        if (this.informer) {
          if (this.myShip.isWeaponReady(Constants.WEAPON_SELECT_TORP_I)) {
            this.informer.setCommand("Выбрана торпеда типа I. Кликните для выбора цели.");
          } else {
            this.informer.setCommandAlarm("Торпеда типа I не готова к запуску!");
          }
        }
        break;
        
      case 'w':
      case 'W':
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
      case 'E':
        // Торпеда III (самонаводящаяся)
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
        
      // Отмена текущего действия
      case 'Escape':
        this.inputTextState = MainScene.ST_UNKNOWN;
        this.weaponSelect = Constants.WEAPON_SELECT_UNKNOWN;
        if (this.informer) this.informer.setCommand("Выбор отменен");
        break;
      
      default:
        // Обработка по keyCode для совместимости со старыми браузерами
        const keyCode = event.keyCode || event.which;
        if (keyCode === 37) { // Левая стрелка
          console.log('Обработка стрелки влево по keyCode');
          this.handleArrowLeft();
        } else if (keyCode === 39) { // Правая стрелка
          console.log('Обработка стрелки вправо по keyCode');
          this.handleArrowRight();
        }
        break;
    }
  }
  
  /**
   * Обработчик стрелки влево
   */
  private handleArrowLeft(): void {
    if (!this.myShip) return;
    
    this.myShip.rudderChange(1); // Руль влево
    this.myShip.stopMoveOnWayPoint(); // Отменяем движение по маршруту при ручном руле
    
    // Прямое обновление состояния руля
    this.myShip.setRudder(this.myShip.getRudder());
    
    // Обновляем индикатор руля напрямую
    if (this.informer) {
      const rudderValue = this.myShip.getRudder();
      console.log(`Значение руля после изменения: ${rudderValue}`);
      if (rudderValue === Vehicle.RUDER_LEFT_5) {
        this.informer.setRudder("L 5");
        this.informer.setCommand("Руль 5 градусов влево.");
      } else if (rudderValue === Vehicle.RUDER_LEFT_10) {
        this.informer.setRudder("L 10");
        this.informer.setCommand("Руль 10 градусов влево.");
      } else if (rudderValue === Vehicle.RUDER_LEFT_15) {
        this.informer.setRudder("L 15");
        this.informer.setCommand("Руль 15 градусов влево.");
      } else if (rudderValue === Vehicle.RUDER_0) {
        this.informer.setRudder("0");
        this.informer.setCommand("Прямо по курсу!");
      }
    }
  }
  
  /**
   * Обработчик стрелки вправо
   */
  private handleArrowRight(): void {
    if (!this.myShip) return;
    
    this.myShip.rudderChange(-1); // Руль вправо
    this.myShip.stopMoveOnWayPoint(); // Отменяем движение по маршруту при ручном руле
    
    // Прямое обновление состояния руля
    this.myShip.setRudder(this.myShip.getRudder());
    
    // Обновляем индикатор руля напрямую
    if (this.informer) {
      const rudderValue = this.myShip.getRudder();
      console.log(`Значение руля после изменения: ${rudderValue}`);
      if (rudderValue === Vehicle.RUDER_RIGHT_5) {
        this.informer.setRudder("R 5");
        this.informer.setCommand("Руль 5 градусов вправо.");
      } else if (rudderValue === Vehicle.RUDER_RIGHT_10) {
        this.informer.setRudder("R 10");
        this.informer.setCommand("Руль 10 градусов вправо.");
      } else if (rudderValue === Vehicle.RUDER_RIGHT_15) {
        this.informer.setRudder("R 15");
        this.informer.setCommand("Руль 15 градусов вправо.");
      } else if (rudderValue === Vehicle.RUDER_0) {
        this.informer.setRudder("0");
        this.informer.setCommand("Прямо по курсу!");
      }
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
    ship.setSelected(true);
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redShips.push(ship);
    } else {
      this.whiteShips.push(ship);
    }
    
    // Устанавливаем как управляемый корабль
    this.myShip = ship;
    
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
   * Запускает торпеду с корабля
   * @param ship Корабль, с которого запускается торпеда
   * @param weaponType Тип оружия
   * @param targetX Целевая координата X
   * @param targetY Целевая координата Y
   */
  public fireTorpedo(ship: Ship, weaponType: number, targetX: number, targetY: number): Torpedo | null {
    // Проверяем готовность оружия
    if (!ship.isWeaponReady(weaponType)) {
      if (this.informer) {
        this.informer.setCommandAlarm("Оружие не готово!");
      }
      return null;
    }
    
    // Позиция корабля
    const shipPos = ship.getPosition();
    const shipDir = ship.getDirection();
    
    // Вычисляем позицию запуска торпеды (перед кораблем)
    const launchDist = 15;
    const launchX = shipPos.x + Math.sin(Phaser.Math.DegToRad(shipDir)) * launchDist;
    const launchY = shipPos.y - Math.cos(Phaser.Math.DegToRad(shipDir)) * launchDist;
    
    // Вычисляем угол направления на цель
    let targetAngle = shipDir;
    
    if (targetX !== undefined && targetY !== undefined) {
      targetAngle = Phaser.Math.RadToDeg(
        Phaser.Math.Angle.Between(launchX, launchY, targetX, targetY)
      );
      targetAngle = (targetAngle + 90) % 360;
      if (targetAngle < 0) targetAngle += 360;
    }
    
    // Определяем силы (принадлежность)
    const forces = ship.getForces();
    
    // Создаем торпеду в зависимости от типа
    let torpedo = null;
    
    switch (weaponType) {
      case Constants.WEAPON_SELECT_TORP_I:
        torpedo = this.createTorpedoTypeI(launchX, launchY, targetAngle, forces);
        break;
        
      case Constants.WEAPON_SELECT_TORP_II:
        torpedo = this.createTorpedoTypeII(launchX, launchY, targetAngle, forces);
        
        // Для торпеды типа II добавляем цель как точку маршрута
        if (targetX !== undefined && targetY !== undefined) {
          torpedo.addWayPoint(targetX, targetY, Constants.WP_TARGET);
          torpedo.startMoveOnWP();
        }
        break;
        
      case Constants.WEAPON_SELECT_TORP_III:
        torpedo = this.createTorpedoTypeIII(launchX, launchY, targetAngle, forces);
        break;
        
      default:
        if (this.informer) {
          this.informer.setCommandAlarm("Неизвестный тип оружия!");
        }
        return null;
    }
    
    return torpedo;
  }
  
  /**
   * Создает торпеду типа I
   * @param x Позиция X
   * @param y Позиция Y
   * @param angle Угол направления
   * @param forces Принадлежность к силам
   */
  private createTorpedoTypeI(x: number, y: number, angle: number, forces: number): TorpedoTypeI {
    // Получаем параметры торпеды
    const params = {
      maxVelocity: Settings.TRP_I_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_I_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_I_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_I_TIME_RELOAD_SEC,
      damage: Settings.TRP_I_DAMEGE,
      executionDist: Settings.TRP_I_DIST_EXECUTION
    };
    
    // Создаем торпеду
    const torpedo = new TorpedoTypeI(this, x, y, angle, params, forces);
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redTorpedos.push(torpedo);
    } else {
      this.whiteTorpedos.push(torpedo);
    }
    
    return torpedo;
  }
  
  /**
   * Создает торпеду типа II
   * @param x Позиция X
   * @param y Позиция Y
   * @param angle Угол направления
   * @param forces Принадлежность к силам
   */
  private createTorpedoTypeII(x: number, y: number, angle: number, forces: number): TorpedoTypeII {
    // Получаем параметры торпеды
    const params = {
      maxVelocity: Settings.TRP_II_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_II_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_II_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_II_TIME_RELOAD_SEC,
      damage: Settings.TRP_II_DAMEGE,
      executionDist: Settings.TRP_II_DIST_EXECUTION
    };
    
    // Создаем торпеду
    const torpedo = new TorpedoTypeII(this, x, y, angle, params, forces);
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redTorpedos.push(torpedo);
    } else {
      this.whiteTorpedos.push(torpedo);
    }
    
    return torpedo;
  }
  
  /**
   * Создает торпеду типа III
   * @param x Позиция X
   * @param y Позиция Y
   * @param angle Угол направления
   * @param forces Принадлежность к силам
   */
  private createTorpedoTypeIII(x: number, y: number, angle: number, forces: number): TorpedoTypeIII {
    // Получаем параметры торпеды
    const params = {
      maxVelocity: Settings.TRP_III_MAX_VELOCITY,
      lifeTimeSec: Settings.TRP_III_LIFE_TIME_SEC,
      maneuvering: Settings.TRP_III_MANEVR_PRC,
      reloadTimeSec: Settings.TRP_III_TIME_RELOAD_SEC,
      damage: Settings.TRP_III_DAMEGE,
      executionDist: Settings.TRP_III_DIST_EXECUTION,
      targetAcceptDist: Settings.TRP_III_TRG_ACCEPT_DIST
    };
    
    // Создаем торпеду
    const torpedo = new TorpedoTypeIII(this, x, y, angle, params, forces);
    
    // Добавляем в соответствующий массив
    if (forces === Constants.FORCES_RED) {
      this.redTorpedos.push(torpedo);
    } else {
      this.whiteTorpedos.push(torpedo);
    }
    
    return torpedo;
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
    for (const obstruction of this.obstructions) {
      obstruction.destroy();
    }
    this.obstructions = [];
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
    // Сохраняем текущий центр экрана
    const centerX = this.cameras.main.width / 2;
    const centerY = this.cameras.main.height / 2;
    
    // Уменьшаем значение зума (что делает объекты крупнее)
    this.zoom *= 0.5;
    
    // Ограничиваем минимальный зум
    if (this.zoom < 0.25) {
      this.zoom = 0.25;
      if (this.informer) {
        this.informer.setCommand("Максимальное приближение!");
      }
    }
    
    // Обновляем зум и центр камеры
    this.updateCameraZoom();
    
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
    // Сохраняем текущий центр экрана
    const centerX = this.cameras.main.width / 2;
    const centerY = this.cameras.main.height / 2;
    
    // Увеличиваем значение зума (что делает объекты мельче)
    this.zoom /= 0.5;
    
    // Ограничиваем максимальный зум
    if (this.zoom > 4) {
      this.zoom = 4;
      if (this.informer) {
        this.informer.setCommand("Максимальное отдаление!");
      }
    }
    
    // Обновляем зум и центр камеры
    this.updateCameraZoom();
    
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
    // Устанавливаем масштаб камеры
    this.cameras.main.setZoom(1 / this.zoom);
    
    console.log(`Масштаб камеры установлен: ${1 / this.zoom}`);
  }
} 