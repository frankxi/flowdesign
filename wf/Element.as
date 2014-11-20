package wf
{
	import mx.core.UIComponent;
	public class Element extends UIComponent
	{
		public var myDrawBoard:DrawBoard;
		public static  const LINE_SELECT_COLOR:int=0x0000FF; 
		public static  const LINE_UNSELECT_COLOR:int=0x000000; 
		private var _selected:Boolean;
		private var _id:int=0;
		protected var _name:String="";
		public function Element(iDrawBoard:DrawBoard,iXML:XML=null)
		{
			super();
			this.myDrawBoard=iDrawBoard;
			iDrawBoard.addChild(this);
			iDrawBoard.setChildIndex(this,iDrawBoard.getChildren().length-1);
			if (iXML==null) {
				ID=iDrawBoard.GetNewElementID();
			}else{
				ParseFromXml(iXML);
			}
			if (ID>iDrawBoard.maxID) {
				iDrawBoard.maxID=ID;
			}
			this.focusEnabled=true;
			this.useHandCursor=true;
			this.buttonMode=true;
			this.mouseChildren=false;
			//this.cursorManager.setCursor
		}
		public function get ID(): int{
			return _id;
		}
		
		public function set ID(value: int): void{
			this._id = value;
		}

		public function get Name(): String{
			return _name;
		}
		
		public function set Name(value: String): void{
			this._name = value;
		}

		public function get Selected(): Boolean{
			return _selected;
		}
		
		public function set Selected(value: Boolean): void{
			if (_selected!=value) {
				this._selected = value;
				if (value==false) {
					myDrawBoard.selectedElement=null;
				} else {
					this.setFocus();
					myDrawBoard.selectedElement=this;
				}
				Draw();
				var evt:ElementEvent=new ElementEvent(ElementEvent.ELEMENT_SELECT_CHANGED);
				evt.srcElement=this;
				myDrawBoard.dispatchEvent(evt);
			}
		}
		
		public function SetLineColor():void{
			if (Selected==true) {
				this.graphics.lineStyle(2,LINE_SELECT_COLOR);
			} else {
				this.graphics.lineStyle(1,LINE_UNSELECT_COLOR);
			}
		}
		public function Draw(): void{}
		public function BuildXml(): XML{return null;}		
		public function ParseFromXml(iXML:XML): int{return 0;}		
		
	}
}