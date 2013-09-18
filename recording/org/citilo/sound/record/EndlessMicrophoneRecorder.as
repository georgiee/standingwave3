package org.citilo.sound.record {
	import flash.utils.ByteArray;
	
	import org.citilo.sound.buffering.BufferStatus;
	import org.citilo.sound.buffering.SoundBufferCircular;
	import org.citilo.sound.utils.SoundActivityWindow;
	import org.osflash.signals.Signal;

	public class EndlessMicrophoneRecorder extends AbstractMicrophoneRecorder {
		public var sampleDataSignal:Signal=new Signal();
		public var silenceSignal:Signal=new Signal();
		private var _pause:Boolean=false;
		private var _firstMicrophoneActivitySamplePosition:int=0;
		private var _soundBuffer:SoundBufferCircular;
		private var _soundActivityWindow:SoundActivityWindow;
		
		[Bindable]
		public var bufferStatus:BufferStatus;

		public function EndlessMicrophoneRecorder(bufferLength:int=8000,silenceLength:int=750) {
			super();
			_soundBuffer=new SoundBufferCircular();
			_soundBuffer.bufferLength = bufferLength +  silenceLength
			_soundActivityWindow=new SoundActivityWindow(_soundBuffer, silenceLength); //set silence delay to q quarter of buffer length
			_soundActivityWindow.silenceSignal.add(silenceSignal.dispatch);
			bufferStatus=_soundBuffer.status;
		}
		public function get activityWindow():SoundActivityWindow{
			return _soundActivityWindow
		}
		public function setBufferSize(ms:Number):void {
			_soundBuffer.bufferLength=ms;
		}
		override protected function handleSampleData(samples:ByteArray):void {
			_soundBuffer.writeSampleBytes(samples);
			_soundActivityWindow.updateLevel(_debugToggle ? 0 : activityLevel);
		}

		public function getBufferContent():ByteArray {
			return _soundBuffer.getBufferContent();
		}

		public function clearBuffer():void {
			_soundBuffer.clear();
		}
		
		override protected function cleanup():void{
			bufferStatus.reset();
			_soundBuffer.reset();
			_soundActivityWindow.reset();
		}
		private var _debugToggle:Boolean=false;
		public function debugToggle():void{
			_debugToggle=!_debugToggle;
			// TODO Auto Generated method stub
			
		}
	}
}
