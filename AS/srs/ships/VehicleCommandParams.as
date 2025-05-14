package srs.ships 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class VehicleCommandParams {
		
		//-- Vehicle.POWER_0 .. Vehicle.POWER_6
		public var power:int; 
		//-- Vehicle.RUDER_LEFT_15 .. Vehicle.RUDER_0 .. Vehicle.RUDER_RIGHT_15
		public var rudder:int;
		
		public function VehicleCommandParams(_power:int, _rudder:int):void {
			rudder = _rudder;
			power = _power;
		}
		
		public function setCommandParams(_power:int, _rudder:int):void	{
			rudder = _rudder;
			power = _power;
		}

		public function power_change(delta:int):void {
			power += delta;
			if ( power > Vehicle.POWER_6 ) {
				power = Vehicle.POWER_6;
				return;
			}
			if ( power < Vehicle.POWER_M1 ) {
				power = Vehicle.POWER_M1;
				return;
			}
		}
		
		public function rudder_change(delta:int):void {
			//trace("rudder=" + rudder + " delta=" + delta);
			if ((rudder < 0 && delta > 0) || (rudder > 0 && delta < 0))  {
				rudder = Vehicle.RUDER_0;
				return; 
			}
			if (delta > 0) {
				if (rudder == Vehicle.RUDER_0) {
					rudder = Vehicle.RUDER_LEFT_5;
					return;
				}
				if (rudder == Vehicle.RUDER_LEFT_5) {
					rudder = Vehicle.RUDER_LEFT_10;
					return;
				}
				if (rudder == Vehicle.RUDER_LEFT_10) {
					rudder = Vehicle.RUDER_LEFT_15;
					return;
				}
			}
			if (delta < 0) {
				if (rudder == Vehicle.RUDER_0) {
					rudder = Vehicle.RUDER_RIGHT_5;
					return;
				}
				if (rudder == Vehicle.RUDER_RIGHT_5) {
					rudder = Vehicle.RUDER_RIGHT_10;
					return;
				}
				if (rudder == Vehicle.RUDER_RIGHT_10) {
					rudder = Vehicle.RUDER_RIGHT_15;
					return;
				}
			}
		}
		
		public function setPower(_power:int):void {
			power = _power;	
		}
		
		public function setRudder(_rudder:int):void {
			rudder = _rudder;	
		}
	
	}

}