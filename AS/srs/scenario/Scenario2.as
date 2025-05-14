package  srs.scenario
{
	/**
	 * ...
	 * @author ...
	 */
	public class Scenario2  extends Scenario
	{
		
		import flash.display.Sprite;
		import flash.geom.Point;
	
		import srs.*;
		import srs.utils.*;
		import srs.ships.*;
		
		
		public function Scenario2(_main:Main) {
			super(_main,"Scenario2");
		}
		
		override public function init():void {
			super.init();
			
			START_X = 350;
			START_Y = 350;
			
			bonus_time_game_sec = 10000;

			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(true);

			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			main.getMyShip().setHealth(1500);
			main.getMyShip().setUnderControl(true);
			main.getWhiteShips().push(main.getMyShip());
			
			
			/* Kashin*/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setPosition(1000-200, -100+110);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_3);
			ship.setName("Kashin");
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1500);
			ship.setTimeReloadTorped(15);
			ship.setEquippedTorpeds(false);
			main.getRedShips().push(ship);
			/**/
			/* Krivak*/
			ship = new Ship(main,Constants.FORCES_RED);
			ship.setPosition(1000-200, -150+110);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_3);
			ship.setName("Krivak");
			ship.setHealth(1000);
			ship.setForces(Constants.FORCES_RED);
			ship.setEquippedTorpeds(false);
			ship.setTimeReloadTorped(30);
			main.getRedShips().push(ship);
			/**/
			/* Dubna*/
			ship = new Ship(main,Constants.FORCES_RED);
			ship.setPosition(1050-200, -100+110);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_3);
			ship.setName("Dubna");
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1000);
			main.getRedShips().push(ship);
			/**/
			
			genCoastData();
			genObstruction();
			genPortGate();
			
			init_after();
		}

		
		override public function gameOver(_success:int):void {
			super.gameOver(_success);
			
			var s:String = "GAME OVER. You score: "+score+ " ";
			s += success;
			comment = 				"Time: " + Statistic.time_game_sec + " sec."
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
			showMissionGoal(this.name+"  "+ "Your Mission:",
			"\n\n" +
				"Destroy the all enemy ships."
				+"\n"
				+"\nS - start"
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
				+"\nESC - exit"
				,Settings.CURRENT_SRS
			);
		}
		
	}

}