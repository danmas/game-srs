package srs.ships 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class TorpedParams 
	{
		public var trp_name:String; //-- имя торпеды с такими параметрами
		public var max_time_life_sec:Number; //-- in sec;
		public var max_velocity_hum:Number; 
		public var manevr_prc:int; 
		public var weapon_type:int;
		public var time_reload_ms:int;
		public var damage:Number;
		public var dist_execution:Number;
		
		//-- для типа III
		public var trg_accept_dist:Number;

		public function TorpedParams(_trp_name:String) {
			trp_name = _trp_name;
		}
		
	}

}