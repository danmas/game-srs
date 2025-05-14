package srs.scenario 
{
	
	import srs.*;
	import srs.utils.*;
	import srs.ships.*;

	/**
	 * ...
	 * @author Erv
	 */
	public class Scenario4MULT extends Scenario
	{
		
		public function Scenario4MULT(_main:Main) {
			super(_main, "Scenario4MULT");
			score_name = Settings.SCENARIO_SCORE_NAME;
		}
		
		override public function init():void {
			super.init();
			
			START_X = 350;
			START_Y = 350;
			
			bonus_time_game_sec = 60000;

			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(true);

			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			main.getMyShip().setHealth(1500);
			main.getMyShip().setManevr(90);
			main.getMyShip().setTimeReloadTorped(5);
			main.getMyShip().setUnderControl(true);
			main.getWhiteShips().push(main.getMyShip());
			
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setPosition(1000- Math.random()*200, 110+Math.random()*200);
			ship.setDirection(250+Math.random()*10);
			ship.setPower(Vehicle.POWER_4);
			ship.setName("Kashin");
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1500);
			ship.setTimeReloadTorped(15);
			ship.setEquippedTorpeds(true);
			ship.moveOnTarget(true);
			ship.setManevr(90);
			main.getRedShips().push(ship);
			
			for (var i:int = 0; i < 200; i++) {
				ship = new Ship(main,Constants.FORCES_RED);
				ship.setPosition(1000- Math.random()*200, 110+Math.random()*200);
				ship.setDirection(250+Math.random()*10);
				ship.setPower(Vehicle.POWER_3);
				ship.setName("Kashin_"+i);
				ship.setForces(Constants.FORCES_RED);
				ship.setHealth(900);
				ship.setTimeReloadTorped(30. + Math.random()* 15.);
				ship.setEquippedTorpeds(true);
				ship.moveOnTarget(true);
				ship.setAntyTorpManevr(true);
				ship.setManevr(50);
				main.getRedShips().push(ship);
				//-- задаем движение по программе
				ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 100));
				ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 15));
				ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 7));
				ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 15));
				ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 17));
				ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 15));
				ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 7));
				ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 15));
				//-- активируем движение по командам, еслу true то комады повторяются
				ship.setCommandMoveState(true);
			}
		}
		override public function gameOver(_success:int):void {
			super.gameOver(_success);
			
			var s:String = "GAME OVER. You score: "+score+ " ";
			s += success;
			comment = 	"Time: " + Statistic.time_game_sec + " sec."
			+ "\nI fire torp    : " + Statistic.friend_fire_count
			+ "\nEnemy fire torp: " + Statistic.enemy_fire_count
			+ "\nEnemy has hits : " + Statistic.enemy_hit_count
			+ "\nEnemy hits me  : " + Statistic.friend_hit_count
			+ "\nEnemy sink     : " + Statistic.enemy_destroyed
			+ "\nFriend sink      : " + Statistic.friend_destroyed
			+ "\nAI time           : " + Statistic.AI_calc_time
			+ "\n\nSCORE: " + score
			;

			showGameOver(s,
			"\n\n" + comment, 
			"Press any key"
			);
		}
		
		override public function showMissinGoal():void {
			main.stop();
			showMissionGoal(this.name+"  "+ "Your Mission:",
			"\n\n" +
				"Destroy all enemy ships."
				+"\n"
				+"\nS - start/stop"
				+"\nUp - increase power"
				+"\nDown - decreese power"
				+"\nLeft - rudder left"
				+"\nRight - rudder right"
				+"\nSpace - fire torped"
				+"\nZ - scale increase"
				+"\nX - scale decreese"
				+"\nC - center on my ship"
				+"\nLeft mouse button+mose move - shift the screen"
				+"\nF11 - enter your name"
				+"\n4 - select way point(WP) for torped and fire"
				+"\nW - select way point(WP) for ship"
				+"\nESC - exit"
				,Settings.CURRENT_SRS
			);
		}
		
	}

}