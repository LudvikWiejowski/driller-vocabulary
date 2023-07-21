import audio.Mp3File;
import audio.Mp3Files;
import audio.WavCard;

import com.adobe.serialization.json.JSON;

import flash.events.Event;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;
			
private var channel:SoundChannel = new SoundChannel();
private var wc:WavCard;
private var mp3c:Mp3Files;
private var myMp3:Mp3File;
private var appFile:File;

private var fileSave:File;
private var directionENCZ:Boolean;

// vse nize patri spolu s httpservice v driller.mxml ke google translate api, ktere ale vraci jen jedno slovicko. Moje reseni vraci vse.
// pro zprovozneni jednoho nebo druheho reseni staci prohodit funkce fTranslateDoIt :) a pohlidat cursorManager.setBusyCursor();
[Bindable]
public var googleTranslateURL:String;

private var googleText:String = "http://ajax.googleapis.com/ajax/services/language/" ;
private var tsrc:String ="translate?v=1.0&q=";
private var lanpair:String = "&langpair=";
private var pairCode:String = "%7C";

private var actualWordForTranslation:int;
private var wordsForTranslation:XMLList;

private var batchTranslation:Boolean;
private var translation_encz:Boolean;
private var ctfrom:String;

private var myWavButton:String;

private function onJSONLoad(event:ResultEvent):void
{
	var rawData:String = String(event.result);
	if(JSON.decode(rawData).responseData.translatedText !=null){
		var decoded:String =JSON.decode(rawData).responseData.translatedText;
	}else {
		decoded = "None support";
	}
	if(batchTranslation){
		wordsForTranslation[actualWordForTranslation].CZ=decoded;
		actualWordForTranslation+=1;
		if(actualWordForTranslation<wordsForTranslation.length()){
			fTranslateDoIt(wordsForTranslation[actualWordForTranslation].EN,"");
		}else{
			//KONEC
			this.status="OK";
			cmdBatchTranslation.enabled=true;
		}
	}else{
		txtCZ.text = decoded;
	}
}
private function onJSONError(event:Event):void{
	//Alert.show("Error");
	this.status="Error...";
	cmdBatchTranslation.enabled=true;
}
private function fTranslate():void{
	cursorManager.setBusyCursor();
	batchTranslation=false;
	fTranslateDoIt(txtEN.text,txtCZ.text);
}
//private function fTranslateDoIt(en:String):void{
//	if(batchTranslation){
//		this.status="Progress: "+ (actualWordForTranslation+1).toString() + " / " + wordsForTranslation.length().toString();
//	}
//	googleTranslateURL=googleText + tsrc+ en + lanpair + String(myXMLconf.translator.ctfrom)+pairCode+String(myXMLconf.translator.ctto);
//	googleTransService.send();
//}
private function fBatchTranslation():void{
	Alert.show(myXMLlang.alerts.alert10,"",Alert.YES | Alert.NO,this,fBatchTranslationDoIt);
}
private function fBatchTranslationDoIt(event:CloseEvent):void{
    if(event.detail==Alert.YES){
		batchTranslation=true;
		wordsForTranslation = myXML.wordList.word.(SL=="true");
		actualWordForTranslation=0;
		
		if(wordsForTranslation.length()>0){
			cursorManager.setBusyCursor();
			cmdBatchTranslation.enabled=false;
			fTranslateDoIt(wordsForTranslation[actualWordForTranslation].EN,"");
		}
    }	
}
//*******************************************************************************************************************************
private function fTranslateDoIt(en:String,cz:String):void{
	var word:String;
	var ctfrom:String=myXMLconf.translator.ctfrom;
	var ctto:String=myXMLconf.translator.ctto;
	var loader:URLLoader = new URLLoader();
	var url:String;
	
	translation_encz=(en.length>0 || cz.length==0);
	
	if(translation_encz){
		word=en;
		url="http://translate.google.com/?hl=en&eotf=1&layout=1&sl="+ctfrom+"&tl="+ctto+"&q="+word+"#";
	}else{
		word=cz;
		url="http://translate.google.com/?hl=en&eotf=1&layout=1&sl="+ctto+"&tl="+ctfrom+"&q="+word+"#";
	}
	
	if(batchTranslation){
		this.status="Progress: "+ (actualWordForTranslation+1).toString() + " / " + wordsForTranslation.length().toString();
	}	
	loader.addEventListener(Event.COMPLETE, fOpenLink);
    loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
    //loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
    loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);	
	
	var urlRequest:URLRequest = new URLRequest(url);
    try {
        loader.load(urlRequest);
    } catch (error:Error) {
        trace("Unable to load requested document.");
    }	
}
private function fOpenLink(event:Event):void{
	//var beginStr1:String="View detailed dictionary</a></span></p><table><tr><td>";
	var beginStr2:String="onmouseout=\"this.style.backgroundColor='#fff'\">";
	//var endStr1:String="</table>";
	var endStr2:String="</span>";
	//var pattern:RegExp=new RegExp("(?<=^|li>)[^><]+?(?=<|$)","gi");
	//var pattern:RegExp=new RegExp("(?<=^|>)[^><]+?(?=</div|$)","gi");
	//newest (?<=^|<div>)[^><]+?(?=</div>|$)
	//myRegEx="(?<=^|<div>)[^><]+?(?=</div>|$)";
	var pattern:RegExp=new RegExp(myRegEx,"gi");
	
    var loader:URLLoader = URLLoader(event.target);
    var myData:String=loader.data;
    var myDataNew:String="";
    
    trace(myData);
    
	var result:Object = pattern.exec(myData);
	while (result != null) {
 		//myDataNew+=fGetSlovniDruh(result.toString());//result.toString()+", ";
		if(result.toString()!=" "){
 			myDataNew+=fGetSlovniDruh(result.toString());//result.toString()+", ";
 		} 		
 		result = pattern.exec(myData);
 	}
 	if(myDataNew.length>0){
 		myDataNew=myDataNew.substr(0,myDataNew.length-2);
 	}else{
 		var pos1:int=myData.indexOf(beginStr2,0);
 		var pos2:int =myData.indexOf(endStr2,pos1);     				
 		if(pos1!=-1){
 			myDataNew=myData.substring(pos1+beginStr2.length,pos2);
 		}else{
 			myDataNew="-";
 		}
 	}
 	//txtCZ.text=myDataNew;	
 	//cursorManager.removeBusyCursor();
 	
	if(batchTranslation){
		wordsForTranslation[actualWordForTranslation].CZ=myDataNew;
		actualWordForTranslation+=1;
		if(actualWordForTranslation<wordsForTranslation.length()){
			fTranslateDoIt(wordsForTranslation[actualWordForTranslation].EN,"");
		}else{
			//KONEC
			cursorManager.removeBusyCursor();
			this.status="OK";
			cmdBatchTranslation.enabled=true;
			
		}
	}else{
		if(translation_encz){
			txtCZ.text = myDataNew;
		}else{
			txtEN.text = myDataNew;
		}
		cursorManager.removeBusyCursor();
	} 	
}
private function fGetSlovniDruh(word:String):String{
	var temp:String="";
	var comma:String=", ";
	var colon:String=": ";
	
	switch(word.toLowerCase()){
		case "noun":
			temp=colon;
			break;
		case "adjective":
			temp=colon;
			break;
		case "pronoun":
			temp=colon;
			break;
		case "adverb":
			temp=colon;
			break;
		case "verb":
			temp=colon;
			break;
		case "conjunction":
			temp=colon;
			break;
		case "preposition":
			temp=colon;
			break;
		case "particle":
			temp=colon;
			break;
		case "interjection":
			temp=colon;
			break;
		default:
			temp=comma;
			break;	
	}
	return word+temp;
}
//********************************************play pronunciation******************************
private var textTTS:String="";

