package  srs
{
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * Класс Препятствие
	 * имеет виртуальные размеры для быстрой проверки попадания
	 * 
	 * @author Erv
	 */
	public class Obstruction extends Sprite {

		protected var position:Point;
		protected var _width;
		protected var _height;
		
		var main:Main;
			
		public function Obstruction(_main:Main) {
			main = _main; 
		}
		
		public function setPosition(p_x:Number, p_y:Number,p_w:Number,p_h:Number) {
			position = new Point(p_x, p_y);
			_width = p_w;
			_height = p_h;
			this.x = main.toDisplayX(p_x);
			this.y = main.toDisplayY(p_y); 
			this.width = p_w;
			this.height = p_h;
		}

		public function zoom():void {
			this.x = main.toDisplayX(position.x);
			this.width = main.zoom * _width;
			if (this.width < 1) this.width = 1;
			this.y = main.toDisplayY(position.y); 
			trace(this.height); 
			this.height = main.zoom * _height;
			trace(" "+this.height); 
			if ( this.height < 1 ) this.height = 1;
		}
		
	}

}