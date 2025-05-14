
//-- Класс Ситуация 1x1

	
	//-- упоминание о DrakonGen
	   /**
	    * Этот текст сгенерирован программой DrakonGen
	    * @author Erv
	    */
	
	//-- package
	//-- imports
	package  srs.AI
	{
	   import flash.display.Sprite;
	   import flash.geom.Point;
	   import srs.ships.Ship;
	   import srs.ships.Sub;
	
	//-- class Situation1x1
	   /**
	    * ...
	    * @author Erv
	    */
	   public class Situation1x1 {
	
	
	//-- константы
		public static var SIT_ERROR_DETEСTION:String = "SIT_ERROR_DETEСTION"; 
		public static var SIT_NOENEMY:String = "SIT_NOENEMY";
		public static var SIT_ENEMY_HERE:String = "SIT_ENEMY_HERE"; //-- > 0.1
		public static var SIT_ENEMY_DETECTED:String = "SIT_ENEMY_DETECTED";  //-- > 0.2
		public static var SIT_ENEMY_ON_FIRE_DISTANCE:String = "SIT_ENEMY_ON_FIRE_DISTANCE"; //-- > 0.5
		public static var SIT_ENEMY_CLOSE:String = "SIT_ENEMY_CLOSE"; //-- > 0.8
		
		public static var EST_UNKNOWN:String = "UNKNOWN";
		public static var EST_SUB:String = "SUB";
		public static var EST_SHIP:String = "SHIP";
		
		//-- distance change
		public static var DC_UNKNOWN:String = "DC_UNKNOWN";
		public static var DC_NOT_CHANGE:String = "DC_NOT_CHANGE";
		public static var DC_INCREASE:String = "DC_INCREASE";
		public static var DC_DECREASE:String = "DC_DECREASE";
	
	//-- переменные2
	public var situation:String = SIT_NOENEMY;
	public var enemy_ship_type:String = EST_UNKNOWN;
	
	public var enemy_dist_change:String = DC_UNKNOWN;
	public var enemy:Ship;
	public var me:Ship;
	protected var mem_dist:Number = -1;
	
	//-- Situation1x1()
	public function Situation1x1(_me:Ship,_en:Ship) { 
		//-- я = из параметра
		me =_me;
		//-- враг = из параметра
		enemy =_en;
		//-- ситуация = ВРАГ НЕ ОБНАРУЖЕН
		situation =SIT_NOENEMY;
		//-- тип врага = НЕ ОПРЕДЕЛЕН
		enemy_ship_type =EST_UNKNOWN;
		//-- изменение дистанции = НЕОПРЕДЕЛЕНО
		enemy_dist_change =DC_UNKNOWN;
		//-- определяем ситуацию
		detectSituation();
		//-- выход
		return;
		
	} //-- конец процедуры
	//-- оценка ситуации
	public function detectSituation():void { 
		//-- враг указан?
		if(enemy != null) {
			//-- определяем расстояние
			var dist:Number = Point.distance(me.getPosition(), enemy.getPosition());
			
			//-- вычисляем шум цели
			var ns:Number = enemy.calcNoiseAtDist(dist);
			
			//-- враг виден?
			if(ns >= 0.1) {
				//-- Враг ПРИСУТСТВУЕТ?
				if(ns >= 0.1 && ns < 0.2) {
					//-- ситуация = ВРАГ ПРИСУТСТВУЕТ
					situation =SIT_ENEMY_HERE;
				} else {
					//-- враг ОБНАРУЖЕН?
					if(ns >= 0.2 && ns < 0.5) {
						//-- ситуация = ВРАГ ОБНАРУЖЕН
						situation =SIT_ENEMY_DETECTED
						//-- тип врага = НЕ ОПРЕДЕЛЕН
						enemy_ship_type =EST_UNKNOWN;
					} else {
						//-- Враг НЕДАЛЕКО?
						if(ns >= 0.5 && ns < 0.8) {
							//-- ситуация = ВРАГ НЕДАЛЕКО
							situation =SIT_ENEMY_ON_FIRE_DISTANCE
						} else {
							//-- Враг РЯДОМ?
							if(ns >= 0.8) {
								//-- ситуация = ВРАГ РЯДОМ
								situation =SIT_ENEMY_CLOSE
							} else {
								//-- ситуация = ОПРЕДЕЛЕНА ОШИБОЧНО
								situation =SIT_ERROR_DETEСTION;
								//-- выход
								return;
							}
							//-- Тип ПЛ?
							if(enemy is Sub) {
								//-- тип врага = ПЛ
								enemy_ship_type =EST_SUB;
							} else {
								//-- тип врага = НАДВОДНЫЙ
								enemy_ship_type =EST_SHIP;
							}
						}
						//-- Тип ПЛ?
						if(enemy is Sub) {
							//-- тип врага = ПЛ
							enemy_ship_type =EST_SUB;
						} else {
							//-- тип врага = НАДВОДНЫЙ
							enemy_ship_type =EST_SHIP;
						}
					}
					//-- Есть сохраненные данные по цели?
					if(mem_dist != -1) {
						//-- расстояние уменьшилось?
						if(dist < mem_dist) {
							//-- изменение дистанции = УМЕНЬШИЛОСЬ
							enemy_dist_change =DC_DECREASE;
						} else {
							//-- расстояние увеличилось?
							if(dist > mem_dist) {
								//-- изменение дистанции = УВЕЛИЧИЛОСЬ
								enemy_dist_change =DC_INCREASE;
							} else {
								//-- изменение дистанции = НЕ ИЗМЕНИЛОСЬ
								enemy_dist_change =DC_NOT_CHANGE;
							}
						}
					} else {
						//-- изменение дистанции = НЕИЗВЕСТНО
						enemy_dist_change =DC_UNKNOWN;
					}
					//-- запоминаем данные цели
					mem_dist = dist;
				}
			} else {
				//-- изменение дистанции = НЕОПРЕДЕЛЕНО
				enemy_dist_change =DC_UNKNOWN;
			}
		} else {
			//-- ситуация = ОПРЕДЕЛЕНА ОШИБОЧНО
			situation =SIT_ERROR_DETEСTION;
			//-- тип врага = НЕ ОПРЕДЕЛЕН
			enemy_ship_type =EST_UNKNOWN;
			//-- изменение дистанции = НЕОПРЕДЕЛЕНО
			enemy_dist_change =DC_UNKNOWN;
		}
		//-- выход
		return;
	} //-- конец процедуры
	//-- getCode()
	public function getCode():String { 
		//-- строим код
		var ret_code:String = "";
		ret_code += enemy.getName();
		ret_code += " "+situation;
		ret_code += " "+enemy_ship_type;
		ret_code += " "+enemy_dist_change;
		
		//-- 
		//--       
		return ret_code;
	} //-- конец процедуры
	//-- Выход
		//-- конец
		   } //-- конец класса
		} //-- крнец пакета
