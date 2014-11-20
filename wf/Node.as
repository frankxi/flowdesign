package wf
{
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import mx.controls.Text;

	public class Node extends Element
	{
		protected var Lable:mx.controls.Text=new Text();
		
		public function Node(iDrawBoard:DrawBoard,iXML:XML=null)
		{
			super(iDrawBoard,iXML);
			this.addChild(Lable);
			Lable.setStyle("textAlign","center");			
	      	this.addEventListener(MouseEvent.CLICK,onclick);
	     	this.addEventListener(MouseEvent.MOUSE_DOWN,onmousedown);
	     	this.addEventListener(MouseEvent.MOUSE_UP,onmouseup);			
		}
		
		private function onclick(event: MouseEvent):void{
			if (myDrawBoard.Status=="") {
				myDrawBoard.UnSelectedAllElement();
				this.Selected=true;
			}
		}
		private function onmousedown(event: MouseEvent):void{
			if (myDrawBoard.Status=="") {
				this.startDrag();
			}else if (myDrawBoard.Status=="routebegin") {
			 	myDrawBoard.fromElement=this;
			} 
		}
		private function onmouseup(event: MouseEvent):void{
			if (myDrawBoard.Status=="") {
				this.stopDrag();
				myDrawBoard.AddUndo();
			}else if (myDrawBoard.Status =="routebegin") {
			 	myDrawBoard.toElement=this;
			} 
		}
	}
}