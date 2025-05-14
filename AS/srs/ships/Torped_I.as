package srs.ships 
{
	import srs.*;
	import srs.utils.*;
	import srs.scenario.Store;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Torped_I  extends Torped
	{
		public function Torped_I(_main:Main,red_white:int) {
			super(_main);
			//weapon_type = Constants.WEAPON_SELECT_TORP_I;
			command_params.power = Vehicle.POWER_6;
			
			var tp:TorpedParams; 
			if(red_white == Constants.FORCES_RED)
				tp = Main.getRedStore().getParams_I();
			else 
				tp = Main.getWhiteStore().getParams_I();
			
			weapon_type = tp.weapon_type;	
			max_velocity_hum = tp.max_velocity_hum; 
			max_time_life_sec = tp.max_time_life_sec;
			setManevr(tp.manevr_prc);
			damage = tp.damage;
			dist_execution = tp.dist_execution;
		}
		
	}

}