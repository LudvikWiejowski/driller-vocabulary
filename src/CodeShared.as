// ActionScript file
private function isDuplicate(wrd:String):Boolean{
	var xmlSel:XMLList;

	xmlSel = Application.application.myXML.wordList.word.(EN==wrd);
	
	return (xmlSel.length()>0);	
}