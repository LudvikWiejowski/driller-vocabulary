package audio
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.controls.Alert;
	import mx.core.Application;

	[Event(name="mp3Created", type="flash.events.Event")]
	[Event(name="mp3Error", type="flash.events.Event")]
	public class Mp3File extends Sprite
	{
		//private var proxy:String=Application.application.myProxy;
		//private var proxy:String="http://www.driller-vocabulary.com/proxy.php";
		//private var proxy:String="http://driller.luwi.net/proxy.php";
		private var tmpBytes:ByteArray = new ByteArray();
		private var file:File;
		private var EN:String;
		private var lang:String;
		
		public function Mp3File(file:File,EN:String,lang:String)
		{
			this.file=file;
			this.EN=EN;
			this.lang=lang;
			
			getPronunciation();
		}
		private function getPronunciation():void{
			var req:URLRequest=new URLRequest("http://translate.google.com/translate_tts");//proxy
			var reqHeader:URLRequestHeader=new URLRequestHeader("Referer","http://translate.google.com/");
//			var reqHeader2:URLRequestHeader=new URLRequestHeader("User-Agent","Chrome/50.0.2661.75");
//			var reqHeader3:URLRequestHeader=new URLRequestHeader("X-Client-Data","CLO1yQEIirbJAQijtskBCMS2yQEIlpLKAQj9lcoBCO6cygE=");
//			var reqHeader4:URLRequestHeader=new URLRequestHeader("Accept","text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");
//			var reqHeader5:URLRequestHeader=new URLRequestHeader("Range","bytes=0-4031");
//			var reqHeader6:URLRequestHeader=new URLRequestHeader("Host","translate.google.com");
//			var reqHeader7:URLRequestHeader=new URLRequestHeader("Cache-Control","max-age=0");
//			var reqHeader8:URLRequestHeader=new URLRequestHeader("Accept-Encoding","identity;q=1, *;q=0");
//			var reqHeader9:URLRequestHeader=new URLRequestHeader("Connection","keep-alive");
//			var reqHeader10:URLRequestHeader=new URLRequestHeader("Cookie","CONSENT=YES+CZ.en+20150628-20-0; HSID=A7BSm2y3S2C5GbKv9; APISID=hfCgqE2tIj8YaW5F/ATKW9uDsTr89uCHqo; OGP=-681502720:; SID=9AIDA-Fk9Vrfro18Y51nltqONEAvRTBttJaCBRS23ctfpeeM1C9XwC4u6CKqNsnygL9SSw.; OGPC=5061900-1:5061918-1:5061921-6:5061937-5:5061933-6:5061940-9:5061952-6:5061574-10:5061975-4:5061983-4:103910400-5:5061968-2:5062006-8:5062028-4:681502720-4:5062083-4:; _ga=GA1.3.1579382488.1438520209; NID=79=TUYiOZhkpkN_xn2Bdbgb0TLOtl4gFP1jZWiFxdQGiBJQvtPeFOPXcVpO0lJbmw6CdiVuP0smftDFuG_AORi53srstq02eqmlwLc6wP1cj_UO0yh9QxzqA8i9fI7hxej1kkRNH1gunktJJNDvLqKnMjzpg7-o2ZNJ-iJpibIQCYNFVqKboQSZ7JS4kYAevL4Xv6tJjMGmrBNppAopZC9qJPq2DPWvK_FdDSR1UiN1rz9cwgNIQTwUnkaA_tJgNEYgA0XhTE-sVPvQIO2jza8wvPhpVYvc0mI6ZqUEakvlIk-JNTdoJcuOg38JdpaA6jLqtf1kdBPmSmv8Q5iLccu0LaDCR-G-NGW2c130kTxZHwDCPr0KK5ix1hQtOK5VVML-xWUo94qqjQ; GOOGLE_ABUSE_EXEMPTION=ID=b158a853a4ab86c0:TM=1463427624:C=c:IP=193.86.229.251-:S=APGng0ux2vTVqzd0rq2iH6YrfGRbZHE7SQ");
			
			var myUrl:URLLoader;
			
			req.method = URLRequestMethod.GET;
			req.requestHeaders.push(reqHeader);
//			req.requestHeaders.push(reqHeader2);
//			req.requestHeaders.push(reqHeader3);
//			req.requestHeaders.push(reqHeader4);
//			req.requestHeaders.push(reqHeader5);
//			req.requestHeaders.push(reqHeader6);
//			req.requestHeaders.push(reqHeader7);
//			req.requestHeaders.push(reqHeader8);
//			req.requestHeaders.push(reqHeader9);
//			req.requestHeaders.push(reqHeader10);
			
			var vars:URLVariables = new URLVariables();
			//vars.url = "http://translate.google.com/translate_tts";
			vars.tl = lang;
			vars.q = EN;//encodeURI(EN);
			vars.ie="UTF-8";
			vars.client="tw-ob";
			//vars.total="1";
			//vars.idx="0";
			//vars.tk="873579.750186";
			//vars.key="459519572445-8aanoi53l70qgqgqpb36oc7g7anproou.apps.googleusercontent.com";
			//vars.tk="000000.000000";
			req.data = vars;
							
			myUrl=new URLLoader();
			myUrl.dataFormat=URLLoaderDataFormat.BINARY;
			myUrl.addEventListener(Event.COMPLETE, onSoundLoaded);
			myUrl.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);

			myUrl.load(req);
		}
		private function onSoundLoaded(event:Event):void
		{
			tmpBytes.writeBytes(event.target.data);
			saveToFile();
		}
		private function saveToFile():void
		{
			//var newFile:File=new File();
			//newFile=file.resolvePath(setName(EN)+".mp3");
			
			try
			{				
				var fileStream:FileStream = new FileStream();
				//fileStream.open(newFile, FileMode.WRITE);
				fileStream.open(file, FileMode.WRITE);
				
				fileStream.writeBytes(tmpBytes);//only for mp3
				fileStream.close();
				
				this.dispatchEvent(new Event("mp3Created"));
				tmpBytes.clear();
			}
			catch (error:Error)
			{
				//trace("error: " + error.message);
				this.dispatchEvent(new Event("mp3Error"));
			}
		}
		private function setName(str:String):String{
			var arr:Array=new Array();
			var exclude:String='?;|;/;*;?;:;\\;>;<';
			var strRes:String=str;
			
			arr=exclude.split(";");
			
			for(var i:int=0;i<arr.length;i++){
				str=replaceAll(str,arr[i],"_");
			}
			return str;
		}
		public function replaceAll( source:String, find:String, replacement:String ) : String
		{
		    return source.split( find ).join( replacement );
		}		
		private function ioErrorHandler(event:Event):void {
			Alert.show("ioErrorHandler: " + event);
			this.dispatchEvent(new Event("mp3Error"));
		}		
	}
}