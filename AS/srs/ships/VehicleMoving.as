package srs.ships 
{
	import flash.geom.Point

	import srs.*;
	import srs.utils.*;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class VehicleMoving 
	{
		
		public function VehicleMoving() {
		}

		/**
		 * Возвращает коеффициент поворота в зависимости от скорости
		 * 100. - та скорость на которой поменяется знак (руль начнет действовать в обратную сторону
		 */
		public static function getAlphaR(vel:Number, _manevr_perc:int):Number {
			var ar:Number = (Settings.alfa_r_30 -  Settings.alfa_r_0) / (100.*Settings.koef_v) * vel + Settings.alfa_r_0;  
			//trace(ar);
			return ar * _manevr_perc / 100.;
		}
		
		/**
		 * Calculate velocity from current power
		 * 
		 * @param	dt_ms             - time ms
		 * @param	_velocity_gm      - velocity in game_dist/ms
		 * @param	_max_velocity_hum - max velocity in human units (knots)
		 * @param	_power            - 0,1,2,3,4,5,6
		 * @return
		 */ 
		public static function calc_velocity(dt_ms:Number,_velocity_gm:Number, _max_velocity_hum:Number, _power:Number):Number {
			var v:Number = (_max_velocity_hum*Settings.koef_v)  / 6. * _power;
			if (_velocity_gm < v) {
				_velocity_gm += (v - _velocity_gm) * Settings.alfa_v * dt_ms;
				if (_velocity_gm > v) 
					_velocity_gm = v;
			}
			
			if (_velocity_gm > v) {
				_velocity_gm -= (_velocity_gm - v) * Settings.alfa_v * dt_ms;
				if (_velocity_gm < v) 
					_velocity_gm = v;
			}
			return _velocity_gm;
		}
		
		/**
		 * Предсказание движения цели. 
		 * Вычисляет положение через момент времени time_ms 
		 * относительный от текущего
		 * 
		 * @param	time_ms - момент времени от текущего
		 * @param	_vp     - параметры движения цели 
		 * @param	command_params    - команды цели
		 * @param	_max_velocity_hum - макс скорость цели (hum)
		 * @param	_manevr_perc      - маневренность цели 
		 * 
		 * @return  параметры движения цели через time_ms
		 */ 
		public static function move_calc_pos2(time_ms:int, _vp:VehicleParams
			, command_params:VehicleCommandParams
			, _max_velocity_hum:Number
			, _manevr_perc:int):VehicleParams {
			var cur_time:int = time_ms;
			
			var vp:VehicleParams = new VehicleParams(_vp.position,_vp.velocity,_vp.direction);
			
			var delta_t:int; // = Settings.AI_TF_IMMITATION_DELTA_T_MS; 
			if (command_params.power >= Vehicle.POWER_5
				|| command_params.rudder <= Vehicle.RUDER_RIGHT_10 
				|| command_params.rudder <= Vehicle.RUDER_LEFT_10 ) {
					delta_t = 20.;
				} else if (command_params.rudder == Vehicle.RUDER_0) {
					delta_t = 100.;
				} else {
					delta_t = 50.;
				}
			
			//var delta_t:int = time / 100;
			
			var t:int = delta_t;
			var p:Point;
			var i:int = 0;
			for (; t < time_ms; ) {
				i++;
				var si:String = i.toString(); 
				Main.main.getInformer().writeDebugRightField("i2", si);

				//-- calculate new speed depended from power
				var new_velocity_gm:Number = calc_velocity(delta_t, vp.velocity, _max_velocity_hum,  command_params.power); //!!!!!
				var cur_vel_gm:Number = vp.velocity + (new_velocity_gm - vp.velocity) / 2.;
				
				vp.direction -= delta_t * command_params.rudder * getAlphaR(cur_vel_gm, _manevr_perc) * cur_vel_gm;
				
				//-- calculate new position
				p = Point.polar(delta_t * cur_vel_gm, Utils.toScreenRad(vp.direction)); 
				vp.position = vp.position.add(p);
				
				vp.velocity = cur_vel_gm;
				t += delta_t;
			}

			var lost_time:Number = new Number( time_ms - (t - delta_t));
			
			p = Point.polar(lost_time * cur_vel_gm, Utils.toScreenRad(vp.direction)); 
			vp.position = vp.position.add(p);
			
			if(Settings.CHEAT) {
				var lost_pos:Number = cur_vel_gm * lost_time;
				trace("time / delta_t=" + time_ms / delta_t + " t - delta_t =" + lost_time + " lost_pos=" + lost_pos  );
			}
			return vp;
		}
		
		
		/**
		 * Расчет шума 
		 * 
		 * ИЗМЕНЯТЬ СОВМЕСТНО С calcNoiseDistanse()
		 * 
		 * @param	_noisy - шумность объекта
		 * @param	_pow   - текущая мощность двигателя
		 * @param	_dist  - расстояние gm
		 * @return  - шум объекта
		 */
		public static function  calcNoise(_noisy:Number, _pow:int, _dist:Number):Number {
			var pw:Number = Math.abs(_pow);
			if (pw == 0)	pw = 0.05;
			if (pw == 1)	pw = 0.2;
			if (pw == 2)	pw = 1;
			var ns:Number =3.*_noisy * 1000000.*pw / 36. / (_dist * _dist);
			//-- умножаем на включенные сонары
			//...
			
			//Main.main.getInformer().writeDebugRightField("noise", ns.toFixed(5));
			return ns;
		}
		
		/**
		 * Рассчет расстояния на котором оказывается заданный уровень шума
		 * 
		 * ИЗМЕНЯТЬ СОВМЕСТНО С calcNoise();
		 * 
		 * @param	_noisy - шумность объекта
		 * @param	_pow   - текущая мощность двигателя
		 * @param	_noise - заданный уровень шума 
		 * @return  - расстояние in gm
		 */
		public static function  calcNoiseDistanse(_noisy:Number, _pow:int, _noise:Number):Number {
			var pw:Number = Math.abs(_pow);
			if (pw == 0) pw = 0.05;
			if (pw == 1)	pw = 0.2;
			if (pw == 2)	pw = 1;
			var dist:Number =Math.sqrt( 3.*_noisy * 1000000.*pw / 36. / (_noise));
			//-- умножаем на включенные сонары
			//...
			
			//Main.main.getInformer().writeDebugRightField("noise", ns.toFixed(5));
			return dist;
		}
		
	/*
	 * Перевод из полярной системы в декартову
	 */ 
	//public function fromPolarToCortesian(r:Number,theta:number):Point {
	//	return new Point(r * Math.cos( theta ), r * Math.sin( theta ));
	//}
	
		
	}

}