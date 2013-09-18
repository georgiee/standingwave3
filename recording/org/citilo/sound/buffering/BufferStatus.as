package org.citilo.sound.buffering {
	[Bindable]
	public class BufferStatus {
		public var filledRatio:Number=0;
		public var cursorRatio:Number=0;
		public var cursorNonCycled:int;
		public var cursor:int;
		public function BufferStatus() {
		}
		
		public function isBufferFull():Boolean{
			return filledRatio>=1;
		}
		public function isBufferFullEnough(minimumFillRatio:Number):Boolean{
			return filledRatio>=minimumFillRatio;
		}
		public function toString():String{
			return "buffer: "+filledRatio.toFixed(2);+" "+cursorRatio.toFixed(2);
		}
		
		public function reset():void{
			filledRatio=0;
			cursorRatio=0;
			cursorNonCycled=0;
		}
	}
}
