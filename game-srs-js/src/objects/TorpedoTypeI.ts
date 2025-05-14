import Phaser from 'phaser';
import { Torpedo } from './Torpedo';
import { Constants } from '../utils/Constants';
import { TorpedoParams } from './TorpedoParams';

/**
 * Торпеда Тип I - обычная прямоидущая торпеда
 */
export class TorpedoTypeI extends Torpedo {
  /**
   * Конструктор
   * @param scene Сцена
   * @param x Начальная позиция X
   * @param y Начальная позиция Y
   * @param angle Начальный угол
   * @param params Параметры торпеды
   * @param forces Принадлежность к силам
   */
  constructor(
    scene: Phaser.Scene, 
    x: number, 
    y: number, 
    angle: number, 
    params: TorpedoParams, 
    forces: number = Constants.FORCES_WHITE
  ) {
    super(scene, x, y, angle, params, forces);
    
    // Устанавливаем тип торпеды
    this.weaponType = Constants.WEAPON_SELECT_TORP_I;
  }
  
  /**
   * Переопределяем метод отрисовки торпеды типа I
   */
  protected drawVehicle(): void {
    // Создаем графику для торпеды
    const graphics = (this.scene.add as Phaser.GameObjects.GameObjectFactory).graphics();
    
    // Выбираем цвет в зависимости от принадлежности
    graphics.fillStyle(this.color, 1);
    
    // Рисуем форму торпеды (тонкий прямоугольник)
    graphics.fillRect(-1.5, -4, 3, 8);
    
    // Генерируем текстуру
    graphics.generateTexture('torpedo_type_i', 6, 12);
    graphics.destroy();
    
    // Устанавливаем текстуру
    this.setTexture('torpedo_type_i');
  }
  
  /**
   * Торпеда типа I движется прямо без наведения
   */
  public AI_step_I(): void {
    // Торпеда движется прямо без изменения направления
  }
  
  /**
   * Торпеда типа I не меняет направление
   */
  public AI_step_II(): void {
    // Нет изменений в направлении
  }
} 