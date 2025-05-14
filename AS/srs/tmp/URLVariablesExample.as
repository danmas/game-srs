package srs 
{
    import flash.display.Sprite;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    public class URLVariablesExample extends Sprite {

        public function URLVariablesExample(url:String,scen:String,nm:String,sc:String) {
            //var url:String = "http://srs.zz.mu/test";
            var request:URLRequest = new URLRequest(url);
            var variables:URLVariables = new URLVariables();
            //variables.exampleSessionId = new Date().getTime();
            variables.scenario = scrn;
            variables.name = nm;
			variables.score = sc;
            request.data = variables;
            navigateToURL(request);
        }
    }

}