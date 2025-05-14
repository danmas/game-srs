package srs.ships 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class Target  {
		
		public var ship:Ship;
		public var noise:Number;
		public var distance:Number;
		
		public function Target(_ship:Ship, _noise:Number) {
				ship = _ship;
				noise = _noise;
		}
		
	}

}