public function fPlayVoice(pText:String):void{
	ctfrom=myXMLconf.translator.ctfrom;
	
	if(pText.length==0){
		textTTS=(myXML.swap=="false")?txtEN.text:txtCZ.text;
	}else{
		textTTS=pText;
	}
	if(textTTS.length==0){
		return;
	}
	if(textTTS.length>99){
		textTTS=textTTS.substr(0,99);
	}

	appFile = File.applicationStorageDirectory;
	appFile = appFile.resolvePath("pronunciation/"+setName(textTTS)+".mp3");
	
	//******************************************************************
	voiceTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onVoiceTimerComplete);
	if(appFile.exists){
		if(removeVoice){
			appFile.deleteFile();
			removeVoice=false;
			Alert.show("Refresh - "+appFile.name);
			//return;
		}
	}
	//******************************************************************		
	
	cmdVoice.enabled=false;
	cursorManager.setBusyCursor();
		
	if(appFile.exists){
		fPlayIt();
	}else{
		myMp3 = new Mp3File(appFile,textTTS,ctfrom);
		myMp3.addEventListener("mp3Created",fPronunciationDone);
		myMp3.addEventListener("mp3Error",fPronunciationError);		
	}
}
private function fPronunciationDone(event:Event):void{
	fRemovePronunciatioListeners();
	fPlayIt();
}
private function fPronunciationError(event:Event):void{
	fRemovePronunciatioListeners();
	this.status="Error...";
	cursorManager.removeBusyCursor();
	cmdVoice.enabled=true;	
}
private function fRemovePronunciatioListeners():void{
	myMp3.removeEventListener("mp3Created",fPronunciationDone);
	myMp3.removeEventListener("mp3Error",fPronunciationError);
}
private function fPlayIt():void{
	var req:URLRequest=new URLRequest(appFile.url);
	//channel.stop();
	//SoundMixer.stopAll();
	var s:Sound = new Sound();
	
	s.addEventListener(Event.COMPLETE, onSoundLoaded);
	s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

	s.load(req);	
}
private function onSoundLoaded(event:Event):void
{
	var localSound:Sound = event.target as Sound;
	
	channel=localSound.play();
	channel.addEventListener(Event.SOUND_COMPLETE,onSoundCompleted);		
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
private function onSoundCompleted(event:Event):void{
	cmdVoice.enabled=true;
	cursorManager.removeBusyCursor();
}
private function ioErrorHandler(event:IOErrorEvent):void {
    CursorManager.removeBusyCursor();	
    Alert.show("ioErrorHandler: " + event);
    cmdVoice.enabled=true;
}
private function securityErrorHandler(event:SecurityErrorEvent):void {
    CursorManager.removeBusyCursor();	
    Alert.show("securityErrorHandler: " + event);
}
//private function ioErrorHandler(event:Event):void {
//	Alert.show("ioErrorHandler: " + event);
//}

//******************************* mp3 player food **************************************
private function fWavIt():void{
	var words:XMLList=myXML.wordList.word.(SL=="true" && EN!="");
	var bw:int=Alert.buttonWidth;
	if(words.length()>0){
		Alert.buttonWidth=130;
	    Alert.okLabel = "Word-Translation";
	    Alert.yesLabel = "Translation-Word";
	    Alert.noLabel = "Word only";
		
		Alert.show(myXMLlang.alerts.alert11,"",Alert.OK | Alert.YES | Alert.NO | Alert.CANCEL,this,fWavItDoIt);
		
	    Alert.yesLabel = "Yes";
	    Alert.noLabel = "No";
	    Alert.okLabel = "OK";
	    Alert.buttonWidth=bw;
	}
}
private function fWavItDoIt(event:CloseEvent):void{
	if(event.detail!=Alert.CANCEL){
		myWavButton=event.detail==Alert.NO?"word only":"all";
		var words:XMLList=myXML.wordList.word.(SL=="true" && EN!="" && CZ!="");
		//if(words.length()>0){	
		directionENCZ=(event.detail==Alert.OK)
		
		fileSave = File.desktopDirectory;
		fileSave.browseForDirectory("Save to");
		fileSave.addEventListener(Event.SELECT, fSaveTranslation);	
		//}
	}
}
private function fSaveTranslation(event:Event):void{
	var words:XMLList;
	
	if(myWavButton=="word only"){
		words=myXML.wordList.word.(SL=="true" && EN!="");
		mp3c=new Mp3Files(fileSave);
		//wc.addEventListener(Event.DEACTIVATE,fTranslationDone);
		mp3c.addEventListener("mp3filesCreated",fTranslationDoneMp3);
		mp3c.addEventListener("mp3filesActual",fTranslationProgressMp3);
		mp3c.addEventListener("mp3filesError",fTranslationErrorMp3);
		mp3c.Pronounce(words,myXMLconf.translator.ctfrom);
		cmdWav.enabled=false;
		cursorManager.setBusyCursor();		
	}else{
		words=myXML.wordList.word.(SL=="true" && EN!="" && CZ!="");
		wc=new WavCard(fileSave);
		//wc.addEventListener(Event.DEACTIVATE,fTranslationDone);
		wc.addEventListener("wavsCreated",fTranslationDone);
		wc.addEventListener("wavActual",fTranslationProgress);
		wc.addEventListener("wavsError",fTranslationError);
		wc.Pronounce(words,myXMLconf.translator.ctfrom,myXMLconf.translator.ctto,directionENCZ);
		cmdWav.enabled=false;
		cursorManager.setBusyCursor();
	}
}
private function fTranslationDone(event:Event):void{
	Alert.show("OK!");
	//wc.removeEventListener(Event.DEACTIVATE,fTranslationDone);
	fRemoveListeners();
	this.status="OK";
}
private function fTranslationError(event:Event):void{
	//Alert.show("Error!");
	//wc.removeEventListener(Event.DEACTIVATE,fTranslationDone);
	fRemoveListeners();
	this.status="Error...";
	
}
private function fRemoveListeners():void{
	wc.removeEventListener("wavsCreated",fTranslationDone);
	wc.removeEventListener("wavActual",fTranslationDone);
	wc.removeEventListener("wavsError",fTranslationError);
	cursorManager.removeBusyCursor();
	cmdWav.enabled=true;
}
private function fTranslationProgress(event:Event):void{
	//this.status=""+wc.actualWord.toString();
	this.status="Progress: "+ (event.target.actualWord+1).toString()+" / "+event.target.numberOfWords.toString();
}


private function fTranslationDoneMp3(event:Event):void{
	Alert.show("OK!");
	//wc.removeEventListener(Event.DEACTIVATE,fTranslationDone);
	fRemoveListenersMp3();
	this.status="OK";
}
private function fTranslationErrorMp3(event:Event):void{
	//Alert.show("Error!");
	//wc.removeEventListener(Event.DEACTIVATE,fTranslationDone);
	fRemoveListenersMp3();
	this.status="Error...";
	
}
private function fRemoveListenersMp3():void{
	mp3c.removeEventListener("mp3filesCreated",fTranslationDoneMp3);
	mp3c.removeEventListener("mp3filesActual",fTranslationDoneMp3);
	mp3c.removeEventListener("mp3filesError",fTranslationErrorMp3);
	cursorManager.removeBusyCursor();
	cmdWav.enabled=true;
}
private function fTranslationProgressMp3(event:Event):void{
	//this.status=""+wc.actualWord.toString();
	this.status="Progress: "+ (event.target.actualWord+1).toString()+" / "+event.target.numberOfWords.toString();
}