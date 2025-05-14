import Phaser from 'phaser';
import { Torpedo } from './Torpedo';
import { Vehicle } from './Vehicle';
import { Constants } from '../utils/Constants';
import { TorpedoParams } from './TorpedoParams';

/**
 * Торпеда Тип II - торпеда с возможностью маневрирования по заданным точкам
 */
export class TorpedoTypeII extends Torpedo {
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
    this.weaponType = Constants.WEAPON_SELECT_TORP_II;
    
    // Устанавливаем состояние движения - движение по точкам
    this.moveState = Vehicle.ST_WP_MOVING;
  }
  
  /**
   * Переопределяем метод отрисовки торпеды типа II
   */
  protected drawVehicle(): void {
    // Создаем графику для торпеды
    const graphics = (this.scene.add as Phaser.GameObjects.GameObjectFactory).graphics();
    
    // Выбираем цвет в зависимости от принадлежности
    graphics.fillStyle(this.color, 1);
    
    // Рисуем форму торпеды (более толстый прямоугольник)
    graphics.fillRect(-2, -4, 4, 8);
    
    // Добавляем хвостовой стабилизатор
    graphics.fillRect(-2, 3, 4, 1);
    
    // Генерируем текстуру
    graphics.generateTexture('torpedo_type_ii', 6, 12);
    graphics.destroy();
    
    // Устанавливаем текстуру
    this.setTexture('torpedo_type_ii');
  }
  
  /**
   * Торпеда типа II может маневрировать по точкам
   */
  public AI_step_I(): void {
    // Проверяем наличие точек маршрута
    if (this.wayPoints.length > 0) {
      // Обновляем направление на текущую точку
      this.setDirectionToWayPoint(this.wayPoints[0]);
    }
  }
  
  /**
   * Торпеда типа II меняет направление на следующую точку
   */
  public AI_step_II(): void {
    // Проверка достижения точек уже реализована в базовом классе Vehicle
  }
} 