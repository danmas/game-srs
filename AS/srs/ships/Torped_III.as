package srs.ships 
{
	import flash.geom.Point;
	import srs.*;
	import srs.utils.*;
	import srs.scenario.Store;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Torped_III  extends Torped
	{
		protected var trg_accept_dist:Number;
		
		public function Torped_III(_main:Main,red_white:int) {
			super(_main);
			//weapon_type = Constants.WEAPON_SELECT_TORP_III;
			command_params.power = Vehicle.POWER_6;

			var tp:TorpedParams; 
			if(red_white == Constants.FORCES_RED)
				tp = Main.getRedStore().getParams_III();
			else 
				tp = Main.getWhiteStore().getParams_III();
			
			weapon_type = tp.weapon_type;	
			max_velocity_hum = tp.max_velocity_hum
			max_time_life_sec = tp.max_time_life_sec;
			moveOnTarget(true);
			setManevr(tp.manevr_prc);
			trg_accept_dist = tp.trg_accept_dist;
			damage = tp.damage;
			dist_execution = tp.dist_execution;
		}
		
		
		/*
		 * Выбор цели
		 * 
		 * overrided для Ship и Torpedo 
		 */ 
		override public function selectTarget():Target {
			if (forces == Constants.FORCES_RED) {
				var dist_t:Number = trg_accept_dist;
				target = new Target(null, 0);
				for each(var s:Ship in main.getWhiteShips()) {
					var dist:Number = Point.distance(position_gm, s.getPosition());
					if (dist < dist_t) {
						dist_t = dist;
						target.ship = s;
					}
				}
			} else {
				//-- ищем из всех самую ближнюю цель
				var dist_t:Number = trg_accept_dist;
				target = new Target(null, 0);
				for each(var s:Ship in main.getRedShips()) {
					var dist:Number = Point.distance(position_gm, s.getPosition());
					if (dist < dist_t) {
						dist_t = dist;
						target.ship = s;
					}
				}
			}
			if (target.ship == null) {
				target = null; 
			}
			return target; // target;
		}
		
		
	/*
	 * Выбор направления движения.
	 * сначала выбираем цель
	 * 
	 * 	override in Ship, Torped_III
	 * 
	 */ 
	override public function AI_step_I():void {
		//-- выбираем цель
		target = selectTarget();
		//super.AI_step_I();
		if ( (move_on_target && target != null) 
			&& move_state != ST_WP_TORP_DEFENCE_MOVING) {
			//-- чистим предыдущую WP
			if(way_points!=null) {
				stopMoveOnWayPoint();
			}
			//-- выбираем цель
			// в Torped_III и Ship target = selectTarget();
			//if ( target != null) {
				//-- устанавливаем WP на цель 
				addWayPoint(target.ship.getPosition().x, target.ship.getPosition().y, Constants.WP_TARGET);
				move_state = ST_WP_TARGET;
				//-- двигаемся с максимальной скоростью
				setPower(POWER_6);
				startMoveOnWP(/*Constants.WP_TARGET*/);
			//}
		}
	}
	
		
		
		/*
		 * Проверка на попадание торпеды
		 * 
		 * НУЖНО ПЕРЕОПРЕДЕЛИТЬ ДЛЯ ТОРПЕДЫ II
		 */ 
		//protected function hitDetection():void {
		//	
		//}

	}

}