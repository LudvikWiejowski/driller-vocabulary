// ActionScript file
    import flash.desktop.DockIcon;
    import flash.desktop.NativeApplication;
    import flash.desktop.SystemTrayIcon;
    import flash.display.Loader;
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.events.Event;
    import flash.events.ScreenMouseEvent;
    import flash.net.URLRequest;

	private var openCommand:NativeMenuItem;
	private var pauseCommand:NativeMenuItem;
	private var exitCommand:NativeMenuItem;
	
	private var iconMenu:NativeMenu = new NativeMenu();
	/*[Embed(source="assets/icons/Driller16.png")]
	public var icon16:Class;
	[Embed(source="assets/icons/Driller32.png")]
	private var icon32:Class;
	[Embed(source="assets/icons/Driller48.png")]
	private var icon48:Class;
	[Embed(source="assets/icons/Driller128.png")]
	private var icon128:Class;*/
   
    public function SysTray():void{
        //NativeApplication.nativeApplication.autoExit = false;//ma se aplikace ukoncit, jakmile jsou vsechna okna uzavrena?
        
        var icon:Loader = new Loader();
        
        openCommand = iconMenu.addItem(new NativeMenuItem("Show"));
            openCommand.addEventListener(Event.SELECT, fOpenCommand);
        pauseCommand = iconMenu.addItem(new NativeMenuItem("Pause"));
            pauseCommand.addEventListener(Event.SELECT, function(event:Event):void {
            	if(pauseCommand.checked){
	            	myTimer.start();
	            	pauseCommand.checked=false;            		
            	}else{
	            	myTimer.stop();
	            	pauseCommand.checked=true;            		
            	}
            });            
        exitCommand = iconMenu.addItem(new NativeMenuItem("Exit"));
            exitCommand.addEventListener(Event.SELECT, function(event:Event):void {
                NativeApplication.nativeApplication.icon.bitmaps = [];
                NativeApplication.nativeApplication.exit();
                //fCloseAppMsg();
            });              

        if (NativeApplication.supportsSystemTrayIcon) {
            //NativeApplication.nativeApplication.autoExit = false;
            icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
            icon.load(new URLRequest("assets/icons/Driller16.png"));            
            var systray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
            systray.tooltip = "Driller 1.35";
            systray.menu = iconMenu;
            //systray.addEventListener(ScreenMouseEvent.CLICK,fDoubleClickIcon);
        }

        if (NativeApplication.supportsDockIcon){
            icon.contentLoaderInfo.addEventListener(Event.COMPLETE,iconLoadComplete);
            icon.load(new URLRequest("assets/icons/Driller128.png"));
            var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
            dock.menu = iconMenu;
        }
        //stage.nativeWindow.close();
    }
	private function fOpenCommand(event:Event):void {
    	if(openCommand.label==myXMLlang.buttons.trayshow){
        	myTimer.stop();
            stage.nativeWindow.visible=true;
            openCommand.label=myXMLlang.buttons.trayhide;
            pauseCommand.checked=false;
            stage.nativeWindow.alwaysInFront=true;
        }else{
        	pauseCommand.checked=true;
        	pauseCommand.enabled=true;
            stage.nativeWindow.visible=false;
            openCommand.label=myXMLlang.buttons.trayshow;
     	}
    }    
    private function fDoubleClickIcon(event:Event):void{
		fOpenCommand(event);
    }
    private function iconLoadComplete(event:Event):void
    {
        NativeApplication.nativeApplication.icon.bitmaps =[event.target.content.bitmapData];
        //NativeApplication.nativeApplication.icon.bitmaps =[ new icon16().bitmapData,new icon32().bitmapData,new icon48().bitmapData,new icon128().bitmapData];
    }