package wf
{

	public class WorkNode extends Node
	{
		private var _nodetype:String="";
		public function WorkNode(iDrawBoard:DrawBoard,iXML:XML=null)
		{
			super(iDrawBoard,iXML);
			this.width=100;
			this.height=30;			
		}

		public function get NodeType(): String{
			return _nodetype;
		}
		
		public function set NodeType(value: String): void{
			this._nodetype = value;
		}
		
		override public function set Name(value: String): void{
			this._name = value;
			Lable.text=value;
		}
		
		override public function Draw(): void{	
	      	this.graphics.clear();
			this.SetLineColor();
			
	      	Lable.width=width;
	      	Lable.height=height;
    	
			this.graphics.beginFill(0xFFFFFF,1); 
			this.graphics.moveTo(x,y);
	      	this.graphics.drawRect(0,0,width,height);
	      
	      	this.graphics.endFill();
			this.myDrawBoard.ReDrawRelationElement(this);			
		}
		override public function BuildXml(): XML{
			var xml:XML=new XML("<WorkNode/>");
			xml.@ID=this.ID;
			xml.@Name=this.Name;
			xml.@NodeType=this.NodeType;
			xml.@x=this.x;
			xml.@y=this.y;
			xml.@Width=this.width;
			xml.@Height=this.height;
			return xml;
		}		
		override public function ParseFromXml(iXML:XML): int{
			this.ID=iXML.@ID;
			this.Name=iXML.@Name;
			this.x=iXML.@x;
			this.y=iXML.@y;
			this.NodeType=iXML.@NodeType;
			this.width=iXML.@Width;
			this.height=iXML.@Height;
			this.Draw();
			return 0;
		}			
		
	}
}