package srs.ships 
{
	/**
	 * Команды на исполнения для автомата управления
	 * 
	 * Команды выполняются последовательно по истечению времени каждой.
	 * ...
	 * @author Erv
	 */
	public class Command {
		public var power:int;
		public var rudder:int;
		protected var time_execution_msec:int = 0; //-- длительность исполнения команды
		public var time_start_execute:int = 0; //-- время по корабельным часам когда началось исполнение команды
		
		public function Command( _power:int, _rudder:int, _time_execution_sec:int) {
			power = _power;
			rudder = _rudder;
			time_execution_msec = _time_execution_sec*1000;
		}
		
		public function setTimeExecutionSec(_time_execution_sec:int):void {
			time_execution_msec = _time_execution_sec*1000;
		}
		
		public function isTimeExpiried(current_time:int):Boolean {
			return current_time - time_start_execute > time_execution_msec;
		}
	}

}