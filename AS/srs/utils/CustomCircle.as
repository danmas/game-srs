package srs.utils 
{
import flash.display.*; 

	public class CustomCircle extends Shape { 
		protected var xPos:Number; 
		protected var yPos:Number; 
		protected var radius:Number; 
		protected var color:uint; 
		 
		public function CustomCircle(xInput:Number, yInput:Number, rInput:Number, colorInput:uint) { 
			xPos = xInput; 
			yPos = yInput; 
			radius = rInput; 
			color = colorInput; 
			this.graphics.beginFill(color); 
			this.graphics.drawCircle(0, 0, radius); 
			this.alpha = 1;
		} 
		
		public function draw():void {
			
		}
		
		public function getX():Number {
			return xPos;
		}
		
		public function getY():Number {
			return yPos;
		}
		
	}
}