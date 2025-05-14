import Phaser from 'phaser';
import { Constants } from './Constants';

/**
 * Класс индикатора (лампы) для информационной панели
 */
export class Lamp {
  // Состояния мигания
  private static readonly ST_NOT_BLINK: number = 0;
  private static readonly ST_BLINK_ALARM: number = 1;
  private static readonly ST_BLINK_WARNING: number = 2;
  
  // Цвета состояний
  private colorOff: number = Constants.COLOR_DARK_GRAY;
  private colorOn: number = Constants.COLOR_WHITE;
  private colorNotReady: number = Constants.COLOR_LIGHT_GRY;
  private colorReady: number = Constants.COLOR_LIGHT_GREEN;
  private colorActive: number = Constants.COLOR_LIGHT_YELLOW;
  private colorAlarm: number = Constants.COLOR_LIGHT_RED;
  private colorWarning: number = Constants.COLOR_LIGHT_YELLOW;
  private colorBlinkAlarm: number = Constants.COLOR_LIGHT_RED;
  private colorBlinkWarning: number = Constants.COLOR_LIGHT_YELLOW;
  
  // Текстовый объект для отображения
  private textObject: Phaser.GameObjects.Text;
  
  // Переменные для отслеживания состояния
  private timeLast: number = 0;
  private blinkState: number = Lamp.ST_NOT_BLINK;
  
  // Публичное имя лампы
  public name: string = '';
  
  /**
   * Конструктор
   * @param scene Сцена, на которой размещается индикатор
   * @param x Позиция X
   * @param y Позиция Y
   * @param name Внутреннее имя индикатора
   * @param displayText Отображаемый текст
   */
  constructor(scene: Phaser.Scene, x: number, y: number, name: string, displayText: string) {
    this.name = name;
    
    // Создаем текстовый объект
    this.textObject = scene.add.text(x, y, displayText, {
      fontSize: '16px',
      fontFamily: 'Courier',
      color: '#000000',
      backgroundColor: '#828282',
      padding: {
        left: 5,
        right: 5,
        top: 2,
        bottom: 2
      }
    });
    
    // Настраиваем стиль индикатора
    this.textObject.setBackgroundColor('#828282');
    this.textObject.setPadding(5);
    this.textObject.setFixedSize(60, 22);
    this.textObject.setAlign('center');
    
    // Добавляем интерактивность для возможного будущего использования
    this.textObject.setInteractive({ useHandCursor: true });
  }
  
  /**
   * Устанавливает пользовательские цвета для индикатора
   */
  public setColors(
    colorOff: number = Constants.COLOR_DARK_GRAY,
    colorOn: number = Constants.COLOR_WHITE,
    colorNotReady: number = Constants.COLOR_LIGHT_RED,
    colorReady: number = Constants.COLOR_LIGHT_GREEN,
    colorActive: number = Constants.COLOR_LIGHT_YELLOW
  ): void {
    this.colorOff = colorOff;
    this.colorOn = colorOn;
    this.colorNotReady = colorNotReady;
    this.colorReady = colorReady;
    this.colorActive = colorActive;
  }
  
  /**
   * Переключает состояние индикатора между тревогой и предупреждением
   * @param time Текущее время
   */
  public blinkAlarmWarning(time: number): void {
    if ((time - this.timeLast) > 300) { // 0.3 секунды в миллисекундах
      if (this.blinkState === Lamp.ST_BLINK_ALARM) {
        this.textObject.setBackgroundColor(this.convertColorToString(this.colorBlinkWarning));
        this.blinkState = Lamp.ST_BLINK_WARNING;
      } else if (this.blinkState === Lamp.ST_BLINK_WARNING) {
        this.textObject.setBackgroundColor(this.convertColorToString(this.colorBlinkAlarm));
        this.blinkState = Lamp.ST_BLINK_ALARM;
      } else {
        this.blinkState = Lamp.ST_NOT_BLINK;
      }
      this.timeLast = time;
    }
  }
  
  /**
   * Останавливает мигание индикатора
   */
  private stopBlinkAlarmWarning(): void {
    this.blinkState = Lamp.ST_NOT_BLINK;
  }
  
  /**
   * Запускает мигание между тревогой и предупреждением
   */
  public startBlinkAlarmWarning(): void {
    if (this.blinkState !== Lamp.ST_BLINK_ALARM && this.blinkState !== Lamp.ST_BLINK_WARNING) {
      this.textObject.setBackgroundColor(this.convertColorToString(this.colorBlinkAlarm));
      this.blinkState = Lamp.ST_BLINK_ALARM;
    }
  }
  
  /**
   * Устанавливает состояние включено/выключено
   * @param on Состояние включения
   */
  public setOnOff(on: boolean): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorOff));
  }
  
  /**
   * Устанавливает состояние тревоги
   */
  public setAlarm(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorAlarm));
  }
  
  /**
   * Устанавливает состояние "включено"
   */
  public setOn(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorOn));
  }
  
  /**
   * Устанавливает состояние "выключено"
   */
  public setOff(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorOff));
  }
  
  /**
   * Устанавливает состояние "готово"
   */
  public setReady(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorReady));
  }
  
  /**
   * Устанавливает состояние "не готово"
   */
  public setNotReady(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorNotReady));
  }
  
  /**
   * Устанавливает состояние готовности
   * @param ready Состояние готовности
   */
  public setReadyNotReady(ready: boolean): void {
    this.stopBlinkAlarmWarning();
    if (ready) {
      this.textObject.setBackgroundColor(this.convertColorToString(this.colorReady));
    } else {
      this.textObject.setBackgroundColor(this.convertColorToString(this.colorNotReady));
    }
  }
  
  /**
   * Устанавливает активное состояние
   */
  public setActiveState(): void {
    this.stopBlinkAlarmWarning();
    this.textObject.setBackgroundColor(this.convertColorToString(this.colorActive));
  }
  
  /**
   * Устанавливает текст индикатора
   * @param text Новый текст
   */
  public setText(text: string): void {
    this.textObject.setText(text);
  }
  
  /**
   * Устанавливает фиксированный размер индикатора
   * @param width Ширина
   * @param height Высота
   */
  public setFixedSize(width: number, height: number): void {
    this.textObject.setFixedSize(width, height);
  }
  
  /**
   * Уничтожает индикатор
   */
  public destroy(): void {
    this.textObject.destroy();
  }
  
  /**
   * Преобразует число в строку с цветом в формате CSS
   */
  private convertColorToString(color: number): string {
    return '#' + color.toString(16).padStart(6, '0');
  }
} 