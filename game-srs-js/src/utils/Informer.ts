import Phaser from 'phaser';
import { Constants } from './Constants';
import { Settings } from './Settings';
import { Lamp } from './Lamp';

/**
 * Класс информационной панели
 * Управляет всеми элементами пользовательского интерфейса
 */
export class Informer {
  // Константы для индексов полей
  private readonly SPD: number = 0;
  private readonly POW: number = 1;
  private readonly RUD: number = 2;
  private readonly DIR: number = 3;
  private readonly ZOM: number = 4;
  private readonly NUMB_FIELDS: number = 5;
  
  // Константы для стилей полей
  private readonly COMMAND_HEIGHT: number = 22;
  private readonly COMMAND_WIDTH: number = 400;
  private readonly COMMAND_COLOR: number = 0xFFFFFF;
  
  private readonly LBL_WIDTH: number = 50;
  private readonly FIELD_HEIGHT: number = 22;
  private readonly FIELD_WIDTH: number = 60;
  private readonly FIELD_TEXT_SIZE: number = 20;
  private readonly FIELD_TEXT_COLOR: string = '#ffffff';
  private readonly FIELD_TEXT_BGCOLOR: string = '#1E90FF';
  private readonly FIELD_ALPHA: number = 0.8;
  
  private readonly R_LBL_WIDTH: number = 150;
  private readonly R_FIELD_WIDTH: number = 100;
  private readonly R_FIELD_HEIGHT: number = 22;
  private readonly R_FIELD_TEXT_SIZE: number = 20;
  private readonly R_FIELD_TEXT_COLOR: string = '#ffff00';
  private readonly R_FIELD_TEXT_BGCOLOR: string = '#1E90FF';
  private readonly R_ALPHA: number = 0.8;
  
  private readonly TF_FIELD_HEIGHT: number = 200;
  private readonly TF_FIELD_WIDTH: number = 300;
  private readonly TF_FIELD_TEXT_SIZE: number = 20;
  private readonly TF_FIELD_TEXT_COLOR: string = '#ffff00';
  private readonly TF_FIELD_TEXT_BGCOLOR: string = '#1E90FF';
  private readonly TF_FIELD_ALPHA: number = 0.8;
  
  // Ссылка на сцену
  private scene: Phaser.Scene;
  
  // Основные текстовые поля
  private timeText: Phaser.GameObjects.Text | null = null;
  private playerNameText: Phaser.GameObjects.Text | null = null;
  private commandText: Phaser.GameObjects.Text | null = null;
  private traceText: Phaser.GameObjects.Text | null = null;
  
  // Массивы полей и индикаторов
  private fields: Phaser.GameObjects.Text[] = [];
  private labels: Phaser.GameObjects.Text[] = [];
  private rightFields: Phaser.GameObjects.Text[] = [];
  private rightLabels: Phaser.GameObjects.Text[] = [];
  private lamps: Lamp[] = [];
  
  // Информационные панели
  private infoPanelHeader: Phaser.GameObjects.Text | null = null;
  private infoPanelText: Phaser.GameObjects.Text | null = null;
  private infoPanelFooter: Phaser.GameObjects.Text | null = null;
  
  // Счетчик сообщений
  private msgCount: number = 1;
  
  /**
   * Конструктор
   * @param scene Сцена, на которой размещается интерфейс
   */
  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    
    // Создаем поле с именем игрока
    this.playerNameText = scene.add.text(0, 10, '', {
      fontSize: `${this.FIELD_TEXT_SIZE}px`,
      fontFamily: 'Courier',
      color: this.FIELD_TEXT_COLOR,
      backgroundColor: this.FIELD_TEXT_BGCOLOR,
      padding: { left: 5, right: 5, top: 2, bottom: 2 }
    });
    this.playerNameText.setFixedSize(this.LBL_WIDTH + this.FIELD_WIDTH + 2, this.FIELD_HEIGHT);
    this.playerNameText.setAlpha(this.FIELD_ALPHA);
    
    // Создаем поле с временем
    this.timeText = scene.add.text(0, this.playerNameText.y + this.playerNameText.height, '', {
      fontSize: `${this.FIELD_TEXT_SIZE}px`,
      fontFamily: 'Courier',
      color: this.FIELD_TEXT_COLOR,
      backgroundColor: this.FIELD_TEXT_BGCOLOR,
      padding: { left: 5, right: 5, top: 2, bottom: 2 }
    });
    this.timeText.setFixedSize(this.LBL_WIDTH + this.FIELD_WIDTH + 2, this.FIELD_HEIGHT);
    this.timeText.setAlpha(this.FIELD_ALPHA);
    
