package  srs.ships
{
	import srs.*;
	import srs.scenario.*;
	import srs.sounds.*;
	import srs.utils.*;
	import srs.ships.Sub;
	
	import flash.filters.GlowFilter;

	
	public class MyShip extends Sub {
	
		 
	public function MyShip(_main:Main) {
		super(_main,Constants.FORCES_WHITE);
		setForces(Constants.FORCES_WHITE);
		//filters = [new GlowFilter(0xffffff, 0.6, 10, 10)];
	}
	
	/*
	override public function destroy():void {
		super.destroy();
		main.stop();
		main.my_ship = null;
	}*/
	
	
	//override public function torpedoHit():void {
	//	main.getInformer().setCommand("TORPEDO HIT!");	
	//}

}
}