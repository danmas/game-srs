package srs.scenario 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class Scenario4  extends Scenario {
		
		import flash.display.Sprite;
		import flash.geom.Point;
		
		import srs.*;
		import srs.utils.*;
		import srs.ships.*;
		
		public function Scenario4(_main:Main,sc:String="Scenario4") {
			super(_main, sc /*"Scenario4"*/);
			score_name = Settings.SCENARIO_SCORE_NAME;
		}
		
		override public function init():void {
			super.init();
			
			START_X = 350;
			START_Y = 350;
			
			Main.getRedStore().setCurParams_II(WeaponTypes.WT_TYPE_IIA_R); 
			Main.getRedStore().setCurParams_III(WeaponTypes.WT_TYPE_IIIA_R);
			
			Main.getWhiteStore().setCurParams_II(WeaponTypes.WT_TYPE_IA_W); 
			Main.getWhiteStore().setCurParams_II(WeaponTypes.WT_TYPE_IIA_W); 
			Main.getWhiteStore().setCurParams_III(WeaponTypes.WT_TYPE_IIIA_W);
			
			bonus_time_game_sec = 10000;

			main.setMyShip(new Sub(main, Constants.FORCES_WHITE));
			main.getMyShip().setColor(Constants.COLOR_WHITE);
			main.getMyShip().setUnderControl(false);
			
			main.getMyShip().setName("L.A.");
			main.getMyShip().setPosition(START_X, START_Y);
			main.getMyShip().setDirection(Math.random()*360.);
			main.getMyShip().setHealth(1500); 
			main.getMyShip().setManevr(60);
			//main.getMyship().setTimeReloadTorped(10);
			main.getMyShip().setUnderControl(true);
			main.getMyShip().setNoisy(0.3);
			main.getMyShip().setHealth(2000);
			//main.my_ship.setNoHitDamage(true);
			main.getWhiteShips().push(main.getMyShip());
			
			var gp:Point = Point.polar(1000, Math.random() * 360.);
			var gp_dir:Number = Math.random() * 360.; 
			/* Kashin*/
			var ship:Ship = new Ship(main,Constants.FORCES_RED);
			ship.setName("Kashin");
			ship.setPosition(gp.x + 200, gp.y + 110);
			ship.setDirection(gp_dir);
			ship.setPower(Vehicle.POWER_4);
			ship.setMaxVelocityHum(25);
			ship.setForces(Constants.FORCES_RED);
			ship.setHealth(1500);
			ship.setTimeReloadTorped(20);
			ship.setEquippedTorpeds(true);
			ship.setManevr(80);
			ship.moveOnTarget(true);
			ship.setFollowConvoy(250, 270);
			main.getRedShips().push(ship);
			// Krivak
			ship = new Ship(main,Constants.FORCES_RED);
			ship.setName("Krivak");
			ship.setPosition(gp.x-200, gp.x-150);
			ship.setDirection(gp_dir);
			ship.setMaxVelocityHum(29);
			ship.setPower(Vehicle.POWER_4);
			ship.setHealth(1000);
			ship.setForces(Constants.FORCES_RED);
			ship.setEquippedTorpeds(true);
			ship.setTimeReloadTorped(40);
			ship.moveOnTarget(true);
			ship.setManevr(80);
			ship.setFollowConvoy(150, 30);
			main.getRedShips().push(ship);
			
			/* Victor*/
			var sub:Sub = new Sub(main,Constants.FORCES_RED);
			sub.setName("Victor");
			sub.setUnderControl(false);
			sub.setPosition(START_X+300, START_Y-100);
			sub.setDirection(250);
			sub.setPower(Vehicle.POWER_2);
			sub.setMaxVelocityHum(15);
			sub.setNoisy(0.4);
			sub.setForces(Constants.FORCES_RED);
			sub.setHealth(1000);
			sub.setEquippedTorpeds(true);
			sub.setTimeReloadTorped(50);
			sub.setFollowConvoy(50, 30);
			sub.moveOnTarget(true);
			main.getRedShips().push(sub);
			
			/*
			//-- переключение управления на Viktor
			main.getMyShip().setPower(Vehicle.POWER_4);
			main.getMyShip().setEquippedTorpeds(true);
			main.getMyShip().setUnderControl(false);
			main.getMyShip().drawShip();
			main.getMyShip().moveOnTarget(true);

			sub.setUnderControl(true);
			main.setMyShip(sub);
			*/
			
			/**/
			/* Dubna*/
			ship = new Ship(main,Constants.FORCES_RED);
			ship.setName("Dubna");
			ship.setPosition(gp.x-100, gp.y+110);
			ship.setDirection(gp_dir);
			ship.setPower(Vehicle.POWER_5);
			ship.setForces(Constants.FORCES_RED);
			ship.setMaxVelocityHum(20);
			//ship.setMaxHits(5);
			ship.setManevr(50);
			ship.setConvoy(true);
			ship.setHealth(3000);
			ship.setNoisy(5.);
			main.getRedShips().push(ship);
			/**/
			//-- задаем движение по программе
			ship.addCommand(new Command(Vehicle.POWER_3, Vehicle.RUDER_0, 120));
			ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 5));
			ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 40));
			ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_LEFT_15, 10));
			ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 40));
			ship.addCommand(new Command(Vehicle.POWER_2, Vehicle.RUDER_RIGHT_15, 10));
			ship.addCommand(new Command(Vehicle.POWER_4, Vehicle.RUDER_0, 120));
			//-- активируем движение по командам, еслу true то комады повторяются
			ship.setCommandMoveState(true);
			
			genCoastData();
			genObstruction();
			genPortGate();
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
			+ "\nEnemy sink       : " + Statistic.enemy_destroyed
			+ "\nFriend sink        : " + Statistic.friend_destroyed
			+ "\nAI time             : " + Statistic.AI_calc_time
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
		
	}

}