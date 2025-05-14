/**
 * Константы игры
 */
export class Constants {
  // Состояния торпедного аппарата
  static readonly ST_TA_EMPTY: number = 0;
  static readonly ST_TA_LOADING: number = 1;
  static readonly ST_TA_READY: number = 2;
  
  // Лампы и индикаторы
  static readonly LAMP_TRPRD_I: string = "TRD I";
  static readonly LAMP_TRPRD_II: string = "TRD II";
  static readonly LAMP_TRPRD_III: string = "TRD III";
  static readonly LAMP_TRPRD_IV: string = "TRD IV";
  static readonly LAMP_WP: string = "WP";
  static readonly LAMP_TRP_ATACK: string = "TATC";
  
  // Типы оружия
  static readonly WEAPON_SELECT_UNKNOWN: number = 0;
  static readonly WEAPON_SELECT_TORP_I: number = 1;
  static readonly WEAPON_SELECT_TORP_II: number = 2;
  static readonly WEAPON_SELECT_TORP_III: number = 3;
  static readonly WEAPON_SELECT_TORP_IV: number = 4;
  
  // Стороны конфликта
  static readonly FORCES_RED: number = 0;
  static readonly FORCES_WHITE: number = 1;
  
  // Цвета
  static readonly COLOR_DARK_GRAY: number = 0x828282;
  static readonly COLOR_WHITE: number = 0x7fff00;
  static readonly COLOR_LIGHT_RED: number = 0xFF4500;
  static readonly COLOR_LIGHT_WHITE: number = 0xFFFFFF;
  static readonly COLOR_LIGHT_GREEN: number = 0x7fff00;
  static readonly COLOR_LIGHT_YELLOW: number = 0xffff00;
  static readonly COLOR_LIGHT_GRY: number = 0xF5F5F5;
  static readonly COLOR_DARK_RED: number = 0xA52A2A;
  static readonly COLOR_DARK_WHITE: number = 0xA9A9A9;
  static readonly COLOR_MADIUM_RED: number = 0xC71585;
  static readonly COLOR_MADIUM_WHITE: number = 0xDCDCDC;
  
  // Настройки точек маршрута
  static readonly WAY_POINT_SIZE: number = 10;
  static readonly WAY_POINT_COLOR: number = 0x90EE90;
  static readonly WAY_POINT_COLOR_TORPED: number = 0xFF6347;
  static readonly WAY_POINT_COLOR_TARGET: number = 0x000000;
  static readonly WAY_POINT_COLOR_T_DEFENCE: number = 0xFF8247;
  
  // Типы точек маршрута
  static readonly WP_SHIP: number = 1;
  static readonly WP_TARGET: number = 2;
  static readonly WP_TARGET_SEARCH: number = 3;
  static readonly WP_TORP: number = 4;
  static readonly WP_TORP_DEFENCE: number = 5;
  static readonly WP_CONVOY: number = 6;
} 