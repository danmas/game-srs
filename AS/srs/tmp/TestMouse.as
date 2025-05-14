package srs.tmp 
{
	// This code moves display objects using the mouse-following 
	// technique. 
	// circle is a DisplayObject (e.g. a MovieClip or Sprite instance). 
	import flash.events.MouseEvent; 

	/**
	 * ...
	 * @author Erv
	 */
	public class TestMouse 
	{
		
		public function TestMouse() 
		{
			
		}
		
		var offsetX:Number; 
		var offsetY:Number; 
		
		// This function is called when the mouse button is pressed. 
		function startDragging(event:MouseEvent):void { 
			 // Record the difference (offset) between where 
			 // the cursor was when the mouse button was pressed and the x, y 
			 // coordinate of the circle when the mouse button was pressed. 
			 offsetX = event.stageX - circle.x; 
			 offsetY = event.stageY - circle.y; 
			 
			 // tell Flash Player to start listening for the mouseMove event 
			 stage.addEventListener(MouseEvent.MOUSE_MOVE, dragCircle); 
		} 
		
		// This function is called when the mouse button is released. 
		function stopDragging(event:MouseEvent):void { 
			 // Tell Flash Player to stop listening for the mouseMove event. 
			 stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragCircle); 
		} 
		
		// This function is called every time the mouse moves, 
		// as long as the mouse button is pressed down. 
		function dragCircle(event:MouseEvent):void { 
			 // Move the circle to the location of the cursor, maintaining 
			 // the offset between the cursor's location and the 
			 // location of the dragged object. 
			 circle.x = event.stageX - offsetX; 
			 circle.y = event.stageY - offsetY; 
			 // Instruct Flash Player to refresh the screen after this event. 
			 event.updateAfterEvent(); 
		} 
		
		circle.addEventListener(MouseEvent.MOUSE_DOWN, startDragging); 
		circle.addEventListener(MouseEvent.MOUSE_UP, stopDragging);		
	}

}