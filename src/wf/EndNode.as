package wf
{
	public class EndNode extends Node
	{
		public var radio:int=20;
		public function EndNode(iDrawBoard:DrawBoard,iXML:XML=null)
		{
			super(iDrawBoard,iXML);
			Lable.text="结束";
			Lable.x=-14;
			Lable.y=-9;
	      	Lable.width=30;
	      	Lable.height=20;
		}
		
		override public function Draw(): void{	
	      	this.graphics.clear();
			this.SetLineColor();

			this.graphics.beginFill(0xFF0000,1); 
			this.graphics.moveTo(x,y);
	      	this.graphics.drawCircle(0,0,radio);
	      	this.graphics.endFill();
	      	
	      	this.myDrawBoard.ReDrawRelationElement(this);
		}

		override public function BuildXml(): XML{
			var xml:XML=new XML("<EndNode/>");
			xml.@ID=this.ID;
			xml.@Name=this.Name;
			xml.@x=this.x;
			xml.@y=this.y;
			xml.@Radio=this.radio;
			return xml;
		}		
		override public function ParseFromXml(iXML:XML): int{
			this.ID=iXML.@ID;
			this.Name=iXML.@Name;
			this.x=iXML.@x;
			this.y=iXML.@y;
			this.radio=iXML.@Radio;
			this.Draw();
			return 0;
		}			
		
	}
}