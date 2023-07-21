package com.luwi
{
	import mx.controls.DataGrid;
	//import mx.controls.List;
	import mx.controls.listClasses.*;
	    	
	public class MultiDataGrid extends DataGrid

	{
		
		
		public function MultiDataGrid()
		{
			super();
		}
		override protected function selectItem(item:IListItemRenderer, shiftKey:Boolean, ctrlKey:Boolean, transition:Boolean = true):Boolean {
			return super.selectItem(item, shiftKey, true, transition )
		} 
	}
}