package srs.tmp 
{
	/**
	 * ...
	 * @author Erv
	 */
	public class NavigateToURLExample 
	{
		import flash.display.Sprite;
		import flash.net.navigateToURL;
		import flash.net.URLRequest;
		import flash.net.URLVariables;

		public class NavigateToURLExample extends Sprite {

			public function NavigateToURLExample() {
				var url:String = "http://www.adobe.com";
				var variables:URLVariables = new URLVariables();
				variables.exampleSessionId = new Date().getTime();
				variables.exampleUserLabel = "Your Name";
				var request:URLRequest = new URLRequest(url);
				request.data = variables;
				try {            
					navigateToURL(request);
				}
				catch (e:Error) {
					// handle error here
				}
			}
		}
	}

}