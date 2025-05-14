package srs.utils 
{

	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import srs.Main;
	import srs.Settings;
	
	public class Informer {
		protected const SPD:int = 0;
		protected const POW:int = 1;
		protected const RUD:int = 2;
		protected const DIR:int = 3;
		protected const ZOM:int = 4;
		
		protected const NUMB_FIELDS:int = 5;
		
		protected const COMMAND_HEIGHT:int = 22;
		protected const COMMAND_WIDTH:int = 400;
		protected const COMMAND_COLOR:uint = 0xFFFFFF;

		protected const LBL_WIDTH:int = 50;
		protected const FIELD_HEIGHT:int = 22;
		protected const FIELD_WIDTH:int = 60;
		protected const FIELD_TEXT_SIZE:int = 20;
		protected const FIELD_TEXT_COLOR:uint = 0xFFFFFF;		
		protected const FIELD_TEXT_BGCOLOR:uint = 0x1E90FF;		
		protected const FIELD_ALPHA:Number = 0.8;
		
		protected const R_LBL_WIDTH:int = 150;
		protected const R_FIELD_WIDTH:int = 100;
		protected const R_FIELD_HEIGHT:int = 22;
		protected const R_FIELD_TEXT_SIZE:int = 20;
		protected const R_FIELD_TEXT_COLOR:uint = 0xFFFF00;		
		protected const R_FIELD_TEXT_BGCOLOR:uint = 0x1E90FF;		
		protected const R_ALPHA:Number = 0.8;		

		protected const TF_FIELD_HEIGHT:int = 200;
		protected const TF_FIELD_WIDTH:int = 300;
		protected const TF_FIELD_TEXT_SIZE:int = 20;
		protected const TF_FIELD_TEXT_COLOR:uint = 0xFFFF00;		
		protected const TF_FIELD_TEXT_BGCOLOR:uint = 0x1E90FF;		
		protected const TF_FIELD_ALPHA:Number = 0.8;
		
		protected var main:Main = null;
		
		protected var time	  :TextField;
		protected var player_name  :TextField;
		protected var command :TextField;
		protected var trace_tf :TextField;
		
		protected var fields:Array = [];
		protected var lbls:Array = [];
		protected var r_fields:Array = [];
		protected var r_lbls:Array = [];
		protected var lamps:Array = [];
		
		protected var infopan_h:TextField;
		protected var infopan_t:TextField;
		protected var infopan_f:TextField;

		protected var format:TextFormat = new TextFormat(); 
		protected var format_dop:TextFormat = new TextFormat(); 
		protected var tf_format:TextFormat = new TextFormat(); 
		protected var r_format:TextFormat = new TextFormat(); 
		protected var format_go_1:TextFormat;
		protected var format_go_2:TextFormat; 
		protected var lamp_format:TextFormat = new TextFormat(); 
		

		public function Informer(_main:Main) {
			main = _main;
			
			format.color = FIELD_TEXT_COLOR; 
 			format.font = "Courier"; 
			format.bold = true;
			format.size = FIELD_TEXT_SIZE;
			format.align = "center";

			format_dop.color = 0xFFFF00; 
 			format_dop.font = "Courier"; 
			format_dop.bold = true;
			format_dop.size = FIELD_TEXT_SIZE-2;
			format_dop.align = "center";
			
			r_format.color = R_FIELD_TEXT_COLOR; 
 			r_format.font = "Courier"; 
			r_format.bold = false;
			r_format.size = R_FIELD_TEXT_SIZE-2;
			r_format.align = "center";

			tf_format.color = TF_FIELD_TEXT_COLOR; 
 			tf_format.font = "Segoe"; 
			tf_format.bold = false;
			tf_format.size = TF_FIELD_TEXT_SIZE-2;
			tf_format.align = "left";

			lamp_format.color = 0x000000; 
 			lamp_format.font = "Segoe"; 
			lamp_format.bold = false;
			lamp_format.size = TF_FIELD_TEXT_SIZE-5;
			lamp_format.align = "center";

			player_name =  new TextField();
			player_name.selectable = false;
			player_name.text = ""; 
			player_name.x = 0;
			player_name.y = 10;
			player_name.width = LBL_WIDTH + FIELD_WIDTH + 2;
			player_name .height = FIELD_HEIGHT;
			player_name .border = true;
			player_name .borderColor = FIELD_TEXT_COLOR;
			player_name.background = true;
			player_name.backgroundColor = FIELD_TEXT_BGCOLOR;
			player_name.alpha = FIELD_ALPHA;
			//time.setTextFormat(format1);
			player_name.defaultTextFormat = format;
			main.addChild(player_name);
			
			time =  new TextField();
			time.selectable = false;
			time.text = ""; 
			time.x = 0;
			time.y = player_name.y + player_name.height;
			time.width = LBL_WIDTH + FIELD_WIDTH + 2;
			time .height = FIELD_HEIGHT;
			time .border = true;
			time .borderColor = FIELD_TEXT_COLOR;
			time.background = true;
			time.backgroundColor = FIELD_TEXT_BGCOLOR;
			time.alpha = FIELD_ALPHA;
			//time.setTextFormat(format1);
			time.defaultTextFormat = format;
			main.addChild(time);
			
			var j:int = 0;
			while (j < NUMB_FIELDS) {
				lbls[j] = new TextField();	
				lbls[j] .selectable = false;
				lbls[j] .text = ""; 
				lbls[j].x = 0;
				lbls[j].y = time.y + time.height + 5 + j*FIELD_HEIGHT;
				lbls[j].width = LBL_WIDTH;
				lbls[j] .height = FIELD_HEIGHT;
				lbls[j] .border = true;
				lbls[j] .borderColor = FIELD_TEXT_COLOR;
				lbls[j].background = true;
				lbls[j].backgroundColor = FIELD_TEXT_BGCOLOR;
				lbls[j].alpha = FIELD_ALPHA;
				//lbls[j] .setTextFormat(format1);
				lbls[j] .defaultTextFormat = format;
				main.addChild(lbls[j] );
				
				fields[j] = new TextField();
				fields[j].selectable = true;
				fields[j].text = "0"; 
				fields[j].y = time.y + time.height + 5 + j*FIELD_HEIGHT;
				fields[j].x = lbls[j].x + lbls[j].width + 2;
				fields[j].width = FIELD_WIDTH;
				fields[j].height = FIELD_HEIGHT;
				fields[j].border = true;
				fields[j].borderColor = FIELD_TEXT_COLOR;
				fields[j].background = true;
				fields[j].backgroundColor = FIELD_TEXT_BGCOLOR;
				fields[j].alpha = FIELD_ALPHA;
				fields[j].setTextFormat(format);
				fields[j].defaultTextFormat = format;
				main.addChild(fields[j]);
				j++;
			}
			
			lbls[SPD].text = "SPD";
			lbls[RUD].text = "RUD";
			lbls[DIR].text = "CRS";
			lbls[POW].text = "POW";
			lbls[ZOM].text = "ZOM";
			
			command = new TextField();
			command.selectable = false;
			command.text = ""; 
			command.x = 200;
			command.y = Main.SCREEN_HEIGHT - COMMAND_HEIGHT; // 480;
			command.width = COMMAND_WIDTH;
			command.height = COMMAND_HEIGHT;
			command.border = true;
			command.background = true;
			command.borderColor = FIELD_TEXT_COLOR;
			command.backgroundColor = 0x1E90FF;
			command.alpha = FIELD_ALPHA;
			command.setTextFormat(format);
			command.defaultTextFormat = format;
			main.addChild(command);
			
			panelLampSet(1, Constants.LAMP_TRPRD_I, Constants.LAMP_TRPRD_I, false);
			panelLampSet(2, Constants.LAMP_TRPRD_II, Constants.LAMP_TRPRD_II, false);
			panelLampSet(3, Constants.LAMP_TRPRD_III, Constants.LAMP_TRPRD_III, false);
			panelLampSet(4, Constants.LAMP_TRPRD_III + "2", Constants.LAMP_TRPRD_III, false);
			
			//panelLampSet(1, Constants.LAMP_TRAP_1, Constants.LAMP_TRAP_1, false);
			//panelLampSet(2, Constants.LAMP_TRAP_2, Constants.LAMP_TRAP_2, false);
			//panelLampSet(3, Constants.LAMP_TRAP_3, Constants.LAMP_TRAP_3, false);
			//panelLampSet(4, Constants.LAMP_TRAP_4, Constants.LAMP_TRAP_4, false);
			
			//var lmp:Lamp = getPanelLamp(Constants.LAMP_TRPRD);
			//lmp.setColors(Constants.COLOR_DARK_GRAY, Constants.COLOR_WHITE, Constants.COLOR_LIGHT_RED,
			//Constants.COLOR_LIGHT_GREEN, Constants.COLOR_LIGHT_YELLOW);
			
			panelLampSet(5, Constants.LAMP_WP, "WP", false);
			panelLampSet(6, Constants.LAMP_TRP_ATACK, Constants.LAMP_TRP_ATACK, false);
			panelLampSet(4, "X","", false);
			//lmp = getPanelLamp(Constants.LAMP_WP);
			//lmp.setColors(Constants.COLOR_DARK_GRAY, Constants.COLOR_WHITE, Constants.COLOR_LIGHT_RED,
			//Constants.COLOR_LIGHT_GREEN, Constants.COLOR_LIGHT_YELLOW);
			//panelLampActive(Constants.LAMP_WP);
			
			prepareGameOver();
		}
		
		public function onSlowLoop(time:int):void {
			getPanelLamp(Constants.LAMP_TRP_ATACK).blinkAlarmWarning(time);
		}
		
		public function scale():void {
			Utils.scale(command, main.scaleX);
			Utils.scale(player_name, main.scaleX);
			Utils.scale(time, main.scaleX);
			if(trace_tf != null)
				Utils.scale(trace_tf, main.scaleX);
			var j:int = 0;
			
			while (j < fields.length ) {
				Utils.scale(lbls[j], main.scaleX);
				Utils.scale(fields[j], main.scaleX);
				j++;
			}
			j = 0;
			while (j < r_fields.length ) {
				Utils.scale(r_lbls[j], main.scaleX);
				Utils.scale(r_fields[j], main.scaleX);
				j++;
			}
			j = 0;
			while (j < lamps.length ) {
				Utils.scale(lamps[j], main.scaleX);
				j++;
			}
		}
		
		public function clean():void {
			main.removeChild(player_name);
			main.removeChild(time);
			main.removeChild(command);
			if(trace_tf != null)
				main.removeChild(trace_tf);
			
			time = null;
			player_name = null; 
			command = null;
			trace_tf = null;
			
			var j:int = 0;
			while (j < fields.length) {
				main.removeChild(lbls[j]);
				main.removeChild(fields[j]);
				lbls[j] = null;
				fields[j] = null;
			}
			fields = null;
			lbls = null;
			
			j = 0;
			while (j < r_fields.length) {
				main.removeChild(r_lbls[j]);
				main.removeChild(r_fields[j]);
				r_lbls[j] = null;
				r_fields[j] = null;
			}
			r_fields = null;
			r_lbls = null;
			
			format_go_1 = null;
			infopan_h = null;
			format_go_2 = null;
			infopan_t = null;
			infopan_f = null;
		}
		
		public function setPlayerName(txt:String):void {
			player_name.text = txt;
		}
		
		public function prepareGameOver():void {
			format_go_1 = new TextFormat(); 
			format_go_1.color = 0xFF4500; 
 			format_go_1.font = "_sans"; // "Courier"; 
			format_go_1.bold = true;
			format_go_1.size = 30;
			format_go_1.align = "center";

			infopan_h = new TextField();
			infopan_h.selectable = true;
			infopan_h.text = ""; 
			infopan_h.x = 0+10;
			infopan_h.y = 0+10;  
			infopan_h.width = Main.SCREEN_WIDTH-10-10;
			infopan_h.height = 50;
			infopan_h.border = true;
			infopan_h.borderColor = 0xFFFFFF;
			infopan_h.setTextFormat(format_go_1);
			infopan_h.defaultTextFormat = format_go_1;
			infopan_h.backgroundColor = 0xFFFF00;
			infopan_h.background = true;
			infopan_h.alpha = 0.9;
			
			format_go_2 = new TextFormat(); 
			format_go_2.color = 0xFF0000; 
 			format_go_2.font = "Courier"; 
			format_go_2.bold = true;
			format_go_2.size = 20;
			format_go_2.align = "left";
			
			infopan_t = new TextField();
			infopan_t.selectable = true;
			infopan_t.text = ""; 
			infopan_t.x = 10;
			infopan_t.y = 10+50+2;  
			infopan_t.width = Main.SCREEN_WIDTH - 10-10;
			infopan_t.height = Main.SCREEN_HEIGHT - (50+2+50+10+10+2);
			infopan_t.border = true;
			infopan_t.borderColor = 0xFFFFFF;
			infopan_t.setTextFormat(format_go_2);
			infopan_t.defaultTextFormat = format_go_2;
			infopan_t.backgroundColor = 0xFFFF00;
			infopan_t.background = true;
			infopan_t.alpha = 0.9;
			infopan_t.multiline = true;
			//gameover_t.scrollV = true;

			infopan_f = new TextField();
			infopan_f.selectable = true;
			infopan_f.text = ""; 
			infopan_f.x = 10;
			infopan_f.y = infopan_t.y + infopan_t.height + 2;  
			infopan_f.width = Main.SCREEN_WIDTH - 10-10;
			infopan_f.height = 50;
			infopan_f.border = true;
			infopan_f.borderColor = 0xFFFFFF;
			infopan_f.setTextFormat(format_go_1);
			infopan_f.defaultTextFormat = format_go_1;
			infopan_f.backgroundColor = 0xFFFF00;
			infopan_f.background = true;
			infopan_f.alpha = 0.9;
		}
		
		public function showInfoPanel(header:String, txt:String, footer:String):void {
			format_go_1.color = 0xFF4500; 
			infopan_h.borderColor = 0xFFFFFF;
			infopan_h.backgroundColor = 0xFFFF00;
			format_go_2.color = 0xFF0000; 
			infopan_f.borderColor = 0xFFFFFF;
			infopan_f.backgroundColor = 0xFFFF00;
			setTextPanel(header, txt, footer);
		}
		
		public function hideInfoPanel():void {
			try {
				main.removeChild(infopan_h);
				main.removeChild(infopan_t);
				main.removeChild(infopan_f);
				main.stage.focus = main;
			} catch (err:Error) {}
		}

		public function setTime(tm:int):void {
			var t:Number = tm / 1000. 
			time.text =  t.toFixed(0) + " sec.";
		}
		
		public function setTimePause():void {
			time.backgroundColor = 0xFF0000;
		}
		
		public function setTimeGo():void {
			time.backgroundColor = FIELD_TEXT_BGCOLOR;
		}
		
		public function setSpeed(speed:Number):void {
			fields[SPD].text = speed.toFixed(0);
		}
		
		public function setRudder(p_rud:String):void {
			fields[RUD].text = p_rud;
		}
		
		/*
		 * Добавить поля слева
		 */ 
		public function writeDebugDopField(_fld_name:String, _val:String):void {
			if (!Settings.DEBUG)
				return;
			
			for (var j:int = 0; j < fields.length; j++) {
				if (lbls[j].text  == _fld_name) {  
					break;
				}
			}
			if (j == fields.length) {
				//-- добавляем новую пару
				lbls[j] = new TextField();	
				lbls[j] .selectable = false;
				lbls[j] .text = _fld_name; 
				lbls[j].x = 0;
				lbls[j].y = time.y + time.height + 5 + j*FIELD_HEIGHT;
				lbls[j].width = LBL_WIDTH;
				lbls[j] .height = FIELD_HEIGHT;
				lbls[j] .border = true;
				lbls[j] .borderColor = FIELD_TEXT_COLOR;
				lbls[j].background = true;
				lbls[j].backgroundColor = FIELD_TEXT_BGCOLOR;
				lbls[j].alpha =FIELD_ALPHA;
				lbls[j] .setTextFormat(format_dop);
				lbls[j] .defaultTextFormat = format_dop;
				main.addChild(lbls[j] );
				
				fields[j] = new TextField();
				fields[j].selectable = true;
				fields[j].text = _val; 
				fields[j].y = time.y + time.height + 5 + j*FIELD_HEIGHT;
				fields[j].x = lbls[j].x + lbls[j].width + 2;
				fields[j].width = FIELD_WIDTH;
				fields[j].height = FIELD_HEIGHT;
				fields[j].border = true;
				fields[j].borderColor = FIELD_TEXT_COLOR;
				fields[j].background = true;
				fields[j].backgroundColor = FIELD_TEXT_BGCOLOR;
				fields[j].alpha = FIELD_ALPHA;
				fields[j].setTextFormat(format_dop);
				fields[j].defaultTextFormat = format_dop;
				main.addChild(fields[j]);
			} else {
				fields[j].text = _val; 
			}
		}
		
		
		/*
		 * Добавить поле справа
		 */ 
		public function removeRightField(_fld_name:String):void {
			for (var j:int = 0; j < r_fields.length; j++) {
				if (r_lbls[j].text  == _fld_name) {  
					break;
				}
			}
			if (j < r_fields.length) {
				main.removeChild(r_lbls[j]);
				main.removeChild(r_fields[j]);
				r_lbls.splice(j, 1);
				r_fields.splice(j, 1);
			}
		}

				
		/*
		 * Добавить поле справа
		 */ 
		public function writeDebugRightField(_fld_name:String, _val:String):void {
			if (!Settings.DEBUG)
				return;
			writeRightField(_fld_name, _val);
		}
		
		/*
		 * Добавить поле справа
		 */ 
		public function writeRightField(_fld_name:String, _val:String):void {
			for (var j:int = 0; j < r_fields.length; j++) {
				if (r_lbls[j].text  == _fld_name) {  
					break;
				}
			}
			if (j == r_fields.length) {
				//-- добавляем новую пару
				r_lbls[j] = new TextField();	
				r_lbls[j] .selectable = false;
				r_lbls[j] .text = _fld_name; 
				r_lbls[j].y = 5 + j*R_FIELD_HEIGHT;
				r_lbls[j].width = R_LBL_WIDTH;
				r_lbls[j] .height = R_FIELD_HEIGHT;
				r_lbls[j] .border = true;
				r_lbls[j] .borderColor = R_FIELD_TEXT_COLOR;
				r_lbls[j].background = true;
				r_lbls[j].backgroundColor = R_FIELD_TEXT_BGCOLOR;
				r_lbls[j].alpha = R_ALPHA;
				r_lbls[j] .setTextFormat(r_format);
				r_lbls[j] .defaultTextFormat = r_format;
				main.addChild(r_lbls[j] );
				
				r_fields[j] = new TextField();
				r_fields[j].selectable = true;
				r_fields[j].text = _val; 
				r_fields[j].y = 5 + j*R_FIELD_HEIGHT;
				r_fields[j].width = R_FIELD_WIDTH;
				r_fields[j].height = R_FIELD_HEIGHT;
				r_fields[j].border = true;
				r_fields[j].borderColor = R_FIELD_TEXT_COLOR;
				r_fields[j].background = true;
				r_fields[j].backgroundColor = R_FIELD_TEXT_BGCOLOR;
				r_fields[j].alpha = R_ALPHA;
				r_fields[j].setTextFormat(r_format);
				r_fields[j].defaultTextFormat = r_format;
				main.addChild(r_fields[j]);
				
				r_fields[j].x = Main.SCREEN_WIDTH - r_fields[j].width -2;
				r_lbls[j].x = r_fields[j].x - r_lbls[j].width;
			} else {
				r_fields[j].text = _val; 
			}
		}


		public function panelLampOnOff(_lamp_name:String, _on:Boolean):void {
			for (var j:int = 0; j < lamps.length; j++) {
				if (lamps[j].name  == _lamp_name) {  
					break;
				}
			}
			if (j == lamps.length) {
				trace(" PANEL LAMP "+ _lamp_name+" NOT SET!!! ");
			}
			lamps[j].setOnOff(_on);
			
		}
		
		public function panelLampReadyNotReady(_lamp_name:String, _on:Boolean):void {
			for (var j:int = 0; j < lamps.length; j++) {
				if (lamps[j].name  == _lamp_name) {  
					break;
				}
			}
			if (j == lamps.length) {
				trace(" PANEL LAMP "+ _lamp_name+" NOT SET!!! ");
			}
			lamps[j].setReadyNotReady(_on);
		}
		
		public function panelLampSet(num:int, _lamp_name:String, _text:String, _on:Boolean):void {
			for (var j:int = 0; j < lamps.length; j++) {
				if (lamps[j].name  == _lamp_name) {  
					break;
				}
			}
			
			if (j == lamps.length) {
				//-- добавляем новую пару
				lamps[j] = new Lamp(_lamp_name, _text);	
				
				//var n:int = num % 2;
				if(num == 1) {  
					lamps[j].x = 0;
					lamps[j].y = 5 + fields[fields.length - 1].y + 1*FIELD_HEIGHT;
				}
				if(num == 2) {  
					lamps[j].x = (LBL_WIDTH + FIELD_WIDTH)/2;
					lamps[j].y = 5 + fields[fields.length - 1].y + 1*FIELD_HEIGHT;
				}
				if(num == 3) {  
					lamps[j].x = 0;
					lamps[j].y = 5 + fields[fields.length - 1].y + 2*FIELD_HEIGHT;
				}
				if(num == 4) {  
					lamps[j].x = (LBL_WIDTH + FIELD_WIDTH)/2;
					lamps[j].y = 5 + fields[fields.length - 1].y + 2*FIELD_HEIGHT;
				}
				
				if(num == 5) {  
					lamps[j].x = 0;
					lamps[j].y = 5 + fields[fields.length - 1].y + 3*FIELD_HEIGHT;
				}
				if(num == 6) {  
					lamps[j].x = (LBL_WIDTH + FIELD_WIDTH)/2;
					lamps[j].y = 5 + fields[fields.length - 1].y + 3*FIELD_HEIGHT;
				}
				
				if(num == 7) {  
					lamps[j].x = 0;
					lamps[j].y = 5 + fields[fields.length - 1].y + 4*FIELD_HEIGHT;
				}
				if(num == 8) {  
					lamps[j].x = (LBL_WIDTH + FIELD_WIDTH)/2;
					lamps[j].y = 5 + fields[fields.length - 1].y + 4*FIELD_HEIGHT;
				}
				
				lamps[j].width = (LBL_WIDTH + FIELD_WIDTH+2)/2;
				lamps[j].height = FIELD_HEIGHT;
				
				lamps[j].border = true;
				lamps[j].borderColor = FIELD_TEXT_COLOR;
				lamps[j].background = true;
				
				lamps[j].setTextFormat(lamp_format);
				lamps[j].defaultTextFormat = lamp_format;
				
				lamps[j].alpha = 1.; //this.FIELD_ALPHA;
				main.addChild(lamps[j] );
				
			} else {
				lamps[j].text = _text; 
			}
			if(_on)
				lamps[j].setOn();
			else	
				lamps[j].setOff();
		}
		
		public function getPanelLamp(_lamp_name:String):Lamp {
			for (var j:int = 0; j < lamps.length; j++) {
				if (lamps[j].name  == _lamp_name) {  
					return lamps[j];
				}
			}
			return null;
		}

		public function panelLampBlinkAlarmWarning(_lamp_name:String):void {
				var lmp:Lamp = getPanelLamp(_lamp_name);
				if (lmp == null)
					return;
				lmp.startBlinkAlarmWarning();	
		}
		
		public function panelLampActive(_lamp_name:String):void {
				var lmp:Lamp = getPanelLamp(_lamp_name);
				if (lmp == null)
					return;
				lmp.setActive();	
		}

		public function panelLampOff(_lamp_name:String):void {
				var lmp:Lamp = getPanelLamp(_lamp_name);
				if (lmp == null)
					return;
				lmp.setOff();	
		}

		protected var msg_count:int = 1;
		
		/**
		 * Добавить текст в правое поле с прокруткой
		 * 
		 * @param	_val
		 */
		public function writeText( _val:String):void {
			_val = msg_count++ + ": " +  _val;	
			if(trace_tf==null) {
				//-- добавляем новую пару
				trace_tf = new TextField();	
				trace_tf .selectable = true;
				trace_tf .text = _val; 
				trace_tf.width = TF_FIELD_WIDTH;
				trace_tf .height = TF_FIELD_HEIGHT;
				trace_tf .border = true;
				trace_tf .borderColor = TF_FIELD_TEXT_COLOR;
				trace_tf.background = true;
				trace_tf.backgroundColor = TF_FIELD_TEXT_BGCOLOR;
				trace_tf.alpha = TF_FIELD_ALPHA;
				trace_tf .setTextFormat(tf_format);
				trace_tf .defaultTextFormat = tf_format;
				//trace_tf.scrollH = 1;
				main.addChild(trace_tf );
				
				trace_tf.x = Main.SCREEN_WIDTH - trace_tf.width -2;
				trace_tf.y = Main.SCREEN_HEIGHT- trace_tf.height-2;
			} else {
				trace_tf.text = _val + "\n" + trace_tf.text; 
			}
		}
		
		/**
		 * Добавить текст в правое поле с прокруткой
		 * @param	_val
		 */		
		public function writeDebugText( _val:String):void {
			if (!Settings.DEBUG)
				return;
			else 
				writeText(_val);
		}

		
		public function setCommand(p_command:String):void {
			command.textColor = COMMAND_COLOR;
			command.text = p_command;
		}
		
		public function setCommandAlarm(p_command:String):void {
			command.textColor = 0xff0000;
			command.text = p_command;
			writeText(p_command);
		}
		
		public function setDirection(p_direction:String):void {
			fields[DIR].text = p_direction;
		}
		
		public function setPower(p_pow:String):void {
			fields[POW].text = p_pow;
		}
		
		public function setZoom(p_zoom:Number):void {
			fields[ZOM].text = p_zoom.toFixed(3);
		}

		protected function setTextPanel(header:String,txt:String,footer:String):void {
			infopan_h.text = header; 
			main.addChild(infopan_h);
			
			infopan_t.text = txt; 
			main.addChild(infopan_t);
			
			infopan_f.text = footer; 
			main.addChild(infopan_f);
		}
		
	}

	
}