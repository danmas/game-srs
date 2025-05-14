package srs.ships 
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class VehicleParams {

		public var position:Point; 
		public var velocity:Number = 0.;   // in pixel/millisecs
		public var direction:Number = 0. ;  // direction in degree

		public function VehicleParams(_position:Point,_velocity:Number,_direction:Number) {
			position = _position;
			velocity = _velocity;
			direction = _direction;
		}
		
	}

}