// ActionScript file
import flash.utils.Timer;

import mx.managers.PopUpManager;

[Embed("assets/b_icons/listshow_black.png")] 
public var listShowIconBlack: Class;
[Embed("assets/b_icons/listhide_black.png")] 
public var listHideIconBlack: Class;
[Embed("assets/b_icons/listshow_grey.png")] 
public var listShowIconGrey: Class;
[Embed("assets/b_icons/listhide_grey.png")] 
public var listHideIconGrey: Class;
[Embed("assets/b_icons/listshow_lightgrey.png")] 
public var listShowIconLightGrey: Class;
[Embed("assets/b_icons/listhide_lightgrey.png")] 
public var listHideIconLightGrey: Class;

public var removeVoice:Boolean=false;

private function fShow():void{
	this.height=maxH;
	colorPicker.visible=true;
	txtPR.visible=true;
	txtEN.height=minEnH;
	//coef.selectedValue="1";
}
private function fNext(pNextMode:String):void{
	this.visible=false;//schová okno
	
	//this.alwaysInFront=false;
	//this.minimize();
	//this.restore();
	//var request:URLRequest = new URLRequest("ahoj");
	//navigateToURL(request,"_blank");
	
	//Alert.show((coef.selectedValue!=null)?coef.selectedValue.toString():"9");
	myXMLlist[index].CF=(coef.selectedValue!=null)?coef.selectedValue:0;//nastavi koeficient znalosti slovicka
	//rb1.selected=rb2.selected=rb3.selected=false;
	coef.selection=null;
	
	//cmdMaximize.visible=false;
	centerNow=true;
	fSetNewLayout(false);//nastaví prvky tak, aby bylo okno jako při spuštění. Krátké.
	if(myXML.randomMode=="true"){
		//if(myXMLlist[index].CF!=0) myXMLlist[index].UT="true";//pokud uzivatel slovicko vubec nevedel, pak se v ranom modu nezahrne do jiz procvicenych slovicek, ale zustane v seznamu prave procvicovanych
		myXMLlist[index].UT="true";
		fUpdateXMLlist();//musi se aktualizovat myXMLlist, protoze zmeny v myXML se neprenaseji do myXMLlist, naopak to funguje
		if(myXMLlist.length()==0){
			fSetUT();
			fUpdateXMLlist();
		}
		index=fGetRandom();
	}else{
		index+=1;
		if(index==myXMLlist.length()){//dojelo se na konec a nyni je treba zacit od zacatku vsechna slovicka, ktera maji CF==0
			index=0;
			fSetUTEngine();//pouze snizi hodnotu CF-=1 u vsech slovicek krome tech, ktere maji CF==0. Neni treba funkce fSetUT, ktera tak dlouho snizuje, dokud neni nejake CF==0
			fUpdateXMLlist();
		}
		if(myXMLlist.length()<=1){//vsechna slovicka maji CF>0 a je nutne snizovat CF u vsech slovicek tak dlouho, dokud nektera nebudou mit CF==0
			fSetUT();
			fUpdateXMLlist();
		}			
	}
	this.status = "";
	fSaveXMLquick();
	fStart(pNextMode);
}
private function fUpdate():void{
	myXMLlist[index].EN=(myXML.swap=="false")?txtEN.text:txtCZ.text;
	myXMLlist[index].CZ=(myXML.swap=="false")?txtCZ.text:txtEN.text;
	myXMLlist[index].PR=txtPR.text;
	myXMLlist[index].CX=txtCX.text;
	myXMLlist[index].CL=colorPicker.selectedColor;
	//fSaveXML();
	fSaveXMLquick();//tahle funkce je lepsi pro ukladani za behu, protoze neaktualizuje seznam a nevypadavaji z nej slova > 0, cimz se pak index ocita uplne mimo poradi zousenych slovicek
	//tim, ze se pouziva savxmlquick, nezobrazuje se infomrace ve statusbaru o ulozeni, je treba uvest zvlast.
	//informace o ulozeni tam neni proto, protoze se ukladani provadi po kazdem prechodu na dalsi slovicko
	this.status=myXMLlang.alerts.alert1;//"Changes has been saved...";
}
private function fAdd():void{
    var newnode:XML = new XML(); 
    newnode =
        <word>
            <EN>{txtEN.text}</EN>
            <CZ>{txtCZ.text}</CZ>
            <PR>{txtPR.text}</PR>
            <CX>{txtCX.text}</CX>
            <CL>{colorPicker.selectedColor}</CL>
            <UT>false</UT>
            <CF>0</CF>
		    <SL>false</SL>            
        </word>;
        
	myXML.wordList.appendChild(newnode);
	//fUpdateXMLlist(true);
	fSaveXML();
}
private function fNew():void{
	//if(cmdNew.label==myXMLlang.buttons.add.toString()){//
	if(cmdNew.selected){
		//cmdNew.label=myXMLlang.buttons.add2;//"Active";
		fSetNewLayout(true);
		cmdNext.enabled=false;
		cmdNextSkip.enabled=false;
		//cmdSetup.enabled=false;
		coef.enabled=false;
		setENFocus();
	}else{
		isNew=false;
		//cmdNew.label=myXMLlang.buttons.add;//"New";
		//if(myXML.wordList.word.length()>0){
			fSetWord();
			cmdNext.enabled=true;
			cmdNextSkip.enabled=true;
			//cmdSetup.enabled=true;
			coef.enabled=true;
		//}
	}
}
private function fSave():void{
	if(txtEN.length==0 || txtEN.text==myXMLlang.buttons.addtext.toString()){
		Alert.show(myXMLlang.alerts.alert4);
		return;
	}else if(txtCZ.length==0){
		Alert.show(myXMLlang.alerts.alert5);
		return;
	}
	if(isNew){
		if(fCheckIfExists(txtEN.text)){
			Alert.show("'"+txtEN.text+"' "+myXMLlang.alerts.alert6);
			return;
		}else{
			fAdd();
			setENFocus();
		}
	}else{
		fUpdate();
	}
}
private function setENFocus():void{
	txtEN.setFocus();
	txtEN.setSelection(0,txtEN.length);
	cmdIPA.selected=false;
}
private function fShowList():void{
	if(cmdList.label==">"){
		this.width=maxW;
		this.height=maxH;
		cmdList.label="<";
		cmdList.toolTip=myXMLlang.tooltips.hidelist;//"Hide vocabulary list";
		fSetListIcons(cmdList.label);
		//cmdMaximize.visible=true;
	}else{
		//cmdMaximize.visible=false;
		this.width=minW;
		centerNow=true;
		this.height=maxH;
		cmdList.label=">";
		cmdList.toolTip=myXMLlang.tooltips.showlist;//"Show vocabulary list";
		fSetListIcons(cmdList.label);
	}
	this.alwaysInFront=false;
}
public function fSetListIcons(type:String):void{
	if(type==">"){
		cmdList.setStyle("icon",listShowIconGrey);
		cmdList.setStyle("overIcon",listShowIconBlack);
		cmdList.setStyle("downIcon",listShowIconBlack);
		cmdList.setStyle("disabledIcon",listShowIconLightGrey);			
	}else{
		cmdList.setStyle("icon",listHideIconGrey);
		cmdList.setStyle("overIcon",listHideIconBlack);
		cmdList.setStyle("downIcon",listHideIconBlack);
		cmdList.setStyle("disabledIcon",listHideIconLightGrey);		
	}
}
public function fShowSettings():void{
    //var setWin:Settings = Settings(PopUpManager.createPopUp(this, Settings, true));
    var setWin:Settings = new Settings();
    PopUpManager.addPopUp(setWin, this, true);
    //setWin.x=this.stage.stageWidth/2-(setWin.width/2);
    //setWin.y=this.stage.stageHeight/2-(setWin.height/2);
    setWin.setStyle("borderAlpha", 0.9);
}
private function fSel():void{
	if(cmdSel.selected){
		fUpdateSelection("check");	
	}else{
		fUpdateSelection("uncheck");
	}
}
public var voiceTimer:Timer=new Timer(0,1);
public function fRemoveVoice():void{
	voiceTimer.delay=1*1000;
    voiceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVoiceTimerComplete);
    voiceTimer.start();
}
private function onVoiceTimerComplete(event:TimerEvent):void{
	removeVoice=true;
}
private function fExportTxt():void{
	//Alert.show(myXMLlang.alerts.alert10,"",Alert.YES | Alert.NO,this,fBatchTranslationDoIt);
    var setWin2:ExportTxt = new ExportTxt();
    PopUpManager.addPopUp(setWin2, this, true);
    setWin2.setStyle("borderAlpha", 0.9);
    PopUpManager.centerPopUp(setWin2);	
    //setWin2.msg.htmlText=event.result.toString();
}
private function fImport():void{
	//Alert.show(myXMLlang.alerts.alert10,"",Alert.YES | Alert.NO,this,fBatchTranslationDoIt);
    var setWin2:ImportTxt = new ImportTxt();
    PopUpManager.addPopUp(setWin2, this, true);
    setWin2.setStyle("borderAlpha", 0.9);
    PopUpManager.centerPopUp(setWin2);	
    //setWin2.msg.htmlText=event.result.toString();
}
private function fVideo():void{
	//Alert.show(myXMLlang.alerts.alert10,"",Alert.YES | Alert.NO,this,fBatchTranslationDoIt);
    var setWin2:VideoStream = new VideoStream();
    PopUpManager.addPopUp(setWin2, this, true);
    setWin2.setStyle("borderAlpha", 0.9);
    PopUpManager.centerPopUp(setWin2);	
}