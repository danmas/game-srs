package srs.scenario 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Scenario3 	extends Scenario  {
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.utils.*;
		import srs.ships.*;
		
		public function Scenario3(_main:Main) {
			super(_main,"Scenario3");
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
			//main.getMyship().setVelocity(10. * Constants.koef_v);
			main.getMyShip().setPower(Vehicle.POWER_0);
			main.getMyShip().setHealth(1500);
			main.getMyShip().setTimeReloadTorped(5);
			main.getMyShip().setUnderControl(true);
			main.getWhiteShips().push(main.getMyShip());
			
			//main.s1.setPosition(400, 200);
			//main.s1.setDirection(0);
			
			/* Kashin*/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			
			var sp:Point = Point.polar(200, Utils.toScreenRad(Math.random() * 360.));
			var pp:Point = new Point(START_X, START_Y).add(sp);
			ship.setPosition2(pp);
			ship.setDirection(Math.random() * 360.);
			ship.setPower(Vehicle.POWER_2);
			ship.setName("Kashin");
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1500);
			ship.setTimeReloadTorped(10);
			ship.setEquippedTorpeds(true);
			main.getRedShips().push(ship);
			
			/**/
			genCoastData();
			genObstruction();
			genPortGate();
		}

		override public function gameOver(_success:int):void {
			super.gameOver(_success);
			
			//var tl:uint = 0;
			//if(main.getMyship()!=null)
			//	tl = main.getMyship().getTimeLife() / 1000.;
			
			var s:String = "GAME OVER. You score: "+score+ " ";
			s += success;
			comment = "Time: " + Statistic.time_game_sec + " sec."
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
				+"\n\nESC - exit"
				,Settings.CURRENT_SRS
			);
		}
		
		//override public function showTopList():void {
		//	super.showTopListFromFile();
		//}
	}

}