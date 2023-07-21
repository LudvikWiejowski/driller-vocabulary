// ActionScript file
import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.collections.*;
import mx.controls.Alert;
import mx.core.WindowedApplication;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.styles.StyleManager;

[Bindable]
private var minH:int=190;//118;
[Bindable]
private var maxH:int=400;//380;//330
private var minW:int=270;
private var maxW:int=800;
private var winX:int=100;
private var winY:int=100;
private var minEnH:int=43;
private var maxEnH:int=68;
public var index:int=0;
[Bindable]
private var isNew:Boolean=false;
private var file:File;
private var fileConf:File;
[Bindable]
public var myXML:XML;
[Bindable]
public var myXMLlang:XMLList;
[Bindable]
public var myXMLconf:XML;
[Bindable]
private var myXMLlist:XMLList;
[Bindable]
public var menuBarCollection:XMLListCollection;
private var centerNow:Boolean=false;
private var myWinApp:WindowedApplication;
private var myNatWin:NativeWindow;
public var myTimer:Timer=new Timer(0,1);
public var firstRun:Boolean=true;
[Bindable]
public var myRegistrationStatus:String;

public var myTransformColor:ColorTransform=new ColorTransform();
[Bindable]
public var mySkinColor:uint;
[Bindable]
public var mySkinName:String;
public var myStatusStyleName:String="white";
[Bindable]
public var registrationEmail:String;
[Bindable]
public var localLang:String;

public var myXMLtheme:XMLList;

[Bindable]
public var serverURL:String="http://www.wiejowski.com/driller/";//"http://www.driller-vocabulary.com";

//[Bindable]
//public var myProxy:String="http://www.driller-vocabulary.com/proxy.php";
//[Bindable]
//public var myProxyMp3:String="http://www.driller-vocabulary.com/proxymp3.php";
[Bindable]
public var myRegEx:String="(?<=^|>)[^><]+?(?=</div|$)";

