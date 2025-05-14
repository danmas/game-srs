package srs.scenario 
{
	import srs.ships.TorpedParams;
	import srs.*;
	import srs.utils.WeaponTypes;
	import srs.utils.Constants;

	/**
	 * ...
	 * @author Erv
	 */
	public class StoreRed   extends Store {
		
		public function StoreRed()  {
			super();
			
			//-- Тип II. Высокоскоростная 
			var t2a:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_IIA_R);
			t2a.weapon_type = Constants.WEAPON_SELECT_TORP_II;
			t2a.max_time_life_sec = Settings.TRP_II_LIFE_TIME_SEC;
			t2a.max_velocity_hum = 90; // Settings.TRP_II_MAX_VELOCITY;
			t2a.manevr_prc = Settings.TRP_II_MANEVR_PRC;
			t2a.time_reload_ms = 1000.*Settings.TRP_II_TIME_RELOAD_SEC;
			t2a.damage = Settings.TRP_II_DAMEGE;
			t2a.dist_execution = Settings.TRP_II_DIST_EXECUTION;
			torped_types.push(t2a);
			
			setCurParams_II(WeaponTypes.WT_TYPE_IIA_R);
			
			//-- Тип III. быстрая маломаневренная
			var t3a:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_IIIA_R);
			t3a.weapon_type = Constants.WEAPON_SELECT_TORP_III;
			t3a.max_time_life_sec = 50; // Settings.TRP_III_LIFE_TIME_SEC;
			t3a.max_velocity_hum = 46; // Settings.TRP_III_MAX_VELOCITY;
			t3a.manevr_prc = 60; // Settings.TRP_III_MANEVR_PRC;
			t3a.trg_accept_dist = Settings.TRP_III_TRG_ACCEPT_DIST;
			t3a.time_reload_ms = 1000.*Settings.TRP_III_TIME_RELOAD_SEC;
			t3a.damage = Settings.TRP_III_DAMEGE;
			t3a.dist_execution = Settings.TRP_III_DIST_EXECUTION;
			torped_types.push(t3a);
			
			setCurParams_III(WeaponTypes.WT_TYPE_IIIA_R);
		}
		
	}
	
}