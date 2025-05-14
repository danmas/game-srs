package srs
{
	/**
	 * Programming ActionScript 3.0 for Flash
	 * http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b8cbfe-7ff7.html
	 * 
	 * http://srs.zz.mu/ - сайт игры
	 * 
	 * http://www.weblabla.ru/html/colorvalues.html - color table
	 * http://soundjax.com/crash-4.html - sound collection
	 * http://translate.google.ru/#en/ru/SILEN - google translator
	 * http://help.adobe.com/ru_RU/as3/dev/as3_devguide.pdf - Руководство разработчика
	 *  //-- загрузка внешних данных
	 * http://help.adobe.com/ru_RU/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b90204-7cfd.html#WS5b3ccc516d4fbf351e63e3d118666ade46-7cb2
	 * //-- how to support HTTP Authentication URLRequest?
	 * http://stackoverflow.com/questions/509219/flex-3-how-to-support-http-authentication-urlrequest
	 */
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.display.StageDisplayState;

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import flash.media.SoundChannel;
	
	import srs.scenario.*;
	import srs.ships.*;
	import srs.sounds.*;
	import srs.utils.*;
	
	[ SWF( backgroundColor = '#2c2cFF', width = '1000', height = '700' ) ]
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Main extends Sprite {

	public static const SCREEN_WIDTH:int = 1000; // 800;	
	public static const SCREEN_HEIGHT:int = 700; // 500;	
	
	public static const STOPED:int = 0;
	public static const STARTED:int = 1;

	public static const ST_UNKNOWN:int = 0;
	public static const ST_SELECT_TORP_WAY_POINT:int = 1;
	public static const ST_SELECT_SHIP_WAY_POINT:int = 2;
		
	public static const INPUT_NAME:int = 122;
	public static const ENTER:int = 13;

	private var my_ship:Ship;
	private var redTorpedos:Array;
	private var whiteTorpedos:Array;
	private var redShips:Array;
	private var whiteShips:Array;
	
	protected var weapon_select:int = Constants.WEAPON_SELECT_UNKNOWN;
	
	public var state:int = STOPED;
	private var zoom:Number = 1.;
	public var delta_x:Number = 0.;
	public var delta_y:Number = 0.;
	protected var offsetX:Number = 0;
	protected var offsetY:Number = 0;
	protected var mouse_delta_x:int=0;
	protected var mouse_delta_y:int = 0;
	protected var time_life:uint = 0;
	protected var time_last_move:uint = 0;
	protected var inputtext_state:int = ST_UNKNOWN;
	
	private var info:Informer;
	protected var captureText:CaptureUserInput;
	protected var scenario:Scenario;
	
	protected var current_cursor:Sprite;
	
	public static var main:Main;
	
	protected static var store_red:Store = new StoreRed();
	protected static var store_white:Store = new StoreWhite();
	
	
	public function Main():void {
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
		main = this;
	}
	
	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		//trace('Hello! stage.frameRate' + stage.frameRate);

		stage.fullScreenSourceRect = new Rectangle(0,0, SCREEN_WIDTH, SCREEN_HEIGHT); 
		//stage.displayState = StageDisplayState.FULL_SCREEN; 
        super.stage.doubleClickEnabled = true;

		info = new Informer(this);

		if(Settings.CURRENT_SCENARIO == "Scenario1")
			scenario = new Scenario1(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario2")
			scenario = new Scenario2(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario3")
			scenario = new Scenario3(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario4")
			scenario = new Scenario4(this);
		else if (Settings.CURRENT_SCENARIO == "ScenarioTest")
			scenario = new ScenarioTest(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario3AI")
			scenario = new Scenario3AI(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario4MULT")
			scenario = new Scenario4MULT(this);
		else if (Settings.CURRENT_SCENARIO == "Scenario1x1")
			scenario = new Scenario1x1(this);
		else {
			trace("ADD SCENARIO IN Main.as  init()!");
		}
		
		//-- полноэкранное масштабирование использует аппаратное ускорение 
		//stage.fullScreenSourceRect = new Rectangle(0,0,320,240); 
		//stage.displayState = StageDisplayState.FULL_SCREEN; 
		
		//stage.frameRate = 31;
		
		//my_ship = new MyShip(this);
		
		redTorpedos = new Array();
		redShips = new Array();
		whiteTorpedos = new Array();
		whiteShips = new Array();
		
		scenario.init();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); 
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		
		//stage.addEventListener(MouseEvent.CLICK, reportClick); 

		scenario.showMissinGoal();
	}
	/*
	public function reportClick(event:MouseEvent):void { 
		trace(event.currentTarget.toString() + " dispatches MouseEvent. Local coords [" + 
		event.localX + "," + event.localY + "] Stage coords [" + event.stageX + "," + event.stageY + "]"); 
	}*/
	
	
	public function getTimeLife():uint {
		return time_life;
	}
	
	public function removeAllHandle():void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown); 
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
	}

	/*
	sprite.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
	function mouseWheel(event:MouseEvent):void {
		trace(event.delta)
		event.target.scaleX = event.target.scaleY += event.delta * 0.01;
	}*/
	
	protected var cur_torp_app:TorpedApp;
	
	protected function mouseDown(event:MouseEvent):void { 
		offsetX = event.stageX - mouse_delta_x; 
		offsetY = event.stageY - mouse_delta_y; 

		if (inputtext_state == ST_SELECT_TORP_WAY_POINT 
		  || inputtext_state == ST_SELECT_SHIP_WAY_POINT) {
			var fp:Point = new Point(toPhisFromDisplayX(current_cursor.x), toPhisFromDisplayY(current_cursor.y));
			//getInformer().writeDebugRightField("WPx", fp.x.toFixed(0));
			//getInformer().writeDebugRightField("WPy", fp.y.toFixed(0));
			
			if (inputtext_state == ST_SELECT_TORP_WAY_POINT)  {
				var torp:Torped = getMyShip().fireAtPosition(weapon_select, fp);
				cur_torp_app.onFire();
				if(torp!=null)
					registerTorped(torp,getMyShip().getForces());
				weapon_select = Constants.WEAPON_SELECT_UNKNOWN;
			} else if (inputtext_state == ST_SELECT_SHIP_WAY_POINT) {
				getMyShip().addWayPoint(fp.x, fp.y,Constants.WP_SHIP);
				getInformer().panelLampReadyNotReady(Constants.LAMP_WP,true);
				getMyShip().startMoveOnWayPoint(/*Constants.WP_SHIP*/);
			}
			this.removeChild(current_cursor);
			current_cursor = null;
			inputtext_state = ST_UNKNOWN;
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag); 
		} else {
			// tell Flash Player to start listening for the mouseMove event 
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drag); 
		}
		
	}
	
	protected function mouseUp(event:MouseEvent):void 	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag); 
	} 

	
	protected function drag(event:MouseEvent):void { 
		if (inputtext_state == ST_SELECT_TORP_WAY_POINT 
		  || inputtext_state == ST_SELECT_SHIP_WAY_POINT) {
			current_cursor.x = event.stageX; // - offsetX;
			current_cursor.y = event.stageY; //- offsetY;
			//current_cursor.x = main.toDisplayX(event.stageX);
			//current_cursor.y = main.toDisplayY(event.stageY);

			//Utils.scale(current_cursor, main.scaleX);
			//trace( "current_cursor.x=" + current_cursor.x);
		} else {
			mouse_delta_x = event.stageX - offsetX; 
			mouse_delta_y = event.stageY - offsetY; 
			//trace(" dxy " + mouse_delta_x + "," + mouse_delta_y);
			// Instruct Flash Player to refresh the screen after this event. 
			zoomAll();
		}
		event.updateAfterEvent(); 
	}	

	protected var snd_tatc_channel:SoundChannel;

	public function startTatcAlarm():void {
		//-- включаем лампочку TATC
		getInformer().panelLampBlinkAlarmWarning(Constants.LAMP_TRP_ATACK);
		//-- включаем звук TATC
		if(snd_tatc_channel == null) {
			var snd:SoundTATC = new SoundTATC();
			snd_tatc_channel = snd. play(0.2, 1000);
		}
	}
	
	public function stopTatcAlarm():void {
		//-- выключаем лампочку TATC
		getInformer().panelLampOff(Constants.LAMP_TRP_ATACK);
		//-- выключаем звук TATC
		if (snd_tatc_channel != null) {
			snd_tatc_channel.stop();
			snd_tatc_channel = null;
		}
	}

	
	protected function handleKeyDown(event:KeyboardEvent):void { 
		/**/
		trace(event.currentTarget.name + " hears key press: " 
			+ String.fromCharCode(event.charCode) + " (key code: " 
			+ event.keyCode + " character code: " + event.charCode + ")"); 
		/**/
			if (getMyShip() != null) {
				if (event.keyCode == 40 || event.keyCode == 189 || event.keyCode == 109) {  //-- - or arrow down
					if(getMyShip() != null) {
						getMyShip().power_change( -1);  //-- power minus 
						getMyShip().drawShip();
					}
				} else if ( event.keyCode == 38 || event.keyCode == 187 || event.keyCode == 107) { //-- + or arrow up
					if(getMyShip() != null) {
						getMyShip().power_change(1);  //-- power plus
						getMyShip().drawShip();
					}
				}	else if ( event.keyCode == 37 ) { //-- arrow right
					if(getMyShip() != null) {
						getMyShip().rudder_change(1);
						getMyShip().stopMoveOnWayPoint();
					}
				} else if ( event.keyCode == 39 ) {  //-- arrow left
						if(getMyShip() != null) {
							getMyShip().rudder_change(-1);
							getMyShip().stopMoveOnWayPoint();
						}
				} else if ( event.keyCode == 84 ) {  //-- 'T'  select target
						if(getMyShip() != null) {
							getMyShip().showTarget();
						}
				} else if ( event.keyCode == 49 && inputtext_state != INPUT_NAME) { //-- '1'
					if (inputtext_state != ST_SELECT_TORP_WAY_POINT
						&& inputtext_state != ST_SELECT_SHIP_WAY_POINT) {
						cur_torp_app = getMyShip().isWeaponReady(Constants.WEAPON_SELECT_TORP_I);		
						if(cur_torp_app != null) {
							fire(Constants.WEAPON_SELECT_TORP_I);
							cur_torp_app.onFire();
						} else {
							getInformer().setCommandAlarm("Weapon not ready, Sir!");
						}
					}
				} else if ( event.keyCode == 50 && inputtext_state != INPUT_NAME) {     // '2'  -- установить точку для торпеды II
					cur_torp_app = getMyShip().isWeaponReady(Constants.WEAPON_SELECT_TORP_II);		
					if(cur_torp_app != null) {
						//if (getMyship().isWeaponReady(Constants.WEAPON_SELECT_TORP_II)) {
						weapon_select = Constants.WEAPON_SELECT_TORP_II;
						begin_set_way_point(weapon_select);
					} else {
						getInformer().setCommandAlarm("Weapon not ready, Sir!");
					}
				} else if ( event.keyCode == 51 && inputtext_state != INPUT_NAME) {     // '3' TORP_III
					if (inputtext_state != ST_SELECT_TORP_WAY_POINT
						&& inputtext_state != ST_SELECT_SHIP_WAY_POINT) {
						cur_torp_app = getMyShip().isWeaponReady(Constants.WEAPON_SELECT_TORP_III);		
						if(cur_torp_app != null) {
							fire(Constants.WEAPON_SELECT_TORP_III);
							cur_torp_app.onFire();
						} else {
							getInformer().setCommandAlarm("Weapon not ready, Sir!");
						}
					}
				} else if ( event.keyCode == 87 ) {     // 'W' - set way point fo ship
					if (inputtext_state != ST_SELECT_TORP_WAY_POINT
						&& inputtext_state != ST_SELECT_SHIP_WAY_POINT) {
						inputtext_state = ST_SELECT_SHIP_WAY_POINT;
						getInformer().panelLampActive(Constants.LAMP_WP);
						//weapon_select = WEAPON_SELECT_TORP_II;
						current_cursor = new CursorTorpFire();
						current_cursor.x = toDisplayX(getMyShip().getPosition().x); 
						current_cursor.y = toDisplayY(getMyShip().getPosition().y); 
						this.addChild(current_cursor);
						offsetX = current_cursor.x;  
						offsetY = current_cursor.y; 
						stage.addEventListener(MouseEvent.MOUSE_MOVE, drag); 
					}
				}/* else if (event.keyCode == SELECT_TA_WEAPON) {
					inputtext_state = SELECT_TA_WEAPON;
					captureText = new CaptureUserInput(this);
					this.addChild(captureText); // , 100);
					captureText.x = SCREEN_WIDTH / 2; captureText.y = SCREEN_HEIGHT / 2;
				}*/
			}
			if (event.keyCode == INPUT_NAME) {     //'F11'
				inputtext_state = INPUT_NAME;
				captureText = new CaptureUserInput(this);
				this.addChild(captureText); // , 100);
				captureText.x = SCREEN_WIDTH / 2; captureText.y = SCREEN_HEIGHT / 2;
			} else if ( event.keyCode == 83 && inputtext_state != INPUT_NAME) {  //-- S
				scenario.hideMissionGoal();
				startStopHandler();
			} else if ( event.keyCode == 90 && inputtext_state != INPUT_NAME) {  //-- Z
				var cur_center:Point = new Point(toPhisFromDisplayX(Main.SCREEN_WIDTH / 2.)
					,toPhisFromDisplayY(Main.SCREEN_HEIGHT / 2.));
				zoom *= 0.5;
				//trace(zoom);
				if (zoom < 0.25) {
					getInformer().setCommand("Max zoom!");
					zoom = 0.25;
				}
				on_centerPhPoint(cur_center);
			} else if ( event.keyCode == 88 && inputtext_state != INPUT_NAME) { //-- X
				cur_center = new Point(toPhisFromDisplayX(Main.SCREEN_WIDTH / 2.)
					,toPhisFromDisplayY(Main.SCREEN_HEIGHT / 2.));
				zoom /= 0.5;
				if (zoom > 4) {
					getInformer().setCommand("Min zoom!");
					zoom = 8;
				}
				on_centerPhPoint(cur_center);
			} else if ( event.keyCode == 67 && inputtext_state != INPUT_NAME) {  //-- C
				//on_center();
				if (my_ship != null) {
					on_centerPhPoint(my_ship.getPosition());
				}
			} else if (event.keyCode == ENTER && stage.focus is TextField) { //-- ENTER
				//trace(c.getText());
				if (inputtext_state == INPUT_NAME) {
					try {	
						var nm:String = captureText.getText();
						scenario.setPlayerName(nm);
						getInformer().setPlayerName(nm);
						//this.removeChild(captureText);
						
						/*
						var dir:Number = Number(captureText.getText());
						if(!isNaN(dir)) {
							if(my_ship != null) {
								my_ship.setDirection(dir);
							}
						} else {
							info.setCommandAlarm("Wrong direction!");
						}*/
					} catch (err:Error) {
						info.setCommandAlarm("Wrong direction!");
					}
				}
				stage.focus = this;
				inputtext_state = 0;
				if(captureText != null)
					this.removeChild(captureText);
				captureText = null;
			} else if (event.keyCode == 27) { //-- ESC
				mainGameOver(Scenario.MISSION_FAILED); 
			} else if (event.keyCode == 123) { //-- F12
				
				//var t:Number = time_life / 1000;
				//getInformer().setField("TML",  t.toFixed(0));
				var t1:int = this.getScenario().calcScore(Scenario.MISSION_SUCCESS);
				getInformer().writeDebugText(t1.toFixed(0));
				getInformer().writeDebugRightField("CSC",  t1.toFixed(0));
				
				if(!(scenario is Scenario1)) {
					if (this.scaleX == Settings.SCALE_MAIN) {
						this.scaleX = 1.; this.scaleY = 1.; 
					} else {
						this.scaleX = Settings.SCALE_MAIN; this.scaleY = Settings.SCALE_MAIN; 
					}
					getInformer().scale();
					scenario.scale();
					on_center();
				}/**/
				
				//trace("stage.width=" + stage.width + " stage.stageWidth=" + stage.stageWidth + " stage.scaleX=" + stage.scaleX);
				//trace("main.width=" + this.width + " main.scaleX=" + this.scaleX);
				//trace("SCORE: " +this.getScenario().calcScore(Scenario.MISSION_SUCCESS));
				//getEnemyShips()[0].AI_torped_fire();
			}
	}

	private  function begin_set_way_point(_weapon_select:int): void {
				if (inputtext_state != ST_SELECT_TORP_WAY_POINT
					&& inputtext_state != ST_SELECT_SHIP_WAY_POINT) {
					getInformer().panelLampActive(Constants.LAMP_TRPRD_II);
					inputtext_state = ST_SELECT_TORP_WAY_POINT;
					current_cursor = new CursorTorpFire();
					current_cursor.x = toDisplayX(getMyShip().getPosition().x); 
					current_cursor.y = toDisplayY(getMyShip().getPosition().y); 
					this.addChild(current_cursor);
					offsetX = current_cursor.x;  
					offsetY = current_cursor.y; 
					stage.addEventListener(MouseEvent.MOUSE_MOVE, drag); 
				}
	}
	
	/*
	 * Смещает дисплей так, чтобы корабль был по центру
	 */ 
	private function on_center():void {
		if(my_ship != null) {
			delta_x = (Main.SCREEN_WIDTH/2.) / this.scaleX - my_ship.getPosition().x * zoom;
			delta_y = (Main.SCREEN_HEIGHT/2.) /this.scaleY - my_ship.getPosition().y * zoom;
			
			mouse_delta_x = 0;
			mouse_delta_y = 0;
			
			getInformer().setZoom(zoom);
			zoomAll();
		}
	}

	/*
	 * Смещает дисплей так, чтобы физ точка была по центру
	 */ 
	private function on_centerPhPoint(point:Point):void {
			delta_x = (Main.SCREEN_WIDTH/2.) / this.scaleX - point.x * zoom;
			delta_y = (Main.SCREEN_HEIGHT/2.) /this.scaleY - point.y * zoom;
			
			mouse_delta_x = 0;
			mouse_delta_y = 0;
			
			getInformer().setZoom(zoom);
			zoomAll();
	}
	
	
	public function mainGameOver(_success:int):void {
			stop();
			removeAllHandle();
			//-- здесь должен быть вызов наследников!
			/*
			main.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			main.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			*/
			scenario.gameOver(_success);
	}
	
	protected var time_last_slow_loop:int = 0;
	
	//protected var st_weapon_ready:Boolean = false;
	
	protected function handleEnterFrame(e:Event):void {
		dt = this.time_last_move
		//-- провека конца игры
		var ret:int = scenario.checkGameOver();
		if (ret == Scenario.MISSION_SUCCESS	|| ret == Scenario.MISSION_FAILED) {
			mainGameOver(ret); 
			return;
		}

		if (isStarted()) {
			var cur_time:int = getTimer();
			
			var dt:int = cur_time - time_last_move;
			time_life += dt;
			Statistic.time_game_sec = time_life / 1000.;
			
			//-- SLOW LOOP
			if( cur_time - time_last_slow_loop > Settings.SLOW_LOOP_INTERVAL_MS) {
				getInformer().onSlowLoop(cur_time);
				 
				//var r:Boolean = my_ship.isWeaponReady(Constants.WEAPON_SELECT_UNKNOWN);

				if(getMyShip() != null) {
					getInformer().setSpeed(my_ship.getPhisVelocity());
					getInformer().setDirection(my_ship.getDirection().toFixed(0));
					getInformer().setTime(my_ship.getTimeLiveMs());
					
					if(inputtext_state != ST_SELECT_TORP_WAY_POINT) {
						getInformer().panelLampReadyNotReady(Constants.LAMP_TRPRD_I
							, null != my_ship.isWeaponReady(Constants.WEAPON_SELECT_TORP_I));
						getInformer().panelLampReadyNotReady(Constants.LAMP_TRPRD_II
							, null != my_ship.isWeaponReady(Constants.WEAPON_SELECT_TORP_II));
						getInformer().panelLampReadyNotReady(Constants.LAMP_TRPRD_III
							, null != my_ship.isWeaponReady(Constants.WEAPON_SELECT_TORP_III));
						//showWeaponReady(my_ship.isWeaponReady(Constants.WEAPON_SELECT_UNKNOWN));	
					}
					//getMyShip().onSlowLoop(cur_time);
				}
				//????????????????????????????????????
				//if (getMyShip() != null) {
				//	getMyShip() .AI_step_I();
				//	getMyShip() .AI_step_II();
				//	getMyShip() .infoText();
				//} //???????????????????????????????????
				//-- move all
				for each(var t:Torped in redTorpedos) {
					t.AI_step_I();
					t.AI_step_II();
					t.infoText();
				}
				for each(var t1:Torped in whiteTorpedos) {
					t1.AI_step_I();
					t1.AI_step_II();
					t1.infoText();
				}
				for each(var s:Ship in redShips) {
					//if(!s.getUnderControl()) {
						s.AI_step_I();
						s.AI_step_II();
						s.infoText();
						s.onSlowLoop(cur_time);
					//}
				}
				for each(var s:Ship in whiteShips) {
					//if(!s.getUnderControl()) {
						s.AI_step_I();
						s.AI_step_II();
						s.infoText();
						s.onSlowLoop(cur_time);
					//}
				}
				
				time_last_slow_loop = cur_time;
			}
			
			//-- FAST LOOP
			if (cur_time - time_last_move > Settings.MOVE_INTERVAL_MS) {
				//-- move Me
				if(my_ship != null) {
					my_ship.move();
					//-- crash test me
					if(scenario.getObstruction() != null) {
						if (my_ship.testCrash(scenario.getObstruction())) {
							my_ship.crash();
						}
					}
					//-- запоминаем время выхода из порта
					if(my_ship!=null) {
						if (my_ship.testCrash(scenario.getPortLine())) {
							Statistic.time_leave_port_sec = my_ship.getTimeLiveMs() / 1000.;
							//getInformer().setCommand("Leave port in "+Statistic.port_leave_time);
						}
					}
				}
				//-- move all
				for each(var t:Torped in redTorpedos) {
					t.move();
					if (t.testCrash(scenario.getObstruction())) {
						t.crash();
					}
				}
				for each(var t1:Torped in whiteTorpedos) {
					t1.move();
					if (t1.testCrash(scenario.getObstruction())) {
						t1.crash();
					}
				}
				for each(var s:Ship in redShips) {
					if(!s.getUnderControl()) {
						s.move();
						if (s.testCrash(scenario.getObstruction())) {
							s.crash();
						}
					}
				}
				for each(var s:Ship in whiteShips) {
					if(!s.getUnderControl()) {
						s.move();
						if (s.testCrash(scenario.getObstruction())) {
							s.crash();
						}
					}
				}
				if(!Settings.DRAW_REAL_WORLD) {
					drawEnemyShipsAsTarget();
				}
				time_last_move = cur_time;
			}
			
		}
		
	}

	public function zoomAll():void {
		scenario.genObstruction();
		scenario.genPortGate();
		
		//?????????
		//if(getMyShip() != null) {
		//	getMyShip().new_disp_pos();
		//	getMyShip().drawShip();
		//}

		for each(var trp_e:Torped in redTorpedos) {
			trp_e.new_disp_pos();
		}
		for each(var trp_f:Torped in whiteTorpedos) {
			trp_f.new_disp_pos();
		}
		for each(var s_e:Ship in redShips) {
			//if(!s_e.getUnderControl()) {
				s_e.new_disp_pos();
				s_e.drawShip();
			//}
		}
		for each(var s_e:Ship in whiteShips) {
			//if(!s_e.getUnderControl()) {
				s_e.new_disp_pos();
				s_e.drawShip();
			//}
		}
		
		if(!Settings.DRAW_REAL_WORLD) {
			drawEnemyShipsAsTarget();
		}
	}

	protected function drawEnemyShipsAsTarget():void {
		if (getMyShip() != null) {
			if(getMyShip().getForces() == Constants.FORCES_RED) {
				//-- убираем с дисплея все суда белых
				for each(var s_e:Ship in whiteShips) {
					//if(!s_e.getUnderControl()) {
						s_e.setVisible(false);
					//}
				}
			} else {
				//-- убираем с дисплея все суда красных
				for each(var s_e:Ship in redShips) {
					//if(!s_e.getUnderControl()) {
						s_e.setVisible(false);
					//}
				}
			}
			getMyShip().drawTargets();
		}
	}
	
	/**
	 * Calculate from phisical coordinates to display
	 * 
	 * @param	_x - phisical x
	 * @return display position x 
	 */
	public function toDisplayX(_x:Number) : Number {
		return zoom * _x + delta_x + mouse_delta_x;;
	}
	
	/**
	 * Calculate from display coordinates to phisical 
	 * 
	 * @param	_x - display position x
	 * @return  phisical - x 
	 */
	public function toPhisFromDisplayX(_x:Number) : Number {
		return (_x - delta_x - mouse_delta_x) / zoom;;
	}
	
	/**
	 * Calculate from phisical coordinates to display
	 * 
	 * @param	_y - phisical y
	 * @return display position y 
	 */
	public function toDisplayY(_y:Number) : Number {
		return zoom * _y + delta_y + mouse_delta_y;;
	}

	
	/**
	 * Calculate from display coordinates to phisical 
	 * 
	 * @param	_y - display position y
	 * @return  phisical - y 
	 */
	public function toPhisFromDisplayY(_y:Number) : Number {
		return (_y - delta_y - mouse_delta_y) / zoom;
	}
	
	
	public function getRedShips():Array {//:Vector.<Ship> {
		return redShips;
	}

	public function getWhiteShips():Array {//:Vector.<Ship> {
		return whiteShips;
	}
	
	public function getRedTorpeds():Array {//:Vector.<Ship> {
		return redTorpedos;
	}
	
	public function getWhiteTorpeds():Array {//:Vector.<Ship> {
		return whiteTorpedos;
	}
	
	public function getMyShip():srs.ships.Ship {
		return my_ship;
	}
	
	public function setMyShip(ship:Ship):void {
			my_ship = ship;
	}
	
	/**
	 * Launch torpedo
	 */
	public function fire(weapon_select:int):void {
		if (getMyShip() == null) 
			return;
		var torp:Torped = getMyShip().fire(weapon_select);
		if (torp == null)
			return;
		registerTorped(torp,getMyShip().getForces());
		//torp.setRudder(Vehicle.RUDER_LEFT_15);
		torp.id = "debug";
	}
	
	/**
	 * ИСПОЛЬЗУЕТСЯ В Ship.AI_torped_fire !!!
	 * 
	 * @param	s
	 * @param	dir
	 * @param	weapon_select
	 */
	public function fire_in_direction(s:Ship,dir:Number,weapon_select:int):void {
		var torp:Torped = s.fire_in_direction(weapon_select,dir);
		if(torp!=null) {
			registerTorped(torp, s.getForces() );
		}
	}
	
	
	//public function registerMyTorped(torp:Torped) {
	//}
	
	/**
	 * Регистрация торпеды в игре
	 * @param	torp
	 * @param	force
	 */
	public function registerTorped(torp:Torped, force:int):void {
		if(force == Constants.FORCES_RED)
			redTorpedos.push(torp);
		else	
			whiteTorpedos.push(torp);
	}
		
	/**
	 * TODO: ПЕРЕПИСАТЬ АЛГОРИТМ!
	 * 
	 * @param	veh
	 */
	public function destroy_vehicle(veh:Vehicle):void {
		if (veh == null) {
			trace("WRONG ALGORITHM!  destroy_vehicle() veh == null");
			return;
		}
		try {
			this.removeChild(veh);
		} catch (err:Error) {
			trace ("WRONG ALGORITHM destroy_vehicle this.removeChild(veh);");
		}
		//-- убираем veh из массивов
		var i:int = 0;
		if(veh.getForces() == Constants.FORCES_RED) {
			for each (var t:Torped in redTorpedos) {
				if (t == veh) {
					redTorpedos.splice(i, 1);
					veh = null;
					return;
				}
				i++;
			}
		}
		i = 0;
		if(veh.getForces() == Constants.FORCES_WHITE) {
			for each (var t1:Torped in whiteTorpedos) {
				if (t1 == veh) {
					whiteTorpedos.splice(i, 1);
					veh = null;
					return;
				}
				i++;
			}
		}
		i = 0;
		if(veh.getForces() == Constants.FORCES_RED) {
			for each (var s:Ship in redShips) {
				if (s == veh) {
					redShips.splice(i, 1);
					veh = null;
					return;
				}
				i++;
			}
		}
		i = 0;
		if(veh.getForces() == Constants.FORCES_WHITE) {
			for each (var s:Ship in whiteShips) {
				if (s == veh) {
					whiteShips.splice(i, 1);
					veh = null;
					return;
				}
				i++;
			}
		}
		veh = null;
	}
	
	//public function getDisplay():Sprite {
	//	return display;
	//}
	
	public function getInformer():Informer {
		return info;
	}
	
	//private function start_btClickHandler(event:MouseEvent):void {
	//	startStopHandler();
	//}
	
	protected function startStopHandler():void {
		if(state==STOPED) {  
			//trace("Start!");
			addEventListener("enterFrame", handleEnterFrame);
			//start_bt.setButtonColor(0xFF0000);
			state = STARTED;
			getInformer().setTimeGo();
			//start_bt.setText("STOP");
			startMoveAll();
			if (snd_tatc_channel != null) {
				snd_tatc_channel = null;
				startTatcAlarm();
			}
			//
		} else {
			stop();
			if (snd_tatc_channel != null) {
				snd_tatc_channel.stop();
				snd_tatc_channel = null;
			}
		}
	}

	public function stop():void {
		trace("Stop");
		removeEventListener("enterFrame", handleEnterFrame);
		//start_bt.setButtonColor(0xFFCC00);
		//start_bt.setText("START");
		state = STOPED;
		getInformer().setTimePause();
	}
		
	protected function startMoveAll():void {
		time_last_move = getTimer();

		//if(my_ship != null) 
		//	my_ship.start_move();
		for each(var t:Torped in redTorpedos) {
			t.start_move();
		}
		for each(var t1:Torped in whiteTorpedos) {
			t1.start_move();
		}
		for each(var s:Ship in redShips) {
			s.start_move();
		}
		for each(var s:Ship in whiteShips) {
			s.start_move();
		}
	}
	
	public function isStarted():Boolean {
		return state == STARTED;
	}

	public function moveToBack(shape:DisplayObject):void { 
		var index:int = this.getChildIndex(shape); 
		if (index > 0) { 
			this.setChildIndex(shape, 0); 
		} 
	}

	/*
	public function moveOnTop(shape:DisplayObject):void { 
		var index:int = this.getChildIndex(shape); 
		var rect:Rectangle = this.getBounds();
		this.
		if (index > 0) { 
			get
			this.setChildIndex(shape, 0); 
		} 
	}*/
		
	public function getZoom():Number {
		return zoom;
	}
	
	public function getScenario():Scenario 	{
		return scenario;
	}
	
	public static function getTime():int {
		return getTimer();
	}
	

	public static function getRedStore():Store {
		return store_red;
	}
	
	public static function getWhiteStore():Store {
		return store_white;
	}
	
	
	}
	
	/*
	 * Запуск новой игры по F2
	 */ 
/*
    public function newGame():void {
		var nm:String = getScenario().getPlayerName();
		
		//-- чистим всё
		scenario.clean();
		scenario = null;
		
		enemyTorpedos.splice(0);
		enemyTorpedos = null;
	
		myTorpedos.splice(0);
		myTorpedos = null;
		
		enemyShips.splice(0);
		enemyShips = null;
		
		my_ship = null;
		
		info.clean()
		info = null;
		
		this.removeAllHandle();
		
		state = STOPED;
		zoom = 1.;
		delta_x = 0.;
		delta_y = 0.;
		offsetX = 0;
		offsetY = 0;
		mouse_delta_x=0;
		mouse_delta_y= 0;
		time_life= 0;
		time_last_move = 0;
		inputtext_state= 0;

		//-- проводим новую инициализацию	
		init();
		
		getScenario().setPlayerName(nm);
	}
*/	
}