private function paramFault(event:FaultEvent):void {
	//myProxy="http://www.driller-vocabulary.com/proxy.php";
	//myProxyMp3="http://www.driller-vocabulary.com/proxymp3.php";
	myRegEx="(?<=^|>)[^><]+?(?=</div|$)";
}
private function paramResult(event:ResultEvent):void {
	//Alert.show(event.result.regex);
	//myProxy=event.result.proxyurl;
	//myProxyMp3=event.result.proxymp3url;
	myRegEx=event.result.regex;
}
public function fSetLanguage():void{
	myXMLlang = myXMLconf.ct.(name==myXMLconf.currentlanguage.toString());
	//cmdShow.label=myXMLlang.buttons.show;
	//cmdNext.label=myXMLlang.buttons.next;
	//cmdNextSkip.label=myXMLlang.buttons.nextskip;
	//cmdUpdate.label=myXMLlang.buttons.save;
	//cmdNew.label=isNew?myXMLlang.buttons.add2:myXMLlang.buttons.add;//pokud je stavajici status "isNew=true", pak se musi vlozit do tlacitka text "update", ne "New"
	cmdNew.label=myXMLlang.buttons.add;
	//cmdSetup.label=myXMLlang.buttons.setup;
	rb1.label=myXMLlang.buttons.radio1;
	rb2.label=myXMLlang.buttons.radio2;
	rb3.label=myXMLlang.buttons.radio3;
	
	dgWords.columns[1].headerText=myXMLlang.grid.col1;
	dgWords.columns[2].headerText=myXMLlang.grid.col2;
	dgWords.columns[3].headerText=myXMLlang.grid.col3;
	dgWords.columns[4].headerText=myXMLlang.grid.col4;
	
	cmdShow.toolTip=myXMLlang.tooltips.show;
	cmdNext.toolTip=myXMLlang.tooltips.next;
	cmdNextSkip.toolTip=myXMLlang.tooltips.nextskip;
	cmdUpdate.toolTip=myXMLlang.tooltips.save;
	cmdNew.toolTip=myXMLlang.tooltips.add;
	cmdSetup.toolTip=myXMLlang.tooltips.setup;
	cmdVoice.toolTip=myXMLlang.tooltips.voice;
	cmdBatchTranslation.toolTip=myXMLlang.tooltips.translateall;
	cmdExport.toolTip=myXMLlang.tooltips.exporttxt;
	cmdImport.toolTip=myXMLlang.tooltips.importtxt;
	cmdVideo.toolTip=myXMLlang.tooltips.videostream;
	cmdWav.toolTip=myXMLlang.tooltips.mp3;
	rb1.toolTip=myXMLlang.tooltips.radio1;
	rb2.toolTip=myXMLlang.tooltips.radio2;
	rb3.toolTip=myXMLlang.tooltips.radio3;
	colorPicker.toolTip=myXMLlang.tooltips.colorpicker;
	txtEN.toolTip=myXMLlang.tooltips.text1;
	txtCZ.toolTip=myXMLlang.tooltips.text2;
	txtPR.toolTip=myXMLlang.tooltips.text3;
	txtCX.toolTip=myXMLlang.tooltips.text4;
	//cmdMaximize.toolTip=myXMLlang.tooltips.maximize;
	cmdClose.toolTip=myXMLlang.tooltips.close;
	cmdList.toolTip=myXMLlang.tooltips.showlist;
	
	cmdIPA.toolTip=myXMLlang.tooltips.ipa;
	cmdTranslate.toolTip=myXMLlang.tooltips.translate+" ("+myXMLconf.translator.ctfrom+"-"+myXMLconf.translator.ctto+")";
	cmdPrint.toolTip=myXMLlang.tooltips.print;
	cmdSel.toolTip=myXMLlang.tooltips.printselect;
	
	cmdWrite.toolTip=myXMLlang.tooltips.write;
	cmdWriteCancel.toolTip=myXMLlang.tooltips.writeclose;
	cmdRec.toolTip=myXMLlang.tooltips.record;
	cmdListen.toolTip=myXMLlang.tooltips.replay;
	imgWrite.toolTip=myXMLlang.tooltips.bulb;
	
	openCommand.label = myXMLlang.buttons.trayshow;
	pauseCommand.label = myXMLlang.buttons.traypause;
	exitCommand.label = myXMLlang.buttons.trayexit;
}
private function fInit():void{
	//this.addEventListener(Event.CLOSING, preventClose);
	
	myWinApp=this;
	myNatWin=myWinApp.nativeWindow;
	//myNatWin.stage.displayState = StageDisplayState.;
	/*var myTitleBar:TitleBar=myWinApp.titleBar;
	myTitleBar.closeButton.visible=false;
	var myCloseButton:Button=myTitleBar.closeButton;*/

	SysTray();
	//cmdMaximize.visible=false;
	//myNatWin.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMoveCommand);
	//lblTitle.addEventListener(MouseEvent.MOUSE_DOWN, onMoveCommand);
	header.addEventListener(MouseEvent.MOUSE_DOWN, onMoveCommand);
	header.addEventListener(MouseEvent.MOUSE_UP, onMoveEndCommand);
	centerNow=true;
	fLoadXML();
	if(myXMLlist.length()!=0){
		fSetNewLayout(false);
		colorPicker.visible=false;
		cmdShow.setFocus();
	}else{
		setENFocus();
	}
	fInitGrid();
	tlIPA.move(10,77);
	cWrite.visible=false;
	cWrite.move(10,85);
	myNatWin.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);	
	
	//fCheckRegistration();
	firstRun=false;
	fSetTheme();
	setupMicrophone();
	xmlParameters.send();
	fShowMessage();
}
private function keyEscHandler(event:KeyboardEvent):void{
	event.preventDefault();
	if(event.keyCode==Keyboard.ESCAPE){
		Alert.show("keydown: "+event.isDefaultPrevented().toString());
	}
}
private function closeEscHandler(event:Event):void{
		event.preventDefault();
		
		Alert.show("closing: "+event.isDefaultPrevented().toString());
		
		event.preventDefault();
		event.cancelable;
}
public function fSetTheme():void{
	
	myXMLtheme = myXMLconf.themes.theme.(name==myXMLconf.currenttheme.toString());
	
	myTransformColor.color=myXMLtheme.theme_color;//0xC16800;
	mySkinColor=myTransformColor.color;
	myStatusStyleName=myXMLtheme.status_color;
	
	this.setStyle("statusTextStyleName",myStatusStyleName);
	lblTitle.setStyle("styleName",myStatusStyleName);
	this.setStyle("backgroundGradientColors",[mySkinColor, mySkinColor]);
	this.setStyle("borderColor",mySkinColor);
	panelWindow.setStyle("borderColor",mySkinColor);
	panelWindow.setStyle("headerColors",[mySkinColor,mySkinColor]);
	
	mySkinName=myXMLtheme.image.toString();//"assets/skins/skin_paper.jpg";
	
	dgWords.setStyle("themeColor",mySkinColor);	
	
	StyleManager.getStyleDeclaration("Alert").setStyle("backgroundColor",mySkinColor);
	StyleManager.getStyleDeclaration("Alert").setStyle("borderColor",mySkinColor);
}
private function fCheckRegistration():void{
	var mEmail:String=myXMLconf.regemail;
	var mCode:String=myXMLconf.regcode;
	
	myRegistrationStatus=RegistrationStatus.REGISTRATED;
	if(!fCheckCode(mEmail,mCode)){
		var fasd:File = File.applicationStorageDirectory;
		var cdate:Date=fasd.creationDate;
		var adate:Date=new Date();
		var elapse:Number = adate.getTime() - cdate.getTime();// get difference in miliseconds
		var milisecondsIn24Hours:Number=86400000;
		var dayDiff:int=elapse/milisecondsIn24Hours; // convert miliseconds to days
		
		if(dayDiff>=0 && dayDiff<=14){
			//continue trial version
			var trialDays:int=(14-dayDiff);
			Alert.show("Days before expiration: "+trialDays);
			myRegistrationStatus="TRIAL DAYS: "+trialDays;
		}else{
			myRegistrationStatus=RegistrationStatus.EXPIRED;
			fShow();
			fShowSettings();
			Alert.show("Trial version has expired.\nPlease, purchase driller and obtain\nregistration code.");
		}
	}
}

