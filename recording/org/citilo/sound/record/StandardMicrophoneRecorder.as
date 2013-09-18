package org.citilo.sound.record {
	import flash.media.Microphone;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class StandardMicrophoneRecorder extends AbstractMicrophoneRecorder {
		private var _recordData:ByteArray;
		public function StandardMicrophoneRecorder() {
			super();
			_recordData=new ByteArray();
			_recordData.endian=flash.utils.Endian.LITTLE_ENDIAN
		}
		
		override protected function handleSampleData(samples:ByteArray):void {
			while (samples.bytesAvailable) {
				var v:Number=samples.readFloat();
				_recordData.writeFloat(v);
				_recordData.writeFloat(v);
			}
		}
		
		public function prepare():void{
			_recordData.position = 0;
			this.record();
			this.pause();
		}
		public function get recordData():ByteArray{
			_recordData.position = 0;
			return _recordData;
		}
	}
}
