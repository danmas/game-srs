package srs.scenario 
{
	import srs.ships.TorpedParams;
	import srs.*;
	import srs.utils.WeaponTypes;
	import srs.utils.Constants;
	
	/**
	 * Склад торпед представляет собой коллекцию оружия
	 * 
	 * В сценарии можно выбрать и сделать активным любой подтип для данного типа со склада
	 * Store.setCurParams_II("Type IIa"); - изменяет тип II
	 * 
	 * @author Erv
	 */
	public class Store 
	{
		
		protected  var torped_types:Array;
		
		//-- в сценарии все торпеды типа I будут с этими параметрами
		public  var cur_I_params:TorpedParams;
		//-- в сценарии все торпеды типа II будут с этими параметрами
		public  var cur_II_params:TorpedParams;
		//-- в сценарии все торпеды типа III будут с этими параметрами
		public  var cur_III_params:TorpedParams;
		
		public  function Store() {
				torped_types = new Array();
				
				var t1:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_I);
				t1.weapon_type = Constants.WEAPON_SELECT_TORP_I;
				t1.max_time_life_sec = Settings.TRP_I_LIFE_TIME_SEC;
				t1.max_velocity_hum = Settings.TRP_I_MAX_VELOCITY;
				t1.manevr_prc = Settings.TRP_I_MANEVR_PRC;
				t1.time_reload_ms = 1000.*Settings.TRP_I_TIME_RELOAD_SEC;
				t1.damage = Settings.TRP_I_DAMEGE;
				t1.dist_execution = Settings.TRP_I_DIST_EXECUTION;
				torped_types.push(t1);
				cur_I_params = t1;
				
				var t2:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_II);
				t2.weapon_type = Constants.WEAPON_SELECT_TORP_II;
				t2.max_time_life_sec = Settings.TRP_II_LIFE_TIME_SEC;
				t2.max_velocity_hum = Settings.TRP_II_MAX_VELOCITY;
				t2.manevr_prc = 100; // Settings.TRP_II_MANEVR_PRC;
				t2.time_reload_ms =1000.* Settings.TRP_II_TIME_RELOAD_SEC;
				t2.damage = Settings.TRP_II_DAMEGE;
				t2.dist_execution = Settings.TRP_II_DIST_EXECUTION;
				torped_types.push(t2);
				cur_II_params = t2;
				
				var t3:TorpedParams = new TorpedParams(WeaponTypes.WT_TYPE_III);
				t3.weapon_type = Constants.WEAPON_SELECT_TORP_III;
				t3.max_time_life_sec = Settings.TRP_III_LIFE_TIME_SEC;
				t3.max_velocity_hum = Settings.TRP_III_MAX_VELOCITY;
				t3.manevr_prc = Settings.TRP_III_MANEVR_PRC;
				t3.trg_accept_dist = Settings.TRP_III_TRG_ACCEPT_DIST;
				t3.time_reload_ms = 1000.*Settings.TRP_III_TIME_RELOAD_SEC;
				t3.damage = Settings.TRP_III_DAMEGE;
				t3.dist_execution = Settings.TRP_III_DIST_EXECUTION;
				torped_types.push(t3);
				cur_III_params = t2;
		}
		
		public  function setCurParams_I(_trp_name:String):void {
			 var tp:TorpedParams = getTorpedParams(_trp_name);
			 if (tp != null) {
				 cur_I_params = tp;
			 }
		}
		
		public  function setCurParams_II(_trp_name:String):void {
			 var tp:TorpedParams = getTorpedParams(_trp_name);
			 if (tp != null) {
				 cur_II_params = tp;
			 }
		}
		
		public  function setCurParams_III(_trp_name:String):void {
			 var tp:TorpedParams = getTorpedParams(_trp_name);
			 if (tp != null) {
				 cur_III_params = tp;
			 }
		}
		
		public function getParams(weapon_type:int):TorpedParams {
			if (weapon_type == Constants.WEAPON_SELECT_TORP_I) {
				return getParams_I();
			} else if (weapon_type == Constants.WEAPON_SELECT_TORP_II) {
				return getParams_II();
			} else if (weapon_type == Constants.WEAPON_SELECT_TORP_III) {
				return getParams_III();
//			} else if (weapon_type == Constants.WEAPON_SELECT_TORP_I) {
//				return getParams_I();
			}
			trace("getParams() UNKNOWN weapon  " + weapon_type); 
			return null;
		}

		public function getParams_I():TorpedParams {
				return cur_I_params;
		}
		
		public function getParams_II():TorpedParams {
				return cur_II_params;
		}
		
		public function getParams_III():TorpedParams {
				return cur_III_params;
		}
		
		public  function getTorpedParams(_trp_name:String):TorpedParams {
			for each(var t:TorpedParams in torped_types) {
				if (t.trp_name == _trp_name) {
					return t;
				}
			}
			return null;
		}
		
	}

}