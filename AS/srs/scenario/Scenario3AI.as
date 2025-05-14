package srs.scenario 
{
	/**
	 * Сценарий для тестирования Автоматическо огня торпедами
	 * ...
	 * @author Erv
	 */
	public class Scenario3AI extends Scenario  {
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.ships.*; // .utils.*;
		import srs.utils.*;
		
		public function Scenario3AI(_main:Main) {
			super(_main,"Scenario3AI");
		}

		override public function init():void {
			START_X = 350;
			START_Y = 350;
			
			setPlayerName("AI");
			
			bonus_time_game_sec = 10000;
			
			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(true);

			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			main.getMyShip().setPower(Vehicle.POWER_0);
			main.getMyShip().setNoHitDamage(true);
			//main.getMyship().setMaxHits(3);
			main.getMyShip().setTimeReloadTorped(5);
			main.getMyShip().setUnderControl(true);
/*			
			//-- задаем движение по программе
			main.my_ship.addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_0, 30));
			main.my_ship.addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_LEFT_15, 30));
			main.my_ship.addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_0, 30));
			main.my_ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_10, 30));
			main.my_ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_0, 15));
			main.my_ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 15));
			main.my_ship.addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_0, 35));
			main.my_ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 15));
			main.my_ship.addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_0, 20));
			main.my_ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 7));
			main.my_ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 35));
			main.my_ship.addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_LEFT_15, 7));
			main.my_ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 35));
			//-- активируем движение по командам, еслу true то комады повторяются
			main.my_ship.setCommandMoveState(false);
*/			
			main.getMyShip().addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_3, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_LEFT_15, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_3, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_RIGHT_5, 30));
			main.getMyShip().setCommandMoveState(false);
			main.getWhiteShips().push(main.getMyShip());

			
			/* Kashin*/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setName("Kashin");
			ship.setPosition(600, 50); 
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_1);
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1500); 
			ship.setEquippedTorpeds(true);
			ship.setTimeReloadTorped(5);
			main.getRedShips().push(ship);
			
			/*
			//-- задаем движение по программе
			ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 7));
			ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 7));
			ship.addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_RIGHT_15, 7));
			ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 7));
			//-- активируем движение по командам, еслу true то комады повторяются
			ship.setCommandMoveState(true);
			*/
			
			/**/
			genCoastData();
			genObstruction();
			genPortGate();
		}
		
		override public function checkGameOver():int {
			var ret:int = super.checkGameOver() ;
			if (ret != GAME_CONTINUE) {
				return ret;
			}
			if (main.getMyShip().isEndMoveCommand()) {
				return MISSION_SUCCESS;
			}
			return GAME_CONTINUE;
		}

		override public function gameOver(_success:int):void {
			super.gameOver(_success);
			
			//var tl:uint = 0;
			//if(main.getMyship()!=null)
			//	tl = main.getMyship().getTimeLife() / 1000.;
			
			var s:String = "GAME OVER. You score: "+score+ " ";
			s += success;
			comment = "Time: " + Statistic.time_game_sec + " sec."
			+ "\nAI time        : " + Statistic.AI_calc_time
			+ "\n"
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
			showMissionGoal(this.name+"  "+ "AI Test Mission:",
			"\n\n" 
				+"\n"
				+"\nS - start/stop"
				+"\nZ - zoom increase"
				+"\nX - zoom decreese"
				+"\nC - center on my ship"
				+"\nLeft mouse button+mose move - shift the screen"
				+"\n\nESC - exit"
				,Settings.CURRENT_SRS
			);
		}
		
		//override public function showTopList():void {
		//	super.showTopListFromFile();
		//}
	}

}