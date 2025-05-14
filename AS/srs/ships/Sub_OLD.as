package srs.ships 
{
	import srs.*;
	import srs.utils.Constants;
	
	/**
	 * Подводная лодка
	 * 
	 * @author Erv
	 */
	public class Sub_OLD  extends Ship {
		
		protected var torp_aps:Array = new Array(); 
		
		public function Sub_OLD(_main:Main,_enemy:int) {
			super(_main, _enemy);
			
			//-- четыре носовых ТА
			var ta:TorpedApp = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(1, Constants.WEAPON_SELECT_TORP_I);

			ta = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(2, Constants.WEAPON_SELECT_TORP_II);
			
			ta = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(3, Constants.WEAPON_SELECT_TORP_III);
			
			ta = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(4, Constants.WEAPON_SELECT_TORP_III);
		}
		
		override public function onSlowLoop(time:int):void {
			for each(var ta:TorpedApp in torp_aps) {
				ta.onSlowLoop(time);
			}
		}
		
		/**
		 * Проверка готовности оружия weapon_type к стрельбе
		 * 
		 * @param	weapon_type - тип оружия
		 * @return    TorpedApp - готовый к стрельбе
		 */
		override public function isWeaponReady(weapon_type:int):TorpedApp {
			for each(var ta:TorpedApp in torp_aps) {
				if (ta.getType() == weapon_type && ta.state == Constants.ST_TA_READY) {
					//var s:String = " WT=" + weapon_type;
					//Main.main.getInformer().writeDebugRightField("TRD ON", s);
					return ta;
				}
			}
			return null;		
		}

		/**
		 * Назначить аппарат ta_num под торпеду класса _torp_type
		 * 
		 * @param	ta_num
		 * @param	_torp_type
		 */
		public function setTorpAppaForType(ta_num:int, _torp_type:int):void {
			torp_aps[ta_num-1].setType(_torp_type);
		}
	}

}