package wf
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	
	import mx.containers.Canvas;
	//[Event(name="myStatusChanged", type="flash.events.Event")]
	public class DrawBoard extends Canvas
	{
		private var _status:String="";
		private var tmpElement:Element;
		public static  const STATUSCHANGED:String="myStatusChanged";
		public static  const SELECT_CHANGED:String="SelectChanged";
		public var selectedElement:Element;
		public var fromElement:Element;
		public var toElement:Element;
		public var maxID:int=0;
		public var undoXML:XML=new XML("<UndoList><WorkFlow/></UndoList>");
		public var redoXML:XML=new XML("<RedoList/>");
		public function DrawBoard()
		{
			super();
			this.setStyle("backgroundColor","0xFFFFFF");
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.addEventListener(KeyboardEvent.KEY_UP,onKeyUp,true);
		}
		public function get Status(): String{
			return _status;
		}
		
		public function set Status(value: String): void{
			this._status = value;
			var e:Event =new Event(STATUSCHANGED);
			dispatchEvent(e);
		}
		public function AddUndo() :void {
			undoXML.appendChild(new XML(this.BuildXml().toXMLString()));
		}
		public function Undo() :void {
			var workflows:XMLList= undoXML..WorkFlow;
			if (workflows.length()>1) {
				var index:int=workflows.length()-2;
				var xml:XML=new XML(workflows[index+1].toString());
				redoXML.appendChild(xml);
				delete workflows[index+1];
				this.ParseFromXml(workflows[index]);
			}
		}
		public function Redo() :void {
			var workflows:XMLList= redoXML..WorkFlow;
			if (workflows.length()>0) {
				var index:int=workflows.length()-1;
				var xml:XML=new XML(workflows[index].toString());
				undoXML.appendChild(xml);
				this.ParseFromXml(workflows[index]);
				delete redoXML.WorkFlow[index];
			}
		}

		private function onClick(event: MouseEvent):void {
			var newElement:Element;   
			if (this.Status=="worknode"){
		       newElement = new WorkNode(this);                 
		 	}else if (this.Status=="beginnode"){
		       newElement = new BeginNode(this);                  
			}else if (this.Status=="endnode"){
		       newElement = new EndNode(this);                 
			}
			if (newElement!=null) {
				newElement.x=mouseX;
				newElement.y=mouseY;
				if (this.selectedElement!=null) {
					this.selectedElement.Selected=false;
				}
				newElement.Selected=true;
				this.AddUndo();
			}
			this.Status="";
		}

		private function onMouseUp(event: MouseEvent):void{
			if (this.Status=="routebegin"){
				var nodeCheck:Boolean;
				nodeCheck=((this.fromElement is WorkNode) && (this.toElement is WorkNode));//业务环节-业务环节
				nodeCheck=nodeCheck || ((this.fromElement is BeginNode) && (this.toElement is WorkNode));//开始环节-业务环节
				nodeCheck=nodeCheck || ((this.fromElement is WorkNode) && (this.toElement is EndNode));//业务环节-结束环节
				
				nodeCheck=nodeCheck && tmpElement is Route;
				if (nodeCheck==true) {
					var myroute:Route=tmpElement as Route;
					myroute.fromElement=this.fromElement;
					myroute.toElement=this.toElement;
					myroute.Name="测试线";
					myroute.Draw();
					AddUndo();
			  	}
			  	else
			  	{
			  		if (tmpElement!=null) { 
			  			this.removeChild(tmpElement);
			  		}
			  	}
				tmpElement=null;
				this.fromElement=null;
				this.toElement=null;
				this.Status="";
			}
		}
		private function onMouseMove(event: MouseEvent):void{
			if (this.Status=="routebegin"){
				var myroute:Route;
				if (this.fromElement is Element) {
					if (tmpElement is Route) {
				  		myroute=tmpElement as Route;
				  	}else{
				       myroute=new Route(this);                  
				       this.setChildIndex(myroute,0);
				       myroute.fromElement=this.fromElement;
				       tmpElement=myroute;
				  	}
			       myroute.toX=mouseX;
			       myroute.toY=mouseY;
			       myroute.Draw();
			  	}
			}
		}
		
		public function UnSelectedAllElement():void{
			for each (var myelement:Element in this.getChildren()) {
				if (myelement.Selected) {
					myelement.Selected=false;
				}
			}
		}
		
		public function DeleteElement(iElement:Element):void{
			this.removeChild(iElement);
			AddUndo();
		}
		
		public function ReDrawRelationElement(iElement:Element):void{
			if ((iElement is WorkNode) || (iElement is BeginNode) || (iElement is EndNode)) {
				for each (var myelement:Element in this.getChildren()) {
					if (myelement is Route) {
						var myroute:Route=myelement as Route;
						if ((myroute.fromElement==iElement)||(myroute.toElement==iElement)) {
							myroute.Draw();
						}
					}
				}
			}
		}
		private function onKeyUp(event:KeyboardEvent):void {
			//Alert.show( event.keyCode.toString());
			if (event.keyCode==46){//Delete
				this.DeleteElement(this.selectedElement);
			}
			else if ((event.keyCode==90) && event.ctrlKey){//Ctrl+Z Undo
				this.Undo();
			}
			else if ((event.keyCode==89) && event.ctrlKey){//Ctrl+Y Redo
				this.Redo();
			}
		}
		public function BuildXml(): XML{
			var xml:XML=new XML("<WorkFlow/>");
			for each (var myelement:Element in this.getChildren()) {
				xml.appendChild(myelement.BuildXml());
			}
			return xml;
		}
		public function ParseFromXml(iXML:XML): void{
			this.Clear();
			var newElementClass : Class
			var myelement:Element;
         	var domain : ApplicationDomain = ApplicationDomain.currentDomain;
         	var elementName:String="";
         	//先解析Node，再解析Route
			var elements:XMLList=iXML..BeginNode+iXML..EndNode+iXML..WorkNode+iXML..Route;
			for each (var elementXml:XML in elements) {
				elementName="wf."+elementXml.name();//动态创建类的名称需要加包名
	            if(domain.hasDefinition(elementName))
	            {
	            	//动态创建类
                    newElementClass = domain.getDefinition(elementName) as Class;
                    myelement = new newElementClass(this,elementXml);
                    //动态调用方法
                    var fnc_draw:Function=myelement["Draw"];
	            	fnc_draw.call(myelement);
	            }
			}
		}
		public function GetNewElementID():int{
			return maxID+1;
		}
		public function Clear():void{
			this.removeAllChildren();
		}
		public function GetElementFromID(iID:int):Element{
			for each (var myelement:Element in this.getChildren()) {
				if (myelement.ID==iID) {
					return myelement;
				}
			}
			return null;
		}
	}
}