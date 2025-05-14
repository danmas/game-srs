
//-- Класс Ship

	
	//-- упоминание о DrakonGen
	   /**
	    * Этот текст сгенерирован программой DrakonGen
	    * @author Erv
	    */
	
	//-- package
	//-- imports
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
	
	//-- class Ship
	   /**
	    * ...
	    * @author Erv
	    */
	public class Ship extends Vehicle {
	
	
	//-- константы
	static protected const  MANEVR_UNKNOWN:int = 0;
	static protected const  MANEVR_STING:int = 1;
	//-- переменные
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
	protected var situation_mem:String = "";
	
	protected var torp_params_I:TorpedParams;
	protected var torp_params_II:TorpedParams;
	protected var torp_params_III:TorpedParams;
	
	protected var torp_on_board_I:int = 5;
	protected var torp_on_board_II:int = 5;
	protected var torp_on_board_III:int = 5;
	
	protected var manevr_state:int = MANEVR_UNKNOWN;
	//-- Ship()
		public function Ship(_main:Main,_enemy:int) { 
		//-- тело процедуры
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
		
		//-- мы за белых?
		if(forces == Constants.FORCES_WHITE) {
			//-- получаем параметры оружия типа I,II и III
			torp_params_I = Main.getWhiteStore().getParams_I();
			torp_params_II = Main.getWhiteStore().getParams_II();
			torp_params_III = Main.getWhiteStore().getParams_III();
			
		} else {
			//-- получаем параметры оружия типа I,II и III
			torp_params_I = Main.getRedStore().getParams_I();
			torp_params_II = Main.getRedStore().getParams_II();
			torp_params_III = Main.getRedStore().getParams_III();
			
		}
		//-- выход
		
		
	} //-- конец процедуры
	//-- AI_step_I()
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
		
		//-- ищем цель, оцениваем ситуацию
		target = selectTarget();
		//-- ручное управление?
		if(under_control) {
			//-- выход
		} else {
			//-- получаем угрожающую торпеду
			var t:Torped = checkTrpAtack();
			
			//-- 
			//--       сообщение для выбранного move_state
			//-- MOVE_STATE
			//--       
			if (display_selected) {
						Main.main.getInformer().writeDebugRightField("MOVE STATE",move_state.toFixed(0));
			}
			
			//-- состояние УКЛОНЕНИЕ ОТ ТОРПЕДЫ?
			if(move_state == ST_WP_TORP_DEFENCE_MOVING) {
				//-- есть угрожающая торпеда?
				if(t != null) {
					//-- выполняем противоторпедный маневр
					antyTorpManevr(t);
					//-- выход
				} else {
					//-- стираем WP и перкращаем движение к ним
					stopMoveOnWayPoint();
					
					//-- двигаться на цель?
					if(move_on_target) {
						//-- нашли цель?
						if(target != null) {
							//-- двигаемся на цель
							st_wp_move_on_target();
							
						} else {
							//-- устанавливаем WP на запомненное положение угрожающей торпеды
							addWayPoint(param_t_before_atack.position.x, param_t_before_atack.position.y
							, Constants.WP_TARGET_SEARCH);
							//-- начинаем движение к точке
							startMoveOnWP();
							//-- двигаемся с максимальной скоростью
							setPower(POWER_6);
							//-- очищаем запомненное место пуска торпеды
							param_t_before_atack = null;
							//-- состояние движения = ПОИСК ЦЕЛИ
							move_state = ST_WP_SEARCH_TARGET;
						}
					} else {
						//-- были команды?
						if(commands != null) {
							//-- устанавливаем запомненное направление
							setDirection(param_before_atack.direction);
							//-- продолжаем движение по командам
							continueCommandMove();
							//-- стираем запомненное состояние
							param_before_atack = null;
							//-- состояние движения = ДВИЖЕНИЕ ПО КОМАНДАМ
							move_state = ST_COMMAND_MOVING;
						} else {
							//-- состояние движения = НЕИЗВЕСТНО
							move_state = ST_MOVE_UNKNOWN;
						}
					}
				}
			} else {
				//-- есть угрожающая торпеда?
				if(t != null) {
					//-- были команды?
					if(commands != null) {
						//-- запоминаем прежний курс чтобы вернуться
						param_before_atack =  new VehicleParams(position_gm, velocity_gm, direction_deg);
					} else {
					}
					//-- запоминаем параметры торпеды
					param_t_before_atack =  new VehicleParams(t.getPosition(), t.getVelocity(), t.getDirection());
					//-- убираем предыдущий маршрут
					stopMoveOnWayPoint();
					//-- выполняем противоторпедный маневр
					antyTorpManevr(t);
					//-- состояние движения = УКЛОНЕНИЕ ОТ ТОРПЕДЫ
					move_state = ST_WP_TORP_DEFENCE_MOVING;
				} else {
					//-- маневр УКОЛ?
					if(manevr_state == MANEVR_STING) {
						//-- 
						//--       выполняем маневр УКОЛ
						//--       
						manevrStick();
					} else {
						//-- состояние ДВИЖЕНИЕ НА ЦЕЛЬ
						//-- или ПОИСК ЦЕЛИ?
						if(move_state == ST_WP_SEARCH_TARGET ||
						move_state == 
						ST_WP_TARGET) {
							//-- нашли цель?
							if(target != null) {
								//-- двигаемся на цель
								st_wp_move_on_target();
								
							} else {
							}
//-- ПРЕДУПРЕЖДЕНИЕ!   Терминатор развилки "нашли цель?" имеет 2 выходов. Должен быть один. 
						} else {
							//-- двигаться на цель?
							if(move_on_target) {
								//-- нашли цель?
								if(target != null) {
									//-- двигаемся на цель
									st_wp_move_on_target();
									
								} else {
									//-- нужно конвоировать?
									if(folow_convoy) {
										//-- выбираем конвоируемое судно
										var c:Ship = selectConvoy();
										//-- нашли подконвойного?
										if(c != null) {
											//-- были старые WP?
											if(way_points != null) {
												//-- стираем WP и перкращаем движение к ним
												stopMoveOnWayPoint();
												
											} else {
											}
											//-- устанавливаем WP точку конвоя
											var p:Point = c.getPosition()		.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
											addWayPoint(p.x, p.y, Constants.WP_CONVOY);
											
											//-- двигаемся с максимальной скоростью
											setPower(POWER_6);
											//-- начинаем движение к точке конвоя
											startMoveOnWP();
											//-- состояние движения = ДВИЖЕНИЕ В КОНВОЕ
											move_state = ST_WP_CONVOY_MOVING;
										} else {
											//-- состояние движения = НЕИЗВЕСТНО
											move_state = ST_MOVE_UNKNOWN;
										}
									} else {
										//-- состояние движения = НЕИЗВЕСТНО
										move_state = ST_MOVE_UNKNOWN;
									}
								}
							} else {
								//-- нужно конвоировать?
								if(folow_convoy) {
									//-- выбираем конвоируемое судно
									var c:Ship = selectConvoy();
									//-- нашли подконвойного?
									if(c != null) {
										//-- были старые WP?
										if(way_points != null) {
											//-- стираем WP и перкращаем движение к ним
											stopMoveOnWayPoint();
											
										} else {
										}
										//-- устанавливаем WP точку конвоя
										var p:Point = c.getPosition()		.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
										addWayPoint(p.x, p.y, Constants.WP_CONVOY);
										
										//-- двигаемся с максимальной скоростью
										setPower(POWER_6);
										//-- начинаем движение к точке конвоя
										startMoveOnWP();
										//-- состояние движения = ДВИЖЕНИЕ В КОНВОЕ
										move_state = ST_WP_CONVOY_MOVING;
									} else {
										//-- состояние движения = НЕИЗВЕСТНО
										move_state = ST_MOVE_UNKNOWN;
									}
								} else {
									//-- состояние движения = НЕИЗВЕСТНО
									move_state = ST_MOVE_UNKNOWN;
								}
							}
						}
//-- ПРЕДУПРЕЖДЕНИЕ!   Терминатор развилки "состояние ДВИЖЕНИЕ НА ЦЕЛЬ
						//-- или ПОИСК ЦЕЛИ?" имеет 2 выходов. Должен быть один. 
					}
				}
				//-- выход
			}
		}
	} //-- конец процедуры
	//-- st_wp_move_on_target()
	protected function st_wp_move_on_target():void { 
		//-- цель есть?
		if(target != null) {
			//-- обновляем данные цели
			for each(var t:Target in targets) {
				if (t.ship == target.ship) {
				target.noise = t.noise;
				break;
				}
			}
			//-- были старые WP?
			if(way_points != null) {
				//-- стираем WP и перкращаем движение к ним
				stopMoveOnWayPoint();
				
			} else {
			}
			//-- устанавливаем WP на цель
			addWayPoint(target.ship.position_gm.x, target.ship.position_gm.y, Constants.WP_TARGET);
			//-- двигаемся с максимальной скоростью
			setPower(POWER_6);
			//-- начинаем движение к WP
			startMoveOnWP();
			//-- цель достаточно шумная?
			if(target.noise >= Settings.NOISE_DIRECTION) {
				//-- стреляем
				AI_torped_fire();
			} else {
			}
			//-- состояние движения = ДВИЖЕНИЕ НА ЦЕЛЬ
			move_state = ST_WP_TARGET;
			//-- выход
							return;
			
		} else {
			//-- состояние движения = НЕИЗВЕСТНО
			move_state = ST_MOVE_UNKNOWN;
			//-- выход
							return;
			
		}
//-- ПРЕДУПРЕЖДЕНИЕ!   Терминатор развилки "цель есть?" имеет 0 выходов. Должен быть один. 
	} //-- конец процедуры
	//-- AI_torped_fire()
				/**
			 * 
			 * Выбор торпеды
			 * Рассчет точки выстрела для прямолинейно движущихся торпед.
			 * Можно улучшить алгоритм повысив точность за счет второго цикла итераций
			 * 
			 */
			public function AI_torped_fire():void {
 
		//-- локальные переменные
		var _getMaxTimeLifeSec:Number;		
		var _getMaxVelocity:Number;
		var _getWeaponType:int;
		var fire_state: int = 0; 
		var cur_torp_app:TorpedApp;
		//-- торпеды перезаряжены?
		if(isTorpedReady()
		) {
			//-- цель есть?
			if(target != null) {
				//-- корабль цели  есть?
				if(target.ship != null) {
					//-- время запуска = getTimer()
					var start_time:int = getTimer();
					//-- выбираем оружие для цели
					var torp_params:TorpedParams =  AI_select_weapon(target.ship);
					_getWeaponType = torp_params.weapon_type;
					//-- оружие типа I?
					if(_getWeaponType == Constants.WEAPON_SELECT_TORP_I) {
						//-- текущий аппарат оружия типа I
						cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_I);
					} else {
						//-- оружие типа II?
						if(_getWeaponType == Constants.WEAPON_SELECT_TORP_II) {
							//-- текущий аппарат оружия типа II
							cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_II);
						} else {
							//-- оружие типа III?
							if(_getWeaponType == Constants.WEAPON_SELECT_TORP_III) {
								//-- текущий аппарат оружия типа III
								cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_III);
							} else {
								//-- текущий аппарат оружия не выбран
								cur_torp_app = null;
							}
						}
					}
					//-- текущий аппарат готов?
					if(cur_torp_app != null) {
						//-- берем максимальную скорость и время жизни для выбранного оружия
						_getMaxTimeLifeSec = torp_params.max_time_life_sec;
								_getMaxVelocity = torp_params.max_velocity_hum;
						//-- остаток тела
								
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
											var torp:Torped; 
											if (_getWeaponType == Constants.WEAPON_SELECT_TORP_II) 						{ 
												torp = fireAtPosition(_getWeaponType, 	target_position2);
											} else {
												torp = fire(_getWeaponType);
											}
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
						
					} else {
					}
				} else {
				}
			} else {
			}
		} else {
		}
		//-- выход
		return;
	} //-- конец процедуры
	//-- выбор цели сейчас возвращается самая громкая
	/**
			 * Выбор цели на которую начинаем охоту
			 * сейчас возвращается самая громкая
			 * 
			 * overrided для Ship и Torpedo 
			 */ 
			override public function selectTarget():Target { 
		//-- определяем перемнные
		var ret_trg:Target;
		var ns:Number = 0;
		//-- для всех целей
		for each(var trg:Target in targets)  {
			//-- выбираем самую громкую цель
			if(ns == 0) {
				ns = trg.noise;	
				ret_trg = trg;
			} else if (trg.noise > ns) {
				ret_trg = trg;
				ns = trg.noise;
			}
		}
		//-- выбрана цель?
		if(ret_trg != null) {
			//-- ситуация задана?
			if(situation != null) {
			} else {
				//-- задаем ситуцию 1х1
				situation = new Situation1x1(this,ret_trg.ship);
			}
			//-- оцениваем ситуацию
			situation.detectSituation();
			//-- получаем код ситуации
			var si:String = situation.getCode();
			//-- ситуация изменилась?
			if(situation_mem != si) {
				//-- сообщение для выбранного "Ситуация"
				if (display_selected) {
					var s:String = "Situation:" + this.getName() +  situation.getCode()
					Main.main.getInformer().writeText(s);
					trace(s);
				}
				
				//-- запоминиаем ситуацию
				situation_mem = si;
			} else {
			}
			//-- возвр. цель
			return ret_trg;
		} else {
		}
		//-- возвр. цель
		return ret_trg;
	} //-- конец процедуры
	//-- antyTorpManevr()
	protected function antyTorpManevr(t:Torped):void { 
		//-- определяем дистанцию до угрожающей Т
		var dist:Number = Point.distance(position_gm, t.getPosition());
		//-- торпеда далеко?
		if(dist > Settings.TRP_ATACK_ALARM_DIST) {
			//-- угол уклонения TRP_ATACK_DEFENSE_ANGLE
			var angle = Settings.TRP_ATACK_DEFENSE_ANGLE;
			
			//-- Неподвижен?
			if(getPower() == POWER_0) {
				//-- 
				//--       двигаемся с тихой скоростью
				//--       
				setPower(POWER_1);
			} else {
			}
		} else {
			//-- угол уклонения 
			//-- 90
			var angle = 90; 
			//-- 
			//--       двигаемся с максимальной скоростью
			//--       
			setPower(POWER_6);
		}
		//-- стираем WP и перкращаем движение к ним
		stopMoveOnWayPoint();
		
		//-- вырабатываем точку уклонения пока не выйдем из атаки
		//-- в какую сторону поворачивать выбираем случайно
		var p:Point;
		//-- в какую сторону поворачивать выбираем случайно
		if(Math.random()>0.5)
			p = Point.polar(100., Utils.toScreenRad(direction_deg + angle)); 
		else 
			p = Point.polar(100., Utils.toScreenRad(direction_deg - angle)); 
		var p2:Point = position_gm.add(p);
		//-- устанавливаем WP на точку уклонения
		addWayPoint(p2.x, p2.y, Constants.WP_TORP_DEFENCE);
		//-- начинаем движение к точке уклонения
		startMoveOnWP();
		//-- выход
			
	} //-- конец процедуры
	//-- AI_select_weapon()
				/**
			 * Выбор оружия по параметрам цели и степени его готовности
			 */ 
			protected function AI_select_weapon(_target:Ship):TorpedParams {
 
		//-- задаем переменные
		var torp_params:TorpedParams;
		var dist_max_III:Number;
		
		
		//-- определяем дистанцию до цели
		var dist:Number = Point.distance(position_gm, _target.getPosition());
		//-- рассчитываем дистанцию стрельбы для оружия III
		dist_max_III = torp_params_III.dist_execution;
		//dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;
		
		//-- для типа III далеко?
		if(dist > dist_max_III) {
			//-- 
			//--       сообщение для выбранного "Выбрано оружие I"
			//--       
			if (display_selected) {
				Main.main.getInformer().writeDebugText("Выбрано оружие I");
			}
			
			//-- текущие параметры - тип I
			torp_params = torp_params_I;
		} else {
			//-- 
			//--       сообщение для выбранного "Выбрано оружие III"
			//--       
			if (display_selected) {
				Main.main.getInformer().writeDebugText("Выбрано оружие III");
			}
			
			//-- текущие параметры - тип III
			torp_params = torp_params_III;
		}
		//-- возвр. выбранные параметры
		return torp_params;
	} //-- конец процедуры
	//-- onWpFineshed()
				/**
			 * Достигли WP
			 */
			override protected function onWpFineshed():void {
 
		//-- курс прямо
		//-- прекратить движение на МТ
		super.onWpFineshed();
		//-- маневр ПОИСК ЦЕЛИ?
		if(move_state == ST_WP_SEARCH_TARGET) {
			//-- руль лево 15
			setRudder(RUDER_LEFT_15);
			//-- скорость 4
			setPower(POWER_4);
		} else {
			//-- маневр ДВИЖЕНИЕ НА ЦЕЛЬ?
			if(move_state == ST_WP_TARGET) {
			} else {
				//-- маневр ДВИЖЕНИЕ В КОНВОЕ?
				if(move_state == ST_WP_CONVOY_MOVING) {
					//-- руль прямо
					setRudder(RUDER_0);
					//-- скорость 4
					setPower(POWER_4);
				} else {
				}
			}
		}
	} //-- конец процедуры
	//-- isTorpedReady()
	/*
			 */ 
			protected function isTorpedReady():Boolean {
 
		//-- просто проверяем прошло ли положенное время с момента последнего выстрела
		return (getTimer() - time_torp_fire) > 
		time_reload_torped_ms  + Math.random() * time_reload_torped_ms/2.;
		//-- выход
		
		
	} //-- конец процедуры
	//-- fire_in_direction()
	public function fire_in_direction(_weapon_select:int, dir_deg:Number):Torped {
 
		//-- тело процедуры
		if (forces == Constants.FORCES_RED) {
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
		if (_weapon_select == Constants.WEAPON_SELECT_TORP_I) {
			torp = new Torped_I(main, forces);
			torp_on_board_I--;
		} else if (_weapon_select == Constants.WEAPON_SELECT_TORP_II) {
			torp = new Torped_II(main, forces);
			torp_on_board_II--;
		} else if (_weapon_select == Constants.WEAPON_SELECT_TORP_III) {
			torp = new Torped_III(main, forces);
			torp_on_board_III--;
		}
		torp.setForces(this.forces);
		torp.setPosition2(getPosition());
		torp.setDirection(dir_deg);
		torp.set_velocity(torp.getMaxVelocityHum() * Settings.koef_v); // velocity);
		//torp.setName("my torped");
		torp.start_move();
		//main.registerEnemyTorped(torp);
		
		//-- возвр. торпеду
		return torp;
		
	} //-- конец процедуры
	//-- checkTrpAtack()
				/*
			 * Проверка наличия торпедной атаки
			 * 
			 * Проверяем для всех торпед и выбираем ближайшую.
			 * Возвращает атакующую торпеду.
			 */ 
			protected function checkTrpAtack():Torped {
 
		//-- тело процедуры
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
		//-- выход
						return null;
		
	} //-- конец процедуры
	//-- manevrStick()
	/*
 * Маневр УКОЛ
 */ 
protected function manevrStick():void  {
 
		//-- тело процедуры
		//-- переопределить в дочерних классах
		//-- выход
	} //-- конец процедуры
	//-- Выход
		//-- тело процедуры
		/**
		 * Выбор направления движения на следующем шаге
		 */
		override public function AI_step_II():void
		{
			super.AI_step_II();
		}
		
		/**
		 * Делает текущим управляемым объектом данный корабль
		 */
		public function underControl(event:MouseEvent):void
		{
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
		public function selectOnDisplay(event:MouseEvent):void
		{
			//trace(event.currentTarget.toString() + " dispatches MouseEvent. Local coords [" + 
			//event.localX + "," + event.localY + "] Stage coords [" + event.stageX + "," + event.stageY + "]"); 
			
			if (display_selected)
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
		public function onSlowLoop(time:int):void
		{
		}
		
		/**
		 *
		 */
		public function getStore():Store
		{
			return store;
		}
		
		/**
		 * Выбор судна конвоя
		 *
		 * overrided для Ship
		 */
		public function selectConvoy():Ship
		{
			//-- для того который под ручным управление не выбираем цель
			if (under_control)
			{
				return null;
			}
			////-- пока исходим из того, что я один ))
			if (forces == Constants.FORCES_RED)
			{
				for each (var s:Ship in Main.main.getRedShips())
				{
					if (s.isConvoy())
					{
						return s;
					}
				}
			}
			else
			{
				for each (var s:Ship in Main.main.getWhiteShips())
				{
					if (s.isConvoy())
					{
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
		public function setFollowConvoy(_folow_convoy_dist:Number, _folow_convoy_angle:Number):void
		{
			folow_convoy = true; // folow_convoy;
			folow_convoy_angle = _folow_convoy_angle;
			folow_convoy_dist = _folow_convoy_dist;
		}
		
		public function setConvoy(_convoy:Boolean):void
		{
			convoy = _convoy;
		}
		
		public function isConvoy():Boolean
		{
			return convoy;
		}
		
		protected function addTarget(_ship:Ship, _noise:Number):void
		{
			var trg:Target;
			for each (trg in targets)
			{
				if (trg.ship == _ship)
				{
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
		public function calcNoiseAtDist(dist:Number):Number
		{
			return VehicleMoving.calcNoise(noisy, getPower(), dist);
		}
		
		/**
		 * Заполняет список мишеней
		 */
		public function fillAllTarget():void
		{
			//-- чистим список мишеней
			targets.splice(0);
			if (forces == Constants.FORCES_RED)
			{
				for each (var s:Ship in Main.main.getWhiteShips())
				{
					var dist:Number = Point.distance(position_gm, s.position_gm);
					//-- вычисляем шум цели
					var ns:Number = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
					//main.getInformer().writeDebugRightField("my noise", ns.toFixed(3));
					//-- если разрешение по шуму > NOISE_TRAKCING_RANGE
					if (ns >= Settings.NOISE_TRAKCING_RANGE)
					{
						addTarget(s, ns);
					}
				}
			}
			else
			{
				for each (var s:Ship in Main.main.getRedShips())
				{
					dist = Point.distance(position_gm, s.position_gm);
					//-- вычисляем шум цели
					ns = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
					//-- берем в обработку только превышающие порог NOISE_TRAKCING_RANGE
					if (ns >= Settings.NOISE_TRAKCING_RANGE)
					{
						addTarget(s, ns);
					}
				}
				main.getInformer().writeDebugRightField("detect", targets.length.toFixed(0));
			}
		}
		
		/**
		 * Возвращает строку насколько данный корабль видит res_ship
		 *
		 * @param	res_ship
		 */
		public function getResolvStr(res_ship:Ship):String
		{
			for each (var trg:Target in targets)
			{
				if (trg.ship == res_ship)
				{
					return "" + trg.noise.toFixed(3);
				}
			}
			return "0";
		}
		
		/*
		 * Установка признака того, что корабль ведет стрельбу торпедами
		 */
		public function setEquippedTorpeds(eq_torp:Boolean):void
		{
			equipped_torpeds = eq_torp;
		}
		
		public function setTimeReloadTorped(t_sec:Number):void
		{
			time_reload_torped_ms = t_sec * 1000;
		}
		
		public function getTimeReloadTorpSec():Number
		{
			return time_reload_torped_ms / 1000;
		}
		
		/*
		 * Получает параметры судна и вычисляет дистанцию до него и направление
		 * Возвращает: VehicleParams.position  - вектор до цели относительно моей позиции
		 *             VehicleParams.direction - направление на цель в градусах
		 */ /*
		   protected function getPositionDirectionTarget(_target:Ship):VehicleParams {
		   var rel_p =  _target.position.subtract(position);
		   return new VehicleParams(rel_p, velocity, Utils.toBattleDegree(Utils.getAngleRad(_target.position, position)));
		 }*/
		
		override public function infoText():void
		{
			var vel:Number = velocity_gm / Settings.koef_v;
			var s1:Ship = main.getMyShip();
			if (!under_control)
			{
				if (s1 != null)
				{
					info.text = ship_name + "(" + health.toFixed(0) + ")" // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
						+ "\n" + Point.distance(s1.position_gm, this.position_gm).toFixed(0) + "," + Utils.toBattleDegree(Utils.calcAngleRad(s1.position_gm, position_gm)).toFixed(0) 
						//+ "\n" + position.x.toFixed(0) + " " + position.y.toFixed(0)	
						+ "\n" + vel.toFixed(0);
				}
				else
				{
					info.text = ship_name // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
						+ "\n" + vel.toFixed(0);
				}
			}
			else
			{
				info.text = ship_name 
					//+ "\n" + position.x.toFixed(0) + "," + position.y.toFixed(0)
					+ "\n" + command_params.power // Point.distance(main.getScenario().getStartPosition(), position).toFixed(0) 
					+ "," + direction_deg.toFixed(0) 
					//+ "\n" + x + "," + y
					+ "\n" + vel.toFixed(0);
			}
		
		}
		
		public function setNoHitDamage(_no_hit_damage:Boolean):void
		{
			no_hit_damage = _no_hit_damage;
		}
		
		public function hasHit(damage:Number):void
		{
			hit_count++;
			//trace(hit_count);
			
			var snd:SoundExplosion = new SoundExplosion();
			snd.play(1.);
			if (under_control)
			{
				var snd2:SoundAlarm = new SoundAlarm();
				snd2.play(1.);
			}
			
			if (forces == Constants.FORCES_RED)
			{
				Statistic.enemy_hit_count++;
			}
			else
			{
				Statistic.friend_hit_count++;
			}
			if (!no_hit_damage)
			{
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
				if (health <= 0)
				{
					trace("I'm die! (" + ship_name + ")");
					main.getInformer().setCommandAlarm("I'm die! (" + ship_name + ")");
					destroy();
					if (forces == Constants.FORCES_RED)
						Statistic.enemy_destroyed++;
					else
						Statistic.friend_destroyed++;
				}
			}
		
		}
		
		//-- true если объект выбран на дисплее
		protected var display_selected:Boolean = false;
		
		override public function drawShip():void
		{
			var idx:int = main.getChildIndex(this);
			if (idx < 0)
				return;
			graphics.clear();
			if (display_selected)
			{
				draw_ship_selected();
			}
			else
			{
				draw_ship();
			}
		}
		
		override protected function draw_ship_selected():void
		{
			//if (Settings.DEBUG) {
			//-- круги шумности
			var dist_00:Number = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .2);
			graphics.lineStyle(2, Constants.COLOR_DARK_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			
			dist_00 = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .5);
			graphics.lineStyle(2, Constants.COLOR_MADIUM_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			
			dist_00 = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .8);
			graphics.lineStyle(2, Constants.COLOR_LIGHT_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			//}
			
			draw_ship_0();
			//x = main.toDisplayX(position_gm.x);
			//y = main.toDisplayY(position_gm.y);
		}
		
		public function setColor(_color:int):void
		{
			color = _color;
		}
		
		override protected function draw_ship():void
		{
			//graphics.clear();
			draw_ship_0();
		}
		
		protected function draw_ship_0():void
		{
			if (under_control && this is Sub)
			{
				draw_ship_sub();
			}
			else
			{
				graphics.lineStyle(2, color);
				graphics.moveTo(-4, 4);
				graphics.lineTo(-4, -4);
				graphics.lineTo(4, -4);
				graphics.lineTo(4, 4);
				//graphics.moveTo( -4, 4);
				graphics.endFill();
				
				graphics.beginFill(0x0000FF, 0.5);
				graphics.drawRect(-4, -4, 8, 8);
				graphics.endFill();
			}
		}
		
		protected function draw_ship_sub():void
		{
			var bh:Number = 14;
			var bw:Number = 3;
			var sh:Number = bw / 2.;
			
			var rh:Number = 3.;
			var rw:Number = 1.;
			
			var shift_x:Number = -bw / 2.;
			var shift_y:Number = -(bh + (bw + bw + bw - sh)) / 2.;
			
			//graphics.beginFill(0xffffff);
			//graphics.lineStyle(1, 0xffffff);
			graphics.beginFill(color);
			graphics.lineStyle(1, color);
			graphics.drawRoundRect(0 + shift_x, 0 + shift_y, bw, bh, bw, bw);
			
			graphics.moveTo(0 + shift_x, bh - sh + shift_y);
			graphics.lineTo(bw / 2. + shift_x, bh + bw + bw + bw - sh + shift_y);
			graphics.lineTo(bw + shift_x, bh - sh + shift_y);
			graphics.moveTo(0 + shift_x, bh - sh + shift_y);
			graphics.endFill();
			
			graphics.lineStyle(1, 0x0f0f0f);
			graphics.beginFill(0x0f0f0f);
			graphics.drawEllipse(bw / 2. - rw / 2. + shift_x, bh * 1 / 3. - rh / 2. + shift_y, rw, rh);
			graphics.endFill();
		}
		
		/**
		 * Рисует мишени как они видятся с данного судна
		 */
		public function drawTargets():void
		{
			for each (var trg:Target in targets)
			{
				trg.ship.setVisible(true);
				
				if (trg.noise >= Settings.NOISE_DETECTION)
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
						trg.ship.color = Constants.COLOR_LIGHT_RED;
					else
						trg.ship.color = Constants.COLOR_LIGHT_WHITE;
				}
				else if (trg.noise >= Settings.NOISE_DIRECTION)
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
						trg.ship.color = Constants.COLOR_MADIUM_RED;
					else
						trg.ship.color = Constants.COLOR_MADIUM_WHITE;
					trg.ship.setTailVisible(true);
					trg.ship.info.visible = true;
					if (trg.ship is Sub)
						trg.ship.info.text = "SUB";
					else
						trg.ship.info.text = "SHIP";
				}
				else
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
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
		public function fire(_weapon_select:int):Torped
		{
			return fire_in_direction(_weapon_select, getDirection());
		}
		
		/*
		 * Запуск торпеды которая пойдет в пункт назначения
		 */
		public function fireAtPosition(_weapon_select:int, _way_point:Point):Torped
		{
			var torp:Torped = fire(_weapon_select);
			if (torp == null)
				return null;
			torp.addWayPoint(_way_point.x, _way_point.y, Constants.WP_TORP);
			torp.startMoveOnWayPoint(); //.startMoveOnWayPoint( /*Constants.WP_TORP*/);
			//torp.setPower(Vehicle.POWER_6);
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
		public function isWeaponReady(weapon_type:int):TorpedApp
		{
			if (!Settings.CHEAT)
				if ((getTimer() - time_torp_fire) > time_reload_torped_ms)
					return default_torp_app;
			return null;
		}
		
		/*
		 * Размер для попадания торпеды
		 */
		public function setSizeForHit(_torpedo_hit_distance:Number):void
		{
			size_for_hit = _torpedo_hit_distance;
		}
		
		public function getSizeForHit():Number
		{
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
				public function getTorpOnBoard(wt:int):int {
					switch(wt) {
						case Constants.WEAPON_SELECT_TORP_I:
							return torp_on_board_I;
						case Constants.WEAPON_SELECT_TORP_II:
							return torp_on_board_II;
						case Constants.WEAPON_SELECT_TORP_III:
							return torp_on_board_III;
					}
					return 0;
				}
		
		//-- setDispalySelected()
		public function setDispalySelected(ds:Boolean) {
		display_selected = ds;
		}
			
		
		//-- showTarget()
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
			for each (trg in targets) {
				if (trg.ship == cur_ship_target) {
					break;
				}
			}
		}
		if (trg == null) 	{
			trg = targets[0];
			cur_ship_target = trg.ship;
		}
		main.getInformer().writeRightField("tgt name", cur_ship_target.getName());
		main.getInformer().writeRightField("tgt noise", trg.noise.toFixed(3));
		main.getInformer().writeRightField("tgt resolv", cur_ship_target.getResolvStr(this));
		}
		//-- setAntyTorpManevr()
		public function setAntyTorpManevr(_anty_torp_manevr:Boolean):void {
			anty_torp_manevr = _anty_torp_manevr;
		}
		
		//-- конец
		   } //-- конец класса
		} //-- крнец пакета
