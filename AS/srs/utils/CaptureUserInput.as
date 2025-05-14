package srs.utils 
{
	
	import flash.display.Sprite; 
    import flash.display.Stage; 
	import flash.geom.Rectangle;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
    import flash.events.*; 

	import srs.*;
	
    public class CaptureUserInput extends Sprite  { 
        private var label:TextField = new TextField(); 
		
        private var myTextBox:TextField = new TextField(); 
        private var myOutputBox:TextField = new TextField(); 
        private var myText:String = ""; 
		private	var format1:TextFormat = new TextFormat(); 
 
		private var main:Main;
		
        public function CaptureUserInput(_main:Main) {
			main = _main;
			trace('captureText');
            captureText(); 
        } 
		
		public function setFocus():void {
			main.stage.focus = myTextBox;
		}
         
		public function getText():String {
			return myTextBox.text;
		}
		
		private const LBL_WIDTH:int = 200;
		private const TXT_WIDTH:int = 200;
		private const HEIGHT:int = 22;
		private const SHIFT:int = 20;
		
        private function captureText():void   { 
			
			graphics.beginFill(0x00FFFF, 1.);
			var rect_w:int = SHIFT + LBL_WIDTH + TXT_WIDTH + SHIFT;
			var rect_h:int = SHIFT + HEIGHT + SHIFT;
			var rect_x:int = -1 * (SHIFT + LBL_WIDTH + TXT_WIDTH + SHIFT) / 2;
			var rect_y:int = -1 * (SHIFT + HEIGHT + SHIFT) / 2;
			this.graphics.drawRoundRect(rect_x, rect_y, rect_w, rect_h, SHIFT, SHIFT);
			graphics.endFill();
			
			format1.color = 0xFFFFFF; 
 			format1.font = "Courier"; 
			format1.bold = true;
			format1.size = 20;
			format1.align = "left";
			
			label.setTextFormat(format1);
			label.defaultTextFormat = format1;
            label.background = true;
			label.backgroundColor = 0x000080;
			label.border = true;
			label.borderColor = 0xFFFFFF;
			label.height = HEIGHT;
			label.width = LBL_WIDTH;
			label.multiline = false;
			
			myTextBox.setTextFormat(format1);
			myTextBox.defaultTextFormat = format1;
			
            myTextBox.type = TextFieldType.INPUT; 
            myTextBox.background = true;
			myTextBox.backgroundColor = 0x000080;
			myTextBox.border = true;
			myTextBox.borderColor = 0xFFFFFF;
			myTextBox.height = HEIGHT;
			myTextBox.width = TXT_WIDTH;
			myTextBox.multiline = false;
			
            addChild(myTextBox); 
            addChild(label); 

            myTextBox.text = myText; 
			main.stage.focus = myTextBox;

			label.x = rect_x + (rect_w - (LBL_WIDTH + TXT_WIDTH)) / 2;
			label.y = rect_y + (rect_h - (HEIGHT)) / 2;
			
			myTextBox.x =  label.x + label.width;
			myTextBox.y = label.y;
			
			label.text = "Enter you name:";
			
            //myTextBox.addEventListener(TextEvent.TEXT_INPUT, textInputCapture); 
        } 

		/*
        public function textInputCapture(event:TextEvent):void  { 
            var str:String = myTextBox.text; 
            createOutputBox(str); 
        } 
             
        public function createOutputBox(str:String):void  { 
            myOutputBox.background = true; 
            myOutputBox.x = 200; 
            addChild(myOutputBox); 
            myOutputBox.text = str; 
        }*/ 
         
    } 

}