package srs.scenario 
{
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.net.*;
	import flash.events.*;
	import flash.system.fscommand; 
	import flash.system.System; 
	import flash.text.TextField;
	import flash.text.TextFormat;
	//import srs.tmp.NetworkInformationExample;
	
	import mx.utils.Base64Encoder;
	import flash.utils.*;
	
	import srs.*;
	import srs.utils.*;
	//import srs.tmp.NetworkInformationExample;
	import srs.ships.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Scenario {

		protected const SHOW_UNKNOWN:int = 0;
		protected const SHOW_RESULT:int = 1;
		protected const SHOW_ENTER_NAME:int = 2;
		protected const SHOW_SCORE:int = 3;
		protected const SHOW_TOPLIST:int = 4;
		protected const SHOW_CONTINUE:int = 5;
		
		protected var main:Main;
		
		protected var obstruction:Sprite =null;
		protected var port_gate:Sprite = null;
		
		protected var coast_data:Array;
		protected var port_line_data:Array;	
	
		protected var START_X:int = 350;
		protected var START_Y:int = 350;
		protected var START_POSITION:Point;
		
		
		protected var name:String = "";
		protected var score_name:String = "";
		protected var score: int = 0;
		protected var success:String = "";
		protected var comment:String = "";
		protected var inputtext_state:int = 0;

		protected var state:int = SHOW_UNKNOWN;
		
		protected var player_name:String = "Unknown";
		
		public static const F2:int = 113;
		public static const ENTER:int = 13;
		
		public static const STATE_ENTER_PLAYER_NAME:int = 122;

		public static const GAME_CONTINUE:int = 1;
		public static const MISSION_SUCCESS:int = 2;
		public static const MISSION_FAILED:int = 3;
		
		
		protected var captureText:CaptureUserInput;
		
		protected var bonus_time_game_sec:int = 10000; //-- при успешно выполненной миссии бонус за время = max_time_game_sec / (время игры)
		protected var session_id:String = "-";
		
		public function Scenario(_main:Main,_name:String) {
			main = _main;
			name = _name;
			score_name = name;
		}
		
		public function init():void {
			main.getInformer().setPlayerName(player_name);
			writeSession();
		}
		
		/*
		 * Дочерние должны вызывать эту функцию в init()!
		 */ 
		public function init_after():void {
			START_POSITION = new Point(START_X, START_Y);
		}
		
		public function getStartPosition():Point {
			return START_POSITION;
		}
		
		public function clean():void {
			obstruction = null;
			port_gate = null;

			coast_data = null;
			port_line_data = null; 

			START_X = 350;
			START_Y = 350;

			name = "";
			score = 0;
			success = "";
			comment = "";
			inputtext_state = 0;

			state = SHOW_UNKNOWN;
		}
		
		public function setPlayerName(nm:String):void {
			player_name = nm;
			main.getInformer().setPlayerName(nm);
		}
		
		public function getPlayerName():String {
			return player_name;
		}
		
		protected function handleKeyDown(event:KeyboardEvent):void { 
			/*
			trace(event.currentTarget.name + " hears key press: " 
				+ String.fromCharCode(event.charCode) + " (key code: " 
				+ event.keyCode + " character code: " + event.charCode + ")"); 
			*/
			if (event.keyCode == 27) {  //-- //-- ESC
				trace("ESC - quit");
				fscommand("quit");
			//} else if (event.keyCode == F2) {
			//	main.newGame();
			} else if (event.keyCode == STATE_ENTER_PLAYER_NAME) {
				captureText = new CaptureUserInput(main);
				inputtext_state = STATE_ENTER_PLAYER_NAME;
				main.addChild(captureText); // , 100);
				captureText.x = Main.SCREEN_WIDTH / 2; captureText.y = Main.SCREEN_HEIGHT / 2;
				main.stage.focus = captureText;
			} else if (event.keyCode == ENTER /*&& main.stage.focus is TextField*/) {
				//trace(c.getText());
				if (inputtext_state == STATE_ENTER_PLAYER_NAME) {
					try {	
						player_name = captureText.getText();
					} catch (err:Error) {
						main.getInformer().setCommandAlarm("Wrong string!");
					}
					main.stage.focus = main;
					inputtext_state = 0;
					if(captureText != null)
						main.removeChild(captureText);
					captureText = null;
				} else {
					nextSlide();
				}
			} else {
				if (inputtext_state != STATE_ENTER_PLAYER_NAME) {
					nextSlide();
				}
			}
		} 		
	

		protected function enterPlayerName():void {
			captureText = new CaptureUserInput(main);
			inputtext_state = STATE_ENTER_PLAYER_NAME;
			main.addChild(captureText); // , 100);
			captureText.x = Main.SCREEN_WIDTH / 2; captureText.y = Main.SCREEN_HEIGHT / 2;
			captureText.setFocus();
		}
		
		protected function handleMouseDown(event:MouseEvent):void { 
			nextSlide();
		}

		protected function nextSlide():void {
			if (inputtext_state != 0) {
				main.getInformer().setCommandAlarm("Enter you name.");
				return;
			}
			if (state == SHOW_RESULT) {
				if(Settings.WEB_ENABLE) {
					if(player_name=="Unknown") 
						enterPlayerName();
				}
				state = SHOW_ENTER_NAME;
			} else if (state == SHOW_ENTER_NAME) {
				state = SHOW_SCORE;
				showScore();
			} else if (state == SHOW_SCORE) {
				state = SHOW_TOPLIST;
				showTopList();
			} else if (state == SHOW_TOPLIST) {
				state = SHOW_CONTINUE;
				showContinue();
			}
		}
		
		/*
		 * Generate coast data
		 */
		protected function genCoastData():void {}
		
		/*
		 * Generate coast profile.
		 */
		public function genObstruction():void {}
		
		public function genPortGate():void {}
		
		public function checkGameOver():int {
			if (main.getRedShips().length == 0) {
				return MISSION_SUCCESS;
			}
			if (main.getMyShip() == null) {
				return MISSION_FAILED;
			}
			return GAME_CONTINUE;
		}
		
		public function gameOver(_success:int):void {
			if(_success == MISSION_SUCCESS)
				success = "Success";
			else
				success = "Mission failed";
				
			calcScore(_success);
			state = SHOW_RESULT; 
			
			main.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			main.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		
		protected function getMinimalScore():int {
			return 0;
		}
		
		
		protected function writeSession():void {
			//var n:NetworkInformationExample = new NetworkInformationExample();
			if (Settings.WEB_ENABLE) {
				//var s :String = "\n\nSaving result..."; 
				//showGameOver("Score", s, "Press any key" );
				
				//var score_min:int = getMinimalScore();
				
				//if (score > score_min) {
					//var player_name:String = player_name; // enterPlayerName();
					try {
						//"http://srs.zz.mu/scores/db_write_score.php?time_game=0&scenario=Scenari1&player_name=test&success=sussess&comment=ddd&score=0"
						var request:URLRequest = new URLRequest("http://srs.zz.mu/score/db_insert_session.php");
						var variables:URLVariables = new URLVariables();
						variables.ip ="ip" ;
						variables.scenario = score_name;
						variables.player_name = player_name;
						variables.comment = comment;
						request.data = variables;
						//request.method = URLRequestMethod.POST;
						//trace(request);
						var loader:URLLoader = new URLLoader(); 
						loader.dataFormat = URLLoaderDataFormat.VARIABLES;
						loader.addEventListener(Event.COMPLETE, onWriteInsertSession);
						loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
						loader.load(request); 
					} catch (err:Error) {
						trace(err.message);
						main.getInformer().setCommandAlarm("Error on saving results!"); 
					}
				//}
			}
		}
		protected function onWriteInsertSession(e:Event):void {
			
			var loader:URLLoader = URLLoader(e.target);
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			//var o:Object = loader.data.gameid;
			//trace("Par: " + loader.data.par + " " + loader.data.gameid + " " + loader.data.hh);
			session_id = loader.data.hh;
			//trace ( "session_id=" + session_id +" " + parseInt(session_id) ) ;
			//if(e.target.data=="SUCCESS")
			//	showMissionGoal("Score", "\n\n Writing successful", "Press any key" );
			//else	
			//	showMissionGoal("Score", "\n\n Writing failed", "Press any key" );
		}
		private function onIOError(event:IOErrorEvent):void {
			Settings.WEB_ENABLE = false;
			trace("Error loading URL.");
		}
		
		protected function showScore():void {
			if (Settings.WEB_ENABLE) {
				var s :String = "\n\nSaving result..."; 
				showGameOver("Score", s, "Press any key" );
				
				var score_min:int = getMinimalScore();
				
				//if (score > score_min) {
					//var player_name:String = player_name; // enterPlayerName();
					try {
						//"http://srs.zz.mu/scores/db_write_score.php?time_game=0&scenario=Scenari1&player_name=test&success=sussess&comment=ddd&score=0"
						var request:URLRequest = new URLRequest("http://srs.zz.mu/score/db_write_score.php");
						var variables:URLVariables = new URLVariables();
						variables.time_game = new Date().getTime();
						variables.scenario = score_name;
						variables.player_name = player_name;
						variables.score = score;
						variables.success = success;
						variables.comment = comment;
						variables.EHC = Statistic.enemy_hit_count;
						variables.FHC = Statistic.friend_hit_count;
						variables.ED = Statistic.enemy_destroyed;
						variables.FD = Statistic.friend_destroyed;
						variables.EFC = Statistic.enemy_fire_count;
						variables.FFC = Statistic.friend_fire_count;
						variables.TLP = Statistic.time_leave_port_sec;
						variables.TG = Statistic.time_game_sec;
						variables.session_id = parseInt(session_id);
						request.data = variables;
						trace(request);
						var loader:URLLoader = new URLLoader(); 
						loader.load(request); 
						loader.addEventListener(Event.COMPLETE, onWriteDb);
						loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					} catch (err:Error) {
						trace(err.message);
						main.getInformer().setCommandAlarm("Error on saving results!"); 
					}
				//}
			}
		}
		protected function onWriteDb(e:Event):void {
			trace(" REPLAY "+e.target.data);
			//if(e.target.data=="SUCCESS")
			//	showMissionGoal("Score", "\n\n Writing successful", "Press any key" );
			//else	
			//	showMissionGoal("Score", "\n\n Writing failed", "Press any key" );
		}
		
		
		public function showTopList():void {
			//state = SHOW_TOPLIST; 
			showTopListFromFile();
		}
		
		public function showContinue():void {
			//state = SHOW_CONTINUE;
			var s:String = "\n\n\n\nESC - exit";
			showGameOver("Continue", s, "http://srs.zz.mu" );
		}
		
		public function showMissinGoal():void {}
		
		public function showMissionGoal(header:String, txt:String, footer:String):void {
			main.getInformer().showInfoPanel(header, txt, footer);
		}

		public function showGameOver(header:String, txt:String, footer:String):void {
			main.getInformer().showInfoPanel(header, txt, footer);
		}
		
		public function hideMissionGoal():void {
			main.getInformer().hideInfoPanel();
		}
		
		
		public function scale():void {
			if(obstruction!=null)
				Utils.scale(obstruction, main.scaleX);
			if(port_gate != null)	
				Utils.scale(port_gate, main.scaleX);
		}
		
		
		/*
		 * Пересчитывает и возвращает счет
		 */ 
		public function calcScore(_success:int):int {
			score = 0;
			score += Statistic.enemy_destroyed * 100;
			score += Statistic.enemy_hit_count * 10;
			score += Statistic.enemy_fire_count * 1;
			
			score -= Statistic.friend_destroyed * 100;
			score -= Statistic.friend_hit_count * 10;
			score -= Statistic.friend_fire_count * 1;
			
			if (_success == MISSION_SUCCESS) {
				score += bonus_time_game_sec / Statistic.time_game_sec ;
			}
			//trace( "score is" + score);  
			return score;
		}

		/*
		 * Показать результаты из файла
		 */ 
		protected function showTopListFromFile():void {
			try {
				if(Settings.WEB_ENABLE) {
					var myTextLoader:URLLoader = new URLLoader();
		 
					myTextLoader.addEventListener(Event.COMPLETE, onLoaded);
					myTextLoader.load(new URLRequest("http://srs.zz.mu/score/"+name+"_toplist.txt"));
					//myTextLoader.load(new URLRequest("file:///c:/tmp/test.txt"));
				}
			} catch (err:Error) {
				main.getInformer().setCommandAlarm(err.message);
				trace(err);
			}
		}
		protected function onLoaded(e:Event):void {
			trace(e.target.data);
			var h:String = "Your score:" + score; 
			showMissionGoal(h, e.target.data, "Press any key" );
		}
		
		public function getObstruction():Sprite {
			return obstruction;
		}
		
		public function getPortLine():Sprite {
			return port_gate;
		}
		
		protected function makeResume():String {
			var ss:String = "";
			for each(var sh:Ship in main.getRedShips()) {
				ss += "\n" + sh.getName() + " speed:" + sh.getMaxVelocityHum() 
			+   " manevr:" + sh.getManevr() + "% " 
			+   " time reload:" + sh.getTimeReloadTorpSec().toFixed(0) + "sec"
			}
			
			var s:String = "";
			s += "\n\nMy  speed:" + main.getMyShip().getMaxVelocityHum() 
			+ " manevr:" + main.getMyShip().getManevr() + "% " 
			+ " time reload depends from weapon type"
			+ "\n" + ss
			+ "\n\nWeapon White\n"
			+ "Torp I  " + Main.getWhiteStore().getParams_I().trp_name 
			+ "  vel:" + Main.getWhiteStore().getParams_I().max_velocity_hum + " "
			+ "  time life:" + Main.getWhiteStore().getParams_I().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getWhiteStore().getParams_I().manevr_prc+ "% "
			+ "  damages:" + Main.getWhiteStore().getParams_I().damage+ ""
			+ "  dist_execution:" + Main.getWhiteStore().getParams_I().dist_execution+ ""
			+ "\nTorp II  " + Main.getWhiteStore().getParams_II().trp_name 
			+ "  vel:" + Main.getWhiteStore().getParams_II().max_velocity_hum + " "
			+ "  time life:" + Main.getWhiteStore().getParams_II().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getWhiteStore().getParams_II().manevr_prc+ "% "
			+ "  damages:" + Main.getWhiteStore().getParams_II().damage+ ""
			+ "  dist_execution:" + Main.getWhiteStore().getParams_II().dist_execution+ ""
			+ "\nTorp III  " + Main.getWhiteStore().getParams_III().trp_name 
			+ "  vel:" + Main.getWhiteStore().getParams_III().max_velocity_hum + " "
			+ "  time life:" + Main.getWhiteStore().getParams_III().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getWhiteStore().getParams_III().manevr_prc+ "% "
			+ "  damages:" + Main.getWhiteStore().getParams_III().damage+ ""
			+ "  dist_execution:" + Main.getWhiteStore().getParams_III().dist_execution+ ""
			+ "\n\nWeapon Red\n"
			+ "Torp I  "+ Main.getRedStore().getParams_I().trp_name +"  vel:" + Main.getRedStore().getParams_II().max_velocity_hum + " "
			+ "  time life:" + Main.getRedStore().getParams_I().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getRedStore().getParams_I().manevr_prc+ "% "
			+ "  damages:" + Main.getRedStore().getParams_I().damage+ ""
			+ "  dist_execution:" + Main.getRedStore().getParams_I().dist_execution+ ""
			+ "\nTorp II  "+ Main.getRedStore().getParams_II().trp_name +"  vel:" + Main.getRedStore().getParams_II().max_velocity_hum + " "
			+ "  time life:" + Main.getRedStore().getParams_II().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getRedStore().getParams_II().manevr_prc+ "% "
			+ "  damages:" + Main.getRedStore().getParams_II().damage+ ""
			+ "  dist_execution:" + Main.getRedStore().getParams_II().dist_execution+ ""
			+ "\nTorp III  "+ Main.getRedStore().getParams_III().trp_name +"vel:" + Main.getRedStore().getParams_III().max_velocity_hum + " "
			+ "  time life:" + Main.getRedStore().getParams_III().max_time_life_sec+ "sec "
			+ "  manevr:" + Main.getRedStore().getParams_III().manevr_prc+ "% "
			+ "  damages:" + Main.getRedStore().getParams_III().damage+ ""
			+ "  dist_execution:" + Main.getRedStore().getParams_III().dist_execution+ ""
			;
			return s;
		}
		
	}

}