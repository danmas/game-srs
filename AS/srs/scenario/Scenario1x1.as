package srs.scenario 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class Scenario1x1 extends Scenario
	{
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.utils.*;
		import srs.ships.*;
		
		public function Scenario1x1(_main:Main) {
			super(_main,"Scenario1x1");
		}

		override public function init():void {
			super.init();
			
			START_X = 350;
			START_Y = 350;
			
			bonus_time_game_sec = 10000;
			
			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);

			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			//main.getMyship().setVelocity(10. * Constants.koef_v);
			main.getMyShip().setPower(Vehicle.POWER_0);
			main.getMyShip().setHealth(1500);
			main.getMyShip().setNoisy(0.5);
			main.getMyShip().setTimeReloadTorped(50);
			main.getMyShip().setUnderControl(true);
			main.getWhiteShips().push(main.getMyShip());
			
			//main.getMyShip().setUnderControl(true);

			/* Victor*/
			var sub:Sub = new Sub(main,Constants.FORCES_RED);
			sub.setName("Victor");
			sub.setUnderControl(false);
			sub.setPosition(START_X+-1000 +Math.random()*2000.,  -1000 +Math.random()*2000.);
			sub.setDirection(250);
			sub.setPower(Vehicle.POWER_2);
			sub.setMaxVelocityHum(15);
			sub.setNoisy(0.4);
			sub.setForces(Constants.FORCES_RED);
			sub.setHealth(1500);
			sub.setEquippedTorpeds(true);
			sub.setTimeReloadTorped(50);
			//sub.setFollowConvoy(50, 30);
			sub.moveOnTarget(true);
			main.getRedShips().push(sub);
			//sub.setDispalySelected(true);
			
			var deg:Number =  Utils.calcAngleBattleDeg(main.getMyShip().getPosition() , sub.getPosition());
			main.getInformer().setCommandAlarm("Slow noises at "+ deg.toFixed(0) + ", Sir!");
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
				"Destroy enemy sub."
				+"\n"
				+"\nS - start/stop"
				+"\nUp/Down  - increase power/decreese power"
				+"\nLeft/Right - rudder left/right"
				+"\nW - select way point(WP) for ship"
				+"\nZ/X/C - scale increase/scale decreese/center on my ship"
				+"\nLeft mouse button+mose move - shift the screen"
				+"\nF11 - enter your name"
				+"\n1 - fire Torp I "
				+"\n2 - fire Torp II"
				+"\n3 - fire Torp III"
				+"\nESC - exit"
				+ "\n" + makeResume()
				,Settings.CURRENT_SRS
			);
		}
		
		//override public function showTopList():void {
		//	super.showTopListFromFile();
		//}
	}

}