// ActionScript file
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filesystem.*;
import flash.geom.ColorTransform;
import flash.media.Microphone;
import flash.net.FileFilter;
import flash.net.URLRequest;
import flash.ui.Keyboard;

import mx.controls.Alert;
import mx.controls.Button;
import mx.core.Application;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;

private var fileToOpen:File = new File();
private var fileToImport:File = new File();
private var fileToSave:File = new File();
private var fileToParse:File = new File();
private var xmlFilter:FileFilter = new FileFilter("xml", "*.xml");
private var txtFilter:FileFilter = new FileFilter("text files", "*.txt;*.csv");

private var themeChanged:Boolean=false;
[Bindable] private var microphoneList:Array;

private var importXMLhead:XML=<root>
		    				<wordList>
		    				</wordList>
		    				<interval>1</interval>
		    				<name>My Vocabulary</name>
		    				<randomMode>false</randomMode>
		    				<swap>false</swap>
		    				<index>0</index>
		    				<swaprnd>false</swaprnd>
						</root>;


private function fKeyDown(event:KeyboardEvent):void{
	//event.preventDefault();
	switch(event.keyCode){
   		case Keyboard.ESCAPE:
			fSaveSettings();
	}
}
private function fNewFile():void{
	try 
	{
		fileToSave.nativePath=File.applicationStorageDirectory.nativePath;
	    fileToSave.browseForSave("Save new file");
	    fileToSave.addEventListener(Event.SELECT, fileNew);
	}
	catch (error:Error)
	{
	    trace("Failed:", error.message);
	}
}
private function fileNew(event:Event):void 
{
	var mySaveFileFull:String=event.target.nativePath;
	var myFileExtension:String=event.target.extension;
	if(myFileExtension==null){
		mySaveFileFull+=".xml";
		fileToSave.nativePath=mySaveFileFull;
	}
	
	var fs2:FileStream = new FileStream();
	fs2.open(fileToSave, FileMode.WRITE);
	fs2.writeUTFBytes(importXMLhead);
	fs2.close();
	
	Alert.show(Application.application.myXMLlang.alerts.alert8);
} 
private function fSelectFile():void{
	try 
	{
		fileToOpen.nativePath=File.applicationStorageDirectory.nativePath;
	    fileToOpen.browseForOpen("Open", [xmlFilter]);
	    fileToOpen.addEventListener(Event.SELECT, fileSelected);
	}
	catch (error:Error)
	{
	    trace("Failed:", error.message);
	}
}
private function fileSelected(event:Event):void 
{
	txtPath.text=event.target.nativePath;
}
private function fInitSettings():void{
	PopUpManager.centerPopUp(this);
	var clsbtn:Button = this.mx_internal::closeButton;
	
	microphoneList=Microphone.names;
	with(Application.application.myXML){
		txtInterval.text=interval;
		chkRnd.selected=(randomMode=="true")?true:false;
		chkSwap.selected=(swap=="true")?true:false;
		chkSwapRnd.selected=(swaprnd=="true")?true:false;
	}
	with(Application.application.myXMLconf){
		txtAboutEmail.text=regemail;
		txtAboutCode.text=regcode;
		chkEval.selected=(showCF=="true")?true:false;
		chkWriteMode.selected=(writemode=="true")?true:false;
		chkPronounce.selected=(pronounce=="true")?true:false;
		cmbMic.selectedIndex=int(microphone);
		colorPicker.selectedColor=fieldcolor;
	}
	txtPath.text=Application.application.myXMLconf.path==""?"driller.xml":Application.application.myXMLconf.path;
	
	with(Application.application.myXMLlang.settings){
		
		accOptions_1.label=options1;
		accOptions_4.label=options4;
		accOptions_5.label=options5;
		
		this.title=title;
		lblFile.text=file;
		lblInterval.text=interval;
		lblRandom.text=random;
		lblSwap.text=swap;
		lblSwapRnd.text=swaprnd;
		lblLang.text=language;
		cmdNewFile.label=newfile;

		
		lblAboutEmail.text=aboutemail;
		lblAboutCode.text=aboutcode;
		lblEval.text=showcf;
		lblWriteMode.text=writemode;
		lblPronounce.text=pronounce;
		
		lblTranslateDescription.text=translatedescription;
		lblFrom.text=translatefrom;
		lblTo.text=translateto;
	}
	
	txtPath.toolTip=txtPath.text;//Application.application.myXMLlang.tooltips.file;
	
	with(Application.application.myXMLlang.tooltips){
		cmdPath.toolTip=filebutton;
		txtInterval.toolTip=interval;
		chkRnd.toolTip=random;
		chkSwap.toolTip=swap;
		chkSwapRnd.toolTip=swaprnd;
		cmbLang.toolTip=language;
		cmdNewFile.toolTip=newfile;
		cmdOpenStorage1.toolTip=showstorage;
		txtAboutEmail.toolTip=aboutemail;
		txtAboutCode.toolTip=aboutcode;
		chkEval.toolTip=eval;
		clsbtn.toolTip=clsbutton;
		colorPicker.toolTip=fieldcolor;
	}
	//Alert.show(Application.application.myXMLconf.currentlanguage+","+cmbLang.dataProvider.length);
	fSetComboboxIndex(cmbLang.dataProvider.length,cmbLang,"name",Application.application.myXMLconf.currentlanguage);
	
	fSetComboboxIndex(cmbTheme.dataProvider.length,cmbTheme,"name",Application.application.myXMLconf.currenttheme);
	cTheme.source=Application.application.myXMLtheme.preview.toString();
	cThemeColor.setStyle("backgroundColor",Application.application.mySkinColor);
	
	fSetComboboxIndex(cmbFrom.dataProvider.length,cmbFrom,"code",Application.application.myXMLconf.translator.ctfrom);
	fSetComboboxIndex(cmbTo.dataProvider.length,cmbTo,"code",Application.application.myXMLconf.translator.ctto);
	
	this.addEventListener("keyDown",fKeyDown);
	
	if(Application.application.myRegistrationStatus==RegistrationStatus.EXPIRED){
		accOptions.selectedIndex=4;
		accOptions.getHeaderAt(0).enabled=accOptions.getHeaderAt(1).enabled=accOptions.getHeaderAt(2).enabled=false;
	}
	
	this.setFocus();
}
private function fSaveSettings():void{
   	if(Application.application.myRegistrationStatus==RegistrationStatus.EXPIRED){
   		Application.application.fCloseAppMsg();
   	}else{
		try{
			Application.application.myXML.interval=txtInterval.text;
			Application.application.myXML.randomMode=chkRnd.selected;
			Application.application.myXML.swap=chkSwap.selected;
			Application.application.myXML.swaprnd=chkSwapRnd.selected;
			Application.application.myXMLconf.showCF=chkEval.selected;
			Application.application.myXMLconf.writemode=chkWriteMode.selected;
			Application.application.myXMLconf.pronounce=chkPronounce.selected;
			Application.application.fSaveXML();
			Application.application.myXMLconf.path=txtPath.text=="driller.xml"?"":txtPath.text;
			Application.application.myXMLconf.currentlanguage=cmbLang.selectedLabel;
			Application.application.myXMLconf.currenttheme=cmbTheme.selectedLabel;
			Application.application.myXMLconf.regemail=txtAboutEmail.text;
			Application.application.myXMLconf.regcode=txtAboutCode.text;
			Application.application.myXMLconf.translator.ctfrom=cmbFrom.selectedItem.code.toString();
			Application.application.myXMLconf.translator.ctto=cmbTo.selectedItem.code.toString();
			Application.application.myXMLconf.microphone=cmbMic.selectedIndex;
			Application.application.myXMLconf.fieldcolor=colorPicker.selectedColor;
			Application.application.fSaveXMLconf();
			//Application.application.fSetLanguage();
			if(themeChanged){
				Application.application.fSetTheme();
			}
			
			PopUpManager.removePopUp(this);
			
		}catch (error:Error){
			Alert.show("Failed:"+error.message,"Option");
		}
   	}
}
private function fComboTheme():void{
	themeChanged=true;
	var myXMLskin:XMLList = Application.application.myXMLconf.themes.theme.(name==cmbTheme.selectedLabel);
	cTheme.source=myXMLskin.preview.toString();
	var myTransColor:ColorTransform=new ColorTransform();
	myTransColor.color=myXMLskin.theme_color;//0xC16800;
	var mySkinColor:uint=myTransColor.color;	
	cThemeColor.setStyle("backgroundColor",mySkinColor);
}
private function fSetComboboxIndex(len:int,cb:ComboBox,fld:String,fld2:String):void{
	for ( var i:int=0;i< len;i++){
		var item:String = cb.dataProvider.source[i][fld];
  		if(item==fld2){
  			cb.selectedIndex=i;
  			//Alert.show(cb.selectedIndex.toString());
  			return;
  		}
	}    	
}
private function fOpenStorageFolder():void{
	var file:File = File.applicationStorageDirectory;
    var urlRequest:URLRequest = new URLRequest(file.url);
    navigateToURL(urlRequest);
}
private function getDateTimeStamp():String{
	var myDate:Date=new Date();
	return myDate.getFullYear().toString()+(myDate.getMonth()+1).toString()+myDate.getDate().toString()+myDate.getHours().toString()+myDate.getMinutes().toString()+myDate.getSeconds().toString();
}
private function fChangeCode():void{
	if(Application.application.fCheckCode(txtAboutEmail.text,txtAboutCode.text)){
		Application.application.myRegistrationStatus=RegistrationStatus.REGISTRATED;
		accOptions.getHeaderAt(0).enabled=accOptions.getHeaderAt(1).enabled=accOptions.getHeaderAt(2).enabled=true;
	}
}