    // Создаем поля основных параметров
    for (let j = 0; j < this.NUMB_FIELDS; j++) {
      // Метка
      const label = scene.add.text(0, this.timeText.y + this.timeText.height + 5 + j * this.FIELD_HEIGHT, '', {
        fontSize: `${this.FIELD_TEXT_SIZE}px`,
        fontFamily: 'Courier',
        color: this.FIELD_TEXT_COLOR,
        backgroundColor: this.FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      label.setFixedSize(this.LBL_WIDTH, this.FIELD_HEIGHT);
      label.setAlpha(this.FIELD_ALPHA);
      this.labels.push(label);
      
      // Значение
      const field = scene.add.text(
        label.x + label.width + 2,
        this.timeText.y + this.timeText.height + 5 + j * this.FIELD_HEIGHT,
        '0',
        {
          fontSize: `${this.FIELD_TEXT_SIZE}px`,
          fontFamily: 'Courier',
          color: this.FIELD_TEXT_COLOR,
          backgroundColor: this.FIELD_TEXT_BGCOLOR,
          padding: { left: 5, right: 5, top: 2, bottom: 2 }
        }
      );
      field.setFixedSize(this.FIELD_WIDTH, this.FIELD_HEIGHT);
      field.setAlpha(this.FIELD_ALPHA);
      this.fields.push(field);
    }
    
    // Устанавливаем метки для основных полей
    this.labels[this.SPD].setText('SPD');
    this.labels[this.RUD].setText('RUD');
    this.labels[this.DIR].setText('CRS');
    this.labels[this.POW].setText('POW');
    this.labels[this.ZOM].setText('ZOM');
    
    // Устанавливаем начальные значения
    this.fields[this.RUD].setText('0');
    
    // Создаем командную строку
    this.commandText = scene.add.text(200, Settings.SCREEN_HEIGHT - this.COMMAND_HEIGHT, '', {
      fontSize: `${this.FIELD_TEXT_SIZE}px`,
      fontFamily: 'Courier',
      color: this.FIELD_TEXT_COLOR,
      backgroundColor: this.FIELD_TEXT_BGCOLOR,
      padding: { left: 5, right: 5, top: 2, bottom: 2 }
    });
    this.commandText.setFixedSize(this.COMMAND_WIDTH, this.COMMAND_HEIGHT);
    this.commandText.setAlpha(this.FIELD_ALPHA);
    
    // Создаем индикаторы (лампы)
    this.panelLampSet(1, Constants.LAMP_TRPRD_I, Constants.LAMP_TRPRD_I, false);
    this.panelLampSet(2, Constants.LAMP_TRPRD_II, Constants.LAMP_TRPRD_II, false);
    this.panelLampSet(3, Constants.LAMP_TRPRD_III, Constants.LAMP_TRPRD_III, false);
    this.panelLampSet(4, Constants.LAMP_TRPRD_III + "2", Constants.LAMP_TRPRD_III, false);
    this.panelLampSet(5, Constants.LAMP_WP, "WP", false);
    this.panelLampSet(6, Constants.LAMP_TRP_ATACK, Constants.LAMP_TRP_ATACK, false);
    
    // Подготавливаем панель конца игры
    this.prepareGameOver();
  }
  
  /**
   * Медленное обновление (для мигающих индикаторов)
   * @param time Текущее время
   */
  public onSlowLoop(time: number): void {
    const lamp = this.getPanelLamp(Constants.LAMP_TRP_ATACK);
    if (lamp) {
      lamp.blinkAlarmWarning(time);
    }
  }
  
  /**
   * Очищает все элементы интерфейса
   */
  public clean(): void {
    if (this.playerNameText) this.playerNameText.destroy();
    if (this.timeText) this.timeText.destroy();
    if (this.commandText) this.commandText.destroy();
    if (this.traceText) this.traceText.destroy();
    
    this.playerNameText = null;
    this.timeText = null; 
    this.commandText = null;
    this.traceText = null;
    
    // Очищаем основные поля
    for (const label of this.labels) {
      label.destroy();
    }
    for (const field of this.fields) {
      field.destroy();
    }
    this.labels = [];
    this.fields = [];
    
    // Очищаем правые поля
    for (const label of this.rightLabels) {
      label.destroy();
    }
    for (const field of this.rightFields) {
      field.destroy();
    }
    this.rightLabels = [];
    this.rightFields = [];
    
    // Очищаем индикаторы
    for (const lamp of this.lamps) {
      lamp.destroy();
    }
    this.lamps = [];
    
    // Очищаем панель конца игры
    if (this.infoPanelHeader) this.infoPanelHeader.destroy();
    if (this.infoPanelText) this.infoPanelText.destroy();
    if (this.infoPanelFooter) this.infoPanelFooter.destroy();
    
    this.infoPanelHeader = null;
    this.infoPanelText = null;
    this.infoPanelFooter = null;
  }
  
  /**
   * Устанавливает имя игрока
   * @param txt Имя игрока
   */
  public setPlayerName(txt: string): void {
    if (this.playerNameText) {
      this.playerNameText.setText(txt);
    }
  }
  
  /**
   * Подготавливает панель конца игры
   */
  public prepareGameOver(): void {
    // Заголовок панели
    this.infoPanelHeader = this.scene.add.text(10, 10, '', {
      fontSize: '30px',
      fontFamily: 'sans-serif',
      color: '#FF4500',
      backgroundColor: '#FFFF00',
      padding: { left: 10, right: 10, top: 5, bottom: 5 }
    });
    this.infoPanelHeader.setFixedSize(Settings.SCREEN_WIDTH - 20, 50);
    this.infoPanelHeader.setAlpha(0.9);
    this.infoPanelHeader.setAlign('center');
    this.infoPanelHeader.setVisible(false);
    
    // Основной текст
    this.infoPanelText = this.scene.add.text(10, 10 + 50 + 2, '', {
      fontSize: '20px',
      fontFamily: 'Courier',
      color: '#FF0000',
      backgroundColor: '#FFFF00',
      padding: { left: 10, right: 10, top: 5, bottom: 5 }
    });
    this.infoPanelText.setFixedSize(Settings.SCREEN_WIDTH - 20, Settings.SCREEN_HEIGHT - (50 + 2 + 50 + 10 + 10 + 2));
    this.infoPanelText.setAlpha(0.9);
    this.infoPanelText.setWordWrapWidth(Settings.SCREEN_WIDTH - 40);
    this.infoPanelText.setVisible(false);
    
    // Подвал панели
    this.infoPanelFooter = this.scene.add.text(10, this.infoPanelText.y + this.infoPanelText.height + 2, '', {
      fontSize: '30px',
      fontFamily: 'sans-serif',
      color: '#FF4500',
      backgroundColor: '#FFFF00',
      padding: { left: 10, right: 10, top: 5, bottom: 5 }
    });
    this.infoPanelFooter.setFixedSize(Settings.SCREEN_WIDTH - 20, 50);
    this.infoPanelFooter.setAlpha(0.9);
    this.infoPanelFooter.setAlign('center');
    this.infoPanelFooter.setVisible(false);
  }
  
  /**
   * Показывает информационную панель
   * @param header Заголовок
   * @param txt Текст
   * @param footer Подвал
   */
  public showInfoPanel(header: string, txt: string, footer: string): void {
    this.setTextPanel(header, txt, footer);
    if (this.infoPanelHeader) this.infoPanelHeader.setVisible(true);
    if (this.infoPanelText) this.infoPanelText.setVisible(true);
    if (this.infoPanelFooter) this.infoPanelFooter.setVisible(true);
  }
  
  /**
   * Скрывает информационную панель
   */
  public hideInfoPanel(): void {
    if (this.infoPanelHeader) this.infoPanelHeader.setVisible(false);
    if (this.infoPanelText) this.infoPanelText.setVisible(false);
    if (this.infoPanelFooter) this.infoPanelFooter.setVisible(false);
  }
  
  /**
   * Устанавливает время
   * @param tm Время в миллисекундах
   */
  public setTime(tm: number): void {
    if (this.timeText) {
      const t = Math.floor(tm / 1000);
      this.timeText.setText(`${t} sec.`);
    }
  }
  
  /**
   * Включает режим паузы для времени
   */
  public setTimePause(): void {
    if (this.timeText) {
      this.timeText.setBackgroundColor('#FF0000');
    }
  }
  
  /**
   * Возвращает нормальный режим отображения времени
   */
  public setTimeGo(): void {
    if (this.timeText) {
      this.timeText.setBackgroundColor(this.FIELD_TEXT_BGCOLOR);
    }
  }
  
  /**
   * Устанавливает скорость
   * @param speed Скорость
   */
  public setSpeed(speed: number): void {
    if (this.fields[this.SPD]) {
      this.fields[this.SPD].setText(Math.floor(speed).toString());
    }
  }
  
  /**
   * Устанавливает руль
   * @param rudder Положение руля
   */
  public setRudder(rudder: string): void {
    console.log(`Informer.setRudder called with: ${rudder}`);
    
    try {
      // Проверяем наличие поля RUD
      if (this.RUD === undefined) {
        console.error('Индекс RUD не определен');
        return;
      }
      
      // Проверяем наличие массива fields
      if (!this.fields || !Array.isArray(this.fields)) {
        console.error('Массив fields не существует или не является массивом');
        return;
      }
      
      // Проверяем наличие элемента по индексу RUD
      if (!this.fields[this.RUD]) {
        console.error(`Поле RUD не существует по индексу ${this.RUD}`);
        return;
      }
      
      // Проверяем наличие метода setText
      if (typeof this.fields[this.RUD].setText !== 'function') {
        console.error('Метод setText не является функцией');
        return;
      }
      
      // Устанавливаем текст руля
      this.fields[this.RUD].setText(rudder);
      console.log(`Rudder indicator successfully updated to: ${rudder}`);
    } catch (error) {
      console.error('Ошибка при обновлении руля:', error);
    }
  }
  
  /**
   * Добавляет отладочное поле слева
   * @param fieldName Имя поля
   * @param value Значение
   */
  public writeDebugDopField(fieldName: string, value: string): void {
    if (!Settings.DEBUG) return;
    
    // Проверяем, существует ли поле
    let index = this.labels.findIndex(label => label.text === fieldName);
    
    if (index === -1) {
      // Создаем новое поле если не существует
      const labelY = this.timeText ? this.timeText.y + this.timeText.height + 5 + this.labels.length * this.FIELD_HEIGHT : 0;
      
      // Создаем метку
      const label = this.scene.add.text(0, labelY, fieldName, {
        fontSize: `${this.FIELD_TEXT_SIZE - 2}px`,
        fontFamily: 'Courier',
        color: '#FFFF00',
        backgroundColor: this.FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      label.setFixedSize(this.LBL_WIDTH, this.FIELD_HEIGHT);
      label.setAlpha(this.FIELD_ALPHA);
      this.labels.push(label);
      
      // Создаем значение
      const field = this.scene.add.text(label.x + label.width + 2, labelY, value, {
        fontSize: `${this.FIELD_TEXT_SIZE - 2}px`,
        fontFamily: 'Courier',
        color: '#FFFF00',
        backgroundColor: this.FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      field.setFixedSize(this.FIELD_WIDTH, this.FIELD_HEIGHT);
      field.setAlpha(this.FIELD_ALPHA);
      this.fields.push(field);
    } else {
      // Обновляем существующее поле
      this.fields[index].setText(value);
    }
  }
  
  /**
   * Удаляет поле справа
   * @param fieldName Имя поля
   */
  public removeRightField(fieldName: string): void {
    const index = this.rightLabels.findIndex(label => label.text === fieldName);
    
    if (index !== -1) {
      this.rightLabels[index].destroy();
      this.rightFields[index].destroy();
      this.rightLabels.splice(index, 1);
      this.rightFields.splice(index, 1);
    }
  }
  
  /**
   * Добавляет отладочное поле справа
   * @param fieldName Имя поля
   * @param value Значение
   */
  public writeDebugRightField(fieldName: string, value: string): void {
    if (!Settings.DEBUG) return;
    this.writeRightField(fieldName, value);
  }
  
  /**
   * Добавляет поле справа
   * @param fieldName Имя поля
   * @param value Значение
   */
  public writeRightField(fieldName: string, value: string): void {
    // Проверяем, существует ли поле
    let index = this.rightLabels.findIndex(label => label.text === fieldName);
    
    if (index === -1) {
      // Создаем новое поле
      const y = 5 + this.rightLabels.length * this.R_FIELD_HEIGHT;
      
      // Создаем значение (справа)
      const field = this.scene.add.text(0, y, value, {
        fontSize: `${this.R_FIELD_TEXT_SIZE - 2}px`,
        fontFamily: 'Courier',
        color: this.R_FIELD_TEXT_COLOR,
        backgroundColor: this.R_FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      field.setFixedSize(this.R_FIELD_WIDTH, this.R_FIELD_HEIGHT);
      field.setAlpha(this.R_ALPHA);
      
      // Создаем метку (слева от значения)
      const label = this.scene.add.text(0, y, fieldName, {
        fontSize: `${this.R_FIELD_TEXT_SIZE - 2}px`,
        fontFamily: 'Courier',
        color: this.R_FIELD_TEXT_COLOR,
        backgroundColor: this.R_FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      label.setFixedSize(this.R_LBL_WIDTH, this.R_FIELD_HEIGHT);
      label.setAlpha(this.R_ALPHA);
      
      // Устанавливаем позиции (справа экрана)
      field.setX(Settings.SCREEN_WIDTH - field.width - 2);
      label.setX(field.x - label.width);
      
      this.rightLabels.push(label);
      this.rightFields.push(field);
    } else {
      // Обновляем существующее поле
      this.rightFields[index].setText(value);
    }
  }
  
  /**
   * Устанавливает состояние индикатора (включен/выключен)
   * @param lampName Имя индикатора
   * @param on Состояние
   */
  public panelLampOnOff(lampName: string, on: boolean): void {
    const lamp = this.getPanelLamp(lampName);
    if (lamp) {
      lamp.setOnOff(on);
    } else {
      console.warn(`PANEL LAMP ${lampName} NOT SET!!!`);
    }
  }
  
  /**
   * Устанавливает состояние индикатора (готов/не готов)
   * @param lampName Имя индикатора
   * @param ready Состояние
   */
  public panelLampReadyNotReady(lampName: string, ready: boolean): void {
    const lamp = this.getPanelLamp(lampName);
    if (lamp) {
      lamp.setReadyNotReady(ready);
    } else {
      console.warn(`PANEL LAMP ${lampName} NOT SET!!!`);
    }
  }
  
  /**
   * Создает или обновляет индикатор
   * @param num Номер позиции индикатора
   * @param lampName Имя индикатора
   * @param text Отображаемый текст
   * @param on Начальное состояние
   */
  public panelLampSet(num: number, lampName: string, text: string, on: boolean): void {
    // Ищем существующий индикатор
    const existingLamp = this.getPanelLamp(lampName);
    
    if (!existingLamp) {
      // Рассчитываем позицию для нового индикатора
      let x = 0;
      let y = 0;
      
      // Вычисляем положение в сетке 2x4
      if (num === 1) {
        x = 0;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + this.FIELD_HEIGHT : 0);
      } else if (num === 2) {
        x = (this.LBL_WIDTH + this.FIELD_WIDTH) / 2;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + this.FIELD_HEIGHT : 0);
      } else if (num === 3) {
        x = 0;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 2 * this.FIELD_HEIGHT : 0);
      } else if (num === 4) {
        x = (this.LBL_WIDTH + this.FIELD_WIDTH) / 2;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 2 * this.FIELD_HEIGHT : 0);
      } else if (num === 5) {
        x = 0;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 3 * this.FIELD_HEIGHT : 0);
      } else if (num === 6) {
        x = (this.LBL_WIDTH + this.FIELD_WIDTH) / 2;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 3 * this.FIELD_HEIGHT : 0);
      } else if (num === 7) {
        x = 0;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 4 * this.FIELD_HEIGHT : 0);
      } else if (num === 8) {
        x = (this.LBL_WIDTH + this.FIELD_WIDTH) / 2;
        y = 5 + (this.fields.length > 0 ? this.fields[this.fields.length - 1].y + 4 * this.FIELD_HEIGHT : 0);
      }
      
      // Создаем индикатор
      const lamp = new Lamp(this.scene, x, y, lampName, text);
      lamp.setFixedSize((this.LBL_WIDTH + this.FIELD_WIDTH + 2) / 2, this.FIELD_HEIGHT);
      this.lamps.push(lamp);
      
      // Устанавливаем начальное состояние
      if (on) {
        lamp.setOn();
      } else {
        lamp.setOff();
      }
    } else {
      // Обновляем существующий индикатор
      existingLamp.setText(text);
      if (on) {
        existingLamp.setOn();
      } else {
        existingLamp.setOff();
      }
    }
  }
  
  /**
   * Получает индикатор по имени
   * @param lampName Имя индикатора
   * @returns Индикатор или null
   */
  public getPanelLamp(lampName: string): Lamp | null {
    return this.lamps.find(lamp => lamp.name === lampName) || null;
  }
  
  /**
   * Запускает мигание индикатора
   * @param lampName Имя индикатора
   */
  public panelLampBlinkAlarmWarning(lampName: string): void {
    const lamp = this.getPanelLamp(lampName);
    if (lamp) {
      lamp.startBlinkAlarmWarning();
    }
  }
  
  /**
   * Устанавливает активное состояние индикатора
   * @param lampName Имя индикатора
   */
  public panelLampActive(lampName: string): void {
    const lamp = this.getPanelLamp(lampName);
    if (lamp) {
      lamp.setActiveState();
    }
  }
  
  /**
   * Выключает индикатор
   * @param lampName Имя индикатора
   */
  public panelLampOff(lampName: string): void {
    const lamp = this.getPanelLamp(lampName);
    if (lamp) {
      lamp.setOff();
    }
  }
  
  /**
   * Добавляет текст в лог
   * @param val Текст сообщения
   */
  public writeText(val: string): void {
    val = `${this.msgCount++}: ${val}`;
    
    // Создаем текстовое поле, если его нет
    if (!this.traceText) {
      this.traceText = this.scene.add.text(0, 0, val, {
        fontSize: `${this.TF_FIELD_TEXT_SIZE - 2}px`,
        fontFamily: 'Segoe',
        color: this.TF_FIELD_TEXT_COLOR,
        backgroundColor: this.TF_FIELD_TEXT_BGCOLOR,
        padding: { left: 5, right: 5, top: 2, bottom: 2 }
      });
      this.traceText.setFixedSize(this.TF_FIELD_WIDTH, this.TF_FIELD_HEIGHT);
      this.traceText.setAlpha(this.TF_FIELD_ALPHA);
      this.traceText.setWordWrapWidth(this.TF_FIELD_WIDTH - 10);
      
      // Устанавливаем позицию справа внизу
      this.traceText.setX(Settings.SCREEN_WIDTH - this.traceText.width - 2);
      this.traceText.setY(Settings.SCREEN_HEIGHT - this.traceText.height - 2);
    } else {
      // Добавляем текст в начало (для эффекта прокрутки)
      this.traceText.setText(`${val}\n${this.traceText.text}`);
    }
  }
  
  /**
   * Добавляет отладочный текст
   * @param val Текст сообщения
   */
  public writeDebugText(val: string): void {
    if (Settings.DEBUG) {
      this.writeText(val);
    }
  }
  
  /**
   * Устанавливает текст команды
   * @param command Текст команды
   */
  public setCommand(command: string): void {
    if (this.commandText) {
      this.commandText.setColor(this.FIELD_TEXT_COLOR);
      this.commandText.setText(command);
    }
  }
  
  /**
   * Устанавливает текст команды с сигналом тревоги
   * @param command Текст команды
   */
  public setCommandAlarm(command: string): void {
    if (this.commandText) {
      this.commandText.setColor('#ff0000');
      this.commandText.setText(command);
      this.writeText(command);
    }
  }
  
  /**
   * Устанавливает направление
   * @param direction Значение направления
   */
  public setDirection(direction: string): void {
    if (this.fields[this.DIR]) {
      this.fields[this.DIR].setText(direction);
    }
  }
  
  /**
   * Устанавливает мощность
   * @param power Значение мощности
   */
  public setPower(power: string): void {
    if (this.fields[this.POW]) {
      this.fields[this.POW].setText(power);
    }
  }
  
  /**
   * Устанавливает масштаб
   * @param zoom Значение масштаба
   */
  public setZoom(zoom: number): void {
    if (this.fields[this.ZOM]) {
      this.fields[this.ZOM].setText(zoom.toFixed(3));
    }
  }
  
  /**
   * Устанавливает текст информационной панели
   * @param header Заголовок
   * @param txt Основной текст
   * @param footer Подвал
   */
  private setTextPanel(header: string, txt: string, footer: string): void {
    if (this.infoPanelHeader) this.infoPanelHeader.setText(header);
    if (this.infoPanelText) this.infoPanelText.setText(txt);
    if (this.infoPanelFooter) this.infoPanelFooter.setText(footer);
  }
} 