private function keyHandler(event:KeyboardEvent):void{
	if(this.visible!=true) return;
	var bShiftPressed:Boolean = event.shiftKey;
	var bCtrlPressed:Boolean = event.ctrlKey;
	var bAltPressed:Boolean = event.altKey;
	
	//Alert.show(event.keyCode.toString());
	//Alert.show(event.charCode.toString());
	if(cWrite.visible) return;
	if(!bShiftPressed && !bCtrlPressed && !bAltPressed){
		switch(event.keyCode){
			case Keyboard.ESCAPE:
				//event.preventDefault();
				break;
			case Keyboard.F5:
				if(cmdNext.enabled) fNext('wait');
				break;
			case Keyboard.F4:
				if(cmdShow.enabled) fShow();
				break;
			case Keyboard.F6:
				fSave();
				break;
			case Keyboard.F7:
				if(cmdNew.visible==true){
					cmdNew.selected=(cmdNew.selected==false)
					fNew();
				}
				break;
			case Keyboard.F8:
				if(cmdSetup.enabled) fShowSettings();
				break;
			case Keyboard.F9:
				fShowList();
				break;
			case Keyboard.F10:
				if(cmdNextSkip.enabled) fNext('now');
				break;
			case Keyboard.F11:
				fPlayVoice("");
				break;
			case Keyboard.F1:
				if(rb1.enabled){
					rb1.selected=true;
					//fNext('wait');
					fShow();
				}
				break;
			case Keyboard.F2:
				if(rb2.enabled){
					rb2.selected=true;
					fShow();
				}
				break;
			case Keyboard.F3:
				if(rb3.enabled){
					rb3.selected=true;
					fShow();
				}
				break;
			case Keyboard.F12:
				fCloseAppMsg();
				break;
		}
	}else{
		var controlUsed:int;
		
		if(bCtrlPressed){
			controlUsed=0;
		}else if(bShiftPressed){
			controlUsed=1;
		}else{
			controlUsed=2;
		}
		
		if(controlUsed==0){
			if(event.keyCode==Keyboard.F1){
				fWrite();
				return;
			}
		}
		var keyUsed:String=String.fromCharCode(event.charCode).toLowerCase();
		
		//Alert.show(controlUsed.toString() + " - " + keyUsed.toString());
		
		for(var i:int=0;i<myXMLconf.hotkeys.key.length();i++){
			if(controlUsed==myXMLconf.hotkeys.key[i].control){
				//Alert.show("keycode: "+keyUsed+" - "+String(myXMLconf.hotkeys.key[i].key).charCodeAt(0).toString())
				if(keyUsed==String(myXMLconf.hotkeys.key[i].key).toLowerCase()){
					//Alert.show("color: " + myXMLconf.hotkeys.key[i].color);
					colorPicker.selectedColor=myXMLconf.hotkeys.key[i].color;
					break;
				}
			}
		}
	}
}
private function onMoveCommand(event:MouseEvent):void{
	myNatWin.startMove();
}
private function onMoveEndCommand(event:MouseEvent):void{
	winX=nativeWindow.x;
	winY=nativeWindow.y;		
}
private function fLoadXML():void {
	/*var applicationDirectoryPath:File = File.applicationDirectory;
	var nativePathToApplicationDirectory:String = applicationDirectoryPath.nativePath.toString();
	nativePathToApplicationDirectory+= "/assets/conf.xml";
	fileConf = new File(nativePathToApplicationDirectory);*/
	var myXMLconfNew:XML;
	var myXMLconfOld:XML;
	var myUpdate:Boolean=false;
	var fileConfOrigin:File = File.applicationDirectory;
	fileConfOrigin=fileConfOrigin.resolvePath("assets/conf.xml");
	fileConf = File.applicationStorageDirectory;
	fileConf = fileConf.resolvePath("preferences/conf.xml");
	
	if(!fileConf.exists){
		if(fileConfOrigin.exists){
			fileConfOrigin.copyTo(fileConf,false);
		}else{
			Alert.show("XML file 'conf.xml' is missing!");
			return;			
		}
	}else{
		myUpdate=true;
	}
	
	if(myUpdate){
		//srovnani dat vytvoreni obou conf.xml
		//pokud je puvodni conf.xml novejsi, pak musi dojit k prekopirovani
		//asi by se mely prenest z puvodniho souboru informace o registraci a aktualnim souboru slovicek
		
		//protoze je instalovyn conf.xml novejsi nez puvodni, dojde k prekopirovani, ale pred tim jeste uchova puvodni data o registraci a aktualnim souboru slovicek
		var fsOld:FileStream = new FileStream();
		fsOld.open(fileConf, FileMode.READ);
		myXMLconfOld = XML(fsOld.readUTFBytes(fsOld.bytesAvailable));
		fsOld.close();	
		
		var fsNew:FileStream = new FileStream();
		fsNew.open(fileConfOrigin, FileMode.READ);
		myXMLconfNew = XML(fsNew.readUTFBytes(fsNew.bytesAvailable));
		fsNew.close();
		
		if(myXMLconfOld.confversion!=null){
			if(int(myXMLconfOld.confversion)>=int(myXMLconfNew.confversion)){
				myUpdate=false;
			}
		}
		
		if(myUpdate){
			fileConfOrigin.copyTo(fileConf,true);
		}
	}

	
	//fileConf tedy jiz existuje, muzeme z nej nacist data
	var fs2:FileStream = new FileStream();
	fs2.open(fileConf, FileMode.READ);
	myXMLconf = XML(fs2.readUTFBytes(fs2.bytesAvailable));
	fs2.close();
	
	if(myUpdate){
		myXMLconf.path=myXMLconfOld.path;
		myXMLconf.currentlanguage=myXMLconfOld.currentlanguage;
		myXMLconf.regemail=myXMLconfOld.regemail;
		myXMLconf.regcode=myXMLconfOld.regcode;
		_fSaveXMLconf();
	}
	
	
	fSetLanguage();	
	
	var pathDefault:Boolean=true;
	if(myXMLconf.path!=""){//pokud nastavena cesta ke slovickum existuje, pak...
		file= new File(myXMLconf.path);
		pathDefault=!file.exists;//pokud soubor fyzicky opravdu existuje...
	}
	if(pathDefault){
		var fileOrigin:File = File.applicationDirectory;
		fileOrigin=fileOrigin.resolvePath("assets/driller.xml");
		file = File.applicationStorageDirectory;
		file = file.resolvePath("driller.xml");
		
		if(!file.exists){
			if(fileOrigin.exists){
				fileOrigin.copyTo(file,false);
			}else{
				Alert.show("XML file 'driller.xml' is missing!");
			}
		}
	}
	var fs:FileStream = new FileStream();
	fs.open(file, FileMode.READ);
	myXML = XML(fs.readUTFBytes(fs.bytesAvailable));
	fs.close();
	//fSetUT();
	fCreateSelectField();//********************************** just for old vocabulary files with no SL node for selectin word for printing. Remove after test phase.
	
	fUpdateXMLlist();
	/*if(myXML.index<myXMLlist.length()){
		index=myXML.index;
	}else{
		index=0;
	}*/
	index=0;
	for(var i:int=0;i<myXMLlist.length();i++){
		var temp:String=myXMLlist[i].EN;
		if(temp==myXML.index){
			index=i;
			break;
		}
	}
	//if (!isNew && this.height!=maxH) fStart('wait');	
	if (!isNew) fStart('wait');
	lblTitle.text="Driller - "+file.name;
		
	/*if(fileConf.nativePath.indexOf("conf.xml") != -1){
		var fs2:FileStream = new FileStream();
		fs2.open(fileConf, FileMode.READ);
		myXMLconf = XML(fs2.readUTFBytes(fs2.bytesAvailable));
		fs2.close();
		fSetLanguage();
	}else{
		Alert.show("XML file 'conf.xml' is missing!");
		return;
	}
	
	var pathDefault:Boolean=true;
	if(myXMLconf.path!=""){
		file= new File(myXMLconf.path);
		pathDefault=!file.exists;	
	}
	if(pathDefault){
		nativePathToApplicationDirectory = applicationDirectoryPath.nativePath.toString();
		nativePathToApplicationDirectory+= "/assets/driller.xml";
		file = new File(nativePathToApplicationDirectory);	
		if(file.nativePath.indexOf("driller.xml") != -1){
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			myXML = XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();
			
			//fSetUT();
			fUpdateXMLlist();
			if (!isNew) fStart();
		}else{
			Alert.show("XML file 'driller.xml' is missing!");
		}
	}else{
		var fs3:FileStream = new FileStream();
		fs3.open(file, FileMode.READ);
		myXML = XML(fs3.readUTFBytes(fs3.bytesAvailable));
		fs3.close();
		//fSetUT();
		fUpdateXMLlist();
		if (!isNew) fStart();		
	}
	lblTitle.text="Driller - "+file.name;*/
}
private function fStart(pNextMode:String):void{
	if(myXMLlist.length()==0){//pokud xml soubor neobsahuje zadne slovicko, pak se musi nastavit rezim novy, hned se zobrazit okno bez cekani na nastaveny interval
		fSetNewLayout(true);
		if(firstRun) fShowList();
		//myTimer = new Timer(0*1000, 1);
		myTimer.delay=0;
	}else{
		//myTimer = new Timer(myXML.interval*1000, 1);
		myTimer.delay=(firstRun || pNextMode=='now')?0:myXML.interval*1000;//pokud jde o prvni spusteni aplikace, tak se musi okno hned zobrazit, neceka se na uplynuti intervalu
		fSetWord();
	}
    myTimer.addEventListener(TimerEvent.TIMER, onTick);
    myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
    
	myTimer.start();
	openCommand.label=myXMLlang.buttons.trayshow;
	pauseCommand.checked=false;
	pauseCommand.enabled=true;
}
public function onTick(event:TimerEvent):void 
{
	//fSetWord();    
    //this.visible=true;
}
public function onTimerComplete(event:TimerEvent):void
{
	this.alwaysInFront=true;
    this.visible=true;
    
    openCommand.label=myXMLlang.buttons.trayhide;
    pauseCommand.checked=false;
    pauseCommand.enabled=false;
	
	if(myXMLconf.writemode=="true"){
		fWrite();
	}
	if(myXML.swap=="false"){
		if(myXMLconf.pronounce=="true" && this.height!=maxH){
			fPlayVoice("");
		}
		if(txtPR.length!=0 || this.height==maxH){
			txtEN.height=minEnH;
			txtPR.visible=true;
		}else{
			txtEN.height=maxEnH;
			txtPR.visible=false;			
		}
	}else{
		txtEN.height=maxEnH;
		txtPR.visible=false;
	}
    //this.activate();
    //NativeApplication.nativeApplication.activate(myNatWin);
}
private function fGetRandom():Number{
	var nbr:Number = Math.floor(Math.random() * (myXMLlist.length()));
	return nbr;
}
private function fGetSwapRandom():Number{
	var nbr:Number = Math.floor(Math.random() * (2));
	return nbr;
}
public function fSaveXML():void{
	try{
		var temp:String=myXMLlist[index].EN;
		myXML.index=temp;//index;
	}catch(error:Error){
		
	}
	//myXML.currentword = 
	var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + myXML.toXMLString();
	var fs:FileStream = new FileStream();
	try{
		fs.open(file, FileMode.WRITE);
		fs.writeUTFBytes(newXMLStr);
		fs.close();
	}catch (error:Error){
	    Alert.show("Failed: "+ error.message,"saveXML");
	}
	this.status=myXMLlang.alerts.alert1;//"Changes has been saved...";
	if(isNew){
		fSetNewLayout(true);
	}
	fUpdateXMLlist();
}
public function fSaveXMLquick():void{
	var temp:String=myXMLlist[index].EN;
	myXML.index=temp;//index;
	var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + myXML.toXMLString();
	var fs:FileStream = new FileStream();
	try{
		fs.open(file, FileMode.WRITE);
		fs.writeUTFBytes(newXMLStr);
		fs.close();
	}catch (error:Error){
	    Alert.show("Failed: "+ error.message,"saveXML");
	}
	/*this.status=myXMLlang.alerts.alert1;//"Changes has been saved...";
	if(isNew){
		fSetNewLayout(true);
	}
	fUpdateXMLlist();*/ //neni treba refreshnout seznam slovicek k opakovani, v pripade totiz, ze seznam uz obsahuje
	//spoustu slovicek s ohodnocenim > 0, se tyto vytridi, ale index zustane stejny, tudiz se posune prilis dopredu
}
public function fSaveXMLconf():void{
	_fSaveXMLconf();
	this.status=myXMLlang.alerts.alert2;//"Conf changes has been saved...";
	fLoadXML();
	setupMicrophone();
}
private function _fSaveXMLconf():void{
	var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + myXMLconf.toXMLString();
	var fs:FileStream = new FileStream();
	try{
		fs.open(fileConf, FileMode.WRITE);
		fs.writeUTFBytes(newXMLStr);
		fs.close();		
	}catch (error:Error){
	    Alert.show("Failed: "+error.message,"saveXMLCong");
	}		
}
private function fSetUT():void{
	//Alert.show("xmllist"+myXMLlist.length().toString());
	//Alert.show("xml"+myXML.wordList.word.length().toString());
	//Alert.show("index"+index.toString());
	while((myXMLlist.length()==0) || (index==0 && myXMLlist.length()==1 && myXML.wordList.word.length()>1)){
		fSetUTEngine();
		fUpdateXMLlist();
	}
}
private function fSetUTEngine():void{
	var myCF:int;	
	for(var i:int=0;i<myXML.wordList.word.length();i++){
		myXML.wordList.word[i].UT="false";
		myCF=myXML.wordList.word[i].CF;
		if(myCF>0){
			myXML.wordList.word[i].CF=myCF-1;
		}
	}	
}
private function fSetNewLayout(state:Boolean):void{
	isNew=state;
	colorPicker.visible=state;
	if(state){
		txtEN.text=myXMLlang.buttons.addtext;//Insert new word
		txtCZ.text=txtPR.text=txtCX.text="";
		if(this.height<maxH){
			this.height=maxH;
		}
		//cmdNew.label=myXMLlang.buttons.add2;
		cmdNew.selected=true;
	}else{
		this.height=minH;
		this.width=minW;
		cmdList.label=">";
		cmdList.toolTip=myXMLlang.tooltips.showlist;
		fSetListIcons(cmdList.label);
		//cmdNew.label=myXMLlang.buttons.add;
	}
}
private function fSetWord():void{
	//txtEN.htmlText="<b><font color='#"+myXMLlist[index].CL+"'>"+myXMLlist[index].EN+"</font></b>";
	//Alert.show("fSetWord: "+myXMLlist.length().toString());
	
	if(myXML.swaprnd=="true"){
		if(fGetSwapRandom()==0){
			myXML.swap="false";
		}else{
			myXML.swap="true"
		}
	}
	
	txtEN.text=(myXML.swap=="false")?myXMLlist[index].EN:myXMLlist[index].CZ;
    txtCZ.text=(myXML.swap=="false")?myXMLlist[index].CZ:myXMLlist[index].EN;
    txtPR.text=myXMLlist[index].PR;
    txtCX.text=myXMLlist[index].CX;
	colorPicker.selectedColor=myXMLlist[index].CL;		
}
private function fChangeWord():void{
	//index=dgWords.selectedIndex;
	//fSetWord();
}
private function fUpdateXMLlist():void{
	if(myXML.randomMode=="true"){
		myXMLlist= myXML.wordList.word.(UT=="false" && CF==0);
	}else{
		myXMLlist= myXML.wordList.word.(CF==0);
	}
}
public function fCellDelete():void{
	Alert.show(myXMLlang.alerts.alert7 + " '"+dgWords.selectedItem.EN+"'?","",Alert.YES | Alert.NO,this,fDeleteWord);
}
private function fDeleteWord(event:CloseEvent):void{
	if(event.detail==Alert.YES){
		delete myXML.wordList.word.(EN==dgWords.selectedItem.EN)[0];
		fSaveXML();
		if(myXMLlist.length()>0){
			index=0;
			if(!isNew) fSetWord();
		}else{
			if(!isNew){
				isNew=true;
				cmdNew.selected=true;
				fNew();
			}
		}
	}
}
private function fCheckIfExists(word:String):Boolean{
	var wXML:XMLList=myXML.wordList.word.(EN==word);
	return (wXML.length()>0);
}
public function centreApp():void
{
	/*var window:WindowedApplication=this;
    var screenBounds:Rectangle = Screen.mainScreen.bounds;
    var nativeWindow:NativeWindow  = window.nativeWindow;

    nativeWindow.x = (screenBounds.width - maxW)/2;
    nativeWindow.y = (screenBounds.height - maxH)/2;*/	 
    
	/*nativeWindow.x=winX;
	nativeWindow.y=winY;*/	    
}
public function resizeApp():void
{
	/*var window:WindowedApplication=this;
    var screenBounds:Rectangle = Screen.mainScreen.bounds;
    var nativeWindow:NativeWindow  = window.nativeWindow;

	if(this.height>maxH){

		this.width=maxW;
		centerNow=true;
		this.height=maxH;
	}else{	
	    nativeWindow.x = 0;
	    nativeWindow.y = 0;
	    nativeWindow.width=screenBounds.width;
	    nativeWindow.height=screenBounds.height;
	}*/
}
private function fResize():void{
	/*if(this.width>minW){
		dgWords.width=this.width-dgWords.x-10;
		dgWords.height=this.height-dgWords.y-50;
		//cmdMaximize.x=dgWords.x+dgWords.width-cmdMaximize.width-20;
	}
	
	if(centerNow){
		centreApp();
		centerNow=false;
	}*/
	fSetTextSearchColor(false);
}
public function fCloseAppMsg():void{
	Alert.show(myXMLlang.alerts.alert3,"",Alert.YES | Alert.NO,this,fCloseApp);
}
private function fCloseApp(event:CloseEvent):void{
    if(event.detail==Alert.YES){
	    //this.removeEventListener(Event.CLOSING, preventClose);
	    //this.close();
	    //fSaveXML();
	    NativeApplication.nativeApplication.icon.bitmaps = [];
	    NativeApplication.nativeApplication.exit();
	    
    }	
}
/*private function preventClose(eventObj:Event):void{
	if(eventObj.cancelable){
		eventObj.preventDefault();
	}
}*/
/*private function fMakeMenu():void{
	var menubarXML:XMLList =
    <>
        <menuitem label="Menu1" data="top">
            <menuitem label="MenuItem 1-A" data="1A"/>
            <menuitem label="MenuItem 1-B" data="1B"/>
        </menuitem>
        <menuitem label="Menu2" data="top">
            <menuitem label="MenuItem 2-A" type="check"  data="2A"/>
            <menuitem type="separator"/>
            <menuitem label="MenuItem 2-B" >
                <menuitem label="SubMenuItem 3-A" type="radio"
                    groupName="one" data="3A"/>
                <menuitem label="SubMenuItem 3-B" type="radio"
                    groupName="one" data="3B"/>
            </menuitem>
        </menuitem>
    </>;
    menuBarCollection = new XMLListCollection(menubarXML);	
}
private function menuHandler(event:MenuEvent):void  {
    // Don't open the Alert for a menu bar item that 
    // opens a popup submenu.
    if (event.item.@data != "top") {
        Alert.show("Label: " + event.item.@label + "\n" + 
            "Data: " + event.item.@data, "Clicked menu item");
    }        
}*/
public function replaceAll( source:String, find:String, replacement:String ) : String
{
    return source.split( find ).join( replacement );
}
public function fGetCode(pEmail:String):String{
	var email:String=replaceAll(pEmail.toLowerCase()," ","");
	var arrEmail:Array=email.split("");
	var finalCode:int=0;
	
	for(var i:int=0;i<arrEmail.length;i++){
		var chCode:String=arrEmail[i];
		finalCode+=chCode.charCodeAt()*((i+1)*3);
	}
	return finalCode.toString();
}
public function fCheckCode(pEmail:String,pCode:String):Boolean{
	return (fGetCode(pEmail)==pCode);
}

