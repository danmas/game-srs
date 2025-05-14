package srs.tmp 
{
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.text.TextField;

class Button extends Sprite {
	private var txt:TextField;
	private var w, h;
	

	public function Button() {
		useHandCursor = true;
		buttonMode = true;
		mouseChildren = false;

		txt = new TextField();
		//this.addChild(txt);
		txt.text = "xxx";
		
		addEventListener(MouseEvent.ROLL_OVER, buttonRollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, buttonRollOutHandler);
	}

	public function getTextField():TextField {
		return txt;
	}
		
	public function setParams(p_x,p_y,p_w,p_h,p_text) {
		x = p_x;
		y = p_y;
		w = p_w;
		h = p_h;
		txt.text = p_text;
		
		useHandCursor = true;
		buttonMode = true;
		mouseChildren = false;
	}
	
	public function setText(p_text) {
		txt.text = p_text;
	}
	
	
	public function setButtonColor(color):void {
		graphics.beginFill(color);
		graphics.drawRect(x,y,w,h);
		graphics.endFill();
	}		
	
	private function buttonRollOverHandler(event:MouseEvent):void {
		trace("Button roll over!");
		turnButtonRed();
	}

	private function buttonRollOutHandler(event:MouseEvent):void {
		trace("Button roll out!");
		turnButtonYellow();
	}
 
	private function turnButtonRed():void {
		graphics.beginFill(0xFF0000);
		graphics.drawRect(x,y,w,h);
		graphics.endFill();
	}
 
	private function turnButtonYellow():void
	{
		graphics.beginFill(0xFFCC00);
		graphics.drawRect(x,y,w,h);
		graphics.endFill();
	}
	 
	private function turnButtonGreen():void
	{
		graphics.beginFill(0x008000);
		graphics.drawRect(x,y,w,h);
		graphics.endFill();
	}
	
}

}