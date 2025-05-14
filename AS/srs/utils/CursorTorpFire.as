package srs.utils 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class CursorTorpFire extends Sprite {
		
		public function CursorTorpFire() {
			graphics.lineStyle(1, 0xFFFFFF);
			graphics.moveTo(0, -5);
			graphics.lineTo(0, 5);
			
			graphics.moveTo(-5, 0);
			graphics.lineTo(5, 0);
		}
		
	}

}