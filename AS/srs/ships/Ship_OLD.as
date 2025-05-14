package  srs.ships
{
	 
import flash.geom.Point;
import flash.utils.getTimer;
import flash.events.MouseEvent;
import srs.AI.Situation1x1;

import srs.*;
import srs.scenario.Store;
import srs.sounds.*;
import srs.utils.*;


public class Ship_OLD extends Vehicle {

	protected var hit_count:int = 0;
	
	protected var size_for_hit:Number = Settings.SHIP_HIT_SIZE; //-- расстояние на котором торпеда попадает в этот корабль
	
	protected var time_reload_torped_ms:int = 15000;  //-- время загрузки торпеды (ДЛЯ БОТОВ!)
	protected var time_torp_fire:uint; //-- время выстрела торпедой
	
	protected var equipped_torpeds:Boolean = false;
	
	protected var store:Store;
	
	protected var default_torp_app:TorpedApp;

	protected var health:Number = 1000.;
	protected var convoy:Boolean = false;
	protected var folow_convoy:Boolean = false;
	protected var folow_convoy_angle:Number = 90;
	protected var folow_convoy_dist:Number = 200;

	protected var cur_ship_target:Ship;
	
	protected var no_hit_damage:Boolean = false;
	//-- список мишеней
	protected var targets:Array = new Array();
	
	protected var param_before_atack:VehicleParams;
	protected var param_t_before_atack:VehicleParams;
	//-- признак уклонения от торпедных атак
	protected var anty_torp_manevr:Boolean = true;

	protected var situation:Situation1x1;
	
	public function Ship_OLD(_main:Main,_enemy:int) {
		super(_main);
		setForces(_enemy);
		if (forces == Constants.FORCES_RED) {
			store = Main.getRedStore();
		} else {
			store = Main.getWhiteStore();
		}
		default_torp_app = new TorpedApp(this);
		
		this. addEventListener(MouseEvent.CLICK, selectOnDisplay); 
		this. addEventListener(MouseEvent.DOUBLE_CLICK, underControl); 
		//this. addEventListener(MouseEvent.CLICK, underControl); 
	}
	
	/**
	 * Делает текущим управляемым объектом данный корабль
	 */
	public function underControl(event:MouseEvent):void {
			main.getMyShip().setUnderControl(false);
			main.getMyShip().drawShip();
			this.setUnderControl(true);
			main.setMyShip(this);
			main.getMyShip().drawShip();
	}
	
	/**
	 * Обработка клика мышки
	 * 
	 * @param	event
	 */
	public function selectOnDisplay(event:MouseEvent):void { 
		//trace(event.currentTarget.toString() + " dispatches MouseEvent. Local coords [" + 
		//event.localX + "," + event.localY + "] Stage coords [" + event.stageX + "," + event.stageY + "]"); 

		if(display_selected)  
			display_selected = false;
		else 	
			display_selected = true;
		drawShip();
	}
	
	/**
	 * Обработка события редкого цикла
	 * 
	 * @param	time
	 * 
	 * overrides in Sub
	 */
	public function onSlowLoop(time:int):void {}
	
	/**
	 * 
	 */ 
	public function getStore():Store {
			return store;
	}

	/**
	 * Выбор судна конвоя
	 * 
	 * overrided для Ship 
	 */ 
	public function selectConvoy():Ship {
		//-- для того который под ручным управление не выбираем цель
		if (under_control) {
			return null;
		}
		////-- пока исходим из того, что я один ))
		if (forces == Constants.FORCES_RED) {
			for each(var s:Ship in Main.main.getRedShips()) {
				if (s.isConvoy()) {
					return s;
				}
			}
		} else {
			for each(var s:Ship in Main.main.getWhiteShips()) {
				if (s.isConvoy()) {
					return s;
				}
			}
		}
		return null;
	}

	/**
	 * Следовать за конвоем на отдалении angle, dist
	 * 
	 * @param	folow_convoy_dist
	 * @param	folow_convoy_angle
	 */
	public function setFollowConvoy(_folow_convoy_dist:Number, _folow_convoy_angle:Number):void {
		folow_convoy = true; // folow_convoy;
		folow_convoy_angle = _folow_convoy_angle;
		folow_convoy_dist = _folow_convoy_dist;
	}
	
	public function setConvoy(_convoy:Boolean):void {
		convoy = _convoy;
	}
	
	public function isConvoy():Boolean {
		return convoy;
	}
		
	protected function addTarget(_ship:Ship, _noise:Number):void {
		var trg:Target; 
		for each(trg in targets) {
			if (trg.ship == _ship) {
				trg.noise = _noise;
				return;
			}
		}
		trg = new Target(_ship, _noise);
		targets.push(trg);
	}
	

	/**
	 * Рассчитывет шум данного сугна на расстоянии dist
	 * 
	 * @param	dist
	 * @return
	 */
	public function calcNoiseAtDist(dist:Number):Number {
		return VehicleMoving.calcNoise(noisy, getPower(), dist);
	}
	
	
	/**
	 * Заполняет список мишеней
	 */
	public function fillAllTarget():void {
		//-- чистим список мишеней
		targets.splice(0);
		if (forces == Constants.FORCES_RED) {
			for each(var s:Ship in Main.main.getWhiteShips()) {
				var dist:Number = Point.distance(position_gm, s.position_gm);
				//-- вычисляем шум цели
				var ns:Number = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
				//main.getInformer().writeDebugRightField("my noise", ns.toFixed(3));
				//-- если разрешение по шуму > NOISE_TRAKCING_RANGE
				 if(ns >= Settings.NOISE_TRAKCING_RANGE) { 
					addTarget(s, ns);
				 }
			}
		} else {
			for each(var s:Ship in Main.main.getRedShips()) {
				dist = Point.distance(position_gm, s.position_gm);
				//-- вычисляем шум цели
				ns = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
				//-- берем в обработку только превышающие порог NOISE_TRAKCING_RANGE
				if (ns >= Settings.NOISE_TRAKCING_RANGE) {
					addTarget(s, ns);
				}
			}
			main.getInformer().writeDebugRightField("detect", targets.length.toFixed(0));
		}
	}
	
	/**
	 * Выводит информацию о текущей цели на правую панель
	 */
	public function showTarget():void {
		if (targets.length == 0) {
			main.getInformer().setCommand("No target defined, Sir.");
			return;
		}
		var trg:Target; 
		if (cur_ship_target != null) {
			for each(trg in targets) {
				if (trg.ship == cur_ship_target) {
					break;
				}
			}
		}
		if(trg == null) {
			trg = targets[0];
			cur_ship_target = trg.ship;
		}
		main.getInformer().writeDebugRightField("tgt name", cur_ship_target.getName());
		main.getInformer().writeDebugRightField("tgt noise", trg.noise.toFixed(3));
		main.getInformer().writeDebugRightField("tgt resolv", cur_ship_target.getResolvStr(this));
	}
	
	/**
	 * Возвращает строку насколько данный корабль видит res_ship
	 * 
	 * @param	res_ship
	 */
	public function getResolvStr(res_ship:Ship):String {
		for each(var trg:Target in targets) {
			if (trg.ship == res_ship) {
				return "" + trg.noise.toFixed(3);
			}
		}
		return "0";
	}
	
	/**
	 * Выбор цели на которую начинаем охоту
	 * сейчас возвращается самая громкая
	 * 
	 * overrided для Ship и Torpedo 
	 */ 
	override public function selectTarget():Target {
		//-- для того который под ручным управление не выбираем цель
		if (under_control) {
			return null;
		}
		//-- пока исходим из того, что я один ))
		//if (enemy != Constants.ENEMY) {
		//	return null;
		//}
		//}
		//-- выбираем самую громкую цель
		var ret_trg:Target;
		var ns:Number = 0;
		for each(var trg:Target in targets) {
			if(ns == 0) {
				ns = trg.noise;	
				ret_trg = trg;
			} else if (trg.noise > ns) {
				ret_trg = trg;
				ns = trg.noise;
			}
		}
		return ret_trg;
	}
	
	/*
	 * Установка признака того, что корабль ведет стрельбу торпедами
	 */ 
	public function setEquippedTorpeds(eq_torp:Boolean):void {
		equipped_torpeds = eq_torp;
	}

	/*
	 * Выбор типа оружия для стрельбы
	 */	
	//public function selectWeapon(type:int) {
	//	weapon_selected = type;
	//}

	/*
	 * Выбор типа оружия для стрельбы
	 */ /*	
	public function selectWeapon(type:int) {
		selected_torp_weapon = null;
		if ( type == Constants.WEAPON_SELECT_TORP_I) {
				//-- не очень красиво заводить новый объект, но пока так
				selected_torp_weapon = new Torped_I(main);
		} else if ( type == Constants.WEAPON_SELECT_TORP_II) {
				//-- не очень красиво заводить новый объект, но пока так
				selected_torp_weapon = new Torped_II(main);
		} else if ( type == Constants.WEAPON_SELECT_TORP_III) {
				//-- не очень красиво заводить новый объект, но пока так
				selected_torp_weapon = new Torped_III(main);
		} else {
			trace(" UNKNOWN TYPE OF WEAPON ! ");
			main.getInformer().setCommandAlarm(" UNKNOWN TYPE OF WEAPON ! ");
		}
	}*/
	
	public function setTimeReloadTorped(t_sec:Number):void {
		time_reload_torped_ms = t_sec*1000;
	}
	
	public function getTimeReloadTorpSec():Number {
		return time_reload_torped_ms/1000;
	}
	
	/**
	 * Выбор оружия по параметрам цели и степени его готовности
	 */ 
	protected function AI_select_weapon(_target:Ship):TorpedParams {
		//-- расстояние до цели маленькое - выбираем торпеду III	
		var dist:Number = Point.distance(position_gm, _target.getPosition());
		//main.getInformer().writeDebugRightField("d 1", dist.toFixed(0));
		
		var torp_params:TorpedParams;
		var torp_params_II:TorpedParams;
		var torp_params_III:TorpedParams;
		var dist_max_III:Number;
		if (forces == Constants.FORCES_WHITE) {
			torp_params_II = Main.getWhiteStore().getParams_II();
			torp_params_III = Main.getWhiteStore().getParams_III();
		} else {
			torp_params_II = Main.getRedStore().getParams_II();
			torp_params_III = Main.getRedStore().getParams_III();
		}
		dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;
		
		//-- выбор типа торпеды для выстрела
		if (dist > dist_max_III) {
			torp_params = torp_params_II;
			//_getWeaponType = Constants.WEAPON_SELECT_TORP_II;
			//_getMaxTimeLifeSec = Store.cur_II_params.max_time_life_sec;
			//_getMaxVelocity = Store.cur_II_params.max_velocity_hum;
		} else {
			torp_params = torp_params_III;
			//_getWeaponType = Constants.WEAPON_SELECT_TORP_III;
			//_getMaxTimeLifeSec = Store.cur_III_params.max_time_life_sec;
			//_getMaxVelocity = Store.cur_III_params.max_velocity_hum;
		}
		return torp_params;
	}
	
	protected function st_wp_move_on_target():void {
		if (target != null) {
			//-- Обновляем данные цели
			for each(var t:Target in targets) {
				if (t.ship == target.ship) {
					target.noise = t.noise;
					break;
				}
			}
			//-- Есть заданные WP?
			if(way_points!=null) {
				//-- Останавливаем и чистим WP
				stopMoveOnWayPoint();
			}
			//-- устанавливаем WP на цель 
			addWayPoint(target.ship.position_gm.x, target.ship.position_gm.y, Constants.WP_TARGET);
			
			//-- двигаемся с максимальной скоростью
			setPower(POWER_6);

			//-- Начинаем движение на WP
			startMoveOnWP();
			
			//-- Вооружен?
			if (equipped_torpeds) {
				//-- цель различима?
				if (target.noise >= Settings.NOISE_DETECTION) {
					//-- стреляем 
					AI_torped_fire();
				}
			}
			
			//-- ДВИЖЕНИЕ НА ЦЕЛЬ
			move_state = ST_WP_TARGET;
		} else {
			//-- НЕИВЕСТНО
			move_state = ST_MOVE_UNKNOWN;
		}
	}
	
	protected function  st_wp_torp_defence_moving(t:Torped):void {
			// угрожающая торпеда исчезла?
			if (t == null) {
				//---- мы не под прицелом, поэтому расслабляемся
				
				//-- Останавливаем движение на WP
				stopMoveOnWayPoint();
				
				//-- Искать цели?
				if (move_on_target) {
					//-- Ищем цель
					target = selectTarget();
					//-- Нашли цель?
					if (target == null) {
						//-- нужно двигаться в сторону пуска угрожающей торпеды
						
						//-- устанавливаем WP на запомненное положение угрожающей торпеды
						addWayPoint(param_t_before_atack.position.x, param_t_before_atack.position.y
							, Constants.WP_TARGET_SEARCH);
						//-- начинаем движение к точке пуска торпеды
						startMoveOnWP();
						//-- двигаемся с максимальной сукоростью
						setPower(POWER_6);
						//-- очищаем запомненное точке пуска торпеды
						param_t_before_atack = null;
						//-- WP ПОИСК ЦЕЛИ
						move_state = ST_WP_SEARCH_TARGET;
						return;
					} else {
						st_wp_move_on_target();
						return;
					}
				} else {
					//-- если выполнял команды то продолжает 
					if (commands != null) {
						//-- Устанавливаем запомненное направление
						setDirection(param_before_atack.direction);
						//-- продолжаем движение по командам
						continueCommandMove();
						param_before_atack = null;
						//-- ДВИЖЕНИЕ ПО КОМАНДАМ
						move_state = ST_COMMAND_MOVING;
						return;
					} 
					move_state = ST_MOVE_UNKNOWN;
					return;
				}
			} else {
				//-- ставим признак уклонения от тореды
				move_state = ST_WP_TORP_DEFENCE_MOVING;
				return;
			}
			
	}
	
	/**
	 * Выбор направления движения
	 * 
	 * Здесь задается состояние движения
	 * 
	 * приоритет - уклонение от торпедной атаки
	 */ 
	override public function AI_step_I():void {
		
		//-- заполняем список целей
		fillAllTarget();

		if (under_control) {
			return;
		}
		//-- Получаем угрожающую торпеду
		var t:Torped = checkTrpAtack();
		
		//-- если выполняется маневр уклонения то его и продолжаем 
		//    (МОЖЕТ БЫТЬ ОТ ДРУГОЙ, МЕНЕЕ ОПАСНОЙ ТОРПЕДЫ!)
		if (move_state == ST_WP_TORP_DEFENCE_MOVING) { 
			//-- выполняется манеар уклонения
			st_wp_torp_defence_moving(t);
			return;
		}
		//-- Есть угрожающая торпеда?
		if (t != null) {
			if (commands != null) {
				//-- запоминаем прежний курс чтобы вернуться
				param_before_atack =  new VehicleParams(position_gm, velocity_gm, direction_deg);
			}
			//-- запоминаем параметры торпеды
			param_t_before_atack =  new VehicleParams(t.getPosition(), t.getVelocity(), t.getDirection());
			
			//-- убираем предыдущий маршрут
			stopMoveOnWayPoint();
			
			//---- вырабатываем точку уклонения TRP_ATACK_DEFENSE_ANGLE градусов пока не выйдем из атаки
			
			var p:Point;
			//-- в какую сторону поворачивать выбираем случайно
			if(Math.random()>0.5)
				p = Point.polar(100., Utils.toScreenRad(direction_deg + Settings.TRP_ATACK_DEFENSE_ANGLE)); 
			else 
				p = Point.polar(100., Utils.toScreenRad(direction_deg - Settings.TRP_ATACK_DEFENSE_ANGLE)); 
			var p2:Point = position_gm.add(p);
			
			//-- устанавливаем WP на точку уклонения
			addWayPoint(p2.x, p2.y, Constants.WP_TORP_DEFENCE);
			//-- двигаемся с максимальной скоростью
			setPower(POWER_6);
			//-- начинаем движение к точке уклонения
			startMoveOnWP(/*Constants.WP_TORP_DEFENCE*/);
			
			st_wp_torp_defence_moving(t);
			return;
		} 
		//-- t == null
		
		if (move_state == ST_WP_TARGET) {
			st_wp_move_on_target();
			return;
		}
		
		if (move_state == ST_WP_SEARCH_TARGET) {
			return;
		}
		
		//-- Искать цели?
		if (move_on_target) {
			//-- Ищем цель
			target = selectTarget();
			//-- Нашли цель?
			if (target != null) {
				st_wp_move_on_target();
				return;
			}
		} 
		//-- Нужно конвоировать?
		if (folow_convoy) {
			//-- выбираем конвоируемое судно
			var c:Ship = selectConvoy();
			//-- нашли подконвойного?
			if (c != null) {
				//-- были старые WP?
				if (way_points != null) {
					//-- stopMoveOnWayPoint();
					stopMoveOnWayPoint();
				}
				//-- устанавливаем WP точку конвоя
				var p:Point = c.getPosition()
					.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
				addWayPoint(p.x, p.y, Constants.WP_CONVOY);
				//-- начинаем движение к точке конвоя
				startMoveOnWP(/*Constants.WP_SHIP*/);
				//-- двигаемся с максимальной сукоростью
				setPower(POWER_6);
				move_state = ST_WP_CONVOY_MOVING;
				return;
			}
		}
		move_state = ST_MOVE_UNKNOWN;
		//super.AI_step_I();
	}


	
	/**
	 * Выбор направления движения
	 * 
	 * Здесь задается состояние движения
	 * 
	 * приоритет - уклонение от торпедной атаки
	 */ 
	/*
	override public function AI_step_I():void {
		//-- заполняем список целей
		fillAllTarget();

		if (under_control) {
			return;
		}
		var t:Torped = checkTrpAtack();
		//-- если выполняется маневр уклонения то его и продолжаем 
		//    (МОЖЕТ БЫТЬ ОТ ДРУГОЙ, МЕНЕЕ ОПАСНОЙ ТОРПЕДЫ!)
		if (move_state == ST_WP_TORP_DEFENCE_MOVING) { 
			//-- выполняется манеар уклонения
			// угрожающая торпеда исчезла?
			if (t == null) {
				//-- мы не под прицелом, поэтому расслабляемся
				stopMoveOnWayPoint();
				if(search_target) {
					target = selectTarget();
					if (target == null) {
						//-- если цели нет то нужно двигаться в сторону пуска угрожающей торпеды
						//var p:Point = main.getMyship().getPosition();
						setWayPoint(param_t_before_atack.position.x, param_t_before_atack.position.y
							, Constants.WP_TARGET_SEARCH);
						//-- начинаем движение к точке пуска торпеды
						move_state = ST_WP_SEARCH_TARGET;
						startMoveOnWP();
						//-- двигаемся с максимальной сукоростью
						setPower(POWER_6);
						super.AI_step_I();
						param_t_before_atack = null;
						return;
					}
				} else {
					//-- если выполнял команды то продолжает 
					if (commands != null) {
						setDirection(param_before_atack.direction);
						continueCommandMove();
						super.AI_step_I();
						param_before_atack = null;
						return;
					}
				}
			} else {
				super.AI_step_I();
				return;
			}
		}
		//-- если мы под прицелом то начинаем выполнять маневр уклонения
		if (t != null) {
			if (commands != null) {
				//-- запоминаем прежний курс чтобы вернуться
				param_before_atack =  new VehicleParams(position_gm, velocity_gm, direction_deg);
			}
			//-- запоминаем параметры торпеды
			param_t_before_atack =  new VehicleParams(t.getPosition(), t.getVelocity(), t.getDirection());
			
			//-- убираем предыдущий маршрут
			stopMoveOnWayPoint();
			//-- вырабатываем точку уклонения TRP_ATACK_DEFENSE_ANGLE градусов пока не выйдем из атаки
			//main.getInformer().writeDebugRightField("tgdr", direction_deg.toFixed(0));
			//main.getInformer().writeDebugRightField("tgpx", position_gm.x.toFixed(0));
			//main.getInformer().writeDebugRightField("tgpy", position_gm.y.toFixed(0));
			var p:Point;
			//-- в какую сторону поворачивать выбираем случайно
			if(Math.random()>0.5)
				p = Point.polar(100., Utils.toScreenRad(direction_deg + Settings.TRP_ATACK_DEFENSE_ANGLE)); 
			else 
				p = Point.polar(100., Utils.toScreenRad(direction_deg - Settings.TRP_ATACK_DEFENSE_ANGLE)); 
			//main.getInformer().writeDebugRightField("px", p.x.toFixed(0));
			//main.getInformer().writeDebugRightField("py", p.y.toFixed(0));
			var p2:Point = position_gm.add(p);
			//main.getInformer().writeDebugRightField("p2x", p2.x.toFixed(0));
			//main.getInformer().writeDebugRightField("p2y", p2.y.toFixed(0));
			setWayPoint(p2.x, p2.y, Constants.WP_TORP_DEFENCE);
			//-- начинаем движение к точке уклонения
			//-- ставим признак уклонения от тореды
			move_state = Vehicle.ST_WP_TORP_DEFENCE_MOVING;
			//-- двигаемся с максимальной скоростью
			setPower(POWER_6);
			startMoveOnWP();
			super.AI_step_I();
			return;
		} 
		//-- t == null
		//-- если вооружен и нашел цель то пойдет на неё
		if (search_target) {
			//-- выбираем цель
			target = selectTarget();
			if (target != null) {
				super.AI_step_I();
				return;
			}
		}
		//-- если не осуществляется поиск цели и нужно конвоировать
		if (folow_convoy && move_state != ST_WP_SEARCH_TARGET) {
			var c:Ship = selectConvoy();
			if (c != null) {
				if(way_points!=null) {
					stopMoveOnWayPoint();
				}
				var p:Point = c.getPosition()
					.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
				setWayPoint(p.x, p.y, Constants.WP_CONVOY);
				//-- начинаем движение к точке уклонения
				move_state = ST_WP_CONVOY_MOVING;
				//-- двигаемся с максимальной сукоростью
				setPower(POWER_6);
				startMoveOnWP();
				super.AI_step_I();
				return;
			}
		}
		//super.AI_step_I();
	}*/

	/**
	 * Выбор направления движения на следующем шаге
	 */
	override public function AI_step_II():void {
		super.AI_step_II();
		/*
		//-- AI работает только для ботов
		if (under_control)
			return;
		
		//-- управление автоматическим огнем
		if (equipped_torpeds) {
			//-- нет цели - не стреляем
			if (target == null)
				return;
			//-- сьреляем если цель различима
			if(target.noise >= Settings.NOISE_DETECTION) {
				AI_torped_fire();
			}
		}
		*/
	}
	
	/**
	 * 
	 * Выбор торпеды
	 * Рассчет точки выстрела для прямолинейно движущихся торпед.
	 * Можно улучшить алгоритм повысив точность за счет второго цикла итераций
	 * 
	 */
	public function AI_torped_fire():void {
		var _getMaxTimeLifeSec:Number;		
		var _getMaxVelocity:Number;
		var _getWeaponType:int;
		var fire_state: int = 0; 
		
		//-- ботам пофиг торпедные аппараты
		if(!Settings.CHEAT) {
			if ((getTimer() - time_torp_fire) < 
				time_reload_torped_ms  + Math.random() * time_reload_torped_ms/2.) {
				return;
			}
		}
		
		//-- Если выбрана цель
		if (target == null) return;
		if (target.ship == null) return;
		
		var start_time:int = getTimer();
		
		//-- выбираем оружие для цели
		var torp_params:TorpedParams =  AI_select_weapon(target.ship);
		if (torp_params == null) {
			Statistic.AI_calc_time += getTimer() - start_time;
			return;
		}
		_getWeaponType = torp_params.weapon_type;
		var cur_torp_app:TorpedApp;
		if(_getWeaponType == Constants.WEAPON_SELECT_TORP_I) {
			cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_I);		
			if (cur_torp_app == null) {
				return;
			}
		}
		if(_getWeaponType == Constants.WEAPON_SELECT_TORP_II) {
			cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_II);		
			if (cur_torp_app == null) {
				return;
			}
		}
		if(_getWeaponType == Constants.WEAPON_SELECT_TORP_III) {
			 cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_III);		
			if (cur_torp_app == null) {
				return;
			}
		}
		_getMaxTimeLifeSec = torp_params.max_time_life_sec;
		_getMaxVelocity = torp_params.max_velocity_hum;
		
		//-- 2 Определяем угол выстрела
		var target_position:Point;
		var len:Number; 
		var dt:Number = _getMaxTimeLifeSec * 1000. / Settings.AI_torped_fire_interval; // * 5.;
		var torpedo_position:Point;
		var target_position2:Point;
		var t_ms:Number = 0; 

		var vp:VehicleParams = new VehicleParams(target.ship.position_gm
			,target.ship.velocity_gm
			,target.ship.direction_deg); 
		target_position2 = target.ship.position_gm;
		
		for (var i:int = 1; i < Settings.AI_torped_fire_interval; i++) {
			t_ms += dt;  
			if (t_ms > _getMaxTimeLifeSec * 1000) { 
				return;
			}
			var si:String = i.toString();
			//main.getInformer().writeDebugRightField("i1", si);
			
			//-- рассчитываем положение цели в момент времени dt ПРЯМОЛИНЕЙНЫЙ АЛГОРИТМ
			var p:Point = Point.polar(t_ms * target.ship.getVelocity()
			   , Utils.toScreenRad(target.ship.getDirection()));
			target_position = target.ship.getPosition().add(p);
						
			//-- рассчитываем положение цели в момент времени t. УЧИТЫВАЕТСЯ ТЕКУЩИЙ МАНЕВР ЦЕЛИ 
			//-- ЗДЕСЬ РЕЗЕРВ ПРОИЗВОДИТЕЛЬНОСТИ! НУЖНО ПЕРЕСЧИТЫВАТЬ ТОЛЬКО КУСОЧКАМИ dt
			vp = VehicleMoving.move_calc_pos2(dt, vp, target.ship.getCommandParams()
				, target.ship.max_velocity_hum,	target.ship.manevr_prc);
			target_position2 = vp.position;
			
			if(Settings.DRAW_TORPED_CALC) {
				//-- рисуем точку вчтречи по линейному алгоритму 
				var c:CustomCircle = new CustomCircle(target_position.x, target_position.y, 2, 0xffff00);
				c.x = main.toDisplayX(c.getX());
				c.y = main.toDisplayX(c.getY());
				main.addChild(c);
				
				var c2:CustomCircle = new CustomCircle(target_position2.x, target_position2.y, 2, 0xff00ff);
				c2.x = main.toDisplayX(c2.getX());
				c2.y = main.toDisplayX(c2.getY());
				main.addChild(c2);
			}
			//-- за время t торпеда пройдет 
			len = t_ms * _getMaxVelocity * Settings.koef_v ; 
			//main.getInformer().writeDebugRightField(" t ", t_ms.toFixed(0));
			//main.getInformer().writeDebugRightField("len", len.toFixed(0));
			//-- рассчитываем расстояние от нашей позиции до target.ship_position
			var dist:Number = Point.distance(this.position_gm, target_position2);
			//main.getInformer().writeDebugRightField("d t", dist.toFixed(0));
			
			if (len > dist ) {
				var atak_point:Point = target_position2.subtract(position_gm);
				var angle:Number = Utils.calcAngle(0, 0, atak_point.x, atak_point.y);
				if (fire_state == 0) {
					var pp:Point = atak_point.add(position_gm);
				}
				//-- 3 Если решение есть производим выстрел
				if (fire_state == 0) {
					//-- выстрел!
					if (this is Sub) {
						var torp:Torped = fire(_getWeaponType);
						if (torp == null)
							return;
						main.registerTorped(torp,getForces());
						cur_torp_app.onFire();
					} else {
						main.fire_in_direction(this, Utils.toBattleDegree(angle), _getWeaponType);
						cur_torp_app.onFire();
					}
					if(Settings.DRAW_TORPED_CALC) {
						//-- рисуем расчетную точку встречи
						var p1:Point = Point.polar(dist, angle);
						var p2:Point = p1.add(position_gm);
						c2 = new CustomCircle(p2.x, p2.y, 3, 0xFF6347);
						c2.x = main.toDisplayX(c2.getX());
						c2.y = main.toDisplayX(c2.getY());
						main.addChild(c2);
					}
				}
				fire_state = 1;
				break;
			}
		}
		fire_state = 0;	
		
		Statistic.AI_calc_time += getTimer() - start_time;

	}
	
	/**
	 * Достигли WP
	 */
	override protected function onWpFineshed():void {
		var ms:int = move_state;
		super.onWpFineshed();
		//-- еси был поиск незаметной цели
		if (ms == ST_WP_SEARCH_TARGET) {
			//Main.main.getInformer().writeText("WP Search target finished.");
			setRudder(RUDER_LEFT_15);
			setPower(POWER_4);
		} else if (ms == ST_WP_TARGET) {
			//Main.main.getInformer().writeText("WP on target finished.");
		} else if (ms == ST_WP_CONVOY_MOVING) {
			//Main.main.getInformer().writeText("WP on convoy finished.");
			setRudder(RUDER_0);
			setPower(POWER_4);
		}
	}
	
	public function antyTorpManevr(_anty_torp_manevr:Boolean):void {
		anty_torp_manevr = _anty_torp_manevr;
	}
	
	/*
	 * Проверка наличия торпедной атаки
	 * 
	 * Проверяем для всех торпед и выбираем ближайшую.
	 * Возвращает атакующую торпеду.
	 */ 
	protected function checkTrpAtack():Torped {
		//-- выполняем проверку только для тех у кого установлен признак
		if (!anty_torp_manevr) {
			return null;
		}
		//-- для всех вражеских торпед определяем угол направления движения
		//   если меньше определенного то считаем что случилась угроза торпедной атаки
		//   для судна под управлением выводим сигнал
		if (forces == Constants.FORCES_RED) {
			for each( var t:Torped in main.getWhiteTorpeds()) {
				var dist:Number = Point.distance(t.getPosition(), position_gm); 
				if(dist < Settings.TRP_ATACK_DISTANCE_WARNING) {
					var angle:Number = Math.abs(Utils.calcDeltaBattleDeg(t.getPosition(), t.getDirection(), position_gm));
					var a:Number = Settings.TRP_ATACK__ANGLE_WARNING / Settings.TRP_ATACK_DISTANCE_WARNING * dist;
					if (angle < a ) {
						return t;
					}
				}
			}
		} else {
			for each(t in main.getRedTorpeds()) {
				dist = Point.distance(t.getPosition(), position_gm); 
				//main.getInformer().writeDebugRightField("trp at a", angle.toString());
				if(dist < Settings.TRP_ATACK_DISTANCE_WARNING) {
					angle = Math.abs(Utils.calcDeltaBattleDeg(t.getPosition(), t.getDirection(), position_gm));
					a = Settings.TRP_ATACK__ANGLE_WARNING / Settings.TRP_ATACK_DISTANCE_WARNING * dist;
					if (angle < a ) {
						if (under_control) {
							main.startTatcAlarm();
						}
						return t;
					}
				}
			}
			if (under_control) {
				main.stopTatcAlarm();
			}
		}
		return null;
	}
	
	/*
	 * Получает параметры судна и вычисляет дистанцию до него и направление 
	 * Возвращает: VehicleParams.position  - вектор до цели относительно моей позиции
	 *             VehicleParams.direction - направление на цель в градусах
	 */
	/*
	protected function getPositionDirectionTarget(_target:Ship):VehicleParams {
		var rel_p =  _target.position.subtract(position);
		return new VehicleParams(rel_p, velocity, Utils.toBattleDegree(Utils.getAngleRad(_target.position, position)));
	}*/
	
	override public function infoText():void {
		var vel:Number = velocity_gm / Settings.koef_v;
		var s1:Ship = main.getMyShip();
		if(!under_control) {
			if(s1 != null) {
				info.text = ship_name + "(" + health.toFixed(0) + ")" // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
				+ "\n" + Point.distance(s1.position_gm, this.position_gm).toFixed(0) + "," 
					+ Utils.toBattleDegree(Utils.calcAngleRad(s1.position_gm, position_gm)).toFixed(0)
				//+ "\n" + position.x.toFixed(0) + " " + position.y.toFixed(0)	
				+ "\n" + vel.toFixed(0);
			} else {
				info.text = ship_name // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
				+ "\n" + vel.toFixed(0);
			}
		} 	else {
			info.text = ship_name 
			//+ "\n" + position.x.toFixed(0) + "," + position.y.toFixed(0)
			+ "\n" + command_params.power // Point.distance(main.getScenario().getStartPosition(), position).toFixed(0) 
			+ "," + direction_deg.toFixed(0)
			//+ "\n" + x + "," + y
			+ "\n" + vel.toFixed(0);
		}
		
	}
	
	public function setNoHitDamage(_no_hit_damage:Boolean):void {
		no_hit_damage = _no_hit_damage;
	}
	
	public function hasHit(damage:Number):void {
		hit_count++;
		//trace(hit_count);
		
		var snd:SoundExplosion = new SoundExplosion();
		snd.play(1.);
		if (under_control) {
			var snd2:SoundAlarm = new SoundAlarm();
			snd2.play(1.);
		}
		
		if(forces==Constants.FORCES_RED) { 
			Statistic.enemy_hit_count++;
		} else {
			Statistic.friend_hit_count++;
		}
		if(!no_hit_damage) {
			setMaxVelocityHum(getMaxVelocityHum() / Settings.HIT_SHIP_SPEED_DECREASE);
			time_reload_torped_ms *= Settings.HIT_TIME_RELOAD_INCREASE;
			var nn:Number = time_reload_torped_ms / 1000.
			//if(enemy==NOTENEMY)
			//	main.getInformer().setField("FL0", nn.toFixed(0));
			//else
			//	main.getInformer().setField("FL1", nn.toFixed(0));
			health -= damage;
			Main.main.getInformer().writeDebugRightField("damg", health.toFixed(0));
			//if (hit_count >= max_hits) {
			if (health <= 0) {
				trace("I'm die! (" + ship_name + ")");
				main.getInformer().setCommandAlarm("I'm die! (" + ship_name + ")");
				destroy();
				if(forces==Constants.FORCES_RED)
					Statistic.enemy_destroyed++;
				else
					Statistic.friend_destroyed++;
			}
		}
		
	}
	
	//-- true если объект выбран на дисплее
	protected var display_selected:Boolean = false;
	
	override public function drawShip():void {
		var idx:int = main.getChildIndex(this);
		if (idx < 0)
			return;
		graphics.clear();
		if (display_selected) {
			draw_ship_selected();
		} else {
			draw_ship();
		}
	}
	
	override protected function draw_ship_selected():void {
		//if (Settings.DEBUG) {
			//-- круги шумности
			var dist_00:Number =  VehicleMoving.calcNoiseDistanse(noisy, getPower(), .2);
			graphics.lineStyle(2, Constants.COLOR_DARK_RED);
			graphics.drawCircle(0, 0, dist_00*main.getZoom());
			
			dist_00 =  VehicleMoving.calcNoiseDistanse(noisy, getPower(), .5);
			graphics.lineStyle(2, Constants.COLOR_MADIUM_RED);
			graphics.drawCircle(0, 0, dist_00*main.getZoom());
			
			dist_00 =  VehicleMoving.calcNoiseDistanse(noisy, getPower(), .8);
			graphics.lineStyle(2, Constants.COLOR_LIGHT_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
		//}
		
		draw_ship_0();
		//x = main.toDisplayX(position_gm.x);
		//y = main.toDisplayY(position_gm.y);
	}
	
	public function setColor(_color:int):void {
		color = _color;
	}
	

	override protected function draw_ship():void {
		//graphics.clear();
		draw_ship_0();
	}

	protected function draw_ship_0():void {
		if (under_control && this is Sub) {
			draw_ship_sub();
		} else {
			graphics.lineStyle(2, color);
			graphics.moveTo( -4, 4);
			graphics.lineTo( -4, -4);
			graphics.lineTo( 4, -4);
			graphics.lineTo( 4, 4);
			//graphics.moveTo( -4, 4);
			graphics.endFill();

			graphics.beginFill(0x0000FF, 0.5);
			graphics.drawRect( -4, -4, 8, 8);
			graphics.endFill();
		}
	}
	
	protected function draw_ship_sub():void {
		var bh:Number = 14;
		var bw:Number = 3;
		var sh:Number = bw/2.;
		
		var rh:Number = 3.;
		var rw:Number = 1.;
		
		var shift_x:Number = - bw / 2.;
		var shift_y:Number = - (bh + (bw + bw + bw - sh))  / 2.;
		
		//graphics.beginFill(0xffffff);
		//graphics.lineStyle(1, 0xffffff);
		graphics.beginFill(color);
		graphics.lineStyle(1, color);
		graphics.drawRoundRect(0 + shift_x, 0 + shift_y, bw , bh, bw, bw );

		graphics.moveTo( 0 + shift_x, bh - sh + shift_y );
		graphics.lineTo( bw/2. + shift_x, bh + bw + bw + bw - sh + shift_y);
		graphics.lineTo( bw + shift_x, bh - sh + shift_y);
		graphics.moveTo( 0 + shift_x, bh - sh + shift_y);
		graphics.endFill();

		graphics.lineStyle(1, 0x0f0f0f);
		graphics.beginFill(0x0f0f0f);
		graphics.drawEllipse( bw/2.-rw/2.  + shift_x, bh*1/3.-rh/2.   + shift_y, rw, rh);
		graphics.endFill();
	}
	
	/**
	 * Рисует мишени как они видятся с данного судна
	 */
	public function drawTargets():void {
		for each(var trg:Target in targets) {
			trg.ship.setVisible(true);
			
			if (trg.noise >= Settings.NOISE_DETECTION) {
				if(trg.ship.getForces() == Constants.FORCES_RED)
					trg.ship.color = Constants.COLOR_LIGHT_RED;
				else
					trg.ship.color = Constants.COLOR_LIGHT_WHITE;
			} else if (trg.noise >= Settings.NOISE_DIRECTION) {
				if(trg.ship.getForces() == Constants.FORCES_RED)
					trg.ship.color = Constants.COLOR_MADIUM_RED;
				else
					trg.ship.color = Constants.COLOR_MADIUM_WHITE;
				trg.ship.setTailVisible(true);
				trg.ship.info.visible = true;
				if(trg.ship is  Sub) 
					trg.ship.info.text = "SUB";
				else 	
					trg.ship.info.text = "SHIP";
			} else {
				if(trg.ship.getForces() == Constants.FORCES_RED)
					trg.ship.color = Constants.COLOR_DARK_RED;
				else	
					trg.ship.color = Constants.COLOR_DARK_RED;
				trg.ship.visible = true;
				trg.ship.setTailVisible(false);
				trg.ship.info.visible = false;
			}
			trg.ship.new_disp_pos();
			trg.ship.draw_ship();
		}
	}
	
	/**
	 * Launch torpedo в направлении движения судна
	 */
	public function fire(_weapon_select:int):Torped {
		return fire_in_direction(_weapon_select, getDirection());
	}
	
	/*
	 * Запуск торпеды которая пойдет в пункт назначения
	 */ 
	public function fireAtPosition(_weapon_select:int, _way_point:Point):Torped {
		var torp:Torped = fire(_weapon_select);
		if (torp == null)
			return null;
		torp.addWayPoint(_way_point.x, _way_point.y, Constants.WP_TORP);
		torp.startMoveOnWayPoint(/*Constants.WP_TORP*/);
		//torp.setPower(Vehicle.POWER_6);
		return torp;
	}
	
	public function fire_in_direction(_weapon_select:int, dir_deg:Number):Torped {
		//trace("(getTimer() - time_torp_fire"+(getTimer() - time_torp_fire);
		//if(!Settings.CHEAT)
		//	if ((getTimer() - time_torp_fire) < time_reload_torped)
		//		return null;
		if(forces==Constants.FORCES_RED) {
			Statistic.enemy_fire_count++;
			var s:SoundEnemyTorpFire = new SoundEnemyTorpFire();
			s.play(0.3);
		} else {
			var s2:SoundMyTorpFire = new SoundMyTorpFire();
			s2.play(0.7);
			Statistic.friend_fire_count++;
		}
			
		time_torp_fire = getTimer();

		var torp:Torped; 
		if(_weapon_select == Constants.WEAPON_SELECT_TORP_I) {
			torp = new Torped_I(main, forces);
		} else if(_weapon_select == Constants.WEAPON_SELECT_TORP_II) {
			torp = new Torped_II(main, forces);
		} else if(_weapon_select == Constants.WEAPON_SELECT_TORP_III) {
			torp = new Torped_III(main,forces);
		}
		//-- нужно сказать ТА что он пуст и 
		torp.setForces(this.forces); 
		torp.setPosition2(getPosition());
		torp.setDirection(dir_deg);
		torp.set_velocity(torp.getMaxVelocityHum()*Settings.koef_v); // velocity);
		//torp.setName("my torped");
		torp.start_move();
		//main.registerEnemyTorped(torp);
		return torp;
	}

	
	/**
	 * Проверка готовности оружия weapon_type к стрельбе
	 * 
	 * @param	weapon_type - тип оружия
	 * @return    TorpedApp - готовый к стрельбе
	 * 
	 * @overrided  Sub
	 */
	public function isWeaponReady(weapon_type:int):TorpedApp {
		if(!Settings.CHEAT)
			if ((getTimer() - time_torp_fire) > time_reload_torped_ms)
				return default_torp_app;
		return null;		
	}
	
	/*
	 * Размер для попадания торпеды
	 */ 
	public function setSizeForHit(_torpedo_hit_distance:Number):void {
		size_for_hit = _torpedo_hit_distance;
	}
	
	public function getSizeForHit():Number {
		return size_for_hit;
	}
	
	public function getHealth():Number 
	{
		return health;
	}
	
	public function setHealth(value:Number):void 
	{
		health = value;
	}
	

}

}

