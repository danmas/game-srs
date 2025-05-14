package srs.scenario 
{
	import srs.ships.TorpedParams;
	import srs.*;
	import srs.utils.WeaponTypes;
	import srs.utils.Constants;

	/**
	 * Торпеды белых.
	 * 
	 * @author Erv
	 */
	public class StoreWhite  extends Store
	{
		
		public function StoreWhite()  {
			super();
			
			var t1:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_IA_W);
			t1.weapon_type = Constants.WEAPON_SELECT_TORP_I;
			t1.max_time_life_sec = Settings.TRP_I_LIFE_TIME_SEC;
			t1.max_velocity_hum = 90; // Settings.TRP_I_MAX_VELOCITY;
			t1.manevr_prc = Settings.TRP_I_MANEVR_PRC;
			t1.time_reload_ms =1000.*Settings.TRP_I_TIME_RELOAD_SEC;
			t1.damage = Settings.TRP_I_DAMEGE;
			t1.dist_execution = Settings.TRP_I_DIST_EXECUTION;
			torped_types.push(t1);
			setCurParams_I(WeaponTypes.WT_TYPE_IA_W);
			
			/*
			var t2a:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_IIA_W);
			t2a.weapon_type = Constants.WEAPON_SELECT_TORP_II;
			t2a.max_time_life_sec = Settings.TRP_II_LIFE_TIME_SEC;
			t2a.max_velocity_hum = Settings.TRP_II_MAX_VELOCITY;
			t2a.manevr_prc = Settings.TRP_II_MANEVR_PRC;
			torped_types.push(t2a);
			setCurParams_II(WeaponTypes.WT_TYPE_II);
			*/
			
			//-- Тип III. медленная и маломаневренная
			var t3a:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_IIIA_W);
			t3a.weapon_type = Constants.WEAPON_SELECT_TORP_III;
			t3a.max_time_life_sec = 60; // Settings.TRP_III_LIFE_TIME_SEC;
			t3a.max_velocity_hum = 30; // Settings.TRP_III_MAX_VELOCITY;
			t3a.manevr_prc = 50; // Settings.TRP_III_MANEVR_PRC;
			t3a.trg_accept_dist = Settings.TRP_III_TRG_ACCEPT_DIST;
			t3a.time_reload_ms = 1000.*Settings.TRP_III_TIME_RELOAD_SEC;
			t3a.damage = Settings.TRP_III_DAMEGE;
			t3a.dist_execution = Settings.TRP_III_DIST_EXECUTION;
			torped_types.push(t3a);
			
			setCurParams_III(WeaponTypes.WT_TYPE_IIIA_W);
		}
		
	}

}