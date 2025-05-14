package  srs.ships
{
	import flash.geom.Point;

	import srs.*;
	import srs.utils.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Torped  extends Vehicle {
		
		protected var max_time_life_sec:Number; //-- in sec;
		public var weapon_type:int;
		protected var damage:Number; 
		protected var dist_execution:Number; 
		
		public function Torped(_main:Main) {
			super(_main);
			//weapon_type = Constants.WEAPON_SELECT_UNKNOWN;
			//command_params.power = Vehicle.POWER_6;
			//max_velocity = Settings.TRP_I_MAX_VELOCITY; 
			//max_time_life_sec = Settings.TRP_I_LIFE_TIME_SEC;
		}
		
		override protected function draw_ship():void {
			graphics.beginFill(color);
			graphics.drawRect(-1.5, -3, 3, 6);
			graphics.endFill();
		}

		override public function AI_step_II():void {
			super.AI_step_II();
			//-- вермя жизни вышло?
			if (!isTimeLifeEnd()) {
				//-- проверка на попадание в цель
				hitDetection();
			}
		}

		override public function infoText():void {
			if(Settings.DEBUG) {
				var t:Number = (max_time_life_sec * 1000 - time_live_msec) / 1000.; 
				info.text = "[" + weapon_type +"], " +t.toFixed(0) + "s.";
			} else {
				info.text = "";
			}
		}
		
		/**
		 * Проверка времени жизни торпеды
		 * @return true если время жизни кончилось 
		 */
		protected function isTimeLifeEnd():Boolean {
			if (time_live_msec > max_time_life_sec*1000) {
				trace("Torpedo die!");
				destroy();
				return true;
			}
			return false;
		}
		
		/**
		 * Проверка на попадание торпеды
		 * 
		 * НУЖНО ПЕРЕОПРЕДЕЛИТЬ ДЛЯ ТОРПЕДЫ II 
		 */ 
		protected function hitDetection():void {
			//-- проверкан на попадание вражеской торпеды в меня
			//-- красная торпеда?
			if (forces == Constants.FORCES_RED) 
				var enship:Array = main.getWhiteShips();
			else 	
				var enship:Array = main.getRedShips();
			//--  для каждого из массива
			for each (var ss:Ship in enship) {
				//-- вычисляем расстояние
				var dist2:Number = Point.distance(ss.getPosition(), this.getPosition());
				//-- расстояние меньше размера судна для торпеды?
				if (dist2 < ss.getSizeForHit() ) {
					//trace(" !!! HIT !!! dist=" + dist2 + " " + ss.getPosition() + " " +this.getPosition() );
					main.getInformer().setCommandAlarm("Hit the target " +ss.getName() );
					//-- сообщаем цели "приятную" новость
					ss.hasHit(damage);
					//-- убираем торпеду
					destroy();
					break;
				}
			}
		}
		
		public function getWeaponType():int {
			return weapon_type;
		}
		
		public function getMaxTimeLifeSec():uint {
			return max_time_life_sec;
		}
	}
}