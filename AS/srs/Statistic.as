package  srs
{
	/**
	 * Собирает статистику по игре
	 * 
	 * @author Erv
	 */
	public class Statistic {
		
		public static var enemy_hit_count:int = 0; //-- EHC кол-во попаданий во врагов 
		public static var friend_hit_count:int = 0; //-- FHC кол-во попаданий в наши суда
		
		public static var enemy_destroyed:int = 0;  //-- ED кол-во потопленных врагов
		public static var friend_destroyed:int = 0;  //-- FD кол-во потопленных наших
		public static var enemy_fire_count:int = 0;  //-- EFC кол-во попаданий во врагов 
		public static var friend_fire_count:int = 0; //-- FFC кол-во попаданий в наши суда
		
		public static var time_leave_port_sec:int = 0; //-- TLP время выхода из порта (пересечения области port_line)
		public static var time_game_sec:int = 0;       //-- TG время выполнения миссии (сек)
		
		public static var AI_calc_time:int = 0;  //-- время потраченное на работу AI
	}

}