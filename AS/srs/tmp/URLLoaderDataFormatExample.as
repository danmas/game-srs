package srs.tmp 
{
		
	import flash.display.Sprite; 
    import flash.events.*; 
    import flash.net.URLLoader; 
    import flash.net.URLLoaderDataFormat; 
    import flash.net.URLRequest; 
 
    public class URLLoaderDataFormatExample extends Sprite 
    { 
        public function URLLoaderDataFormatExample() { 
            var request:URLRequest = new URLRequest("http://srs.zz.mu/test/params.txt"); 
            var variables:URLLoader = new URLLoader(); 
            variables.dataFormat = URLLoaderDataFormat.VARIABLES; 
            variables.addEventListener(Event.COMPLETE, completeHandler); 
            try { 
                variables.load(request); 
            }  
            catch (error:Error) { 
                trace("Unable to load URL: " + error); 
            } 
        } 
		
        private function completeHandler(event:Event):void { 
			var loader:URLLoader = URLLoader(event.target); 
			trace(loader.data.dayNames); 
        } 
    } 

}