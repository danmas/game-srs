package srs.utils 
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	/**
	 * Лампочка в панели Информера
	 * @author Erv
	 */
	public class Lamp extends TextField {
		
		protected var color_off:int = Constants.COLOR_DARK_GRAY;
		protected var color_on:int = Constants.COLOR_WHITE;
		protected var color_not_ready:int = Constants.COLOR_LIGHT_GRY;
		protected var color_ready:int = Constants.COLOR_LIGHT_GREEN;
		protected var color_active:int = Constants.COLOR_LIGHT_YELLOW;
		protected var color_alarm:int = Constants.COLOR_LIGHT_RED;
		protected var color_warning:int = Constants.COLOR_LIGHT_YELLOW;
		protected var color_blink_alarm:int = Constants.COLOR_LIGHT_RED;
		protected var color_blink_warning:int = Constants.COLOR_LIGHT_YELLOW;
		
		//public var l_name:String = "";
		protected var time_last:int = 0;
		protected var st:int = LST_NOT_BLINK;
		
		protected static const LST_NOT_BLINK:int = 0;
		protected static const LST_BLINK_ALARM:int = 1;
		protected static const LST_BLINK_WARNING:int = 2;
		
		protected var gl_filter:GlowFilter = new GlowFilter(0xffffff, .6, 12, 12);
		
		/*
		public function Lamp(_l_name:String,_text:String,_color_off:int = 0xffffff,_color_on:int = 0xffffff) {
			color_off = _color_off;
			color_on = _color_on;
			text = _text;
			l_name = _l_name;
		}*/
		
		public function Lamp(_name:String,_text:String) {
			text = _text;
			name = _name;
			if(filters == null)
				filters = new Array();
		}
		
		/*
		 * Мигает. Преключение между состояниями Active и Warning
		 */ 
		public function blinkAlarmWarning(time:int):void  {
			if ((time - time_last) / 1000. > 0.3) {
				if (st == LST_BLINK_ALARM) {
					backgroundColor = color_blink_warning;
					st = LST_BLINK_WARNING;
				} else if(st == LST_BLINK_WARNING) {
					backgroundColor = color_blink_alarm;
					st = LST_BLINK_ALARM;
				} else {
					st = LST_NOT_BLINK;
				}
				time_last = time;
			}
		}
		
		
		protected function stopBlinkAlarmWarning():void {
			st = LST_NOT_BLINK;
		}
		
		public function startBlinkAlarmWarning():void {
				if(st != LST_BLINK_ALARM && st != LST_BLINK_WARNING) {
					backgroundColor = color_blink_alarm;
					st = LST_BLINK_ALARM;
				}
		}
		
		public function setColors(_color_off:int = 0x828282,  _color_on:int = 0x7fff00, _color_not_ready:int = 0xFF4500
			,_color_ready:int = 0x7fff00, _color_active:int = 0xffff00):void {
			color_off = _color_off;
			color_on = _color_on;
			color_not_ready = _color_not_ready;
			color_ready = _color_ready;
			color_active = _color_active;
		}
		
		public function setOnOff(on:Boolean):void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_off;
		}

		public function setAlarm():void {
			stopBlinkAlarmWarning();
			backgroundColor = color_alarm;
		}
		
		public function setOn():void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_on;
		}
		
		public function setOff():void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_off;
		}
		
		public function setReady():void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_ready;
		}
		
		public function setNotReady():void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_not_ready;
		}
		
		public function setReadyNotReady(ready:Boolean):void {
			stopBlinkAlarmWarning();
			if(ready) 
				this.backgroundColor = color_ready;
			else	
				this.backgroundColor = color_not_ready;
		}
		
		
		public function setActive():void {
			stopBlinkAlarmWarning();
			this.backgroundColor = color_active;
		}
		
	}

}