private function httpStatusHandler(event:HTTPStatusEvent):void {
    trace("httpStatusHandler: " + event);
}


//for old driller vocabulary files, which did not have SL column for word selection for printing flashcards
private function fCreateSelectField():void{
	if("swaprnd" in myXML){
	}else{
		myXML.swaprnd="false";
	}
		
	if(myXML.wordList.word.length()>0){
		if("SL" in myXML.wordList.word[i]){
			return;
		}else{
			for(var i:int=0;i<myXML.wordList.word.length();i++){
				if("SL" in myXML.wordList.word[i]){
				}else{
					myXML.wordList.word[i].SL="false";
				}
			}				
		}	
	}
}
private function fUpdateSelection(pState:String):void{
	var xmlSel:XMLList;

	xmlSel = myXML.wordList.word.(SL==((pState=="check")?"false":"true"));
	
	for(var i:int=0;i<xmlSel.length();i++){
		xmlSel[i].SL=((pState=="check")?"true":"false");
	}
	
	//pro pripad, ze je v nove vygenerovanem souboru misto false - nula (0)
	xmlSel = myXML.wordList.word.(SL==((pState=="check")?"0":"true"));
	
	for(var j:int=0;j<xmlSel.length();j++){
		xmlSel[j].SL=((pState=="check")?"true":"false");
	}	
	//fUpdateXMLlist();
}
private function fSearchInGrid(pTerm:String,pStart:int):int{
	var temp:String=""
	var res:int=-1;
	var i:int=0;
	
	var dp:Object=dgWords.dataProvider;
	var cursor:IViewCursor=dp.createCursor();
	//cursor.seek(CursorBookmark.CURRENT);
	while( !cursor.afterLast ){
		if(i>pStart){
			temp=cursor.current.EN;
			temp=temp.concat(" ",cursor.current.CZ," ",cursor.current.CX);
			if(temp.indexOf(pTerm,0)!=-1){
				res=i;
				break;
			}else{
				res=-1;
			}
		}
		// Obviously don't forget to move to next row:
		cursor.moveNext();
		i++;
	}

//	Alert.show(dgWords.dataProvider.source[1].EN.toString());
//	for(var i:int=pStart;i<myXML.wordList.word.length();i++){
//		temp=myXML.wordList.word[i].EN.toString();
//		temp=temp.concat(" ",myXML.wordList.word[i].CZ.toString()," ",myXML.wordList.word[i].CX.toString());
//		if(temp.indexOf(pTerm,0)!=-1){
//			res=i;
//			break;
//		}else{
//			res=0;
//		}
//	}
	return res;
}
private function fSetRowInGrid(pTerm:String):void{
	if(pTerm.length==0){
		return;
	}	
	var m:int=fSearchInGrid(pTerm,dgWords.selectedIndex);
	if(m!=-1){
		dgWords.selectedIndex=m;
		dgWords.scrollToIndex(m);
		fSetTextSearchColor(true);
	}else{
		dgWords.selectedIndex=-1;
		dgWords.scrollToIndex(0);
		fSetTextSearchColor(false);	
	}
}
private function fSetTextSearchColor(pStatus:Boolean):void{
	if(pStatus){
		txtSearch.setStyle("backgroundColor","#009dff");
	}else{
		txtSearch.setStyle("backgroundColor","#FFFFFF");
	}
}

