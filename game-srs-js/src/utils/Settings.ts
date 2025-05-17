/**
 * Настройки игры
 */
export class Settings {
  // Информация о версии
  static readonly CURRENT_PROGRAM: string = "Silent Red Storm";
  static readonly CURRENT_VERSION: string = "v.06.0";
  static readonly CURRENT_SRS: string = `${Settings.CURRENT_PROGRAM} ${Settings.CURRENT_VERSION}`;
  static readonly CURRENT_SCENARIO: string = "Scenario1x1";
  static readonly SCENARIO_SCORE_NAME: string = Settings.CURRENT_SCENARIO;
  
  // Флаги отладки
  static readonly DEBUG: boolean = true;
  static readonly DRAW_REAL_WORLD: boolean = true;
  static readonly CHEAT: boolean = false;
  static readonly DRAW_TORPED_CALC: boolean = false;
  
  // Настройки дисплея
  static readonly SCREEN_WIDTH: number = 1000;
  static readonly SCREEN_HEIGHT: number = 700;
  static readonly SCALE_MAIN: number = 1.5;
  
  // Физика
  static readonly koef_v: number = 30;
  static readonly alfa_v: number = 0.0005;
  static readonly alfa_r_0: number = 0.001;    // поворот на минимальной скорости
  static readonly alfa_r_30: number = 0.005;   // поворот на максимальной скорости
  
  // Торпеды
  static readonly HIT_TIME_RELOAD_INCREASE: number = 1.3;
  static readonly HIT_SHIP_SPEED_DECREASE: number = 1.3;
  static readonly SHIP_HIT_SIZE: number = 10;
  
  // Торпеда Тип I
  static readonly TRP_I_LIFE_TIME_SEC: number = 60;
  static readonly TRP_I_MAX_VELOCITY: number = 60.0;
  static readonly TRP_I_MANEVR_PRC: number = 80;
  static readonly TRP_I_TIME_RELOAD_SEC: number = 120;
  static readonly TRP_I_DAMEGE: number = 1000.0;
  static readonly TRP_I_DIST_EXECUTION: number = 1000.0;
  
  // Торпеда Тип II
  static readonly TRP_II_LIFE_TIME_SEC: number = 60;
  static readonly TRP_II_MAX_VELOCITY: number = 50.0;
  static readonly TRP_II_MANEVR_PRC: number = 80;
  static readonly TRP_II_TIME_RELOAD_SEC: number = 120;
  static readonly TRP_II_DAMEGE: number = 800.0;
  static readonly TRP_II_DIST_EXECUTION: number = 1000.0;
  
  // Торпеда Тип III
  static readonly TRP_III_LIFE_TIME_SEC: number = 30;
  static readonly TRP_III_MAX_VELOCITY: number = 38.0;
  static readonly TRP_III_TRG_ACCEPT_DIST: number = 200.0;
  static readonly TRP_III_MANEVR_PRC: number = 80;
  static readonly TRP_III_TIME_RELOAD_SEC: number = 200;
  static readonly TRP_III_DAMEGE: number = 500.0;
  static readonly TRP_III_DIST_EXECUTION: number = 300.0;
  
  // Другие настройки
  static readonly koef_coast: number = 15;
  static readonly TAIL_MAX_LENGTH: number = 10;
  static readonly TAIL_TIME_INTERVAL: number = 1000;
  static readonly TAIL_COLOR: number = 0x00FF00;
  
  // Интервалы обновления
  static readonly MOVE_INTERVAL_MS: number = 20;
  static readonly SLOW_LOOP_INTERVAL_MS: number = 500;
  
  // ИИ настройки
  static readonly AI_torped_fire_interval: number = 100;
  static readonly WEB_ENABLE: boolean = true;
  
  // Настройки атаки торпедами
  static readonly TRP_ATACK__ANGLE_WARNING: number = 25.0;
  static readonly TRP_ATACK_DISTANCE_WARNING: number = 500.0;
  static readonly TRP_ATACK_DEFENSE_ANGLE: number = 45.0;
  static readonly TRP_ATACK_ALARM_DIST: number = 300.0;
  static readonly MOVE_ON_TARGET_FROM_DIST: number = 1000;
  
  // Настройки шума
  static readonly NOISE_TRAKCING_RANGE: number = 0.2;
  static readonly NOISE_DIRECTION: number = 0.5;
  static readonly NOISE_DETECTION: number = 0.8;
  
  // Настройки для точек маршрута и хвоста
  static readonly WAY_POINT_COLOR: number = 0xFFFF00;
  
  // Максимальная дальность обнаружения (используется как "бесконечность" для некоторых расчетов)
  static readonly MAX_DETECTION_RANGE: number = 20000; // Произвольное большое значение
  
  // Отладочный вывод значения коэффициента
  static {
    console.log(`Настройки загружены. koef_coast = ${Settings.koef_coast}`);
  }
} 