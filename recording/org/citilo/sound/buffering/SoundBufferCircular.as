package org.citilo.sound.buffering {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.osflash.signals.Signal;

	public class SoundBufferCircular {
		private var _bufferLength:int=44100;
		private var _buffer:ByteArray;
		private var _cursor:int=0;
		private var _cursor_non_cycled:int=0;
		public static const SAMPLE_BYTE_SIZE:int=4;
		private var _sampling:int;
		[Bindable]
		public var filledRatio:Number=0;
		[Bindable]
		public var cursorRatio:Number=0;
		private var _cycled:Boolean=false;
		public var sampleSignal:Signal=new Signal();
		public var cycledSignal:Signal=new Signal();
		public var status:BufferStatus=new BufferStatus;
		public function SoundBufferCircular(sampling:int=44100) {
			_sampling=sampling;
			_buffer=new ByteArray();
			_buffer.endian=flash.utils.Endian.LITTLE_ENDIAN;
		}
		public function get cycled():Boolean{
			return _cycled;
		}
		public function writeSampleBytes(samples:ByteArray):void {
			_cycled=false;
			while (samples.bytesAvailable) {
				var v:Number=samples.readFloat();
				_buffer.position=_cursor * SAMPLE_BYTE_SIZE;
				_buffer.writeFloat(v);
				_cursor+=1;
				_buffer.writeFloat(v);
				_cursor+=1;
				
				_cursor_non_cycled+=2
				if (_cursor >= _bufferLength) {
					_cycled=true;
					_cursor=_cursor % (_bufferLength);
				}
			}
			cursorRatio=_cursor / _bufferLength;
			filledRatio=_buffer.length / SAMPLE_BYTE_SIZE / _bufferLength;
			
			testCycled();
			updateStatus();
			sampleSignal.dispatch();
		}
		
		private function updateStatus():void{
			status.filledRatio=filledRatio;
			status.cursorRatio=cursorRatio;
			status.cursor=_cursor;
			status.cursorNonCycled=_cursor_non_cycled;
		}
		private function testCycled():void{
			if(_cycled){
				cycledSignal.dispatch();
			}
		}
		public function get cursorNonCycled():int{
			return _cursor_non_cycled;
		}
		public function get cursor():int{
			return _cursor;
		}
		public function clear():void{
			_cursor=0;
			_cursor_non_cycled=0;
			_buffer.clear();
			_buffer.position=0;
		}
		public function getBufferContent():ByteArray {
			var BYTES_CURSOR:int=_cursor*SAMPLE_BYTE_SIZE;
			
			var BYTES_RIGHT:int=_buffer.length - BYTES_CURSOR; //LENGTH == CURSOR if not full
			var BYTES_LEFT:int=BYTES_CURSOR;
			
			var output:ByteArray=new ByteArray;
			output.endian=flash.utils.Endian.LITTLE_ENDIAN;
			output.writeBytes(_buffer, BYTES_CURSOR, BYTES_RIGHT);
			output.writeBytes(_buffer, 0, BYTES_LEFT);
			output.position=0;
			
			return output;
		}

		public function isFilled():Boolean {
			return filledRatio >= 1;
		}
		
		public function get bufferRealLength():int {
			return _buffer.length/SAMPLE_BYTE_SIZE;
		}
		public function get bufferLength():int {
			return _bufferLength;
		}
		public function set bufferLength(milliseconds:int):void {
			_bufferLength=2*_sampling * milliseconds/1000;
		}
		
		public function reset():void{
			clear();
		}
	}
}
