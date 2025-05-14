package srs.scenario 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class ScenarioTest   extends Scenario  {
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.ships.*; // .utils.*;
		import srs.utils.*;
		
		public function ScenarioTest(_main:Main) {
			super(_main,"ScenarioTest");
		}

		override public function init():void {
			START_X = 350;
			START_Y = 350;
			
			setPlayerName("TEST");
			
			//Main.getRedStore().setCurParams_I("Type I");
			Main.getRedStore().setCurParams_II(WeaponTypes.WT_TYPE_IIA_R); // "Type IIa (R)");
			Main.getRedStore().setCurParams_III(WeaponTypes.WT_TYPE_IIIA_R);// "Type IIIa (R)");
			
			Main.getWhiteStore().setCurParams_II(WeaponTypes.WT_TYPE_IIA_W); // "Type IIa (W)");
			Main.getWhiteStore().setCurParams_III(WeaponTypes.WT_TYPE_IIIA_W);// "Type IIIa (W)");
			
			bonus_time_game_sec = 10000;
			
			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(true);

			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(90);
			main.getMyShip().setPower(Vehicle.POWER_0);
			main.getMyShip().setNoHitDamage(false);
			main.getMyShip().setHealth(1500);
			main.getMyShip().setManevr(100);
			main.getMyShip().setNoHitDamage(true);
			//main.getMyship().setEquippedTorpeds(true);
			main.getMyShip().setUnderControl(true);
			main.getMyShip().setNoisy(0.5);
			main.getWhiteShips().push(main.getMyShip());
			
			
			//main.getMyship().id = "debug";
			/*
			//-- задаем движение по программе
			main.my_ship.addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_0, 30));
			main.my_ship.addCommand(new Command(Vehicle.POWER_6, Vehicle.RUDER_LEFT_15, 30));
			//-- активируем движение по командам, еслу true то комады повторяются
			main.my_ship.setCommandMoveState(false);
			*/
			
			/* Kashin*/
			/**/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setName("Kashin");
			ship.setPosition(START_X+500, START_Y);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_3);
			ship.setMaxVelocityHum(15);
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1000);
			ship.setEquippedTorpeds(true);
			ship.setTimeReloadTorped(10);
			ship.moveOnTarget(true);
			main.getRedShips().push(ship);
			
			
			//-- переключение управления на 
			/**/
			main.getMyShip().setPower(Vehicle.POWER_4);
			main.getMyShip().setEquippedTorpeds(true);
			main.getMyShip().setUnderControl(false);
			main.getMyShip().setTimeReloadTorped(10);
			main.getMyShip().drawShip();
			main.getMyShip().moveOnTarget(true);
			
			ship.setUnderControl(true);
			main.setMyShip(ship);
			/**/
			
			/**/
			
			/* Alpha
			var sub:Sub = new Sub(main,Constants.FORCES_RED);
			sub.setName("Alpha");
			sub.setPosition(START_X+300, START_Y-100);
			sub.setDirection(250);
			sub.setPower(Vehicle.POWER_2);
			sub.setMaxVelocityHum(30);
			sub.setNoisy(0.5);
			sub.setEnemy(Constants.FORCES_RED);
			sub.setHealth(1000);
			sub.setEquippedTorpeds(true);
			sub.setTimeReloadTorped(10);
			sub.moveOnTarget(true);
			main.getRedShips().push(sub);
			*/
			
			/* Kashin
			var ship:Ship = new Ship(main,Constants.RED);
			ship.setName("Kashin-2");
			ship.setPosition(600, +110);
			ship.setDirection(250);
			ship.setPower(Vehicle.POWER_1);
			ship.setEnemy(Constants.ENEMY);
			ship.setMaxHits(1);
			ship.setEquippedTorpeds(true);
			ship.setTimeReloadTorped(10);
			ship.searchTarget(true);
			ship.setAntyTorpManevr(false);
			main.getEnemyShips().push(ship);
			*/

			//-- указываем пункт назначения
			//ship.setWayPoint(START_X + 300, START_Y);
			//ship.setMoveOnWayPoint();
			
			//-- задаем движение по программе
			//ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 7));
			//ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 7));
			//ship.addCommand(new Command(Vehicle.POWER_1, Vehicle.RUDER_RIGHT_15, 7));
			//ship.addCommand(new Command(Vehicle.POWER_5, Vehicle.RUDER_0, 7));
			//-- активируем движение по командам, еслу true то комады повторяются
			//ship.setCommandMoveState(true);
			
			/**/
			genCoastData();
			genObstruction();
			genPortGate();
		}
		
		override public function checkGameOver():int {
			/*var ret:int = super.checkGameOver() ;
			if (ret != GAME_CONTINUE) {
				return ret;
			}
			if (main.getMyship().getMoveState() == Vehicle.ST_END_COMMAND_MOVING) {
				return MISSION_SUCCESS;
			}*/
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
		
		//override public function showTopList():void {
		//	super.showTopListFromFile();
		//}
	}

}