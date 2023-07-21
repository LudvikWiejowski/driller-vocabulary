// ActionScript file
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filesystem.*;
import flash.net.FileFilter;
import flash.net.URLRequest;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Button;
import mx.core.Application;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private var fileToImport:File = new File();
private var fileToSave:File = new File();
private var fileToParse:File = new File();
private var xmlFilter:FileFilter = new FileFilter("xml", "*.xml");
private var txtFilter:FileFilter = new FileFilter("text files", "*.txt;*.csv");

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

private function fSelectTextFile():void{
	try 
	{
		fileToParse.nativePath=File.desktopDirectory.nativePath;
	    fileToParse.browseForOpen("Open", [txtFilter]);
	    fileToParse.addEventListener(Event.SELECT, textFileSelected);
	}
	catch (error:Error)
	{
	    trace("Failed:", error.message);
	}
}
private function textFileSelected(event:Event):void 
{
	CursorManager.setBusyCursor();
	
	var myPathFull:String=event.target.nativePath;
	var myPathDir:String=myPathFull.substr(0,myPathFull.length-event.target.name.length)
	var myFileExtension:String=event.target.extension;
	var myFileNameFull:String=event.target.name;
	var myFileName:String=myFileNameFull.substr(0,myFileNameFull.length-(myFileExtension==null?0:myFileExtension.length+1));
	
	var fileText:File;
	var arrWord:Array;
	var myDelimiter:String=" ";
	fileText = new File(myPathFull);
		
	var fs:FileStream = new FileStream();
	fs.open(fileText, FileMode.READ);
	var fileData:String = fs.readUTFBytes(fs.bytesAvailable);
	fs.close();
	
    var crlf:String = String.fromCharCode(13, 10);
    var regEx:RegExp = new RegExp(crlf, "g");
    fileData = fileData.replace(regEx, " ");
	fileData = fileData.toLowerCase();

	var fileDataOrigin:String=fileData;//pro ucely rozdeleni na vety (context)
	var arrSentence:Array=fileDataOrigin.split(".");// pole by melo uchovávat jednotlivé věty
	
	var arrExcluded:Array=txtExcluded.text.split(" ");

	for(var q:int=0;q<arrExcluded.length;q++){
		fileData=Application.application.replaceAll(fileData,arrExcluded[q]," ");
	}
	
	/*if(myExcluded!=""){
		myExcluded = myExcluded.substr(0,myExcluded.length-1);
		Alert.show(myExcluded);		
		var regExpik:RegExp = new RegExp(myExcluded,"g");//("\\,|\\.","g"); // OR this entry: /\,|\./g; there must be double slash in new RegExp syntax
		fileData = fileData.replace(regExpik," ")
	}*/
    var newnode:XML = new XML();
    var importXML:XML= new XML(importXMLhead);
	arrWord=fileData.split(myDelimiter);
	for(var m:int=0;m<arrWord.length;m++){
		if(arrWord[m]==""){
			arrWord.splice(m,1);
			m--;
		}
		for(var n:int=m+1;n<arrWord.length;n++){
			if(arrWord[m]==arrWord[n]){
				arrWord.splice(n,1);
				n--;
				m--;
			}
		}
	}
	
	var mySentence:String;
	for(var j:int=0;j<arrWord.length;j++){
		mySentence="";
		for(var p:int=0;p<arrSentence.length;p++){
			if(arrSentence[p].indexOf(arrWord[j],0)!=-1){
				mySentence=arrSentence[p];
				break;
			}
		}
	    newnode =
	        <word>
	            <EN>{arrWord[j]}</EN>
	            <CZ></CZ>
	            <PR></PR>
	            <CX>{mySentence}</CX>
	            <CL></CL>
	            <UT>false</UT>
	            <CF>0</CF>
		        <SL>false</SL>	            
	        </word>;
	        
		if(rb3.selected){
			if(!isDuplicate(arrWord[j])){	
				Application.application.myXML.wordList.appendChild(newnode);
			}
		}else{
			importXML.wordList.appendChild(newnode);
		}	
	}

	if(rb3.selected){
		Application.application.fSaveXML();
	}else{
		var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + importXML.toXMLString();
		var file:File = File.applicationStorageDirectory.resolvePath(myFileName+".xml");
		
		if(file.exists){
			//Alert.show("File already exits. Overwrite?");
			var timeStr:String=getDateTimeStamp();
			file = File.applicationStorageDirectory.resolvePath(myFileName+"_"+timeStr+".xml");
		}
		
		var fs2:FileStream = new FileStream();
		fs2.open(file, FileMode.WRITE);
		fs2.writeUTFBytes(newXMLStr);
		fs2.close();
		
		if(rb2.selected){
			//txtPath.text=file.nativePath;
			Application.application.myXMLconf.path=file.nativePath;
		}	
	}
	
	CursorManager.removeBusyCursor();
	
	if(rb3.selected){
		Alert.show("OK");
	}else{	
		Alert.show(Application.application.myXMLlang.alerts.alert8+"\n"+file.name);
	}
}
private function fImportFile():void{
	try 
	{
	    fileToImport.browseForOpen("Open", [txtFilter]);
	    fileToImport.addEventListener(Event.SELECT, fileImported);
	}
	catch (error:Error)
	{
	    trace("Failed:", error.message);
	}
}
private function fileImported(event:Event):void 
{
	CursorManager.setBusyCursor();
	
	var myPathFull:String=event.target.nativePath;
	var myPathDir:String=myPathFull.substr(0,myPathFull.length-event.target.name.length)
	var myFileExtension:String=event.target.extension;
	var myFileNameFull:String=event.target.name;
	var myFileName:String=myFileNameFull.substr(0,myFileNameFull.length-(myFileExtension==null?0:myFileExtension.length+1));
	
	var fileText:File;
	var arrWord:Array;
	var myDelimiter:String;
	fileText = new File(myPathFull);
		
	var fs:FileStream = new FileStream();
	fs.open(fileText, FileMode.READ);
	var fileData:String = fs.readUTFBytes(fs.bytesAvailable);
	fs.close();
	fileData = fileData.replace(/\n/g, File.lineEnding);
	var arrLine:Array=fileData.split(File.lineEnding);
	
	switch(rgDelimiters.selection.id){
		case "semicolon":
			myDelimiter=";";
			break;
		case "tab":
			myDelimiter="\t";
			break;
		case "commna":
			myDelimiter=",";
			break;
		case "custom":
			if(txtCustom.text.length!=0){
				myDelimiter=txtCustom.text;
			}else{
				Alert.show(Application.application.myXMLlang.alerts.alert9);
				return;
			}
			break;
	}
	
    var newnode:XML = new XML();
    var indexEN:int;
    var indexCZ:int;
    var indexPR:int;
    var indexCX:int;
	
	var arrList:Array=lsOrder.dataProvider.toArray();
	//arrList.reverse();
	for(var k:int;k<arrList.length;k++){
		switch(arrList[k].data){
			case "en":
				indexEN=k;
				break;
			case "cz":
				indexCZ=k;
				break;
			case "pr":
				indexPR=k;
				break;
			case "cx":
				indexCX=k;
				break;
		}
	}
	
	var importXML:XML=new XML(importXMLhead);
	
	for(var i:int=0;i<arrLine.length;i++){
		arrWord=arrLine[i].split(myDelimiter);
		//for(var j:int=0;j<arrWord.length;j++){
		    newnode =
		        <word>
		            <EN>{arrWord[indexEN]==undefined?"":arrWord[indexEN]}</EN>
		            <CZ>{arrWord[indexCZ]==undefined?"":arrWord[indexCZ]}</CZ>
		            <PR>{arrWord[indexPR]==undefined?"":arrWord[indexPR]}</PR>
		            <CX>{arrWord[indexCX]==undefined?"":arrWord[indexCX]}</CX>
		            <CL></CL>
		            <UT>false</UT>
		            <CF>0</CF>
		            <SL>false</SL>		            
		        </word>;
		    
		    if(rb3.selected){
				if(!isDuplicate(arrWord[indexEN])){		    	
					Application.application.myXML.wordList.appendChild(newnode);
				}    	
		    }else{
				importXML.wordList.appendChild(newnode);
		    }
		//}
	}
	
	if(rb3.selected){
		Application.application.fSaveXML();
	}else{
		var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + importXML.toXMLString();
		var file:File = File.applicationStorageDirectory.resolvePath(myFileName+".xml");
		
		if(file.exists){
			//Alert.show("File already exits. Overwrite?");
			var timeStr:String=getDateTimeStamp();
			file = File.applicationStorageDirectory.resolvePath(myFileName+"_"+timeStr+".xml");
		}
		
		var fs2:FileStream = new FileStream();
		fs2.open(file, FileMode.WRITE);
		fs2.writeUTFBytes(newXMLStr);
		fs2.close();
		
		if(rb2.selected){
			//txtPath.text=file.nativePath;
			Application.application.myXMLconf.path=file.nativePath;
		}
	}
	CursorManager.removeBusyCursor();
	
	if(rb3.selected){
		Alert.show("OK");
	}else{
		Alert.show(Application.application.myXMLlang.alerts.alert8+"\n"+file.name);
	}
}
private function fInitSettings():void{
	var clsbtn:Button = this.mx_internal::closeButton;
	
	httpThemes.send();
	
	with(Application.application.myXMLlang.settings){
		accOptions_2.label=options2;
		accOptions_3.label=options3;
		accOptions_7.label=options7;
		
		semicolon.label=opt1;
		tab.label=opt2;
		comma.label=opt3;
		custom.label=opt4;

		lblDescription.text=imptext1;
		lblExcluded.text=imptext2;
		txtExcluded.text=excluded;

		rb1.label=importoption1;
		rb2.label=importoption2;
		rb3.label=importoption3;

	}
	with(Application.application.myXMLconf){
		rbGroup1.selectedValue=importoption;
		rgDelimiters.selectedValue=importdelimiteroption;
		accOptions.selectedIndex=importaccoption;
		
		var temp:String=columnorder;
		var arrOrder:Array=temp.split(";");
		var arrOrderList:Array=new Array();
		
		for(var k:int=0;k<arrOrder.length;k++){
			var obj:Object=new Object();
			switch(arrOrder[k]){
				case "en":
					obj.label=Application.application.myXMLlang.settings.order1;
					obj.data="en";
					obj.id="en";
					arrOrderList.push(obj);
					break;
				case "cz":
					arrOrderList.push({label:Application.application.myXMLlang.settings.order2, data:"cz", id:"cz"});
					break;
				case "pr":
					arrOrderList.push({label:Application.application.myXMLlang.settings.order3, data:"pr", id:"pr"});
					break;
				case "cx":
					arrOrderList.push({label:Application.application.myXMLlang.settings.order4, data:"cx", id:"cx"});
					break;
			}			
		}
		lsOrder.dataProvider=arrOrderList;
	}
	with(Application.application.myXMLlang.tooltips){
		cmdOpenStorage2.toolTip=showstorage;
		lsOrder.toolTip=listorder;
		txtCustom.toolTip=custom;
		txtExcluded.toolTip=excluded;
		clsbtn.toolTip=clsbutton;
	}
	getEnabling();
	this.addEventListener("keyDown",fKeyDown);
	this.setFocus();
}
private function fSaveSettings():void{
	try{		
		Application.application.myXMLconf.importoption=rbGroup1.selectedValue;
		Application.application.myXMLconf.importdelimiteroption=rgDelimiters.selectedValue;
		Application.application.myXMLconf.importaccoption=accOptions.selectedIndex;
		
		var arrList:Array=lsOrder.dataProvider.toArray();
		var textOrder:String="";
		for(var k:int=0;k<arrList.length;k++){
			textOrder+=arrList[k].data;
			textOrder+=(k < arrList.length-1)?";":"";
		}
		//Alert.show(textOrder);
		Application.application.myXMLconf.columnorder=textOrder;
		
		Application.application.fSaveXMLconf();
		
		PopUpManager.removePopUp(this);
		
	}catch (error:Error){
		Alert.show("Failed:"+error.message);
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
private function fImport():void {
	switch(accOptions.selectedIndex){
		case 0:
			fImportFile();
			break;
		case 1:
			fSelectTextFile();
			break;
		case 2:
			fImportPredefined();
			break;
	}
}
private function fImportPredefined():void{
	CursorManager.setBusyCursor();
	//osetrit pripad, kdy nebude oznaceno zadne tema nebo v tematu nebudou zadna slovicka (kdyby se z duvodu chyby nanacetla)

	var myFileName:String=dgThemes.selectedItem.theme;
    var newnode:XML = new XML();
	var importXML:XML=new XML(importXMLhead);
	var arrWord:Array;
	var tXMLvocabs:ArrayCollection;
	
	tXMLvocabs=httpVocabulary.lastResult.records.record;

	for(var i:int=0;i<tXMLvocabs.length;i++){
	    newnode =
	        <word>
	            <EN>{tXMLvocabs[i].word}</EN>
	            <CZ>{(tXMLvocabs[i].translation==undefined)?"":tXMLvocabs[i].translation}</CZ>
	            <PR>{(tXMLvocabs[i].pronunciation==undefined)?"":tXMLvocabs[i].pronunciation}</PR>
	            <CX>{(tXMLvocabs[i].context==undefined)?"":tXMLvocabs[i].context}</CX>
	            <CL></CL>
	            <UT>false</UT>
	            <CF>0</CF>
	            <SL>false</SL>		            
	        </word>;
	    
	    if(rb3.selected){
	    	if(!isDuplicate(tXMLvocabs[i].word)){
				Application.application.myXML.wordList.appendChild(newnode);
	    	}
	    }else{
			importXML.wordList.appendChild(newnode);
	    }
	}
	
	if(rb3.selected){
		Application.application.fSaveXML();
	}else{
		var newXMLStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + importXML.toXMLString();
		var file:File = File.applicationStorageDirectory.resolvePath(myFileName+".xml");
		
		if(file.exists){
			//Alert.show("File already exits. Overwrite?");
			var timeStr:String=getDateTimeStamp();
			file = File.applicationStorageDirectory.resolvePath(myFileName+"_"+timeStr+".xml");
		}
		
		var fs2:FileStream = new FileStream();
		fs2.open(file, FileMode.WRITE);
		fs2.writeUTFBytes(newXMLStr);
		fs2.close();
		
		if(rb2.selected){
			//txtPath.text=file.nativePath;
			Application.application.myXMLconf.path=file.nativePath;
		}
	}
	CursorManager.removeBusyCursor();
	
	if(rb3.selected){
		Alert.show("OK");
	}else{
		Alert.show(Application.application.myXMLlang.alerts.alert8+"\n"+file.name);
	}
}
private function fThemesResult(event:ResultEvent):void{
	//Alert.show("OK: "+event.result.toString());
	getEnabling();
}
private function fThemesFault(event:FaultEvent):void{
	//Alert.show("Error: "+event.message.toString());
}

private function getEnabling():void{
	var tmp:Boolean=true;
	switch(accOptions.selectedIndex){
		case 2:
			if(dgThemes.selectedIndex<0 || dgVocabulary.dataProvider==null){
				tmp=false;
			}
			break;
	}
	
	cmdImport.enabled = tmp;
}