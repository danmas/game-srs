package srs.ships 
{
	import srs.utils.Constants;
	import srs.*;
	import srs.scenario.Store;
	import srs.sounds.SoundTorpLoad;
	
	/**
	 * Торпедный аппарат
	 * 
	 * @author Erv
	 */
	public class TorpedApp 
	{
		public var state:int = Constants.ST_TA_READY;
		protected var beg_loading_time:int = 0;
		protected var torp_trype:int;  //-- тип торпеды которой назначен этот аппарат
		
		protected var ship:Ship; //-- судно на котором расположн ТА  
		
		public function TorpedApp(_ship:srs.ships.Ship) {
			ship = _ship;
			//-- по умолчанию стреляем первым типом
			torp_trype = Constants.WEAPON_SELECT_TORP_I;
		}
		
		/**
		 * Начать загрузку торпеды 
		 */
		public function load():void {
			if (state == Constants.ST_TA_EMPTY) {
				beg_loading_time = Main.getTime();
				state = Constants.ST_TA_LOADING;
				
				//Main.get
			}
		}
		
		/**
		 * На событие выстрела
		 */
		public function onFire():void {
			state = Constants.ST_TA_EMPTY;
			//-- автоматическое заряжания
			load();
		}
		
		public function onSlowLoop(time:int):void {
			if(state == Constants.ST_TA_LOADING) { 
				//var tp:TorpedParams =  Store.getParams(torp_trype);
				if (time - beg_loading_time >  ship.getStore().getParams(torp_trype).time_reload_ms) {
					//Main.main.getInformer().writeDebugText(" TORP READY " + ship.getStore().getParams(torp_trype).time_reload_ms);
					state = Constants.ST_TA_READY;
					var snd:SoundTorpLoad ;
					snd = new SoundTorpLoad();
					snd.play(0.5);
					beg_loading_time = time;
				}
			}
		}
		
		
		/**
		 * Назначить аппарат под тип торпеды
		 * @param	_torp_trype
		 */
		public function setType(_torp_trype:int):void {
			var old_torp_trype:int = torp_trype;
			torp_trype = _torp_trype;
			//-- если тип сменился то загружаем
			if (torp_trype != old_torp_trype) {
				load();
			}
		}
		
		public function getType():int {
			return torp_trype;
		}
		
	}

}