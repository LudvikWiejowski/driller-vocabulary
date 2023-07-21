package audio
{
	import com.adobe.audio.format.WAVWriter;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.media.Sound;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.controls.Alert;
	import mx.core.Application;

	[Event(name="wavsCreated", type="flash.events.Event")]
	[Event(name="wavActual", type="flash.events.Event")]
	[Event(name="wavsError", type="flash.events.Event")]
	public class WavCard extends Sprite
	{
		//private var proxy:String="http://driller.luwi.net/proxy.php";
		//private var proxy:String=Application.application.myProxy;
		//private var lngEN:String;
		//private var lngCZ:String;
		private var lngFrom:String;
		private var lngTo:String;
		private var words:XMLList;
		private var directionENCZ:Boolean;
		
		public var actualWord:int;
		public var numberOfWords:int;
		
		private var firstWord:Boolean;
		
		private var blankSound:Sound=new Sound();
		private var blankBytes:ByteArray = new ByteArray();
		private var tmpBytes:ByteArray = new ByteArray();
		
		private var file:File;
		
		public function WavCard(file:File)
		{
			this.file=file;
			blankSound.addEventListener(Event.COMPLETE, onBlankSoundLoaded);
			blankSound.load(new URLRequest("assets/blank.mp3"));
			
			/*var blankReq:URLRequest=new URLRequest("assets/blank.mp3");
			var blankUrl:URLLoader=new URLLoader();
			blankUrl.dataFormat=URLLoaderDataFormat.BINARY;
			blankUrl.addEventListener(Event.COMPLETE,onBlankSoundLoaded);
			blankUrl.load(blankReq);*/		
		}
		public function Pronounce(words:XMLList,lngFrom:String,lngTo:String,directionENCZ:Boolean):void{
			//this.lngEN=lngEN;
			//this.lngCZ=lngCZ;
			this.words=words;
			this.lngFrom=lngFrom;
			this.lngTo=lngTo;
			this.numberOfWords=words.length();
			this.directionENCZ=directionENCZ;
			
			firstWord=true;
			actualWord=0;
			getPronunciation();			
		}
		private function onBlankSoundLoaded(event:Event):void{
			blankBytes.endian=Endian.LITTLE_ENDIAN;
			blankSound.extract(blankBytes,blankSound.length*615);
			
			//blankBytes=event.target.data;			
		}
		private function getPronunciation():void{
			if(firstWord){
				if(actualWord==words.length()){
					//this.dispatchEvent(new Event(Event.DEACTIVATE));
					this.dispatchEvent(new Event("wavsCreated"));
					return;//KONEC
				}
				this.dispatchEvent(new Event("wavActual"));
			}
			
			var tl:String;
			var word:String;
			if(directionENCZ){
				tl=(firstWord)?lngFrom:lngTo;
				word=(firstWord)?words[actualWord].EN:words[actualWord].CZ;
			}else{
				tl=(firstWord)?lngTo:lngFrom;
				word=(firstWord)?words[actualWord].CZ:words[actualWord].EN;
			}
			
			word=word.substr(0,99);
			
			var req:URLRequest=new URLRequest("http://translate.google.com/translate_tts");//proxy
			var reqHeader:URLRequestHeader=new URLRequestHeader("Referer","http://translate.google.com");
			req.requestHeaders.push(reqHeader);
			
			var s:Sound = new Sound();
			
			s.addEventListener(Event.COMPLETE, onSoundLoaded);
			s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			req.method = URLRequestMethod.GET;
			var vars:URLVariables = new URLVariables();
			//vars.url = "http://translate.google.com/translate_tts";
			vars.tl = tl
			vars.q = word;//encodeURI(word);
			vars.ie="UTF-8";
			vars.client="tw-ob";
			req.data = vars;

			s.load(req);
			
			/*var req:URLRequest=new URLRequest(proxy);
			var myUrl:URLLoader;
			
			req.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars.url = "http://translate.google.com/translate_tts";
			vars.tl = tl
			vars.q = encodeURI(word);		
			req.data = vars;
							
			myUrl=new URLLoader();
			myUrl.dataFormat=URLLoaderDataFormat.BINARY;
			myUrl.addEventListener(Event.COMPLETE, onSoundLoaded);
			myUrl.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);

			myUrl.load(req);*/
		}
		private function onSoundLoaded(event:Event):void
		{
			var localSound:Sound = event.target as Sound;
			localSound.removeEventListener(Event.COMPLETE,onSoundLoaded);
			localSound.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			var sndBytes:ByteArray = new ByteArray();
		
			sndBytes.endian = Endian.LITTLE_ENDIAN;
			tmpBytes.endian=Endian.LITTLE_ENDIAN;
			localSound.extract(sndBytes,localSound.length*615);//44100*2

			sndBytes.position=0;
			tmpBytes.writeBytes(sndBytes);
			
			if(firstWord){
				blankBytes.position=0;
				//txtTo.text=blankBytes.length.toString();
				tmpBytes.writeBytes(blankBytes);
				
				firstWord=false;
				getPronunciation();
			}else{
				//savePrompt();
				saveToFile();
			}
			/*tmpBytes.writeBytes(event.target.data);
			if(firstWord){
				tmpBytes.writeBytes(blankBytes);
				
				firstWord=false;
				getPronunciation();
			}else{
				//savePrompt();
				saveToFile();
			}*/
		}
		private function saveToFile():void
		{
			var newFile:File=new File();
			newFile=file.resolvePath(setName(words[actualWord].EN)+".wav");
			
			try
			{
				var ww:WAVWriter = new WAVWriter();//**** remove for mp3
				
				var fileStream:FileStream = new FileStream();
				fileStream.open(newFile, FileMode.WRITE);
				ww.numOfChannels = 2;//**** remove for mp3
				tmpBytes.position = 0;//**** remove for mp3
				ww.processSamples(fileStream, tmpBytes, 44100, 2);//**** remove for mp3
				
				//fileStream.writeBytes(tmpBytes);//only for mp3
				
				fileStream.close();
				
				firstWord=true;
				actualWord+=1;
//				this.dispatchEvent(new Event("wavActual"));
				tmpBytes.clear();
				getPronunciation();
			}
			catch (error:Error)
			{
				//trace("error: " + error.message);
				this.dispatchEvent(new Event("wavsError"));
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
			this.dispatchEvent(new Event("wavsError"));
		}		
	}
}