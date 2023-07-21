import mx.controls.Alert;
import mx.events.DataGridEvent;
private var tempValue:String;

private function fInitGrid():void{
	// register itemEditEnd listener that will be called before an item's value is updated
	dgWords.addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditPreEnd, false, 100);
	// register itemEditEnd listener that will be called after an item's value is updated
	dgWords.addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditPostEnd, false, -100);

}
private function itemEditPreEnd(event:DataGridEvent):void
{
   // get a reference to the datagrid
   var grid:DataGrid = event.target as DataGrid;
   // get a reference to the name of the property in the
   // underlying object corresponding to the cell that's being edited
   var field:String = event.dataField;
   // get a reference to the row number (the index in the 
   // dataprovider of the row that's being edited)
   var row:Number = Number(event.rowIndex);

   if (grid != null)
   {
      // gets the value (pre-edit) from the grid's dataprovider
      tempValue = grid.dataProvider.getItemAt(row)[field];
      // you could also use this line to get the value
      // directly from the cellrenderer that's showing the value
      // in the datagrid -- it's the same value.
      // That way you wouldn't need a reference to the DataGrid.
      //tempValue = event.itemRenderer.data[field];
   }
}
private function itemEditPostEnd(event:DataGridEvent):void
{
   var grid:DataGrid = event.target as DataGrid;
   var field:String = event.dataField;
   var row:Number = Number(event.rowIndex);
   if (grid != null)
   {
      // gets the value (post-edit) from the grid's dataprovider
      var newValue:String = grid.dataProvider.getItemAt(row)[field];
      // you could also use this line to get the value
      // directly from the cellrenderer that's showing the value
      // in the datagrid -- it's the same value.
      // That way you wouldn't need a reference to the DataGrid.
      //var newValue = event.itemRenderer.data[field];

      // check if the value has changed
      if (newValue != tempValue)
      {
          // do actions that should happen when the data changes
          fSaveXML();
      }
   }
}