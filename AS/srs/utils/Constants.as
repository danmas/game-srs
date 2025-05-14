package srs.utils 
{
	/**
	 * ...
	 * @author ...
	 */
	
	 
	public class Constants {
		
		public static const ST_TA_EMPTY:int = 0;
		public static const ST_TA_LOADING:int = 1;
		public static const ST_TA_READY:int = 2;
		
		public static const LAMP_TRPRD_I:String = "TRD I";	
		public static const LAMP_TRPRD_II:String = "TRD II";	
		public static const LAMP_TRPRD_III:String = "TRD III";	
		public static const LAMP_TRPRD_IV:String = "TRD IV";	
		//public static const LAMP_TRAP_1:String = "TRD 1";	
		//public static const LAMP_TRAP_2:String = "TRD 2";	
		//public static const LAMP_TRAP_3:String = "TRD 3";	
		//public static const LAMP_TRAP_4:String = "TRD 4";	
		public static const LAMP_WP:String = "WP";	
		public static const LAMP_TRP_ATACK:String = "TATC";	
		
		//-- выбор пользователем типа оружия
		public static const WEAPON_SELECT_UNKNOWN:int = 0;
		public static const WEAPON_SELECT_TORP_I:int = 1;  //-- торпеды идущие в точку указания но несамонаводящиеся
		public static const WEAPON_SELECT_TORP_II:int = 2;  //-- торпеды самонаводящиеся
		public static const WEAPON_SELECT_TORP_III:int = 3;  //-- торпеды самонаводящиеся
		public static const WEAPON_SELECT_TORP_IV:int = 4;  //-- торпеды дальние самонаводящиеся
	
		public static const FORCES_RED:int = 0;
		public static const FORCES_WHITE:int = 1;

		public static const COLOR_DARK_GRAY:int = 0x828282;
		public static const COLOR_WHITE:int = 0x7fff00;
		public static const COLOR_LIGHT_RED:int = 0xFF4500;
		public static const COLOR_LIGHT_WHITE:int = 0xFFFFFF;
		public static const COLOR_LIGHT_GREEN:int = 0x7fff00;
 		public static const COLOR_LIGHT_YELLOW:int = 0xffff00;
		public static const COLOR_LIGHT_GRY:int = 0xF5F5F5; 
		public static const COLOR_DARK_RED:int = 0xA52A2A;
		public static const COLOR_DARK_WHITE:int = 0xA9A9A9;
		public static const COLOR_MADIUM_RED:int = 0xC71585;
		public static const COLOR_MADIUM_WHITE:int = 0xDCDCDC;
		
		public static const WAY_POINT_SIZE:int = 10; //-- миниммальная дистанция на которую нужно подойти к контрольной точке 
		                                             // чтобы считалось что она достигнута (есть опасность, что можно проскочить!) 
		public static const WAY_POINT_COLOR:int = 0x90EE90;
		public static const WAY_POINT_COLOR_TORPED:int = 0xFF6347; 
		public static const WAY_POINT_COLOR_TARGET:int = 0x000000;													 
		public static const WAY_POINT_COLOR_T_DEFENCE:int = 0xFF8247;													 
		
		public static const WP_SHIP:int = 1;
		public static const WP_TARGET:int = 2;
		public static const WP_TARGET_SEARCH:int = 3;
		public static const WP_TORP:int = 4;
		public static const WP_TORP_DEFENCE:int = 5;
		public static const WP_CONVOY:int = 6;
	}

}