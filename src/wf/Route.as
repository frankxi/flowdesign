package wf
{
	import flash.events.MouseEvent;
	import flash.text.*;
	
	import mx.controls.Label;
	public class Route extends Element
	{
		public var fromElement:Element;
		public var toElement:Element;
		public var fromX:int;
		public var fromY:int;
		public var toX:int;
		public var toY:int;
		private var lable:Label=new  Label();
		public function Route(iDrawBoard:DrawBoard,iXML:XML=null)
		{
			super(iDrawBoard,iXML);
			lable.width=0;
			lable.height=0;
			this.addChild(lable);
			//RouteName="测试线";
	      	this.addEventListener(MouseEvent.CLICK,onclick);
		}

		
		override public function set Name(value: String): void{
			_name = value;
			lable.text=value;
			lable.validateNow();//立即计算文本的尺寸
			//自动根据文本设置尺寸
			lable.width=lable.textWidth+5;
			lable.height=lable.textHeight+2;
			Draw();
		}
		
		override public function Draw():void{
	      	this.graphics.clear();
			this.SetLineColor();
	      	if (fromElement is Element) {
	      		fromX=fromElement.x+fromElement.width/2;
	      		fromY=fromElement.y+fromElement.height/2;
				this.graphics.moveTo(fromX,fromY);
	      	} else {
	      		throw new Error("Route中非法的fromElement")
	      	}
			if (toElement is Element) {
				toX=toElement.x;
				toY=toElement.y;
			}

			if (toElement is WorkNode) {
				//计算终点
				var minDistance:int;	 			
				var distance1:int=Math.sqrt(Math.pow(fromX-toElement.x,2)+Math.pow(fromY-(toElement.y+toElement.height/2),2)); //左
				var distance2:int=Math.sqrt(Math.pow(fromX-(toElement.x+toElement.width),2)+Math.pow(fromY-(toElement.y+toElement.height/2),2)); //右
				var distance3:int=Math.sqrt(Math.pow(fromX-(toElement.x+toElement.width/2),2)+Math.pow(fromY-toElement.y,2));//上
				var distance4:int=Math.sqrt(Math.pow(fromX-(toElement.x+toElement.width/2),2)+Math.pow(fromY-(toElement.y+toElement.height),2));//下
				//取最小距离
				minDistance= Math.min(distance1,distance2,distance3,distance4);
				if (minDistance==distance1) {
					toX=toElement.x;
					toY=toElement.y+toElement.height/2;
				}
				if (minDistance==distance2) {
					toX=(toElement.x+toElement.width);
					toY=(toElement.y+toElement.height/2);
				}
				if (minDistance==distance3) {
					toX=(toElement.x+toElement.width/2);
					toY=toElement.y;
				}
				if (minDistance==distance4) {
					toX=(toElement.x+toElement.width/2);
					toY=(toElement.y+toElement.height);
				}
			}
			if (toElement is EndNode) {
				var distance:int=Math.sqrt(Math.pow((toX-fromX),2)+Math.pow((toY-fromY),2));
				var rate:Number=1-(toElement as EndNode).radio/distance;
				toX=fromX+(toX-fromX)*rate;
				toY=fromY+(toY-fromY)*rate;
			}
			
			this.graphics.lineTo(toX,toY);
			//箭头
			this.graphics.beginFill(0x000000,1);
		  	var slopy:Number;
		  	var cosy:Number;
		  	var siny:Number;
		  	var Par:Number=6;
		  	slopy = Math.atan2((fromY - toY),(fromX - toX));
		  	cosy = Math.cos(slopy);
		  	siny = Math.sin(slopy);
			this.graphics.moveTo(toX,toY);
		  	this.graphics.lineTo(toX + int( Par * cosy - ( Par / 2.0 * siny ) ), toY + int( Par * siny + ( Par / 2.0 * cosy ) ) );
		  	this.graphics.lineTo(toX + int( Par * cosy + Par / 2.0 * siny ),toY - int( Par / 2.0 * cosy - Par * siny ) );
		  	this.graphics.lineTo(toX,toY);	      	
			//this.graphics.drawCircle(toX,toY,3);//圆 
			this.graphics.endFill();
			lable.x=(fromX+toX)/2;
			lable.y=(fromY+toY)/2;
			//Lable.width=100;
			//Lable.height=50;
	      	this.myDrawBoard.ReDrawRelationElement(this);
		}
		private function onclick(event: MouseEvent):void{
			if (myDrawBoard.Status=="") {
				myDrawBoard.UnSelectedAllElement();
				this.Selected=true;
			}
		}
		override public function BuildXml(): XML{
			var xml:XML=new XML("<Route/>");
			xml.@ID=this.ID;
			xml.@Name=this.Name;
			xml.@FromElementID=this.fromElement.ID;
			xml.@ToElementID=this.toElement.ID;
			return xml;
		}		
		override public function ParseFromXml(iXML:XML): int{
			this.fromElement=this.myDrawBoard.GetElementFromID(iXML.@FromElementID);
			this.toElement=this.myDrawBoard.GetElementFromID(iXML.@ToElementID);
			this.ID=iXML.@ID;
			this.Name=iXML.@Name;
			myDrawBoard.setChildIndex(this,0);
			this.Draw();
			return 0;
		}			
		
	}
}