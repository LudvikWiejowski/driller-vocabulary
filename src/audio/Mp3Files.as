package audio
{
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.media.Sound;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.controls.Alert;

	[Event(name="mp3filesCreated", type="flash.events.Event")]
	[Event(name="mp3filesActual", type="flash.events.Event")]
	[Event(name="mp3filesError", type="flash.events.Event")]
	public class Mp3Files extends Sprite
	{
		//private var proxy:String="http://driller.luwi.net/proxy.php";
		//private var proxy:String=Application.application.myProxy;
		//private var lngEN:String;
		//private var lngCZ:String;
		private var lngFrom:String;
		private var words:XMLList;
		
		public var actualWord:int;
		public var numberOfWords:int;
		
		private var blankSound:Sound=new Sound();
		private var blankBytes:ByteArray = new ByteArray();
		private var tmpBytes:ByteArray = new ByteArray();
		
		private var file:File;
		
		public function Mp3Files(file:File)
		{
			this.file=file;	
		}
		public function Pronounce(words:XMLList,lngFrom:String):void{
			//this.lngEN=lngEN;
			//this.lngCZ=lngCZ;
			this.words=words;
			this.lngFrom=lngFrom;
			this.numberOfWords=words.length();

			actualWord=0;
			getPronunciation();			
		}
		private function getPronunciation():void{
			if(actualWord==words.length()){
				//this.dispatchEvent(new Event(Event.DEACTIVATE));
				this.dispatchEvent(new Event("mp3filesCreated"));
				return;//KONEC
			}
			this.dispatchEvent(new Event("mp3filesActual"));
			
			var tl:String;
			var word:String;

			tl=lngFrom;
			word=words[actualWord].EN;
			word=word.substr(0,99);
			
			var req:URLRequest=new URLRequest("http://translate.google.com/translate_tts");//proxy
			var reqHeader:URLRequestHeader=new URLRequestHeader("Referer","http://translate.google.com");
			req.requestHeaders.push(reqHeader);
			
			req.method = URLRequestMethod.GET;
			var vars:URLVariables = new URLVariables();

			vars.tl = tl
			vars.q = word;//encodeURI(word);
			vars.ie="UTF-8";
			vars.client="tw-ob";
			req.data = vars;
			
			var myUrl:URLLoader=new URLLoader();
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
			var newFile:File=new File();
			newFile=file.resolvePath(setName(words[actualWord].EN)+".mp3");

			try
			{				
				var fileStream:FileStream = new FileStream();
				//fileStream.open(newFile, FileMode.WRITE);
				fileStream.open(newFile, FileMode.WRITE);
				
				fileStream.writeBytes(tmpBytes);//only for mp3
				fileStream.close();
				
				actualWord+=1;

				tmpBytes.clear();
				getPronunciation();				
			}
			catch (error:Error)
			{
				//trace("error: " + error.message);
				this.dispatchEvent(new Event("mp3filesError"));
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
			this.dispatchEvent(new Event("mp3filesError"));
		}		
	}
}