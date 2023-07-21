// ActionScript file
import flash.events.SampleDataEvent;
import flash.media.Microphone;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.ByteArray;
import mx.controls.Alert;

[Bindable]
public var microphoneList:Array;
protected var microphone:Microphone;
protected var isRecording:Boolean = false;
protected var soundRecording:ByteArray;
protected var soundOutput:Sound;

private var lchannel:SoundChannel=new SoundChannel();

protected function setupMicrophoneList():void
{
	microphoneList = Microphone.names;
}

protected function setupMicrophone():void
{
	var micIndex:int=0;
	
	setupMicrophoneList();
	if(microphoneList.length==0)
		return;	
	
	if(int(myXMLconf.microphone)>microphoneList.length-1){
		micIndex=0;
		myXMLconf.microphone=0;
	}else{
		micIndex=int(myXMLconf.microphone);
	}
	microphone = Microphone.getMicrophone(micIndex);//(comboMicList.selectedIndex);
	microphone.rate = 44;
}

protected function startMicRecording():void
{
	if(microphoneList.length==0)
		return;	
		
	isRecording = true;
	soundRecording = new ByteArray();
	microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, gotMicData);
}

protected function stopMicRecording():void
{
	if(microphoneList.length==0)
		return;
	
	isRecording = false;
	microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, gotMicData);
	cmdListen.enabled=true;
}

private function gotMicData(micData:SampleDataEvent):void
{
	//soundRecording.writeBytes(micData.data);
	var isWritten:Boolean = false;
	// Lock ByteArray to not read/write over eachother
	while (!isWritten){

		if (micData.position*4 != soundRecording.position){
			var wlen:int = ((micData.position*4)-soundRecording.position)/4;
			for (var i:int = 0;i<wlen;i++)
				soundRecording.writeFloat(0);
		}
		soundRecording.writeBytes(micData.data);
		isWritten = true;
		//micStats = " " + (event.position/44100).toFixed(1) + "s";

	}	
}

protected function playbackData():void
{
	cmdListen.enabled=false;
	soundRecording.position = 0;
	
	soundOutput = new Sound();
	soundOutput.addEventListener(SampleDataEvent.SAMPLE_DATA, playSound);
	
	lchannel=soundOutput.play();
	lchannel.addEventListener(Event.SOUND_COMPLETE,onListenCompleted);
}
private function onListenCompleted(event:Event):void{
	cmdListen.enabled=true;
	lchannel.removeEventListener(Event.SOUND_COMPLETE,onListenCompleted);
}
private function playSound(soundOutput:SampleDataEvent):void
{
	if (!soundRecording.bytesAvailable > 0)
		return;
	for (var i:int = 0; i < 8192; i++)
	{
		var sample:Number = 0;
		if (soundRecording.bytesAvailable > 0)
			sample = soundRecording.readFloat();
		soundOutput.data.writeFloat(sample); 
		soundOutput.data.writeFloat(sample);  
	}				
}