private var writeErrorCount:int=0;
private var writeTimer:Timer=new Timer(0,1);
private var mFind:int;
private function fWrite():void{
	cWrite.visible=true;
	txtWrite.text="";
	fResetBulb();
	txtWrite.setFocus();
	writeErrorCount=0;
}
private function fWriteEval():void{
	var mText:String=txtWrite.text;
	var mTrans:String=txtCZ.text;
	
	writeTimer.delay=1*1000;
    writeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onWriteTimerComplete);
    
	writeTimer.start();		
	if(mText.length>0){
		mFind=mTrans.indexOf(mText);
		if(mFind!=-1){
			imgWrite.source="assets/b_icons/bulb_green.png";
		}else{
			imgWrite.source="assets/b_icons/bulb_red.png";
			writeErrorCount+=1;
		}
	}else{
		//cWrite.visible=false;
		mFind=-1;
		imgWrite.source="assets/b_icons/bulb_red.png";
		writeErrorCount+=1;		
	}
}
private function fWriteKeyDown(event:KeyboardEvent):void{
	if(event.keyCode==13){
		fWriteEval();
	}else if(event.keyCode==27){
		fWriteCancel();
	}
}
private function fWriteCancel():void{
	cWrite.visible=false;
}
private function fResetBulb():void{
	imgWrite.source="assets/b_icons/bulb_grey.png";
}
private function onWriteTimerComplete(event:TimerEvent):void{
	fResetBulb();
	writeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onWriteTimerComplete);
	if(mFind!=-1){
		cWrite.visible=false;
		if(writeErrorCount>0){
			coef.selectedValue="3";
			rb2.selected=true;
		}else{
			coef.selectedValue="6";
			rb1.selected=true;
		}
		fShow();
	}
}
private function fGetMessageResult(event:ResultEvent):void{
	switch(event.result.toString()){
		case "ok":
			break;
		case "error":
			break;
		default:
			//Alert.show(event.result.toString());
		    var setWin2:Message = new Message();
		    PopUpManager.addPopUp(setWin2, this, true);
		    setWin2.setStyle("borderAlpha", 0.9);
		    PopUpManager.centerPopUp(setWin2);	
		    setWin2.msg.htmlText=event.result.toString();	
			break;		
	}
}
private function fGetMessageFault(event:FaultEvent):void{
	
}
public function fShowMessage():void{
	registrationEmail=myXMLconf.regemail;
	localLang=myXMLconf.translator.ctto;
	if(localLang=="cs" || localLang=="sk"){
		localLang="cs";
	}else{
		localLang="en";
	}
	getMessages.send();
}