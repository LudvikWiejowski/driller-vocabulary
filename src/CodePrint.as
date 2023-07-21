// ActionScript file
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import mx.printing.*;

private var myPrintJob:PrintJob;
private var mySprite:Sprite;
private var myCol:int=0;
private var myRow:int=0;
private var cm:Number=28.4;

[Embed(source="assets/LucidaSansRegular.ttf", fontFamily="LucidaFont")]
private var LucidaFont:Class; // This needs to be declared on this line; like, EXACTLY here!
[Bindable]
private var lucidaFont:Font = new LucidaFont();

private function fPrintIt():void{
	myPrintJob = new PrintJob();
	mySprite = new Sprite();
	myCol=0;
	myRow=0;
	
	try{
		this.alwaysInFront=false;
		if(myPrintJob.start()==false){
			return;
			this.alwaysInFront=true;
		}
		this.alwaysInFront=true;
		if (myPrintJob.orientation == PrintJobOrientation.PORTRAIT)
		{
		    //mySprite.rotation = 90;
		    //Alert.show("You must choose landscape!");
		    //return;
		}
		
		var xmlSel:XMLList;
		
		xmlSel = myXML.wordList.word.(SL=="true");
		for(var i:int=0;i<xmlSel.length();i++){
			fAddCard(xmlSel[i].EN);
			fAddCard(xmlSel[i].CZ);			
		}	
		
		if((myCol+myRow)>0){
			fAddPage();
		}
		
    	myPrintJob.send();
	}catch(error:Error){
		Alert.show(error.message);
	}				
}	            
private function fAddCard(pWord:String):void{
	var txt:TextField=new TextField();
	var newFormat:TextFormat = new TextFormat();
	var shape:Shape=new Shape();
	
	txt.wordWrap=true;
	//txt.border=true;
	txt.height=cm*5;
	txt.width=cm*7;
	txt.x=1*myCol*txt.width;
	txt.y=1*myRow*txt.height;
	
	shape.graphics.lineStyle(1, 0x000000, 1.0, false,LineScaleMode.NONE, CapsStyle.SQUARE)
	shape.graphics.drawRect(txt.x,txt.y,txt.width,txt.height);
	
	newFormat.font=lucidaFont.fontName;
    //newFormat.bold = true;
    newFormat.size = 14;
    newFormat.color = 0x000000;
    newFormat.align = TextFormatAlign.CENTER;
    
    txt.embedFonts=true;
    txt.autoSize=TextFieldAutoSize.CENTER;
	txt.defaultTextFormat=newFormat;
	txt.text=pWord;
	
	txt.y+=((cm*5)/2)-(txt.height/2);
	
	mySprite.addChild(shape);
	mySprite.addChild(txt);
	
	if(myCol==3){
		myCol=0;
		if(myRow==3){
			fAddPage();
			myRow=0;
		}else{
			myRow+=1;
		}
	}else{
		myCol+=1;
	}				
}
private function fAddPage():void{
	//var options:PrintJobOptions = new PrintJobOptions();
	//options.printAsBitmap = true;
	var posY:Number=0;
	if (myPrintJob.orientation == PrintJobOrientation.PORTRAIT)
	{
	    mySprite.rotation = 90;
	    posY=-(cm/1.5);
	}		
	myPrintJob.addPage(mySprite,new Rectangle(0,posY , 29.6*cm, 20.9*cm));
	mySprite=new Sprite();
}