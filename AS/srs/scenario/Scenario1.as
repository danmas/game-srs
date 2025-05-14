package  srs.scenario
{
	/**
	 * ...
	 * @author ...
	 */
	public class Scenario1  extends Scenario
	{
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.utils.*;
		import srs.ships.*;
		
	
		//-- при успешно выполненной миссии бонус за время выхода из порта 
		//   = max_time_leave_port_sec / (время выхода игры)
		protected var max_time_leave_port_sec:int = 1000; 

		public function Scenario1(_main:Main) {
			super(_main,"Scenario1");
		}
		
		override public function init():void {
			super.init();
			
			START_X = 350;
			START_Y = 350;
			
			bonus_time_game_sec = 5000;
			max_time_leave_port_sec = 1000; 
			
			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(true);
			
			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			main.getMyShip().setPosition(40, 20);
			main.getMyShip().setUnderControl(true);
			main.getWhiteShips().push(main.getMyShip());
			
			/* Kashin*/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setPosition(1000, -100);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_3);
			ship.setName("Kashin");
			ship.setHealth(1000);
			ship.setForces(Constants.FORCES_RED);
			main.getRedShips().push(ship);
			/**/
			
			genCoastData();
			genObstruction();
			genPortGate();
			
			init_after();
		}

		
		/*
		 * Пересчитывает и возвращает счет
		 */ 
		override public function calcScore(_success:int):int {
			
			score = super.calcScore(_success);
			
			if (_success == MISSION_SUCCESS && Statistic.time_leave_port_sec != 0) {
				score += max_time_leave_port_sec / Statistic.time_leave_port_sec;
			}
			return score;
		}

		
		/*
		 * Generate coast data
		 */
		override protected function genCoastData():void {
			coast_data = new Array();
			port_line_data = new Array();
			
			coast_data.push(new Point(0, 0)); 
			coast_data.push(new Point(0,2));
			coast_data.push(new Point( 7,2));
			coast_data.push(new Point( 14,10));
			coast_data.push(new Point( 18,10));
			coast_data.push(new Point( 18,6 ));
			coast_data.push(new Point( 20,6));
			coast_data.push(new Point( 20,10));
			coast_data.push(new Point( 27, 10));
			coast_data.push(new Point( 29, 3));
			coast_data.push(new Point( 26, -3  ));
			coast_data.push(new Point( 17 ,-10  ));
			coast_data.push(new Point( 14 ,-10  ));
			coast_data.push(new Point( 14 ,-7  ));
			coast_data.push(new Point( 12 ,-6  ));
			coast_data.push(new Point(11,-10));
			coast_data.push(new Point( 6 ,-8  ));
			coast_data.push(new Point( 5 , -9  ));
			
			coast_data.push(new Point( 10 , -12  ));
			coast_data.push(new Point( 18 , -13 ));
			coast_data.push(new Point( 27 ,-8 ));
			coast_data.push(new Point( 34 , -1 ));
			coast_data.push(new Point( 32 , 14 ));
			coast_data.push(new Point( -2,14));
			coast_data.push(new Point( -4,5 ));
			coast_data.push(new Point( -3, -2));
			
			coast_data.push(new Point( 3, -8));
			port_line_data.push(new Point( 3, -8));
			coast_data.push(new Point( 4, -7));
			port_line_data.push(new Point( 4, -7));
			
			port_line_data.push(new Point( 6, -8));
			port_line_data.push(new Point( 5, -9));
			
			coast_data.push(new Point( 1, -2));
			coast_data.push(new Point( 7,-2));
			coast_data.push(new Point( 10,-5 ));
			coast_data.push(new Point( 24,-1 ));
			coast_data.push(new Point( 24, 7));
			coast_data.push(new Point( 22, 7));
			coast_data.push(new Point( 22, 3 ));
			coast_data.push(new Point( 16, 3));
			coast_data.push(new Point( 16, 6));
			coast_data.push(new Point( 14, 6));
			coast_data.push(new Point( 14, 3 ));
			coast_data.push(new Point( 11, 3 ));
			coast_data.push(new Point( 6, 0));
			coast_data.push(new Point( 0,0));
		}		
			
		/*
		 * Generate coast profile.
		 */
		override public function genObstruction():void {
			/**/
			if (obstruction != null) {
				main.removeChild(obstruction);
				obstruction = null;
			}
			obstruction = new Sprite();
			obstruction.graphics.beginFill(0xCD853F);
			obstruction.graphics.lineStyle(2, 0xffffff);
			obstruction.graphics.moveTo( main.getZoom()*(coast_data[0].x * Settings.koef_coast)
				, main.getZoom() * (coast_data[0].y * Settings.koef_coast));
				
			for ( var i:int = 1; i < coast_data.length; i++) {
				obstruction.graphics.lineTo(main.getZoom()*(coast_data[i].x * Settings.koef_coast)
				, main.getZoom()*(coast_data[i].y * Settings.koef_coast));
			}
			obstruction.graphics.endFill();
			
			obstruction.x = main.toDisplayX(START_X-10);
			obstruction.y = main.toDisplayY(START_Y-10);

			main.addChild(obstruction);
			main.moveToBack(obstruction);
			/**/
			scale();
		}
			
		
		override public function genPortGate():void {
			if (port_gate != null) {
				main.removeChild(port_gate);
				port_gate = null;
			}
			port_gate = new Sprite();
			port_gate.graphics.beginFill(0x0000ff);
			//port_line.graphics.lineStyle(2, 0xff0000);
			port_gate.alpha = 0;
			port_gate.graphics.moveTo( main.getZoom()*(port_line_data[0].x * Settings.koef_coast)
				, main.getZoom() * (port_line_data[0].y * Settings.koef_coast));
				
			for ( var i:int = 1; i < port_line_data.length; i++) {
				port_gate.graphics.lineTo(main.getZoom()*(port_line_data[i].x * Settings.koef_coast)
				, main.getZoom()*(port_line_data[i].y * Settings.koef_coast));
			}
			port_gate.graphics.endFill();
			
			port_gate.x = main.toDisplayX(START_X-10);
			port_gate.y = main.toDisplayY(START_Y-10);

			main.addChild(port_gate);
			main.moveToBack(port_gate);
			
			scale();
		}
		
		override public function gameOver(_success:int):void {
			super.gameOver(_success);
			
			var s:String = "GAME OVER. You score: "+score+ " ";
			s += success;

			comment = 				"Time: " + Statistic.time_game_sec + " sec."
			+ "\n\nLeft port      : " + Statistic.time_leave_port_sec + " sec."
			+ "\nI fire torp    : " + Statistic.friend_fire_count
			+ "\nEnemy fire torp: " + Statistic.enemy_fire_count
			+ "\nEnemy has hits : " + Statistic.enemy_hit_count
			+ "\nEnemy hits me  : " + Statistic.friend_hit_count
			+ "\nEnemy sink     : " + Statistic.enemy_destroyed
			+ "\nFriend sink    : " + Statistic.friend_destroyed
			+ "\n\nSCORE: " + score
			;
			showGameOver(s,
			"\n\n" + comment,
			"Press any key"
			);
		}
		
		override public function showMissinGoal():void {
			main.stop();
			var tl:uint = main.getMyShip().getTimeLiveMs() / 1000.;
			showMissionGoal(this.name+"  "+ "Your Mission:",
			"\n\n" +
				"Leave the port as soon as possible and"
				+"\n destroy the enemy ship."
				+"\n"
				+"\nS - start"
				+"\nUp - increase power"
				+"\nDown - decreese power"
				+"\nLeft - rudder left"
				+"\nRight - rudder right"
				+"\nSpace - fire torped"
				+"\nZ - zoom increase"
				+"\nX - zoom decreese"
				+"\nLeft mouse button+mose move - shift the screen"
				//+"\nC - center on my ship"
				+"\nESC - exit"
				,Settings.CURRENT_SRS
			);
		}
		
	}

}