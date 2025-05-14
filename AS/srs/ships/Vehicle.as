package  srs.ships
{
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import srs.*;
	import srs.utils.*;
	import srs.sounds.SoundCrash;
	import srs.scenario.Scenario;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Vehicle extends Sprite {
		
	public static const POWER_M1:int = -1;
	public static const POWER_0:int = 0;
	public static const POWER_1:int = 1;
	public static const POWER_2:int = 2;
	public static const POWER_3:int = 3;
	public static const POWER_4:int = 4;
	public static const POWER_5:int = 5;
	public static const POWER_6:int = 6;
	
	public static const RUDER_RIGHT_15:int = -3;
	public static const RUDER_RIGHT_10:int = -2;
	public static const RUDER_RIGHT_5:int = -1;
	public static const RUDER_0:int = 0;
	public static const RUDER_LEFT_5:int = 1;
	public static const RUDER_LEFT_10:int = 2;
	public static const RUDER_LEFT_15:int = 3;
	
	protected var position_gm:Point; 
	protected var velocity_gm:Number = 0.;   // in pixel/millisecs
	protected var direction_deg:Number = 0. ;  // direction in degree
	protected var max_velocity_hum:Number = 30.; 
	
	protected var command_params:VehicleCommandParams = new VehicleCommandParams(POWER_0, RUDER_0);
	
	protected var time_live_msec:uint = 0;
	
	protected var color:uint = 0xffffff;
	
	protected var forces:int = Constants.FORCES_RED;  //-- признак свой чужой
	
	protected var time_last_move:int = 0;
	protected var info	:TextField;
	protected var ship_name:String = "";
	
	protected var tail:Array = null;
	protected var max_tails:int = Settings.TAIL_MAX_LENGTH;
	protected var tail_time_msec:int = 0;
	
	protected var way_point_color:int = Constants.WAY_POINT_COLOR; 

	protected var main:Main;
	
	//-- состояния движения объяекта
	protected static const ST_MOVE_UNKNOWN:int = 0;
	//-- чтобы судно двигалось по командам нужно задать их и установить move_state = ST_COMMAND_MOVING
	protected static const ST_COMMAND_MOVING:int = 1;
	protected static const ST_BEG_COMMAND_MOVING:int = 2;
	protected static const ST_END_COMMAND_MOVING:int = 3;
	
	protected static const ST_WP_MOVING:int = 4;
	protected static const ST_WP_TORP_DEFENCE_MOVING:int = 5;  //-- уход от атакующей торпеды
	protected static const ST_WP_TARGET:int = 6;
	protected static const ST_WP_SEARCH_TARGET:int = 7;
	protected static const ST_WP_CONVOY_MOVING:int = 8;
	protected static const ST_WP_FINISHED:int = 9;
	
	protected var move_state:int = ST_MOVE_UNKNOWN;
	//-- еслу cycle true то комады повторяются
	protected var move_command_cycle:Boolean = false;
	
	protected var commands:Array;
	protected var current_command:int = 0;
	
	protected var way_points:Array = null;
	protected var way_point:Point; //-- физическая точка в которую нужно переместиться
	protected var current_way_point:int = 0; //-- индекс в way_points физическая точка в которую нужно переместиться
	
	public var id:String = "";
	
	//-- маневренность в процентах 100 - торпеды и катера, 
	//   sub и суда 80-50, 10 - авианосец
	//   если суда идут в группе, то маневренность и скорость по последнему
	protected var manevr_prc:int = 100; 
	
	//-- признак того, что данный объект управляется в ручную
	protected var under_control:Boolean = false;
	
	//-- текущая цель
	protected var target:Target = null;
	
	//-- признак того, что это будет искать цель и двигаться к ней.
	protected var move_on_target:Boolean = false;
	
	protected var noisy:Number; //-- шумность 
	
	public function Vehicle(_main:Main) {
		main = _main; 
		//trace("I'm alive");
		
		draw_ship();
		
		main.addChild(this);
		info = new TextField();
		info.textColor = 0xdddddd;
		info.selectable = false;
		info.defaultTextFormat = new TextFormat("_sans", 9);
		info.text = "info";
		//main.getDisplay().addChild(info);
		main.addChild(info);
		
		tail = new Array();
		way_points = new Array();
		noisy = 1.;  
	}
	
	public function setNoisy(_noisy:Number):void {
		noisy  = _noisy ;
	}
		
	public function getCommandParams() :VehicleCommandParams {
		return command_params;	
	}
	
	/*
	 * Выбор направления движения.
	 * приоритет для судов - уклонение от торпедной атаки
	 * 
	 * 	override in Ship, Torped_III
	 * 
	 */ 
	public function AI_step_I():void {}
	
	
	/*
	 * Выбор направления движения на следующем шаге
	 */ 
	public function AI_step_II():void {
		//-- движение по программе
		if (commands != null 
			&& (move_state == ST_BEG_COMMAND_MOVING || move_state == ST_COMMAND_MOVING)) {
			var cmd:Command = commands[current_command];
			if (current_command == 0 && move_state == ST_COMMAND_MOVING ) {//ST_BEG_COMMAND_MOVING ) {
				move_state = ST_BEG_COMMAND_MOVING;
				setPower(cmd.power);
				setRudder(cmd.rudder);
				showPower();
				showRudder();
				cmd.time_start_execute = time_live_msec;
			} else {
				if (cmd.isTimeExpiried(time_live_msec)) {
					if(current_command < commands.length-1) {
						current_command++;
						trace ("current_command=" + current_command);
						cmd = commands[current_command];
						setPower(cmd.power);
						setRudder(cmd.rudder);
						showPower();
						showRudder();
						cmd.time_start_execute = time_live_msec;
					} else {
						if (move_command_cycle) {
							move_state = ST_COMMAND_MOVING;
							current_command = 0;
						} else {
							move_state = ST_END_COMMAND_MOVING;
							current_command = 0;
						}
					}
				}
			}
			return;
		}
		//-- движение к указанной точке
		if (
			move_state != ST_MOVE_UNKNOWN && move_state != ST_WP_FINISHED
			//&& !(move_state == ST_BEG_COMMAND_MOVING || move_state == ST_COMMAND_MOVING
			//|| move_state == ST_END_COMMAND_MOVING 
			) {
			//-- проверяем не достигнут ли пункт назначения
			if ( Point.distance(way_point, position_gm) <= Constants.WAY_POINT_SIZE) {
				//-- достигли WP!
				//main.getInformer().writeDebugText("WAY POINT " + current_way_point + " REACHED");
				//-- есть ещё WP?
				if(current_way_point == way_points.length -1) {
					//-- прекращаем наводку на пункт назначения
					onWpFineshed();
				} else {
					current_way_point++;
					var c2:CustomCircle = way_points[current_way_point];
					way_point = new Point( c2.getX(), c2.getY() );
				}
			} else {
				//-- вычисляем рассогласование направления на точку и направления объекта
				var delta:Number = Utils.calcDeltaBattleDeg(position_gm, direction_deg, way_point);
				//main.getInformer().writeDebugRightField("del", delta.toFixed(2));
				var dd:Number = 10.;
				if ((delta > 0 && delta < 1.) || (delta < 0 && delta > -1.)) {
					setRudder(Vehicle.RUDER_0);
				} else if (delta > 0 && delta < 180.) {
					if(delta < dd)
						setRudder(Vehicle.RUDER_0); //setRudder(Vehicle.RUDER_LEFT_5);
					else
						setRudder(Vehicle.RUDER_LEFT_15);
				} else if (delta > 0 && delta >= 180.) { 
					if(delta < 180.-dd) 
						setRudder(Vehicle.RUDER_RIGHT_5);
					else 	
						setRudder(Vehicle.RUDER_RIGHT_15);
				} else if (delta < 0 && delta > -180.) {
					if( delta > -dd)
						setRudder(Vehicle.RUDER_RIGHT_5);
					else 	
						setRudder(Vehicle.RUDER_RIGHT_15);
				} else if (delta < 0 && delta <= -180.) { 
					if (delta > 180. -dd)
						setRudder(Vehicle.RUDER_LEFT_5);
					else
						setRudder(Vehicle.RUDER_LEFT_15);
				}
				//showRudder();
			}
			return;
		}
	}
	
	/**
	 * Движение. Отрабатывает установленные руль и power
	 */
	public function move():void {
		if (!main.isStarted()) {
			return;
		}
		//before_move();
		var cur_time:int = getTimer();
		var dt_ms:int = cur_time - time_last_move;
		if (dt_ms < 50) {
			return; 
		}
		//-- calculate new speed depended from power
		var new_velocity_gm:Number = VehicleMoving.calc_velocity(dt_ms,velocity_gm, max_velocity_hum, command_params.power);
		var cur_vel_gm:Number = velocity_gm + (new_velocity_gm - velocity_gm) / 2.;
		
		direction_deg -= dt_ms * command_params.rudder * VehicleMoving.getAlphaR(cur_vel_gm,manevr_prc) * cur_vel_gm;
		if (direction_deg < 0)
			direction_deg = 360. + direction_deg;
		if (direction_deg > 360)
			direction_deg = direction_deg - 360.;
		this.rotation = direction_deg;	
		//-- calculate new position
		var p:Point = Point.polar(dt_ms * cur_vel_gm, Utils.toScreenRad(direction_deg)); // (direction - 90.) * Math.PI / 180.);
		
		//if (under_control) {
		//	var nn:Number = dt_ms * cur_vel_gm;
		//	Main.main.getInformer().writeDebugRightField("mov", nn.toFixed(2));
		//}
		position_gm = position_gm.add(p);
		makeTail();
		//if(Settings.DRAW_REAL_WORLD)
			new_disp_pos();	
		
		//-- remember values
		time_live_msec += dt_ms;
		velocity_gm = cur_vel_gm;
		time_last_move = cur_time;
		//infoText();
		//after_move();
	}

	/**
	 * Достигли WP
	 * 
	 * override in Ship
	 */
	protected function onWpFineshed():void {
		setRudder(RUDER_0);
		stopMoveOnWayPoint();
		//main.getInformer().writeDebugText("WAY POINT FINISHED");
	}
	
	
	/*
	 * Искать цель и двигаться на неё автоматически
	 */ 
	public function moveOnTarget(_move_on_target:Boolean): void {
		move_on_target = _move_on_target;
	}
		
	/*
	 * Выбор цели пока только для вражеских кораблей
	 * 
	 * overrided для Ship и Torpedo 
	 */ 
	public function selectTarget():Target {
		return null; // target;
	}
	
	/*
	 * Выбор судна конвоя
	 * 
	 * overrided для Ship 
	 */ 
	//override public function selectConvoy():Ship {}
	
	
	/*
	 * Задает пункт назначения
	 * 
	 * _type используется для отрисовки wp
	 * 
	 */ 
	public function addWayPoint(_x:Number, _y:Number, draw_type:int):void {
		var c2:CustomCircle = null;
		if(draw_type == Constants.WP_SHIP ) {
			c2 = new CustomCircle(_x, _y, 3, Constants.WAY_POINT_COLOR);
		} else if(draw_type == Constants.WP_TARGET ) {
			c2 = new CustomCircle(_x, _y, 1, Constants.WAY_POINT_COLOR_TARGET);
		} else if (draw_type == Constants.WP_TORP ) {
			if(Settings.DEBUG)
				c2 = new CustomCircle(_x, _y, 2, Constants.WAY_POINT_COLOR_TORPED);
			else	
				c2 = new CustomCircle(_x, _y, 0, Constants.WAY_POINT_COLOR_TORPED);
		} else if (draw_type == Constants.WP_TORP_DEFENCE) {
			if(Settings.DEBUG)
				c2 = new CustomCircle(_x, _y, 4, Constants.WAY_POINT_COLOR_T_DEFENCE);
			else	
				c2 = new CustomCircle(_x, _y, 0, Constants.WAY_POINT_COLOR_T_DEFENCE);
		}  else if (draw_type == Constants.WP_CONVOY) {
			if(Settings.DEBUG)
				c2 = new CustomCircle(_x, _y, 4, Constants.WAY_POINT_COLOR);
			else	
				c2 = new CustomCircle(_x, _y, 0, Constants.WAY_POINT_COLOR);
		} else if (draw_type == Constants.WP_TARGET_SEARCH) {
			if(Settings.DEBUG)
				c2 = new CustomCircle(_x, _y, 4, Constants.WAY_POINT_COLOR);
			else	
				c2 = new CustomCircle(_x, _y, 0, Constants.WAY_POINT_COLOR);
		}
		if (c2 == null)
			return;
		c2.x = main.toDisplayX(c2.getX());
		c2.y = main.toDisplayX(c2.getY());
			
		if (way_points == null)
			way_points = new Array();
			
		way_points.push(c2);
		main.addChild(c2);
	}
	
	
	public function startMoveOnWayPoint():void {
		move_state = ST_WP_MOVING;
		startMoveOnWP();
	}
	
	/*
	 * Активирует движение в указанную точку
	 * 
	 */ 
	protected function startMoveOnWP():void {
		//if (move_state != ST_WP_MOVING || move_state == ST_WP_AT_MOVING) {
			current_way_point = 0;
			//if((draw_point>0) {
			var c2:CustomCircle = way_points[0];
			way_point = new Point( c2.getX(), c2.getY() );
		//	if (move_state != ST_WP_AT_MOVING) {
		//		move_state = ST_WP_MOVING;
		//	} else {
		//	//if (under_control) {
		//		main.getInformer().writeDebugText("WAY POINT TORP DEFENCE MOVING...");
		//	//}
		//	}
	}

	/*
	 * Прекращает движение по маршруту
	 */ 
	public function stopMoveOnWayPoint():void {
		//if(move_state == ST_WP_MOVING) 
			move_state = ST_WP_FINISHED;
		removeWayPoints();
	}
	
	/*
	 * Добавление команды в массив команд
	 */ 
	public function addCommand(_command:Command):void {
		if (commands == null) {
			commands = new Array();
		}
		commands.push(_command);
	}
	
	/*
	 * Объект должен двигаться по командам
	 * еслу cycle true то комады повторяются
	 */ 
	public function setCommandMoveState(cycle:Boolean):void {
		move_state = ST_COMMAND_MOVING;
		move_command_cycle = cycle;
	}
	
	public function isEndMoveCommand():Boolean {
		return move_state == ST_END_COMMAND_MOVING;
	}
	
	/**
	 * Продолжаем выполнять команды движения
	 */
	protected function continueCommandMove():void {
		if (move_state != ST_BEG_COMMAND_MOVING
		&& move_state != ST_END_COMMAND_MOVING)
			move_state = ST_COMMAND_MOVING;
	}
	
	//public function getMoveState():int {
	//	return move_state;
	//}
	
	public function setMaxVelocityHum(max_vel:Number):void {
		max_velocity_hum = max_vel;
	}
	
	public function getMaxVelocityHum():Number {
		return max_velocity_hum;
	}
	
	public function drawShip():void {}

	protected function draw_ship():void {}

	protected function draw_ship_selected():void {}

	public function getTimeLiveMs():uint {
		return time_live_msec;
	}
	
	public function setForces(en:int):void {
		forces = en;	
		if (forces == Constants.FORCES_RED) {
			color = 0xff0000;
		} else {
			color = 0xffffff;
		}
		draw_ship();
	}
	
	public function getForces():int {
		return forces;
	}
	
	/*
	 * On events when torpedo hit
	 */
	//public function torpedoHit():void {}

	public function setPower(_power:int):void {
		command_params.setPower(_power);
		//if (Settings.DEBUG)
			drawShip();
	}
	
	public function getPower():int {
		return command_params.power;	
	}
	
	public function setRudder(_rudder:int):void {
		command_params.setRudder(_rudder);
	}
	
	public function setDirection(dir_deg:Number):void {
		direction_deg = dir_deg;
		this.rotation = direction_deg;	
	}
	
	public function start_move():void {
		time_last_move = getTimer();
	}
	
	public function setName(nm:String):void {
		ship_name = nm;	
	}
	
	public function getName():String {
		return ship_name;	
	}
	
	public function setTailVisible(tf:Boolean):void {
		for each(var c:CustomCircle in tail) {
			c.visible = tf;
		}
	}	
	
	public function setVisible(tf:Boolean):void {
		this.visible = tf;
		setTailVisible(tf);
		info.visible = tf;
	}	
	
	protected function new_disp_pos_tail():void {
		for each(var c:CustomCircle in tail) {
			c.x =  main.toDisplayX(c.getX());
			c.y =  main.toDisplayY(c.getY());
		}
	}	
		
	protected function new_dysp_pos_way_points():void {
		for each(var c:CustomCircle in way_points) {
			c.x =  main.toDisplayX(c.getX());
			c.y =  main.toDisplayY(c.getY());
		}
	}	
		
	/*
	 * Рисует форватерный след из нескольких кружочков. Если судно движется за ним через определенные интервалы времени оставляются точки. 
	 * Каждая точка живет определенное время. При масштабировании точки тоже масштабируются.
	 */ 
	protected function makeTail():void {
		if (velocity_gm == 0)
			return;
		if ( time_live_msec-tail_time_msec < Settings.TAIL_TIME_INTERVAL ) 
			return;
		
		if (tail.length >= max_tails) {	 
			main.removeChild(tail.shift());
		}
		//trace(tail.length);
		
		var c:CustomCircle = new CustomCircle(position_gm.x, position_gm.y, 1, Settings.TAIL_COLOR);
		c.x = main.toDisplayX(c.getX());
		c.y = main.toDisplayX(c.getY());
		//c.alpha = 1. - tail.length /  max_tails; 
		tail.push(c);
		main.addChild(c);
		main.moveToBack(c);

		/*
		for (var i:int = 0; i < tail.lenngth; i++) {
			var c2:CustomCircle = tail[i];
			c2.alpha = 1. - i / max_tails + 0.2;
		} */
		
		
		//if(tail.length>5)
		//	trace(tail[5].alpha);
		/**/
		tail_time_msec = time_live_msec;
	}
	
	protected function removeTail():void {
		for each(var c:CustomCircle in tail) {
			main.removeChild(c);
		}
		tail.splice(0);
		tail = null;
	}
	
	protected function removeWayPoints():void {
		if (under_control) {
			main.getInformer().panelLampOnOff(Constants.LAMP_WP,false);
			main.getInformer().removeRightField("dir");
			main.getInformer().removeRightField("_dir");
			main.getInformer().removeRightField("wpa");
			main.getInformer().removeRightField("_wpa");
			main.getInformer().removeRightField("dir");
			main.getInformer().removeRightField("del");		
			main.getInformer().removeRightField("dir");		
			main.getInformer().removeRightField("WPx");		
			main.getInformer().removeRightField("WPy");		
		}
		
		if(way_points != null) {
			for each(var c:CustomCircle in way_points) {
				main.removeChild(c);
				c = null;
			}
			way_points.splice(0);
			way_points = null;
		}
	}
	
	public function infoText():void {
		//info.text = ship_name + "\n" // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
		//+ "\px=" + position.x.toFixed(0) + " py=" + position.y.toFixed(0)
		//+ "\nvel=" + cur_vel.toFixed(0);
	}
	
	/**
	 * Пересчет из игровых в дисплейные коотдинаты
	 */
	public function new_disp_pos():void {
		this.x = main.toDisplayX(position_gm.x);
		this.y = main.toDisplayY(position_gm.y);
		info.x = this.x +4;
		info.y = this.y + 4;
		
		new_disp_pos_tail();
		new_dysp_pos_way_points();
	}

	public function getDirection():Number {
		return direction_deg;
	}
	
	public function getPosition():Point {
		return position_gm;
	}
	
	public function setPosition(p_x:Number, p_y:Number):void {
		position_gm = new Point(p_x, p_y);
		this.x = main.toDisplayX(p_x);
		this.y = main.toDisplayY(p_y); 
		info.x = this.x;
		info.y = this.y;
	}
	
	public function setPosition2(p:Point):void {
		position_gm = new Point(p.x,p.y);
		this.x = main.toDisplayX(p.x);
		this.y = main.toDisplayY(p.y); 
		info.x = this.x;
		info.y = this.y;
	}
	
	/**
	 * 
	 * @return phisical velosity in knots
	 */
	public function getPhisVelocity():Number {
		return velocity_gm / Settings.koef_v;
	}
	
	public function getVelocity():Number {
		return velocity_gm;
	}
	
	public function set_velocity(v:Number):void {
		velocity_gm = v;
	}
	
	public function power_change(delta:int):void {
		command_params.power_change(delta);
		if (under_control)
			showPower();
	}
	
	public function rudder_change(delta:int):void {
		command_params.rudder_change(delta);
		if (under_control)
			showRudder();
	}
	
	/*
	 * Вызывается когда механизм уничтожен
	 */ 
	public function destroy():void {
		//-- удаляем из всех массивов
		main.destroy_vehicle(this);
		//-- удаляем хвост
		removeTail();
		//-- удаляем все маршрутные точки
		removeWayPoints();
		//-- удаляем info text из графики
		main.removeChild(info);
		//-- переводим фокус на main
		main.stage.focus = main;
		//-- данный объект под контролем?
		if (under_control) {
			main.stop();
			//main .my_ship = null; //!!! ЭТО ПРАВИЛЬНО?
		}
	}

	/*
	 * Проверка столкновения с объектом
	 */ 
	public function testCrash(obj:Sprite):Boolean {
		if (obj == null)
			return false;
		if (obj.hitTestPoint(x, y, true)) {
			return true;
		}
		return false;
	}
	
	public function crash():void {
		//trace("CRASH!!!");
		this.set_velocity(0);
		this.setPower(0);
		if (under_control) {
			var sound:SoundCrash = new SoundCrash(); 			     
			sound.play(1.); 		
			main.getInformer().setCommandAlarm("CRASH!!!");	
			main.mainGameOver(Scenario.MISSION_FAILED)
		}
		this.destroy();
	}
	
	public function showPower():void {
		if (under_control) {
			main.getInformer().setCommand("Power: " + command_params.power);
			main.getInformer().setPower(getPower().toString());
		}
	}
	
	public function showRudder():void {
			if(under_control) {
				if(command_params.rudder == RUDER_0) {
					main.getInformer().setCommand("Steady as she goes, Sir!");
					main.getInformer().setRudder("0");
					return;
				}		
				if (command_params.rudder == RUDER_LEFT_5) {
					main.getInformer().setCommand("5 deg left rudder, aye.");
					main.getInformer().setRudder("L 5");
					return;
				}
				if (command_params.rudder == RUDER_LEFT_10) {
					main.getInformer().setCommand("10 deg left rudder, aye.");
					main.getInformer().setRudder("L 10");
					return;
				}
				if (command_params.rudder == RUDER_LEFT_15) {
					main.getInformer().setCommand("15 deg left rudder, aye.");
					main.getInformer().setRudder("L 15");
					return;
				}
				if (command_params.rudder == RUDER_RIGHT_5) {
					main.getInformer().setCommand("5 deg right rudder, aye.");
					main.getInformer().setRudder("R 5");
					return;
				}
				if (command_params.rudder == RUDER_RIGHT_10) {
					main.getInformer().setCommand("10 deg right rudder, aye.");
					main.getInformer().setRudder("R 10");
					return;
				}
				if (command_params.rudder == RUDER_RIGHT_15) {
					main.getInformer().setCommand("15 deg right rudder, aye.");
					main.getInformer().setRudder("R 15");
					return;
				}
			}	
			/*
			if(command_params.rudder == RUDER_0) {
				//main.getInformer().setCommand("Steady as she goes, Sir!");
				main.getInformer().writeDebugDopField("RUD","0");
				return;
			}		
			if (command_params.rudder == RUDER_LEFT_5) {
				//main.getInformer().setCommand("5 deg left rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","L 5");
				return;
			}
			if (command_params.rudder == RUDER_LEFT_10) {
				//main.getInformer().setCommand("10 deg left rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","L 10");
				return;
			}
			if (command_params.rudder == RUDER_LEFT_15) {
				//main.getInformer().setCommand("15 deg left rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","L 15");
				return;
			}
			if (command_params.rudder == RUDER_RIGHT_5) {
				//main.getInformer().setCommand("5 deg right rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","R 5");
				return;
			}
			if (command_params.rudder == RUDER_RIGHT_10) {
				//main.getInformer().setCommand("10 deg right rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","R 10");
				return;
			}
			if (command_params.rudder == RUDER_RIGHT_15) {
				//main.getInformer().setCommand("15 deg right rudder, aye.");
				main.getInformer().writeDebugDopField("RUD","R 15");
				return;
			}*/
	}

	public function setUnderControl(_under_control:Boolean):void {
		under_control = _under_control;
	}
	
	public function getUnderControl():Boolean {
		return under_control;
	}
	
	public function setManevr(_manevr_prc:int):void {
		manevr_prc = _manevr_prc;
	}
		
	public function getManevr():int {
		return manevr_prc;
	}
		
	}

}